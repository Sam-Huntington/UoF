
using DataFrames
using JuMP, Gurobi

function dr_dre(path)

    m = Model(solver=GurobiSolver())

    iHourlyInputs = readtable("$path/Hourly_Parameters.csv",header=true)
    iTechParameters = readtable("$path/Tech_Parameters.csv",header=true)

    T =  length(iHourlyInputs[:pHour]) #24*7 #
    pMonth = iHourlyInputs[:pMonth][1:T]
    pWeek = iHourlyInputs[:pWeek][1:T]
    pHour = iHourlyInputs[:pHour][1:T]

    pBuyEnergy = iHourlyInputs[:pBuy_Energy][1:T]
    pSellEnergy = iHourlyInputs[:pSell_Energy][1:T]
    pNonControllableLoad = iHourlyInputs[:pNonControllableLoad][1:T]

    pNetworkPeakHour = 117
    pNetworkCostperkW = 30
    pDelta = 1 #duration of time period (hr)
    pCCurtail = 0.25 #cost of curtailment - will depend on the scenario ($/KWH)
    pGenAssets = [5 5 2.5 2.5] # this is where you specify the technology choices; will ultimately take this from dataframes
    #genAssets = [pPVbank pBatt_NominalE pBatt_DischargeCapacity pBatt_ChargeCapacity]
    #pGenAssets = [15 5 2.5 2.5]


    #NON-CONTROLLABLE GEN PARAMETERS
    pPV_Capacity = pGenAssets[1] #this is the total capacity of the PV panels 
    pPV_Generation = pGenAssets[1]*iHourlyInputs[:pPV_Generation][1:T]
    pOtherNonControllableGen = iHourlyInputs[:pOtherNonControllableGen][1:T]  # declaring non-PV based non-controllable generation
    @defExpr(pTotalNonControllableGen[t=1:T], pPV_Generation[t]+pOtherNonControllableGen[t]) #total non-controllable generation = PV + other


    #SCHEDULABLE LOADS PARAMETERS
    pNumCycles = 170
    pLoadTime = iTechParameters[:pLoadTime][1:pNumCycles]
    pFinishTime = iTechParameters[:pFinishTime][1:pNumCycles]
    pMaxLoad = 1
    pTotal_SL_kWh = 1

    #THERMAL PARAMETERS
    pOutdoorTemp = iHourlyInputs[:pOutdoorTemp][1:T]
    pSetpoint = iHourlyInputs[:pSetPoint][1:T]
    pDeadband = iTechParameters[1,:pDeadband]
    pCapacitance = iTechParameters[1,:pCapacitance]              #heat capacity of building interior (kWh/C) 
    pResistance = iTechParameters[1,:pResistance]                #thermal resistance of between interior and exterior (C/kWh) 
    pCOP = iTechParameters[1,:pCOP]                              #COP of heat pump (eventually convert to piecewise linear)
    pMaxPower = iTechParameters[1,:pMaxPower]
    pTempDevPenalty = iTechParameters[1,:pTempDevPenalty]        #temperature deviation penalty ($/deg C)

    pWH_AmbientTemp = 20
    pWH_Setpoint = 50
    pWH_Deadband = iTechParameters[2,:pDeadband]
    pWH_Capacitance = iTechParameters[2,:pCapacitance]              
    pWH_Resistance = iTechParameters[2,:pResistance]                
    pWH_COP = iTechParameters[2,:pCOP]                              
    pWH_MaxPower = iTechParameters[2,:pMaxPower]

    #BATTERY PARAMETERS
    pBattNominalE = pGenAssets[2]
    pBattDischargeCapacity = pGenAssets[3] #installed battery discharge power capacity (KW)
    pBattChargeCapacity = pGenAssets[4] #installed battery charge power capacity (KW)

    pBattDischargeEff = iTechParameters[1,:pBatt_DischargeEff] #pBatt_DischargeEff Efficiency of battery discharge
    pBattChargeEff = iTechParameters[1,:pBatt_ChargeEff] #pBattChargeEff Efficiency of battery charge
    pBattCDeg = iTechParameters[1,:pBatt_CDeg] #pBattCDeg battery degradation cost ($) 
    pBattInitialSOC = iTechParameters[1,:pBatt_InitialSOC] #pBatt_InitialSOC initial state of charge 
    pBattSOCMax = iTechParameters[1,:pBatt_SOCMax] #pBatt_SOCMax maximum SOC
    pBattSOCMin = iTechParameters[1,:pBatt_SOCMin] #pBatt_SOCMin minimum SOC


    #VARIABLES

    #SCHEDULABLE LOADS
    @defVar(m, 0<=vSL[t=1:T,1:pNumCycles]<=pMaxLoad)

    #THERMAL LOADS
    @defVar(m, sTempInt[t=1:T] >=0)                 # internal home temp (state variable)
    @defVar(m, sExtLosses[t=1:T])                   # losses/gains from thermal leakage through building shell
    @defVar(m, sIntGains[t=1:T])                    # internal gains
    @defVar(m, 0 <= vPowerHP[t=1:T] <= pMaxPower)         # HVAC power draw (continuous, 5kW max) | allow negative values = cooling???
    @defVar(m, 0 <= vPowerAC[t=1:T] <= pMaxPower)
    @defVar(m, vTempLow[t=1:T]>=0)                                       # penalty for temp deviations
    @defVar(m, vTempHigh[t=1:T]>=0) 

    #WATER HEAETER
    @defVar(m, sWH_TempInt[t=1:T] >=0)                 # internal tank temp (state variable)
    @defVar(m, sWH_ExtLosses[t=1:T])                   # losses/gains from thermal leakage through building shell
    @defVar(m, sWH_IntGains[t=1:T])                    # internal gains
    @defVar(m, 0 <= vPowerWH[t=1:T] <= pWH_MaxPower)         # WH power draw 
    @defVar(m, vWH_TempLow[t=1:T]>=0)                                       # penalty for temp deviations
    @defVar(m, vWH_TempHigh[t=1:T]>=0)

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


    #SCHEDULABLE LOADS
    for w = 1:pNumCycles
        @addConstraint(m, pTotal_SL_kWh==sum{vSL[t,w],t=pLoadTime[w]:pFinishTime[w]})
        @addConstraint(m, pTotal_SL_kWh==sum{vSL[t,w],t=1:T})
    end 
    @defExpr(vScheduledLoads[t=1:T], sum{vSL[t,w], w=1:pNumCycles})


    #THERMAL LOADS (HEATING/COOLING/WATER HEATING)
    for t = 1
        @addConstraint(m, sTempInt[t]==pSetpoint[t])                         
        @addConstraint(m, sWH_TempInt[t]==pWH_Setpoint)                      
    end
    for t = 2:T
        @addConstraint(m,sTempInt[t-1]+((sExtLosses[t-1]+sIntGains[t-1])/pCapacitance)==sTempInt[t]) # temp evolution | temp(t) = temp(t-1) + (gains - losses)/heat capacity    
        @addConstraint(m,sWH_TempInt[t-1]+((sWH_ExtLosses[t-1]+sWH_IntGains[t-1])/pWH_Capacitance)==sWH_TempInt[t]) # temp evolution | temp(t) = temp(t-1) + (gains - losses)/heat capacity    
    end
    for t = 1:T
        @addConstraint(m, ((pOutdoorTemp[t] - sTempInt[t])/(pCapacitance*pResistance))==sExtLosses[t])   #losses from thermal leakage
        @addConstraint(m, ((pCOP*vPowerHP[t])/pCapacitance)-(((pCOP-1)*vPowerAC[t])/pCapacitance)==sIntGains[t])                         #interanl temp gain from heat pump
        @addConstraint(m, (pSetpoint[t]-pDeadband)-vTempLow[t]<=sTempInt[t])
        @addConstraint(m, (pSetpoint[t]+pDeadband)+vTempHigh[t]>=sTempInt[t])
        @addConstraint(m, vPowerHP[t]+vPowerAC[t]<=pMaxPower)
        
        @addConstraint(m, ((pWH_AmbientTemp - sWH_TempInt[t])/(pWH_Capacitance*pWH_Resistance))==sWH_ExtLosses[t])   
        @addConstraint(m, ((pWH_COP*vPowerWH[t])/pWH_Capacitance)==sWH_IntGains[t])                         
        @addConstraint(m, (pWH_Setpoint-pWH_Deadband)-vWH_TempLow[t]<=sWH_TempInt[t])
        @addConstraint(m, (pWH_Setpoint+pWH_Deadband)+vWH_TempHigh[t]>=sWH_TempInt[t])
    end
    @defExpr(vThermalLoad[t=1:T], vPowerHP[t]+vPowerAC[t]+vPowerWH[t])
    @defExpr(vTotalTempDev[t=1:T],vTempHigh[t]+vTempLow[t]+vWH_TempHigh[t]+vWH_TempLow[t])

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

    #OBJECTIVE FUNCTION
    @defExpr(EndUseLoads[t=1:T], pNonControllableLoad[t]+vScheduledLoads[t]+vThermalLoad[t])
    @defExpr(NetworkCost, pNetworkCostperkW*vPowerPurchased[pNetworkPeakHour])
    @defExpr(EnergyCost, sum{pBuyEnergy[t]*vPowerPurchased[t],t=1:T}+pTempDevPenalty*sum{vTotalTempDev[t],t=1:T})
    @defExpr(TotalCost, EnergyCost+NetworkCost)
    @defExpr(TotalRevenue, sum{pSellEnergy[t]*sPowerExport[t],t=1:T})
    @defExpr(TotalPowerProvided[t=1:T],vPowerConsumed[t]+sPowerExport[t])
    @setObjective(m, Min, TotalCost - TotalRevenue)

    status = solve(m)

    #REPORTING
    aTemp = hcat(pMonth[1:T],
        pWeek[1:T],
        pHour[1:T],
        pBuyEnergy[1:T],
        pSellEnergy[1:T],
        getValue(vPowerConsumed[1:T]),
        getValue(sPowerProduced[1:T]),
        getValue(vPowerPurchased[1:T]),
        getValue(sPowerExport[1:T]),
        getValue(vBattDischarge[1:T]),
        getValue(vBattCharge[1:T]),
        pSetpoint[1:T],
        pOutdoorTemp[1:T],
        getValue(sTempInt[1:T]),
        getValue(vBattSOC[1:T]),
        getValue(vBattSOH[1:T]),
        getValue(vPowerHP[1:T]),
        getValue(vScheduledLoads[1:T]),
        getValue(vPowerWH[1:T]),
        getValue(vPowerAC[1:T]),
        pNonControllableLoad[1:T],
        getValue(EndUseLoads[1:T])
        )

        aTemp = convert(Array, aTemp)

        dfUsage = convert(DataFrame, aTemp)

        rename!(dfUsage, {:x1=>:Month,
            :x2=>:Week, 
            :x3=>:Hour, 
            :x4=>:Buy_Energy, 
            :x5=>:Sell_Energy, 
            :x6=>:Power_Consumed,
            :x7=>:Power_Produced,
            :x8=>:Power_Purchased,
            :x9=>:Power_Export,
            :x10=>:Batt_Discharge,
            :x11=>:Batt_Charge,
            :x12=>:Set_point,
            :x13=>:Outdoor_temp,
            :x14=>:Indoor_temp,
            :x15=>:Battery_SOC,
            :x16=>:Battery_SOH,
            :x17=>:HP_kW,
            :x18=>:Scheduled_Loads_kW,
            :x19=>:WH_kW,
            :x20=>:AC_kW,
            :x21=>:NonControllableLoads_kW,
            :x22=>:EndUseLoads_kW
            })

    #writetable("outputs.csv",dfUsage)
 
    return dfUsage #status, println("Objective value: ", getObjectiveValue(m))
    
end


#this line just calls the function to create and run the model. Edit as neccessary to pick up the right path
df = dr_dre("inputs/1")
writetable("outputs.csv", df)

