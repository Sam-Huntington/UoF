

path = "C:\\Program Files\\Git\\UoF\\Aggregation\\"

#writetable("$path\\inputs\\1\\df1.csv",df1)
#writetable("$path\\inputs\\1\\df2.csv",df2)
#writetable("$path\\inputs\\1\\df3.csv",df3)

df1 = readtable("$path"*"Hourly_Parameters.csv",header=true)
df2 = readtable("$path"*"Tech_Parameters.csv",header=true)
df3 = readtable("$path"*"df3.csv",header=true)

df_out = DataFrame()

tic()
out,k = run_dr_dre(df1,df2[1,:],df3[1])
df_out = hcat(df_out,out)
if isfile("$path"*"test_outputs.csv")==true
  rm("$path"*"test_outputs.csv")
end
writetable("$path"*"test_outputs.csv",df_out)
a = toq()

k
n = ["Total_Cost","Energy_Cost","Network_Cost","Peak_Day_Cost","Total_Revenue","Energy_Revenue","Primary_Reserve_Revenue"]
aCost_Out = hcat(n,k)
writecsv("$path"*"cost_outputs.csv",aCost_Out)
#M
#rename!(dfCosts, {:x1=>:Total_Cost,:x2=>:EnergyCost,:x3=>:NetworkCost,:x4=>:CapacityCost,:x5=>:TotalRevenue,:x6=>:EnergyRevenue,:x7=>:PrimaryReserveRevenue})
