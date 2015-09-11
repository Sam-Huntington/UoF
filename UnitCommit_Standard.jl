module UnitCommit_Standard

using JuMP
using Gurobi
using DataFrames

function UC(path)	

# SETUP
UnitCommit = Model(solver=GurobiSolver())
#using GLPKMathProgInterface
#UnitCommit = Model(solver=GLPKSolverMIP())

# Read input file
load_in = readtable("$path/input/loads.csv", header=true)     # Load related inputs
gen_in = readtable("$path/input/generators.csv", header=true) # Generator related inputs
segments_in = readtable("$path/input/fuel_segments.csv", header=false) # Piecewise linear fuel use related inputs
fuels_in = readtable("$path/input/fuels.csv", header=true)    # Fuel related inputs
reserves_in = readtable("$path/input/reserves.csv", header=true)    # Reserve related inputs


# INDEXES
G = maximum(dropna(gen_in[:gen_indices])) # Number of generating units
periods = load_in[:periods][1]			    # Number of time periods (e.g. days or weeks)
segments_per_period = maximum(dropna(load_in[:time_indices])) # Number of time segments (e.g. hours) per period
T = periods*segments_per_period             # Number of time segments (e.g. hours)
X = segments_in[1,1]  # Number of segments in piecewise linear variable fuel consumption function


# PARAMETERS
   # Note on syntax: parameter references are lower case as in parameter_name
# Load parameters
load_peak = load_in[:peak_load][1]            # Peak load [MW]
load = zeros(T)						  # per unit load levels for each time t as percent of peak load
for p = 1:periods
	index = indexToNumber(names(load_in), string("period_", p))
	segments = load_in[index]
	for s = 1:segments_per_period
		t = (p-1)*segments_per_period + s
		load[t] = load_peak*segments[s]
	end
end
lost_load_val = load_in[:lost_load_value][1]  # Value of lost load [$]

# Generator parameters
max_power = gen_in[:max_power][1:G]      # Maximum stable power output level for each generator g [MW]
min_power_pu = gen_in[:min_power][1:G]   # Minimum stable power output level for each generator g as percent of max power
min_power = max_power .* min_power_pu    # Minimum stable power output level for each generator g [MW]
ramp_up = gen_in[:ramp_up][1:G]          # Upward ramp limit (as % of max power/hr) for each generation g
ramp_down = gen_in[:ramp_down][1:G]      # Downward ramp limit (as % of max power/hr) for each generation g
reg_up = gen_in[:reg_up][1:G]            # Maximum frequency regulation up capability (as % of max power/hr) for each generation g
reg_down = gen_in[:reg_down][1:G]        # Maximum frequency regulation down capability (as % of max power/hr) for each generation g
follow_up = gen_in[:follow_up][1:G]      # Maximum load following up capability (as % of max power) for each generation g
follow_down = gen_in[:follow_down][1:G]  # Maximum load following down capability (as % of max power) for each generation g
min_up = gen_in[:min_up][1:G]            # Minimum up time for each generator g
min_down = gen_in[:min_down][1:G]        # Minimum down time for each generator g
var_cost = gen_in[:var_cost][1:G]        # Variable O&M costs for each generator g [$/MWh]
fuel_type = gen_in[:fuel][1:G]           # Fuel type for each generator g
  # Piecewise linear marginal fuel use (MMBtu/MW) paramters
fuel_slope = Array(Float32, X, G)
fuel_min = Array(Float32, X, G)
for i = 1:X
    for g = 1:G
        s = 3+i-1
        m = 3+X+i-1
        fuel_slope[i,g] = segments_in[g,s] # Matrix of margina fuel use (MMBtu/MW) for each segment x of piecewise linear variable fuel consumption for each generator g  
        fuel_min[i,g] = segments_in[g,m] # Matrix of intercepts (theoretical fuel use at 0 output) for each segment x of piecewise linear variable fuel consumption for each generator g  
    end
end
  # Start up related generator paramters
startup_cost = gen_in[:start_cost][1:G]  # Fixed startup costs for each generator g in K$/startup
startup_fuel = gen_in[:start_fuel][1:G]  # Start-up fuel consumption for each generator g in billion BTU/startup
fast_start_capable = gen_in[:fast_start][1:G]   # Fast start capability for each generator g [1 = fast start capable, 0 = not]
  # For each fast start capable plant, maximum contribution unit to secondary reserves 
fast_start_up = zeros(Float32, 1, G)
for g = 1:G
    fast_start_up[g] = fast_start_capable[g] * min(1, min_power[g]+ramp_up[g])
