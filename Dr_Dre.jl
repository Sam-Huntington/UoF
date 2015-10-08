
# test comments
# test comments2
#scotts comment and sams comment

function dr_dre(df1,df2,df3)
    # df1 = hourly prices, weather
    # df2 = technology parameters
    # df3 = non-controllable loads

    m = Model(solver=GurobiSolver())

    iHourlyInputs = df1 #readtable("$path/Hourly_Parameters.csv",header=true)
    iTechParameters = df2 #readtable("$path/Tech_Parameters.csv",header=true)

    T =  168 #length(iHourlyInputs[:pHour]) #24*7 #
    pMonth = iHourlyInputs[:pMonth][1:T]
    pWeek = iHourlyInputs[:pWeek][1:T]
    pHour = iHourlyInputs[:pHour][1:T]

    pBuyEnergy = iHourlyInputs[:pBuy_Energy][1:T]
    pSellEnergy = iHourlyInputs[:pSell_Energy][1:T]
    pNonControllableLoad = df3[1:T] #iHourlyInputs[:pNonControllableLoad][1:T]

    pSellPrimaryUpCap = iHourlyInputs[:pSell_PrimaryUpCap][1:T]
	  pSellPrimaryDownCap = iHourlyInputs[:pSell_PrimaryDownCap][1:T]
	  pSellPrimaryEnergy = iHourlyInputs[:pSell_PrimaryEnergy][1:T]
	  pBuyPrimaryEnergy = iHourlyInputs[:pBuy_PrimaryEnergy][1:T] #will be equal to pSellPrimaryEnergy if movement/ mileage prices are symmetric
	  pD2CPrimaryUp = iHourlyInputs[:pD2CPrimaryUp][1:T]
	  pD2CPrimaryDown = iHourlyInputs[:pD2CPrimaryDown][1:T]

    pNetworkPeakHour = 117
    pNetworkCostperkW = 0
    pDelta = 1 #duration of time period (hr)
    pCostCurtail = 2500 #cost of curtailment - will depend on the scenario ($/KWH)
    #pGenAssets = [5 5 2.5 2.5] # this is where you specify the technology choices; will ultimately take this from dataframes
    #genAssets = [pPVbank pBatt_NominalE pBatt_DischargeCapacity pBatt_ChargeCapacity]
    #pGenAssets = [15 5 2.5 2.5]

    #NON-CONTROLLABLE GEN PARAMETERS
    pPV_Capacity = iTechParameters[:PV_Cap] #this is the total capacity of the PV panels

    pPV_Generation = iHourlyInputs[:pPV_Generation][1:T]*iTechParameters[1,:PV_Cap]

    pOtherNonControllableGen = iHourlyInputs[:pOtherNonControllableGen][1:T]  # declaring non-PV based non-controllable generation
    @defExpr(pTotalNonControllableGen[t=1:T], pPV_Generation[t]+pOtherNonControllableGen[t]) #total non-controllable generation = PV + other

    #SCHEDULABLE LOADS PARAMETERS
    pNumCycles = int(iTechParameters[1,:pNumCycles]) #170
    pLoadTime = iTechParameters[1,:pLoadTime] #iTechParameters[:pLoadTime][1:pNumCycles]
    pFlexWindow = iTechParameters[1,:pFlexWindow] #iTechParameters[:pFinishTime][1:pNumCycles]
    pMaxLoad = iTechParameters[1,:pMaxLoad]
    pTotal_SL_kWh = iTechParameters[1,:pTotal_SL_kWh]
    pSchedule = fBuild_Sched(pLoadTime, pFlexWindow, pNumCycles)
    #below code ensures final schedule doesn't include start times outside of time range
    i = 1

    while (pSchedule[2,pNumCycles] > T) & (i<=100)
        pSchedule = fBuild_Sched(pLoadTime, pFlexWindow, pNumCycles)
        i+=1
    end

    #THERMAL PARAMETERS
    pOutdoorTemp = iHourlyInputs[:pOutdoorTemp][1:T]
    pSetpoint = iHourlyInputs[:pSetPoint][1:T]
    pDeadband = iTechParameters[1,:pDeadband_HVAC]
    pCapacitance = iTechParameters[1,:pCapacitance_HVAC]              #heat capacity of building interior (kWh/C)
    pResistance = iTechParameters[1,:pResistance_HVAC]                #thermal resistance of between interior and exterior (C/kWh)
    pCOP = iTechParameters[1,:pCOP_HVAC]                              #COP of heat pump (eventually convert to piecewise linear)
    pMaxPower = iTechParameters[1,:pMaxPower_HVAC]
    pTempDevPenalty = 10 #iTechParameters[1,:pTempDevPenalty]        #temperature deviation penalty ($/deg C)

    pWH_AmbientTemp = 20
    pWH_Setpoint = 50
    pWH_Deadband = iTechParameters[1,:pDeadband_WH]
    pWH_Capacitance = iTechParameters[1,:pCapacitance_WH]
    pWH_Resistance = iTechParameters[1,:pResistance_WH]
    pWH_COP = iTechParameters[1,:pCOP_WH]

    pWH_MaxPower = iTechParameters[1,:pMaxPower_WH]

    #BATTERY PARAMETERS
    pBattNominalE = iTechParameters[1,:pBatt_NominalE]
    pBattDischargeCapacity = iTechParameters[1,:pBatt_DischargeCapacity] #installed battery discharge power capacity (KW)
    pBattChargeCapacity = iTechParameters[1,:pBatt_ChargeCapacity] #installed battery charge power capacity (KW)
    pBattDischargeEff = iTechParameters[1,:pBatt_DischargeEff] #pBatt_DischargeEff Efficiency of battery discharge
    pBattChargeEff = iTechParameters[1,:pBatt_ChargeEff] #pBattChargeEff Efficiency of battery charge
    pBattCDeg = iTechParameters[1,:pBatt_CDeg] #pBattCDeg battery degradation cost ($)
    pBattInitialSOC = iTechParameters[1,:pBatt_InitialSOC] #pBatt_InitialSOC initial state of charge
    pBattSOCMax = iTechParameters[1,:pBatt_SOCMax] #pBatt_SOCMax maximum SOC
    pBattSOCMin = iTechParameters[1,:pBatt_SOCMin] #pBatt_SOCMin minimum SOC


    #VARIABLES
    #k = iTechParameters[1,:XXXXXXXXXX]

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
    @defVar(m, vBattPrimaryDownCap[t=1:T] >=0) #capacity made available for down regulation
    @defVar(m, vBattPrimaryUpCap[t=1:T] >=0) #capacity made available for down regulation
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
        @addConstraint(m, pTotal_SL_kWh==sum{vSL[t,w],t=pSchedule[1,w]:pSchedule[2,w]})
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

    @defExpr(sBattPrimaryUpEnergy[t=1:T], vBattPrimaryUpCap[t]*pD2CPrimaryUp[t])
    @defExpr(sBattPrimaryDownEnergy[t=1:T], vBattPrimaryDownCap[t]*pD2CPrimaryDown[t])
    @defExpr(sBattPrimaryDownEnergyLosses[t=1:T], sBattPrimaryDownEnergy[t]*(1-pBattChargeEff))
    @defExpr(sBattPrimaryUpEnergyLosses[t=1:T], sBattPrimaryUpEnergy[t]*(1-pBattDischargeEff))
    @defExpr(sBattPrimaryEnergyLosses[t=1:T], sBattPrimaryUpEnergyLosses[t]+sBattPrimaryDownEnergyLosses[t])

    if pBattNominalE > 0
        for t=1:T
            @addConstraint(m, vBattCharge[t]<=pBattChargeCapacity)
            @addConstraint(m, vBattDischarge[t]<=pBattDischargeCapacity)
            @addConstraint(m, vBattPrimaryUpCap[t]<= (pBattDischargeCapacity-vBattDischarge[t]))
            @addConstraint(m, vBattPrimaryDownCap[t]<=(pBattChargeCapacity-vBattCharge[t]))
            @addConstraint(m, vBattPrimaryUpCap[t]==vBattPrimaryDownCap[t])
        end
    else
        for t=1:T
            @addConstraint(m, vBattCharge[t]==0)
            @addConstraint(m, vBattDischarge[t]==0)
            @addConstraint(m, vBattRegUpCap[t]==0)
            @addConstraint(m, vBattRegDownCap[t]==0)
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
        @addConstraint(m, pNonControllableLoad[t]+vScheduledLoads[t]+vThermalLoad[t]+vBattCharge[t]-vPowerCurtail[t]==vPowerConsumed[t])
        @addConstraint(m, vPowerConsumed[t]+sPowerExport[t]==vPowerPurchased[t]+sPowerProduced[t])
        #cannot import and export at the same time
        @addConstraint(m, sPowerExport[t] <= 10000000*(1-vPowerImportorExport[t]))
        @addConstraint(m, vPowerPurchased[t] <= 10000000*(vPowerImportorExport[t]))
    end

    #OBJECTIVE FUNCTION
    @defExpr(EndUseLoads[t=1:T], pNonControllableLoad[t]+vScheduledLoads[t]+vThermalLoad[t])
    @defExpr(NetworkCost, pNetworkCostperkW*vPowerPurchased[pNetworkPeakHour])
    @defExpr(EnergyCost, sum{pBuyEnergy[t]*vPowerPurchased[t],t=1:T}+pTempDevPenalty*sum{vTotalTempDev[t],t=1:T}+pDelta*sum{pCostCurtail*vPowerCurtail[t],t=1:T})
    @defExpr(PrimaryReserveRevenue, sum{pSellPrimaryUpCap[t]*vBattPrimaryUpCap[t]+pSellPrimaryDownCap[t]*vBattPrimaryDownCap[t],t=1:T}+pDelta*sum{pSellPrimaryEnergy[t]*sBattPrimaryUpEnergy[t]+pBuyPrimaryEnergy[t]*sBattPrimaryDownEnergy[t],t=1:T})
    @defExpr(TotalCost, EnergyCost+NetworkCost)
    @defExpr(TotalRevenue, sum{pSellEnergy[t]*sPowerExport[t],t=1:T})
    @defExpr(TotalPowerProvided[t=1:T],vPowerConsumed[t]+sPowerExport[t])
    @setObjective(m, Min, TotalCost - TotalRevenue-PrimaryReserveRevenue)

    #TT = STDOUT # save original STDOUT stream
    #redirect_stdout()
    solve(m)
    #redirect_stdout(TT)

    #REPORTING
    aTemp = hcat(pMonth[1:T],pWeek[1:T],pHour[1:T],pBuyEnergy[1:T],pSellEnergy[1:T],getValue(vPowerConsumed[1:T]),
                getValue(sPowerProduced[1:T]),getValue(vPowerPurchased[1:T]),getValue(sPowerExport[1:T]),
                getValue(vBattDischarge[1:T]),getValue(vBattCharge[1:T]),pSetpoint[1:T],pOutdoorTemp[1:T],
                getValue(sTempInt[1:T]),getValue(vBattSOC[1:T]),getValue(vBattSOH[1:T]),getValue(vPowerHP[1:T]),
                getValue(vScheduledLoads[1:T]),getValue(vPowerWH[1:T]),getValue(vPowerAC[1:T]),pNonControllableLoad[1:T],
                getValue(EndUseLoads[1:T]), getValue(vBattPrimaryDownCap[1:T]),
             getValue(vBattPrimaryUpCap[1:T]),
             getValue(sBattPrimaryUpEnergy[1:T]),
             getValue(sBattPrimaryDownEnergy[1:T]),
             getValue(sBattPrimaryEnergyLosses[1:T])
                 )

    aTemp = convert(Array, aTemp)
    dfUsage = convert(DataFrames.DataFrame, aTemp)
    rename!(dfUsage, {:x1=>:Month,:x2=>:Week,:x3=>:Hour,:x4=>:Buy_Energy,:x5=>:Sell_Energy,:x6=>:Power_Consumed,
                :x7=>:Power_Produced,:x8=>:Power_Purchased,:x9=>:Power_Export,:x10=>:Batt_Discharge,:x11=>:Batt_Charge,
                :x12=>:Set_point,:x13=>:Outdoor_temp,:x14=>:Indoor_temp,:x15=>:Battery_SOC,:x16=>:Battery_SOH,
                :x17=>:HP_kW,:x18=>:Scheduled_Loads_kW,:x19=>:WH_kW,:x20=>:AC_kW,:x21=>:NonControllableLoads_kW,
                :x22=>:EndUseLoads_kW,:x23=>:Primary_DownCap,
                  :x24=>:Primary_UpCap,
                  :x25=>:Primary_UpEnergy,
                  :x26=>:Primary_DownEnergy,
                  :x27=>:Primary_EnergyLosses}
            )

    #writetable("outputs.csv",dfUsage)

    #out = convert(Array, getValue(vPowerConsumed[1:T]))
    #out = convert(DataFrames.DataFrame, out)
    return  dfUsage #getValue(vPowerConsumed[1:T])

end
