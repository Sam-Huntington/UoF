
using DataFrames
using JuMP, Gurobi
using Gadfly

m = Model(solver=GurobiSolver())

iTimeVaryingInputData = readtable("Input Data by timestep.csv", header=true) # 24x2, hours, non-deferrable loads (baseload)
iGenLoad = readtable("BatteryModel_GenLoad.csv",header=true)
iPrices = readtable("BatteryModel_Prices.csv",header=true)
iParameters = readtable("BatteryModel_Parameters.csv",header=true)
iScheduledLoadsData = readtable("SchedulableLoads_Parameters.csv", header=true) 

T = length(iPrices[:Hour]) 
pHours = iPrices[:Hour][1:T]

pBuyEnergy = iPrices[:pBuy_Energy][1:T]
pSellEnergy = iPrices[:pSell_Energy][1:T]
pNonControllableLoad = iGenLoad[:pNonControllableLoad][1:T]

pDelta = 1 #duration of time period (hr)
pCCurtail = 0.25 #cost of curtailment - will depend on the scenario ($/KWH)

pNonControllableLoad = iTimeVaryingInputData[:,2]
pEnergyBuyPrices = iTimeVaryingInputData[:,3]
pTempAir = iTimeVaryingInputData[:,4]

pGenAssets = [15 5 2.5 2.5] # this is where you specify the technology choices; will ultimately take this from dataframes


#NON-CONTROLLABLE GEN PARAMETERS
pPV_Capacity = pGenAssets[1] #this is the total capacity of the PV panels 
pPV_Generation = pGenAssets[1]*iGenLoad[:pPV_Generation][1:T]
pOtherNonControllableGen = iGenLoad[:pOtherNonControllableGen][1:T]  # declaring non-PV based non-controllable generation
@defExpr(pTotalNonControllableGen[t=1:T], pPV_Generation[t]+pOtherNonControllableGen[t]) #total non-controllable generation = PV + other


#SCHEDULABLE LOADS PARAMETERS
pLoadTime_CW = iScheduledLoadsData[1,2]
pFinishTime_CW = iScheduledLoadsData[2,2]
pkWh_CW = iScheduledLoadsData[3,2]
pMaxLoad_CW = iScheduledLoadsData[4,2]

pLoadTime_CD = iScheduledLoadsData[1,3]
pFinishTime_CD = iScheduledLoadsData[2,3]
pkWh_CD = iScheduledLoadsData[3,3]
pMaxLoad_CD = iScheduledLoadsData[4,3]

pLoadTime_DW = iScheduledLoadsData[1,3]
pFinishTime_DW = iScheduledLoadsData[2,3]
pkWh_DW = iScheduledLoadsData[3,3]
pMaxLoad_DW = iScheduledLoadsData[4,3]


#THERMAL PARAMETERS
pDeadband = 2
pSetpoint = 30
pCapacitance = 2 #heat capacity of building interior (kWh/C) 
pResistance = 2 #thermal resistance of between interior and exterior (C/kWh) 
pCOP = 3 #COP of heat pump (eventually convert to piecewise linear)
pTempDevPenalty = 10 #temperature deviation penalty ($/deg C)
;

#SCHEDULABLE LOADS
@defVar(m, 0<=vCW[t=1:T]<=pMaxLoad_CW)
@defVar(m, 0<=vCD[t=1:T]<=pMaxLoad_CD)
@defVar(m, 0<=vDW[t=1:T]<=pMaxLoad_DW)

#THERMAL LOADS
@defVar(m, sTempInt[t=1:T] >=0)                 # internal home temp (state variable)
@defVar(m, sExtLosses[t=1:T])                   # losses/gains from thermal leakage through building shell
@defVar(m, sIntGains[t=1:T])                    # internal gains
@defVar(m, 0 <= vPowerHVAC[t=1:T] <= 5)         # HVAC power draw (continuous, 5kW max) | allow negative values = cooling???
@defVar(m, vTempLow[t=1:T]>=0)                                       # penalty for temp deviations
@defVar(m, vTempHigh[t=1:T]>=0) 

;

#SCHEDULABLE LOADS
@addConstraint(m, pkWh_CW==sum{vCW[t],t=pLoadTime_CW:pFinishTime_CW}) 
@addConstraint(m, pkWh_CD==sum{vCD[t],t=pLoadTime_CD:pFinishTime_CD}) 
@addConstraint(m, pkWh_DW==sum{vDW[t],t=pLoadTime_DW:pFinishTime_DW}) 
@defExpr(vScheduledLoads[t=1:T], vCW[t]+vCD[t]+vDW[t])

#THERMAL LOADS
for t = 1
    @addConstraint(m, sTempInt[t]==pSetpoint)                         #starting temp
end

for t = 2:T
    @addConstraint(m,sTempInt[t-1]+((sExtLosses[t-1]+sIntGains[t-1])/pCapacitance)==sTempInt[t]) # temp evolution | temp(t) = temp(t-1) + (gains - losses)/heat capacity    