end

# Fuel costs & CO2 emissions rate for each fuel type (stored in dictionary objects)
fuels = fuels_in[:fuels] # fuel type indexes
costs = fuels_in[:costs]   # $/MMBtu
CO2 = fuels_in[:CO2]    # tons CO2/MMBtu
fuel_costs = (String => Float32)[]
fuel_CO2 = (String => Float32)[]
for i = 1:length(fuels)
    fuel_costs[fuels[i]] = costs[i]
    fuel_CO2[fuels[i]] = CO2[i]
end

# Reserve related parameters
load_reg_req = reserves_in[:regulation_req][1]      # Primary regulation up and down requirement as % of load
load_follow_req = reserves_in[:follow_req][1]       # Secondary (load following) reserve up and down requirement as % of load
replacement_req = reserves_in[:replacement_req][1]  # Replacement reserve requirement as pu share of largest generator's capacity
non_synched = reserves_in[:non_synched][1]          # Portion of secondary reserves that can be supplied by non-synchronized offline reserves (quick starting units)


# DECISION VARIABLES
  # Note on syntax: decision variable references all begin with lower case v as in vVariableName
@defVar(UnitCommit, vPower[1:G,1:T] >= 0)      # Power output for plant g in time t 
@defVar(UnitCommit, vFuel[1:G,1:T] >= 0)       # Fuel usage for plant g in time t (piecewise linear function)
@defVar(UnitCommit, vRegUp[1:G,1:T] >= 0)      # Primary (regulation) reserve up provided by each plant g in time t 
@defVar(UnitCommit, vRegDown[1:G,1:T] >= 0)    # Primary (regulation) reserve up provided by each plant g in time t
@defVar(UnitCommit, vFollowUp[1:G,1:T] >= 0)   # Secondary (load following) reserve up provided by each plant g in time t
@defVar(UnitCommit, vFollowDown[1:G,1:T] >= 0) # Secondary (load following) reserve down provided by each plant g in time t 
@defVar(UnitCommit, vStandby[1:G,1:T] >= 0)    # Tertiary (replacement) reserve provided by generators (note: only quick-start capable units can provide)
@defVar(UnitCommit, vCommit[1:G,1:T], Bin)     # Binary commitment decision for each generator g at time t (1 = on, 0 = off)
@defVar(UnitCommit, vStartUp[1:G,1:T], Bin)    # Binary start-up decision for each generation g at time t
@defVar(UnitCommit, vShutDown[1:G,1:T], Bin)   # Binary shut-down decision for each generation g at time t
@defVar(UnitCommit, vLostLoad[1:T] >= 0)       # Lost load due to insufficient generation in time t 


# EXPRESSIONS
    # Note on syntax: expression references are first letter upper case as in Expression_Name
  # Var cost = fuel cost + variable O&M   
@defExpr(C_Var, sum{fuel_costs[fuel_type[g]]*vFuel[g,t] + var_cost[g]*vPower[g,t], g=1:G, t=1:T})      
  # Startup Cost = startup fuel cost + fixed
@defExpr(C_Start, sum{(fuel_costs[fuel_type[g]]*startup_fuel[g]*1000 + startup_cost[g]*1000)*vStartUp[g,t], g=1:G, t=1:T})  
  # Lost load penalty = value of lost load * lost load
@defExpr(VLL, lost_load_val*sum{vLostLoad[t], t=1:T})
  # Primary (regulation) reserve up & down requirements = share of load
@defExpr(Reg_Up_Req[t=1:T], load[t]*load_reg_req)    
@defExpr(Reg_Down_Req[t=1:T], load[t]*load_reg_req)   
  # Secondary (spinning & non-spinning) reserve up requirement = share of load + contingency for two largest plants
@defExpr(Follow_Up_Req[t=1:T], load[t]*load_follow_req + replacement_req*maximum(max_power)) #Should be based on largest operating plants using maximum(P_Max[:]*vCommit[t,:])) but syntax not working  
  # Secondary (spinning) reserve down requirement = share of load
@defExpr(Follow_Down_Req[t=1:T], load[t]*load_follow_req)
  # Maximum total secondary up capability of fast start units on standby (non-spinning or replacement reserves)
@defExpr(Fast_Start_Standby[t=1:T], sum{fast_start_up[g]*transpose(ones(Int16, G, 1)-vCommit[:,t])[g], g=1:G})


# OBJECTIVE FUNCTION
@setObjective(UnitCommit, Min, C_Var + C_Start + VLL) 


