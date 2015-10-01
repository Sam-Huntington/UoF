
using DataFrames
using JuMP, Gurobi
using Gadfly

m = Model(solver=GurobiSolver())


iGenLoad = readtable("BatteryModel_GenLoad.csv",header=true)
iPrices = readtable("BatteryModel_Prices.csv",header=true)
iParameters = readtable("BatteryModel_Parameters.csv",header=true)
iScheduledLoadsData = readtable("SchedulableLoads_Parameters.csv", header=true) 
iThermalParameters = readtable("Thermal_Parameters.csv", header=true) 

T = length(iPrices[:Hour]) 
pHours = iPrices[:Hour][1:T]

pBuyEnergy = iPrices[:pBuy_Energy][1:T]
pSellEnergy = iPrices[:pSell_Energy][1:T]
pNonControllableLoad = iGenLoad[:pNonControllableLoad][1:T]


pDelta = 1 #duration of time period (hr)
pCCurtail = 0.25 #cost of curtailment - will depend on the scenario ($/KWH)
pGenAssets = [5 5 2.5 2.5] # this is where you specify the technology choices; will ultimately take this from dataframes
#genAssets = [pPVbank pBatt_NominalE pBatt_DischargeCapacity pBatt_ChargeCapacity]
#pGenAssets = [15 5 2.5 2.5]

#NON-CONTROLLABLE GEN PARAMETERS
pPV_Capacity = pGenAssets[1] #this is the total capacity of the PV panels 
pPV_Generation = pGenAssets[1]*iGenLoad[:pPV_Generation][1:T]
pOtherNonControllableGen = iGenLoad[:pOtherNonControllableGen][1:T]  # declaring non-PV based non-controllable generation
@defExpr(pTotalNonControllableGen[t=1:T], pPV_Generation[t]+pOtherNonControllableGen[t]) #total non-controllable generation = PV + other


#SCHEDULABLE LOADS PARAMETERS
pLoadTime_CW = iScheduledLoadsData[1,:pLoadTime_CW]
pFinishTime_CW = iScheduledLoadsData[1,:pFinishTime_CW]
pkWh_CW = iScheduledLoadsData[1,:pkWh_CW]
pMaxLoad_CW = iScheduledLoadsData[1,:pMaxLoad_CW]

pLoadTime_CD = iScheduledLoadsData[1,:pLoadTime_CD]
pFinishTime_CD = iScheduledLoadsData[1,:pFinishTime_CD]
pkWh_CD = iScheduledLoadsData[1,:pkWh_CD]
pMaxLoad_CD = iScheduledLoadsData[1,:pMaxLoad_CD]

pLoadTime_DW = iScheduledLoadsData[1,:pLoadTime_DW]
pFinishTime_DW = iScheduledLoadsData[1,:pFinishTime_DW]
pkWh_DW = iScheduledLoadsData[1,:pkWh_DW]
pMaxLoad_DW = iScheduledLoadsData[1,:pMaxLoad_DW]


#THERMAL PARAMETERS
pOutdoorTemp = iGenLoad[:pOutdoorTemp][1:T]
pSetpoint = iGenLoad[:pSetPoint][1:T]
pDeadband = iThermalParameters[1,:pDeadband]
pCapacitance = iThermalParameters[1,:pCapacitance]              #heat capacity of building interior (kWh/C) 
pResistance = iThermalParameters[1,:pResistance]                #thermal resistance of between interior and exterior (C/kWh) 
pCOP = iThermalParameters[1,:pCOP]                              #COP of heat pump (eventually convert to piecewise linear)
pMaxPower = iThermalParameters[1,:pMaxPower]
pTempDevPenalty = iThermalParameters[1,:pTempDevPenalty]        #temperature deviation penalty ($/deg C)


#BATTERY PARAMETERS
pBattNominalE = pGenAssets[2]
pBattDischargeCapacity = pGenAssets[3] #installed battery discharge power capacity (KW)
pBattChargeCapacity = pGenAssets[4] #installed battery charge power capacity (KW)

pBattDischargeEff = iParameters[1,:pBatt_DischargeEff] #pBatt_DischargeEff Efficiency of battery discharge
pBattChargeEff = iParameters[1,:pBatt_ChargeEff] #pBattChargeEff Efficiency of battery charge
pBattCDeg = iParameters[1,:pBatt_CDeg] #pBattCDeg battery degradation cost ($) 
pBattInitialSOC = iParameters[1,:pBatt_InitialSOC] #pBatt_InitialSOC initial state of charge 
pBattSOCMax = iParameters[1,:pBatt_SOCMax] #pBatt_SOCMax maximum SOC
pBattSOCMin = iParameters[1,:pBatt_SOCMin] #pBatt_SOCMin minimum SOC
;