end

for t = 1:T
    @addConstraint(m, ((pTempAir[t] - sTempInt[t])/(pCapacitance*pResistance))==sExtLosses[t])   #losses from thermal leakage
    @addConstraint(m, ((pCOP*vPowerHVAC[t])/pCapacitance)==sIntGains[t])                         #interanl temp gain from heat pump
    @addConstraint(m, (pSetpoint-pDeadband)-vTempLow[t]<=sTempInt[t])
    @addConstraint(m, (pSetpoint+pDeadband)+vTempHigh[t]>=sTempInt[t])
end
@defExpr(vThermalLoad[t=1:T], vPowerHVAC[t])
@defExpr(vTotalTempDev[t=1:T],vTempHigh[t]+vTempLow[t])

#BATTERY

#constraining state of charge to appropriate limits
@addConstraint(m, vBattSOC[1] == pBattInitialSOC)

for t = 1:T
    @addConstraint(m, vBattSOC[t] <= pBattSOCMax)
    @addConstraint(m, vBattSOC[t] >= pBattSOCMin)
end 

# defining charging losses and efficiency
@defExpr(sBattDischargeLosses[t=1:T], pBattDischargeEff*vBattDischarge[t])
@defExpr(sBattChargeLosses[t=1:T], pBattChargeEff*vBattCharge[t])
@defExpr(sBattLosses[t=1:T], sBattChargeLosses[t] + sBattDischargeLosses[t])

@defExpr(sBattOutput[t=1:T], vBattDischarge[t] - sBattDischargeLosses[t])
@defExpr(sBattInput[t=1:T], vBattCharge[t] + sBattChargeLosses[t])
        

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
@defVar(m, vPowerCurtail[t=1:T] >= 0) #curtailed power
@defVar(m, vPowerConsumed[t=1:T] >=0) # consumed power
@defVar(m, vPowerImportorExport[t=1:T], Bin)
@defVar(m, vPowerPurchased[t=1:T] >=0) # power ultimately purchased from utility
@defVar(m, sPowerExport[t=1:T] >= 0)

@defExpr(sPowerProduced[t=1:T], pTotalNonControllableGen[t]) # + vBattDischarge[t])

for t=1:T
    
    @addConstraint(m, pNonControllableLoad[t]+vScheduledLoads[t]+vThermalLoad[t]==vPowerConsumed[t])  #vBattCharge[t]) 
    
    @addConstraint(m, vPowerConsumed[t]+sPowerExport[t]==vPowerPurchased[t]+sPowerProduced[t])
    #@addConstraint(m, sPowerProduced[t]-vPowerConsumed[t]==sPowerExport[t])
        
    @addConstraint(m, sPowerExport[t] <= 10000000*(1-vPowerImportorExport[t]))
    @addConstraint(m, vPowerPurchased[t] <= 10000000*(vPowerImportorExport[t]))

end

#Consumed = sum(loads) + BatteryCharge
#Generated = PV + BattDischarge
#Provided = Generated + Purchased
#Provided = Consumed + Sales
#Purchased = Generation - Consumed
#Sales = Generation - Consumed


pSellEnergy;

#@defExpr(TotalCost,sum{pDelta*pBuyEnergy[t]*sPowerPurchase[t] + pDelta*pSellEnergy[t]*sPowerExport[t],t=1:T})
#@defExpr(TotalCost, sum{pBuyEnergy[t]*vPowerConsumed[t],t=1:T}+pTempDevPenalty*sum{vTotalTempDev[t],t=1:T}) #WORKS!
@defExpr(TotalCost, sum{pBuyEnergy[t]*vPowerPurchased[t],t=1:T}+pTempDevPenalty*sum{vTotalTempDev[t],t=1:T})
@defExpr(TotalRevenue, sum{pSellEnergy[t]*sPowerExport[t],t=1:T})
;

@setObjective(m, Min, TotalCost - TotalRevenue)


# Print outputs
status = solve(m)
status
println("Objective value: ", getObjectiveValue(m))

A = hcat(pBuyEnergy[1:T],pSellEnergy[1:T],getValue(vPowerConsumed[1:T]),getValue(sPowerProduced[1:T]),getValue(vPowerPurchased[1:T]),getValue(sPowerExport[1:T]))
#B = sum{vPowerConsumed[t],t=1:T}

plot(layer(x=1:24,y=getValue(sPowerProduced[1:24]) ,Geom.point, Geom.line, Theme(default_color=colorant"yellow")),
layer(x=1:24,y=getValue(vPowerConsumed[1:24]) ,Geom.point, Geom.line, Theme(default_color=colorant"blue")),
layer(x=1:24,y=getValue(sPowerExport[1:24]) ,Geom.point, Geom.line, Theme(default_color=colorant"orange")))

