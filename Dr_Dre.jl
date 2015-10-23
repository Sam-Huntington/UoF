#####################################################################
#
#    The Demand Response and Distributed Resource Economics model
#                             (DrDre)
#
#
# Notes:
#   - actual model is contained within run_dr_dre function at the bottom
#   - the function must be passed 2 sets of inputs, formatted as dataframes:
#         1: "hourly parameters" which vary by timestep
#         2: "tech parameters" which are all single values
#   - to specify inputs and output files and run the model, run the code at the top
#
#
####################################################################


####################################################################
###### Set Inputs and Outputs Files Locations and Run DrDre ########
####################################################################

path = "C:\\Program Files\\Git\\UoF\\Inputs_Outputs\\"             #working folder
df1 = readtable("$path"*"Hourly_Parameters.csv",header=true)       #timeseries inputs
df2 = readtable("$path"*"Tech_Parameters.csv",header=true)         #single value inputs
df2[:id]=ones(1:size(df2,1))                                       #reshape df so model can read inputs
df2 = unstack(df2,:id,:Variable,:Value)
df3 = zeros(1,1) #readtable("$path"*"df3.csv",header=true)         #non-functional unless running iterations over many bldg types
usage_out, cost_out = run_dr_dre(df1,df2[1,:],df3[1])              #pass input arrays to Dre, solve it, and store outputs in dataframes
if isfile("$path"*"test_outputs.csv")==true                        #delete existing copy of outputs file
  rm("$path"*"test_outputs.csv")
end
writetable("$path"*"test_outputs.csv",usage_out)                   #write outputs
writecsv("$path"*"cost_outputs.csv",cost_out)

####################################################################
########## Modules & F'n to build/solve DrDre ######################
####################################################################

using DataFrames
using JuMP
using Gurobi
using Statsbase