#SCHEDULABLE LOADS
@defVar(m, 0<=vCW[t=1:T]<=pMaxLoad_CW)
@defVar(m, 0<=vCD[t=1:T]<=pMaxLoad_CD)
@defVar(m, 0<=vDW[t=1:T]<=pMaxLoad_DW)

#THERMAL LOADS
@defVar(m, sTempInt[t=1:T] >=0)                 # internal home temp (state variable)
@defVar(m, sExtLosses[t=1:T])                   # losses/gains from thermal leakage through building shell
@defVar(m, sIntGains[t=1:T])                    # internal gains
@defVar(m, 0 <= vPowerHVAC[t=1:T] <= pMaxPower)         # HVAC power draw (continuous, 5kW max) | allow negative values = cooling???
@defVar(m, vTempLow[t=1:T]>=0)                                       # penalty for temp deviations
@defVar(m, vTempHigh[t=1:T]>=0) 

#BATTERY
@defVar(m, pBattSOCMin <= vBattSOC[t=1:T] <= pBattSOCMax) # SOC of battery ----- SB!!! Maybe make this a state variable, not a decision variable.
@defVar(m, vBattSOH[t=1:T] >= 0) #State of health of battery (degradation costs)
@defVar(m, vBattCharge[t=1:T] >= 0) #battery charging power
@defVar(m, vBattDischarge[t=1:T] >= 0) #battery discharging power
@defVar(m, vBattCorD[t=1:T], Bin) #batt charging or discharging binary variable. 

#DEMAND BALANCE
@defVar(m, vPowerCurtail[t=1:T] >= 0) #curtailed power
@defVar(m, vPowerConsumed[t=1:T] >=0) # consumed power
@defVar(m, vPowerImportorExport[t=1:T], Bin)
@defVar(m, vPowerPurchased[t=1:T] >=0) # power ultimately purchased from utility
@defVar(m, sPowerExport[t=1:T] >= 0)
;

#SCHEDULABLE LOADS
@addConstraint(m, pkWh_CW==sum{vCW[t],t=pLoadTime_CW:pFinishTime_CW}) 
@addConstraint(m, pkWh_CD==sum{vCD[t],t=pLoadTime_CD:pFinishTime_CD}) 
@addConstraint(m, pkWh_DW==sum{vDW[t],t=pLoadTime_DW:pFinishTime_DW}) 
@defExpr(vScheduledLoads[t=1:T], vCW[t]+vCD[t]+vDW[t])

#THERMAL LOADS
for t = 1
    @addConstraint(m, sTempInt[t]==pSetpoint[t])                         #starting temp
end

for t = 2:T
    @addConstraint(m,sTempInt[t-1]+((sExtLosses[t-1]+sIntGains[t-1])/pCapacitance)==sTempInt[t]) # temp evolution | temp(t) = temp(t-1) + (gains - losses)/heat capacity    
end

for t = 1:T
    @addConstraint(m, ((pOutdoorTemp[t] - sTempInt[t])/(pCapacitance*pResistance))==sExtLosses[t])   #losses from thermal leakage
    @addConstraint(m, ((pCOP*vPowerHVAC[t])/pCapacitance)==sIntGains[t])                         #interanl temp gain from heat pump
    @addConstraint(m, (pSetpoint[t]-pDeadband)-vTempLow[t]<=sTempInt[t])
    @addConstraint(m, (pSetpoint[t]+pDeadband)+vTempHigh[t]>=sTempInt[t])
end
@defExpr(vThermalLoad[t=1:T], vPowerHVAC[t])
@defExpr(vTotalTempDev[t=1:T],vTempHigh[t]+vTempLow[t])

#BATTERY

#constraining state of charge to appropriate limits
@addConstraint(m, vBattSOC[1] == pBattInitialSOC)


# defining charging losses and efficiency
@defExpr(sBattDischargeLosses[t=1:T], pBattDischargeEff*vBattDischarge[t])
@defExpr(sBattChargeLosses[t=1:T], pBattChargeEff*vBattCharge[t])
@defExpr(sBattLosses[t=1:T], sBattChargeLosses[t] + sBattDischargeLosses[t])

@defExpr(sBattOutput[t=1:T], vBattDischarge[t] - sBattDischargeLosses[t])
@defExpr(sBattInput[t=1:T], vBattCharge[t] + sBattChargeLosses[t])

if pBattNominalE > 0
    for t=1:T
        @addConstraint(m, vBattCharge[t]<=pBattChargeCapacity)
        @addConstraint(m, vBattDischarge[t]<=pBattDischargeCapacity)
    end
else
    for t=1:T
        @addConstraint(m, vBattCharge[t]==0)
        @addConstraint(m, vBattDischarge[t]==0)
    end
end
    
if pBattNominalE > 0
    for t = 2:T  
        @addConstraint(m, vBattSOC[t-1] - (pDelta/pBattNominalE)*(sBattOutput[t-1] - sBattInput[t-1] + sBattLosses[t-1]) == vBattSOC[t])
    end 
