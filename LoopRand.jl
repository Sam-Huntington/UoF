# this file includes 3 functions
#        - rand_tech_parameters(n): creates a dataframe with n rows of semi-random technology parameters
#        - rand_bldg_loads(n): creates a dataframe with n columns of semi-random residential non-controllable load profiles
#        - run_n_rand_Dre(n): reads in price/weather data from filesystem and calls the above two functions to build inputs
#              to Dre, then runs Dre n times (once for each input set) and writes the outputs to a file. Note that Dre
#              can produce many different outputs - which ones are actually spit out is customized within Dre


using DataFrames
using JuMP
using Gurobi
using Statsbase

#run_n_rand_Dre(1)

function run_n_rand_Dre(n)
#builds n sets of random inputs and then runs DrDre n times. Outputs stored in the specified path
    tic() #start timer
    path = "C:\\Program Files\\Git\\UoF\\Aggregation"
    df1 = readtable("$path\\Hourly_Parameters.csv",header=true)
    df2 = rand_tech_parameters(n)
    df3 = rand_bldg_loads(n)
    df_out = DataFrames.DataFrame()

    for i in 1:n
        df_in1 = df1
        df_in2 = df2[i,:]
        df_in3 = df3[i]
        output_i = dr_dre(df_in1, df_in2, df_in3)
        df_out = hcat(df_out, output_i)
    end
    if isfile("$path"*"agg_outputs.csv")==true
        rm("$path"*"agg_outputs.csv")
    end
    writetable("$path\\agg_outputs.csv",df_out)

    return toq()
end

function rand_tech_parameters(n)
#builds a dataframe with n rows of semi-random technology parameters for DrDre
#Note: fill(x,n) simply creates an n-length array of value x
#Note: randn(n) creates an n-length array of normally distributed values, mean=0 and std=1
#Note: sample([x,y,z],n) creats an n-length array with random selections from list [x,y,z]

    PV = fill(4,n)        #sample([3,4,5,6],n)
    B1 = fill(5,n)        #pBattNominalE
    B2 = fill(2.5,n)      #pBattDischargeCapacity
    B3 = fill(2.5,n)      #pBattChargeCapacity
    B4 = fill(1,n)        #pBatt_DischargeEff
    B5 = fill(1,n)        #pBattChargeEff
    B6 = fill(0.1,n)      #pBattCDeg
    B7 = fill(0.5,n)      #pBattInitialSOC
    B8 = fill(1,n)        #pBattSOCMax
    B9 = fill(0.1,n)      #pBattSOCMin

    H1 = fill(1,n)        #pDeadband_HVAC
    H2 = (randn(n)/4)+2   #pCapacitance_HVAC
    H3 = (randn(n)/4)+4   #pResistance_HVAC
    H4 = (randn(n)/4)+2.5 #pCOP_HVAC
    H5 = (randn(n)/4)+5   #pMaxPower_HVAC

    W1 = fill(4,n)        #pDeadband_WH
    W2 = rand(2:6,n)/10   #pCapacitance_WH
    W3 = rand(100:140,n)  #pResistance_WH
    W4 = fill(1,n)        #pCOP_WH
    W5 = (randn(n)/4)+4   #pMaxPower_WH

    SL1 = sample([7,8,9,17,18,19],n) #pLoadTime
    SL2 = sample([4,5,6,7,8],n) #pFlexWindow
    SL3 = fill(3,n)       #pNumCycles
    SL4 = fill(1,n)       #pMaxLoad
    SL5 = fill(1,n)       #pTotal_SL_kWh

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


function rand_bldg_loads(n)
#builds a dataframe with n columns, each with a profile of non-controllable loads
#profiles are based on stock profiles saved in filesystem. Profiles are scaled up an down randomly
#Note: current profiles are based on EnergyPlus load profiles
    profiles = readtable("$path\\stock_res_profiles.csv", header = false)
    df = DataFrames.DataFrame()
    for i in 1:n
        a = profiles[rand(1:5)]*((randn()/4)+1)
        df = hcat(df,a)
     end
    return df
end