# CONSTRAINTS
    # Note on syntax: constraint references are of form constraintName

  # System power balance constraint
@addConstraint(UnitCommit, sysBalance[t=1:T], sum(vPower[:,t]) + vLostLoad[t] == load[t])  

   #Piece-wise linear fuel use constraint 
@addConstraint(UnitCommit, fuelUse[g=1:G, t=1:T, x=1:X], 
    vFuel[g,t] >= fuel_slope[x,g]*vPower[g,t] + fuel_min[x,g]*vCommit[g,t])    

  # Unit power output limits
## Versions for use with reserve constraints
@addConstraint(UnitCommit, minPower[g=1:G, t=1:T], 
    vPower[g,t] >= min_power[g]*vCommit[g,t] + vRegDown[g,t] + vFollowDown[g,t]) # Unit min power output constraint
@addConstraint(UnitCommit, maxPower[g=1:G, t=1:T], 
    vPower[g,t] <= max_power[g]*vCommit[g,t] - vRegUp[g,t] - vFollowUp[g,t]) # Unit max power output constraint

 # Unit ramp limits & commitment state (determined by startup/shutdown decisions)
 # Note: These constraints wrap around from t=T to t=1 (i.e. first period is treated as immediately following last period)
@defConstrRef commitState[1:G, 1:T] 
@defConstrRef rampDown[1:G, 1:T] 
@defConstrRef rampUp[1:G, 1:T] 
prior_t = 0
for g = 1:G
    for t = 1:T
        if t==1
            #  Wrap around indices across time periods
            prior_t = T
        else
            prior_t = t-1
        end
        commitState[g,t] = @addConstraint(UnitCommit, 
            vCommit[g,t] == vCommit[g,prior_t] + vStartUp[g,t] - vShutDown[g,t] ) 
        rampDown[g,t] = @addConstraint(UnitCommit,     
            vPower[g,prior_t] - vPower[g,t] <= ramp_down[g]*max_power[g]*vCommit[g,t] + max(min_power[g], ramp_down[g]*max_power[g])*vShutDown[g,t] ) # Downward ramp limit
        rampUp[g,t] = @addConstraint(UnitCommit,  
            vPower[g,t] - vPower[g,prior_t] <= ramp_up[g]*max_power[g]*vCommit[g,t] + max(min_power[g], ramp_up[g]*max_power[g])*vStartUp[g,t] ) # Upward ramp limit
    end
end

  # Min up and down constraints
# Note: Constraints wrap around from t=T to t=1 (i.e. first period is treated as immediately following last period)
@defConstrRef minUpTime[1:G,1:T] 
@defConstrRef minDownTime[1:G,1:T]
first_t = 0
for g = 1:G 
    if (min_up[g] > 0 || min_down[g] > 0)
        for t = 1:T
            # Min up constraints
            if min_up[g] < t
                minUpTime[g,t] = @addConstraint(UnitCommit, 
                    vCommit[g,t] >= sum{vStartUp[g,t_i], t_i=(t-min_up[g]):t})
            else
                # Wrap around constraints
                first_t = max(t, T - (min_up[g] - t) + 1) # Note: max() ensures can't wrap all the way back around to current t
                minUpTime[g,t] = @addConstraint(UnitCommit, 
                    vCommit[g,t] >= sum{vStartUp[g,t_i], t_i=1:t} + sum{vStartUp[g,t_j], t_j = first_t:T})
            end  
            # Min down constraints
            if min_down[g] < t
                minDownTime[g,t] = @addConstraint(UnitCommit, 
                    1 - vCommit[g,t] >= sum{vShutDown[g,t_i], t_i=(t-min_down[g]):t})
            else
                # Wrap around constraints
                first_t = max(t, T - (min_down[g] - t) + 1) # Note: max() ensures can't wrap all the way back around to current t
                minDownTime[g,t] = @addConstraint(UnitCommit, 
                    1 - vCommit[g,t] >= sum{vShutDown[g,t_i], t_i=1:t} + sum{vShutDown[g,t_j], t_j = first_t:T})
            end
        end
    end
end

# Reserve constraints
  # Primary reserve requirements
@addConstraint(UnitCommit, primaryReservesUp[t=1:T], 
    sum(vRegUp[:,t]) >= Reg_Up_Req[t])
@addConstraint(UnitCommit, primaryReservesDown[t=1:T], 
    sum(vRegDown[:,t]) >= Reg_Down_Req[t])
  # Primary reserve capability limits