function run_dr_dre(df1,df2,df3)
    # df1 = hourly prices, weather
    # df2 = technology parameters
    # df3 = non-controllable loads (if looping across multiple random test cases, otherwise this can come from "hourly parameters")

    dre = Model(solver=GurobiSolver())

    iHourlyInputs = df1 #readtable("$path/Hourly_Parameters.csv",header=true)
    iTechParameters = df2 #readtable("$path/Tech_Parameters.csv",header=true)

    T =  length(iHourlyInputs[:pHour]) #24*7 #168
    pMonth = iHourlyInputs[:pMonth][1:T]
    pWeek = iHourlyInputs[:pWeek][1:T]
    pDay = iHourlyInputs[:pDay][1:T]
    pHour = iHourlyInputs[:pHour][1:T]
    M = maximum(pMonth[1:T]) #pMonth[T-1]

    pBuyEnergy = iHourlyInputs[:pBuy_Energy][1:T]
    pSellEnergy = iHourlyInputs[:pSell_Energy][1:T]
    pMoNetworkCost = iHourlyInputs[:pMonthly_Network_Cost][1:M]
    #pNetworkCostperkW = 0 #for annual network cost use this single value
    pHP_Month = iHourlyInputs[:pHP_Month][1:M]
    pAC_Month = iHourlyInputs[:pAC_Month][1:M]

    pNonControllableLoad = iHourlyInputs[:pNonControllableLoad][1:T] #df3[1:T] #
    pWH_use = iHourlyInputs[:pWH_use][1:T]

    pSellPrimaryUpCap = iHourlyInputs[:pSell_PrimaryUpCap][1:T]
    pSellPrimaryDownCap = iHourlyInputs[:pSell_PrimaryDownCap][1:T]
    pSellPrimaryEnergy = iHourlyInputs[:pSell_PrimaryEnergy][1:T]
    pBuyPrimaryEnergy = iHourlyInputs[:pBuy_PrimaryEnergy][1:T] #will be equal to pSellPrimaryEnergy if movement/ mileage prices are symmetric
    pD2CPrimaryUp = iHourlyInputs[:pD2CPrimaryUp][1:T]
    pD2CPrimaryDown = iHourlyInputs[:pD2CPrimaryDown][1:T]

    #Peak day capacity charge
    pPeakDemandCharge = 10
    pNetworkPeakHour = 4240

    pDelta = 1 #duration of time period (hr)
    pCostCurtail = iTechParameters[1,:pCostCurtail] #cost of curtailment - will depend on the scenario ($/KWH)

    #NON-CONTROLLABLE GEN PARAMETERS
    #pPV_Capacity = iTechParameters[1,:PV_Cap] #this is the total capacity of the PV panels
    pPV_Generation = iHourlyInputs[:pPV_Generation][1:T]*iTechParameters[1,:pPV_Cap]

    pOtherNonControllableGen = iHourlyInputs[:pOtherNonControllableGen][1:T]  # declaring non-PV based non-controllable generation
    @defExpr(pTotalNonControllableGen[t=1:T], pPV_Generation[t]+pOtherNonControllableGen[t]) #total non-controllable generation = PV + other

    #SCHEDULABLE LOADS PARAMETERS
    pNumCycles = int(iTechParameters[1,:pNumCycles]) #170
    pLoadTime = iTechParameters[1,:pLoadTime] #iTechParameters[:pLoadTime][1:pNumCycles]
    pFlexWindow = iTechParameters[1,:pFlexWindow] #iTechParameters[:pFinishTime][1:pNumCycles]
    pMaxLoad = iTechParameters[1,:pMaxLoad]
    pTotal_SL_kWh = iTechParameters[1,:pTotal_SL_kWh]
    pSchedule = DataFrame()

    for i in 0:(pNumCycles-1)
      a = [pLoadTime,pLoadTime+pFlexWindow].+i*48 #sample([36,48,48,60])
      pSchedule = hcat(pSchedule,a)
    end

    #THERMAL PARAMETERS
    pOutdoorTemp = iHourlyInputs[:pOutdoorTemp][1:T]
    pSetpoint = iHourlyInputs[:pSetPoint][1:T]
    pDeadband = iTechParameters[1,:pDeadband_HVAC]
    pCapacitance = iTechParameters[1,:pCapacitance_HVAC]              #heat capacity of building interior (kWh/C)
    pResistance = iTechParameters[1,:pResistance_HVAC]                #thermal resistance of between interior and exterior (C/kWh)
    pCOP = iTechParameters[1,:pCOP_HVAC]                              #COP of heat pump (eventually convert to piecewise linear)
    pMaxPower = iTechParameters[1,:pMaxPower_HVAC]
    pTempDevPenalty = iTechParameters[1,:pTempDevPenalty]        #temperature deviation penalty ($/deg C)

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

    #SCHEDULABLE LOADS
    @defVar(dre, 0<=vSL[t=1:T,1:pNumCycles]<=pMaxLoad)

    #THERMAL LOADS
    @defVar(dre, sTempInt[t=1:T] >=0)                 # internal home temp (state variable)
    @defVar(dre, sExtLosses[t=1:T])                   # losses/gains from thermal leakage through building shell
    @defVar(dre, sIntGains[t=1:T])                    # internal gains
    @defVar(dre, 0 <= vPowerHP[t=1:T] <= pMaxPower)         # HVAC power draw (continuous, 5kW max) | allow negative values = cooling???
    @defVar(dre, 0 <= vPowerAC[t=1:T] <= pMaxPower)
    @defVar(dre, vTempLow[t=1:T]>=0)                                       # penalty for temp deviations
    @defVar(dre, vTempHigh[t=1:T]>=0)

    #WATER HEAETER
    @defVar(dre, sWH_TempInt[t=1:T] >=0)                 # internal tank temp (state variable)
    @defVar(dre, sWH_ExtLosses[t=1:T])                   # losses/gains from thermal leakage through building shell
    @defVar(dre, sWH_IntGains[t=1:T])                    # internal gains
    @defVar(dre, 0 <= vPowerWH[t=1:T] <= pWH_MaxPower)         # WH power draw
    @defVar(dre, vWH_TempLow[t=1:T]>=0)                                       # penalty for temp deviations
    @defVar(dre, vWH_TempHigh[t=1:T]>=0)

    #BATTERY
    @defVar(dre, pBattSOCMin <= vBattSOC[t=1:T] <= pBattSOCMax) # SOC of battery ----- SB!!! Maybe make this a state variable, not a decision variable.
    @defVar(dre, vBattSOH[t=1:T] >= 0) #State of health of battery (degradation costs)
    @defVar(dre, vBattPrimaryDownCap[t=1:T] >=0) #capacity made available for down regulation
    @defVar(dre, vBattPrimaryUpCap[t=1:T] >=0) #capacity made available for down regulation
    @defVar(dre, vBattCharge[t=1:T] >= 0) #battery charging power
    @defVar(dre, vBattDischarge[t=1:T] >= 0) #battery discharging power
    @defVar(dre, vBattCorD[t=1:T], Bin) #batt charging or discharging binary variable.

    #DEMAND BALANCE
    @defVar(dre, vPowerCurtail[t=1:T] >=0) #curtailed power
    @defVar(dre, vPowerConsumed[t=1:T] >=0) # consumed power
    @defVar(dre, vPowerImportorExport[t=1:T], Bin)
    @defVar(dre, vPowerPurchased[t=1:T] >=0) # power ultimately purchased from utility
    @defVar(dre, sPowerExport[t=1:T] >= 0)
    @defVar(dre, vMaxDemand[m=1:M] >= 0)

    #SCHEDULABLE LOADS
    for w = 1:pNumCycles
      @addConstraint(dre, pTotal_SL_kWh==sum{vSL[t,w],t=pSchedule[1,w]:pSchedule[2,w]})
      @addConstraint(dre, pTotal_SL_kWh==sum{vSL[t,w],t=1:T})
    end
    @defExpr(vScheduledLoads[t=1:T], sum{vSL[t,w], w=1:pNumCycles})

    #THERMAL LOADS (HEATING/COOLING/WATER HEATING)
    for t = 1
      @addConstraint(dre, sTempInt[t]==pSetpoint[t])
      @addConstraint(dre, sWH_TempInt[t]==pWH_Setpoint)
    end
    for t = 2:T
        if (pHP_Month[pMonth[t]] | pAC_Month[pMonth[t]])
            @addConstraint(dre,sTempInt[t-1]+((sExtLosses[t-1]+sIntGains[t-1])/pCapacitance)==sTempInt[t]) # temp evolution | temp(t) = temp(t-1) + (gains - losses)/heat capacity
        else #if neither HP or AC are affecting the temp, let it equal the Setpoint (assume heating from a different fuel)
            @addConstraint(dre,sTempInt[t]==pSetpoint[t])
        end
        @addConstraint(dre,sWH_TempInt[t-1]+((sWH_ExtLosses[t-1]+pWH_use[t]+sWH_IntGains[t-1])/pWH_Capacitance)==sWH_TempInt[t]) # temp evolution | temp(t) = temp(t-1) + (gains - losses)/heat capacity
    end
    for t = 1:T
        if pHP_Month[pMonth[t]]==false
            @addConstraint(dre, vPowerHP[t]==0)
        end
        if pAC_Month[pMonth[t]]==false
            @addConstraint(dre, vPowerAC[t]==0)
        end
        @addConstraint(dre, ((pCOP*vPowerHP[t])/pCapacitance)-(((pCOP-1)*vPowerAC[t])/pCapacitance)==sIntGains[t])
        @addConstraint(dre, ((pOutdoorTemp[t] - sTempInt[t])/(pCapacitance*pResistance))==sExtLosses[t])   #losses from thermal leakage
        @addConstraint(dre, (pSetpoint[t]-pDeadband)-vTempLow[t]<=sTempInt[t])
        @addConstraint(dre, (pSetpoint[t]+pDeadband)+vTempHigh[t]>=sTempInt[t])
        @addConstraint(dre, vPowerHP[t]+vPowerAC[t]<=pMaxPower)

        @addConstraint(dre, ((pWH_AmbientTemp - sWH_TempInt[t])/(pWH_Capacitance*pWH_Resistance))==sWH_ExtLosses[t])
        @addConstraint(dre, ((pWH_COP*vPowerWH[t])/pWH_Capacitance)==sWH_IntGains[t])
        @addConstraint(dre, (pWH_Setpoint-pWH_Deadband)-vWH_TempLow[t]<=sWH_TempInt[t])
        @addConstraint(dre, (pWH_Setpoint+pWH_Deadband)+vWH_TempHigh[t]>=sWH_TempInt[t])
    end
    @defExpr(vThermalLoad[t=1:T], vPowerHP[t]+vPowerAC[t]+vPowerWH[t])
    @defExpr(vTotalTempDev[t=1:T],vTempHigh[t]+vTempLow[t]+vWH_TempHigh[t]+vWH_TempLow[t])

    #BATTERY

    #constraining state of charge to appropriate limits
    @addConstraint(dre, vBattSOC[1] == pBattInitialSOC)

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
        @addConstraint(dre, vBattCharge[t]<=pBattChargeCapacity)
        @addConstraint(dre, vBattDischarge[t]<=pBattDischargeCapacity)
        @addConstraint(dre, vBattPrimaryUpCap[t]<= (pBattDischargeCapacity-vBattDischarge[t]))
        @addConstraint(dre, vBattPrimaryDownCap[t]<=(pBattChargeCapacity-vBattCharge[t]))
        @addConstraint(dre, vBattPrimaryUpCap[t]==vBattPrimaryDownCap[t])
      end
    else
      for t=1:T
        @addConstraint(dre, vBattCharge[t]==0)
        @addConstraint(dre, vBattDischarge[t]==0)
        @addConstraint(dre, vBattPrimaryUpCap[t]==0)
        @addConstraint(dre, vBattPrimaryDownCap[t]==0)
      end
    end

    if pBattNominalE > 0
      for t = 2:T
        @addConstraint(dre, vBattSOC[t-1] - (pDelta/pBattNominalE)*(sBattOutput[t-1] - sBattInput[t-1] + sBattLosses[t-1]) == vBattSOC[t])
      end
    else
      for t = 2:T
        @addConstraint(dre, vBattSOC[t] == vBattSOC[1])
      end
    end

    #define charge or discharge constraint
    for t=1:T
      @addConstraint(dre, vBattCharge[t] <= 1000000*vBattCorD[t])
      @addConstraint(dre, vBattDischarge[t] <= 1000000*(1-vBattCorD[t]))
    end

    #DEMAND BALANCE
    @defExpr(sPowerProduced[t=1:T], pTotalNonControllableGen[t] + vBattDischarge[t])

    for t=1:T
      @addConstraint(dre, pNonControllableLoad[t]+vScheduledLoads[t]+vThermalLoad[t]+vBattCharge[t]-vPowerCurtail[t]==vPowerConsumed[t])
      @addConstraint(dre, vPowerConsumed[t]+sPowerExport[t]==vPowerPurchased[t]+sPowerProduced[t])
      #cannot import and export at the same time
      @addConstraint(dre, sPowerExport[t] <= 10000000*(1-vPowerImportorExport[t]))
      @addConstraint(dre, vPowerPurchased[t] <= 10000000*(vPowerImportorExport[t]))
    end

    for t = 1:T #setting the monthly max demand Variable
      #pMonth[t]
      @addConstraint(dre, vPowerPurchased[t] <= vMaxDemand[pMonth[t]])
      @addConstraint(dre, sPowerExport[t] <= vMaxDemand[pMonth[t]])
    end

    #OBJECTIVE FUNCTION
    @defExpr(EndUseLoads[t=1:T], pNonControllableLoad[t]+vScheduledLoads[t]+vThermalLoad[t])
    @defExpr(PeakDayCost, pPeakDemandCharge*vPowerPurchased[pNetworkPeakHour])
    @defExpr(EnergyCost, sum{pBuyEnergy[t]*vPowerPurchased[t],t=1:T})
    @defExpr(TempDevCost, pTempDevPenalty*sum{vTotalTempDev[t],t=1:T})
    @defExpr(CurtailCost, pCostCurtail*sum{vPowerCurtail[t],t=1:T})
    @defExpr(NetEnergyCost, EnergyCost+TempDevCost+CurtailCost)
    @defExpr(PrimaryReserveRevenue, sum{pSellPrimaryUpCap[t]*vBattPrimaryUpCap[t]+pSellPrimaryDownCap[t]*vBattPrimaryDownCap[t],t=1:T}+pDelta*sum{pSellPrimaryEnergy[t]*sBattPrimaryUpEnergy[t]+pBuyPrimaryEnergy[t]*sBattPrimaryDownEnergy[t],t=1:T})
    @defExpr(NetworkCost, sum{pMoNetworkCost[m]*vMaxDemand[m],m=1:M})
    @defExpr(TotalCost, NetEnergyCost+NetworkCost+PeakDayCost)
    @defExpr(EnergyRevenue, sum{pSellEnergy[t]*sPowerExport[t],t=1:T})
    @defExpr(TotalRevenue,EnergyRevenue+PrimaryReserveRevenue)
    @defExpr(TotalPowerProvided[t=1:T],vPowerConsumed[t]+sPowerExport[t])

    @setObjective(dre, Min, TotalCost - TotalRevenue)
    solve(dre)

    #REPORTING
    md = zeros(T,1)
    md[1:M] = getValue(vMaxDemand[1:M])
    aUsage = hcat(pMonth[1:T],pWeek[1:T],pHour[1:T],pBuyEnergy[1:T],pSellEnergy[1:T],getValue(vPowerConsumed[1:T]),
                getValue(sPowerProduced[1:T]),getValue(vPowerPurchased[1:T]),getValue(sPowerExport[1:T]),
                getValue(vBattDischarge[1:T]),getValue(vBattCharge[1:T]),pSetpoint[1:T],pOutdoorTemp[1:T],
                getValue(sTempInt[1:T]),getValue(vBattSOC[1:T]),getValue(vBattSOH[1:T]),getValue(vPowerHP[1:T]),
                getValue(vScheduledLoads[1:T]),getValue(vPowerWH[1:T]),getValue(vPowerAC[1:T]),pNonControllableLoad[1:T],
                getValue(EndUseLoads[1:T]), getValue(vBattPrimaryDownCap[1:T]),getValue(vBattPrimaryUpCap[1:T]),
                getValue(sBattPrimaryUpEnergy[1:T]),getValue(sBattPrimaryDownEnergy[1:T]),getValue(sBattPrimaryEnergyLosses[1:T]),
                md[1:T], getValue(sWH_ExtLosses[1:T]))


    aUsage = convert(Array, aUsage)
    dfUsage = convert(DataFrames.DataFrame, aUsage)
    rename!(dfUsage, {:x1=>:Month,:x2=>:Week,:x3=>:Hour,:x4=>:Buy_Energy,:x5=>:Sell_Energy,:x6=>:Power_Consumed,
                :x7=>:Power_Produced,:x8=>:Power_Purchased,:x9=>:Power_Export,:x10=>:Batt_Discharge,:x11=>:Batt_Charge,
                :x12=>:Set_point,:x13=>:Outdoor_temp,:x14=>:Indoor_temp,:x15=>:Battery_SOC,:x16=>:Battery_SOH,
                :x17=>:HP_kW,:x18=>:Scheduled_Loads_kW,:x19=>:WH_kW,:x20=>:AC_kW,:x21=>:NonControllableLoads_kW,
                :x22=>:EndUseLoads_kW,:x23=>:Primary_DownCap,:x24=>:Primary_UpCap,:x25=>:Primary_UpEnergy,:x26=>:Primary_DownEnergy,
                :x27=>:Primary_EnergyLosses,:x28=>:Monthly_Peak_Demand,:x29=>:WH_Losses})

    aCosts = [getValue(TotalCost),getValue(EnergyCost),getValue(NetworkCost),getValue(PeakDayCost),getValue(TotalRevenue),getValue(EnergyRevenue),getValue(PrimaryReserveRevenue),getValue(TempDevCost),getValue(CurtailCost)]
    names = ["Total_Cost","Energy_Cost","Network_Cost","Peak_Day_Cost","Total_Revenue","Energy_Revenue","Primary_Reserve_Revenue","Temp_Deviation_Cost","CurtailCost"]
    aCost_out = hcat(names,aCosts)

    return  dfUsage, aCost_out

end


#builds semi-random schedule of start and finish times for schedulable loads
#function fBuild_Sched(st, fw, nc)
#    df = DataFrame()
#    for i in 0:(nc-1)
#        a = [st,st+fw].+i*48 #sample([36,48,48,60])
#        df = hcat(df,a)
#    end
#    return df
#end
