using DataFrames
using JuMP
using Gurobi
using Statsbase

path = "C:\\Program Files\\Git\\UoF\\Aggregation\\"

#writetable("$path\\inputs\\1\\df1.csv",df1)
#writetable("$path\\inputs\\1\\df2.csv",df2)
#writetable("$path\\inputs\\1\\df3.csv",df3)

df1 = readtable("$path"*"Hourly_Parameters.csv",header=true)
df2 = readtable("$path"*"df2.csv",header=true)
df3 = readtable("$path"*"df3.csv",header=true)

df_out = DataFrame()

tic()
out,k = dr_dre(df1,df2[1,:],df3[1])
df_out = hcat(df_out,out)
if isfile("$path"*"test_outputs.csv")==true
  rm("$path"*"test_outputs.csv")
end
writetable("$path"*"test_outputs.csv",df_out)
a = toq()

k