@addConstraint(UnitCommit, primaryUpCapabilities[g=1:G, t=1:T], 
    vRegUp[g,t] <= reg_up[g]*max_power[g]*vCommit[g,t])
@addConstraint(UnitCommit, primaryDownCapabilities[g=1:G, t=1:T], 
    vRegDown[g,t] <= reg_down[g]*max_power[g]*vCommit[g,t])

  # Secondary reserve requirements
# Online spinning reserves only
@addConstraint(UnitCommit, spinningReservesUp[t=1:T],
    sum(vFollowUp[:,t]) >= (1-non_synched)*Follow_Up_Req[t]) 
@addConstraint(UnitCommit, spinningReservesDown[t=1:T], 
    sum(vFollowDown[:,t]) >= Follow_Down_Req[t])
# Spinning and non-spinning reserves (includes contribution from offline fast-start capable units in standby)
@addConstraint(UnitCommit, secondaryReserves[t=1:T], 
    sum(vFollowUp[:,t]) + sum(vStandby[:,t]) >= Follow_Up_Req[t]) 
  # Secondary reserve capability limits
@addConstraint(UnitCommit, spinningUpCapabilities[g=1:G, t=1:T], 
    vFollowUp[g,t] <= follow_up[g]*max_power[g]*vCommit[g,t])
@addConstraint(UnitCommit, spinningDownCapabilities[g=1:G, t=1:T], 
    vFollowDown[g,t] <= follow_down[g]*max_power[g]*vCommit[g,t])
  # Tertiary (non-spinning or replacement reserves) reserve capability limits (fast start units on standby)
@addConstraint(UnitCommit, standbyCapabilities[g=1:G, t=1:T],
    vStandby[g,t] <= fast_start_up[g]*(1-vCommit[g,t]))
    
    
# SOLVE
solve(UnitCommit)


# OUTPUT
# costs
costs_out = Array(Float64, 4)
costs_out[1] = round(getObjectiveValue(UnitCommit),4)
costs_out[2] = round(getValue(C_Var),4)
costs_out[3] = round(getValue(C_Start),4)
costs_out[4] = round(getValue(VLL),4)
writecsv("$path/output/costs.csv", costs_out)

lost_load_out = round(transpose(getValue(vLostLoad)[:]),4)
writecsv("$path/output/lost_load.csv", lost_load_out)

# plant decisions
power_out = Array(Float64, G, T)
reg_up_out = Array(Float64, G, T)
reg_down_out = Array(Float64, G, T)
follow_up_out = Array(Float64, G, T)
follow_down_out = Array(Float64, G, T)
standby_out = Array(Float64, G, T)
commit_out = Array(Int32, G, T)
start_up_out = Array(Int32, G, T)
shut_down_out = Array(Int32, G, T)
fuel_out = Array(Float64, G, T)
for g = 1:G
    power_out[g,:] = round(getValue(vPower[g,:]),4)
    reg_up_out[g,:] = round(getValue(vRegUp[g,:]),4)
    reg_down_out[g,:] = round(getValue(vRegDown[g,:]),4)
    follow_up_out[g,:] = round(getValue(vFollowUp[g,:]),4)
    follow_down_out[g,:] = round(getValue(vFollowDown[g,:]),4)
    standby_out[g,:] = round(getValue(vStandby[g,:]),4)
    commit_out[g,:] = getValue(vCommit[g,:])
    start_up_out[g,:] = getValue(vStartUp[g,:])
    shut_down_out[g,:] = getValue(vShutDown[g,:])
    fuel_out[g,:] = round(getValue(vFuel[g,:]),4)
end
writecsv("$path/output/power.csv", power_out)
writecsv("$path/output/reg_up.csv", reg_up_out)
writecsv("$path/output/reg_down.csv", reg_down_out)
writecsv("$path/output/follow_up.csv", follow_up_out)
writecsv("$path/output/follow_down.csv", follow_down_out)
writecsv("$path/output/standby.csv", standby_out)
writecsv("$path/output/commit.csv", commit_out)
writecsv("$path/output/start_up.csv", start_up_out)
writecsv("$path/output/shut_down.csv", shut_down_out)
writecsv("$path/output/fuel.csv", fuel_out)


# END UC() FUNCTION
end

# Takes vector of index names (as generated by names(collection)) and a string with a specific index.
# Searches the names vector for that index string and returns the numeric index of that string.
function indexToNumber(names, index)
	num = -1
	for i = 1:size(names, 1)
		if string(names[i]) == index
			num = i
		end
	end
	return num
# END indexToNumber() function
end


# END UnitCommit MODULE
end