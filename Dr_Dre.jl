
using DataFrames
using JuMP, Gurobi
using Statsbase

n=5
df1 = readtable("inputs/1/Hourly_Parameters.csv",header=true)
df2 = rand_tech_parameters(n)
df3 = rand_bldg_loads(n)
df_out = DataFrames.DataFrame()

tic()
for i in 1:n
    df_in1 = df1
    df_in2 = df2[i,:]
    df_in3 = df3[i]
    output_i = dr_dre(df_in1, df_in2, df_in3)
    df_out = hcat(df_out, output_i)
end
#this writes to whatever directory you're in
writetable("agg_outputs.csv",df_out)
toc()

function dr_dre(df1,df2,df3)

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

    pNetworkPeakHour = 117
    pNetworkCostperkW = 0
    pDelta = 1 #duration of time period (hr)
    pCCurtail = 0.25 #cost of curtailment - will depend on the scenario ($/KWH)
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

    
    TT = STDOUT # save original STDOUT stream
    redirect_stdout()
    solve(m)
    #redirect_stdout(TT)
    
    #REPORTING
    aTemp = hcat(pMonth[1:T],pWeek[1:T],pHour[1:T],pBuyEnergy[1:T],pSellEnergy[1:T],getValue(vPowerConsumed[1:T]),
                getValue(sPowerProduced[1:T]),getValue(vPowerPurchased[1:T]),getValue(sPowerExport[1:T]),
                getValue(vBattDischarge[1:T]),getValue(vBattCharge[1:T]),pSetpoint[1:T],pOutdoorTemp[1:T],
                getValue(sTempInt[1:T]),getValue(vBattSOC[1:T]),getValue(vBattSOH[1:T]),getValue(vPowerHP[1:T]),
                getValue(vScheduledLoads[1:T]),getValue(vPowerWH[1:T]),getValue(vPowerAC[1:T]),pNonControllableLoad[1:T],
                getValue(EndUseLoads[1:T]))

    aTemp = convert(Array, aTemp)
    dfUsage = convert(DataFrames.DataFrame, aTemp)
    rename!(dfUsage, {:x1=>:Month,:x2=>:Week,:x3=>:Hour,:x4=>:Buy_Energy,:x5=>:Sell_Energy,:x6=>:Power_Consumed,
                :x7=>:Power_Produced,:x8=>:Power_Purchased,:x9=>:Power_Export,:x10=>:Batt_Discharge,:x11=>:Batt_Charge,
                :x12=>:Set_point,:x13=>:Outdoor_temp,:x14=>:Indoor_temp,:x15=>:Battery_SOC,:x16=>:Battery_SOH,
                :x17=>:HP_kW,:x18=>:Scheduled_Loads_kW,:x19=>:WH_kW,:x20=>:AC_kW,:x21=>:NonControllableLoads_kW,
                :x22=>:EndUseLoads_kW})

    #writetable("outputs.csv",dfUsage)
 
    #out = convert(Array, getValue(vPowerConsumed[1:T]))
    #out = convert(DataFrames.DataFrame, out)
    return  getValue(vPowerConsumed[1:T])
    
end



function rand_tech_parameters(n)
    
    PV = fill(4,n) #sample([3,4,5,6],n)
    B1 = fill(0,n) #pBattNominalE
    B2 = fill(1,n) #pBattDischargeCapacity
    B3 = fill(1,n) #pBattChargeCapacity
    B4 = fill(1,n) #pBatt_DischargeEff
    B5 = fill(1,n) #pBattChargeEff
    B6 = fill(1,n) #pBattCDeg
    B7 = fill(1,n) #pBattInitialSOC
    B8 = fill(1,n) #pBattSOCMax
    B9 = fill(1,n) #pBattSOCMin
    
    H1 = fill(0,n) #pDeadband_HVAC
    H2 = (randn(n)/4)+2 #pCapacitance_HVAC
    H3 = (randn(n)/4)+4 #pResistance_HVAC
    H4 = (randn(n)/4)+2.5 #pCOP_HVAC
    H5 = (randn(n)/4)+5 #pMaxPower_HVAC
    
    W1 = fill(4,n) #pDeadband_WH
    W2 = rand(2:6,n)/10 #pCapacitance_WH
    W3 = rand(100:140,n) #pResistance_WH
    W4 = fill(1,n) #pCOP_WH
    W5 = (randn(n)/4)+4 #pMaxPower_WH
    
    SL1 = sample([7,8,9,17,18,19],n) #pLoadTime
    SL2 = sample([4,5,6,7,8],n) #pFlexWindow
    SL3 = fill(3,n) #pNumCycles
    SL4 = fill(1,n) #pMaxLoad
    SL5 = fill(1,n) #pTotal_SL_kWh
    
    df = hcat(PV,B1,B2,B3,B4,B5,B6,B7,B8,B9,H1,H2,H3,H4,H5,W1,W2,W3,W4,W5,SL1,SL2,SL3,SL4,SL5)
    df = convert(DataFrames.DataFrame, df)
    rename!(df, {:x1=>:PV_Cap,:x2=>:pBatt_NominalE,:x3=>:pBatt_DischargeCapacity,:x4=>:pBatt_ChargeCapacity,
                :x5=>:pBatt_DischargeEff,:x6=>:pBatt_ChargeEff,:x7=>:pBatt_CDeg,:x8=>:pBatt_InitialSOC,
                :x9=>:pBatt_SOCMax,:x10=>:pBatt_SOCMin,:x11=>:pDeadband_HVAC,:x12=>:pCapacitance_HVAC,
                :x13=>:pResistance_HVAC,:x14=>:pCOP_HVAC,:x15=>:pMaxPower_HVAC,:x16=>:pDeadband_WH,
                :x17=>:pCapacitance_WH,:x18=>:pResistance_WH,:x19=>:pCOP_WH,:x20=>:pMaxPower_WH,
                :x21=>:pLoadTime,:x22=>:pFlexWindow, :x23=>:pNumCycles,:x24=>:pMaxLoad,:x25=>:pTotal_SL_kWh,})

    return df
end

#non-controllable loads
function rand_bldg_loads(n)
    profiles = readtable("stock_res_profiles.csv", header = false)
    df = DataFrames.DataFrame()
    for i in 1:n
        a = profiles[rand(1:5)]*((randn()/4)+1)
        df = hcat(df,a)
    end
    return df
    #writetable("profiles.csv",header=false,df)
end

function fBuild_Sched(st, fw, nc)
    df = DataFrame()
    for i in 0:(nc-1)
        a = [st,st+fw].+i*48 #sample([36,48,48,60])
        df = hcat(df,a)
    end
    return df
end