else 
    for t = 2:T
        @addConstraint(m, vBattSOC[t] == vBattSOC[1])
    end 
end 

#define charge or discharge constraint
for t=1:T
    @addConstraint(m, vBattCharge[t] <= 1000000*vBattCorD[t])
    @addConstraint(m, vBattDischarge[t] <= 1000000*(1-vBattCorD[t]))
end


#DEMAND BALANCE

@defExpr(sPowerProduced[t=1:T], pTotalNonControllableGen[t] + vBattDischarge[t])

for t=1:T
    
    @addConstraint(m, pNonControllableLoad[t]+vScheduledLoads[t]+vThermalLoad[t]+vBattCharge[t]==vPowerConsumed[t])     
    @addConstraint(m, vPowerConsumed[t]+sPowerExport[t]==vPowerPurchased[t]+sPowerProduced[t])
    
    #cannot import and export at the same time
    @addConstraint(m, sPowerExport[t] <= 10000000*(1-vPowerImportorExport[t]))
    @addConstraint(m, vPowerPurchased[t] <= 10000000*(vPowerImportorExport[t]))

end

#@defExpr(TotalCost,sum{pDelta*pBuyEnergy[t]*sPowerPurchase[t] + pDelta*pSellEnergy[t]*sPowerExport[t],t=1:T})
#@defExpr(TotalCost, sum{pBuyEnergy[t]*vPowerConsumed[t],t=1:T}+pTempDevPenalty*sum{vTotalTempDev[t],t=1:T}) #WORKS!
@defExpr(TotalCost, sum{pBuyEnergy[t]*vPowerPurchased[t],t=1:T}+pTempDevPenalty*sum{vTotalTempDev[t],t=1:T})
@defExpr(TotalRevenue, sum{pSellEnergy[t]*sPowerExport[t],t=1:T})
@defExpr(TotalPowerProvided[t=1:T],vPowerConsumed[t]+sPowerExport[t])
;

@setObjective(m, Min, TotalCost - TotalRevenue);

# Print outputs
status = solve(m)
status
println("Objective value: ", getObjectiveValue(m))

# Build output array
aTemp = hcat([1:T],
        pBuyEnergy[1:T],
        pSellEnergy[1:T],
        getValue(vPowerConsumed[1:T]),
        getValue(sPowerProduced[1:T]),
        getValue(vPowerPurchased[1:T]),
        getValue(sPowerExport[1:T]),
        getValue(vBattDischarge[1:T]),
        getValue(vBattCharge[1:T]))

dfUsage = convert(DataFrame, aTemp)

rename!(dfUsage, {:x1=>:Buy_Energy, 
            :x2=>:Sell_Energy, 
            :x3=>:Power_Consumed,
            :x4=>:Power_Produced,
            :x5=>:Power_Purchased,
            :x6=>:Power_Export,
            :x7=>:Batt_Discharge,
            :x8=>:Batt_Charge,
            })

writetable("outputs2.csv",dfUsage)

aTemp

aTemp2 = hcat([1:T],
        pSetpoint[1:T],
        pOutdoorTemp[1:T],
        getValue(sTempInt[1:T]),
        getValue(vPowerHVAC[1:T]))

#aTemp2

dfTemp = convert(DataFrame, aTemp2)

rename!(dfTemp, {:x1=>:Hour,
                :x2=>:SetPoint,
                :x3=>:Outdoor_Temp,
                :x4=>:Indoor_Temp,
                :x5=>:Heat_Pump_kW})

writetable("Temp outputs.csv", dfTemp)

# Check if file is open and close it so it can be updated

    #f = open("outputs2.csv")
    #isopen(f)

plot(layer(x=1:24,y=getValue(sPowerProduced[1:T]) ,Geom.point, Geom.line, Theme(default_color=colorant"yellow")),
layer(x=1:24,y=getValue(vPowerConsumed[1:T]) ,Geom.point, Geom.line, Theme(default_color=colorant"blue")),
layer(x=1:24,y=getValue(sPowerExport[1:T]) ,Geom.point, Geom.line, Theme(default_color=colorant"orange")),
layer(x=1:24,y=getValue(vBattCharge[1:T]) ,Geom.point, Geom.line, Theme(default_color=colorant"green")),
layer(x=1:24,y=getValue(vBattDischarge[1:T]) ,Geom.point, Geom.line, Theme(default_color=colorant"red")))


plot(layer(x=1:24,y=getValue(sPowerProduced[1:24]) ,Geom.point, Geom.line, Theme(default_color=colorant"yellow")),
layer(x=1:24,y=getValue(TotalPowerProvided[1:24]) ,Geom.point, Geom.line, Theme(default_color=colorant"blue")),
layer(x=1:24,y=getValue(vPowerHVAC[1:24]) ,Geom.point, Geom.line, Theme(default_color=colorant"orange")))



