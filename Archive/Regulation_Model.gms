* DER-CAM with 3 daytypes
* version 3.9.4.m
*
* Implement new fiancial incentives for CEC CHPinRest Project
* Set heat storage to operate in High Temperature
* Heat balance for High and Low temperature
* Decoupled heat pumps from absorption chillers
* Heat Pumps code
* 4 CPU threads as standard
* Load shifting code
* Natural gas-only load included in goal function, energy flow and CO2 emissions
* CO2 balance linked with EV charged or discharged at home
* more accurate way of billing electricity sold to/purchase from EV
* consideration of electric vehicles (V2Grid)
* variable PV and solar thermal efficiency and output in m2
* with FiT > purchase tariff
* fixed output rows to simplify automated runs
* with refrigeration load consideration
* ZNEB & Multi-Objective
* with thermal and electrical storage
* with sprint capacity function
* Please change the system efficiency! DSM and sales need to be considered.

* ----------------------------
* > Last revision <
* Date: 2013/09/06
* By: Lenaig Le Gall
* Version 3.9.4.m
* 3 daytype optimization over multiple years (here over 5 years)
* New features :
*     - Opportunity to consider trends in building loads and utility tariffs (electricity rates, fuel prices, utility services...),
*     - Opportunity to consider optimal reinvestments through a dedicated option,
*     - Linear model for stationary battery degradation.
*
* ----------------------------

* >DER-CAM Team<
* Michael Stadler
* Chris Marnay
* Afzal Siddiqui
* Jonathan Donadee
* Olivier Mégel
* Ilan Momber
* Sebastian Beer
* Gonçalo Cardoso
* Judy Lai
* Markus Groissböck
* ----------------------------

* >Copyright<
* Copyright by Lawrence Berkeley National Laboratory (Berkeley Lab),
* Technology Evaluation, Modeling, and Assessment Group
* ----------------------------

* >Contact<
* Contact:
* Michael Stadler
* Lawrence Berkeley National Laboratory
* 1 Cyclotron Road
* Mailstop 90R4000
* Berkeley, CA 94720, USA
* Tel: +1.510.486.4929
* Fax: +1.510.486.6996
* Email: MStadler@lbl.gov
* http://der.lbl.gov/

* Licensing contact:
* Pamela Seidenman
* Marketing Manager
* Technology Transfer and Intellectual Property Management
* Lawrence Berkeley National Lab
* One Cyclotron Road, MS 90-1070
* Berkeley, CA 94720
* tel: +1.510.486.6461
* fax: +1.510.486.6457
* PSSeidenman@lbl.gov
* ----------------------------


* >Acknowledgment<
* Development of this program was begun in 2000 by the Consortium for Electric Reliability Technology Solutions.
* It has been continued with funding provided by the Office of Electricity Delivery and
* Energy Reliability of the U.S. Department of Energy under contracts DE-AC03-76SF00098
* and DE-AC02-05CH11231. Additional support has been provided by the California Energy Commission,
* Public Interest Energy Research Program, under Work for Others Contract No. 150-99-003, 500-07-043, 500-99-013.
* ----------------------------


* >General DER-CAM file Information<
* Distributed Energy Resources Customer Adoption Model (DER-CAM)
* DER-CAM is a software tool developed at the Berkeley Lab in which the economically optimal CHP DER system
* is determined for a site, given the site's energy usage, utility tariffs, and DER equipment options.
* Equipment options include natural gas-fired generators such as reciprocating engines, microturbines,
* and fuel cells; heat recovery and utilization equipment such as heat exchangers and absorption chillers;
* and photovoltaics.

* DER-CAM is written as mixed integer linear program, written in the optimization platform,
* General Algebraic Modeling System (GAMS).  The CPLEX solver is used to solve the program.

* Key inputs to DER-CAM include:
* End-use load profiles
*        electricity only: loads that can only be met by electricity
*        cooling
*        space heating
*        water heating
*        natural gas only (such as cooking and distributed heating)
* Electricity tariff
*        volumetric ($/kWh) prices, varying by time of use and by month
*        demand ($/kW) prices, varying by time of use and by month
*        fixed ($) monthly fees
* Natural gas tariff
*        volumetric ($/kWh) prices, varying by type of use (DG, cooling, or other) and month
*        fixed ($) monthly fees
* Distributed generation costs
*        amortized capital costs for equipment, system design, and installation
*        fixed ($/kW capacity) annual maintenance costs
*        variable ($/kWh) maintenance costs
* Distributed generation performance
*        electrical efficiency
*        heat to electricity ratio for combined heat and power systems
*        minimum and maximum load
* Energy Conversion Efficiency
*        recovered heat used for heating and absorption cooling
*        natural gas used for heating and absorption cooling
*        electricity used for cooling
* Subject to constraints such as
*        maximum payback period
*        minimum CHP efficiency
*        maximum operation hours
* Key outputs include
*        optimal CHP investment
*        operating schedule
*        energy costs
*        fuel consumption and emissions
* ----------------------------

* >Specific DER-CAM file Information<
* City: Oakland ("OAK")
* Building type: Nursing Home ("NH")
* Tariffs: PG&E
* Solar data from San Francisco
* Year: 2006
* Considered DER technologies:
* XXX
* ----------------------------

* >Tree View Structure for front-end tool<
* Please note that the name of the table, parameter, and scalar must be exactly the same as specified in the sections below. If the name differs the front-end can not
* read the hierarchy structure and the table, parameter, scalar. However, do not use the term 'TABLE' and 'PARAMETERS' in the hierarchy structure!
*%h1
*/1/{Simulation Settings};/2/OptionsTable (ModelOption,OptionsVariable) Model Options*%?t;/2/ParameterTable (ParameterOption, ParameterDummy) Parameters for user input*%?t
*/1/{Weather Data};/2/SolarInsolation (months, hours)   Avg. fraction of max. solar insolation (1000W per square meter)*%?t;/2/AmbientHourlyTemperature(months, hours)   in °Celsius*%?t;/2/OtherLocationData (OptionsVariable2) wind speed m per s*%?p
*/1/{Load Data};/2/Load (enduse, months, daytypes, hours)*%?t;/2/NumberOfDays (months, daytypes) days of each type*%?t
*/1/{Load Reduction Measures};/2/DemandResponseParameters (DemandResponseType,DemandResponseInvestParameters)*%?t;/2/DemandResponseParametersHeating (DemandResponseType,DemandResponseInvestParameters)*%?t
*/1/{Load Shift Measures};/2/Table SchedulableLoadParameterTable (SLParameterOption, SLParameterValue) Parameters for user input*%?t
*/1/{Technology Data};/2/{DG};/3/GenConstraints (TECHNOLOGIES, GeneratorConstraints)*%?t;/3/DEROPT (TECHNOLOGIES, TECH_CHARACTERISTICS) DER technologies  information*%?t;/3/Beta (enduse)*%?P;/2/{Direct-fired NG chillers};/3/NGChiller ( NGChillTech, NGChillTechParameter)   direct-fired NG chiller cost and performance parameters*%?t;/3/NGChillForcedInvest (NGChillTech, NGChillForcedInvestParameters)*%?t;/2/{Electric Storage};/3/ElectricityStorageStationaryParameter(StorageParameters)*%?P;/3/ElectricityStorageEVParameter(StorageParameters)*%?P;/3/Electricity_Exchange_EV*%?P;/2/{Heat Storage};/3/HeatStorageParameter(StorageParameters)*%?P;/2/{Heat Pumps};/3/HeatPumpParameterValue(ContinuousInvestType, HeatPumpParameters)*%?t;/2/{Flow Battery};/3/FlowBatteryParameter(StorageParameters)*%?P;/2/ContinuousInvestParameter(ContinuousInvestType,ContinuousInvestParameters)*%?t;/2/ContinuousVariableForcedInvest (ContinuousInvestType,ContForcedInvestParameters)*%?t;/2/StaticSwitchParameter (StaticSwitchParameters)*%?p;/2/COP_Electric_Abs_Chillers*%?p;/2/COP_Electric_Abs_Refrigeration*%?p
*/1/{Fuel Information};/2/FuelPrice (months, FuelType) Fuel Costs*%?t;/2/CO2EmissionsRate (FuelType)*%?P
*/1/{Utility Data};/2/HourlyMarginalCO2Emissions*%?t;/2/MonthlyFee (service)*%?p;/2/MonthlyDemandRates (months, DemandType)*%?t;/2/DailyDemandRates(months, DemandType)*%?t;/2/CoincidentHour(months)   Hour of month that coincident demand charges are applied to*%?p;/2/ElectricityRates (months, TimeOfDay) Monthly volumetric and demand charges*%?t;/2/ListOfHours (hours, seasons, daytypes)*%?t;/2/MonthSeason (months, seasons)*%?t
*/1/{EVs parameters};/2/ElectricityStorageEVParameter(StorageParameters)*%?p
*/1/{Financial Incentives};/2/{Feed In Tariffs};/3/FeedInOptions(FeedInParameters, OptionsVariable) "Feed-in Tariff Requirements"*%?t;/3/PX (months, daytypes, hours) "IE prices in $/kWh"*%?t;/2/{SGIP};/3/SGIPOptions(SGIP_Parameters, OptionsVariable) "SGIP Options"*%?t;/3/SGIPIncentives(TECHTYPE, OptionsVariable) "SGIP incentives by technology"*%?t
*%h2
* -----------------------------

* output restrictions
* Map control
$OFFSYMXREF OFFSYMLIST OFFUELLIST OFFUELXREF
* ----------------------------

$ontext
Iterationoptions/subsystem
Limrow: This controls the number of rows that are listed for each equation
in the EQUATION LISTING section of the listing file.
Specify zero to suppress the EQUATION LISTING altogether.
Limcol: This controls the number of columns that are listed for each
variable in the COLUMN LISTING section of the listing file.
Specify zero to suppress the COLUMN LISTING altogether.
Sysout: This option controls the printing of the solver status file as part of the listing file.
SolPrint: This option controls the printing of the model solution in the listing file.
ITERLIM: Iteration limit
Reslim: Time limit for solver in CPU sec.
optcr: Relative termination criterion, default =0.1
Decimals: Number of decimals printed for symbols not having a specific
print format attached. Range: 0 to 8 (default = 3)
$offtext

OPTION LIMROW=0;
Option LIMCOL=0;
OPTION SYSOUT=OFF;
Option SOLPRINT=OFF;
OPTION ITERLIM=5000000;
*2 hours max. execution time
OPTION Reslim =720000;
*requested
OPTION optcr = 0.001;
OPTION DECIMALS=8;

$onecho > cplex.opt
threads 4
$offecho
* ---------------------------

* SET DECLARATIONS
Sets
* Sets needed for Simulation Options
* 2013/05/31. Lenaig added the option "RenewInvestments" that allows/does not allow optimal new investments in technologies.
    ModelOption 'model options'
        / DiscreteInvest, ContinuousInvest, NGChillInvest, RenewInvestments, Sales, PVSales, BatterySales, NetMetering, InvestmentConst,  SwitchInvest,  StandbyOpt, VaryPrice,
          CHP, CO2Tax, MinimizeCO2, ZNEB, MultiObjective, DiscreteElecStorage, LS, CentralChiller, GSHPAnnualBalance, FuelCellConstraint, Regulation /

    OptionsVariable 'dummy name' / OptionValue /

    OptionsVariable2 / WindSpeed /

* Sets needed for Simulation Parameters
    ParameterOption 'model options'
        / IntRate,Standby, Contrct, turnvar, CO2Tax,
          macroeff, cooleff, BaseCaseCost, MaxPaybackPeriod, FractionBaseLoad,FractionPeakLoad,ReliabilityDER,
          MaxSpaceAvailablePVSolar, PeakPVEfficiency, MultiObjectiveMaxCosts, MultiObjectiveMaxCO2, MultiObjectiveWCosts, MultiObjectiveWCO2 /


    ParameterDummy 'dummy name' / ParameterValue /

    SLParameterOption 'Schedulable Load model options'
        / PercentageSchedulablePeak, PercentageSchedulableWeek, PercentageSchedulableWeekend, MaxLoadInHour, MaxIncrease /
    SLParameterValue 'Schedulable Load parameter Value'
        / ParameterValue /

* Sets needed for finding the optimum solution
*2013/03. Lenaig added a new set for years. This set can be modified by the DER-CAM user to define the time horizon of the optimization. It has been tested up to 10 years.
    YEARS           years
        / 1 * 5 /
*2013/05/31. Lenaig added a subset years_counter for the reason below.
    years_counter(YEARS)   the subset of years that is used to sum annualized capital costs or capacities from different investments
    MONTHS          months
        / january, february, march, april, may, june,
          july, august, september, october, november, december /
    DAYTYPES        load type
        / week, peak, weekend /
    WEEKANDPEAKDAYS (daytypes) week-peak
        / week, peak /
    FUELTYPE        types of fuel
        / Solar, NGbasic, NGforAbs, NGforDG, Diesel /
    TECHTYPE        type of technology
        / FuelCell, GasTurbine, ICEDiesel, ICENG, Microturbine, Photovoltaics /
    SERVICE         types of utility service
        / UtilElectric, UtilNGbasic, UtilNGforDG, UtilNGforABS, UtilDiesel /
    HOURS           24 hours
        / 1 * 24 /
    ENDUSE          enduse
        / electricity-only, cooling, refrigeration, space-heating, water-heating, naturalgas-only /
    SEASONS         two seasons
        / summer, winter /
    TIMEOFDAYPLUS   load periods including coincident
        / on, mid, off, coincident /
    TIMEOFDAY (TIMEOFDAYPLUS)   load periods
        / on, mid, off /
    TARIFFCOMPONENT energy or power
        / energy, power, coincident, MonthlyDemand, DailyDemand /
*%ss
    TECHNOLOGIES         der and chp technologies
        / ICE-small-20________, ICE-med-20__________, GT-20_______________, MT-small-20_________, MT-med-20___________,
          FC-small-20_________, FC-med-20___________, ICE-HX-small-20_____, ICE-HX-med-20_______, GT-HX-20____________,
          MT-HX-small-20______, MT-HX-med-20________, FC-HX-small-20______, FC-HX-med-20________, FC-HX-small-20-wSGIP,
          FC-HX-med-20-wSGIP__, ICE-small-30________, ICE-med-30__________, GT-30_______________, MT-small-30_________,
          MT-med-30___________, FC-small-30_________, FC-med-30___________, ICE-HX-small-30_____, ICE-HX-med-30_______,
          GT-HX-30____________, MT-HX-small-30______, MT-HX-med-30________, FC-HX-small-30______, FC-HX-med-30________,
          FC-HX-small-30-wSGIP, FC-HX-med-30-wSGIP__, MT-HX-small-30-wSGIP, MT-HX-med-30-wSGIP__ /

    TECH_CHARACTERISTICS   der characteristics
        / maxp, lifetime, capcost, OMFix,
          OMVar, SprintCap, SprintHours, Fuel, Type,wasteheat,
          efficiency, alpha, chpenable, coolenable, SGIPIncentive, AllowFeedIn, NoxRate, NoxTreatCost /
    NGChillTech            Direct-fired chillers
        / NGCHILL--------00100, NGCHILL--HX----00100 /
    NGChillTechParameter   direct-fired chiller characteristics
        / maxp, lifetime, capcost, OMFix, OMVar, COP_025, COP_050, COP_075, COP_100, alpha, chpenable /
    NGChillForcedInvestParameters forced invest parameters
        / ForcedInvest, ForcedInvestQuantity /

    ENDUSEFUELS            fuel for all uses
        / Sun, NGDG, NGheat, NGabs, Diesel /
    FUELS (EnduseFuels)    fuels for DG
        / Sun, NGDG, Diesel /
    COINCSET               the coincident set
        / coincident /
    COINC_PARAMETERS       coindident demand paramters
        / coincrate, coinchour /

*TK adders for demand costs based on imperfect reliability
    DisplayMonths (months) the months for which to display hourly disaggregated load data
        / january, july /
    AvailableTECHNOLOGIES(TECHNOLOGIES)      the subset of technologies available for purchase

*GC added the fuel cell subset to deal with the fuel cell startup and shutdown constraint
*01/16/2012
    AvailableFCTechnologies(TECHNOLOGIES)    the subset of available technologies that are Fuel Cells

    AvailableCHPTechnologies(TECHNOLOGIES)   the subset of available technologies that have CHP
    AvailableSGIPTechnologies(TECHNOLOGIES)  the subset of available technologies that have CHP and SGIP incentives

    EnduseRateNGheat(enduse)  NG enduses that get the basic NG rate
        / space-heating, water-heating, naturalgas-only /
    EnduseRateNGabs(enduse)   NG enduses that get the absorption cooling NG rate
        / cooling/
    GeneratorConstraints      types of generator constraints
        / MaxAnnualHours, MinLoad,  ForcedInvest, ForcedNumber /
    DemandType types of demand charges
        / coincident, noncoincident, onpeak, midpeak, offpeak /

    StorageParameters storage parameters for heat or electricity
        / EfficiencyCharge, EfficiencyDischarge, Decay, SelfDischarge, BatteryDegradation, MaxChargeRate, MaxDischargeRate, DiscreteSize, MaxDepthOfDischarge, ConnectingHourOffice,
          DisconnectHourOffice, BeginingHomeCharge, EndHomeCharge, FractionBatteryJourney, BatteryJourney, MinSOCConnect, MinSOCDisconnect,
          MaxStateOfCharge, MaxSOConnect, MaxSOCDisconnect /
* FractionBatteryJourney and BatteryJourney not used yet
*2013/03/22. Lenaig renamed "Decay" and "MinStateOfCharge", replaced them by "SelfDischarge" and "MaxDepthOfDischarge" and then, added 'BatteryDegradation'.

    ContinuousInvestType     continuous investment type
        / ElectricStorage, HeatStorage, AirSourceHeatPump, GroundSourceHeatPump, FlowBatteryEnergy,
          FlowBatteryPower, AbsChiller,  Refrigeration, PV, SolarThermal, EVs1 /
    ContinuousInvestParameters continuous investment parameters
        / FixedCost, VariableCost, Lifetime, FixedMaintenance /
    ContForcedInvestParameters   continuous forced investment parameters...
        / ForcedInvest, ForcedInvestCapacity /

    HeatPumpParameters   specific heat pump parameters
        / COP_heating, COP_cooling, BoreholeCost, HeatTransferBorehole_Cooling, HeatTransferBorehole_Heating /

    StaticSwitchParameters static switch parameters
        / CostM, CostB, Lifetime, Value, ForcedInvest /

    DemandResponseType / low, mid, high /
    DemandResponseInvestParameters / VariableCost, MaxContribution,MaxHours /

    FeedInParameters feed in tariff options
        / MaxInstalledCapacity, MaxExportCapacity, MinHeatRecovered, MinHHVefficiency, MinLHVefficiency /
    SGIP_Parameters
        / enableSGIP, SGIPPercentage, MinSGIPHeatRecovered, MinSGIPHHVefficiency, MinSGIPLHVefficiency, MinSGIPHHVElectricEfficiency, MaxElectricityExport, MaxNoxRate /
    SGIP_Years
        / 1*5 /
;
* ---------------------------

* PARAMETER_DECLARATIONS
*TK this can be with the statement of parameter value
*2013/03. Lenaig - added a year index to some parameters
*                - turned annual parameters needed for the output into 'all period' parameters
*                  (example : "AnnualElectD", annual electricity-only load demand refering to the typical year,
*                   is changed to "AllPeriodElectD" which refers to the total electricity-only load demand for
*                   the considered period (=number of years defined in sets))
PARAMETERS
    MonthlyParameters (years)
*   KWHCost(months,TECHNOLOGIES)  'Energy cost             ($/kWh)'
    ContractDemand (years)            ContractDemand (kW)
*    ContractCost (years,months)       Contract Demand Cost ($)
    ElectricLoadEstimate (years,months,daytypes,hours) a priori stimate of electricity load
    GenNumPenalty(years,TECHNOLOGIES)

*   Needed for the Output
    InsCap             Installed discrete technologies
    InsCHPCap          Installed CHP electric capacity
    AllPeriodElectD          All Period Electricity-Only Load Demand (kWh)
    AllPeriodCoolD           All Period Cooling Demand (kWh)
    AllPeriodRefrD           All Period Refrigeration Demand (kWh)
    AllPeriodSpaceD          All Period Space Heating Demand (kWh)
    AllPeriodWaterD          All Period Water Heating Demand (kWh)
    AllPeriodNatGasOnlyD     All Period Natural Gas-Only Heating Demand (kWh)
    AllPeriodEnergyD         All Period Total Energy Demand (kWh)
    AllPeriodNGforHeatConsumption      All Period natural gas consumption for heating and hot water (kWh)
    AllPeriodGasDER          All Period natural gas purchase for DER (kWh)
    AllPeriodGASDERCosts     All Period natural gas costs for DER ($)
    AllPeriodElectGen        All Period electricity generation from PV + DER (kWh)
    AllPeriodNGChillers      All Period natural gas consumption for Chillers (kWh)
    AnnualTotalEnergyConsumption(years)  Annual total energy consumption (NG + Input for electricity) (kWh)
    AllPeriodTotalEnergyConsumption  All Period total energy consumption (NG + Input for electricity) (kWh)
    SystemEfficiency   Total system efficiency (on-site and off-site), without NG-only load
    SystemEfficiency2  Total system efficiency (on-site and off-site), with NG-only load
    CHPSGIPEfficiency  SGIP CHP efficiency
;
* ----------------------------

*********************************************************
*********   SIMULATION OPTIONS   ************************
*********************************************************
*
* All tables and parameters shown in the front-end tool are listed first
* to increase the performance of the tool

Table OptionsTable (ModelOption,OptionsVariable) Model Options
                                OptionValue
* Option DiscreteInvest       '0-Do nothing 1-Invest in fuel-fired DG technologies'
* Option ContinuousInvest     '0-Do nothing 1-Invest continuous variable techs like pv, solar thermal, storage, and abs chillers'
* Option NGChillInvest        '0-Do nothing 1-Invest in fuel-fired direct compression chiller technologies'
* Option HeatPumpInvest       '0-Do nothing 1-Invest in electric powered heat pumps for heating purposes'
* +*+*+*
* Do not use heat pumps since the design is in progress and would deliver wrong results
* +*+*+*
*
* SwitchInvest                '0-no investment in CERTS microgrid capabilities    1-invest in CERTS microgrid capabilities'
*
* 2013/05/31. Lenaig added the option "RenewInvestments" that allows/does not allow optimal new investments in technologies.
* Option RenewInvestments     '0-no new investment   1-allow optimal new investments'
*                              Investments may be decided in any quantity in any year (before or after the end of the lifetime).
*                              Technologies and capacities can be different from one investment to the next one, they are optimized by DER-CAM.
*
* Option Sales                '0-No sales   1-Sales'
* Option PVSales              '0-No PV Sales 1-Allow PV Sales. If Sales is set to zero PV Sales will be disabled'
* Option BatterySales         '0-No battery sales 1-Allow battery sales. If sales is set to zero BatterySales will be disabled'
*2015/06/11 Dani included BatterySales option
* Option NetMetering          '0-unrestricted electric sales to the macrogrid  1-electricity sales < purchases electricity on an annual basis'
* Option InvestmentConst      '0-unrestricted investments in discrete technologies, if economically attractive  1-total adopted nameplate capacities (discrete technologies) < max. total electric load before any investments'
* Please note that if you use InvestmentConst and NetMetering at the same time the optimization problem might be too restricted
* and the solver might be not able to find a valid solution
*
* Option Standby              '0-No STB     1-Stand by charge'
* Option VaryPrice            '0-Nothing    1-var. turnk. tech x.'
* If you set this Option to 1 the model uses turnvar from table ParameterTable to vary the the capital costs by (1 + turnvar)*capcost
* Option CHP                  '0-with CHP   1-without CHP'
* Option CO2Tax               '0-without CO2 Emissions   1-with CO2 Emissions'
* Option MinimizeCO2          '0-minimize Energy Costs   1-minimize CO2 Emissions'
* Option ZNEB                 '0-no Zero Net Energy Building Constraint   1-Zero Net Energy Building Constraint'
* Option MultiObjective       '0-no multi-objective function   1-multi-objective function, which is a weighted combination of costs and CO2'
* To consider the Multi-Objective frontier please set ZNEB and MinimizeCO2 to 0!
* Option DiscreteElecStorage  '0-batteries can be adopted in any size    1-batteries have to be multiple sizes of DiscreteSize from table ElectricityStorageStationaryParameter(StorageParameters)'
* Option DiscreteElecStorage is especially important for NaS batteries which are produced in multiple sizes of 500 kWh
* To consider load shifting for electricity-only loads use option DR, For on set LS=1
* CentralChiller = 0 means that no central chiller can be used for cooling. However, in the do-nothing case where there are no HPs available this will result in infeasible problems.
* Thus, in the do-nothing case CentralChiller will be always set to 1 internally.
* Also if HPs are turned off (forced to zero) CentralChiller will be always set to 1 internally.
* Option FuelCellConstraint   '0-can start and stop hourly     ´1-has to run a whole day
* Option Regulation           '0-cannot use der generation as regulation 1-can use der generation as regulation'

*2015/02/02 Dani included Regulation option

DiscreteInvest                  0
ContinuousInvest                0
NGChillInvest                   0
SwitchInvest                    0
* 2013/05/31. Lenaig added the option "RenewInvestments".
RenewInvestments                1
Sales                           1
PVSales                         1
BatterySales                    1
*2015/06/11 Dani included BatterySales option
NetMetering                     0
InvestmentConst                 0
StandbyOpt                      0
VaryPrice                       0
CHP                             0
CO2Tax                          0
MinimizeCO2                     0
ZNEB                            0
MultiObjective                  0
DiscreteElecStorage             0
LS                              0
CentralChiller                  1
GSHPAnnualBalance               0
*MG add an option for turn on/off the FC constraint
FuelCellConstraint              1
Regulation                      1
*2015/02/02 Dani included Regulation option
;
****************************************************
********   DATA   **********************************
****************************************************


* Simulation Parameters
Table ParameterTable (ParameterOption, ParameterDummy) Parameters for user input
                                ParameterValue
* IntRate    'Interest rate p.u.
* Standby    'Stand-by charge ($/kW/month)
* Contrct    'Contract demand charge ($/kW)
* turnvar    'turnkey cost variation (pu)
* CO2Tax     'tax on CO2 emissions ($/kgCO2)
* MktCO2Rate 'open market CO2 emissions rate (kgC02/kWh)
* macroeff   'energy efficiency of macrogrid
* cooleff    'conversion of gas to cooling
* BaseCaseCost 'Total Annual Energy Cost prior to DG Installation
* To find a valid BaseCaseCost value you have to run this file
* without any Investment in DG (OptionInvest=0 - Do Nothing)
* an enter the result for 'Goal Function Value'.
* Please make sure that you add some dollars (around $20)
* to the 'Goal Function Value' to give GAMS the possibility to find
* valid solutions. 'BaseCaseCost' is important for 'MaxPaybackPeriod'
*
* MaxPaybackPeriod 'Maximum Payback Period Allowed (years).
* In case that you are using OptionInvest=0 (Do Nothing) increase
* 'MaxPaybackPeriod' to a big number, otherwise the boundary conditions
* might be too tight and GAMS is not able not find any valid solution.
*
* Efficiency = (onsite electricity production + waste heat utilization)/fuel input.
* Please note that this also contains electricity sales from CHP units.
* Also, only CHP units are considered that get California SGIP incentives.
*
* FractionBaseLoad: Relevant for Static Switch. It determines the fraction of
* base load which is considered as sensitive load.
* FractionPeakLoad: Relevant for Static Switch. It determines the fraction of
* peak load which is considered as sensitive load.
*
* ReliabilityDER: For the calculation of the DER switch size an average reliability of the
* DER equipment is necessary
*
* MaxSpaceAvailablePVSolar: Maxium space available for PV and solar thermal (m2)
*
* PeakPVEfficiency: Peak total efficiency for the used PV panels (1), depends on the used model.
* PeakPVEfficiency: Efficiency @ 1000W/m^2, 25°C, no wind and AM = 1.5 (test condition).
*
* MultiObjectiveMaxCosts: Max. Annual Costs, must be >0  ($)
*
* MultiObjectiveMaxCO2: Max. Annual CO2 Emissions, must be > 0  (kgCO2)
*
* Please make sure that MultiObjectiveWCosts + MultiObjectiveWCO2 = 1, with MultiObjectiveWCosts >= 0 and
* MultiObjectiveWCO2 >= 0

IntRate                         .03
Standby                         0
*2014/10/25 José this is the capacity charge
Contrct                         3.17
turnvar                         0
*2014/10/25  José CO2 tax equal to cero
CO2Tax                          0

macroeff                        .34
cooleff                         0
*2014/10/25  José base cost needs to be changed
BaseCaseCost                    116576
MaxPaybackPeriod                10
FractionBaseLoad                .5
FractionPeakLoad                .1
ReliabilityDER                  .9
MaxSpaceAvailablePVSolar        400
PeakPVEfficiency                .1529
MultiObjectiveMaxCosts          1
MultiObjectiveMaxCO2            1
MultiObjectiveWCosts            .6
MultiObjectiveWCO2              .4
;
* -----------------------------

* 2020 day distribution
* Data Section and calculation of associated parameters
TABLE NumberOfDays (months, daytypes) days of each type
            peak      week      weekend
* Please use this table to specify the number of peak, week, and weekend days
* for each month. If the year you are considering is a leap year please note
* the relation between this table and table 'GenConstraints(TECHNOLOGIES, GeneratorConstraints).
* If you are using 8760 hours for MaxAnnualHours in 'GenConstraints(TECHNOLOGIES, GeneratorConstraints)'
* and a leap year, the 8760 hours must be replaced by 8784 hours,
* otherwise the DER equipment is not allowed to run the whole year.

January     3         20        8
February    3         17        9
March       3         19        9
April       3         19        8
May         3         18        10
June        3         19        8
July        3         20        8
August      3         18        10
September   3         19        8
October     3         19        9
November    3         18        9
December    3         20        8
;
*2014/10/25 José import data
$ontext
* San Francisco
TABLE SolarInsolation (months, hours)   Avg. fraction of max. solar insolation (1000W per square meter)
            1              2              3              4              5              6              7              8              9              10             11             12             13             14             15             16             17             18             19             20             21             22             23             24
* Avg. fraction of max. solar insolation
* (1000W per square meter, 1 square meter = 10.76 square foot)

January     0              0              0              0              0              0              0              .000189252     .167539233     .327551507     .434029869     .477058336     .513141136     .456683308     .418646718     .307494689     .044962567     0              0              0              0              0              0              0
February    0              0              0              0              0              0              0              .014138093     .22283787      .422664274     .498943938     .652373557     .552194113     .605904811     .523669154     .332202852     .239198792     .001231369     0              0              0              0              0              0
March       0              0              0              0              0              0              .0000387891    .125951415     .338746177     .55620855      .668071805     .733239858     .793653914     .74301295      .627781758     .488883682     .305687855     .037941301     0              0              0              0              0              0
April       0              0              0              0              0              .00000180616   .003893774     .204134129     .425376115     .580250453     .734275359     .829258121     .812739507     .816395292     .694333802     .49634704      .299585572     .129000571     .0000488184    0              0              0              0              0
May         0              0              0              0              0              .000779958     .027032378     .214375731     .384835738     .574299229     .685120808     .763039671     .791249932     .761186633     .650377957     .494329687     .321185843     .139417531     .007926973     0              0              0              0              0
June        0              0              0              0              0              .007264393     .030929943     .213630456     .389211207     .543188656     .656313679     .726382403     .760064506     .727388681     .60866132      .500049176     .325479952     .157616373     .046452702     .0000320555    0              0              0              0
July        0              0              0              0              0              .011794277     .017795012     .205459799     .395222194     .522050169     .628797002     .682765536     .711984614     .674280028     .547467431     .471631733     .317537001     .155400722     .031536726     .0000226526    0              0              0              0
August      0              0              0              0              0              .00000106091   .005806121     .168385143     .388012675     .549926504     .634364684     .714397528     .712374803     .688663057     .581653708     .480424438     .301438231     .13239788      .003693844     0              0              0              0              0
September   0              0              0              0              0              0              .001049745     .169530178     .375026368     .539313851     .664967862     .690690735     .689279735     .672013381     .581465905     .414023925     .254296691     .051860842     0              0              0              0              0              0
October     0              0              0              0              0              0              .000253072     .171519814     .37271792      .503040996     .616022104     .638759418     .609084893     .562465331     .464640497     .338359868     .144242563     .0000703339    0              0              0              0              0              0
November    0              0              0              0              0              0              0              .058180849     .259682756     .433146519     .567094439     .632106582     .61108461      .548200869     .412160437     .250094307     .013382225     0              0              0              0              0              0              0
December    0              0              0              0              0              0              0              .004954366     .208514098     .383244503     .472593656     .526495699     .529008776     .445973463     .369389414     .250917623     .022730801     0              0              0              0              0              0              0
;

* California
TABLE AmbientHourlyTemperature(months, hours)   in °Celsius
            1           2           3           4          5           6           7           8           9           10          11          12          13          14          15          16          17          18          19          20          21          22          23          24
* used to calculate the efficiency of PV and solar thermal as funtion of the ambient temperature

January     8.1         7.9         7.8         7.7        7.8         7.9         8.0         8.9         9.7         10.6        11.5        12.4        13.3        13.4        13.6        13.8        12.8        11.9        10.9        10.4        9.9         9.3         8.9         8.5
February    9.7         9.5         9.3         9.1        8.8         8.6         8.2         9.5         10.7        12.0        13.2        14.4        15.5        15.6        15.7        15.8        14.9        13.9        13.0        12.3        11.7        11.1        10.5        10.1
March       11.1        10.6        10.1        9.6        9.3         9.0         8.7         9.9         11.1        12.3        13.4        14.5        15.6        15.9        16.1        16.4        15.6        14.8        14.0        13.6        13.1        12.6        12.1        11.6
April       10.3        9.8         9.4         9.0        9.4         9.7         10.1        11.5        13.0        14.5        15.6        16.8        18.0        18.1        18.2        18.4        17.0        15.5        14.1        13.5        12.9        12.2        11.5        10.8
May         11.2        11.1        10.8        10.4       10.9        11.3        11.7        13.2        14.6        16.1        17.5        18.9        20.4        20.2        20.0        19.8        18.2        16.6        15.0        14.0        13.2        12.2        11.7        11.5
June        13.0        12.9        12.7        12.3       12.9        13.6        14.2        15.5        16.7        18.0        19.4        20.7        22.0        21.6        21.1        20.7        19.3        17.8        16.4        15.5        14.7        13.8        13.3        13.1
July        13.4        13.3        13.1        13.0       13.4        13.7        14.1        15.5        16.9        18.3        19.8        21.3        22.8        22.4        22.1        21.8        20.2        18.6        17.1        16.3        15.5        14.7        14.0        13.7
August      14.0        13.8        13.6        13.4       13.5        13.7        13.9        15.2        16.5        17.9        19.6        21.4        23.1        22.6        22.1        21.6        20.1        18.5        17.1        16.3        15.7        14.9        14.4        14.1
September   14.8        14.5        14.1        13.7       13.5        13.7        14.7        16.2        17.7        19.0        20.6        22.2        23.4        23.6        23.2        22.4        21.3        19.5        18.2        17.2        16.6        16.1        15.6        15.2
October     13.4        12.9        12.4        11.9       12.1        12.3        12.5        14.2        15.8        17.4        18.6        19.9        21.1        21.2        21.2        21.3        19.9        18.6        17.2        16.6        16.0        15.3        14.6        13.9
November    10.8        10.2        9.6         9.2        9.3         9.3         9.9         11.5        13.4        14.4        15.3        16.6        17.1        17.4        17.3        16.3        15.0        14.1        13.3        12.7        11.9        11.7        11.5        11.2
December    8.2         7.9         7.4         6.9        6.9         7.0         7.0         8.1         9.3         10.4        11.5        12.6        13.6        13.8        13.9        14.1        13.0        12.0        11.0        10.3        9.7         9.1         8.6         8.3
;
$offtext
* San Francisco
Parameter
OtherLocationData (OptionsVariable2) wind speed m per s
/
WindSpeed 5
/;

* California (2020)
Table HourlyMarginalCO2Emissions (months,hours)
            1            2            3            4            5            6            7            8            9            10           11           12           13           14           15           16           17           18           19           20           21           22           23           24
* all numbers in kgC02/kWh

January     .481746583   .480936526   .494054128   .486273062   .485150078   .509145785   .525330791   .516663906   .507155512   .497523708   .504104566   .503535631   .508636132   .492484539   .510616570   .525129430   .520751755   .512332234   .506786653   .488385143   .519013373   .509525247   .497797880   .4736548
February    .504965908   .521956621   .507946724   .530684710   .516157864   .506402525   .507069358   .529334700   .509769645   .503835412   .492813116   .486018443   .489844955   .501052230   .496736778   .496172794   .527699663   .539537123   .515270076   .506900737   .495170836   .498236731   .491622390   .488536277
March       .505358200   .556058867   .557902993   .547899422   .529392109   .520293926   .500453832   .501196474   .486287422   .484293627   .474786678   .482221377   .482418787   .486844493   .493572540   .495440217   .487876409   .498711987   .491089313   .483829801   .484754768   .487540816   .491126213   .513775955
April       .524414291   .546542175   .616499733   .604602223   .559804894   .502737779   .532098798   .509197359   .507965060   .501644473   .502819122   .506566405   .498736634   .505787333   .507096546   .479762340   .517789125   .517457840   .487059887   .580973896   .541363252   .507696174   .516368172   .506394334
May         .531052814   .564394651   .580164246   .565106113   .544601901   .495560258   .522344909   .513489470   .499671515   .485817883   .483296476   .491006655   .480577680   .481858705   .496508359   .518177756   .533902773   .483607966   .492716847   .526674433   .496700878   .482293432   .499074396   .511605014
June        .500379835   .485026777   .539777959   .538613995   .428604814   .493172920   .513156044   .509790898   .460039986   .483845887   .496333347   .469993837   .502262812   .514911172   .514323199   .519923212   .556999724   .507665457   .494186101   .467815537   .501936022   .501372080   .467074771   .477093349
July        .482737281   .496777447   .483691470   .490346581   .504696274   .492577859   .492545235   .511379084   .517888908   .517763346   .516429018   .538962490   .556764008   .514828790   .481551860   .453167394   .525339169   .530317752   .529394542   .533351049   .522514340   .511569534   .488972303   .478241591
August      .519714278   .511717295   .520024780   .518496413   .534491071   .518157568   .512587080   .491244194   .505201984   .519342537   .535581403   .540975659   .532140653   .544072205   .510542486   .542147949   .516241280   .528391058   .545484781   .563651832   .531649848   .510696889   .511494442   .527223514
September   .511319061   .480955649   .492512363   .511786053   .485706068   .532907631   .506533210   .516833168   .526934300   .518591994   .517868893   .540586242   .541014058   .511214335   .543120744   .490953192   .527608904   .544533074   .549210015   .542517392   .540444325   .535969879   .501807315   .513738185
October     .489221462   .495747928   .501436070   .506515208   .516648487   .502418965   .529823131   .529581737   .513463098   .504507803   .515139670   .510499716   .523030811   .508510248   .509772396   .512870721   .528474178   .521526414   .523091542   .519102938   .499143006   .488738925   .494584203   .491702767
November    .503811212   .499479136   .503063669   .514076285   .501754091   .492877271   .520685843   .502337031   .523283088   .508793314   .510443889   .503323776   .515631365   .511405326   .516234281   .512005592   .523321493   .518881813   .504159909   .504846578   .511652307   .503999470   .492158646   .489155284
December    .486977303   .506978290   .505844562   .502001081   .516669050   .501390618   .523289251   .508057703   .517834019   .503992296   .497395331   .505513615   .521762796   .510844657   .510961287   .526539345   .531712554   .526834337   .517609932   .505767436   .503938689   .495273795   .507042574   .486324336
;
*2014/25/10 Gas prices changes

* PGE
Table ListOfHours (hours, seasons, daytypes)
            summer.week      summer.peak      summer.weekend   winter.peak      winter.week      winter.weekend
* Please enter the on-peak, mid-peak, and off-peak periods for each season and daytype.
* on-peak = 1, mid-peak = 2, off-peak = 3

1           3                3                3                3                3                3
2           3                3                3                3                3                3
3           3                3                3                3                3                3
4           3                3                3                3                3                3
5           3                3                3                3                3                3
6           3                3                3                3                3                3
7           3                3                3                3                3                3
8           3                3                3                3                3                3
9           2                2                3                2                2                3
10          2                2                3                2                2                3
11          2                2                3                2                2                3
12          2                2                3                2                2                3
13          1                1                3                2                2                3
14          1                1                3                2                2                3
15          1                1                3                2                2                3
16          1                1                3                2                2                3
17          1                1                3                2                2                3
18          1                1                3                2                2                3
19          2                2                3                2                2                3
20          2                2                3                2                2                3
21          2                2                3                2                2                3
22          2                2                3                2                2                3
23          3                3                3                3                3                3
24          3                3                3                3                3                3
;

* PGE
Table MonthSeason (months, seasons)
            Summer   Winter
* Please specify the summer and winter months.
* 1 = enabled, 0 = disabled

January     0        1
February    0        1
March       0        1
April       0        1
May         1        0
June        1        0
July        1        0
August      1        0
September   1        0
October     1        0
November    0        1
December    0        1
;
$ontext
* PGE
Table FuelPrice1 (months, FuelType) Fuel Costs
            Solar      NGbasic    NGforDG    NGforAbs   Diesel
* Solar (/)   NGbasic ($/kWh)   NGforDG ($/kWh)
* NGforAbs ($/kWh)   Diesel ($/kWh)

January     0          .026059    .026059    .026059    0
February    0          .026059    .026059    .026059    0
March       0          .026059    .026059    .026059    0
April       0          .023668    .023668    .023668    0
May         0          .023668    .023668    .023668    0
June        0          .023668    .023668    .023668    0
July        0          .023668    .023668    .023668    0
August      0          .023668    .023668    .023668    0
September   0          .023668    .023668    .023668    0
October     0          .023668    .023668    .023668    0
November    0          .026059    .026059    .026059    0
December    0          .026059    .026059    .026059    0
;
*2013/09/06. Lenaig renamed "FuelPrice(months,FuelType)" as "FuelPrice1(months,FuelType)" and defined "FuelPrice(years,months,FuelType)" with a year index.
*This enables to consider a trend in fuel prices.
Parameter FuelPrice (years, months, FuelType);
FuelPrice (years, months, FuelType) = FuelPrice1 (months, FuelType);
***

* PGE
Table MonthlyDemandRates1 (months, DemandType)
             coincident      noncoincident   onpeak          midpeak         offpeak
* (all in $/kW)

January     0               0               0               0               0
February    0               0               0               0               0
March       0               0               0               0               0
April       0               0               0               0               0
May         0               0               0               0               0
June        0               0               0               0               0
July        0               0               0               0               0
August      0               0               0               0               0
September   0               0               0               0               0
October     0               0               0               0               0
November    0               0               0               0               0
December    0               0               0               0           0
;
*2013/09/06. Lenaig renamed "MonthlyDemandRates(months,DemandType)" as "MonthlyDemandRates1(months,DemandType)"
*and defined "MonthlyDemandRates(years,months,DemandType)" with a year index. This enables to consider a trend in monthly demand rates.
Parameter MonthlyDemandRates (years, months, DemandType);
MonthlyDemandRates (years, months, DemandType) = MonthlyDemandRates1 (months, DemandType);
***
$offtext
* PGE
Table DailyDemandRates1 (months, DemandType)
            coincident      noncoincident   onpeak          midpeak         offpeak
* (all in $/kW)

January     0               0               0               0               0
February    0               0               0               0               0
March       0               0               0               0               0
April       0               0               0               0               0
May         0               0               0               0               0
June        0               0               0               0               0
July        0               0               0               0               0
August      0               0               0               0               0
September   0               0               0               0               0
October     0               0               0               0               0
November    0               0               0               0               0
December    0               0               0               0               0
;
*2013/09/06. Lenaig renamed "DailyDemandRates(months,DemandType)" as "DailyDemandRates1(months,DemandType)"
*and defined "DailyDemandRates(years,months,DemandType)" with a year index. This enables to consider a trend in daily demand rates.
Parameter DailyDemandRates (years, months, DemandType);
DailyDemandRates (years, months, DemandType) = DailyDemandRates1 (months, DemandType);
***
$ontext
* PGE
Table ElectricityRates1 (months, TimeOfDay) Monthly volumetric and demand charges
                On             Mid            Off
* (all in $/kWh)

January         0              0.09063        0.07320
February        0              0.09063        0.07320
March           0              0.09063        0.07320
April           0              0.09063        0.07320
May             0.13476        0.09579        0.07028
June            0.13476        0.09579        0.07028
July            0.13476        0.09579        0.07028
August          0.13476        0.09579        0.07028
September       0.13476        0.09579        0.07028
October         0.13476        0.09579        0.07028
November        0              0.09063        0.07320
December        0              0.09063        0.07320
;
*2013/09/06. Lenaig renamed "ElectricityRates(months,TimeOfDay)" as "ElectricityRates1(months,TimeOfDay)"
*and defined "ElectricityRates (years, months, TimeOfDay)" with a year index. This enables to consider a trend in electricity rates.
Parameter ElectricityRates (years, months, TimeOfDay);
ElectricityRates (years, months, TimeOfDay) = ElectricityRates1 (months, TimeOfDay);
***

* PGE
TABLE PX1 (months, daytypes, hours) "IE prices in $/kWh"
                              1     2     3     4     5     6     7     8     9     10    11    12    13    14    15    16    17    18    19    20    21    22    23    24
* PX Prices in $/kWh
* In this version of DER-CAM the PX prices are only relevant if you consider
* electricity sales. Electricity is always purchased at TOU tariff rates
* and sold as specified in this table. Furthermore, if you specify higher numbers
* than the TOU tariffs, negative total energy costs can occur and therefore please
* make sure that the PX prices are in relation to the TOU tariffs specified in
* table 'Electricity Rates'.

January   .         Week      .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .161  .161  .161  .161  .161  .161  .161  .161  .138  .138  .097
February  .         Week      .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .161  .161  .161  .161  .161  .161  .161  .161  .138  .138  .097
March     .         Week      .089  .089  .089  .089  .089  .089  .089  .132  .132  .132  .132  .132  .132  .179  .179  .179  .179  .179  .179  .179  .179  .138  .138  .089
April     .         Week      .089  .089  .089  .089  .089  .089  .089  .132  .132  .132  .132  .132  .132  .179  .179  .179  .179  .179  .179  .179  .179  .138  .138  .089
May       .         Week      .089  .089  .089  .089  .089  .089  .089  .132  .132  .132  .132  .132  .132  .179  .179  .179  .179  .179  .179  .179  .179  .138  .138  .089
June      .         Week      .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .348  .348  .348  .348  .348  .348  .348  .348  .164  .164  .086
July      .         Week      .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .348  .348  .348  .348  .348  .348  .348  .348  .164  .164  .086
August    .         Week      .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .348  .348  .348  .348  .348  .348  .348  .348  .164  .164  .086
September .         Week      .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .348  .348  .348  .348  .348  .348  .348  .348  .164  .164  .086
October   .         Week      .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .161  .161  .161  .161  .161  .161  .161  .161  .138  .138  .097
November  .         Week      .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .161  .161  .161  .161  .161  .161  .161  .161  .138  .138  .097
December  .         Week      .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .161  .161  .161  .161  .161  .161  .161  .161  .138  .138  .097
January   .         Peak      .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .161  .161  .161  .161  .161  .161  .161  .161  .138  .138  .097
February  .         Peak      .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .161  .161  .161  .161  .161  .161  .161  .161  .138  .138  .097
March     .         Peak      .089  .089  .089  .089  .089  .089  .089  .132  .132  .132  .132  .132  .132  .179  .179  .179  .179  .179  .179  .179  .179  .138  .138  .089
April     .         Peak      .089  .089  .089  .089  .089  .089  .089  .132  .132  .132  .132  .132  .132  .179  .179  .179  .179  .179  .179  .179  .179  .138  .138  .089
May       .         Peak      .089  .089  .089  .089  .089  .089  .089  .132  .132  .132  .132  .132  .132  .179  .179  .179  .179  .179  .179  .179  .179  .138  .138  .089
June      .         Peak      .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .348  .348  .348  .348  .348  .348  .348  .348  .164  .164  .086
July      .         Peak      .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .348  .348  .348  .348  .348  .348  .348  .348  .164  .164  .086
August    .         Peak      .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .348  .348  .348  .348  .348  .348  .348  .348  .164  .164  .086
September .         Peak      .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .348  .348  .348  .348  .348  .348  .348  .348  .164  .164  .086
October   .         Peak      .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .161  .161  .161  .161  .161  .161  .161  .161  .138  .138  .097
November  .         Peak      .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .161  .161  .161  .161  .161  .161  .161  .161  .138  .138  .097
December  .         Peak      .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .161  .161  .161  .161  .161  .161  .161  .161  .138  .138  .097
January   .         Weekend   .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .097
February  .         Weekend   .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .097
March     .         Weekend   .089  .089  .089  .089  .089  .089  .089  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .089
April     .         Weekend   .089  .089  .089  .089  .089  .089  .089  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .089
May       .         Weekend   .089  .089  .089  .089  .089  .089  .089  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .132  .089
June      .         Weekend   .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .086
July      .         Weekend   .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .086
August    .         Weekend   .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .086
September .         Weekend   .086  .086  .086  .086  .086  .086  .086  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .164  .086
October   .         Weekend   .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .097
November  .         Weekend   .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .097
December  .         Weekend   .097  .097  .097  .097  .097  .097  .097  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .138  .097
;
*2013/09/06. Lenaig renamed "PX(months,daytypes,hours)" as "PX1(months,daytypes,hours)"
*and defined "PX (years,months,daytypes,hours)" with a year index. This enables to consider a trend in daily prices to sell electricity to the grid.
Parameter PX (years,months,daytypes,hours);
PX (years,months,daytypes,hours) = PX1(months,daytypes,hours);
***
$offtext
TABLE SGIPOptions(SGIP_Parameters, OptionsVariable) "SGIP Options"
                             OptionValue
*Use this table to set the SGIP general options
*
* enableSGIP                controls whether or not to consider SGIP incentives
*    (setting this number to zero will disable all technologies with SGIP incentives)
* SGIPPercentage            percentage of SGIP incentive to consider. SGIPercentage = 1 means 100% of SGIP incentive
* MinSGIPHeatRecovered      minimum share of recovered heat in all SGIP technologies
* MinSGIPHHVefficiency      minimum HHH global fuel efficiency
* MinSGIPLHVefficiency      minumum LHV global fuel efficiency
* MinHHVElectricEfficiency  minimum HHV electric fuel efficiency
* MaxElectricityExport      maximum global share of electricity export allowed to get SGIP incentives
* MaxNOxRate                maximum NOx rate allowed in SGIP Technologies. Units kg / MWh (NOTE UNITS)

enableSGIP                   0
SGIPPercentage               1.00
MinSGIPHeatRecovered         0.05
MinSGIPHHVefficiency         0.60
MinSGIPLHVefficiency         0.425
MinSGIPHHVElectricEfficiency 0.40
MaxElectricityExport         0.25
MaxNOxRate                   0.03175
;
*2014/25/10 Incentives are zero
Table SGIPIncentives(TECHTYPE, OptionsVariable) "SGIP incentives by technology"
                         OptionValue
*Use this table to set the SGIP Incentive value
*Values are in $/ W (NOTE UNITS)

FuelCell                 0
GasTurbine               0
ICENG                    0
MicroTurbine             0
;

TABLE FeedInOptions(FeedInParameters, OptionsVariable) "Feed-in Tariff Requirements"
                         OptionValue
*These parameters are used in
*MaxInstalledCapacity is the maximum total capacity the system can have in order to apply for electricity sales
*MaxExportCapacity is the maximum capacity the system can export
*MinHeatRecovered is the minimum share of heat recovered by CHP systems [ Heat / (Heat + Electricity) ] in order to qualify for the Feed-in-Tariffs
*MinHHVefficiency is the minimum HHV fuel consumption efficiency at rated capacity
*MinLHVefficiency is the minimum LHV fuel consumption efficiency at rated capacity

MaxInstalledCapacity     20000
MaxExportCapacity        5000
MinHeatRecovered         0.05
MinHHVefficiency         0.60
MinLHVefficiency         0.425
;

* note that not all of the technology data is in here
* should make HX an option for each tech,(i.e. just have one line per tech and just add $/kW cost for HX)
TABLE DEROPT (TECHNOLOGIES, TECH_CHARACTERISTICS) DER technologies  information
                       maxp            lifetime        capcost         OMFix           OMVar           SprintCap       SprintHours     Fuel            Type            efficiency      alpha           Chpenable       SGIPIncentive   AllowFeedIn     NoxRate         NoxTreatCost
* TECHNOLOGY TYPES                      FUEL TYPES
* Fuel Cell        1                    NGbasic          2
* Gas Turbine      2                    NGforAbs         3
* ICE, Diesel      3                    NGforDG          4
* ICE, NG          4                    Diesel           5
* Microturbine     5
*
* maxp (kW)   lifetime (years)   capcost ($/kW) OMFix ($/kW/year)  OMVar ($/kWh)
* SprintCap (kW)
* Please enter for SprintCap numbers greater or equal than maxp to avoid optimization problems
* Sprinthours (hours) Fuel (2,3,4,5)
* Type (1,2,3,4,5,6)   efficiency (/)
*
* alpha (kW/kW) - specifies the amount of recoverable heat (kW) from one kW electricity
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* Please not that in old DER-CAM versions there was also a Gamma (typically 0.8 for space heating).!!!!!!
* In the old DER-CAM versions alpha was multiplied with gamma.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* gamma: kW of heat produced from one kW of recovered heat!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* In this new version we do not use gamma anymore and gamma is included in the alpha value.!!!!!!!!!!!!!!
* This means if you want reproduce old results you have to multiply the 'old' alpha with the 'old' gamma!
* and use it as 'new' alpha in this table.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* alpha is 0 for all technologies without heat exchanger / absorption chiller
* chpenable (0/1, 1=yes)
* SGIPIncentive (0/1, 1= yes). This is important to know which technologies must verify the SGIP requirements

ICE-small-20________   60              20              2098            0               .021            60              0               4               4               .29             0               0               0               1               0               300
ICE-med-20__________   250             20              1143            0               .015            250             0               4               4               .30             0               0               0               0               0               300
GT-20_______________   1000            20              2039            0               .011            1000            0               4               2               .22             0               0               0               0               0               0
MT-small-20_________   60              10              2116            0               .017            60              0               4               5               .28             0               0               0               0               0               0
MT-med-20___________   150             10              1723            0               .017            150             0               4               5               .29             0               0               0               0               0               0
FC-small-20_________   100             10              4969            0               .033            100             0               4               1               .40             0               0               0               0               0               0
FC-med-20___________   250             10              3981            0               .033            250             0               4               1               .40             0               0               0               0               0               0
ICE-HX-small-20_____   60              20              2760            0               .021            60              0               4               4               .29             1.73            1               0               0               0               300
ICE-HX-med-20_______   250             20              1681            0               .015            250             0               4               4               .30             1.48            1               0               0               0               300
GT-HX-20____________   1000            20              2794            0               .011            1000            0               4               2               .22             1.96            1               0               0               0               0
MT-HX-small-20______   60              10              2377            0               .017            60              0               4               5               .28             1.8             1               0               0               0               0
MT-HX-med-20________   150             10              1935            0               .017            150             0               4               5               .29             1.4             1               0               0               0               0
FC-HX-small-20______   100             10              5778            0               .033            100             0               4               1               .40             1               1               0               0               0               0
FC-HX-med-20________   250             10              4629            0               .033            250             0               4               1               .40             1               1               0               0               0               0
FC-HX-small-20-wSGIP   100             10              5778            0               .033            100             0               4               1               .40             1               1               1               1               0               0
FC-HX-med-20-wSGIP__   250             10              4629            0               .033            250             0               4               1               .40             1               1               1               1               0               0
ICE-small-30________   60              20              1587            0               .021            60              0               4               4               .29             0               0               0               0               0               300
ICE-med-30__________   250             20              865             0               .015            250             0               4               4               .30             0               0               0               0               0               300
GT-30_______________   1000            20              1932            0               .011            1000            0               4               2               .22             0               0               0               0               0               0
MT-small-30_________   60              10              1410            0               .017            60              0               4               5               .31             0               0               0               0               0               0
MT-med-30___________   150             10              1148            0               .017            150             0               4               5               .33             0               0               0               0               0               0
FC-small-30_________   100             10              3605            0               .033            100             0               4               1               .46             0               0               0               0               0               0
FC-med-30___________   250             10              2889            0               .033            250             0               4               1               .46             0               0               0               0               0               0
ICE-HX-small-30_____   60              20              2088            0               .021            60              0               4               4               .29             1.73            1               0               0               0               300
ICE-HX-med-30_______   250             20              1271            0               .015            250             0               4               4               .30             1.48            1               0               0               0               300
GT-HX-30____________   1000            20              2647            0               .011            1000            0               4               2               .22             1.96            1               0               0               0               0
MT-HX-small-30______   60              10              1584            0               .017            60              0               4               5               .31             1.8             1               0               0               0               0
MT-HX-med-30________   150             10              1290            0               .017            150             0               4               5               .33             1.4             1               0               0               0               0
FC-HX-small-30______   100             10              4192            0               .033            100             0               4               1               .46             1               1               0               0               0               0
FC-HX-med-30________   250             10              3359            0               .033            250             0               4               1               .46             1               1               0               0               0               0
MT-HX-small-30-wSGIP   60              10              1584            0               .017            60              0               4               5               .33             1.8             1               1               0               0               0
MT-HX-med-30-wSGIP__   150             10              1290            0               .017            150             0               4               5               .33             1.4             1               1               0               0               0
FC-HX-small-30-wSGIP   100             10              4192            0               .033            100             0               4               1               .46             1               1               1               0               0               0
FC-HX-med-30-wSGIP__   250             10              3359            0               .033            250             0               4               1               .46             1               1               1               0               0               0
*2013/07/18. Lenaig deleted xxx technologies.
;

Table GenConstraints (TECHNOLOGIES, GeneratorConstraints)
                       MaxAnnualHours   MinLoad          ForcedInvest     ForcedNumber
* Please note that you can use this table to enable or disable specific discrete DG technologies / units.
* If you set 'MaxAnnualHours' to 0 the technology will be disabled.
* If you want force a technology set 'ForcedInvest' to 1
* Please specify for 'ForcedNumber' the number of forced units.
* If the year you are considering is a leap year please note the relation between this table and
* table 'TABLE NumberOfDays (months, daytypes)'. If you are using 8760 hours for MaxAnnualHours
* and a leap year, the 8760 hours must be replaced by 8784 hours,
* otherwise the DER equipment is not allowed to run the whole year.
ICE-small-20________   8784             .25              0                0
ICE-med-20__________   8784             .25              0                0
GT-20_______________   8784             .5               0                0
MT-small-20_________   8784             .5               0                0
MT-med-20___________   8784             .5               0                0
FC-small-20_________   8784             .90              0                0
FC-med-20___________   8784             .90              0                0
ICE-HX-small-20_____   8784             .25              0                0
ICE-HX-med-20_______   8784             .25              0                0
GT-HX-20____________   8784             .5               0                0
MT-HX-small-20______   8784             .5               0                0
MT-HX-med-20________   8784             .5               0                0
FC-HX-small-20______   8784             .90              0                0
FC-HX-med-20________   8784             .90              0                0
FC-HX-small-20-wSGIP   0                .90              0                0
FC-HX-med-20-wSGIP__   0                .90              0                0
ICE-small-30________   0                .25              0                0
ICE-med-30__________   0                .25              0                0
GT-30_______________   0                .5               0                0
MT-small-30_________   0                .5               0                0
MT-med-30___________   0                .5               0                0
FC-small-30_________   0                .90              0                0
FC-med-30___________   0                .90              0                0
ICE-HX-small-30_____   0                .25              0                0
ICE-HX-med-30_______   0                .25              0                0
GT-HX-30____________   0                .5               0                0
MT-HX-small-30______   0                .5               0                0
MT-HX-med-30________   0                .5               0                0
FC-HX-small-30______   0                .90              0                0
FC-HX-med-30________   0                .90              0                0
MT-HX-small-30-wSGIP   0                .5               0                0
MT-HX-med-30-wSGIP__   0                .5               0                0
FC-HX-small-30-wSGIP   0                .90              0                0
FC-HX-med-30-wSGIP__   0                .90              0                0
;

Table NGChiller ( NGChillTech, NGChillTechParameter)   direct-fired NG chiller cost and performance parameters
                       maxp   lifetime  capcost   OMFix     OMVar     COP_025   COP_050   COP_075 COP_100     alpha     chpenable
* maxp is kW of cooling offset, assuming 4.5 COP electric chiller
* maxp (kW)   lifetime (years)   capcost ($/kW) OMFix ($/kW/year)  OMVar ($/kWh)
* alpha (kW/kW) -  is always 1
* chpenable (0/1, 1=yes)
NGCHILL--------00100   100    10        100       100       0.02      2         2         2       2           1         0
NGCHILL--HX----00100   100    10        100       100       0.02      2         2         2       2           1         1
;

Table NGChillForcedInvest (NGChillTech, NGChillForcedInvestParameters)
                       ForcedInvest           ForcedInvestQuantity
* ForcedInvest  = 1 to force invest
* ForcedInvestQuantity = number of units to purchase
NGCHILL--------00100   0                      0
NGCHILL--HX----00100   0                      0
;

*TK get better estimated for maintenance costs
Table ContinuousInvestParameter(ContinuousInvestType,ContinuousInvestParameters)
                     FixedCost          VariableCost       Lifetime           FixedMaintenance
* FixedCost ($ if you invest) regardless of system size
* VariableCost ($/kW or $f/kWh)
* Note abs. chiller capacity is in terms of electricity offset (electric load equivalent) and
* this effects the $/kWh and fixed maintenance costs.
* Please also note that PV costs should be represented by $/kWACpeak
* SolarThermal costs are in kW peak.
* Please note that $400/kWpeak are equivalent to $280/m2 using a maximum conversation efficiency of 0.7 kW/m2,
* which also considers the "useless" frame area, etc. Older versions of DER-CAM used $250/m2 which seems a bit low.
* Lifetime (years)
* FixedMaintenance ($/kW per month or $/kWh per month)
*2014/25/10 Jose investment costs have been changed
ElectricStorage      300                350                10                 0
HeatStorage          10000              1000               17                 0
FlowBatteryEnergy    0                  2200               10                 0
FlowBatteryPower     0                  2125               10                 0
AbsChiller           9391200            68522              20                 1.88
Refrigeration        93912.00           753.74             20                 2.07
PV                   3000               2000               25                 0.25
SolarThermal         0                  500000             15                 0.50
EVs1                 10000              5                  1                  0
*2014/10/08 big investment cost to not to invest
AirSourceHeatPump    100000             70000              10                 0.52
GroundSourceHeatPump 100000             790040             10                 0.32
;

*NOTE CAPACITY FOR ABSORPTION CHILLER = ELECTRIC CHILLER LOAD OFFSET
Table ContinuousVariableForcedInvest (ContinuousInvestType,ContForcedInvestParameters)
                     ForcedInvest           ForcedInvestCapacity
* ForcedInvest (=1 to force invest)     ForcedInvestCapacity (kW or kWh)

ElectricStorage      0                      0
HeatStorage          0                      0
FlowBatteryEnergy    0                      0
FlowBatteryPower     0                      0
AbsChiller           0                      0
Refrigeration        0                      0
PV                   0                      0
SolarThermal         0                      0
EVs1                 1                      0
AirSourceHeatPump    1                      0
GroundSourceHeatPump 1                      0
;

Table HeatPumpParameterValue(ContinuousInvestType, HeatPumpParameters)
                     COP_Heating         COP_Cooling       BoreHoleCost      HeatTransferBorehole_Heating        HeatTransferBorehole_Cooling
* COP_Heating  Heat pump heating COP
* COP_Cooling  Heat pump Cooling COP
* Borehole related costs are only relevant for ground source heat pumps
* BoreHoleCost Cost per borehole meter ($/m)
* HeatTransferBorehole_Heating Heat transfer per borehole meter when in heating mode (W/m)
* HeatTransferBorehole_Cooling Heat transfer per borehole meter when in cooling mode (W/m)

AirSourceHeatPump    6                    6                 0                 0                                  0
GroundSourceHeatPump 4.5                  5                 15.52             50                                 7
;
*2014/25/10 José This includes all the data
file TMP / tmp.txt /
$onecho  > tmp.txt
   i="Regulation_Model_Beta.xls"
   r1=AnnualLoad1
   o1=AnnualLoad1
   r2=PX1
   o2=PX1
   r3=ElectricityRates11
   o3=ElectricityRates11
   r4=SolarInsolation
   o4=SolarInsolation
   r5=AmbientHourlyTemperature
   o5=AmbientHourlyTemperature
   r6=MonthlyDemandRates1
   o6=MonthlyDemandRates1
   r7=FuelPrice1
   o7=FuelPrice1
   r8=RegulationEnergyPrice1
   o8=RegulationEnergyPrice1
   r9=RegulationCapacityUpPrice1
   o9=RegulationCapacityUpPrice1
   r10=RegulationCapacityDownPrice1
   o10=RegulationCapacityDownPrice1
   r11=RegulationEnergyPrice2
   o11=RegulationEnergyPrice2
$offecho
*2015/01/15 Dani included regulation data
$call xls2gms @"tmp.txt"

table AnnualLoad1 (enduse, months, daytypes, hours)
$include  AnnualLoad1
;

TABLE PX1 (months, daytypes, hours) "IE prices in $/kWh"
$include  PX1
;
Table ElectricityRates11 (months,daytypes, hours) Monthly volumetric and demand charges
$include ElectricityRates11
;
*Table ElectricityRates2 (months,daytypes, TimeOfDay) Monthly volumetric and demand charges
*$include ElectricityRates2
*;

Table SolarInsolation (months,hours) in 1000W hour
$include SolarInsolation
;
Table AmbientHourlyTemperature (months,hours)  in celcius
$include AmbientHourlyTemperature
;
;
Table MonthlyDemandRates1 (months, DemandType)  "in $/kWh"
$include  MonthlyDemandRates1
;
Table FuelPrice1 (months,FuelType) "in €/kWh"
$include FuelPrice1
;
*
Table RegulationEnergyPrice1 (months, daytypes, hours) "in €/MWh"
$include RegulationEnergyPrice1
;
Table RegulationCapacityUpPrice1 (months, daytypes, hours) "in €/MWh"
$include RegulationCapacityUpPrice1
;
Table RegulationCapacityDownPrice1 (months, daytypes, hours) "in €/MWh"
$include RegulationCapacityDownPrice1
;
Table RegulationEnergyPrice2(months, daytypes, hours) "in €/MWh"
$include RegulationEnergyPrice2
;
*
*2015/01/14 Dani included regulation parameters

execute 'del tmp.txt AnnualLoad1 PX1 ElectricityRates11 SolarInsolation AmbientHourlyTemperature MonthlyDemandRates1 FuelPrice1 RegulationEnergyPrice RegulationCapacityUpPrice RegulationCapacityDownPrice' ;
;
*2014/10/10 José parameter for Spanish tariffs
Parameter Exchangerate Euro-dolar exchange rate                     [€-$] /1.30/ ;
Parameter Lossescoef   Losses coefficient                           [%market price]   /0.148/;
Parameter Taxes        IVA 21%                                      [%]   /0.21/ ;
Parameter Elect_tax    Electricity tax autonomous communities       [%]   /0.06/;
Parameter Energy_component energy component to recover fixed costs  [€]   /0.053/    ;
Parameter Fixedcomp     Fixed component on the tariff               [€]   /0/  ;
Parameter EnergyConsumed Maximum energy in a year kwh               [kwh] /9000000/;
Parameter Fixedtariff    Fixed tariff component "0 no" "1 yes"      [0 1] /0    /;
*Parameter MonthlyDemandRates3  monthly capacity charg             [€-kwh] /0/;
Parameter Balancingcost  Cost of system balancing           [%market price]/0.07/;
Parameter Capacitypayment Payment for capcity OM and OS             [€]   /0/;
*2014/10/07 Jose change in ElectricityRates hourly
Parameter ElectricityRates (years, months,daytypes, hours);
* 0.053255 includes all variable components as losses
*
Parameter DispatchToContractRatioUp amount of energy supplied for regulation divided by the amount of regulation service capacity supplied to the market [%] /0.2981/;
Parameter DispatchToContractRatioDown amount of energy supplied for regulation divided by the amount of regulation service capacity supplied to the market [%] /0.2387/;
*2015/02/10 DispatchToContractRatio values were obtained from Spanish market dividing the secondary regulation asignation by the energy used
*2015/01/15 Dani included regulation parameters

ElectricityRates (years, months,daytypes, hours) = (((ElectricityRates11 (months,daytypes, hours)*(1+Balancingcost))*(1+Lossescoef))+Energy_component+Capacitypayment)*Exchangerate*(1+Taxes+Elect_tax);
Parameter MonthlyDemandRates (years, months, DemandType);
 MonthlyDemandRates (years, months, DemandType)= MonthlyDemandRates1 ( months, DemandType);


Parameter FuelPrice (years, months, FuelType);
FuelPrice (years, months, FuelType) = FuelPrice1 (months, FuelType)*Exchangerate*(1+Taxes+Elect_tax);

*
Parameter RegulationEnergyPrice (years, months, daytypes, hours);
RegulationEnergyPrice (years, months, daytypes, hours) = RegulationEnergyPrice1 (months, daytypes, hours)*Exchangerate/1000;
Parameter RegulationCapacityUpPrice (years, months, daytypes, hours);
RegulationCapacityUpPrice (years, months, daytypes, hours) = RegulationCapacityUpPrice1 (months, daytypes, hours)*Exchangerate/1000;
Parameter RegulationCapacityDownPrice (years, months, daytypes, hours);
RegulationCapacityDownPrice (years, months, daytypes, hours) = RegulationCapacityDownPrice1 (months, daytypes, hours)*Exchangerate/1000;
Parameter RegulationEnergyPricep (years, months, daytypes, hours);
RegulationEnergyPricep (years, months, daytypes, hours) = RegulationEnergyPrice2 (months, daytypes, hours)*Exchangerate/1000;
*
*2015/01/15 Dani included regulation parameters

$ontext
TABLE AnnualLoad1 (enduse, months, daytypes, hours)
* 2013/09/06. Lenaig renamed 'Load' as 'AnnualLoad1'.
* San Francisco LSCHL
                                                                    1             2             3             4             5             6             7             8             9             10            11            12            13            14            15            16            17            18            19            20            21            22            23            24
electricity-only        .        January         .        week      102.3465866   103.5521804   106.8661296   115.8967204   131.8510223   154.6287139   222.1153484   337.4141927   385.3113997   402.6036163   409.4711619   399.1653945   387.8456235   372.9985603   328.0718769   256.8420086   182.2092666   157.2430788   122.7149385   107.676321    104.3497389   104.6930537   102.9954692   102.7210578
electricity-only        .        February        .        week      99.58034831   101.1348917   105.2728125   115.922695    133.7706964   159.8825033   231.74817     349.4337805   412.981712    431.2894287   438.1212057   427.0292587   415.2124702   401.9304798   351.1269805   276.2156913   190.5759826   119.8953208   123.4703873   107.4315029   102.817921    102.6116314   100.7691998   100.0438494
electricity-only        .        March           .        week      95.95458393   96.98871737   100.8007394   111.4540303   129.6785514   156.9888477   192.082823    351.2636998   418.3782649   438.4579542   446.9946122   436.0969081   424.6047964   411.977535    359.7946175   284.5940122   193.8578199   119.8685402   123.3666609   106.982989    101.8201148   101.2506547   98.61111981   96.8994062
electricity-only        .        April           .        week      94.93161604   97.96555852   106.7487754   122.7354909   147.1444158   209.1484692   305.455957    392.8993653   428.1056226   443.3086757   439.6711098   428.8209835   409.6676866   364.8975759   293.9655298   215.0544293   137.7569214   92.39933041   71.1183833    93.28077492   100.3620011   98.143095     96.12505562   94.97251581
electricity-only        .        May             .        week      92.7570154    94.61838482   100.4947718   111.7259522   134.6106203   159.1644453   285.3717217   365.2740732   392.0093952   408.5006805   404.4791945   395.2310449   370.476055    319.0018293   249.1756063   185.105705    117.8811946   85.11044179   71.56043831   100.3960891   99.71901547   95.04431208   93.02402266   92.15649892
electricity-only        .        June            .        week      90.65765702   91.63726817   94.95343109   102.1839607   122.8396062   140.4448689   249.5599752   323.1785543   348.1602353   366.8623717   367.066732    361.2057025   317.8353076   268.0778676   203.0267384   161.2335719   109.1689977   83.6151937    73.88104815   100.2531256   99.2797362    93.30739312   91.37980607   90.57473304
electricity-only        .        July            .        week      87.05659634   87.0894544    87.69189299   90.74143065   105.916034    114.7079569   203.3365343   254.1342433   270.7005982   285.501429    286.3745408   284.7448473   233.1634082   197.89952     145.3407937   118.2904642   94.09583664   78.33512227   74.32684645   98.39078528   97.26917079   90.798193     88.87728656   87.11063595
electricity-only        .        August          .        week      88.91363272   90.3224778    95.04224538   104.4551254   124.019114    140.2863188   236.1401117   295.4357782   314.1646848   330.409006    331.1464737   327.8023833   279.965342    236.5261316   175.4067996   138.2135845   99.1557879    77.26962327   68.52031983   98.01146275   96.95230005   92.11982088   90.16046797   88.53145095
electricity-only        .        September       .        week      92.73754778   95.63465926   104.7849828   121.188848    146.3379228   212.8011756   326.2428293   399.9965202   421.3838814   431.9321588   423.3306623   413.4218885   400.9676712   350.8334335   279.8558427   192.8622656   117.3582836   83.62067975   105.7300577   100.114964    99.03299216   95.91068007   94.02565359   92.46545524
electricity-only        .        October         .        week      93.43589927   96.19071279   104.7911352   120.5617248   144.4975898   203.5564936   345.2723144   397.782261    419.0478702   430.2904639   423.4244263   412.3431057   401.0912517   358.0461565   290.8244343   204.4129341   128.1772413   88.34368053   101.5037974   101.2719665   99.76643808   97.33808638   95.12111589   93.37116552
electricity-only        .        November        .        week      96.13849431   96.91540419   100.878847    110.7098037   126.7340844   150.9904195   214.0145901   318.1279426   375.6502165   390.934608    397.6858835   387.0210164   376.4382569   366.3251797   320.9511443   254.3349851   172.510763    149.0563194   119.6751659   105.6879296   101.4382482   100.7714179   97.90297528   96.76055768
electricity-only        .        December        .        week      100.686049    102.0306343   105.4361216   115.3545818   132.183989    154.7100663   220.5275924   352.766596    376.8909145   394.8388003   403.8063038   394.83055     383.618142    364.7534504   318.9152221   248.4945228   178.6612908   155.7094027   121.4739877   106.6922803   103.0924758   103.6814394   101.8404027   101.0781315
electricity-only        .        January         .        peak      102.3465866   103.5521804   106.8661296   115.8967204   131.8510223   154.6287139   222.1153484   337.4141927   385.3113997   402.6036163   409.4711619   399.1653945   387.8456235   372.9985603   328.0718769   256.8420086   182.2092666   157.2430788   122.7149385   107.676321    104.3497389   104.6930537   102.9954692   102.7210578
electricity-only        .        February        .        peak      99.58034831   101.1348917   105.2728125   115.922695    133.7706964   159.8825033   231.74817     349.4337805   412.981712    431.2894287   438.1212057   427.0292587   415.2124702   401.9304798   351.1269805   276.2156913   190.5759826   119.8953208   123.4703873   107.4315029   102.817921    102.6116314   100.7691998   100.0438494
electricity-only        .        March           .        peak      95.95458393   96.98871737   100.8007394   111.4540303   129.6785514   156.9888477   192.082823    351.2636998   418.3782649   438.4579542   446.9946122   436.0969081   424.6047964   411.977535    359.7946175   284.5940122   193.8578199   119.8685402   123.3666609   106.982989    101.8201148   101.2506547   98.61111981   96.8994062
electricity-only        .        April           .        peak      94.93161604   97.96555852   106.7487754   122.7354909   147.1444158   209.1484692   305.455957    392.8993653   428.1056226   443.3086757   439.6711098   428.8209835   409.6676866   364.8975759   293.9655298   215.0544293   137.7569214   92.39933041   71.1183833    93.28077492   100.3620011   98.143095     96.12505562   94.97251581
electricity-only        .        May             .        peak      92.7570154    94.61838482   100.4947718   111.7259522   134.6106203   159.1644453   285.3717217   365.2740732   392.0093952   408.5006805   404.4791945   395.2310449   370.476055    319.0018293   249.1756063   185.105705    117.8811946   85.11044179   71.56043831   100.3960891   99.71901547   95.04431208   93.02402266   92.15649892
electricity-only        .        June            .        peak      90.65765702   91.63726817   94.95343109   102.1839607   122.8396062   140.4448689   249.5599752   323.1785543   348.1602353   366.8623717   367.066732    361.2057025   317.8353076   268.0778676   203.0267384   161.2335719   109.1689977   83.6151937    73.88104815   100.2531256   99.2797362    93.30739312   91.37980607   90.57473304
electricity-only        .        July            .        peak      87.05659634   87.0894544    87.69189299   90.74143065   105.916034    114.7079569   203.3365343   254.1342433   270.7005982   285.501429    286.3745408   284.7448473   233.1634082   197.89952     145.3407937   118.2904642   94.09583664   78.33512227   74.32684645   98.39078528   97.26917079   90.798193     88.87728656   87.11063595
electricity-only        .        August          .        peak      88.91363272   90.3224778    95.04224538   104.4551254   124.019114    140.2863188   236.1401117   295.4357782   314.1646848   330.409006    331.1464737   327.8023833   279.965342    236.5261316   175.4067996   138.2135845   99.1557879    77.26962327   68.52031983   98.01146275   96.95230005   92.11982088   90.16046797   88.53145095
electricity-only        .        September       .        peak      92.73754778   95.63465926   104.7849828   121.188848    146.3379228   212.8011756   326.2428293   399.9965202   421.3838814   431.9321588   423.3306623   413.4218885   400.9676712   350.8334335   279.8558427   192.8622656   117.3582836   83.62067975   105.7300577   100.114964    99.03299216   95.91068007   94.02565359   92.46545524
electricity-only        .        October         .        peak      93.43589927   96.19071279   104.7911352   120.5617248   144.4975898   203.5564936   345.2723144   397.782261    419.0478702   430.2904639   423.4244263   412.3431057   401.0912517   358.0461565   290.8244343   204.4129341   128.1772413   88.34368053   101.5037974   101.2719665   99.76643808   97.33808638   95.12111589   93.37116552
electricity-only        .        November        .        peak      96.13849431   96.91540419   100.878847    110.7098037   126.7340844   150.9904195   214.0145901   318.1279426   375.6502165   390.934608    397.6858835   387.0210164   376.4382569   366.3251797   320.9511443   254.3349851   172.510763    149.0563194   119.6751659   105.6879296   101.4382482   100.7714179   97.90297528   96.76055768
electricity-only        .        December        .        peak      100.686049    102.0306343   105.4361216   115.3545818   132.183989    154.7100663   220.5275924   352.766596    376.8909145   394.8388003   403.8063038   394.83055     383.618142    364.7534504   318.9152221   248.4945228   178.6612908   155.7094027   121.4739877   106.6922803   103.0924758   103.6814394   101.8404027   101.0781315
electricity-only        .        January         .        weekend   103.001928    103.457191    103.8544852   104.9755741   107.1447013   112.3211958   110.8027465   86.4325069    75.30219289   78.86287891   83.48548256   85.61601752   81.92292181   75.31571829   66.8411805    59.02237381   55.2266254    103.6175681   104.7918589   106.6170912   109.5116387   108.8513891   106.754416    105.5234266
electricity-only        .        February        .        weekend   100.2117996   101.5609175   103.082652    103.9219545   106.5327824   111.8955199   110.1268863   71.93743299   69.94379029   71.41185465   74.01821381   77.06436076   74.884771     70.45699449   63.28848721   55.78595013   50.93243498   60.56132796   100.5663051   101.8160499   104.3859161   104.6362409   102.8982026   102.2593766
electricity-only        .        March           .        weekend   97.23089087   98.20094426   99.01938439   100.0844643   102.7636004   108.5060802   68.19086437   66.66591621   66.07295098   69.49286863   71.05752352   73.92050644   72.71279617   68.43551732   61.51673056   54.19262795   49.55040295   58.46237409   98.65212685   99.8991255    102.5638197   102.8475817   100.5957135   99.28678436
electricity-only        .        April           .        weekend   93.59297336   94.19273582   95.54694926   97.55676571   102.7457569   102.7153002   67.76841106   71.39613813   74.01967093   83.59687964   87.15093429   86.91212313   77.59075458   68.27459222   58.12530112   52.43982407   58.75904177   58.55410241   58.92032355   94.44908924   99.18010082   97.03906765   95.04104621   93.65895722
electricity-only        .        May             .        weekend   92.12942712   92.43657457   93.0538773    94.68487643   98.82317715   56.75748715   56.00717052   70.09546945   75.4116705    87.52400605   91.25545361   91.09962736   79.35752511   68.01579359   56.48564917   52.19193233   60.25608535   58.04956367   57.74367573   98.08571829   97.52805512   95.30388528   93.50013897   91.86810024
electricity-only        .        June            .        weekend   90.65461125   90.774082     91.23659127   92.03387428   94.18219765   49.96601977   49.06413889   67.72084267   76.36080774   90.07829224   91.02466149   90.82462477   78.19295607   66.92690029   55.23133944   52.46041075   61.51050966   57.17764899   56.82593997   96.6479908    95.64705566   93.64890258   91.7835586    90.30952848
electricity-only        .        July            .        weekend   87.1217342    87.21283896   87.22940952   87.22113028   87.42542864   41.02376116   39.26076088   58.55326644   70.38698797   83.97718502   85.220666     85.53218018   74.95158275   64.11641881   53.08235452   50.87411849   61.19427047   55.59805239   54.71904102   92.25802117   91.52454096   90.20781259   88.41434542   87.0636306
electricity-only        .        August          .        weekend   87.85037101   87.93150839   88.25628493   88.97595172   91.29455786   47.59110616   47.29081821   66.38270515   75.64450607   89.5221783    90.93497859   90.72779239   78.55111362   66.47566591   54.06671876   52.2478382    60.83141123   56.44369077   55.54662208   94.67435149   93.59923627   91.55646035   89.32032114   88.02060156
electricity-only        .        September       .        weekend   91.54981564   91.69980552   92.46289089   93.90362579   98.5593495    97.24969214   59.07886557   62.80971882   65.91044774   71.2661633    75.07541811   75.06373114   70.14911296   63.5576115    56.93874196   52.54637005   60.74501605   60.58771176   99.4663328    99.48790164   98.7291023    95.8163648    93.8122876    91.57107321
electricity-only        .        October         .        weekend   92.31106853   92.559611     93.41253998   95.31845156   100.5102171   100.390072    100.9279576   68.92109438   67.68739641   71.13377734   72.4866549    70.98689591   66.86047447   60.76022963   54.50908986   50.85539008   57.58670871   59.14698369   93.73744712   99.30469675   99.08016743   97.03429659   94.58830656   91.9737876
electricity-only        .        November        .        weekend   96.60600232   98.19884668   99.68464002   102.0462677   104.1314544   110.7741827   109.6465309   70.74595823   68.83523523   72.05168931   74.29668474   75.44084526   73.32131017   68.75777783   61.45356233   54.38671353   50.79781827   98.35032869   99.58864515   101.0709194   102.9829166   103.7349265   101.9670086   101.1258455
electricity-only        .        December        .        weekend   98.94461066   99.62572326   100.5175606   101.2668915   103.6346428   108.4649355   106.0770627   106.9620519   73.6868123    75.81330327   84.02312781   85.05306676   83.35537797   74.44138814   65.90852163   57.30361631   53.38241426   100.921494    100.0867339   101.063769    103.5292727   103.2357082   101.5748426   100.4889013
cooling                 .        January         .        week      .751635235    .832450501    .832006216    .832143082    .831708026    1.742102981   1.265732521   2.289613327   3.698045357   5.617824297   7.731442813   10.4956415    13.38824581   14.44206212   13.90932644   8.003079938   4.045717572   1.392880791   .103776631    .207420968    .231744539    .28209903     .364173482    .502453576
cooling                 .        February        .        week      .770471377    .896122802    .990700457    1.084926131   1.083933892   2.406432577   1.879357275   3.148838601   6.861433031   10.1184242    13.57659564   17.37171388   21.18739579   24.23152124   24.58910096   15.06968755   8.635333858   1.886875764   .04118279     .0626423      .1535357      .244214542    .269526541    .357328514
cooling                 .        March           .        week      .432652353    .550700527    .672196086    .731343721    .821358395    2.69795297    2.083914181   4.020602316   10.31251737   14.95986965   23.61644283   30.92793805   36.96620675   46.03803445   45.63256913   30.38883905   13.65450883   2.630271982   .053476872    .034955421    .026895146    .050927237    .046250628    .221206934
cooling                 .        April           .        week      .212932069    .353562713    .496968529    .583130405    2.500500944   2.625776787   4.076611544   10.89663115   19.0286215    29.1203402    39.28286376   47.89450782   55.82034571   58.98744672   48.35558921   30.43959226   6.866111233   1.292960645   .069040088    .03891426     .031632882    .052734074    .080330723    .16010574
cooling                 .        May             .        week      .142206243    .139756       .246095261    .272531082    3.352689309   3.486222586   7.137661183   23.86672225   35.52986235   49.24254736   63.4767759    76.33279197   87.27647573   77.95479103   65.23769759   47.21804484   5.992552143   1.589260675   .253759816    .090073416    .068212374    .060174797    .052054568    .040504005
cooling                 .        June            .        week      .118803831    .105410646    .097813112    .151623439    3.822413481   5.592116165   17.67767754   42.67250701   55.94620922   75.29277713   91.03514598   108.4150495   110.1847875   83.93182459   72.28399323   58.73341151   9.956073257   5.979070983   2.592447381   1.235938956   .42969878     .160820039    .084326619    .123998504
cooling                 .        July            .        week      .157377495    .145602131    .13776364     .126134777    3.335998532   7.315774837   17.6095383    38.89398054   51.16058783   69.52149834   84.82112921   103.8056322   95.39294596   68.73558683   57.54314691   37.15162175   13.15874682   7.789302413   5.789091669   2.203482409   .697985147    .489323943    .289468788    .21440459
cooling                 .        August          .        week      .264514648    .195866788    .185910458    .13092377     3.871001311   10.24810587   19.5853387    38.59779687   49.79689156   66.96673028   89.53717615   109.7460853   106.692623    83.72854258   72.50283326   53.30004084   12.30618366   6.703886792   4.50544887    2.863765078   1.232259134   .619071359    .35945871     .341202221
cooling                 .        September       .        week      .24797961     .232215997    .157896153    .147001835    3.971359326   7.919556162   17.70655245   37.2276483    47.44369145   68.64347328   91.28226624   106.3596729   133.4916998   142.3016753   129.6795244   79.02376915   9.918051528   2.931192477   1.505765041   .749832372    .411522983    .329856101    .323257691    .173860748
cooling                 .        October         .        week      .092866093    .079494517    .059388901    .077878064    2.907564983   3.750513813   6.591702389   17.61415946   28.76655689   38.85091958   50.76982385   62.74416674   80.51976682   90.55491711   79.10327354   47.49885615   9.028963764   .996857463    .262281977    .241341728    .17807258     .167502495    .097822097    .080742693
cooling                 .        November        .        week      .322073795    .589737807    .706635821    .765307359    .88390546     2.47384792    2.051423595   3.778680626   9.382754232   13.750985     20.31973784   26.0146233    31.61746353   38.84660414   38.69509483   24.51292375   9.648520504   2.166861865   .200626563    .182588434    .173520005    .162876198    .150033209    .141324089
cooling                 .        December        .        week      .667684982    .755100292    .869807579    .869505099    .870138154    1.687319244   1.265614564   2.278090053   3.490444851   6.554123911   8.737570779   11.52019078   14.040293     15.90296998   14.47678996   7.409269856   3.680566587   1.3103033     .015603222    .069975715    .06286679     .121327043    .294909528    .381438685
cooling                 .        January         .        peak      .751635235    .832450501    .832006216    .832143082    .831708026    1.742102981   1.265732521   2.289613327   3.698045357   5.617824297   7.731442813   10.4956415    13.38824581   14.44206212   13.90932644   8.003079938   4.045717572   1.392880791   .103776631    .207420968    .231744539    .28209903     .364173482    .502453576
cooling                 .        February        .        peak      .770471377    .896122802    .990700457    1.084926131   1.083933892   2.406432577   1.879357275   3.148838601   6.861433031   10.1184242    13.57659564   17.37171388   21.18739579   24.23152124   24.58910096   15.06968755   8.635333858   1.886875764   .04118279     .0626423      .1535357      .244214542    .269526541    .357328514
cooling                 .        March           .        peak      .432652353    .550700527    .672196086    .731343721    .821358395    2.69795297    2.083914181   4.020602316   10.31251737   14.95986965   23.61644283   30.92793805   36.96620675   46.03803445   45.63256913   30.38883905   13.65450883   2.630271982   .053476872    .034955421    .026895146    .050927237    .046250628    .221206934
cooling                 .        April           .        peak      .212932069    .353562713    .496968529    .583130405    2.500500944   2.625776787   4.076611544   10.89663115   19.0286215    29.1203402    39.28286376   47.89450782   55.82034571   58.98744672   48.35558921   30.43959226   6.866111233   1.292960645   .069040088    .03891426     .031632882    .052734074    .080330723    .16010574
cooling                 .        May             .        peak      .142206243    .139756       .246095261    .272531082    3.352689309   3.486222586   7.137661183   23.86672225   35.52986235   49.24254736   63.4767759    76.33279197   87.27647573   77.95479103   65.23769759   47.21804484   5.992552143   1.589260675   .253759816    .090073416    .068212374    .060174797    .052054568    .040504005
cooling                 .        June            .        peak      .118803831    .105410646    .097813112    .151623439    3.822413481   5.592116165   17.67767754   42.67250701   55.94620922   75.29277713   91.03514598   108.4150495   110.1847875   83.93182459   72.28399323   58.73341151   9.956073257   5.979070983   2.592447381   1.235938956   .42969878     .160820039    .084326619    .123998504
cooling                 .        July            .        peak      .157377495    .145602131    .13776364     .126134777    3.335998532   7.315774837   17.6095383    38.89398054   51.16058783   69.52149834   84.82112921   103.8056322   95.39294596   68.73558683   57.54314691   37.15162175   13.15874682   7.789302413   5.789091669   2.203482409   .697985147    .489323943    .289468788    .21440459
cooling                 .        August          .        peak      .264514648    .195866788    .185910458    .13092377     3.871001311   10.24810587   19.5853387    38.59779687   49.79689156   66.96673028   89.53717615   109.7460853   106.692623    83.72854258   72.50283326   53.30004084   12.30618366   6.703886792   4.50544887    2.863765078   1.232259134   .619071359    .35945871     .341202221
cooling                 .        September       .        peak      .24797961     .232215997    .157896153    .147001835    3.971359326   7.919556162   17.70655245   37.2276483    47.44369145   68.64347328   91.28226624   106.3596729   133.4916998   142.3016753   129.6795244   79.02376915   9.918051528   2.931192477   1.505765041   .749832372    .411522983    .329856101    .323257691    .173860748
cooling                 .        October         .        peak      .092866093    .079494517    .059388901    .077878064    2.907564983   3.750513813   6.591702389   17.61415946   28.76655689   38.85091958   50.76982385   62.74416674   80.51976682   90.55491711   79.10327354   47.49885615   9.028963764   .996857463    .262281977    .241341728    .17807258     .167502495    .097822097    .080742693
cooling                 .        November        .        peak      .322073795    .589737807    .706635821    .765307359    .88390546     2.47384792    2.051423595   3.778680626   9.382754232   13.750985     20.31973784   26.0146233    31.61746353   38.84660414   38.69509483   24.51292375   9.648520504   2.166861865   .200626563    .182588434    .173520005    .162876198    .150033209    .141324089
cooling                 .        December        .        peak      .667684982    .755100292    .869807579    .869505099    .870138154    1.687319244   1.265614564   2.278090053   3.490444851   6.554123911   8.737570779   11.52019078   14.040293     15.90296998   14.47678996   7.409269856   3.680566587   1.3103033     .015603222    .069975715    .06286679     .121327043    .294909528    .381438685
cooling                 .        January         .        weekend   .800403378    .878840579    .956552479    .955320783    .955280162    .955251624    .955222084    .956379788    .876911055    .80185636     .719676994    .566841567    .333494404    .184826465    .186613318    .197523648    .352515181    .574328918    .646366789    .724131275    .882097535    .961426903    .961846608    .957721564
cooling                 .        February        .        weekend   .958141387    1.115494308   1.116638027   1.116573967   1.275089951   1.275036159   1.275003628   1.273845719   .876126764    .800953424    .563079655    .328411847    .099433064    .041631914    .207094759    .209908151    .206046338    .346319011    .414899445    .803695139    .881158627    .879745931    1.039178331   1.196989895
cooling                 .        March           .        weekend   .577934109    .708724843    .769299561    .766845792    .766270924    .892737115    .894211034    .831604148    .64949798     .747360425    .457713067    .385280889    .355181591    1.013943317   1.2783463     1.100296714   .741954524    .473514131    .506798303    .60790869     .72639688     .720414163    .717550763    .775315618
cooling                 .        April           .        weekend   .496757707    .654157354    .806725062    .726222274    .801374738    .801358175    .80076354     .50881643     .297690854    .232808964    .121553507    .164378818    .769138237    .944318368    1.163771744   1.051381397   .894173957    .532468932    .080147684    .049945576    .114001231    .270448706    .431990964    .575949042
cooling                 .        May             .        weekend   .028037893    .025663779    .019555512    .172088513    .410149102    .487745655    .104761587    .448303719    .519268816    .820561507    .805230758    1.011345319   1.241376122   1.37636283    1.435982984   2.018327552   1.585763695   1.032926104   .13957667     .252628732    .227614754    .216804492    .209146125    .199640135
cooling                 .        June            .        weekend   .115777284    .165275242    .159746895    .151534546    .273895114    .269218834    .670412046    .732082828    .966778509    1.081804317   1.205705723   2.438567058   2.98855359    4.754141053   5.135517681   5.783661293   6.026968333   4.675793811   3.464938506   1.665620354   .372009939    .094066372    .079426261    .067767895
cooling                 .        July            .        weekend   .113624817    .108259023    .10756167     .099618313    .093333375    .09043136     .892856293    1.092566248   1.36228718    1.50121742    1.630649269   2.255770313   3.655606286   6.369571604   8.945126348   10.79786802   12.94523498   7.401444603   4.163049001   .70490812     .153374378    .139600421    .136219305    .125674754
cooling                 .        August          .        weekend   .542796268    .494706282    .349514308    .217417349    .205877924    .19095348     .914074939    1.361705465   1.532257721   1.687974404   2.432176475   4.677355511   7.269809444   9.237343703   10.08543029   13.28783098   12.76613161   10.7055289    7.825412929   5.980961007   3.067347672   1.203824583   .582674566    .441936684
cooling                 .        September       .        weekend   .197435749    .202144264    .176994828    .163347912    .151912468    .142880548    .277460253    .600077086    1.441282141   1.738216871   2.030502751   3.087651383   4.695543439   5.963169743   8.412204067   8.573917467   8.524682482   4.951852053   3.23900946    1.281467614   .648863025    .426714524    .390832301    .378970239
cooling                 .        October         .        weekend   .111914987    .094294295    .074844562    .051322659    .048174711    .11838217     .130991429    .346349258    .674727564    1.492411946   1.482024576   1.696859324   2.618102047   3.340737093   3.549879192   3.011557374   1.857156157   .986627756    .505700049    .447239642    .42166559     .227227761    .21100062     .176158776
cooling                 .        November        .        weekend   .646688142    .645464981    .784827908    .924942046    .997329895    1.136248967   1.278193216   1.067967211   .581880183    .388859801    .205396915    .089399601    .113284009    .133633898    .142458615    .149567103    .271709406    .299368778    .412767142    .614289691    .884028285    .875431474    .866836954    .996831358
cooling                 .        December        .        weekend   .712128433    .714866598    .855641845    .852811784    .853249786    .852469396    .853182765    .853488892    .785044931    .518588591    .24876488     .13755426     .068500619    .082874658    .092148453    .089883544    .288761679    .413507016    .606100138    .739221274    .801658608    .794652647    .792266225    .852692338
refrigeration           .        January         .        week      15.73284847   15.73376003   15.73450897   15.73629876   15.75366075   15.90014032   16.30508933   17.01731259   17.97054071   18.80399891   19.04080141   19.05149381   18.95654796   18.59442303   18.19449221   17.6061555    16.7898111    16.24441155   15.94257904   15.7990074    15.76591293   15.74996752   15.74976431   15.73200329
refrigeration           .        February        .        week      15.74380488   15.74432925   15.74472418   15.74593416   15.7639755    15.9204816    16.36406716   17.14657311   18.20525487   19.15087965   19.41934483   19.43274193   19.32749846   18.91906811   18.48481828   17.8139954    16.90092943   16.30577568   15.97320838   15.81543881   15.77842244   15.76314348   15.76191437   15.74328273
refrigeration           .        March           .        week      15.75063604   15.75038492   15.75013491   15.75031744   15.76748108   15.9281887    16.39045862   17.20590785   18.31724095   19.30554013   19.58588876   19.59976348   19.49133443   19.06743517   18.61615817   17.91708979   16.96434251   16.3432069    15.99674148   15.82884537   15.78863057   15.77356219   15.77011066   15.75086172
refrigeration           .        April           .        week      15.75708841   15.75687646   15.75703119   15.77090777   15.90048159   16.26478743   16.96248983   17.92932297   18.81387469   19.21707747   19.28609518   19.21863841   18.9198656    18.49055235   17.9564586    17.1342228    16.46629517   16.08031576   15.87826239   15.80496049   15.7842985    15.77907655   15.76285479   15.75856768
refrigeration           .        May             .        week      15.77144038   15.77046687   15.77041435   15.78934368   15.95251427   16.3516253    17.06850376   17.97390504   18.62564474   18.80784682   18.81090924   18.74190222   18.4550811    18.04844523   17.62830832   16.84756764   16.29859654   16.00850161   15.85914701   15.82154958   15.79769729   15.79345498   15.77339293   15.77262336
refrigeration           .        June            .        week      15.78135691   15.77993868   15.78071334   15.80805253   15.98983177   16.39523838   17.08304497   17.88112707   18.36064006   18.49407133   18.49486501   18.43856192   18.22510125   17.81445887   17.50696071   16.78444956   16.27281624   16.01133073   15.87558915   15.83756254   15.81102904   15.80427863   15.78403959   15.78270765
refrigeration           .        July            .        week      15.78489362   15.78332163   15.78491094   15.81834796   15.99947909   16.37974121   17.00824169   17.68142587   18.047992     18.1503448    18.15582272   18.10841102   17.94117896   17.5572666    17.29795448   16.65431781   16.21237366   15.98789803   15.87289134   15.84075249   15.81437293   15.8077357    15.78725217   15.78592726
refrigeration           .        August          .        week      15.79039838   15.78857747   15.78978405   15.82218849   16.00359964   16.38830081   17.03720141   17.75278164   18.17614788   18.29611674   18.30549361   18.25474927   18.06871622   17.68181415   17.37955466   16.7095735    16.24145669   15.9987874    15.87541181   15.84407712   15.8187087    15.81208883   15.7923288    15.79136304
refrigeration           .        September       .        week      15.7843947    15.78301962   15.78268189   15.80032059   15.95669841   16.38321998   17.17125444   18.22474458   19.15689043   19.42356878   19.43812191   19.34223285   18.94827465   18.51959961   17.86592991   16.9584138    16.36392685   16.02956081   15.86996024   15.83340769   15.81114851   15.80609179   15.78622224   15.78439617
refrigeration           .        October         .        week      15.76983645   15.76909391   15.76834353   15.78231796   15.91567747   16.3037028    17.04274072   18.0826829    19.08168246   19.48484351   19.54706516   19.46384452   19.10254279   18.66853856   18.01967706   17.12863096   16.46156796   16.06840457   15.87536508   15.82079386   15.79707711   15.79035514   15.77349014   15.77035923
refrigeration           .        November        .        week      15.7492145    15.74949217   15.74934835   15.74742467   15.76373802   15.91035472   16.32324937   17.06154508   18.06736574   18.98751462   19.24972084   19.26370397   19.16191301   18.76623289   18.36060084   17.69937101   16.83719616   16.27835841   15.96310066   15.81786183   15.78386817   15.76810896   15.7673793    15.74822882
refrigeration           .        December        .        week      15.73078972   15.73170902   15.73224888   15.73317899   15.75028234   15.89528071   16.28201448   16.95707478   17.85864723   18.6246183    18.84332557   18.85288794   18.76384485   18.42941374   18.04261862   17.50438941   16.73608896   16.21576826   15.93222836   15.79612489   15.76456884   15.74779029   15.74771219   15.72974652
refrigeration           .        January         .        peak      15.73284847   15.73376003   15.73450897   15.73629876   15.75366075   15.90014032   16.30508933   17.01731259   17.97054071   18.80399891   19.04080141   19.05149381   18.95654796   18.59442303   18.19449221   17.6061555    16.7898111    16.24441155   15.94257904   15.7990074    15.76591293   15.74996752   15.74976431   15.73200329
refrigeration           .        February        .        peak      15.74380488   15.74432925   15.74472418   15.74593416   15.7639755    15.9204816    16.36406716   17.14657311   18.20525487   19.15087965   19.41934483   19.43274193   19.32749846   18.91906811   18.48481828   17.8139954    16.90092943   16.30577568   15.97320838   15.81543881   15.77842244   15.76314348   15.76191437   15.74328273
refrigeration           .        March           .        peak      15.75063604   15.75038492   15.75013491   15.75031744   15.76748108   15.9281887    16.39045862   17.20590785   18.31724095   19.30554013   19.58588876   19.59976348   19.49133443   19.06743517   18.61615817   17.91708979   16.96434251   16.3432069    15.99674148   15.82884537   15.78863057   15.77356219   15.77011066   15.75086172
refrigeration           .        April           .        peak      15.75708841   15.75687646   15.75703119   15.77090777   15.90048159   16.26478743   16.96248983   17.92932297   18.81387469   19.21707747   19.28609518   19.21863841   18.9198656    18.49055235   17.9564586    17.1342228    16.46629517   16.08031576   15.87826239   15.80496049   15.7842985    15.77907655   15.76285479   15.75856768
refrigeration           .        May             .        peak      15.77144038   15.77046687   15.77041435   15.78934368   15.95251427   16.3516253    17.06850376   17.97390504   18.62564474   18.80784682   18.81090924   18.74190222   18.4550811    18.04844523   17.62830832   16.84756764   16.29859654   16.00850161   15.85914701   15.82154958   15.79769729   15.79345498   15.77339293   15.77262336
refrigeration           .        June            .        peak      15.78135691   15.77993868   15.78071334   15.80805253   15.98983177   16.39523838   17.08304497   17.88112707   18.36064006   18.49407133   18.49486501   18.43856192   18.22510125   17.81445887   17.50696071   16.78444956   16.27281624   16.01133073   15.87558915   15.83756254   15.81102904   15.80427863   15.78403959   15.78270765
refrigeration           .        July            .        peak      15.78489362   15.78332163   15.78491094   15.81834796   15.99947909   16.37974121   17.00824169   17.68142587   18.047992     18.1503448    18.15582272   18.10841102   17.94117896   17.5572666    17.29795448   16.65431781   16.21237366   15.98789803   15.87289134   15.84075249   15.81437293   15.8077357    15.78725217   15.78592726
refrigeration           .        August          .        peak      15.79039838   15.78857747   15.78978405   15.82218849   16.00359964   16.38830081   17.03720141   17.75278164   18.17614788   18.29611674   18.30549361   18.25474927   18.06871622   17.68181415   17.37955466   16.7095735    16.24145669   15.9987874    15.87541181   15.84407712   15.8187087    15.81208883   15.7923288    15.79136304
refrigeration           .        September       .        peak      15.7843947    15.78301962   15.78268189   15.80032059   15.95669841   16.38321998   17.17125444   18.22474458   19.15689043   19.42356878   19.43812191   19.34223285   18.94827465   18.51959961   17.86592991   16.9584138    16.36392685   16.02956081   15.86996024   15.83340769   15.81114851   15.80609179   15.78622224   15.78439617
refrigeration           .        October         .        peak      15.76983645   15.76909391   15.76834353   15.78231796   15.91567747   16.3037028    17.04274072   18.0826829    19.08168246   19.48484351   19.54706516   19.46384452   19.10254279   18.66853856   18.01967706   17.12863096   16.46156796   16.06840457   15.87536508   15.82079386   15.79707711   15.79035514   15.77349014   15.77035923
refrigeration           .        November        .        peak      15.7492145    15.74949217   15.74934835   15.74742467   15.76373802   15.91035472   16.32324937   17.06154508   18.06736574   18.98751462   19.24972084   19.26370397   19.16191301   18.76623289   18.36060084   17.69937101   16.83719616   16.27835841   15.96310066   15.81786183   15.78386817   15.76810896   15.7673793    15.74822882
refrigeration           .        December        .        peak      15.73078972   15.73170902   15.73224888   15.73317899   15.75028234   15.89528071   16.28201448   16.95707478   17.85864723   18.6246183    18.84332557   18.85288794   18.76384485   18.42941374   18.04261862   17.50438941   16.73608896   16.21576826   15.93222836   15.79612489   15.76456884   15.74779029   15.74771219   15.72974652
refrigeration           .        January         .        weekend   15.73284847   15.73376003   15.73450897   15.73586857   15.73673256   15.75266382   15.74944239   15.73886709   15.72849257   15.74481103   15.7598877    15.78253397   15.80630696   15.81176249   15.82937914   15.82652111   15.80280731   15.79246266   15.76998067   15.76348416   15.76287239   15.74988932   15.74976431   15.73200329

refrigeration           .        February        .        weekend   15.74380488   15.74432925   15.74472418   15.7454875    15.74608267   15.76193539   15.75773934   15.74414561   15.73785762   15.75907626   15.77618182   15.79918928   15.82369185   15.82909815   15.84676513   15.84277209   15.8181257    15.8094504    15.785288     15.7775923    15.77527358   15.76306488   15.76191437   15.74328273
refrigeration           .        March           .        weekend   15.75063604   15.75038492   15.75013491   15.74984838   15.74892355   15.76375961   15.76044968   15.74785391   15.75151873   15.77565601   15.7926796    15.81438632   15.83962134   15.8449689    15.86321003   15.85910492   15.83348602   15.82506627   15.80062388   15.78940606   15.78536931   15.77348144   15.77011066   15.75086172
refrigeration           .        April           .        weekend   15.75699303   15.75687646   15.75664027   15.75567534   15.77033882   15.76126666   15.76349632   15.76865454   15.79275015   15.81125222   15.83185578   15.85648806   15.863244     15.87899107   15.87603694   15.85085761   15.83878319   15.81607635   15.80259352   15.79247275   15.78247022   15.7787724    15.76079428   15.75786739
refrigeration           .        May             .        weekend   15.77144038   15.77046687   15.76996463   15.76913383   15.78606405   15.7751884    15.78367452   15.78959247   15.81914401   15.83697307   15.85804734   15.88406991   15.8887245    15.90551035   15.8986283    15.86879521   15.85780949   15.8313505    15.82174317   15.81842107   15.79762005   15.79345498   15.77339293   15.77216498
refrigeration           .        June            .        weekend   15.78135691   15.77993868   15.77917094   15.77764098   15.79431897   15.78701432   15.79520066   15.80601491   15.84461788   15.86379989   15.87661427   15.901764     15.90735449   15.92855432   15.92598945   15.8951032    15.87832842   15.84716394   15.84106734   15.83470634   15.81094939   15.80427863   15.78403959   15.7830049
refrigeration           .        July            .        weekend   15.78489362   15.78332163   15.78260366   15.78273973   15.79877941   15.78974015   15.79573055   15.80558236   15.84426111   15.8656916    15.88121631   15.90872017   15.9162527    15.93818653   15.93514376   15.90248307   15.88472592   15.85191201   15.84509966   15.83859595   15.81431684   15.8077357    15.78725217   15.78568017
refrigeration           .        August          .        weekend   15.79039838   15.78857747   15.78761281   15.78768029   15.80386821   15.78853986   15.79476122   15.80521441   15.84420875   15.86657735   15.88249509   15.91111172   15.91932841   15.9419791    15.93918014   15.9062792    15.88819282   15.85393008   15.84511429   15.84162268   15.81865117   15.81208883   15.7923288    15.79066658
refrigeration           .        September       .        weekend   15.7843947    15.78301962   15.78223417   15.78238794   15.79884025   15.78346101   15.78733871   15.7944972    15.82732192   15.84929767   15.87315616   15.90400436   15.91206298   15.93098447   15.92346693   15.89079549   15.87732295   15.84478573   15.83297086   15.83047157   15.81108988   15.80609179   15.78622224   15.78509496
refrigeration           .        October         .        weekend   15.76980187   15.76905722   15.76791611   15.76748384   15.78216738   15.77073459   15.76644327   15.77543385   15.80754431   15.83172012   15.85198088   15.87785369   15.88794473   15.90807107   15.90794012   15.87969977   15.8586573    15.8233597    15.81049416   15.81179858   15.79557485   15.79017547   15.77252784   15.77037644
refrigeration           .        November        .        weekend   15.7492145    15.74949217   15.74934835   15.74701968   15.7475197    15.76477848   15.75901044   15.75023459   15.7499756    15.77744357   15.79690946   15.81712257   15.8423361    15.84894699   15.86944662   15.86656862   15.83813403   15.81882105   15.7901593    15.78333355   15.78097746   15.7680331    15.7673793    15.74822882
refrigeration           .        December        .        weekend   15.73078972   15.73170902   15.73224888   15.73277103   15.73346577   15.75053205   15.74701414   15.73439257   15.72587657   15.74751626   15.76519935   15.78700351   15.81076587   15.81698773   15.83570259   15.83308972   15.80731901   15.79139672   15.76851887   15.76216795   15.76163006   15.74771219   15.74771219   15.72974652
space-heating           .        January         .        week      205.6235913   220.4754621   230.5281672   234.8370801   241.0246499   269.3969787   489.4807934   832.8234998   646.5632177   418.5112169   353.1258064   286.3567653   240.3501103   196.9170973   186.1962179   141.2266945   191.8384995   148.8424255   72.25906164   86.57087447   121.1159987   143.9395976   173.8257631   179.5833943
space-heating           .        February        .        week      156.9097078   176.5912465   186.2964872   201.4782877   213.7173361   250.5820406   471.0542499   731.0908551   512.1708248   314.5892985   262.6110391   205.4955705   184.2655092   140.2978484   131.5822629   89.27670848   120.7937321   101.0085782   47.1076041    62.87856      83.3074973    101.1033244   122.722353    130.3921598
space-heating           .        March           .        week      111.0625023   124.3138037   136.7594737   148.8159646   163.1536554   209.9267018   413.8313989   532.4280801   330.7286062   187.5882522   165.7135912   130.831317    110.5945043   86.30326098   81.16690833   43.36726112   65.74770645   54.62903466   20.75663885   33.15764856   55.7196959    69.49271603   84.77823055   85.99452081
space-heating           .        April           .        week      79.80478347   100.925419    112.2824655   120.3007503   146.748357    294.0568089   386.7317555   309.070426    187.6248724   147.1726607   119.4751051   102.5639603   83.31391466   77.29562076   47.7316144    46.82698213   35.40973342   14.40543949   12.84467318   27.68390812   42.06963436   61.30490484   63.50198863   73.64295578
space-heating           .        May             .        week      41.92044689   49.25838331   60.17800163   72.41933318   96.71185864   216.7334537   193.1992847   167.5610694   97.96748123   80.21787597   67.06168272   58.84101956   51.96761251   50.26237018   13.2836738    17.46007216   8.077157103   1.100312374   1.232202078   4.430142586   11.27690398   24.35902668   19.28880832   29.72849986
space-heating           .        June            .        week      10.96032754   13.58779225   17.79445685   21.80813459   37.69018479   82.46119503   108.2668752   116.6567623   63.66557868   60.41433759   52.33670026   47.20550244   44.33860158   42.42757891   3.953027912   5.201927451   2.680290162   0             0             .11226425     .839623835    3.783010787   4.349584121   8.455849881
space-heating           .        July            .        week      1.607449793   2.810753965   4.168812621   6.549599789   16.56856449   30.68902568   63.98048971   90.73025771   51.5867693    48.32925837   43.5143301    39.90840139   37.65486618   36.76410879   .532832499    .748039489    .939574084    0             0             0             0             0             .361734339    1.23277973
space-heating           .        August          .        week      3.187664321   4.57082698    5.591857679   8.132060497   19.28575137   40.50254349   74.9582488    94.43745335   55.67446221   45.19157742   40.92630584   38.57721493   37.5255343    36.91458784   4.237275289   .792179014    .945171661    0             0             0             0             0             .645283374    1.55702995
space-heating           .        September       .        week      4.46012289    6.310759788   8.535870861   10.98225172   25.91566848   102.7828807   115.5105601   113.2237516   56.10002884   43.07375947   37.69983751   35.94175418   35.06337136   37.04483995   9.553218066   2.216242824   1.267015216   0             0             0             0             .303837099    1.4841825     3.168635814
space-heating           .        October         .        week      30.64212273   42.85783678   51.23061382   56.25289973   82.99858045   158.7012386   252.4342823   240.5778305   145.4880844   99.66707036   71.2363207    51.75325216   45.53872221   43.20186058   14.58601435   9.799330264   8.343344293   2.792961427   1.823429008   7.037110806   17.9057946    26.24577421   20.67782216   24.44680575
space-heating           .        November        .        week      111.2254569   120.6157023   142.0848025   159.5436501   163.7860944   209.7433082   366.9513658   522.5791745   326.7719662   189.0684993   165.7701336   124.3635851   98.44687468   68.91488163   63.00801972   35.03985034   65.66517883   60.62150997   27.22038371   44.32743499   60.25630243   66.38227294   79.89778979   93.28564479
space-heating           .        December        .        week      196.8945912   204.8743839   214.5955178   227.6230966   236.5940368   263.1726745   467.0915451   805.9972099   610.4022726   377.5887464   311.1735582   254.952278    227.6408916   185.9975863   178.4896352   141.3550955   207.6152094   141.3486301   69.60670079   87.0864548    113.641811    149.9186417   168.5559501   171.9959547
space-heating           .        January         .        peak      205.6235913   220.4754621   230.5281672   234.8370801   241.0246499   269.3969787   489.4807934   832.8234998   646.5632177   418.5112169   353.1258064   286.3567653   240.3501103   196.9170973   186.1962179   141.2266945   191.8384995   148.8424255   72.25906164   86.57087447   121.1159987   143.9395976   173.8257631   179.5833943
space-heating           .        February        .        peak      156.9097078   176.5912465   186.2964872   201.4782877   213.7173361   250.5820406   471.0542499   731.0908551   512.1708248   314.5892985   262.6110391   205.4955705   184.2655092   140.2978484   131.5822629   89.27670848   120.7937321   101.0085782   47.1076041    62.87856      83.3074973    101.1033244   122.722353    130.3921598
space-heating           .        March           .        peak      111.0625023   124.3138037   136.7594737   148.8159646   163.1536554   209.9267018   413.8313989   532.4280801   330.7286062   187.5882522   165.7135912   130.831317    110.5945043   86.30326098   81.16690833   43.36726112   65.74770645   54.62903466   20.75663885   33.15764856   55.7196959    69.49271603   84.77823055   85.99452081
space-heating           .        April           .        peak      79.80478347   100.925419    112.2824655   120.3007503   146.748357    294.0568089   386.7317555   309.070426    187.6248724   147.1726607   119.4751051   102.5639603   83.31391466   77.29562076   47.7316144    46.82698213   35.40973342   14.40543949   12.84467318   27.68390812   42.06963436   61.30490484   63.50198863   73.64295578
space-heating           .        May             .        peak      41.92044689   49.25838331   60.17800163   72.41933318   96.71185864   216.7334537   193.1992847   167.5610694   97.96748123   80.21787597   67.06168272   58.84101956   51.96761251   50.26237018   13.2836738    17.46007216   8.077157103   1.100312374   1.232202078   4.430142586   11.27690398   24.35902668   19.28880832   29.72849986
space-heating           .        June            .        peak      10.96032754   13.58779225   17.79445685   21.80813459   37.69018479   82.46119503   108.2668752   116.6567623   63.66557868   60.41433759   52.33670026   47.20550244   44.33860158   42.42757891   3.953027912   5.201927451   2.680290162   0             0             .11226425     .839623835    3.783010787   4.349584121   8.455849881
space-heating           .        July            .        peak      1.607449793   2.810753965   4.168812621   6.549599789   16.56856449   30.68902568   63.98048971   90.73025771   51.5867693    48.32925837   43.5143301    39.90840139   37.65486618   36.76410879   .532832499    .748039489    .939574084    0             0             0             0             0             .361734339    1.23277973
space-heating           .        August          .        peak      3.187664321   4.57082698    5.591857679   8.132060497   19.28575137   40.50254349   74.9582488    94.43745335   55.67446221   45.19157742   40.92630584   38.57721493   37.5255343    36.91458784   4.237275289   .792179014    .945171661    0             0             0             0             0             .645283374    1.55702995
space-heating           .        September       .        peak      4.46012289    6.310759788   8.535870861   10.98225172   25.91566848   102.7828807   115.5105601   113.2237516   56.10002884   43.07375947   37.69983751   35.94175418   35.06337136   37.04483995   9.553218066   2.216242824   1.267015216   0             0             0             0             .303837099    1.4841825     3.168635814
space-heating           .        October         .        peak      30.64212273   42.85783678   51.23061382   56.25289973   82.99858045   158.7012386   252.4342823   240.5778305   145.4880844   99.66707036   71.2363207    51.75325216   45.53872221   43.20186058   14.58601435   9.799330264   8.343344293   2.792961427   1.823429008   7.037110806   17.9057946    26.24577421   20.67782216   24.44680575
space-heating           .        November        .        peak      111.2254569   120.6157023   142.0848025   159.5436501   163.7860944   209.7433082   366.9513658   522.5791745   326.7719662   189.0684993   165.7701336   124.3635851   98.44687468   68.91488163   63.00801972   35.03985034   65.66517883   60.62150997   27.22038371   44.32743499   60.25630243   66.38227294   79.89778979   93.28564479
space-heating           .        December        .        peak      196.8945912   204.8743839   214.5955178   227.6230966   236.5940368   263.1726745   467.0915451   805.9972099   610.4022726   377.5887464   311.1735582   254.952278    227.6408916   185.9975863   178.4896352   141.3550955   207.6152094   141.3486301   69.60670079   87.0864548    113.641811    149.9186417   168.5559501   171.9959547
space-heating           .        January         .        weekend   223.9650024   230.897288    237.6035581   244.8512922   252.3507857   256.9323843   265.0929779   273.4351328   236.0164205   235.5616154   194.8538719   158.9157997   120.5967254   103.4396838   97.87321915   102.6641967   92.95083053   114.381831    151.1526717   176.3972432   198.2916863   202.9254869   214.2543383   210.6516162
space-heating           .        February        .        weekend   174.2022315   195.8272301   216.4793219   217.5959491   232.1189913   245.2793572   249.4633617   255.3714244   169.5807147   163.0021959   123.8788137   93.075374     63.18391456   52.19573351   48.99975915   48.16106713   36.97698327   61.5390618    94.25269231   109.0568221   131.0596001   150.9405409   161.0804444   170.236675
space-heating           .        March           .        weekend   128.4023769   144.5809459   150.0260353   161.4133978   181.7794701   193.9334106   197.8876232   158.9936598   115.8239147   123.830438    79.59767875   55.93347795   38.8516307    31.7690225    29.15822322   30.73579085   22.011209     31.6471482    52.43851209   70.34496249   90.12390364   108.4191484   114.9875576   117.6989452
space-heating           .        April           .        weekend   77.30617147   89.28131665   101.4193085   110.5879119   122.3668426   144.2840185   116.8031154   80.39547791   91.12383123   61.60569122   32.39357567   19.46098599   10.98304866   4.22444172    2.755698284   .988134245    .732479882    1.252806951   6.922070159   22.68182875   43.11060896   52.66856871   52.83405633   58.96157433
space-heating           .        May             .        weekend   39.56572771   46.12260361   47.42303977   68.67687955   70.78483507   84.62691192   57.94713522   47.34526572   55.3454267    20.38454179   13.66746287   6.759032417   5.267295181   3.393557617   2.752010684   6.119896851   4.315781549   5.396407851   5.960325919   7.912480964   11.97193748   22.43575077   27.71998988   30.55414857
space-heating           .        June            .        weekend   16.32719061   20.09898497   29.25189048   30.33867574   32.98919295   51.26185642   55.7535442    33.27932068   30.76994185   13.39436595   6.020639731   3.643677167   2.355950636   1.562623202   1.041350767   0             0             0             0             1.088993438   3.937788371   10.86405901   9.783637506   13.08889496
space-heating           .        July            .        weekend   3.919221752   5.523054524   7.250015754   9.214575759   10.38308141   11.62936062   34.85897946   8.2791275     9.983458739   6.488589172   4.063783953   1.969494341   .269842113    0             0             0             0             0             0             0             0             0             .943839379    2.317611817
space-heating           .        August          .        weekend   5.107617028   6.439391171   7.980758879   9.876802076   11.56876683   12.96660555   36.9532577    24.4508797    19.76404736   6.049364311   3.668294059   1.865536      .69837382     .266875042    0             0             0             0             0             0             .224494773    2.763058155   4.791580491   5.615827609
space-heating           .        September       .        weekend   9.853151366   11.24593056   14.77400444   16.62842795   18.52834867   34.96305069   49.60602525   29.31280881   24.75522074   7.795788792   3.315871723   1.378557513   .413506551    0             0             0             0             0             0             0             .212157745    2.383726234   4.495517266   7.835248233
space-heating           .        October         .        weekend   34.78777809   36.40476331   42.29527688   57.66328071   57.29747453   79.0099484    87.68627365   59.6088385    68.53662394   41.7019914    19.11095557   10.42856255   1.879638858   .892209128    .418134102    0             0             0             0             2.344116301   10.95464121   21.80099278   14.95292317   14.45562667
space-heating           .        November        .        weekend   120.2655522   147.7108566   177.2553312   184.3506594   195.0466508   204.6828965   218.3982755   202.3120448   114.3082074   129.7632092   90.05322375   60.99013264   45.66698342   39.5853558    35.66609157   40.53054869   30.32311788   45.40249892   61.53349842   81.50667013   95.13629779   114.5162078   126.5299699   128.6044204
space-heating           .        December        .        weekend   174.8625052   185.8722487   199.5657576   204.1797206   213.0601907   219.9240765   227.1318696   236.7997303   169.1377302   156.2550941   126.1339465   89.02198432   68.48054565   59.23324682   60.64032719   67.74313168   48.15627683   63.12784115   86.63479347   105.4430371   131.9084035   147.6293575   160.9323131   165.3225286
water-heating           .        January         .        week      18.97407174   18.97407174   18.97407174   18.9788308    19.86275541   27.09431852   47.79288707   84.54479621   132.85486     160.4279865   159.3829687   161.3968094   160.9783781   139.9385112   109.8376829   76.08809912   44.47399799   29.94536815   22.94612068   19.62190481   19.00449052   18.97421076   18.97407174   18.97407174
water-heating           .        February        .        week      19.06245274   19.06245274   19.06245274   19.06766712   20.03622604   27.95588756   50.65446018   90.94819718   143.7817732   173.7816027   172.4036442   174.7785676   174.5118588   151.6914414   118.8651788   81.7712416    47.01866234   31.08548526   23.39689221   19.75941426   19.09420072   19.06262818   19.06245274   19.06245274
water-heating           .        March           .        week      18.9818238    18.9818238    18.9818238    18.98703611   19.97601568   28.07282069   51.3563264    92.71323681   147.012173    177.9799934   176.5564687   178.9978211   178.7905572   155.3905111   121.6786177   83.53035223   47.76687992   31.36680686   23.45101961   19.69664049   19.01516847   18.98200847   18.9818238    18.9818238
water-heating           .        April           .        week      16.19256217   16.19256217   16.19658986   16.81944883   22.12534945   38.40801654   69.11767505   111.9847687   143.2397732   149.3610983   150.3380689   150.0638371   134.25522     107.5405157   76.69541639   46.76467794   29.57262028   21.42845102   17.52289778   16.35682903   16.19958526   16.19260414   16.19256217   16.2103522
water-heating           .        May             .        week      16.58394286   16.58394286   16.58830633   17.40410604   23.98993612   42.67231749   75.84040177   119.6565207   144.6377972   144.3788287   145.5868417   144.8280778   125.3927634   98.11988502   68.2150249    39.7249964    26.54795067   20.23888376   17.18924513   16.61395522   16.5841195    16.58394286   16.58394286   16.61428144
water-heating           .        June            .        week      17.28173032   17.28173032   17.30784114   18.229512     24.55053757   41.16626814   69.57572264   105.1661646   122.7413813   122.6898707   124.2081084   123.3054452   107.0840124   84.02242697   60.0483916    36.85755252   25.65482505   20.38587101   17.83401282   17.31484695   17.2818683    17.28173032   17.28173032   17.28173032
water-heating           .        July            .        week      24.08863105   24.08863105   24.12740508   25.06336147   30.55524851   42.85060676   62.14426116   82.72671745   85.51535893   85.46961212   87.47694453   85.12224687   74.48379367   60.14852446   47.95565615   36.30169236   29.22281202   26.04185932   24.55116328   24.12990388   24.08863105   24.08863105   24.08863105   24.0781311
water-heating           .        August          .        week      23.84713225   23.84713225   23.88843497   24.83620519   30.43324807   43.06620777   62.92321391   84.28760118   87.74727414   87.77110604   89.8827664    87.32771309   76.16238934   61.07907333   48.27013916   36.379317     29.10826756   25.83991143   24.31380431   23.88955431   23.84713225   23.84713225   23.84713225   23.84713225
water-heating           .        September       .        week      14.50459063   14.50459063   14.5083137    15.23962092   21.17024452   38.03694233   67.9179342    107.4816628   130.308811    130.254275    131.5269625   130.2412511   112.1423934   86.88684195   59.76631596   34.85824589   23.21746782   17.65985762   15.0289748    14.5316611    14.50459063   14.50459063   14.50459063   14.49044456
water-heating           .        October         .        week      14.20752326   14.20752326   14.21129171   14.80342306   19.75072541   34.50906005   61.80635937   99.32682702   125.0689239   129.1376592   130.1438589   129.3620646   114.4685827   90.72626476   64.10630026   38.91610754   24.95846917   18.34569316   15.19779738   14.32163075   14.2121304    14.20752326   14.20752326   14.20752326
water-heating           .        November        .        week      17.04461799   17.04461799   17.04461799   17.04874441   17.85925506   24.46844297   43.15150283   76.2239914    119.5442836   143.760513    143.0212699   144.8366821   143.9823198   124.7379304   97.47153919   67.42733858   39.58427793   26.71699495   20.53742403   17.62151125   17.0734796    17.04474284   17.04461799   17.04461799
water-heating           .        December        .        week      18.59882908   18.59882908   18.59882908   18.60318254   19.46521564   26.46894356   46.35555093   81.5653256    127.7536989   153.6986603   152.851068    154.7224179   154.0587885   133.7349482   104.8562727   72.79269058   42.81099422   29.00335749   22.36297769   19.2126372    18.62803815   18.5989681    18.59882908   18.59882908
water-heating           .        January         .        peak      18.97407174   18.97407174   18.97407174   18.9788308    19.86275541   27.09431852   47.79288707   84.54479621   132.85486     160.4279865   159.3829687   161.3968094   160.9783781   139.9385112   109.8376829   76.08809912   44.47399799   29.94536815   22.94612068   19.62190481   19.00449052   18.97421076   18.97407174   18.97407174
water-heating           .        February        .        peak      19.06245274   19.06245274   19.06245274   19.06766712   20.03622604   27.95588756   50.65446018   90.94819718   143.7817732   173.7816027   172.4036442   174.7785676   174.5118588   151.6914414   118.8651788   81.7712416    47.01866234   31.08548526   23.39689221   19.75941426   19.09420072   19.06262818   19.06245274   19.06245274
water-heating           .        March           .        peak      18.9818238    18.9818238    18.9818238    18.98703611   19.97601568   28.07282069   51.3563264    92.71323681   147.012173    177.9799934   176.5564687   178.9978211   178.7905572   155.3905111   121.6786177   83.53035223   47.76687992   31.36680686   23.45101961   19.69664049   19.01516847   18.98200847   18.9818238    18.9818238
water-heating           .        April           .        peak      16.19256217   16.19256217   16.19658986   16.81944883   22.12534945   38.40801654   69.11767505   111.9847687   143.2397732   149.3610983   150.3380689   150.0638371   134.25522     107.5405157   76.69541639   46.76467794   29.57262028   21.42845102   17.52289778   16.35682903   16.19958526   16.19260414   16.19256217   16.2103522
water-heating           .        May             .        peak      16.58394286   16.58394286   16.58830633   17.40410604   23.98993612   42.67231749   75.84040177   119.6565207   144.6377972   144.3788287   145.5868417   144.8280778   125.3927634   98.11988502   68.2150249    39.7249964    26.54795067   20.23888376   17.18924513   16.61395522   16.5841195    16.58394286   16.58394286   16.61428144
water-heating           .        June            .        peak      17.28173032   17.28173032   17.30784114   18.229512     24.55053757   41.16626814   69.57572264   105.1661646   122.7413813   122.6898707   124.2081084   123.3054452   107.0840124   84.02242697   60.0483916    36.85755252   25.65482505   20.38587101   17.83401282   17.31484695   17.2818683    17.28173032   17.28173032   17.28173032
water-heating           .        July            .        peak      24.08863105   24.08863105   24.12740508   25.06336147   30.55524851   42.85060676   62.14426116   82.72671745   85.51535893   85.46961212   87.47694453   85.12224687   74.48379367   60.14852446   47.95565615   36.30169236   29.22281202   26.04185932   24.55116328   24.12990388   24.08863105   24.08863105   24.08863105   24.0781311
water-heating           .        August          .        peak      23.84713225   23.84713225   23.88843497   24.83620519   30.43324807   43.06620777   62.92321391   84.28760118   87.74727414   87.77110604   89.8827664    87.32771309   76.16238934   61.07907333   48.27013916   36.379317     29.10826756   25.83991143   24.31380431   23.88955431   23.84713225   23.84713225   23.84713225   23.84713225
water-heating           .        September       .        peak      14.50459063   14.50459063   14.5083137    15.23962092   21.17024452   38.03694233   67.9179342    107.4816628   130.308811    130.254275    131.5269625   130.2412511   112.1423934   86.88684195   59.76631596   34.85824589   23.21746782   17.65985762   15.0289748    14.5316611    14.50459063   14.50459063   14.50459063   14.49044456
water-heating           .        October         .        peak      14.20752326   14.20752326   14.21129171   14.80342306   19.75072541   34.50906005   61.80635937   99.32682702   125.0689239   129.1376592   130.1438589   129.3620646   114.4685827   90.72626476   64.10630026   38.91610754   24.95846917   18.34569316   15.19779738   14.32163075   14.2121304    14.20752326   14.20752326   14.20752326
water-heating           .        November        .        peak      17.04461799   17.04461799   17.04461799   17.04874441   17.85925506   24.46844297   43.15150283   76.2239914    119.5442836   143.760513    143.0212699   144.8366821   143.9823198   124.7379304   97.47153919   67.42733858   39.58427793   26.71699495   20.53742403   17.62151125   17.0734796    17.04474284   17.04461799   17.04461799
water-heating           .        December        .        peak      18.59882908   18.59882908   18.59882908   18.60318254   19.46521564   26.46894356   46.35555093   81.5653256    127.7536989   153.6986603   152.851068    154.7224179   154.0587885   133.7349482   104.8562727   72.79269058   42.81099422   29.00335749   22.36297769   19.2126372    18.62803815   18.5989681    18.59882908   18.59882908
water-heating           .        January         .        weekend   18.97407174   18.97407174   18.97407174   18.97407174   18.97537481   18.98384585   19.01349605   19.1066837    19.29336507   19.65386408   20.21284684   20.71635027   20.5365557    20.51336695   20.31016783   19.89008002   19.41396611   19.09984359   18.98776027   18.97407174   18.97407174   18.97407174   18.97407174   18.97407174
water-heating           .        February        .        weekend   19.06245274   19.06245274   19.06245274   19.06245274   19.06343005   19.07190212   19.10187705   19.19571728   19.38508677   19.75275685   20.32542919   20.84262115   20.65928358   20.63801001   20.43020551   20.00038094   19.51314523   19.19164828   19.07614335   19.06245274   19.06245274   19.06245274   19.06245274   19.06245274
water-heating           .        March           .        weekend   18.9818238    18.9818238    18.9818238    18.9818238    18.98280111   18.99127215   19.02124811   19.11265524   19.29377488   19.62922285   20.13815396   20.59528195   20.42026353   20.39125741   20.19977789   19.81579735   19.38212082   19.09655913   18.99337409   18.9818238    18.9818238    18.9818238    18.9818238    18.9818238
water-heating           .        April           .        weekend   16.19256217   16.19256217   16.19256217   16.19329515   16.19964843   16.22270037   16.29554858   16.45576262   16.77445928   17.27756846   17.75351533   17.67610622   17.63268371   17.46048974   17.09141595   16.65535844   16.34534045   16.21758766   16.19405939   16.19256217   16.19256217   16.19256217   16.19256217   16.19256217
water-heating           .        May             .        weekend   16.58394286   16.58394286   16.58451308   16.59054059   16.61351135   16.66287357   16.74050263   16.89362263   17.21884725   17.75220343   18.23891599   18.09793648   18.09527326   17.88857264   17.46877922   17.00595053   16.70413266   16.59677651   16.58394286   16.58394286   16.58394286   16.58394286   16.58394286   16.58394286
water-heating           .        June            .        weekend   17.28173032   17.28173032   17.28290309   17.29450234   17.33412222   17.4052167    17.45617552   17.70236405   18.25973084   18.71381734   18.84909149   18.63506023   18.36433494   18.57966471   18.38658416   17.95110738   17.48015349   17.28173032   17.28173032   17.28173032   17.28173032   17.28173032   17.28173032   17.96242039
water-heating           .        July            .        weekend   24.08863105   24.08863105   24.0905867    24.10850712   24.16682916   24.26424975   24.29976379   24.50481481   25.01588355   25.45479647   25.59490528   25.42786241   25.19209258   25.37921696   25.1659221    24.7337414    24.27902038   24.08863105   24.08863105   24.08863105   24.08863105   24.08863105   24.08863105   24.08863105
water-heating           .        August          .        weekend   23.84713225   23.84713225   23.8486525    23.86081663   23.902377     23.97709898   24.03046151   24.26817028   24.79812061   25.22871408   25.35608434   25.14968494   24.88931573   25.08447136   24.89511548   24.48026961   24.03473663   23.84713225   23.84713225   23.84713225   23.84713225   23.84713225   23.84713225   22.80907207
water-heating           .        September       .        weekend   14.50459063   14.50459063   14.50459063   14.50545934   14.51154129   14.53355251   14.60296788   14.75171961   15.0578043    15.55153177   15.99989833   15.8579526    15.85229671   15.68104074   15.31347856   14.89360712   14.6166729    14.51656835   14.50459063   14.50459063   14.50459063   14.50459063   14.50459063   14.50459063
water-heating           .        October         .        weekend   14.20752326   14.20752326   14.20752326   14.20850109   14.21534328   14.23945384   14.311003     14.53853081   15.00039256   15.45048759   15.68101398   15.48328058   15.26358018   15.3337063    15.18843018   14.82409288   14.43168794   14.23415361   14.20752326   14.20752326   14.20752326   14.20752326   14.20752326   14.20752326
water-heating           .        November        .        weekend   17.04461799   17.04461799   17.04461799   17.04461799   17.04570389   17.05403026   17.08299272   17.17038615   17.43211504   17.94370195   18.45132245   18.73805292   18.49080232   18.29193111   18.34901152   18.07919085   17.62847347   17.21735192   17.05032184   17.04461799   17.04461799   17.04461799   17.04461799   17.04461799
water-heating           .        December        .        weekend   18.59882908   18.59882908   18.59882908   18.59882908   18.5996978    18.60664846   18.63126676   18.70707625   18.92442915   19.37407793   19.91657926   20.3038876    20.09931878   19.98344497   19.94900034   19.61420795   19.14128084   18.75711284   18.60795477   18.59882908   18.59882908   18.59882908   18.59882908   18.59882908
naturalgas-only         .        January         .        week      .135008525    .135008525    .135008525    .135008525    .300654475    2.883210772   14.31484238   31.21585986   49.87305291   67.09793946   67.74071156   64.5673751    63.18386465   56.98593143   42.80095892   25.26890478   17.14805705   11.87317775   6.400189004   1.436983019   .216038253    .135008525    .135008525    .135008525
naturalgas-only         .        February        .        week      .135008525    .135008525    .135008525    .135008525    .307359192    2.99444753    14.88878803   32.47389432   51.88625947   69.80834381   70.47713288   67.17535184   65.73584216   59.28704022   44.52791406   26.28622915   17.83668044   12.34829412   6.653779643   1.489681986   .219318028    .135008525    .135008525    .135008525
naturalgas-only         .        March           .        week      .135008525    .135008525    .135008525    .135008525    .31643028     3.14494432    15.66530274   34.17594094   54.61000952   73.47536146   74.17934995   70.70379096   69.18851761   62.40030504   46.86438277   27.66260919   18.76834739   12.99109863   6.99687286    1.56098059    .22375537     .135008525    .135008525    .135008525
naturalgas-only         .        April           .        week      .135008525    .135008525    .135008525    .275198063    2.50210022    12.81976674   29.96897771   49.96590302   69.18778147   74.01935256   71.49369073   69.53289792   63.94308063   50.3952742    32.02664864   20.78977052   14.30410971   8.359196898   2.796410651   .527670193    .155178263    .135008525    .135008525    .135008525
naturalgas-only         .        May             .        week      .135008525    .135008525    .135008525    .308542378    3.014077546   14.99007256   32.6959004    52.24153121   70.28665046   70.96003076   67.63558303   66.18619113   59.69311824   44.83267085   26.46575698   17.95820222   12.43213819   6.698530932   1.498981804   .219896812    .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        June            .        week      7.857235595   7.857235595   7.864062225   8.082319522   10.27675174   18.48712159   30.07359405   42.63092151   52.83249862   52.88087238   50.8518506    49.91155889   45.90406442   36.90351338   25.40779076   19.58088209   15.9492957    12.28713328   8.916354311   7.942038193   7.857235595   7.857235595   7.857235595   7.857235595
naturalgas-only         .        July            .        week      15.57341946   15.57341946   15.5864791    15.8317344    17.30114643   20.83605614   24.97154165   29.08234332   30.12316021   29.50450257   29.01899265   28.70042291   27.66190235   25.61451053   22.35256432   19.85512574   18.53442455   17.3711442    16.21917985   15.65076261   15.57341946   15.57341946   15.57341946   15.57341946
naturalgas-only         .        August          .        week      15.57341946   15.57341946   15.58396971   15.82334088   17.37387164   21.23063658   25.79969194   30.41066256   31.78179479   31.14589541   30.60039193   30.27666541   29.1237142    26.76473055   23.07237818   20.33022584   18.86905752   17.56222523   16.2732796    15.6560711    15.57341946   15.57341946   15.57341946   15.57341946
naturalgas-only         .        September       .        week      .135008525    .135008525    .135008525    .307791149    3.001614044   14.92576492   32.55494416   52.01596185   69.9829637    70.65342893   67.34337275   65.90025527   59.43529092   44.63917447   26.35177106   17.88104554   12.37890386   6.670117415   1.493077158   .21952933     .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        October         .        week      .135008525    .135008525    .135008525    .276990768    2.522162061   12.81261892   29.47665897   48.68778016   67.00571969   70.83759797   68.24002807   66.44971693   60.87367695   47.53457037   29.80519587   19.50503036   13.4368771    7.741004979   2.444354373   .45245772     .150442759    .135008525    .135008525    .135008525
naturalgas-only         .        November        .        week      .135008525    .135008525    .135008525    .135008525    .290512886    2.714953492   13.44668928   29.31295059   46.82786652   62.99816818   63.60158689   60.62253633   59.3237306    53.50526268   40.18875788   23.73009481   16.10644184   11.15451433   6.016606526   1.357270295   .21107725     .135008525    .135008525    .135008525
naturalgas-only         .        December        .        week      .135008525    .135008525    .135008525    .135008525    .29169095     2.73449853    13.54753535   29.53399561   47.18160029   63.47440424   64.0823943    61.08077518   59.77213001   53.90958279   40.49219537   23.90884546   16.22743754   11.23799543   6.061164087   1.366529854   .211653528    .135008525    .135008525    .135008525
naturalgas-only         .        January         .        peak      .135008525    .135008525    .135008525    .135008525    .300654475    2.883210772   14.31484238   31.21585986   49.87305291   67.09793946   67.74071156   64.5673751    63.18386465   56.98593143   42.80095892   25.26890478   17.14805705   11.87317775   6.400189004   1.436983019   .216038253    .135008525    .135008525    .135008525
naturalgas-only         .        February        .        peak      .135008525    .135008525    .135008525    .135008525    .307359192    2.99444753    14.88878803   32.47389432   51.88625947   69.80834381   70.47713288   67.17535184   65.73584216   59.28704022   44.52791406   26.28622915   17.83668044   12.34829412   6.653779643   1.489681986   .219318028    .135008525    .135008525    .135008525
naturalgas-only         .        March           .        peak      .135008525    .135008525    .135008525    .135008525    .31643028     3.14494432    15.66530274   34.17594094   54.61000952   73.47536146   74.17934995   70.70379096   69.18851761   62.40030504   46.86438277   27.66260919   18.76834739   12.99109863   6.99687286    1.56098059    .22375537     .135008525    .135008525    .135008525
naturalgas-only         .        April           .        peak      .135008525    .135008525    .135008525    .275198063    2.50210022    12.81976674   29.96897771   49.96590302   69.18778147   74.01935256   71.49369073   69.53289792   63.94308063   50.3952742    32.02664864   20.78977052   14.30410971   8.359196898   2.796410651   .527670193    .155178263    .135008525    .135008525    .135008525
naturalgas-only         .        May             .        peak      .135008525    .135008525    .135008525    .308542378    3.014077546   14.99007256   32.6959004    52.24153121   70.28665046   70.96003076   67.63558303   66.18619113   59.69311824   44.83267085   26.46575698   17.95820222   12.43213819   6.698530932   1.498981804   .219896812    .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        June            .        peak      7.857235595   7.857235595   7.864062225   8.082319522   10.27675174   18.48712159   30.07359405   42.63092151   52.83249862   52.88087238   50.8518506    49.91155889   45.90406442   36.90351338   25.40779076   19.58088209   15.9492957    12.28713328   8.916354311   7.942038193   7.857235595   7.857235595   7.857235595   7.857235595
naturalgas-only         .        July            .        peak      15.57341946   15.57341946   15.5864791    15.8317344    17.30114643   20.83605614   24.97154165   29.08234332   30.12316021   29.50450257   29.01899265   28.70042291   27.66190235   25.61451053   22.35256432   19.85512574   18.53442455   17.3711442    16.21917985   15.65076261   15.57341946   15.57341946   15.57341946   15.57341946
naturalgas-only         .        August          .        peak      15.57341946   15.57341946   15.58396971   15.82334088   17.37387164   21.23063658   25.79969194   30.41066256   31.78179479   31.14589541   30.60039193   30.27666541   29.1237142    26.76473055   23.07237818   20.33022584   18.86905752   17.56222523   16.2732796    15.6560711    15.57341946   15.57341946   15.57341946   15.57341946
naturalgas-only         .        September       .        peak      .135008525    .135008525    .135008525    .307791149    3.001614044   14.92576492   32.55494416   52.01596185   69.9829637    70.65342893   67.34337275   65.90025527   59.43529092   44.63917447   26.35177106   17.88104554   12.37890386   6.670117415   1.493077158   .21952933     .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        October         .        peak      .135008525    .135008525    .135008525    .276990768    2.522162061   12.81261892   29.47665897   48.68778016   67.00571969   70.83759797   68.24002807   66.44971693   60.87367695   47.53457037   29.80519587   19.50503036   13.4368771    7.741004979   2.444354373   .45245772     .150442759    .135008525    .135008525    .135008525
naturalgas-only         .        November        .        peak      .135008525    .135008525    .135008525    .135008525    .290512886    2.714953492   13.44668928   29.31295059   46.82786652   62.99816818   63.60158689   60.62253633   59.3237306    53.50526268   40.18875788   23.73009481   16.10644184   11.15451433   6.016606526   1.357270295   .21107725     .135008525    .135008525    .135008525
naturalgas-only         .        December        .        peak      .135008525    .135008525    .135008525    .135008525    .29169095     2.73449853    13.54753535   29.53399561   47.18160029   63.47440424   64.0823943    61.08077518   59.77213001   53.90958279   40.49219537   23.90884546   16.22743754   11.23799543   6.061164087   1.366529854   .211653528    .135008525    .135008525    .135008525
naturalgas-only         .        January         .        weekend   .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .168181176    .501981091    1.704489941   3.67204313    5.081880771   5.110906919   4.870404687   4.275370593   3.176525915   2.206227021   .972618072    .240746365    .135008525    .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        February        .        weekend   .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .168181176    .501981091    1.704489941   3.67204313    5.081880771   5.110906919   4.870404687   4.275370593   3.176525915   2.206227021   .972618072    .240746365    .135008525    .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        March           .        weekend   .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .164863911    .465283834    1.5475418     3.318339669   4.587193546   4.61331708    4.396865071   3.861334387   2.872374176   1.999105171   .888857117    .230172581    .135008525    .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        April           .        weekend   .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .164034595    .460256101    1.554176335   3.426098981   4.905651066   5.10727865    4.900467466   4.349749855   3.3138815     2.327514383   1.12681919    .332230328    .148225755    .135008525    .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        May             .        weekend   .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .168181176    .501981091    1.704489941   3.67204313    5.081880771   5.110906919   4.870404687   4.275370593   3.176525915   2.206227021   .972618072    .240746365    .135008525    .135008525    .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        June            .        weekend   9.402083889   9.402083889   9.402083889   9.402083889   9.402083889   9.402083889   9.402083889   10.53202749   12.82508753   14.2079721    14.37798192   14.17894557   13.92600529   13.92600529   13.35792264   11.94393864   11.23902017   9.402083889   9.402083889   9.402083889   9.402083889   9.402083889   9.402083889   9.402083889
naturalgas-only         .        July            .        weekend   15.57341946   15.57341946   15.57341946   15.57341946   15.57341946   15.57341946   15.57341946   16.70336298   18.99642351   20.37930769   20.54931725   20.35028154   20.09734088   20.09734088   19.52925862   18.11527461   17.41035628   15.57341946   15.57341946   15.57341946   15.57341946   15.57341946   15.57341946   15.57341946
naturalgas-only         .        August          .        weekend   13.8558023    13.8558023    13.8558023    13.8558023    13.8558023    13.8558023    13.8558023    14.98574584   17.27880628   18.66169054   18.83170014   18.63266436   18.37972373   18.37972373   17.81164143   16.39765741   15.69273906   13.8558023    13.8558023    13.8558023    13.8558023    13.8558023    13.8558023    13.8558023
naturalgas-only         .        September       .        weekend   .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .168181176    .501981091    1.704489941   3.67204313    5.081880771   5.110906919   4.870404687   4.275370593   3.176525915   2.206227021   .972618072    .240746365    .135008525    .135008525    .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        October         .        weekend   .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .143301688    .932966493    2.807999143   4.450822755   5.082399106   4.986508996   4.743416139   4.563040073   3.933277288   2.73595224    1.810227841   .391060001    .135008525    .135008525    .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        November        .        weekend   .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .149751926    .925853956    2.734224531   4.376961788   5.098006409   5.000330988   4.752918694   4.488459097   3.684482249   2.467691628   1.527799507   .18200312     .135008525    .135008525    .135008525    .135008525    .135008525
naturalgas-only         .        December        .        weekend   .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .135008525    .157123626    .75630481     2.322330695   4.094994325   5.091556153   5.04456136    4.799913091   4.403223696   3.481299715   2.363105785   1.305726933   .205500418    .135008525    .135008525    .135008525    .135008525    .135008525
;

*2013/05/31. Lenaig defined load for the different years. It is possible to multiply "AnnualLoad1" by a coefficient to consider a trend in the building load.
Parameter Load (years, enduse, months, daytypes, hours);
Load (years, enduse, months, daytypes, hours)= AnnualLoad1 (enduse, months, daytypes, hours);
$offtext
Parameter PX (years,months,daytypes,hours);
PX (years,months,daytypes,hours) = PX1(months,daytypes,hours)*Exchangerate;
Parameter Load (years, enduse, months, daytypes, hours);
Load (years, enduse, months, daytypes, hours)= AnnualLoad1 (enduse, months, daytypes, hours);

parameter max_electric_load;
max_electric_load = smax ((years, months, daytypes, hours), load(years, 'electricity-only', months, daytypes, hours) + load(years, 'cooling', months, daytypes, hours));

* note static switch cost = CostM*SizeNeeded + CostB
* where SizeNeeded is the required switch capacity (kW)
* CostB ($)
* CostM ($/kW)
Parameter
StaticSwitchParameter (StaticSwitchParameters)
/
CostM          100
CostB          0
Lifetime       10
Value          350
ForcedInvest   0
/

* PGE
*José cero for Spain
Parameter
MonthlyFee1 (service)
/
UtilElectric    0
UtilNGbasic     0
UtilNGforDG     0
UtilNGforABS    0
UtilDiesel      0
/
;
*2013/09/06. Lenaig renamed "MonthlyFee(service)" as "MonthlyFee1(service)" and defined "MonthlyFee (years, service)" with a year index.
*This enables to consider a trend in monthly fees.
Parameter MonthlyFee (years, service);
MonthlyFee (years,'UtilElectric') = MonthlyFee1 ('UtilElectric');
MonthlyFee (years,'UtilNGbasic')  = MonthlyFee1 ('UtilNGbasic');
MonthlyFee (years,'UtilNGforDG')  = MonthlyFee1 ('UtilNGforDG');
MonthlyFee (years,'UtilNGforABS') = MonthlyFee1 ('UtilNGforABS');
MonthlyFee (years,'UtilDiesel')   = MonthlyFee1 ('UtilDiesel');
***

* PGE
Parameter
CoincidentHour1(months)   Hour of month that coincident demand charges are applied to
/
* Demand charges are proportional to the maximum rate of electricity consumption
* (regardless of the duration or frequency of such consumption).
* Demand charges may be assessed daily (e.g. for New York DG customers)
* or monthly (more common) and may be for all hours of the month
* or only certain hours (on, mid, or off peak), or just at the hour of
* peak system-wide consumption.
*
* There are five demand types in DER-CAM, and each are applicable to daily or
* monthly demand charges:
*   -) Non-coincident: these are incurred based on the maximum consumption in ANY hour
*   -) On-peak: based only on on-peak hours.
*   -) Mid-peak: based only on mid-peak hours.
*   -) Off-peak: based only on off-peak hours.
*   -) Coincident: based only on the hour of peak system-wide consumption.
*
*  Please specify the coincident hours here

January          18
February         18
March            18
April            18
May              18
June             18
July             18
August           18
September        18
October          18
November         18
December         18
/
;
*2013/09/06. Lenaig renamed "CoincidentHour(months)" as "CoincidentHour1(months)" and defined "CoincidentHour(years,months)" with a year index.
*This enables to consider changes over time.
Parameter CoincidentHour (years,months);
CoincidentHour (years,months) = CoincidentHour1 (months);
***

Parameter
CO2EmissionsRate (FuelType)
/
Solar       0
NGbasic    .18084
NGforDG    .18084
NGforAbs   .18084
Diesel     .24948
/

Parameter
Beta (enduse)
/
* kW of heat produced from one kW of natural gas
space-heating           0.8
water-heating           0.8
naturalgas-only         1.0
/

* Lifetime            lifetime of system, in years TK more detailed costing should be done, batteries short life, inverter long life
*2013/03/22. Lenaig rewrote the comments below.
* EfficiencyCharge        [] fraction of power input   that is not lost in transfer (charging)
* EfficiencyDischarge     [] fraction of power output  that is not lost in transfer (discharging)
* SelfDischarge           [] fraction of stored energy that is lost from one hour to the next due to self-discharge
* MaxChargeRate        [1/h] fraction of total installed capacity that can be charged in 1 hour
* MaxDischargeRate     [1/h] fraction of total installed capacity that can be discharged in 1 hour
* MaxDepthOfDischarge     [] fraction of total installed capacity that is considered a limit when discharging
* DiscreteSize         [kWh] unit battery size
*                            When Option 'DiscreteElecStorage' is set to 1, batteries have to be multiple sizes of DiscreteSize.
*                            This is especially important for NaS batteries which are produced in multiple sizes of 500 kWh. Lenaig : why 500 kWh? where is the reference?
* BatteryDegradation      [] fraction of total installed capacity that is lost from one month to the next due to battery ageing

Parameter ElectricityStorageStationaryParameter(StorageParameters)
/
EfficiencyCharge    0.97
EfficiencyDischarge 0.97
SelfDischarge       0.000042
*2013/06/06. Lenaig. Li-ion batteries : realistic self-discharge = 3%/month.
MaxChargeRate       0.25
MaxDischargeRate    0.25
MaxDepthOfDischarge 0.8
DiscreteSize        500
BatteryDegradation  0.000027
/
*2013/06/06. Lenaig added the parameter 'BatteryDegradation' to model capacity loss due to battery ageing.
*Battery degradation : 0.333% initial capacity/month = 20% of initial capacity lost at the end of a 5-year lifetime
;

Parameter
ElectricityStorageEVParameter(StorageParameters)
/
EfficiencyCharge      .954
*[] fraction of Energy that is not lost in transfer
EfficiencyDischarge   .954
*[] fraction of Energy that is not lost in transfer
SelfDischarge         .001
*[] fraction of Energy that is lost from one hour to the next
MaxChargeRate         .45
*[1/h] fraction of total capacity that can be charged in 1 hour
MaxDischargeRate      .45
*[1/h] fraction of total capacity that can be discharged in 1 hour
BeginingHomeCharge     21
EndHomeCharge          7
ConnectingHourOffice   9
DisconnectHourOffice   19
MaxDepthOfDischarge    .8
MinSOCConnect          .73
MinSOCDisconnect       .32
MaxStateOfCharge       .9
MaxSOConnect           .73
MaxSOCDisconnect       .9
*OLIVIER : hour when EVs start charging at home
*OLIVIER : hour when EVs stop charging at home
*OLIVIER : hour when EVs are plugged into building
*OLIVIER : hour when EVs are disconnected from building
*FractionBatteryJourney 0.1586
*BatteryJourney         2.5376
/

*2013/03. Lenaig added a year index.
Parameter NightlyMarginalCO2EmissionsResidential(years,months,hours);
NightlyMarginalCO2EmissionsResidential(years,months,hours)= HourlyMarginalCO2Emissions(months,hours) $ (ord(hours) >= ElectricityStorageEVParameter('BeginingHomeCharge') or ord(hours) <= ElectricityStorageEVParameter('EndHomeCharge'));
* 0 when the car is not being charged at home

*2013/03. Lenaig added a year index.
Parameter MonthlyNightlyMarginalCO2EmissionsResidential(years,months);
MonthlyNightlyMarginalCO2EmissionsResidential(years,months)=sum(hours,NightlyMarginalCO2EmissionsResidential(years,months,hours))/(ElectricityStorageEVParameter('EndHomeCharge')+25-ElectricityStorageEVParameter('BeginingHomeCharge'));

Parameter Electricity_Exchange_EV
/
P_EX_Vehicle                     0.06218
*[$/kWh]
*The energy exchange price for buying and selling energy.
*It needs to be above Offsite access prices, to assure,
*energy exchange is always
*OLIVIER : does not include carbon tax

Capacity_Loss_per_Normalized_Wh  .000027
*dimensionless []. Steady charge rate assumed within hours.
Production_Cost_Li-Ion           600
*[$/kWh]
Future_Replacement_Cost          200
*[$/kWh]
Reference_Cost                   244894
*[$]
P_Offsite_Access                 0
*OLIVIER : offsite_access price is not used so far !
*[$/kWh]
/


Parameter
HeatStorageParameter(StorageParameters)
/
EfficiencyCharge    0.90
EfficiencyDischarge 0.90
Decay               0.01
MaxChargeRate       0.25
MaxDischargeRate    0.25
MaxDepthOfDischarge 1
/

* note that MaxChargeRate and MaxDischargeRate are not included because that's a variable

Parameter
FlowBatteryParameter(StorageParameters)
/
EfficiencyCharge      .84
EfficiencyDischarge   .84
SelfDischarge         0
*2013/06/06. Lenaig. Flow batteries : self-discharge = negligible.
MaxDepthOfDischarge   .75
/

* COP absorption chillers for building cooling
Parameter
COP_Electric_Abs_Chillers
/
Electric    4.5
Absorption  0.7
/

* COP absorption chillers for refrigeration
Parameter
COP_Electric_Abs_Refrigeration
/
Electric    4.5
Absorption  0.7
/

Parameters
     COPelectric
     COPabs;

COPelectric = COP_Electric_Abs_Chillers  ('Electric');
COPabs = COP_Electric_Abs_Chillers  ('Absorption');

Table DemandResponseParameters1 (DemandResponseType,DemandResponseInvestParameters)
        VariableCost       MaxContribution    MaxHours
*  VariableCost ($/kW)
*  MaxContribution must be <1. Additionally, the sum of low, mid, and high maxContributions must be <=1.
low     0                   0.3               0
mid     0.06                0.1               0
high    1                   0.05              0
;
*2013/09/06. Lenaig renamed "DemandResponseParameters(DemandResponseType,DemandResponseInvestParameters)" as "DemandResponseParameters1(DemandResponseType,DemandResponseInvestParameters)"
*and defined "DemandResponseParameters(years,DemandResponseType,DemandResponseInvestParameters)" with a year index.
*This enables to consider a trend in demand response costs.
Parameter DemandResponseParameters(years,DemandResponseType,DemandResponseInvestParameters);
DemandResponseParameters(years,DemandResponseType,'VariableCost') = DemandResponseParameters1 (DemandResponseType,'VariableCost');
***

Table DemandResponseParametersHeating1 (DemandResponseType,DemandResponseInvestParameters)
        VariableCost       MaxContribution    MaxHours
*  VariableCost ($/kW)
*  MaxContribution must be <1. Additionally, the sum of low, mid, and high maxContributions must be <=1.
low     0                   0.3               0
mid     0.03                0.2               0
high    0.05                0.1               0
;
*2013/09/06. Lenaig renamed "DemandResponseParametersHeating(DemandResponseType,DemandResponseInvestParameters)" as "DemandResponseParametersHeating1(DemandResponseType,DemandResponseInvestParameters)"
*and defined "DemandResponseParametersHeating(years,DemandResponseType,DemandResponseInvestParameters)" with a year index.
*This enables to consider a trend in demand response costs.
Parameter DemandResponseParametersHeating(years,DemandResponseType,DemandResponseInvestParameters);
DemandResponseParametersHeating (years,DemandResponseType,'VariableCost') = DemandResponseParametersHeating1 (DemandResponseType,'VariableCost');
***

Table SchedulableLoadParameterTable (SLParameterOption, SLParameterValue) Parameters for user input
                               ParameterValue
* PercentageSchedulablePeak          'percentage of the load that can be scheduled daily on peak days
* PercentageSchedulableWeek          'percentage of the load that can be scheduled daily on week days
* PercentageSchedulableWeekend       'percentage of the load that can be scheduled daily on weekend days
* MaxLoadInHour                      'Max load that can be scheduled in any hour (kW)
* LoadIncrease                       'Max load that can be added in any hour (kW)


PercentageSchedulablePeak      15
PercentageSchedulableWeek      15
PercentageSchedulableWeekend   15
MaxLoadInHour                  50
MaxIncrease                    50
;

*Turn off and on load scheduling
SchedulableLoadParameterTable(SLParameterOption,SLParameterValue) $ (OptionsTable ('LS','OptionValue')=0)=0;

* Load Scheduling
*2013/03. Lenaig added a year index.
parameter MaxShiftableLoad (years,months, daytypes) days of each type;

    MaxShiftableLoad(years,months,'week') = sum(hours, Load(years,'electricity-only',months,'week',hours))*SchedulableLoadParameterTable ('PercentageSchedulableWeek','ParameterValue')/100;
    MaxShiftableLoad(years,months,'weekend') = sum(hours, Load(years,'electricity-only',months,'weekend',hours))*SchedulableLoadParameterTable ('PercentageSchedulableWeekend','ParameterValue')/100;
    MaxShiftableLoad(years,months,'peak') = sum(hours, Load(years,'electricity-only',months,'peak',hours))*SchedulableLoadParameterTable ('PercentageSchedulablePeak','ParameterValue')/100;

*****************************************************************
*****   Availabilities for EV Storage - Connection times   *********
*****************************************************************

* The three following tables represent the key inputs for mobility behavior and resulting connection times
* They need to be consistent, so please follow instructions as given for each table!


* Indicates the hours of connection indirectly
* Indicates the hours at which the electricity stored must depend on the hour before.

*envisioned reasonable availabilities

*2013/03. Lenaig added a year index.
parameter BinaryEVsConnectionTable (years, months, daytypes, hours);
BinaryEVsConnectionTable(years,months,daytypes,hours)$(ord(hours)>ElectricityStorageEVParameter('ConnectingHourOffice')AND ord(hours)<ElectricityStorageEVParameter('DisconnectHourOffice') AND ord(daytypes)<3)=1;

* This parameter indicates the hours of connection and disconnection of EVs via zeros.
* Thus, e.g. there is a '0' at 9h for connection and another '0' at 19h for disconnection at 18h.
* +++++++++++++++++++++++++++++++++++++++++++
* Note that for the disconnection, the discharging energy flow is assigned to the next hour, which is why the '0'
* is implemented at 19h, indicating a disconnection at 18h.
* +++++++++++++++++++++++++++++++++++++++++++

* The constraint for charging rates needs to be relaxed in these hours so that e.g. the SOC can go from 0 in hour 8 to 73% in hour 9. The same is necessary for disconnection.
* This table is also used to isolate the effects of connection and disconnection of EVs in the microgrid's energy balance and the billing.
* Energy is basically not charged when brought into the system or out of the microgrid system. It is rather billed via the net energy exchanged (see Parameter Electricity_Exchange_EV).
* If it was not implemented in this way the connection would mean that in order to meet a certain SOC at connection the energy for that would have to be procured
* from the utility, or generated on site, and billed accordingly.



* The following two parameters limit ElectricityStorageEVsOutput and ElectricityStorageEVsInput, and therefore, the State of Charge of the batteries ElectricityStored (=SOC)

*2013/03. Lenaig added a year index.
parameter MinimumStateofChargeEVs (years, months, daytypes, hours);
MinimumStateofChargeEVs(years, months, daytypes, hours)$(ord(hours)=ElectricityStorageEVParameter('ConnectingHourOffice') AND ord(daytypes)<>3)=ElectricityStorageEVParameter('MinSOCConnect');
MinimumStateofChargeEVs(years, months, daytypes, hours)$(ord(hours)=(ElectricityStorageEVParameter('DisconnectHourOffice')-1) AND ord(daytypes)<>3)=ElectricityStorageEVParameter('MinSOCDisconnect');
MinimumStateofChargeEVs(years, months, daytypes, hours)$(ord(hours)>ElectricityStorageEVParameter('ConnectingHourOffice') AND ord(hours)<(ElectricityStorageEVParameter('DisconnectHourOffice')-1) AND ord(daytypes)<>3)=ElectricityStorageEVParameter('MaxDepthOfDischarge');

*2013/03. Lenaig added a year index.
parameter MaximumStateofChargeEVs (years, months, daytypes, hours);
MaximumStateofChargeEVs(years, months, daytypes, hours)$(ord(hours)=ElectricityStorageEVParameter('ConnectingHourOffice') AND ord(daytypes)<>3)=ElectricityStorageEVParameter('MaxSOConnect');
MaximumStateofChargeEVs(years, months, daytypes, hours)$(ord(hours)=(ElectricityStorageEVParameter('DisconnectHourOffice')-1) AND ord(daytypes)<>3)=ElectricityStorageEVParameter('MaxSOCDisconnect');
MaximumStateofChargeEVs(years, months, daytypes, hours)$(ord(hours)>ElectricityStorageEVParameter('ConnectingHourOffice') AND ord(hours)<(ElectricityStorageEVParameter('DisconnectHourOffice')-1) AND ord(daytypes)<>3)=ElectricityStorageEVParameter('MaxStateOfCharge');


* During hours of disconnection the minimum values need to be 0.
* They serve as a tool to meet certain states of charge at certain times.

* During hours of disconnection the maxium values need to be 0.
* They serve as a tool to meet certain states of charge at certain times.

* Do not remove the following line. It is important for UFII. It increases the performance of UFII.
*%spd

****************************************************
*****   ASSIGNING NUMBERS TO SET ENTRIES   *********
****************************************************

Parameters DemandValue (DemandType);
DemandValue (DemandType) = ord(DemandType);

Parameter daytypesValue(daytypes);
daytypesValue(daytypes) = ord(daytypes);

Parameter FuelValue;
FuelValue (FuelType) = ord(FuelType);


**************************************
*****   DYNAMIC SET DECLARATIONS   ***
**************************************
*2013/05/31. Lenaig declared the year-counter.
years_counter(YEARS) =yes;

* Only consider available technologies (saves lots of computation time)
* should be needed if other techs are fixed at zero

AvailableTECHNOLOGIES(TECHNOLOGIES) = yes;
AvailableTECHNOLOGIES(TECHNOLOGIES)$(OptionsTable('DiscreteInvest','OptionValue') = 0) = no;
AvailableTECHNOLOGIES(TECHNOLOGIES)$(GenConstraints(TECHNOLOGIES,'MaxAnnualHours') = 0)= no;
AvailableTECHNOLOGIES(TECHNOLOGIES)$((SGIPOptions('enableSGIP','OptionValue') = 0) and (deropt(TECHNOLOGIES, 'SGIPIncentive') = 1)) = no;

*GC added this to create a subset of Fuel Cell Technologies
*01/16/2012
AvailableFCTechnologies(TECHNOLOGIES) = yes;
AvailableFCTechnologies(TECHNOLOGIES)$(GenConstraints(TECHNOLOGIES,'MaxAnnualHours') = 0) = no;
AvailableFCTechnologies(TECHNOLOGIES)$(DerOpt(TECHNOLOGIES,'Type') <> 1) = no;

AvailableCHPTECHNOLOGIES(AvailableTECHNOLOGIES) = yes;
AvailableCHPTECHNOLOGIES(AvailableTECHNOLOGIES)$(DEROPT(AvailableTECHNOLOGIES, 'chpenable') = 0) = no;
AvailableCHPTECHNOLOGIES(AvailableTECHNOLOGIES)$((DEROPT(AvailableTechnologies, 'SGIPIncentive') = 1) and (DEROPT(AvailableTechnologies, 'maxp') gt max_electric_load)) = no;

AvailableSGIPTechnologies(AvailableCHPTechnologies) = yes;
AvailableSGIPTechnologies(AvailableCHPTechnologies)$(DEROPT(AvailableCHPTechnologies, 'SGIPIncentive') = 0) = no;
AvailableSGIPTechnologies(AvailableCHPTechnologies)$(DEROPT(AvailableCHPTechnologies, 'NoxRate') gt SGIPOptions('MaxNOxRate', 'OptionValue')) = no;


set NonNGFuels (FuelType);
NonNGFuels(FuelType) = yes;
NonNGFuels(FuelType)$(ord(FuelType) = FuelValue('NGbasic') ) = no;
NonNGFuels(FuelType)$(ord(FuelType) = FuelValue('NGforDG') ) = no;
NonNGFuels(FuelType)$(ord(FuelType) = FuelValue('NGforABS') ) = no;


sets
OnHoursMonth (hours, months, daytypes)
MidHoursMonth (hours, months, daytypes)
OffHoursMonth (hours, months, daytypes);

     Parameter HoursByMonth(hours, months, daytypes);
     loop ((months, seasons)$(MonthSeason(months,seasons)=1),
     HoursByMonth (hours, months, daytypes)
     =
     ListOfHours(hours,seasons,daytypes)
     );

     loop (seasons,
     OnHoursMonth (hours, months, daytypes)
     $(ListOfHours(hours,seasons,daytypes) = 1
     and MonthSeason(months,seasons) = 1 )
     = yes);

     loop (seasons,
     MidHoursMonth (hours, months, daytypes)
     $(ListOfHours(hours,seasons,daytypes) = 2
     and MonthSeason(months,seasons) = 1 )
     = yes);

     loop (seasons,
     OffHoursMonth (hours, months, daytypes)
     $(ListOfHours(hours,seasons,daytypes) = 3
     and MonthSeason(months,seasons) = 1 )
     = yes);


***********************************
****** PARAMETER ADJUSTMENT  ******
***********************************

Parameter SGIPIncentiveAmount(Technologies);
* SGIP Incentive is in $/W, so the number is multiplied by 1000 to make it $/kW
SGIPIncentiveAmount(AvailableSGIPTechnologies)$(Deropt(AvailableSGIPTechnologies,'Type') = 1) = Deropt(AvailableSGIPTechnologies, 'maxp') * SGIPIncentives('FuelCell','OptionValue') * SGIPOptions('SGIPPercentage','OptionValue') * 1000;
SGIPIncentiveAmount(AvailableSGIPTechnologies)$(Deropt(AvailableSGIPTechnologies,'Type') = 2) = Deropt(AvailableSGIPTechnologies, 'maxp') * SGIPIncentives('GasTurbine','OptionValue') * SGIPOptions('SGIPPercentage','OptionValue') * 1000;
SGIPIncentiveAmount(AvailableSGIPTechnologies)$(Deropt(AvailableSGIPTechnologies,'Type') = 4) = Deropt(AvailableSGIPTechnologies, 'maxp') * SGIPIncentives('ICENG','OptionValue') * SGIPOptions('SGIPPercentage','OptionValue') * 1000;
SGIPIncentiveAmount(AvailableSGIPTechnologies)$(Deropt(AvailableSGIPTechnologies,'Type') = 5) = Deropt(AvailableSGIPTechnologies, 'maxp') * SGIPIncentives('Microturbine','OptionValue') * SGIPOptions('SGIPPercentage','OptionValue') * 1000;

* Internal calculation of C02_emission_rate needed to adjust PBI Payment in the SGIP program. Emission limits are hard coded.
Parameter CO2_emission_rate(Technologies);
         CO2_emission_rate(AvailableSGIPTechnologies)$(Deropt(AvailableSGIPTechnologies, 'Fuel') = 4) = 1 / DEROPT(AvailableSGIPTechnologies, 'efficiency') * CO2EmissionsRate ('NGforDG');

Parameter PBI_CO2_Adjustment(Technologies);
         PBI_CO2_Adjustment(AvailableSGIPTechnologies)$(CO2_emission_rate(AvailableSGIPTechnologies) gt 0.417) = 0;
         PBI_CO2_Adjustment(AvailableSGIPTechnologies)$((CO2_emission_rate(AvailableSGIPTechnologies) gt 0.398) and (CO2_emission_rate(AvailableSGIPTechnologies) le 0.417)) = 0.5;
         PBI_CO2_Adjustment(AvailableSGIPTechnologies)$(CO2_emission_rate(AvailableSGIPTechnologies) le 0.398) = 1;

*turn off CHP
    GenConstraints(TECHNOLOGIES,'MaxAnnualHours')$((OptionsTable('CHP','OptionValue')  eq 1) and (deropt(TECHNOLOGIES,'chpenable')=1))=0;

*turn off absorption chiller
    GenConstraints(TECHNOLOGIES,'MaxAnnualHours')$((OptionsTable('CHP','OptionValue')  eq 1) and (deropt(TECHNOLOGIES,'coolenable')=1))=0;

* turn on the central chiller in the do-nothing case
OptionsTable ('CentralChiller','OptionValue')$(OptionsTable ('ContinuousInvest','OptionValue') eq 0 and OptionsTable ('DiscreteInvest ','OptionValue') eq 0  )  =1;
OptionsTable ('CentralChiller','OptionValue')$(ContinuousVariableForcedInvest ('AirSourceHeatPump','ForcedInvest') eq 1 and ContinuousVariableForcedInvest ('AirSourceHeatPump','ForcedInvestCapacity') eq 0 and ContinuousVariableForcedInvest ('GroundSourceHeatPump','ForcedInvest') eq 1 and ContinuousVariableForcedInvest ('GroundSourceHeatPump','ForcedInvestCapacity') eq 0)=1;

*adjust capital costs
DEROPT(TECHNOLOGIES, 'capcost')$(OptionsTable('VaryPrice','OptionValue') eq DEROPT(TECHNOLOGIES,'type'))
                          =  DEROPT(TECHNOLOGIES, 'capcost')
                             *
                             (1 + ParameterTable('turnvar','ParameterValue'));

* SprintCap
* If value SprintCap of table deropt = 0 --> assign maxp
* This procedure avoids optimization problems

deropt(TECHNOLOGIES,'sprintcap')$(deropt(TECHNOLOGIES,'sprintcap') =0) = deropt(TECHNOLOGIES,'maxp');


Parameter NetmeteringOnOff;
NetmeteringOnOff=0;
NetmeteringOnOff $ ((OptionsTable ('NetMetering','OptionValue') eq 1) and (OptionsTable ('Sales','OptionValue') eq 1)) =1;

Parameter InvestmentConstOnOff;
InvestmentConstOnOff=1000000;
InvestmentConstOnOff $ (OptionsTable ('InvestmentConst','OptionValue') eq 1)  =1;


********************************************************************************
********************  ANNUITY RATES FOR ALL DER  *******************************
********************************************************************************

Parameter AnnuityRate_DiscTech (Technologies);
Parameter AnnuityRate_ContTech (ContinuousInvestType);
Parameter AnnuityRate_NGChill  (NGChillTech);
Parameter AnnuityRate_StaticSwitch;

*To avoid an error due to missing input data
DEROPT(TECHNOLOGIES,'lifetime')$(DEROPT(TECHNOLOGIES,'lifetime')=0) = 1;
AnnuityRate_DiscTech (Technologies)
     = ParameterTable('IntRate','ParameterValue')
             / ( 1 - 1 / ( 1 + ParameterTable('IntRate','ParameterValue') ) ** DEROPT(TECHNOLOGIES,'lifetime') );

AnnuityRate_ContTech (ContinuousInvestType)
     = ParameterTable('IntRate','ParameterValue')
             / ( 1 - 1 / ( 1 + ParameterTable('IntRate','ParameterValue') ) ** ContinuousInvestParameter(ContinuousInvestType,'lifetime'));

AnnuityRate_NGChill(NGChillTech)
     = ParameterTable('IntRate','ParameterValue')
       / ( 1 - 1 / ( 1 + ParameterTable('IntRate','ParameterValue') ) ** NGChiller(NGChillTech,'lifetime') );

AnnuityRate_StaticSwitch
     = ParameterTable('IntRate','ParameterValue')
       / ( 1 - 1 / ( 1 + ParameterTable('IntRate','ParameterValue') ) ** StaticSwitchParameter('lifetime'));

*25/10/2014    José this is changed
***********************************************************
*******   ELECTRIC VEHICLES CONSTRAINTS  ******************
***********************************************************
*2013/03. Lenaig added a year index to all variables and equations in this section about EVs.

* All units for energy are measured in kWh
* Capacity of batteries is also measured in kWh

Positive Variables
     Electricity_FromEVs(years,months,daytypes,hours)
     ElectricityStoredEVs(years,months,daytypes,hours)
     ElectricityStorageEVsInput(years,months,daytypes,hours)
     ElectricityStorageEVsOutput(years,months,daytypes,hours)
     ElectricityStorageEVsLosses(years,months,daytypes,hours)
     ElectricityForStorageEVs(years,months,daytypes,hours);

Binary Variables
     BinaryCharge(years,months,daytypes,hours)
     BinaryDischarge(years,months,daytypes,hours);

*These Constraints makes sure that now charging and discharging is
*conducted at the same time
Equation EitherChargeXOrDischarge_Eq(years,months,daytypes,hours);
     EitherChargeXOrDischarge_Eq(years,months,daytypes,hours)..
     BinaryCharge(years,months,daytypes,hours)
     =E=
     (1 - BinaryDischarge(years,months,daytypes,hours));

Equation XORDischargeEVs_Eq(years,months,daytypes,hours);
     XORDischargeEVs_Eq(years,months,daytypes,hours)..
     Electricity_FromEVs(years,months,daytypes,hours)
     =L= BinaryDischarge(years,months,daytypes,hours) * 1000000;

Equation EitherChargeEVs_Eq(years,months,daytypes,hours);
     EitherChargeEVs_Eq(years,months,daytypes,hours)..
     ElectricityForStorageEVs(years,months,daytypes,hours)
     =L= BinaryCharge(years,months,daytypes,hours) * 1000000;

*The most important constraint for SOC
*measured in kWh
Equation ElectricityStoredEVsEq (years,months,daytypes,hours);
     ElectricityStoredEVsEq(years,months,daytypes,hours)..
     ElectricityStoredEVs(years,months,daytypes,hours)
     =E=
     (ElectricityStoredEVs(years,months,daytypes,hours--1)
     +
     ElectricityStorageEVsInput(years,months,daytypes,hours)
     -
     ElectricityStorageEVsOutput(years,months,daytypes,hours)
     -
     ElectricityStorageEVsLosses(years,months,daytypes,hours));

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
*measured in kWh

* In DER-CAM, in the most favorable cases, the hourly output can reach this capacity.
*2013/05/31. Lenaig added the variable 'TotalCapacityInYearY(ContinuousInvestType,years)'. It refers to the sum of the installed capacities that are available in a given year.
POSITIVE VARIABLE TotalCapacityInYearY(ContinuousInvestType,years);

Equation ElectricityStoredEVsLowerBoundaryEq (years,months,daytypes,hours);
     ElectricityStoredEVsLowerBoundaryEq(years,months,daytypes,hours)..
     ElectricityStoredEVs(years,months,daytypes,hours)
     =G=
     TotalCapacityInYearY('EVs1',years)*MinimumStateofChargeEVs(years,months,daytypes,hours);

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
*measured in kWh
Equation ElectricityStoredEVsUpperBoundaryEq (years,months,daytypes,hours);
     ElectricityStoredEVsUpperBoundaryEq(years,months,daytypes,hours)..
     ElectricityStoredEVs(years,months,daytypes,hours)
     =L=
     TotalCapacityInYearY('EVs1',years)*MaximumStateofChargeEVs(years,months,daytypes,hours);

*measured in kWh
Equation ElectricityStorageEVsInputEq(years,months,daytypes,hours);
     ElectricityStorageEVsInputEq(years,months,daytypes,hours)..
     ElectricityStorageEVsInput(years,months,daytypes,hours)
     =E=
     ElectricityForStorageEVs(years,months,daytypes,hours)
     *ElectricityStorageEVParameter('EfficiencyCharge');

*measured in kWh
Equation Electricity_FromEVsEq(years,months,daytypes,hours);
     Electricity_FromEVsEq(years,months,daytypes,hours)..
     Electricity_FromEVs(years,months,daytypes,hours)
     =E=
     (ElectricityStorageEVsOutput(years,months,daytypes,hours)
     *ElectricityStorageEVParameter('EfficiencyDischarge'))
     ;

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
*measured in kWh
Equation ElectStorageEVsChargingRateEq(years,months,daytypes,hours);
     ElectStorageEVsChargingRateEq(years,months,daytypes,hours)..
     ElectricityStorageEVsInput(years,months,daytypes,hours)
     =L=
     (TotalCapacityInYearY('EVs1',years)
     * ((BinaryEVsConnectionTable(years,months,daytypes,hours)-1)*(-1))
     )
     +
     (TotalCapacityInYearY('EVs1',years)* ElectricityStorageEVParameter('MaxChargeRate'))
     * BinaryEVsConnectionTable(years,months,daytypes,hours)
     ;

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
*measured in kWh
Equation ElectStorageEVsDischargingRateEq(years,months,daytypes,hours);
     ElectStorageEVsDischargingRateEq(years,months,daytypes,hours)..
     ElectricityStorageEVsOutput(years,months,daytypes,hours)
     =L=
     (TotalCapacityInYearY('EVs1',years)
     * ((BinaryEVsConnectionTable(years,months,daytypes,hours)-1)*(-1))
     )
     +
     (TotalCapacityInYearY('EVs1',years) * ElectricityStorageEVParameter('MaxDischargeRate'))
     * BinaryEVsConnectionTable(years,months,daytypes,hours)
     ;

*measured in kWh
Equation ElectricityStorageEVsLossesEq(years,months,daytypes,hours);
     ElectricityStorageEVsLossesEq(years,months,daytypes,hours)..
     ElectricityStorageEVsLosses(years,months,daytypes,hours)
     =E=
     (ElectricityStoredEVs(years,months,daytypes,hours--1)
     *(ElectricityStorageEVParameter('SelfDischarge')))
     ;

Variable NetEVOutput(years,months,daytypes,hours);

Variables
         EVsElectricityFromHome(years,months,daytypes)
         EVsElectricityFromHome_without_eff(years,months,daytypes)
*Hourly electricity consumed by the car to charge at home.
*Can also be negative: the energy will either be given back to the house,
*or will be consumed during driving, and thus displacing home electricity consumption in each case
* Assumed hourly constant consumption over the whole charging period (slow charge, better for battery life)
       ;

*2013/05/31. Lenaig calculated of the present value.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Variable ElectricVehicleBilling(years,months);
*2013/05/31. Lenaig calculated the present value of 'ElectricVehicleBilling(years,months)' later in the equation that determines the 'ElectricVehicleBilling' value.

Equation ElectricVehicleBilling_Eq(years,months);
*payment (positive or negative) for electricity exchanged between car and building
*bill based on kWh of electricity only, does not consider fixed yearly amount (based on battery capacity) *nor battery degradation compensation
ElectricVehicleBilling_Eq(years,months)..
     ElectricVehicleBilling(years,months)
*measured in $
     =E=
         sum (   (daytypes), numberofdays(months,daytypes) *
                 sum (   (hours)$(ord(hours)<=ElectricityStorageEVParameter('EndHomeCharge') or ord(hours)>=ElectricityStorageEVParameter('BeginingHomeCharge')),
                 EVsElectricityFromHome(years,months,daytypes)
*OLIVIER : EH instead of netEVOuput
*NetEVOutput(months,daytypes,hours)
              )       )
          *Electricity_Exchange_EV('P_EX_Vehicle')
*P_EX_Vehicle measured in $/kWh
         *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     ;

*measured in kWh
Equation NetEVOutput_Eq(years,months,daytypes,hours);
     NetEVOutput_Eq(years,months,daytypes,hours)..
     NetEVOutput(years,months,daytypes,hours)
     =E=
     BinaryEVsConnectionTable(years,months,daytypes,hours)
     *
     (Electricity_FromEVs(years,months,daytypes,hours)
      -
      ElectricityForStorageEVs(years,months,daytypes,hours))
     ;

Variable EV_Payment(years,months,daytypes,hours);

*2013/06/06. Lenaig calculated of the present value and modified 'ElectricVehicleBilling' to consider the total capacity available in the year considered.
Equation EV_Payment_Eq(years,months,daytypes,hours);
      EV_Payment_Eq(years,months,daytypes,hours)..
      EV_Payment(years,months,daytypes,hours)
*measured in $
      =E=
      (ContinuousInvestParameter('EVs1','VariableCost')
*measured in $/kWh
         * TotalCapacityInYearY('EVs1',years)
*measured in kWh
       )
       *(ContinuousInvestParameter('EVs1','Lifetime')
*Olivier : why is that needed?
*measured in years
            /8760 )
       +
       EVsElectricityFromHome(years,months,daytypes)$(ord(hours)<=ElectricityStorageEVParameter('EndHomeCharge') or ord(hours)>=ElectricityStorageEVParameter('BeginingHomeCharge'))
       *
*OLIVIER : EH instead of netEVOuput
      (Electricity_Exchange_EV('P_EX_Vehicle')
       - Electricity_Exchange_EV('P_Offsite_Access') )
* OLIVIER : this Offsite Access should be removed!
*both P_Offsite_Access and P_EX_Vehicle measured in $/kWh
*
*2013/05/31. Lenaig ccalculated of the present value.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
       *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
       ;

Variable Yearly_EV_Payment(years);
* OLIVIER : removed "positive"

*All measured in $
Equation Yearly_EV_Payment_Eq(years);
         Yearly_EV_Payment_Eq(years)..
         Yearly_EV_Payment(years)
         =E=
         sum( (months),
                 sum (   (daytypes), numberofdays(months,daytypes) *
                         sum (   (hours),
                         EV_Payment(years,months,daytypes,hours)
         )       )       );


*All measured in $
Equation Yearly_EV_Payment_Eq2(years);
         Yearly_EV_Payment_Eq2(years)..
         Yearly_EV_Payment(years)
         =G=0;


*************************  FIXED COST CALCULATIONS  *******************************
* Computation of Contract Demand: max potential electric load to utility
*2013/03. Lenaig added a year index to 'ContractDemand', 'ContractCost' and 'MonthlyCharge'.

 ContractDemand (years)
        =
       smax ( (months,daytypes,hours), load(years,'electricity-only',months,daytypes,hours)
        + load(years,'cooling',months,daytypes,hours)+ load(years,'refrigeration',months,daytypes,hours));

*2013/05/31. Lenaig calculated the present value of 'ContractCost'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
*2014/10/25 José change contract cpacity to incorporate the possibility of PV to reduce it
*ContractCost(years,months)
*        =
*        ContractDemand(years)*ParameterTable('Contrct','ParameterValue')
*        * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
*        ;
*2014/25/10 José This has been changed of position.
Positive Variables
     ElectricityProvided (years,months, daytypes,hours)
     Electricity_Generation(years,months,daytypes,hours)
     Electricity_Generation_Technology(TECHNOLOGIES,years,months,daytypes,hours)
     Electricity_Photovoltaics(years,months,daytypes,hours)
     Electricity_FromStationaryBattery(years,months,daytypes,hours)
     Electricity_FromFlowBattery(years,months,daytypes,hours)
     EnergyFlowFromBuildingToStationaryStorage (years, months, daytypes, hours)
     EnergyFlowFromStationaryStorageToBuilding (years, months, daytypes, hours)
     EnergyFlowFromStationaryStorageToNetwork (years, months, daytypes, hours)
*2015/01/21 Dani moved EnergyFlow
*2015/06/11 Dani defined EnergyFlowFromStationaryStorageToNetwork
     ;

* kW

*2013/03. Lenaig added a year index.
Positive Variable Electricity_Purchase(years,months, daytypes,hours);
Binary Variable PurchaseOrSale(years,months,daytypes,hours);
Equation PurchaseEq(years,months,daytypes,hours);
     PurchaseEq(years,months,daytypes,hours)..
     Electricity_Purchase(years,months,daytypes,hours)
     =L=
     PurchaseOrSale(years,months,daytypes,hours)*1000000;

Equation ElectricityProvidedEq (years,months,daytypes,hours);
     ElectricityProvidedEq(years,months,daytypes,hours)..
     ElectricityProvided (years,months,daytypes,hours)
     =E=
     Electricity_Purchase(years,months,daytypes,hours)
     +
     Electricity_Generation(years,months,daytypes,hours)
     +
     Electricity_Photovoltaics(years,months,daytypes,hours)
     +
     EnergyFlowFromStationaryStorageToBuilding(years,months,daytypes,hours)
*2015/01/21 Dani changed Electricity_FromStationaryBattery by EnergyFlowFromStationaryStorageToBuilding
     +
     EnergyFlowFromStationaryStorageToNetwork(years,months,daytypes,hours)
*2015/06/11 Dani added EnergyFlowFromStationaryStorageToNetwork
     +
     BinaryEVsConnectionTable(years,months,daytypes,hours)
     *
     Electricity_FromEVs(years,months,daytypes,hours)
     +
     Electricity_FromFlowBattery(years,months,daytypes,hours)
     ;

* VARIABLE DECLARATIONS

*2013/03. Lenaig added a year index to the following positive variables.
Positive VARIABLES
    Generation_Use   (TECHNOLOGIES, years, months, daytypes, hours)    DER generation up to the load (kW)
    Generation_Sell   (TECHNOLOGIES, years, months, daytypes, hours)   DER generation to sell        (kW)
    Electricity_PV_Export (years,months,daytypes,hours)                Electricity sales from PV      (kW)
    Electricity_PV_Onsite (years,months,daytypes,hours)                Electricity from PV for onsite use     (kW)
    AnnualElectricitySales (years)                                     Energy Sales                   ($)
    TotalElectricitySales (years)                                      Energy Sales                   (kWh)
    NGforDER_ElectricityProduction(years)            Annual Electricity from NG DER (kWh)
    NGforDER_ConsumedEnergy (years)                  Annual NG consumed for DER (kWh) if 0 set to 1
    DailyDemandCost(years)                           Annual cost of daily demand charges (kW)
    AllPeriodSavings                                 Base case annual costs (annualized) - DER-CAM solution cost ($)
    HeatingFromASHeatPump(years,months,daytypes,hours)
    CoolingFromASHeatPump(years,months,daytypes,hours)
    HeatingFromGSHeatPump(years,months,daytypes,hours)
    CoolingFromGSHeatPump(years,months,daytypes,hours)

* Variables characteristics
*2013/05/31. Lenaig  - added a year index to DER_Investment, DER_CurrentlyOperating, Capacity, Purchase, SwitchPurchase, NGChillPurchQuantity in order to consider potential consecutive investments.
*                    - renamed 'Capacity(ContinuousInvestType)' as 'CapacityAddedInYearY(ContinuousInvestType, years)' which refers to the capacity installed in a given year.
*
INTEGER VARIABLE DER_Investment(Technologies, years), DER_CurrentlyOperating(Technologies,years,months,daytypes,hours);
POSITIVE VARIABLE CapacityAddedInYearY(ContinuousInvestType,years);
* PV and solar thermal capacities refer to the peak output power,
* i.e. the output that can be obtain under specific test conditions (solar radiation of
* 1000W/m^2 and ambient temperature of 25C).


BINARY VARIABLE Purchase(ContinuousInvestType,years);
BINARY VARIABLE SwitchPurchase(years);
INTEGER VARIABLE NGChillPurchQuantity(NGChillTech,years);

*2013/03. Lenaig added a year index to these variables.
Positive Variable DemandResponse(DemandResponseType,years,months,daytypes,hours);
Binary variable DemandResponseOnOff(DemandResponseType,years,months,daytypes,hours);

Positive Variable DemandResponseHeating(DemandResponseType,years,months,daytypes,hours);
Binary variable DemandResponseOnOffHeating(DemandResponseType,years,months,daytypes,hours);


Positive Variable ElectricSales(years,months,daytypes,hours);


positive Variable LoadReduction (years,months,daytypes,hours);
positive Variable LoadIncrease (years,months,daytypes,hours);
Binary Variable ReductionOrAddition(years,months,daytypes,hours);
*

*2013/05/31. Lenaig added a year index to this equation.
Equation ContinuousPurchaseConstraintEq(ContinuousInvestType,years);
     ContinuousPurchaseConstraintEq(ContinuousInvestType,years)..
     CapacityAddedInYearY(ContinuousInvestType,years)
     =L=
     Purchase(ContinuousInvestType,years)*100000;

*2013/06/06. Lenaig added an equation to define 'TotalCapacityInYearY(ContinuousInvestType,years)'.
*The counter 'years_counter' is used to sum all the available capacities that might have been installed in different years.
*The capacities are not summed once the technologies reach their lifetime.
Equation DefineTotalCapacity_ContTech_Eq (ContinuousInvestType,years);
     DefineTotalCapacity_ContTech_Eq (ContinuousInvestType,years)..
     TotalCapacityInYearY(ContinuousInvestType,years)
     =E=
     sum(years_counter $(years_counter.val le ContinuousInvestParameter(ContinuousInvestType,'lifetime')),
           CapacityAddedInYearY(ContinuousInvestType,years-(years_counter.val-1))
     );

*2013/05/31. Lenaig added a year index to NumBatts and DiscreteElecStorage.
INTEGER VARIABLE NumBatts(years);
Equation DiscreteElecStorageEq(years);
         DiscreteElecStorageEq(years)..
         CapacityAddedInYearY('ElectricStorage',years)$(Optionstable('DiscreteElecStorage','optionvalue')=1)=E= NumBatts(years)*ElectricityStorageStationaryParameter('DiscreteSize');

*2013/03. Lenaig added a year index.
Equation DemandResponseonOffEq(DemandResponseType,years,months,daytypes,hours);
     DemandResponseonOffEq(DemandResponseType,years,months,daytypes,hours)..
     DemandResponse(DemandResponseType,years,months,daytypes,hours)
     =L=
     DemandResponseonOff(DemandResponseType,years,months,daytypes,hours)*100000;

*2013/03. Lenaig added a year index.
Equation DemandResponseonOffHeatingEq(DemandResponseType,years,months,daytypes,hours);
     DemandResponseonOffHeatingEq(DemandResponseType,years,months,daytypes,hours)..
     DemandResponseHeating(DemandResponseType,years,months,daytypes,hours)
     =L=
     DemandResponseOnOffHeating(DemandResponseType,years,months,daytypes,hours)*100000;



*2013/03. Lenaig added a year index.
Equation SaleEq(years,months,daytypes,hours);
     SaleEq(years,months,daytypes,hours)..
     ElectricSales(years,months,daytypes,hours)
     =L=
     (1-PurchaseOrSale(years,months,daytypes,hours))*1000000;

Positive variable ContractCapacity(years,months)
                  EnergyFlowFromISOToBattery (years, months, daytypes, hours)
                  EnergyFlowFromBatteryToISO (years, months, daytypes, hours);

Equation ContractCapacity_Eq (years,months,daytypes,hours);
     ContractCapacity_Eq (years,months,daytypes,hours)..
     ContractCapacity(years,months)
     =G=
     (
     Electricity_Purchase(years,months,daytypes,hours)
     -
     sum(AvailableTECHNOLOGIES,Generation_Sell(AvailableTECHNOLOGIES,years,months,daytypes,hours))
     -
     EnergyFlowFromStationaryStorageToNetwork(years,months,daytypes,hours)
     -
     EnergyFlowFromBatteryToISO(years,months,daytypes,hours)
     +
     EnergyFlowFromISOToBattery(years,months,daytypes,hours)
     -
     Electricity_PV_Export(years,months,daytypes,hours)
     )
     ;
*2015/02/05 Dani found a possible error in the ContractCapacity_Eq and change -Electricity_Photovoltaics to -Electricity_Photovoltaics-sum(AT,Generation_Use+Generation_Sell)-Energy_FromStationaryStorage
*2015/06/11 Dani added EnergyFlowFromStationaryStorageToNetwork

Positive variable ContractCost(years,months);
Equation ContractCost_Eq(years,months);
ContractCost_Eq(years,months)..
        ContractCost(years,months) =E=
        ContractCapacity(years,months)*ParameterTable('Contrct','ParameterValue')*ExchangeRate*(1+Taxes+Elect_tax)
        * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
        ;

Parameter MonthlyCharge;
MonthlyCharge (years, months, service) = MonthlyFee (years, service);

*******************************************
**  INCLUDE THE MASTER INCLUDE LIST  ******
*******************************************

*because tariff files were written long ago and names have since changed
*these a little bit of fudging right here

* used?
$ontext
set TariffParameterOption /Standby , Contrct , CO2Tax , MktCRate , macroeff , MinEffic/  ;
set TariffParameterDummy /ParameterValue/ ;
$offtext

parameter CO2Tax;
CO2Tax = ParameterTable ('CO2Tax', 'ParameterValue') ;
*tax in dollars per metric ton CO2

parameter NoInvestEnergyCost;
NoInvestEnergyCost = 999999999;
*($/year) for no invest case
parameter NoInvestElectricity;
NoInvestElectricity = 999999999;
*(kWh/year) for no invest case
parameter NoInvestNG;
NoInvestNG = 9999999999;
*(kWh/year) for no invest case


* reset internal CO2tax value
* only if CO2tax from table OptionsTable = 1
ParameterTable('CO2Tax','ParameterValue')$(OptionsTable('CO2tax','OptionValue')     eq 1) = CO2Tax;
ParameterTable('CO2Tax','ParameterValue')$(OptionsTable('CO2tax','OptionValue')     eq 0) = 0;

*determine the static switch size (estimate since it can change by the optimization results!)
*2013/03. Lenaig added a year index.
Parameter TotalELoad (years,months,daytypes,hours);
TotalELoad(years,months,daytypes,hours) =
     Load(years,'electricity-only',months,daytypes,hours)
     + Load(years,'cooling',months,daytypes,hours) + Load(years,'refrigeration',months,daytypes,hours) ;

Parameter SwitchSize;
*2013/03. Lenaig modified the assignment of the parameter 'SwitchSize' to screen total electricity load over all the years and find its minimum and its maximum.
SwitchSize = smin((years,months,daytypes,hours),TotalELoad(years,months,daytypes,hours))*ParameterTable ('FractionbaseLoad', 'ParameterValue')
+(smax((years,months,daytypes,hours),TotalELoad(years,months,daytypes,hours))-smin((years,months,daytypes,hours),TotalELoad(years,months,daytypes,hours)))*ParameterTable ('FractionPeakLoad', 'ParameterValue') ;
SwitchSize$((OptionsTable('switchinvest','OptionValue')  eq 0) )=0;


* ---------------------


* -------------------

* FIXED VARIABLE VALUES
*General note
*.fx fixes a variable
*.lo sets a lower limit
*.up sets an upper limit
* If no investment is allowed...
*2013/05/31. Lenaig added a year index.
DER_Investment.up(TECHNOLOGIES,years)                $(OptionsTable('DiscreteInvest','OptionValue') eq 0)   = 0;
CapacityAddedInYearY.up(ContinuousInvestType,years)  $(OptionsTable('ContinuousInvest','OptionValue') eq 0) = 0;
NGChillPurchQuantity.up(NGChillTech,years)           $(OptionsTable('NGChillInvest','OptionValue') eq 0)    = 0;
SwitchPurchase.up(years)                             $(OptionsTable('SwitchInvest','OptionValue') eq 0)     = 0;

*Disallow negative purchase amounts
*2013/05/31. Lenaig added a year index.
DER_Investment.lo(TECHNOLOGIES,years)                = 0;
CapacityAddedInYearY.lo(ContinuousInvestType,years)  = 0;
NGChillPurchQuantity.lo(NGChillTech,years)           = 0;

*If fixed purchase option is selected,
*fix all DER_Investment variables as defined in GenConstraints(TECHNOLOGIES, 'ForcedInvest')
*TK want a binary switch, too.

*TK would solutions be faster if integer variables had an upper limit (say five or ten)?

*2013/05/31. Lenaig added a year index to these equations.
*It means that if 'ForcedInvest = 1' for a given technology, there will be an investment every year in that technology.
*The size or quantity installed each year will be the one specified by the user.

*****    DISCRETE VARIABLE FORCED INVEST  ******
*DER_Investment.fx(TECHNOLOGIES,years)
DER_Investment.fx(TECHNOLOGIES,'1')
     $
     (GenConstraints(TECHNOLOGIES, 'ForcedInvest') eq 1)
     =
     GenConstraints(TECHNOLOGIES, 'ForcedNumber');
DER_Investment.fx(TECHNOLOGIES,'2')
     $
     (GenConstraints(TECHNOLOGIES, 'ForcedInvest') eq 1)
     =
     0;
DER_Investment.fx(TECHNOLOGIES,'3')
     $
     (GenConstraints(TECHNOLOGIES, 'ForcedInvest') eq 1)
     =
     0;
DER_Investment.fx(TECHNOLOGIES,'4')
     $
     (GenConstraints(TECHNOLOGIES, 'ForcedInvest') eq 1)
     =
     0;
DER_Investment.fx(TECHNOLOGIES,'5')
     $
     (GenConstraints(TECHNOLOGIES, 'ForcedInvest') eq 1)
     =
     0;
*2015/03/01 Dani changed this statement so now it only forces the investment in the first year. From DER_Investment.fx(TECHNOLOGIES,years) to DER_Investment.fx(TECHNOLOGIES,'1')

*****   NG DIRECT FIRED CHILLER FORCED INVEST   ******
NGChillPurchQuantity.fx(NGChillTech,years)$
     (NGChillForcedInvest (NGChillTech, 'ForcedInvest') eq 1)
     =
     NGChillForcedInvest (NGChillTech, 'ForcedInvestQuantity');

*****    CONTINUOUS VARIABLE FORCED INVEST  ******
*CapacityAddedInYearY.fx(ContinuousInvestType,years)
CapacityAddedInYearY.fx(ContinuousInvestType,'1')
     $
     (ContinuousVariableForcedInvest(ContinuousInvestType,'ForcedInvest') = 1)
     =
     ContinuousVariableForcedInvest(ContinuousInvestType,'ForcedInvestCapacity');
CapacityAddedInYearY.fx(ContinuousInvestType,'2')
     $
     (ContinuousVariableForcedInvest(ContinuousInvestType,'ForcedInvest') = 1)
     =
     0;
CapacityAddedInYearY.fx(ContinuousInvestType,'3')
     $
     (ContinuousVariableForcedInvest(ContinuousInvestType,'ForcedInvest') = 1)
     =
     0;
CapacityAddedInYearY.fx(ContinuousInvestType,'4')
     $
     (ContinuousVariableForcedInvest(ContinuousInvestType,'ForcedInvest') = 1)
     =
     0;
CapacityAddedInYearY.fx(ContinuousInvestType,'5')
     $
     (ContinuousVariableForcedInvest(ContinuousInvestType,'ForcedInvest') = 1)
     =
     0;
CapacityAddedInYearY.fx('FlowBatteryEnergy',years)=0;
CapacityAddedInYearY.fx('FlowBatteryPower',years)=0;
CapacityAddedInYearY.fx('SolarThermal',years)=0;
*2015/03/01 Dani changed this statement so now it only forces the investment in the first year. From CapacityAddedInYearY.fx(ContinuousInvestType,years) to CapacityAddedInYearY.fx(ContinuousInvestType,'1')

*****    STATIC SWITCH FORCED INVEST  ******
SwitchPurchase.fx(years)$ (StaticSwitchParameter('ForcedInvest') = 1)
     =     1;

*2013/03. Lenaig added a year index.
*If selling of electricity is not an option
Generation_Sell.up(TECHNOLOGIES, years, months, daytypes, hours)$((OptionsTable('Sales','OptionValue') eq 0) or (DEROPT(TECHNOLOGIES,'AllowFeedIn') eq 0)) = 0;
Electricity_PV_Export.up(years, months, daytypes, hours)$((OptionsTable('Sales','OptionValue') eq 0) or (OptionsTable('PVSales','OptionValue') eq 0)) = 0;
EnergyFlowFromStationaryStorageToNetwork.up(years,months,daytypes,hours)$((OptionsTable('Sales','OptionValue') eq 0) or (OptionsTable('BatterySales','OptionValue') eq 0))=0;
*2015/06/11 Dani included EnergyFlowFromStationaryStorageToNetwork adjustment

*************************************************************************
*--------------------   ELECTRICITY COSTS   -----------------------------
*************************************************************************
*2013/03. Lenaig added a year index to all variables and equations in this section about electricity costs.

Positive Variable ElectricFixedCost(years,months);
*2013/05/31. Lenaig calculated the present value of 'ElectricFixedCost'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation ElectricFixedCost_Eq (years,months);
     ElectricFixedCost_Eq  (years,months) ..
     ElectricFixedCost(years,months)
     =E=
     MonthlyFee(years,'UtilElectric')
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     ;

Positive Variable StandbyCost (years,months);
*2013/05/31. Lenaig calculated the present value of 'StandbyCost' and replaced 'DER_Investment (AvailableTECHNOLOGIES)' by the sum of 'DER_Investment (AvailableTECHNOLOGIES, years_counter)'.
*            The counter 'years_counter' is used to sum all the available capacities that might have been installed in different years.
*            The capacities are not summed once the technologies reach their lifetime.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".

Equation StandbyCostEq (years,months);
     StandbyCostEq(years,months)..
     StandbyCost(years,months)
     =E=
     sum(AvailableTECHNOLOGIES,
         sum(years_counter $(years_counter.val le years.val),
                 DER_Investment (AvailableTECHNOLOGIES,years_counter)
                 * deropt (AvailableTECHNOLOGIES, 'maxp')
                 * ParameterTable('Standby','ParameterValue')
*2013/09/06. Lenaig. $-condition to be checked.
                 $(years_counter.val le deropt(AvailableTECHNOLOGIES, 'lifetime'))
         )
     ) * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

Positive Variable ElectricPurchTOU(years,months,daytypes,TimeOfDay);
Equation ElectricPurchTOUEq (years,months,daytypes,TimeOfDay);
     ElectricPurchTOUEq (years,months,daytypes,TimeOfDay)..
     ElectricPurchTOU (years,months,daytypes,TimeOfDay)
     =E=
     sum(hours$ (ord(TimeOfDay)= HoursByMonth(hours,months,daytypes)) ,
          Electricity_Purchase(years,months,daytypes,hours)*ElectricityRates (years, months,daytypes, hours)
          *NumberOfDays(months,daytypes)
        );

Positive Variable ElectricTOUCostByTOU (years,months, TimeOfDay);


Equation ElectricTOUCostByTOU_Eq (years,months, TimeOfDay);
     ElectricTOUCostByTOU_Eq (years,months, TimeOfDay) ..
     ElectricTOUCostByTOU (years,months, TimeOfDay)
     =E=
          sum(daytypes,  ElectricPurchTOU (years,months,daytypes,TimeOfDay)  )

     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     ;

Positive Variable ElectricTOUCost (years,months);
*2013/05/31. Lenaig. 'ElectricTOUCost(years,months)' is a present value as a sum of present values.
Equation ElectricTOUCost_Eq (years,months);
     ElectricTOUCost_Eq (years,months) ..
     ElectricTOUCost (years,months)
     =E=
     sum(TimeOfDay, ElectricTOUCostByTOU (years,months,TimeOfDay))
     ;

Positive Variable ElectricConsumption(years,months);
Equation ElectricConsumption_Eq(years,months);
     ElectricConsumption_Eq(years,months)..
     ElectricConsumption(years,months)
     =E=
     sum((hours,daytypes),
     Electricity_Purchase(years,months,daytypes,hours)*NumberOfDays(months,daytypes)
     );


**********************************************************************************************************************************
* Please note if you want consider PX prices for electricity purchase you have to include HourlyCostEq and AnnualHourlyCostEq at the sovler statement MODEL CUSTADOP
* Currently it is not used
* The PX price is used for electricity sales.
* TK red flag These equations should be included, but the price should be zero if excluded
$ontext
Positive Variable HourlyCost(months);
Positive Variable AnnualHourlyCost;

Equation HourlyCostEq(months);
HourlyCostEq(months)..
     HourlyCost(months)
     =E=
     sum( (daytypes,hours),
          Electricity_Purchase(months,daytypes,hours)
          *PX (months,daytypes,hours)
          *NumberOfDays(months,daytypes)
         );
$offtext

$ontext
Equation AnnualHourlyCostEq;
AnnualHourlyCostEq..  AnnualHourlyCost
     =E=
     sum(months, HourlyCost(months));
$offtext
**********************************************************************************************************************************

* DEMAND CHARGES
* DETERMINING MAXIMUM DEMAND

*2013/03. Lenaig added a year index to all variables and equations in this section about demand charges.

Positive Variable MaxDemandMonthly   (years,months,DemandType);

Equation MaxDemandMonthlyEq (years,hours,months,daytypes,DemandType);
     MaxDemandMonthlyEq (years,hours,months,daytypes,DemandType) ..
     MaxDemandMonthly (years,months,DemandType)
     =G=
*noncoincident
      Electricity_Purchase (years,months,daytypes,hours)$(ord(DemandType)= DemandValue('Noncoincident'))
      +
*coincident
      Electricity_Purchase (years,months,daytypes,hours)$(ord(DemandType)= DemandValue('coincident')
                                           and CoincidentHour(years,months) = ord(hours)
                                           and daytypesValue('weekend') <> ord (daytypes))
      +
*onpeak
      Electricity_Purchase (years,months,daytypes,hours)$(ord(DemandType)= DemandValue('Onpeak')
                                           and  OnHoursMonth (hours, months, daytypes))
     +
*midpeak
      Electricity_Purchase (years,months,daytypes,hours)$(ord(DemandType)= DemandValue('Midpeak')
                                           and MidHoursMonth (hours, months, daytypes))
     +
*offpeak
      Electricity_Purchase (years,months,daytypes,hours)$(ord(DemandType)= DemandValue('Offpeak')
                                           and OffHoursMonth (hours, months, daytypes));

Positive Variable ElectricDemandCostByType (years,months,DemandType);
*2013/05/31. Lenaig calculated the present value of 'ElectricDemandCostByType(years,months,DemandType)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation ElectricDemandCostByType_Eq (years,months,DemandType);
     ElectricDemandCostByType_Eq (years,months,DemandType) ..
     ElectricDemandCostByType(years,months,DemandType)
     =E=
     MaxDemandMonthly(years,months,DemandType)
     * MonthlyDemandRates(years,months,DemandType)
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     ;

Positive Variable ElectricDemandCost (years,months);
*2013/05/31. Lenaig. 'ElectricDemandCost(years,months)' is a present value as a sum of present values.
Equation ElectricDemandCost_Eq (years,months);
     ElectricDemandCost_Eq (years,months) ..
     ElectricDemandCost(years,months)
     =E=
     sum(DemandType, ElectricDemandCostByType(years,months,DemandType));


Positive Variable MaxDemandDaily   (years,months, daytypes,DemandType);
Equation MaxDemandDailyEq (hours,months,years,daytypes,DemandType);
     MaxDemandDailyEq (hours,months,years,daytypes,DemandType) ..
     MaxDemandDaily (years,months,daytypes,DemandType)
     =G=
*noncoincident
      Electricity_Purchase (years,months,daytypes,hours)$(ord(DemandType)= DemandValue('Noncoincident'))
      +
*coincident
      Electricity_Purchase (years,months,daytypes,hours)$(ord(DemandType)= DemandValue('coincident')
                                           and CoincidentHour(years,months) = ord(hours)
                                           and daytypesValue('weekend') <> ord (daytypes))
      +
*onpeak
      Electricity_Purchase (years,months,daytypes,hours)$(ord(DemandType)= DemandValue('Onpeak')
                                            and  OnHoursMonth (hours, months, daytypes))
     +
*midpeak
      Electricity_Purchase (years,months,daytypes,hours)$(ord(DemandType)= DemandValue('Midpeak')
                                           and  MidHoursMonth (hours, months, daytypes))
     +
*offpeak
      Electricity_Purchase (years,months,daytypes,hours)$(ord(DemandType)= DemandValue('Offpeak')
                                           and  OffHoursMonth (hours, months, daytypes))

Positive Variable DailyDemandCharge (years,months,daytypes,DemandType);
*2013/05/31. Lenaig calculated the present value of 'DailyDemandCharge(years,months,daytypes,DemandType)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation DailyDemandChargeEq (years, months, daytypes, DemandType);
     DailyDemandChargeEq (years, months, daytypes, DemandType) ..
     DailyDemandCharge(years, months,daytypes,DemandType)
     =E=
     MaxDemandDaily(years, months,daytypes,DemandType)
     *DailyDemandRates(years,months,DemandType)
     *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

Positive Variable ElectricDailyDemandCost(years,months);
*2013/05/31. Lenaig. 'ElectricDailyDemandCost(years,months)' is a present value as a sum of present values.
Equation ElectricDailyDemandCost_Eq(years,months);
     ElectricDailyDemandCost_Eq(years,months)..
     ElectricDailyDemandCost(years,months)
     =E=
     sum((daytypes,DemandType),
       DailyDemandCharge(years,months,daytypes,DemandType)
       * NumberOfDays(months,daytypes)
     );


*---TotalDailyDemandCharges
$ontext
Positive Variable AnnualDailyDemandCost;

Equation AnnualDailyDemandCostEq;
     AnnualDailyDemandCostEq..
     AnnualDailyDemandCost
     =E=
     sum((months, daytypes, DemandType), DailyDemandCharge(months,daytypes, DemandType));

Positive Variable AnnualMonthlyDemandCost;

Equation AnnualMonthlyDemandCostEq;
AnnualMonthlyDemandCostEq.. AnnualMonthlyDemandCost
     =E=
     sum((months, DemandType), MonthlyDemandCharge(months,DemandType));

$offtext

*Monthly Macrogrid CO2 Emissions
*2013/03. Lenaig added a year index to all variables and equations in this section about CO2 emissions.

Positive Variable ElectricCO2 (years,months);

Equation ElectricCO2_Eq (years,months);
     ElectricCO2_Eq(years,months)..
     ElectricCO2(years,months)
     =E=
     sum ((daytypes,hours),
          Electricity_Purchase(years,months,daytypes,hours)*HourlyMarginalCO2Emissions(months, hours)
          *NumberOfDays(months, daytypes)
          );

Positive Variable ElectricCO2Cost (years,months);

Variable CO2fromEVsHomeCharging(years,months);
Variable EVHomeElectricityCO2Cost(years,months);
*Olivier : 2 variables above added
*OLIVIER : not positive, as it can be a negative value if the car(+building) displaces home electricity

*2013/05/31. Lenaig calculated the present value of 'ElectricCO2Cost(years,months)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation ElectricCO2Cost_Eq (years,months);
     ElectricCO2Cost_Eq(years,months)..
     ElectricCO2Cost(years,months)
     =E=
     ElectricCO2(years,months)*ParameterTable('CO2Tax','ParameterValue')
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));


*2013/05/31. Lenaig calculated the present value of 'EVHomeElectricityCO2Cost(years,months)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation EVHomeElectricityCO2Cost_Eq (years,months);
         EVHomeElectricityCO2Cost_Eq (years,months)..
         EVHomeElectricityCO2Cost(years,months)
         =E=
         CO2fromEVsHomeCharging(years,months)*ParameterTable('CO2Tax','ParameterValue')
         * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

*2013/03. Lenaig added a year index to all variables and equations in this section about electric costs.
*
Variable RegulationTotalCost(years,months);
Variable YearlyBatteryDegradation(years);
Variable RegulationCapacityUpCost(years,months);
Variable RegulationCapacityDownCost(years,months);
Variable RegulationEnergyCost1(years,months);
Variable RegulationEnergyCost2(years,months);
Positive Variables
     ElectricityStorageStationaryCapacity(years,months)
     ElectricityForStorageStationary(years,months,daytypes,hours)
     DiscreteTechnologyRegulationUp (TECHNOLOGIES, years,months, daytypes, hours)
     DiscreteTechnologyRegulationDown (TECHNOLOGIES, years, months, daytypes, hours)
     CapacityBidRegulationDownBattery (years, months, daytypes, hours)
     CapacityBidRegulationDownDiscreteTechnology (TECHNOLOGIES, years, months, daytypes, hours)
     CapacityBidRegulationUpBattery (years, months, daytypes, hours)
     CapacityBidRegulationUpDiscreteTechnology (TECHNOLOGIES, years, months, daytypes, hours)
     ;

*2015/01/16 Dani moved ElectricityStorageStationaryCapacity, ElectricityForStorageStationary
*2015/01/22 Dani included DiscreteTechnologies

********Regulation Variables Adjustment*******
DiscreteTechnologyRegulationUp.up (TECHNOLOGIES,years,months,daytypes,hours)$(OptionsTable('Regulation','OptionValue')=0)=0;
DiscreteTechnologyRegulationDown.up (TECHNOLOGIES,years,months,daytypes,hours)$(OptionsTable('Regulation','OptionValue')=0)=0;
EnergyFlowFromISOToBattery.up(years,months,daytypes,hours)$(OptionsTable('Regulation','OptionValue')=0)=0;
EnergyFlowFromBatteryToISO.up(years,months,daytypes,hours)$(OptionsTable('Regulation','OptionValue')=0)=0;
CapacityBidRegulationDownDiscreteTechnology.up(TECHNOLOGIES,years,months,daytypes,hours)$(OptionsTable('Regulation','OptionValue')=0)=0;
CapacityBidRegulationUpDiscreteTechnology.up(TECHNOLOGIES,years,months,daytypes,hours)$(OptionsTable('Regulation','OptionValue')=0)=0;
CapacityBidRegulationDownBattery.up (years,months,daytypes,hours)$(OptionsTable('Regulation','OptionValue')=0)=0;
CapacityBidRegulationUpBattery.up (years,months,daytypes,hours)$(OptionsTable('Regulation','OptionValue')=0)=0;
*2015/02/02 Dani included Regulation Variables Adjustment to disable them if OptionTable('Regulation','OptionValue')=0

Equation YearlyBatteryDegradationEq(years);
      YearlyBatteryDegradationEq(years)..
      YearlyBatteryDegradation(years)
      =E=
      (ContinuousInvestParameter('ElectricStorage','FixedCost')
      *
      Electricity_Exchange_EV('Capacity_Loss_per_Normalized_Wh')
      *
      sum((months,daytypes,hours),(Electricity_FromStationaryBattery(years,months,daytypes,hours)+ElectricityForStorageStationary(years,months,daytypes,hours))*NumberOfDays(months,daytypes)))
      *
      5
*The 5 at the end is because 20% degradation is equivalent to a worthless battery
      *
      (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
      ;

Equation RegulationCapacityUpCostEq(years,months);
      RegulationCapacityUpCostEq(years,months)..
      RegulationCapacityUpCost(years,months)
      =E=
      sum((daytypes,hours),
      (CapacityBidRegulationUpBattery(years,months,daytypes,hours)
      +
      sum(AvailableTECHNOLOGIES,CapacityBidRegulationUpDiscreteTechnology(AvailableTECHNOLOGIES, years,months,daytypes, hours)))
      *RegulationCapacityUpPrice(years,months,daytypes,hours)*NumberOfDays(months,daytypes))
      *
      (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

Equation RegulationCapacityDownCostEq(years,months);
      RegulationCapacityDownCostEq(years,months)..
      RegulationCapacityDownCost(years,months)
      =E=
      sum((daytypes,hours),
      (CapacityBidRegulationDownBattery(years,months,daytypes,hours)
      +
      sum(AvailableTECHNOLOGIES,CapacityBidRegulationDownDiscreteTechnology(AvailableTECHNOLOGIES, years,months,daytypes, hours)))
      *RegulationCapacityDownPrice(years,months,daytypes,hours)*NumberOfDays(months,daytypes))
      *
      (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

Equation RegulationEnergyCost1Eq(years,months);
      RegulationEnergyCost1Eq(years,months)..
      RegulationEnergyCost1(years,months)
      =E=
      sum((daytypes,hours),
      (EnergyFlowFromBatteryToISO(years,months,daytypes,hours)
      +
      sum(AvailableTECHNOLOGIES, DiscreteTechnologyRegulationUp(AvailableTECHNOLOGIES, years, months, daytypes, hours)))
      *RegulationEnergyPrice(years,months,daytypes,hours)*NumberOfDays(months,daytypes))
      *
      (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

Equation RegulationEnergyCost2Eq(years,months);
      RegulationEnergyCost2Eq(years,months)..
      RegulationEnergyCost2(years,months)
      =E=
      sum((daytypes,hours),
      (EnergyFlowFromISOToBattery(years,months,daytypes,hours)
      +
      sum(AvailableTECHNOLOGIES, DiscreteTechnologyRegulationDown(AvailableTECHNOLOGIES, years, months, daytypes, hours)))
      *RegulationEnergyPricep(years,months,daytypes,hours)*NumberOfDays(months,daytypes))
      *
      (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

Equation RegulationTotalCostEq(years,months);
      RegulationTotalCostEq(years,months)..
      RegulationTotalCost(years,months)
      =E=
      RegulationEnergyCost2(years,months)
      -
      RegulationCapacityUpCost(years,months)
      -
      RegulationCapacityDownCost(years,months)
      -
      RegulationEnergyCost1(years,months)
      ;

*
*2015/01/15 Dani included regulation costs
*2015/01/22 Dani included discrete technologies regulation equations

Positive Variable ElectricTotalCost(years,months);
Equation ElectricTotalCost_Eq(years,months);
     ElectricTotalCost_Eq(years,months)..
     ElectricTotalCost(years,months)
     =E=
     ContractCost(years,months) +
     ElectricFixedCost(years,months) +
     StandbyCost(years,months) +
     ElectricTOUCost(years,months) +
     ElectricDemandCost(years,months) +
     ElectricDailyDemandCost(years,months) +
     ElectricCO2Cost(years,months)   +
     ElectricVehicleBilling(years,months) +
     EVHomeElectricityCO2Cost(years,months) +
     RegulationTotalCost(years,months)
*2015/01/15 Dani included RegulationTotalCost
     ;

* Annual Electricity costs
Positive Variable AnnualElectricCost(years);

Equation AnnualElectricCostEq(years);
     AnnualElectricCostEq(years) ..
     AnnualElectricCost(years)
     =E=
     sum(months,ElectricTotalCost(years,months));

* Annual Electricity Consumption
Positive Variable AnnualElectricConsumption(years);

Equation AnnualElectricConsumption_Eq(years);
         AnnualElectricConsumption_Eq(years)..
         AnnualElectricConsumption(years)
         =E=
         sum ((months,daytypes,hours),
          Electricity_Purchase(years,months,daytypes,hours)
          *NumberOfDays(months, daytypes)
          );

Positive Variable AnnualElectricCO2(years);

Equation AnnualElectricCO2_Eq(years);
     AnnualElectricCO2_Eq(years)..
     AnnualElectricCO2(years)
     =E=
     sum(months,ElectricCO2(years,months));


***************************************************************************************
*--------------------   NATURAL GAS CONSUMPTION/CO2/COST   -------------------------
***************************************************************************************
*2013/03. Lenaig added a year index to all variables and equations in this section about natural gas consumption, CO2 and cost.

*----------------  monthly consumption  -----------------------

*TK not sure where these first two declarations should go
Positive Variable NG_ForHeat(years,months,daytypes,hours);
Positive Variable NG_ForNGChill(years,months,daytypes,hours);
Positive Variable NG_ForDG(years,months,daytypes,hours);
Positive Variable NG_ForCHPDG(years,months,daytypes,hours);

Positive Variable Heat_FromStorage(years,months,daytypes,hours);

Positive Variable NGforDGConsumption (years,months);
Positive Variable NGforCHPDGConsumption (years,months);
Positive Variable NGforHeatConsumption (years,months);
Positive Variable NGforNGChillConsumption (years,months);
Positive Variable NGforNGOnlyLoadConsumption(years,months);
Positive Variable NGTotalConsumption (years,months);
Positive Variable Generation_NetworkSales(TECHNOLOGIES, years, months, daytypes, hours);
*2015/01/23 Dani included Generation_NetworkSales
Equation NG_ForCHPDG_Eq(years,months,daytypes,hours);
     NG_ForCHPDG_Eq(years,months,daytypes,hours)..
     NG_ForCHPDG(years,months,daytypes,hours)
     =E=
     sum((AvailableCHPTECHNOLOGIES)$(FuelValue('NGforDG')=(deropt(AvailableCHPTECHNOLOGIES,'fuel'))),
        Generation_Use(AvailableCHPTECHNOLOGIES,years,months,daytypes,hours)*(1/deropt(AvailableCHPTECHNOLOGIES,'efficiency')) )
        + sum((AvailableCHPTECHNOLOGIES)$(FuelValue('NGforDG')=(deropt(AvailableCHPTECHNOLOGIES,'fuel'))),
        Generation_Sell(AvailableCHPTECHNOLOGIES,years,months,daytypes,hours)*(1/deropt(AvailableCHPTECHNOLOGIES,'efficiency')) );

Equation NG_ForDG_Eq(years,months,daytypes,hours);
     NG_ForDG_Eq(years,months,daytypes,hours)..
     NG_ForDG(years,months,daytypes,hours)
     =E=
     sum((AvailableTECHNOLOGIES)$(FuelValue('NGforDG')=(deropt(AvailableTECHNOLOGIES,'fuel'))),
        Generation_Use(AvailableTECHNOLOGIES,years,months,daytypes,hours)*(1/deropt(AvailableTECHNOLOGIES,'efficiency')) )
        + sum((AvailableTECHNOLOGIES)$(FuelValue('NGforDG')=(deropt(AvailableTECHNOLOGIES,'fuel'))),
        Generation_Sell(AvailableTECHNOLOGIES,years,months,daytypes,hours)*(1/deropt(AvailableTECHNOLOGIES,'efficiency')) )
   ;

Equation NGforDGConsumption_Eq(years,months);
     NGforDGConsumption_Eq(years,months)..
     NGforDGConsumption(years,months)
     =E=
     sum((daytypes,hours), NG_ForDG(years,months,daytypes,hours)
         *NumberOfDays(months,daytypes));

Equation NGforCHPDGConsumption_Eq(years,months);
    NGforCHPDGConsumption_Eq(years,months)..
    NGforCHPDGConsumption(years,months)
    =E=
    sum((daytypes,hours), NG_ForCHPDG(years,months,daytypes,hours)*NumberOfDays(months,daytypes));

Equation NGforHeatConsumption_Eq(years,months);
     NGforHeatConsumption_Eq(years,months)..
     NGforHeatConsumption(years,months)
     =E=
     sum((daytypes,hours), NG_ForHeat(years,months,daytypes,hours)
         *NumberOfDays(months,daytypes));

Equation NGforNGChillConsumption_Eq(years,months);
     NGforNGChillConsumption_Eq(years,months)..
     NGforNGChillConsumption(years,months)
     =E=
     sum((daytypes,hours), NG_ForNGChill(years,months,daytypes,hours)
         *NumberOfDays(months,daytypes));

Parameters NaturalGasOnlyLoad(years,months,daytypes,hours);
         NaturalGasOnlyLoad(years,months,daytypes,hours) = Load(years,'naturalgas-only',months,daytypes,hours);

Equation NGforNGOnlyLoadConsumption_Eq(years,months);
         NGforNGOnlyLoadConsumption_Eq(years,months)..
         NGforNGOnlyLoadConsumption(years,months)
         =E=
         sum((daytypes,hours), NaturalGasOnlyLoad(years,months,daytypes,hours)
         *NumberOfDays(months,daytypes));

Equation NGTotalConsumption_Eq(years,months);
     NGTotalConsumption_Eq(years,months)..
     NGTotalConsumption(years,months)
     =E=
     NGforDGConsumption(years,months)
     + NGforHeatConsumption(years,months)
     + NGforNGChillConsumption(years,months)
     + NGforNGOnlyLoadConsumption(years,months);

*---------- monthly CO2 -------------------------------------------

Positive Variable CO2FromNG(years,months);
Positive Variable CO2FromDER(years,months);
Positive Variable CO2FromNonDER(years,months);
Positive Variable CO2FromChillers(years,months);
Positive Variable CO2FromNGOnlyLoad(years,months);

Equation CO2FromDER_Eq(years,months);
     CO2FromDER_Eq(years,months)..
     CO2FromDER(years,months)
     =E=
     NGforDGConsumption(years,months)*CO2EmissionsRate ('NGforDG');

Equation CO2FromNonDER_Eq(years,months);
     CO2FromNonDER_Eq(years,months)..
     CO2FromNonDER(years,months)
     =E=
     NGforHeatConsumption(years,months)*CO2EmissionsRate ('NGBasic');

Equation CO2FromChillers_Eq(years,months);
     CO2FromChillers_Eq(years,months)..
     CO2FromChillers(years,months)
     =E=
     NGforNGChillConsumption(years,months)*CO2EmissionsRate ('NGBasic');

Equation CO2FromNGOnlyLoad_Eq(years,months);
         CO2FromNGOnlyLoad_Eq(years,months)..
         CO2FromNGOnlyLoad(years,months)
         =E=
         NGforNGOnlyLoadConsumption(years,months)*CO2EmissionsRate ('NGBasic');

Equation CO2FromNG_Eq(years,months);
     CO2FromNG_Eq(years,months)..
     CO2FromNG(years,months)
     =E=
     CO2FromDER(years,months)+CO2FromNonDER(years,months)+CO2FromChillers(years,months)+CO2FromNGOnlyLoad(years,months);

*-------------------  monthly costs  -----------------------------
*2013/05/31. Lenaig calculated the present values of all NG costs in this section.
Positive Variable NGforDGCost(years,months);
Positive Variable NGforHeatCost(years,months);
Positive Variable NGforNGChillCost(years,months);
Positive Variable NGforNGOnlyLoadCost(years,months);
Positive Variable NGFixedCost(years,months);
Positive Variable NGCO2Cost(years,months);
Positive Variable NGTotalCost(years,months);

*2013/05/31. Lenaig calculated the present value of 'NGforDGCost(years,months)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation NGforDGCost_Eq(years,months);
     NGforDGCost_Eq(years,months)..
     NGforDGCost(years,months)
     =E=
     NGforDGConsumption(years,months)
     * FuelPrice(years,months,'NGforDG')
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

*2013/05/31. Lenaig calculated the present value of 'NGforHeatCost(years,months)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation NGforHeatCost_Eq(years,months);
     NGforHeatCost_Eq(years,months)..
     NGforHeatCost(years,months)
     =E=
     NGforHeatConsumption(years,months)
     * FuelPrice(years,months,'NGbasic')
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

*2013/05/31. Lenaig calculated the present value of 'NGforNGChillCost(years,months)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation NGforNGChillCost_Eq(years,months);
     NGforNGChillCost_Eq(years,months)..
     NGforNGChillCost(years,months)
     =E=
     NGforNGChillConsumption(years,months)
     * FuelPrice(years,months,'NGbasic')
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

*2013/05/31. Lenaig calculated the present value of 'NGforNGOnlyLoadCost(years,months)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation NGforNGOnlyLoadCost_Eq(years,months);
     NGforNGOnlyLoadCost_Eq(years,months)..
     NGforNGOnlyLoadCost(years,months)
     =E=
     NGforNGOnlyLoadConsumption(years,months)
     * FuelPrice(years,months,'NGbasic')
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

*2013/05/31. Lenaig calculated the present value of 'NGFixedCost(years,months)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation NGFixedCost_Eq(years,months);
     NGFixedCost_Eq(years,months)..
     NGFixedCost(years,months)
     =E=
     ( MonthlyFee(years,'UtilNGbasic')
       +
       MonthlyFee(years,'UtilNGforDG')
       +
       MonthlyFee(years,'UtilNGforABS'))
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

*2013/05/31. Lenaig calculated the present value of 'NGCO2Cost(years,months)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation NGCO2Cost_Eq(years,months);
     NGCO2Cost_Eq(years,months)..
     NGCO2Cost(years,months)
     =E=
     CO2FromNG(years,months)
     * ParameterTable('CO2Tax','ParameterValue')
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

Equation NGTotalCost_Eq(years,months);
     NGTotalCost_Eq(years,months)..
     NGTotalCost(years,months)
     =E=
       NGforDGCost(years,months)
     + NGforHeatCost(years,months)
     + NGforNGChillCost(years,months)
     + NGforNGOnlyLoadCost(years,months)
     + NGFixedCost(years,months)
     + NGCO2Cost(years,months);

*--------------- annual NG totals  ------------------------------
*TK this should be done post solver, otherwise it's just extra variables
*However, CO2 is calculated anyways for CO2 constrained runs

Positive Variable AnnualNGCost       (years);
Positive Variable AnnualNGConsume    (years);
Positive Variable AnnualNGCO2        (years);
Positive Variable AnnualNGCO2DER     (years);
Positive Variable AnnualNGCO2NonDER  (years);
Positive Variable AnnualNGCO2Chillers(years);
positive variable AnnualNGCO2NGOnly  (years);

Equation AnnualNGCost_Eq(years);
     AnnualNGCost_Eq(years)..
     AnnualNGCost(years) =E= sum(months,NGTotalCost(years,months));

Equation AnnualNGConsume_Eq(years);
     AnnualNGConsume_Eq(years)..
     AnnualNGConsume(years) =E= sum(months,NGTotalConsumption(years,months));

Equation AnnualNGCO2DER_Eq(years);
     AnnualNGCO2DER_Eq(years)..
     AnnualNGCO2DER(years) =E= sum(months,CO2FromDER(years,months));

Equation AnnualNGCO2NonDER_Eq(years);
     AnnualNGCO2NonDER_Eq(years)..
     AnnualNGCO2NonDER(years) =E= sum(months,CO2FromNonDER(years,months));

Equation AnnualNGCO2Chillers_Eq(years);
     AnnualNGCO2Chillers_Eq(years)..
     AnnualNGCO2Chillers(years) =E= sum(months,CO2FromChillers(years,months));

Equation AnnualNGCO2NGOnly_Eq(years);
     AnnualNGCO2NGOnly_Eq(years)..
     AnnualNGCO2NGOnly(years) =E= sum(months,CO2FromNGOnlyLoad(years,months));

Equation AnnualNGCO2_Eq(years);
     AnnualNGCO2_Eq(years)..
     AnnualNGCO2(years) =E= AnnualNGCO2DER(years)+AnnualNGCO2NonDER(years)+AnnualNGCO2Chillers(years)+AnnualNGCO2NGOnly(years);

* ------------------------------

***************************************************************************************
*--------------------   OTHER FUEL CONSUMPTION/CO2/COST   --------------------------
***************************************************************************************
*2013/03. Lenaig added a year index to all variables and equations in this section about other fuel consumption, CO2 and cost.

Positive Variable OtherFuelConsumption (years,months,fueltype);
*red flag
Equation OtherFuelConsumptionEq (years,months,fueltype);
OtherFuelConsumptionEq (years,months,NonNGFuels).. OtherFuelConsumption (years,months,NonNGFuels)
     =E=
     sum(  (enduse,AvailableTECHNOLOGIES,daytypes,hours)$(FuelValue(NonNGFuels)=(deropt(AvailableTECHNOLOGIES,'fuel'))),
        Generation_Use(AvailableTECHNOLOGIES,years,months,daytypes,hours)*(1/deropt(AvailableTECHNOLOGIES,'efficiency'))*NumberOfDays(months,daytypes)  )
        + sum(         (AvailableTECHNOLOGIES,daytypes,hours)$(FuelValue(NonNGFuels)=deropt(AvailableTECHNOLOGIES,'fuel')),
        Generation_Sell(AvailableTECHNOLOGIES,years,months,daytypes,hours)*(1/deropt(AvailableTECHNOLOGIES,'efficiency'))*NumberOfDays(months,daytypes)   )
   ;

Positive Variable OtherFuelCost (years,months,FuelType);
*2013/05/31. Lenaig calculated the present value of 'OtherFuelCost (years, months, NonNGFuels)'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation OtherFuelCostEq (years,months,FuelType);
OtherFuelCostEq(years,months,NonNGFuels) ..
OtherFuelCost (years,months,NonNGFuels)
     =E=
     OtherFuelConsumption (years,months,NonNGFuels)
     * FuelPrice(years,months,NonNGFuels)
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

Positive Variable AnnualOtherFuelCost (years,FuelType);
Equation AnnualOtherFuelCostEq (years,FuelType);
AnnualOtherFuelCostEq(years,NonNGFuels) ..
AnnualOtherFuelCost (years,NonNGFuels)
     =E=
     sum(months, OtherFuelCost(years,months,NonNGFuels));

* ---------------------------------------------------

***************************************************************************************
*--------------------   DG INVESTMENT AND MAINTENANCE COSTS   -------------------------
***************************************************************************************

*DG EQUIPMENT COSTS

*---------------- Upfront Capital Costs  ------------------------------------------------------
*2013/05/31. Lenaig added a year index to UpfrontCapitalCosts in order to consider investments in different years.
Positive Variable UpfrontCapitalCost_DiscTech (Technologies,years);
Positive Variable UpfrontCapitalCost_ContTech (ContinuousInvestType,years);
Positive Variable UpfrontCapitalCost_NGChill  (NGChillTech,years);
Positive Variable UpfrontCapitalCostBoreHole  (ContinuousInvestType,years);
Positive Variable UpfrontCapitalCost_StaticSwitch (years);
Positive Variable UpfrontCapitalCost (years);

*2013/05/31. Lenaig calculated the present value of 'UpfrontCapitalCost_DiscTech(AvailableTechnologies,years)'.
*2014/06/13. Lenaig removed the NPV statement " *(1/(1+ParameterTable('IntRate','ParameterValue'))** (ord(years)-1)) ".
Equation UpfrontCapitalCost_DiscTech_Eq (Technologies,years);
         UpfrontCapitalCost_DiscTech_Eq (AvailableTechnologies,years)..
         UpfrontCapitalCost_DiscTech (AvailableTechnologies,years)
         =E=
         ( DER_Investment (AvailableTechnologies,years)
           * deropt (AvailableTechnologies, 'maxp')
           * ( deropt (AvailableTechnologies, 'capcost') + deropt(AvailableTechnologies, 'NoxTreatCost') )
           - 0.5 * SGIPIncentiveAmount(AvailableTechnologies)
         )
         ;

*2013/05/31. Lenaig calculated the present value of 'UpfrontCapitalCost_NGChill(NGChillTech,years)'.
*2014/06/13. Lenaig removed the NPV statement " *(1/(1+ParameterTable('IntRate','ParameterValue'))** (ord(years)-1)) ".
Equation UpfrontCapitalCost_NGChill_Eq (NGChillTech,years);
         UpfrontCapitalCost_NGChill_Eq (NGChillTech,years)..
         UpfrontCapitalCost_NGChill (NGChillTech,years)
         =E=
         NGChillPurchQuantity (NGChillTech,years)
         * NGChiller (NGChillTech, 'maxp')
         * NGChiller (NGChillTech, 'capcost')
         ;

*2013/05/31. Lenaig calculated the present value of 'UpfrontCapitalCost_ContTech(ContinuousInvestType, years)'.
*2014/06/13. Lenaig removed the NPV statement " *(1/(1+ParameterTable('IntRate','ParameterValue'))** (ord(years)-1)) ".
Equation UpfrontCapitalCost_ContTech_Eq (ContinuousInvestType, years);
     UpfrontCapitalCost_ContTech_Eq (ContinuousInvestType, years)..
     UpfrontCapitalCost_ContTech (ContinuousInvestType, years)
     =E=
      (
*fixed cost
     ContinuousInvestParameter(ContinuousInvestType,'FixedCost')
     *Purchase(ContinuousInvestType, years)
*variable cost
     +
     ContinuousInvestParameter(ContinuousInvestType,'VariableCost')
     *CapacityAddedInYearY(ContinuousInvestType, years)
     +
     UpfrontCapitalCostBoreHole(ContinuousInvestType, years)
     )
     ;

*2013/05/31. Lenaig did not calculate the present value of 'UpfrontCapitalCostBoreHole('GroundSourceHeatPump',years) because it is included in 'UpfrontCapitalCost_ContTech(ContinuousInvestType,years)' which is already a present value.
Equation UpfrontCapitalCostBoreHole_Eq1(years,months,daytypes,hours);
     UpfrontCapitalCostBoreHole_Eq1(years,months,daytypes,hours)..
     UpfrontCapitalCostBoreHole('GroundSourceHeatPump',years)
     =G=
     HeatPumpParameterValue('GroundSourceHeatPump','BoreHoleCost')
     *CoolingfromGSHeatPump(years, months, daytypes, hours)*COPelectric
     *(1+HeatPumpParameterValue('GroundSourceHeatPump','COP_Cooling'))/HeatPumpParameterValue('GroundSourceHeatPump','HeatTransferBorehole_Cooling')
     ;

Equation UpfrontCapitalCostBoreHole_Eq2(years,months,daytypes,hours);
     UpfrontCapitalCostBoreHole_Eq2(years,months,daytypes,hours)..
     UpfrontCapitalCostBoreHole('GroundSourceHeatPump',years)
     =G=
     HeatPumpParameterValue('GroundSourceHeatPump','BoreHoleCost')
     *HeatingfromGSHeatPump(years, months, daytypes, hours)
     *(1-HeatPumpParameterValue('GroundSourceHeatPump','COP_Heating'))/HeatPumpParameterValue('GroundSourceHeatPump','HeatTransferBorehole_Heating')
     ;

*2013/05/31. Lenaig calculated the present value of 'UpfrontCapitalCost_Switch(years)'.
*2014/06/13. Lenaig removed the NPV statement " *(1/(1+ParameterTable('IntRate','ParameterValue'))** (ord(years)-1)) ".
Equation UpfrontCapitalCost_Switch_Eq(years);
     UpfrontCapitalCost_Switch_Eq(years)..
     UpfrontCapitalCost_StaticSwitch(years)
     =E=
     (SwitchSize*StaticSwitchParameter('CostM') + StaticSwitchParameter('CostB')) * SwitchPurchase(years)
     ;

*------------------Summary----------------
*2013/05/31. Lenaig added a year index to the intermediate upfront capital costs.
Equation UpfrontCapitalCost_Eq (years);
     UpfrontCapitalCost_Eq(years)..
     UpfrontCapitalCost(years)
     =E=
     sum(AvailableTechnologies, UpfrontCapitalCost_DiscTech(AvailableTechnologies, years))
     +
     sum(ContinuousInvestType, UpfrontCapitalCost_ContTech (ContinuousInvestType, years))
     +
     sum(NGChillTech, UpfrontCapitalCost_NGChill (NGChillTech, years))
     +
     UpfrontCapitalCost_StaticSwitch(years)
     ;

*---------------- Annualized Capital Costs  ------------------------------------------------------
*2013/05/31. Lenaig added a year index to annualized capital costs (=equivalent annual costs).
Positive Variable AnnualizedCapitalCost_DiscTech(Technologies, years);
Positive Variable AnnualizedCapitalCost_ContTech(ContinuousInvestType, years);
Positive Variable AnnualizedCapitalCost_NGChill (NGChillTech, years);
Positive Variable AnnualizedCapitalCost_Switch(years);
Positive Variable AnnualizedCapitalCost(years);

*-----   Discrete Technologies   -----
*2013/05/31. Lenaig considered the latest investments thanks to the year-counter when calculating the annualized capital cost.
*2014/06/13. Lenaig added the NPV statement " * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))" after calculating the annuities.
Equation AnnualizedCapCost_DiscTech_Eq (Technologies, years);
     AnnualizedCapCost_DiscTech_Eq (AvailableTechnologies, years)..
     AnnualizedCapitalCost_DiscTech(AvailableTechnologies, years)
     =E=
     sum(years_counter $(years_counter.val le deropt(AvailableTechnologies,'lifetime')),

         UpfrontCapitalCost_DiscTech(AvailableTechnologies, years - (years_counter.val - 1))
         * AnnuityRate_DiscTech (AvailableTECHNOLOGIES)
     )
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     ;

*-----   Continuous Technologies   -----
*2013/05/31. Lenaig considered the latest investments thanks to the year-counter when calculating the annualized capital cost.
*2014/06/13. Lenaig added the NPV statement " * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))" after calculating the annuities.
Equation AnnualizedCapCost_ContTech_Eq (ContinuousInvestType, years);
     AnnualizedCapCost_ContTech_Eq (ContinuousInvestType, years)..
     AnnualizedCapitalCost_ContTech(ContinuousInvestType, years)
     =E=
     sum(years_counter $(years_counter.val le ContinuousInvestParameter(ContinuousInvestType,'lifetime')),

           UpfrontCapitalCost_ContTech (ContinuousInvestType, years - (years_counter.val - 1))
           * AnnuityRate_ContTech (ContinuousInvestType)
     )
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     ;

*-----   NG directly fired chillers   -----
*2013/05/31. Lenaig considered the latest investments thanks to the year-counter when calculating the annualized capital cost.
*2014/06/13. Lenaig added the NPV statement " * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))" after calculating the annuities.
Equation AnnualizedCapCost_NGChill_Eq (NGChillTech, years);
     AnnualizedCapCost_NGChill_Eq (NGChillTech, years)..
     AnnualizedCapitalCost_NGChill (NGChillTech, years)
     =E=
     sum(years_counter $(years_counter.val le NGChiller(NGChillTech,'lifetime')),

         UpfrontCapitalCost_NGChill (NGChillTech, years - (years_counter.val - 1))
         * AnnuityRate_NGChill (NGChillTech)
     )
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     ;

*-----   Static Switch   -----
*2013/05/31. Lenaig considered the latest investments thanks to the year-counter when calculating the annualized capital cost.
*2014/06/13. Lenaig added the NPV statement " * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))" after calculating the annuities.
Equation AnnualizedCapCost_Switch_Eq (years);
     AnnualizedCapCost_Switch_Eq (years)..
     AnnualizedCapitalCost_Switch(years)
     =E=
     sum(years_counter $(years_counter.val le StaticSwitchParameter('lifetime')),

         UpfrontCapitalCost_StaticSwitch (years - (years_counter.val - 1))
         * AnnuityRate_StaticSwitch
     )
     * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     ;

*-----   Summary   -----
*2013/05/31. Lenaig a year index to the intermediate annualized capital costs.
Equation AnnualizedCapCost_Eq(years);
     AnnualizedCapCost_Eq(years)..
     AnnualizedCapitalCost(years)
     =E=
     sum(AvailableTechnologies, AnnualizedCapitalCost_DiscTech(AvailableTechnologies, years))
     +
     sum(ContinuousInvestType, AnnualizedCapitalCost_ContTech (ContinuousInvestType, years))
     +
     sum(NGChillTech, AnnualizedCapitalCost_NGChill (NGChillTech, years))
     +
     AnnualizedCapitalCost_Switch(years)
     ;


*---------------- Fixed Maintenance Costs  ------------------------------------------------------
*2013/03. Lenaig added a year index to all variables and equations in this section about fixed maintenance costs.
Positive Variable FixedMaintCost_DiscTech (years, months, Technologies);
Positive Variable FixedMaintCost_ContTech (years, months, ContinuousInvestType);
Positive Variable FixedMaintCost_NGChill  (years, months, NGChillTech);
Positive Variable FixedMaintCost          (years, months);

*2013/05/31. Lenaig calculated the present value of the fixed maintenance costs and considered them only during the lifetime of the installed technologies (see $ condition).
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation FixedMaintCost_DiscTech_Eq (years, months, Technologies);
     FixedMaintCost_DiscTech_Eq (years, months, AvailableTechnologies)..
     FixedMaintCost_DiscTech (years, months, AvailableTechnologies)
     =E=
     sum(years_counter $(years_counter.val le deropt(AvailableTechnologies,'lifetime')),

         DER_Investment (AvailableTECHNOLOGIES, years - (years_counter.val - 1))
         *deropt (AvailableTECHNOLOGIES, 'maxp')
         *deropt (AvailableTECHNOLOGIES, 'OMFix')
         /12
         *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     );

*2013/05/31. Lenaig calculated the present value of fixed maintenance costs and considered them only during the lifetime of the installed technologies (see $ condition).
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation FixedMaintCost_ContTech_Eq (years, months, ContinuousInvestType);
     FixedMaintCost_ContTech_Eq (years, months, ContinuousInvestType)..
     FixedMaintCost_ContTech (years, months, ContinuousInvestType)
     =E=
     sum(years_counter $(years_counter.val le ContinuousInvestParameter(ContinuousInvestType,'lifetime')),

         ContinuousInvestParameter(ContinuousInvestType,'FixedMaintenance')
         *CapacityAddedInYearY(ContinuousInvestType, years - (years_counter.val - 1))
         *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     );

*2013/05/31. Lenaig calculated the present value of fixed maintenance costs and considered them only during the lifetime of the installed technologies (see $ condition).
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation FixedMaintCost_NGChill_Eq (years, months, NGChillTech);
     FixedMaintCost_NGChill_Eq (years, months, NGChillTech)..
     FixedMaintCost_NGChill (years, months, NGChillTech)
     =E=
     sum(years_counter $(years_counter.val le NGChiller(NGChillTech,'lifetime')),

         NGChillPurchQuantity (NGChillTech, years - (years_counter.val - 1))
         *NGChiller (NGChillTech, 'maxp')
         *NGChiller (NGChillTech, 'OMFix')
         /12
         *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))

     );

*2013/05/31.  Lenaig. The total fixed maintenance cost is a present value as a sum of present values.
Equation FixedMaintCost_Eq(years, months);
     FixedMaintCost_Eq(years, months)..
     FixedMaintCost(years, months)
     =E=
     sum(AvailableTechnologies, FixedMaintCost_DiscTech(years, months, AvailableTechnologies))
     +
     sum(ContinuousInvestType, FixedMaintCost_ContTech (years, months, ContinuousInvestType))
     +
     sum(NGChillTech, FixedMaintCost_NGChill (years, months, NGChillTech))
     ;

*---------------- Variable Maintenance Costs  ------------------------------------------------------
*2013/03. Lenaig added a year index to all variables and equations in this section about variable maintenance costs.
Positive Variable VariableMaintCost_DiscTech (years, months, Technologies);
Positive Variable VariableMaintCost_ContTech (years, months, ContinuousInvestType);
Positive Variable VariableMaintCost_NGChill  (years, months, NGChillTech);
Positive Variable VariableMaintCost          (years, months);
Positive Variable NGChill_Level (NGChillTech, years, months, daytypes, hours);
Positive Variable NGChill_Amount(NGChillTech, years, months, daytypes, hours);

*2013/05/31. Lenaig calculated the present value of variable maintenance costs and considered them only during the lifetime of the installed technologies (see $ condition).
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation VariableMaintCost_DiscTech_Eq(years, months, Technologies);
     VariableMaintCost_DiscTech_Eq(years, months, AvailableTechnologies)..
     VariableMaintCost_DiscTech(years, months, AvailableTechnologies)
     =E=
     sum ((hours,daytypes),
            ( Generation_Use (AvailableTECHNOLOGIES, years, months, daytypes, hours)
              + Generation_Sell (AvailableTECHNOLOGIES, years, months, daytypes, hours)
            )* NumberOfDays (months, daytypes)
          )
     * Deropt (AvailableTECHNOLOGIES,'OMVar')
     *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     $( (years.val - mod(years.val-1,deropt(AvailableTechnologies,'lifetime')))  le   deropt(AvailableTechnologies,'lifetime') )
     ;

*2013/06/06. Lenaig calculated the present value of variable maintenance costs and considered them only during the lifetime of the installed technologies (see $ condition).
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation VariableMaintCost_NGChill_Eq(years, months, NGChillTech);
     VariableMaintCost_NGChill_Eq(years, months, NGChillTech)..
     VariableMaintCost_NGChill(years, months, NGChillTech)
     =E=
     sum ((hours,daytypes),
            ( NGChill_Amount (NGChillTech, years, months, daytypes, hours)
              * NumberOfDays (months, daytypes)
             )
            * NGChiller (NGChillTech,'OMVar')
        )
    *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
     $( (years.val - mod(years.val-1,NGChiller(NGChillTech,'lifetime')))  le   NGChiller(NGChillTech,'lifetime') )
     ;

*************************************************************************************
*************************************************************************************
*TKKKK need a NGChill_Amount = NGChill_Level*NGChillPurchQuantity (NGChillTech)
*************************************************************************************
*************************************************************************************
* long term should have something similar to generator logic: at each timestep,
* turn on zero to max invest number.  For now, maybe just assume avg. effic?


*TK may want to change this later
Equation VariableMaintCost_ContTech_Eq (years, months, ContinuousInvestType);
     VariableMaintCost_ContTech_Eq (years, months, ContinuousInvestType)..
     VariableMaintCost_ContTech (years, months, ContinuousInvestType)
     =E=
     0
*2013/05/31. Lenaig calculated the present value of variable maintenance costs and considered them only during the lifetime of the installed technologies (see $ condition).
*     *(1/(1+ParameterTable('IntRate','ParameterValue'))** (ord(years)-1))
*     $( (years.val - mod(years.val-1,ContinuousInvestParameter(ContinuousInvestType,'lifetime')))  le   ContinuousInvestParameter(ContinuousInvestType,'lifetime') )
     ;

*2013/05/31. Lenaig. The total variable maintenance cost is a present value as a sum of present values.
Equation VariableMaintCost_Eq(years, months);
     VariableMaintCost_Eq(years, months)..
     VariableMaintCost(years, months)
     =E=
     sum(AvailableTechnologies, VariableMaintCost_DiscTech(years, months, AvailableTechnologies))
     +
     sum(ContinuousInvestType, VariableMaintCost_ContTech (years, months, ContinuousInvestType))
     +
     sum(NGChillTech, VariableMaintCost_NGChill (years, months, NGChillTech))
     ;

*-----------------------  TOTAL DER COST  ---------------------------------------------
*2013/03. Lenaig added a year index to DERCost and defined DERTotalCost as a new variable.
Positive Variable DERCost(years)
                  DERTotalCost;

Equation DERCost_Eq(years);
     DERCost_Eq(years)..
     DERCost(years)
     =E=
     AnnualizedCapitalCost(years)
     + sum(months,FixedMaintCost(years,months) + VariableMaintCost(years,months));

Equation DERTotalCost_Eq;
     DERTotalCost_Eq..
     DERTotalCost
     =E=
     sum(years,DERCost(years));

* ---------------------------------------------
*2013/03. Lenaig added a year index to all variables and equations in this section about demand responses costs and calculated the present values of demand response costs.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
* Demand Response Costs

Positive Variable  DemandResponseCosts(years);
Equation DemandResponseCostsEq(years);
         DemandResponseCostsEq(years)..
         DemandResponseCosts(years)
         =E=
         sum((DemandResponseType,months,daytypes,hours),
               DemandResponse(DemandResponseType,years,months,daytypes,hours)* DemandResponseParameters (years,DemandResponseType,'VariableCost') * NumberOfDays (months, daytypes)
               + DemandResponseOnOff(DemandResponseType,years,months,daytypes,hours)* 0.000000001 * NumberOfDays (months, daytypes)
         )
        *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));
* Please note that the 0.000000001 just link the  DemandResponseOnOff and DemandResponse decision variables

Positive Variable  DemandResponseCostsHeating(years);
Equation DemandResponseCostsHeatingEq(years);
         DemandResponseCostsHeatingEq(years)..
         DemandResponseCostsHeating(years) =E=
         sum((DemandResponseType,months,daytypes,hours),
               DemandResponseHeating(DemandResponseType,years,months,daytypes,hours)* DemandResponseParametersHeating (years,DemandResponseType,'VariableCost') * NumberOfDays (months, daytypes)
               + DemandResponseOnOffHeating(DemandResponseType,years,months,daytypes,hours)* 0.000000001 * NumberOfDays (months, daytypes)
         )
        *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));
* Please note that the 0.000000001 just link the  DemandResponseOnOffHeating and DemandResponseHeating decision variables

*-------------------------------------------------------------------------------------
*-------------------------   ANNUAL TOTAL COST AND CO2  ---------------------------
*-------------------------------------------------------------------------------------
*2013/03. Lenaig added - a year index to all variables and equations in this section.
*                      - new variables (AllPeriodTotalCO2, AllPeriodTotalEnergyCosts) that are the sum of annual variables.
Variable AllPeriodTotalCO2
         TotalAnnualCO2 (years);

Equation AllPeriodTotalCO2_Eq;
         AllPeriodTotalCO2_Eq..
         AllPeriodTotalCO2
         =E=
         sum(years,TotalAnnualCO2(years));

Equation TotalAnnualCO2_Eq(years);
         TotalAnnualCO2_Eq(years)..
         TotalAnnualCO2(years)
         =E=
         sum(months,ElectricCO2(years,months) + CO2FromNG(years,months) + CO2fromEVsHomeCharging(years,months));

Variables AllPeriodTotalEnergyCosts
          TotalEnergyCosts (years)
          YearlyBatteryDegradationEVs (years)
*2013/05/31. Lenaig replaced PBI_INCENTIVE and created PBI_NPV(years).
          PBI_NPV(years);

*2014/08/19 José Include German subsidies

Equation AllPeriodTotalEnergyCosts_Eq;
         AllPeriodTotalEnergyCosts_Eq..
         AllPeriodTotalEnergyCosts
         =E=
         sum(years,TotalEnergyCosts(years));

*2013/05/31. Lenaig. 'TotalEnergyCosts(years)' is a present value as a sum of present values.

*2014/10/13 José fixed tariff component linearilization

Positive Variable Z(years) variabble for linearization product of binary and continues variables;
binary variable b(years)    varibale ;
Equation lin_fixed1(years);
         lin_fixed1(years)..
         Z(years)  =l= b(years) *EnergyConsumed;
Equation lin_fixed2(years);
         lin_fixed2(years)..
         -sum((months, daytypes,hours),Electricity_Purchase(years,months, daytypes,hours))+ Z(years) =l= 0  ;
Equation lin_fixed3(years);
         lin_fixed3(years)..
         sum((months, daytypes,hours),Electricity_Purchase(years,months, daytypes,hours))- Z(years)+b(years)*EnergyConsumed
          =l= EnergyConsumed;
Equation fixedtarif(years);
         fixedtarif(years)..
         -Z(years)+ sum((months, daytypes,hours),Electricity_Purchase(years,months, daytypes,hours)) =l=0;


Equation TotalEnergyCosts_Eq(years);
         TotalEnergyCosts_Eq(years)..
         TotalEnergyCosts(years)
         =E=
*2015/01/21 Dani included YearlyBatteryDegradation
         YearlyBatteryDegradation(years)
         +
*    Cost inferred due to YearlyBatteryDegradationEVs
         YearlyBatteryDegradationEVs(years)
         +
         sum(months, ElectricTotalCost(years,months)+ NGTotalCost(years,months) )
         +
         DERCost(years) + DemandResponseCosts(years)  +  DemandResponseCostsHeating(years)
*2013/05/31. Lenaig modified the payment for the switch.
*2014/10/13   José add a fixed component in the total cost
         +Fixedcomp*Exchangerate*b(years)*Fixedtariff*(1+Taxes+Elect_tax)

         - SwitchSize * StaticSwitchParameter('Value') * SwitchPurchase(years-mod(years.val-1, StaticSwitchParameter('lifetime')))
         - AnnualElectricitySales(years)
         - PBI_NPV(years)
         ;

*2013/03. Lenaig modified MultiObjective equation to consider AllPeriodTotalEnergyCosts and AllPeriodTotalCO2 instead of AnnualTotalEnergyCosts and AnnualTotalCO2.
Variable MultiObjective;
Equation MultiObjective_Eq;
         MultiObjective_Eq..
         MultiObjective
         =E=  ParameterTable ('MultiObjectiveWCosts','ParameterValue')/ParameterTable ('MultiObjectiveMaxCosts','ParameterValue' )*AllPeriodTotalEnergyCosts
         + ParameterTable ('MultiObjectiveWCO2','ParameterValue')/ParameterTable ('MultiObjectiveMaxCO2','ParameterValue')* AllPeriodTotalCO2;

***************************************************************************************
*--------------------   OPERATING CONSTRAINTS   ---------------------------------------
***************************************************************************************
*2013/03. Lenaig added a year index to all variables and equations in this section about operating constraints.

Positive Variables
         CoolingByAbsorption(years,months,daytypes,hours)
         RefrigerationByAbsorption(years,months,daytypes,hours)
         SprintAmount(Technologies,years,months,daytypes,hours);

*2013/05/31. Lenaig added new constraints to set the number of generators running to zero if there is no new investment after the lifetime is reached.
DER_CurrentlyOperating.fx(AvailableTECHNOLOGIES, years, months, daytypes, hours)$((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt deropt(AvailableTECHNOLOGIES,'lifetime')) ) = 0;
DER_CurrentlyOperating.fx(AvailableFCTechnologies,years,months,daytypes,hours)  $((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt deropt(AvailableFCTechnologies,'lifetime')) ) = 0;
Generation_Use.fx        (AvailableTECHNOLOGIES,years,months,daytypes,hours)    $((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt deropt(AvailableTECHNOLOGIES,'lifetime')) ) = 0;
Generation_Sell.fx       (AvailableTECHNOLOGIES,years,months,daytypes,hours)    $((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt deropt(AvailableTECHNOLOGIES,'lifetime')) ) = 0;
SprintAmount.fx          (AvailableTECHNOLOGIES,years,months,daytypes,hours)    $((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt deropt(AvailableTECHNOLOGIES,'lifetime')) ) = 0;
CoolingByAbsorption.fx      (years,months,daytypes,hours)$((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt ContinuousInvestParameter('AbsChiller','lifetime')) ) = 0;
RefrigerationByAbsorption.fx(years,months,daytypes,hours)$((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt ContinuousInvestParameter('Refrigeration','lifetime')) ) = 0;


* OPERATIONAL CONSTRAINTS
* MINIMUM AND MAXIMUM POWER CONSTRAINTS

*TK treat ng dg separately

*2013/05/31. Lenaig modified this equation to consider the latest investments thanks to the year-counter.

*2015/03/26. Dani included ramp constraints for discrete technologies

Parameter RampDiscreteGeneration  amount of generation increase or decrease allowed each hour while operating [kW]  /9/;
Binary Variable GenerationAuxBinaryDC (TECHNOLOGIES, years, months, daytypes, hours);
Binary Variable GenerationAuxBinaryCD (TECHNOLOGIES, years, months, daytypes, hours);

Equation Aux1RampUp (TECHNOLOGIES, years, months, daytypes, hours);
         Aux1RampUp (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
         GenerationAuxBinaryDC (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         =L=
         DER_CurrentlyOperating(AvailableTECHNOLOGIES, years, months, daytypes, hours);

Equation Aux2RampUp (TECHNOLOGIES, years, months, daytypes, hours);
         Aux2RampUp (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
         GenerationAuxBinaryDC (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         =L=
         1
         -
         DER_CurrentlyOperating(AvailableTECHNOLOGIES, years, months, daytypes, hours--1);

Equation Aux3RampUp (TECHNOLOGIES, years, months, daytypes, hours);
         Aux3RampUp (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
         DER_CurrentlyOperating(AvailableTECHNOLOGIES, years, months, daytypes, hours)
         +
         1-DER_CurrentlyOperating(AvailableTECHNOLOGIES, years, months, daytypes, hours--1)
         =L=
         GenerationAuxBinaryDC (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         +1
         ;

Equation Aux1RampDown (TECHNOLOGIES, years, months, daytypes, hours);
         Aux1RampDown (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
         GenerationAuxBinaryCD (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         =L=
         DER_CurrentlyOperating(AvailableTECHNOLOGIES, years, months, daytypes, hours--1);

Equation Aux2RampDown (TECHNOLOGIES, years, months, daytypes, hours);
         Aux2RampDown (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
         GenerationAuxBinaryCD (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         =L=
         1
         -
         DER_CurrentlyOperating(AvailableTECHNOLOGIES, years, months, daytypes, hours);

Equation Aux3RampDown (TECHNOLOGIES, years, months, daytypes, hours);
         Aux3RampDown (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
         DER_CurrentlyOperating(AvailableTECHNOLOGIES, years, months, daytypes, hours--1)
         +
         1-DER_CurrentlyOperating(AvailableTECHNOLOGIES, years, months, daytypes, hours)
         =L=
         GenerationAuxBinaryCD (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         +1
         ;

Equation Rampup_Eq (TECHNOLOGIES, years, months, daytypes, hours);
         Rampup_Eq (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
         Generation_Use (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         +
         Generation_Sell (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         -
         Generation_Use (AvailableTECHNOLOGIES, years, months, daytypes, hours--1)
         -
         Generation_Sell (AvailableTECHNOLOGIES, years, months, daytypes, hours--1)
         -
         100000*GenerationAuxBinaryDC(AvailableTECHNOLOGIES,years, months,daytypes,hours)
         =L=
         DER_CurrentlyOperating (AvailableTechnologies, years, months, daytypes, hours)
         *
         RampDiscreteGeneration
         ;

Equation Rampdown_Eq (TECHNOLOGIES, years, months, daytypes, hours);
         Rampdown_Eq (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
         Generation_Use (AvailableTECHNOLOGIES, years, months, daytypes, hours--1)
         +
         Generation_Sell (AvailableTECHNOLOGIES, years, months, daytypes, hours--1)
         -
         Generation_Use (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         -
         Generation_Sell (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         -
         100000*GenerationAuxBinaryCD(Availabletechnologies,years,months,daytypes, hours)
         =L=
         RampDiscreteGeneration
         *
         DER_CurrentlyOperating (AvailableTECHNOLOGIES, years, months, daytypes, hours)
         ;


* Constraint: At each hour- # of gens running is between 0 and purchase number
Equation DER_CurrentlyOperatingEq (TECHNOLOGIES, years, months, daytypes, hours);
DER_CurrentlyOperatingEq (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
         DER_CurrentlyOperating(AvailableTECHNOLOGIES,years,months,daytypes,hours)
         =L=
         sum(years_counter $(years_counter.val le deropt(AvailableTechnologies,'lifetime')),
             DER_Investment(AvailableTECHNOLOGIES,years - (years_counter.val-1))
         );

* Constraint: Total Generation >= DER_CurrentlyOperating*Capacity*MinCapacity
Equation DER_CurrentlyOperatingMinCapEq (TECHNOLOGIES,years,months,daytypes,hours);
DER_CurrentlyOperatingMinCapEq (AvailableTECHNOLOGIES,years,months,daytypes,hours)..
         Generation_Use(AvailableTECHNOLOGIES,years,months,daytypes,hours)
               + Generation_Sell(AvailableTECHNOLOGIES,years,months,daytypes,hours)
         =G=
         (   DER_CurrentlyOperating(AvailableTECHNOLOGIES,years,months,daytypes,hours)
             *deropt(AvailableTECHNOLOGIES,'maxp')
             *GenConstraints(AvailableTECHNOLOGIES,'MinLoad')
          )$(deropt(AvailableTECHNOLOGIES,'fuel') <> FuelValue('Solar'))
         ;

* Constraint: Total Generation <= DER_CurrentlyOperating*Capacity
* note PV is treated separately
Equation DER_CurrentlyOperatingMaxCapEq (TECHNOLOGIES,years,months,daytypes,hours);
         DER_CurrentlyOperatingMaxCapEq (AvailableTECHNOLOGIES,years,months,daytypes,hours)..
         Generation_Use(AvailableTECHNOLOGIES,years,months,daytypes,hours)
          + Generation_Sell(AvailableTECHNOLOGIES,years,months,daytypes,hours)
         =L=
         (DER_CurrentlyOperating(AvailableTECHNOLOGIES,years,months,daytypes,hours)*deropt(AvailableTECHNOLOGIES,'sprintcap'))
                 $(deropt(AvailableTECHNOLOGIES,'fuel') <> 1)
         ;

*2013/05/31. Lenaig modified this equation to consider the latest investments thanks to the year-counter.
* Constraint NGChill is less than installed capacity
* TK later can think about integer variable similar to DER_CurrentlyOperating
Equation NGChill_MaxCapacity_Eq (NGChillTech,years,months,daytypes,hours);
     NGChill_MaxCapacity_Eq (NGChillTech,years,months,daytypes,hours)..
     NGChill_Amount (NGChillTech,years,months,daytypes,hours)
     =L=
     sum(years_counter $(years_counter.val le NGChiller(NGChillTech,'lifetime')),
           NGChillPurchQuantity(NGChillTech,years -(years_counter.val-1) )*NGChiller(NGChillTech,'maxp'));

* Constraint: abs cooling limited by size of chiller
*2013/05/31. Lenaig modified this equation to consider the latest investments thanks to the year-counter.
Equation AbsorptionCoolingLimitEq(years,months,daytypes,hours);
     AbsorptionCoolingLimitEq(years,months,daytypes,hours)..
     CoolingByAbsorption(years,months,daytypes,hours)
     =L=
     sum(years_counter $(years_counter.val le ContinuousInvestParameter('AbsChiller','lifetime')),
           CapacityAddedInYearY('AbsChiller',years -(years_counter.val-1)));

* Constraint: abs refrigeration limited by size of chiller
*2013/05/31. Lenaig modified this equation to consider the latest investments thanks to the year-counter.
Equation  RefrigerationByAbsorptionEq(years,months,daytypes,hours);
      RefrigerationByAbsorptionEq(years,months,daytypes,hours)..
      RefrigerationByAbsorption(years,months,daytypes,hours)
      =L=
      sum(years_counter $(years_counter.val le ContinuousInvestParameter('Refrigeration','lifetime')),
           CapacityAddedInYearY('Refrigeration',years -(years_counter.val-1)));

*sprint cap constraints:
Equation SprintAmount_Eq(Technologies,years,months,daytypes,hours);
     SprintAmount_Eq(AvailableTechnologies,years,months,daytypes,hours)..
     SprintAmount(AvailableTechnologies,years,months,daytypes,hours)
     =G=
     (  ( Generation_Use(AvailableTECHNOLOGIES,years,months,daytypes,hours)
         + Generation_Sell(AvailableTECHNOLOGIES,years,months,daytypes,hours)
        )
        -
        ( deropt(AvailableTECHNOLOGIES,'maxp')
          * DER_CurrentlyOperating(AvailableTECHNOLOGIES,years,months,daytypes,hours)
        )
     );

*2013/05/31. Lenaig modified this equation to consider all the latest investments thanks to the year-counter.
*CONSTRAINT: sprinting is limited to the [sprint capacity] * [sprint hours] * [number of units purchased]
Equation SprintLimit_Eq (Technologies,years);
     SprintLimit_Eq (AvailableTechnologies,years)..
     sum ((months,daytypes,hours),
                SprintAmount (AvailableTechnologies,years,months,daytypes,hours)
                *
                NumberOfDays(months,daytypes)
         )
     =L=
     sum(years_counter $(years_counter.val le deropt(AvailableTechnologies,'lifetime')),
                 ( deropt(AvailableTECHNOLOGIES,'SprintCap')
                   - deropt(AvailableTECHNOLOGIES,'maxp') )
                 *deropt(AvailableTECHNOLOGIES,'SprintHours')
                 *DER_Investment(AvailableTECHNOLOGIES,years -(years_counter.val-1))
     );

*MG Add a possibility to turn the FC constraint on and off via an option within the OptionsTable
Parameter FuelCellOperatesWholeDay;
FuelCellOperatesWholeDay = 0$(OptionsTable('FuelCellConstraint', 'OptionValue') eq 0) + 1$(OptionsTable('FuelCellConstraint', 'OptionValue') eq 1);

*GC Added new Operating Constraint specific for Markus, to deal with the fuel cell startup and shutdown times
Equation FuelCellRunsWholeDay_Eq(TECHNOLOGIES,years,months,daytypes,hours);
FuelCellRunsWholeDay_Eq(AvailableFCTechnologies,years,months,daytypes,hours)..
         DER_CurrentlyOperating(AvailableFCTechnologies,years,months,daytypes,hours)
         *FuelCellOperatesWholeDay
         =e=
         DER_CurrentlyOperating(AvailableFCTechnologies,years,months,daytypes,hours--1)
         *FuelCellOperatesWholeDay
         ;


Variable MicrogridBenefit(years);

Positive Variable Daysinthisyear(years);
Equations Daysinthisyear_Eq(years);
          Daysinthisyear_Eq(years)..
          Daysinthisyear(years)
          =E=
          sum( (months),
                 sum (   (daytypes), numberofdays(months,daytypes)));

*All measured in $
*2013/06/06. Lenaig calculated the present value of 'MicrogridBenefit'. 'TotalEnergyCosts(years)' is already a present value.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation MicrogridBenefit_Eq(years);
         MicrogridBenefit_Eq(years)..
         MicrogridBenefit(years)
         =E=
         Electricity_Exchange_EV('Reference_Cost') * (1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))   - TotalEnergyCosts(years);

*#############EV Battery Degradation###############


* EnergyprocessedEVs-Equations normalize the processed energy (input and output)
* to the initial capacity chosen
* Optimization can be performed because the yearly total cost calculation
* cuts out the capacity!
* OLIVIER : no normalization any more (removed by Ilan), comment not accurate...

Positive Variables
         EnergyprocessedEVsHourly(years,months,daytypes,hours)
         EnergyprocessedEVsMonthly(years,months)
         EnergyprocessedEVsYearly(years);

Equation EnergyprocessedEVsHourly_Eq(years,months,daytypes,hours);
     EnergyprocessedEVsHourly_Eq(years,months,daytypes,hours)..
     EnergyprocessedEVsHourly(years,months,daytypes,hours)
*measured in kWh
     =E=
     (Electricity_FromEVs(years,months,daytypes,hours)
       + ElectricityForStorageEVs(years,months,daytypes,hours))
     *BinaryEVsConnectionTable(years,months,daytypes,hours)
*measured in kWh
     ;

Equation EnergyprocessedEVsMonthly_Eq(years,months);
    EnergyprocessedEVsMonthly_Eq(years,months)..
    EnergyprocessedEVsMonthly(years,months)
*measured in kWh
    =E=
    sum ((daytypes), numberofdays(months,daytypes) *
    sum ((hours), EnergyprocessedEVsHourly(years,months,daytypes,hours)));

Equation EnergyprocessedEVsYearly_Eq(years);
    EnergyprocessedEVsYearly_Eq(years)..
    EnergyprocessedEVsYearly(years)
*measured in kWh
    =E=
    sum(months, EnergyprocessedEVsMonthly(years,months));

*The degradation function

*2013/05/31. Lenaig calculated the present value of 'YearlyBatteryDegradationEVs'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation YearlyBatteryDegradationEVs_Eq(years);
    YearlyBatteryDegradationEVs_Eq(years)..
    YearlyBatteryDegradationEVs(years)
    =E=
    EnergyprocessedEVsYearly(years)*
*measured in kWh
    Electricity_Exchange_EV('Capacity_Loss_per_Normalized_Wh')
*dimensionless, w/o unit []
    *Electricity_Exchange_EV('Future_Replacement_Cost')
    *5
*OLIVIER : the 5 at the end is because 20% degradation is equivalent to a worthless battery (c.f. master thesis)
*measured in $/kWh
*
    *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))

***old
*    *ContinuousVariableForcedInvest ('EVs1','ForcedInvestCapacity')
*    *Capacity('EVs1')
*     *100000
;

*2013/05/31. Lenaig added a year index.
Variable EV_connection_payment(years);

Equation EV_connection_payment_Eq(years);
     EV_connection_payment_Eq(years)..
     EV_connection_payment(years)
     =E=
     (ContinuousInvestParameter('EVs1','VariableCost')
*     measured in $/kWh
*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
      *TotalCapacityInYearY('EVs1',years))
*     measured in kWh
      *ContinuousInvestParameter('EVs1','Lifetime')
*     measured in years
*Olivier : not clear why we have to multiply by the lifetime…
*
*2013/05/31. Lenaig calculated the present value of 'EV_connection_payment'.
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
      *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years));

scalar j;
scalar DurationHomeCharge;
DurationHomeCharge = ElectricityStorageEVParameter('EndHomeCharge') + 25 -ElectricityStorageEVParameter('BeginingHomeCharge');

scalar SelfDischargeSummation;
SelfDischargeSummation = 0;

for  ( j = 1 to DurationHomeCharge by 1,
         SelfDischargeSummation = SelfDischargeSummation + (1-ElectricityStorageEVParameter('SelfDischarge'))**(j-1););

Equation EVsElectricityFromHome_without_eff_Eq(years,months,daytypes);
         EVsElectricityFromHome_without_eff_Eq(years,months,daytypes)..
         EVsElectricityFromHome_without_eff(years,months,daytypes)
         =E=
         (
         sum((hours)$(ord(hours)=ElectricityStorageEVParameter('ConnectingHourOffice')), ElectricityStoredEVs(years,months,daytypes,hours))/(1-ElectricityStorageEVParameter('SelfDischarge'))**(ElectricityStorageEVParameter('ConnectingHourOffice')-ElectricityStorageEVParameter('EndHomeCharge'))-
         sum((hours)$(ord(hours)=(ElectricityStorageEVParameter('DisconnectHourOffice')-1)), ElectricityStoredEVs(years,months,daytypes,hours))*(1-ElectricityStorageEVParameter('SelfDischarge'))**(ElectricityStorageEVParameter('EndHomeCharge')+25-ElectricityStorageEVParameter('DisconnectHourOffice'))
         )     /    SelfDischargeSummation;
*the conditionnal sums are used to get the SOCs at connecting and disconnecting hours (in each sum, there's only one non-zero term)

*it should be divided by efficiencycharge if home electricity is used to charge EVs, or multiplicated by efficiencydischarge if batteries from EVs are used to displace home electricity!!!
*this what is done below

Variables        EHToCar(years,months,daytypes)
                 EHToHome(years,months,daytypes);
* EHToCar : electricity from home to car
* EHToHouse : electricity from car to home

Equation  EHToCar_Eq1(years,months,daytypes);
          EHToCar_Eq1(years,months,daytypes)..
          EHToCar(years,months,daytypes) =G= 0;

Equation  EHToHome_Eq1(years,months,daytypes);
          EHToHome_Eq1(years,months,daytypes)..
          EHToHome(years,months,daytypes) =L= 0;

binary variable HomeChargeOrDischarge(years,months,daytypes);
* 1 for charge at home, 0 for discharge
*1 when EHToCar (and also EVsElectricityFromHome_without_eff) > 0, 0 when EHToHome (and also EVsElectricityFromHome_without_eff) < 0

Equation EHToCar_Eq2(years,months,daytypes);
         EHToCar_Eq2(years,months,daytypes)..
         EHToCar(years,months,daytypes) =L= HomeChargeOrDischarge(years,months,daytypes) *10000000;

Equation EHToHome_Eq2(years,months,daytypes);
         EHToHome_Eq2(years,months,daytypes)..
         EHToHome(years,months,daytypes) =G= (HomeChargeOrDischarge(years,months,daytypes)-1) *10000000;
*these 2 equations above ensure that either EHToCar or EHToHome is equal to 0

Equation EVsElectricityFromHome_without_eff_Eq2(years,months,daytypes);
         EVsElectricityFromHome_without_eff_Eq2(years,months,daytypes)..
         EVsElectricityFromHome_without_eff(years,months,daytypes) =E= EHToCar(years,months,daytypes) + EHToHome(years,months,daytypes);
*left term can be positive or negative, one of the right terms is always 0, the other is therefore equal to the left term

Equation EVsElectricityFromHome_Eq(years,months,daytypes);
         EVsElectricityFromHome_Eq(years,months,daytypes)..
         EVsElectricityFromHome(years,months,daytypes) =E=
         EHToCar(years,months,daytypes)/ElectricityStorageEVParameter('EfficiencyCharge')  +  EHToHome(years,months,daytypes) * ElectricityStorageEVParameter('EfficiencyDischarge');
*residential electricity consumed overnight (if positive),
*residential electricity displaced overnight (if negative),

Equation CO2fromEVsHomeCharging_Eq(years,months);
         CO2fromEVsHomeCharging_Eq(years,months)..
         CO2fromEVsHomeCharging(years,months)
         =E= sum((daytypes,hours), EVsElectricityFromHome(years,months,daytypes)* NightlyMarginalCO2EmissionsResidential(years,months,hours)*NumberOfDays(months, daytypes));
*OLIVIER : TO BE CHECKED
*units should be checked! kWh and kgCO2, is it okay?


***********************************************************
*******   ENERGY BALANCE CONSTRAINTS  *********************
***********************************************************
*2013/03. Lenaig added a year index to all variables and equations in this section about energy balance constraints.

**** electricity balance, top level equations **************


Positive Variables
     ElectricityStoredStationary(years,months,daytypes,hours)

* 2013/03/22. Lenaig. ElectricityStorageStationaryCapacity = Total installed capacity    minus     capacity loss due to battery degradation
* 2015/01/16. Dani moved up ElectricityStorageStationaryCapacity
     ElectricityStorageStationaryInput(years,months,daytypes,hours)
     ElectricityStorageStationaryOutput(years,months,daytypes,hours)
     ElectricityStorageStationaryLosses(years,months,daytypes,hours)
     FlowBatteryStored(years,months,daytypes,hours)
     FlowBatteryInput(years,months,daytypes,hours)
     FlowBatteryOutput(years,months,daytypes,hours)
     FlowBatteryLosses(years,months,daytypes,hours)
;

*TK Note the cicular lag (--) usage.  this means that for each daytype,
*charge at beginning of day = charge at end of day
*this is fair because regardless of what level you start at, you can't gain
*this will not reflect charging on weekdays to provide for peak days
*nor will it reflect chraging on weekends to provide for weekdays
*some analysis should be done to see how significant this ommission is

Equation ElectricityStoredStationaryEq (years,months,daytypes,hours);
     ElectricityStoredStationaryEq(years,months,daytypes,hours)..
     ElectricityStoredStationary(years,months,daytypes,hours)
     =E=
     ElectricityStoredStationary(years,months,daytypes,hours--1)
     +
     ElectricityStorageStationaryInput(years,months,daytypes,hours)
     -
     ElectricityStorageStationaryOutput(years,months,daytypes,hours)
     -
     ElectricityStorageStationaryLosses(years,months,daytypes,hours)
     ;

*

Equation CapacityBidRegulationUpEq (years,months,daytypes,hours);
     CapacityBidRegulationUpEq (years,months,daytypes,hours)..
     CapacityBidRegulationUpBattery (years,months,daytypes,hours)
     +
     sum(AvailableTECHNOLOGIES,CapacityBidRegulationUpDiscreteTechnology(AvailableTECHNOLOGIES, years, months, daytypes, hours))
     =L=
     ContractCapacity (years,months)
     +
     (
     Electricity_Purchase(years,months,daytypes,hours)
     -
     sum(AvailableTECHNOLOGIES,Generation_NetworkSales(AvailableTECHNOLOGIES,years,months,daytypes,hours))
     -
     EnergyFlowFromStationaryStorageToNetwork(years,months,daytypes,hours)
     -
     Electricity_PV_Export(years,months,daytypes,hours)
     )
     ;

Equation CapacityBidRegulationDownEq (years,months,daytypes,hours);
     CapacityBidRegulationDownEq (years,months,daytypes,hours)..
     CapacityBidRegulationDownBattery (years,months,daytypes,hours)
     +
     sum(AvailableTECHNOLOGIES,CapacityBidRegulationDownDiscreteTechnology(AvailableTECHNOLOGIES,years,months,daytypes,hours))
     =L=
     ContractCapacity (years,months)
     -
     (
     Electricity_Purchase(years,months,daytypes,hours)
     -
     sum(AvailableTECHNOLOGIES,Generation_NetworkSales(AvailableTECHNOLOGIES,years,months,daytypes,hours))
     -
     EnergyFlowFromStationaryStorageToNetwork(years,months,daytypes,hours)
     -
     Electricity_PV_Export(years,months,daytypes,hours)
     )
     ;

Equation CapacityBidRegulationDownBatteryEq (years,months,daytypes,hours);
     CapacityBidRegulationDownBatteryEq(years,months,daytypes,hours)..
     CapacityBidRegulationDownBattery (years,months,daytypes,hours)
     =L=
     ElectricityStorageStationaryCapacity(years,months)
     -
     (
     ElectricityStoredStationary(years,months,daytypes,hours--1)
     +
     EnergyFlowFromBuildingToStationaryStorage(years,months,daytypes,hours)*ElectricityStorageStationaryParameter('EfficiencyCharge')
     -
     (EnergyFlowFromStationaryStorageToBuilding(years,months,daytypes,hours)+EnergyFlowFromStationaryStorageToNetwork(years,months,daytypes,hours))/ElectricityStorageStationaryParameter('EfficiencyDischarge')
     -
     ElectricityStorageStationaryLosses(years,months,daytypes,hours)
     )
     ;

Equation CapacityBidRegulationUpDiscreteTechnologyEq (TECHNOLOGIES, years, months, daytypes, hours);
     CapacityBidRegulationUpDiscreteTechnologyEq (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
     CapacityBidRegulationUpDiscreteTechnology(AvailableTECHNOLOGIES, years, months, daytypes, hours)
     =L=
     (DER_CurrentlyOperating(AvailableTECHNOLOGIES,years,months,daytypes,hours)
     *
     DEROPT(AvailableTECHNOLOGIES,'maxp')$(deropt(AvailableTECHNOLOGIES,'fuel')<>1))
     -
     (Generation_Use(AvailableTECHNOLOGIES,years,months,daytypes,hours)
     +
     Generation_NetworkSales(AvailableTECHNOLOGIES,years,months,daytypes,hours));

Equation CapacityBidRegulationUpBatteryEq (years,months,daytypes,hours);
     CapacityBidRegulationUpBatteryEq(years,months,daytypes,hours)..
     CapacityBidRegulationUpBattery (years,months,daytypes,hours)
     =L=
     (
     ElectricityStoredStationary(years,months,daytypes,hours--1)
     +
     EnergyFlowFromBuildingToStationaryStorage(years,months,daytypes,hours)*ElectricityStorageStationaryParameter('EfficiencyCharge')
     -
     (EnergyFlowFromStationaryStorageToBuilding(years,months,daytypes,hours)+EnergyFlowFromStationaryStorageToNetwork(years,months,daytypes,hours))/ElectricityStorageStationaryParameter('EfficiencyDischarge')
     -
     ElectricityStorageStationaryLosses(years,months,daytypes,hours)
     )
     -
     ElectricityStorageStationaryCapacity(years,months)
     *
     (1-ElectricityStorageStationaryParameter('MaxDepthOfDischarge'))
     ;

Equation CapacityBidRegulationDownDiscreteTechnologyEq (TECHNOLOGIES, years, months, daytypes, hours);
     CapacityBidRegulationDownDiscreteTechnologyEq (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
     CapacityBidRegulationDownDiscreteTechnology(AvailableTECHNOLOGIES, years, months, daytypes, hours)
     =L=
     Generation_Use(AvailableTECHNOLOGIES,years,months,daytypes,hours)
     +
     Generation_NetworkSales(AvailableTECHNOLOGIES,years,months,daytypes,hours)
     -
     DER_CurrentlyOperating(AvailableTECHNOLOGIES, years,months,daytypes,hours)
     *
     deropt(AvailableTECHNOLOGIES, 'maxp')
     *
     GenConstraints(AvailableTECHNOLOGIES,'MinLoad')$(deropt(AvailableTechnologies,'fuel')<>1)
     ;

Equation CapacityBidRegulationUpEqualDown (years,months,daytypes,hours);
     CapacityBidRegulationUpEqualDown(years,months,daytypes,hours)..
     CapacityBidRegulationUpBattery (years,months,daytypes,hours)
     +
     sum(AvailableTECHNOLOGIES,CapacityBidRegulationUpDiscreteTechnology(AvailableTECHNOLOGIES, years, months, daytypes, hours))
     =E=
     (CapacityBidRegulationDownBattery(years,months,daytypes,hours)
     +
     sum(AvailableTECHNOLOGIES,CapacityBidRegulationDownDiscreteTechnology(AvailableTECHNOLOGIES,years,months,daytypes,hours)))
     *
     (7/5)
     ;
*2015/02/02 Dani included CapacityBidRegulationUpEqualDown. In Spain CapacityBidRegulationUp must be equal to CapacityBidRegulationDown*(7/5)

Equation EnergyFlowFromBatteryToISOEq (years,months,daytypes,hours);
     EnergyFlowFromBatteryToISOEq (years,months,daytypes,hours)..
     EnergyFlowFromBatteryToISO (years,months,daytypes,hours)
     =E=
     CapacityBidRegulationUpBattery (years,months,daytypes,hours)
     *
     DispatchToContractRatioUp;

Equation DiscreteTechnologyRegulationUpEq (TECHNOLOGIES, years, months, daytypes, hours);
     DiscreteTechnologyRegulationUpEq(AvailableTECHNOLOGIES, years, months, daytypes, hours)..
     DiscreteTechnologyRegulationUp(AvailableTECHNOLOGIES, years, months, daytypes, hours)
     =E=
     CapacityBidRegulationUpDiscreteTechnology(AvailableTECHNOLOGIES, years, months, daytypes, hours)
     *
     DispatchToContractRatioUp;

Equation EnergyFlowFromISOToBatteryEq (years,months,daytypes,hours);
     EnergyFlowFromISOToBatteryEq (years,months,daytypes,hours)..
     EnergyFlowFromISOToBattery (years,months,daytypes,hours)
     =E=
     CapacityBidRegulationDownBattery (years,months,daytypes,hours)
     *
     DispatchToContractRatioDown;

Equation DiscreteTechnologyRegulationDownEq (TECHNOLOGIES, years, months, daytypes, hours);
     DiscreteTechnologyRegulationDownEq (AvailableTECHNOLOGIES, years, months, daytypes, hours)..
     DiscreteTechnologyRegulationDown (AvailableTECHNOLOGIES, years, months, daytypes, hours)
     =E=
     CapacityBidRegulationDownDiscreteTechnology(AvailableTECHNOLOGIES, years, months, daytypes, hours)
     *
     DispatchToContractRatioDown;

Equation Electricity_FromStationaryBatteryEq2 (years,months,daytypes,hours);
     Electricity_FromStationaryBatteryEq2 (years,months,daytypes,hours)..
     Electricity_FromStationaryBattery (years,months,daytypes,hours)
     =E=
     EnergyFlowFromStationaryStorageToBuilding (years,months,daytypes,hours)
     +
     EnergyFlowFromBatteryToISO (years,months,daytypes,hours)
     +
     EnergyFlowFromStationaryStorageToNetwork (years, months,daytypes,hours)
     ;

Equation ElectricityForStorageStationaryEq (years,months,daytypes,hours);
     ElectricityForStorageStationaryEq (years,months,daytypes,hours)..
     ElectricityForStorageStationary (years,months,daytypes,hours)
     =E=
     EnergyFlowFromBuildingToStationaryStorage (years,months,daytypes,hours)
     +
     EnergyFlowFromISOToBattery (years,months,daytypes,hours)
     ;

Equation Generation_SellEq(TECHNOLOGIES, years, months, daytypes, hours);
     Generation_SellEq(AvailableTECHNOLOGIES, years, months, daytypes, hours)..
     Generation_Sell (AvailableTECHNOLOGIES, years, months, daytypes, hours)
     =E=
     Generation_NetworkSales(AvailableTECHNOLOGIES, years, months, daytypes, hours)
     +
     DiscreteTechnologyRegulationUp(AvailableTECHNOLOGIES, years, months, daytypes, hours)
     -
     DiscreteTechnologyRegulationDown(AvailableTECHNOLOGIES, years, months, daytypes, hours)
     ;

*
*2015/01/15 Dani included regulation variables and equations
*2015/01/22 Dani included Discrete Technologies

Equation FlowBatteryStoredEq (years,months,daytypes,hours);
     FlowBatteryStoredEq(years,months,daytypes,hours)..
     FlowBatteryStored(years,months,daytypes,hours)
     =E=
     FlowBatteryStored(years,months,daytypes,hours--1)
     +
     FlowBatteryInput(years,months,daytypes,hours)
     -
     FlowBatteryOutput(years,months,daytypes,hours)
     -
     FlowBatteryLosses(years,months,daytypes,hours)
     ;


Parameters ElectricNonCoolingLoad(years,months,daytypes,hours);
     ElectricNonCoolingLoad(years,months,daytypes,hours) = Load(years,'electricity-only',months,daytypes,hours);

Positive Variables
     ElectricityConsumed(years,months,daytypes,hours)
     ElectricityForCooling(years,months,daytypes,hours)
     ElectricityForRefrigeration (years,months,daytypes,hours)
*2015/01/16 Dani moved up ElectricityForStorageStationary
     ElectricityForFlowBattery(years,months,daytypes,hours)
     ElectricityForHeatPumps(years,months,daytypes,hours)
     ;

Electricityforcooling.up(years,months, daytypes, hours)$(OptionsTable('CentralChiller', 'OptionValue') eq 0) = 0;

Equation ElectricityConsumedEq (years,months,daytypes,hours);
     ElectricityConsumedEq (years,months,daytypes,hours)..
     ElectricityConsumed(years,months,daytypes,hours)
     =E=
     ElectricNonCoolingLoad(years,months,daytypes,hours)
     +
     ElectricityForCooling(years,months,daytypes,hours)
     +
     ElectricityForRefrigeration (years,months,daytypes,hours)
     +
     EnergyFlowFromBuildingToStationaryStorage(years,months,daytypes,hours)
*2015/01/21 Dani changed ElectricityForStorageStationary by EnergyFlowFromBuildingToStationaryStorage
     +
     BinaryEVsConnectionTable(years,months,daytypes,hours)
     *
     ElectricityForStorageEVs(years,months,daytypes,hours)
     +
     ElectricityForFlowBattery(years,months,daytypes,hours)
     +
     ElectricityForHeatPumps(years,months,daytypes,hours)
     -
     LoadReduction(years,months,daytypes,hours)
     +
     LoadIncrease(years,months,daytypes,hours)
     -
     sum(DemandResponseType,DemandResponse(DemandResponseType,years,months,daytypes,hours))
     ;

Equation ElectricSalesEq (years,months,daytypes,hours);
     ElectricSalesEq (years,months,daytypes,hours)..
     ElectricSales(years,months,daytypes,hours)
     =E=
     Electricity_PV_Export(years,months,daytypes,hours)
     +
     sum(AvailableTECHNOLOGIES,Generation_NetworkSales(AvailableTECHNOLOGIES, years, months, daytypes, hours))
     +
     EnergyFlowFromStationaryStorageToNetwork(years,months,daytypes,hours);
*2015/01/22 Dani changed Generation_Sell by Generation_NetworkSales
*2015/06/11 Dani included EnergyFlowFromStationaryStorageToNetwork(years,months,daytypes,hours)

Equation ElectricityBalanceEq (years,months,daytypes,hours);
     ElectricityBalanceEq(years,months,daytypes,hours)..
     ElectricityProvided(years,months,daytypes,hours)
     =E=
     ElectricityConsumed(years,months,daytypes,hours) +  ElectricSales(years,months,daytypes,hours);


**** electricity balance, lower-level equations **************

* note this assumes pv is not part of the technologies set
Equation  Electricity_GenerationEq(years,months,daytypes,hours);
     Electricity_GenerationEq(years,months,daytypes,hours)..
     Electricity_Generation(years,months,daytypes,hours)
     =E=
     sum (AvailableTECHNOLOGIES,
           Generation_Use(AvailableTECHNOLOGIES, years, months, daytypes, hours)
           +
           Generation_NetworkSales(AvailableTECHNOLOGIES, years, months, daytypes, hours)
*2015/01/22 Dani changed Generation_Sell by Generation_NetworkSales
         )
         ;

* note this assumes pv is not part of the technologies set
Equation  Electricity_Generation_TechnologyEq(TECHNOLOGIES,years,months,daytypes,hours);
     Electricity_Generation_TechnologyEq(TECHNOLOGIES,years,months,daytypes,hours)..
     Electricity_Generation_Technology(TECHNOLOGIES,years,months,daytypes,hours)
     =E=
     Generation_Use(TECHNOLOGIES,years,months,daytypes,hours)
     +
     Generation_NetworkSales(TECHNOLOGIES,years,months,daytypes,hours)
*2015/01/22 Dani changed Generation_Sell by Generation_NetworkSales
     ;

*note the 'less than' instead of 'equals' incase PV is greater than load
Equation Electricity_PhotovoltaicsEq(years,months,daytypes,hours);
     Electricity_PhotovoltaicsEq(years,months,daytypes,hours)..
     Electricity_Photovoltaics(years,months,daytypes,hours)
     =E=
     Electricity_PV_Export(years,months,daytypes,hours) + Electricity_PV_Onsite(years,months,daytypes,hours);

* For PV capacity constraint see PV modeling section

*------------------------------------------------------
*2013/02/22. Lenaig added a new variable and a new equation to represent battery degradation.
*            'ElectricityStorageStationaryCapacity' refers to the available capacity for stationary storage.
*            = initial capacity - constant value (constant fraction of initial capacity) that is lost every month.
*2013/05/31. About reinvestment, Lenaig considered the installed energy capacity from the latest investments,
*            and added a condition to set the available battery capacity to zero at the end of the lifetime if no new investments.
Equation ElectricityStorageStationaryCapacityEq(years,months);
     ElectricityStorageStationaryCapacityEq(years,months)..
     ElectricityStorageStationaryCapacity(years,months)
     =E=
     sum(years_counter $(years_counter.val le ContinuousInvestParameter('ElectricStorage','lifetime')),
           CapacityAddedInYearY('ElectricStorage',years - (years_counter.val-1))
           *(1 - (12*(years_counter.val-1) + ord(months)-1)
           *ElectricityStorageStationaryParameter('BatteryDegradation'))
     );
*2013/09/06. Lenaig. Not sure.
*     $( (years.val - mod(years.val-1,ContinuousInvestParameter('ElectricStorage','lifetime'))) le ContinuousInvestParameter('ElectricStorage','lifetime') );

Equation ElectricityStorageStationaryInputEq(years,months,daytypes,hours);
     ElectricityStorageStationaryInputEq(years,months,daytypes,hours)..
     ElectricityStorageStationaryInput(years,months,daytypes,hours)
     =E=
     ElectricityForStorageStationary(years,months,daytypes,hours)
     *ElectricityStorageStationaryParameter('EfficiencyCharge');

Equation FlowBatteryInputEq(years,months,daytypes,hours);
     FlowBatteryInputEq(years,months,daytypes,hours)..
     FlowBatteryInput(years,months,daytypes,hours)
     =E=
     ElectricityForFlowBattery(years,months,daytypes,hours)
     *FlowBatteryParameter('EfficiencyCharge');

Equation Electricity_FromStationaryBatteryEq(years,months,daytypes,hours);
     Electricity_FromStationaryBatteryEq(years,months,daytypes,hours)..
     ElectricityStorageStationaryOutput(years,months,daytypes,hours)
     =E=
     Electricity_FromStationaryBattery(years,months,daytypes,hours)
*2015/06/11 Dani included EnergyFlowFromStationaryStorageToNetwork
     /
     ElectricityStorageStationaryParameter('EfficiencyDischarge');

Equation Electricity_FromFlowBatteryEq(years,months,daytypes,hours);
     Electricity_FromFlowBatteryEq(years,months,daytypes,hours)..
     Electricity_FromFlowBattery(years,months,daytypes,hours)
     =E=
     FlowBatteryOutput(years,months,daytypes,hours)
     *FlowBatteryParameter('EfficiencyDischarge');

*TK for now make this a fraction of stored electricity
Equation ElectricityStorageStationaryLossesEq(years,months,daytypes,hours);
     ElectricityStorageStationaryLossesEq(years,months,daytypes,hours)..
     ElectricityStorageStationaryLosses(years,months,daytypes,hours)
     =E=
     ElectricityStoredStationary(years,months,daytypes,hours--1)
     *
     ElectricityStorageStationaryParameter('SelfDischarge');

*TK for now make this a fraction of stored electricity
Equation FlowBatteryLossesEq(years,months,daytypes,hours);
     FlowBatteryLossesEq(years,months,daytypes,hours)..
     FlowBatteryLosses(years,months,daytypes,hours)
     =E=
     FlowBatteryStored(years,months,daytypes,hours--1)
     *(FlowBatteryParameter('SelfDischarge'));

****** electricity stationary storage performance constraints  ***********

*2013/02/22. Lenaig replaced the initial capacity        ( Capacity('ElectricStorage') )
*            by the available capacity after degradation ( ElectricityStorageStationaryCapacity(years,months) )
*            in the charging rate constraint equation.
Equation ElectStorageStationaryChargingRateEq(years,months,daytypes,hours);
     ElectStorageStationaryChargingRateEq(years,months,daytypes,hours)..
     ElectricityStorageStationaryInput(years,months,daytypes,hours)
     =L= ElectricityStorageStationaryCapacity(years,months) * ElectricityStorageStationaryParameter('MaxChargeRate');

*2013/02/22. Lenaig replaced the initial capacity        ( Capacity('ElectricStorage') )
*            by the available capacity after degradation ( ElectricityStorageStationaryCapacity(years,months) )
*            in the discharging rate constraint equation.
Equation ElectStorageStationaryDischargingRateEq(years,months,daytypes,hours);
     ElectStorageStationaryDischargingRateEq(years,months,daytypes,hours)..
     ElectricityStorageStationaryOutput(years,months,daytypes,hours)
     =L= ElectricityStorageStationaryCapacity(years,months) * ElectricityStorageStationaryParameter('MaxDischargeRate');

*2013/02/22. Lenaig replaced the initial capacity        ( Capacity('ElectricStorage') )
*            by the available capacity after degradation ( ElectricityStorageStationaryCapacity(years,months) )
*            in the storage constraint equation.
Equation ElectricityStorageStationaryConstraintEq(years,months,daytypes,hours);
     ElectricityStorageStationaryConstraintEq(years,months,daytypes,hours)..
     ElectricityStoredStationary(years,months,daytypes,hours)
     =L=
     ElectricityStorageStationaryCapacity(years,months);

*2013/02/22. Lenaig replaced the initial capacity        ( Capacity('ElectricStorage') )
*            by the available capacity after degradation ( ElectricityStorageStationaryCapacity(years,months) )
*            in the constraint equation about depth of discharge.
Equation ElectricityStorageStationaryConstraint2Eq(years,months,daytypes,hours);
     ElectricityStorageStationaryConstraint2Eq(years,months,daytypes,hours)..
     ElectricityStoredStationary(years,months,daytypes,hours)
     =G=
     ElectricityStorageStationaryCapacity(years,months)*(1-ElectricityStorageStationaryParameter('MaxDepthOfDischarge'));
*2015/02/02 Dani replace ElectricityStorageStationaryParameter('MaxDepthOfDischarge') by (1-ElectricityStorageStationaryParameter('MaxDepthOfDischarge'))
* make sure that charging and discharging does not happen at the same time
Binary variable ElecStationaryXORCharge(years,months,daytypes,hours);
Equation ElecStationaryChargingEq(years,months,daytypes,hours);
     ElecStationaryChargingEq(years,months,daytypes,hours)..
     ElectricityStorageStationaryInput(years,months,daytypes,hours)
     =L=
     ElecStationaryXORCharge(years,months,daytypes,hours)*1000000;


Equation ElecStationaryDischargingEq(years,months,daytypes,hours);
     ElecStationaryDischargingEq(years,months,daytypes,hours)..
     ElectricityStorageStationaryOutput(years,months,daytypes,hours)
     =L=
     (1-ElecStationaryXORCharge(years,months,daytypes,hours))*1000000;

****** flow battery storage performance constraints  ***********

*2013/03. Lenaig added a year index to all equations in this section about flow batteries.


*TK for now make this proportional to room left to charge
*TK need to discuss with David MacMillan or other on actual charging patterns

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
*TK note flow battery is modeled differently than regular battery to avoid non-linear constraint
Equation FlowBatteryChargingRateEq(years,months,daytypes,hours);
     FlowBatteryChargingRateEq(years,months,daytypes,hours)..
     FlowBatteryInput(years,months,daytypes,hours)
     =L=
     TotalCapacityInYearY('FlowBatteryPower',years);

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
Equation FlowBatteryDischargingRateEq(years,months,daytypes,hours);
     FlowBatteryDischargingRateEq(years,months,daytypes,hours)..
     FlowBatteryOutput(years,months,daytypes,hours)
     =L=
     TotalCapacityInYearY('FlowBatteryPower',years);

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
Equation FlowBatteryStorageConstraintEq(years,months,daytypes,hours);
     FlowBatteryStorageConstraintEq(years,months,daytypes,hours)..
     FlowBatteryStored(years,months,daytypes,hours)
     =L=
     TotalCapacityInYearY('FlowBatteryEnergy',years);

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
Equation FlowBatteryStorageConstraint2Eq(years,months,daytypes,hours);
     FlowBatteryStorageConstraint2Eq(years,months,daytypes,hours)..
     FlowBatteryStored(years,months,daytypes,hours)
     =G=
     TotalCapacityInYearY('FlowBatteryEnergy',years)*(1-FlowBatteryParameter('MaxDepthOfDischarge'));

* make sure that charging and discharging does not happen at the same time
Binary variable FlowBatteryXORCharge(years,months,daytypes,hours);
Equation FlowBatteryChargingEq(years,months,daytypes,hours);
     FlowBatteryChargingEq(years,months,daytypes,hours)..
     FlowBatteryInput(years,months,daytypes,hours)
     =L=
     FlowBatteryXORCharge(years,months,daytypes,hours)*1000000;

Equation FlowBatteryDischargingEq(years,months,daytypes,hours);
     FlowBatteryDischargingEq(years,months,daytypes,hours)..
     FlowBatteryOutput(years,months,daytypes,hours)
     =L=
     (1-FlowBatteryXORCharge(years,months,daytypes,hours))*1000000;

****** Heat Pump Electricity Balance Equations ********
*2013/03. Lenaig added a year index to all equations in this section about heat pumps.

Positive Variables
     ElectricityForASHeatPump(years,months,daytypes,hours)
     ElectricityForGSHeatPump(years,months,daytypes,hours)
     ;

*2013/05/31. Lenaig added lifetime constraints to heat pumps, fixed variables to zero.
HeatingFromASHeatPump.fx(years,MONTHS,DAYTYPES,HOURS)$((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt ContinuousInvestParameter('AirSourceHeatPump','lifetime')) ) = 0;
CoolingFromASHeatPump.fx(years,MONTHS,DAYTYPES,HOURS)$((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt ContinuousInvestParameter('AirSourceHeatPump','lifetime')) ) = 0;
HeatingFromGSHeatPump.fx(years,MONTHS,DAYTYPES,HOURS)$((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt ContinuousInvestParameter('GroundSourceHeatPump','lifetime')) ) = 0;
CoolingFromGSHeatPump.fx(years,MONTHS,DAYTYPES,HOURS)$((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt ContinuousInvestParameter('GroundSourceHeatPump','lifetime')) ) = 0;

Equation ElectricityForHeatPumps_Eq(years,months,daytypes,hours);
     ElectricityForHeatPumps_Eq(years,months,daytypes,hours)..
     ElectricityForHeatPumps(years,months,daytypes,hours)
     =E=
     ElectricityForASHeatPump(years,months,daytypes,hours)
     +
     ElectricityForGSHeatPump(years,months,daytypes,hours);

Equation ElectricityForASHeatPump_Eq(years,months,daytypes,hours);
     ElectricityForASHeatPump_Eq(years,months,daytypes,hours)..
     ElectricityForASHeatPump(years,months,daytypes,hours)
     =E=
     HeatingFromASHeatPump(years,MONTHS,DAYTYPES,HOURS)/HeatPumpParameterValue('AirSourceHeatPump','COP_heating')
     +
     CoolingFromASHeatPump(years,MONTHS,DAYTYPES,HOURS)*COPelectric/HeatPumpParameterValue('AirSourceHeatPump','COP_cooling');

Equation ElectricityForGSHeatPump_Eq(years,months,daytypes,hours);
     ElectricityForGSHeatPump_Eq(years,months,daytypes,hours)..
     ElectricityForGSHeatPump(years,months,daytypes,hours)
     =E=
     HeatingFromGSHeatPump(years,MONTHS,DAYTYPES,HOURS)/HeatPumpParameterValue('GroundSourceHeatPump','COP_heating')
     +
     CoolingFromGSHeatPump(years,MONTHS,DAYTYPES,HOURS)*COPelectric/HeatPumpParameterValue('GroundSourceHeatPump','COP_cooling');

****** cooling constraints  ***********
*Cooling load can be met by electric cooling or abs. cooling

*2013/03. Lenaig added a year index to all variables and equations in this section about cooling.

Positive Variables
     CoolingByElectric(years,months,daytypes,hours)
     CoolingByNGChill(years,months,daytypes,hours)
     CoolingByHeatPumps(years,months,daytypes,hours)
     ;

Equation CoolingProvisionEq(years,months,daytypes,hours);
     CoolingProvisionEq(years,months,daytypes,hours)..

     load(years,'Cooling',months,daytypes,hours)
     =E=
     CoolingByElectric(years,months,daytypes,hours)
     +
     CoolingByAbsorption(years,months,daytypes,hours)
     +
     CoolingByNGChill(years,months,daytypes,hours)
     +
     CoolingByHeatPumps(years,months,daytypes,hours)
     ;

*electricity required for compression chilling
*this is straightforward b.cs. we express cooling loads in terms
*  of electric load equivalent

Equation ElectricCoolingEq(years,months,daytypes,hours);
     ElectricCoolingEq(years,months,daytypes,hours)..
     CoolingByElectric(years,months,daytypes,hours)
     =E=
     OptionsTable('CentralChiller','OptionValue')*ElectricityForCooling(years,months,daytypes,hours);

Equation CoolingByNGChill_Eq(years,months,daytypes,hours);
     CoolingByNGChill_Eq(years,months,daytypes,hours)..
     CoolingByNGChill(years,months,daytypes,hours)
     =E=
     sum(NGChillTech,NGChill_Amount(NGChillTech,years,months,daytypes,hours));

Equation CoolingByHeatPumps_Eq(years,months,daytypes,hours);
     CoolingByHeatPumps_Eq(years,months,daytypes,hours)..
     CoolingByHeatPumps(years,months,daytypes,hours)
     =E=
     CoolingFromASHeatPump(years,MONTHS,DAYTYPES,HOURS)
     +
     CoolingFromGSHeatPump(years,MONTHS,DAYTYPES,HOURS);

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
Equation CoolingFromASHeatPump_Eq(years,months,daytypes,hours);
     CoolingFromASHeatPump_Eq(years,months,daytypes,hours)..
     CoolingFromASHeatPump(years,MONTHS,DAYTYPES,HOURS)
     =L=
     TotalCapacityInYearY('AirSourceHeatPump',years)*HeatPumpParameterValue('AirSourceHeatPump','COP_cooling')/COPelectric;

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
Equation CoolingFromGSHeatPump_Eq(years,months,daytypes,hours);
     CoolingFromGSHeatPump_Eq(years,months,daytypes,hours)..
     CoolingFromGSHeatPump(years,MONTHS,DAYTYPES,HOURS)
     =L=
     TotalCapacityInYearY('GroundSourceHeatPump',years)*HeatPumpParameterValue('GroundSourceHeatPump','COP_cooling')/COPelectric;

Binary Variables
     BinaryASHPheating(years,months,daytypes,hours)
     BinaryASHPcooling(years,months,daytypes,hours)
     BinaryGSHPheating(years,months,daytypes,hours)
     BinaryGSHPcooling(years,months,daytypes,hours);

Equation ASHP_Heat_Or_Cool_Eq(years,months,daytypes,hours);
     ASHP_Heat_Or_Cool_Eq(years,months,daytypes,hours)..
     BinaryASHPheating(years,months,daytypes,hours)
     =E=
     1-BinaryASHPcooling(years,months,daytypes,hours);

Equation ASHP_Cooling_max_Eq(years,months,daytypes,hours);
     ASHP_Cooling_max_Eq(years,months,daytypes,hours)..
     CoolingFromASHeatPump(years,MONTHS,DAYTYPES,HOURS)
     =L=
     BinaryASHPcooling(years,months,daytypes,hours)*1000000;

Equation ASHP_Heating_max_Eq(years,months,daytypes,hours);
     ASHP_Heating_max_Eq(years,months,daytypes,hours)..
     HeatingFromASHeatPump(years,MONTHS,DAYTYPES,HOURS)
     =L=
     BinaryASHPheating(years,months,daytypes,hours)*1000000;

Equation GSHP_Heat_Or_Cool_Eq(years,months,daytypes,hours);
     GSHP_Heat_Or_Cool_Eq(years,months,daytypes,hours)..
     BinaryGSHPheating(years,months,daytypes,hours)
     =E=
     1-BinaryGSHPcooling(years,months,daytypes,hours);

Equation GSHP_Cooling_max_Eq(years,months,daytypes,hours);
     GSHP_Cooling_max_Eq(years,months,daytypes,hours)..
     CoolingFromGSHeatPump(years,MONTHS,DAYTYPES,HOURS)
     =L=
     BinaryGSHPcooling(years,months,daytypes,hours)*1000000;

Equation GSHP_Heating_max_Eq(years,months,daytypes,hours);
     GSHP_Heating_max_Eq(years,months,daytypes,hours)..
     HeatingFromGSHeatPump(years,MONTHS,DAYTYPES,HOURS)
     =L=
     BinaryGSHPheating(years,months,daytypes,hours)*1000000;


Equation GSHP_Annual_Balance_Eq(years);
     GSHP_Annual_Balance_Eq(years)..
     OptionsTable('GSHPAnnualBalance','OptionValue')
     *
     sum(months,
         sum(daytypes,
             sum(hours, CoolingFromGSHeatPump(years,MONTHS,DAYTYPES,HOURS)*COPelectric*(1+1/HeatPumpParameterValue('GroundSourceHeatPump','COP_cooling')))))
     =E=
     OptionsTable('GSHPAnnualBalance','OptionValue')
     *
     sum(months,
         sum(daytypes,
             sum(hours, HeatingFromGSHeatPump(years,MONTHS,DAYTYPES,HOURS)*(1-1/HeatPumpParameterValue('GroundSourceHeatPump','COP_heating')))));


*TK for now, assume COP at 100% for all levels of operation
Equation NG_ForNGChill_Eq(years,months,daytypes,hours);
     NG_ForNGChill_Eq(years,months,daytypes,hours)..
     NG_ForNGChill(years,months,daytypes,hours)
     =E=
     sum(NGChillTech,
          NGChill_Amount(NGChillTech,years,months,daytypes,hours)*COPelectric
          /NGChiller(NGChillTech,'COP_100')
         );


Positive Variable
     HeatForCooling(years,months,daytypes,hours);

*heat required for abs chilling
Equation AbsorptionCoolingEq(years,months,daytypes,hours);
     AbsorptionCoolingEq(years,months,daytypes,hours)..
     CoolingByAbsorption(years,months,daytypes,hours)
     =E=
     HeatForCooling(years,months,daytypes,hours)*COPabs/COPelectric;

*   abs cooling is limited by the size of the abs chiller purchased
*   assume that electric chilling is not limited
*   note abs capacity is in terms of electricity offset
*   this is a problem if the COP electric changes from run to run


****** refrigeration constraints  ***********
*refrigeration load can be met by electric cooling or abs. cooling

*2013/03. Lenaig added a year index to all equations in this section about refrigeration.

Positive Variables
     RefrigerationByElectric(years,months,daytypes,hours);

Equation RefrigerationProvisionEq(years,months,daytypes,hours);
     RefrigerationProvisionEq(years,months,daytypes,hours)..
     load(years,'refrigeration',months,daytypes,hours)
     =E=
     RefrigerationByElectric(years,months,daytypes,hours)
     +
     RefrigerationByAbsorption(years,months,daytypes,hours)
     ;

*    electricity required for compression chilling
*    this is straightforward b.cs. we express cooling loads in terms
*    of electric load equivalent

Equation ElectricRefrigerationEq(years,months,daytypes,hours);
     ElectricRefrigerationEq(years,months,daytypes,hours)..
     RefrigerationByElectric(years,months,daytypes,hours)
     =E=
     ElectricityForRefrigeration(years,months,daytypes,hours);

Parameters
     COPelectric_refr
     COPabs_refr;

COPelectric_refr = COP_Electric_Abs_Refrigeration  ('Electric');
COPabs_refr = COP_Electric_Abs_Refrigeration       ('Absorption');


Positive Variable
     HeatForRefrigeration(years,months,daytypes,hours);

*heat required for abs chilling
Equation AbsorptionRefrigerationEq(years,months,daytypes,hours);
     AbsorptionRefrigerationEq(years,months,daytypes,hours)..
     RefrigerationByAbsorption(years,months,daytypes,hours)
     =E=
     HeatForRefrigeration(years,months,daytypes,hours)*COPabs/COPelectric;

*   abs cooling is limited by the size of the abs chiller purchased
*   assume that electric chilling is not limited
*   note abs capacity is in terms of electricity offset
*   this is a problem if the COP electric changes from run to run


****** thermal balance, top level equations ***************
*2013/03. Lenaig added a year index to all equations in this section about heat.

*tk eventually may want to do this twice, for two different qualities of heat
*tk possibly also one more time for cold storage

Positive Variables
* HeatProvided (months, daytypes,hours)
     HT_HeatProvided_for_HT (years, months, daytypes, hours)
     HT_HeatProvided_for_LT (years, months, daytypes, hours)
     LT_HeatProvided (years, months, daytypes, hours)

     Heat_FromNG(years, months, daytypes,hours)
     Heat_FromDG(years, months,daytypes,hours)
     Heat_FromSolar(years, months,daytypes,hours)
     Heat_FromNGChill(years, months,daytypes,hours)
     Heat_FromHeatPumps(years, months,daytypes,hours)
     ;


* NEW HEAT PROVIDED EQUATIONS
Equation HT_HeatProvided_Eq (years,months,daytypes,hours);
     HT_HeatProvided_Eq (years,months,daytypes,hours)..
     HT_HeatProvided_for_HT (years,months,daytypes,hours)
     +
     HT_HeatProvided_for_LT (years,months,daytypes,hours)
     =E=
     Heat_FromNG(years,months,daytypes,hours)
     +
     Heat_FromDG(years,months,daytypes,hours)
     +
     Heat_FromSolar(years,months,daytypes,hours)
     +
     Heat_FromStorage(years,months,daytypes,hours)
     +
     Heat_FromNGChill(years,months,daytypes,hours)
     ;

Equation LT_HeatProvided_Eq (years,months,daytypes,hours);
        LT_HeatProvided_Eq (years,months,daytypes,hours)..
        LT_HeatProvided (years,months,daytypes,hours)
        =E=
        Heat_FromHeatPumps(years,months,daytypes,hours)
        ;


* OLD HEAT PROVIDED EQUATION
* Equation HeatProvidedEq (months, daytypes,hours);
*     HeatProvidedEq(months, daytypes,hours)..
*     HeatProvided (months, daytypes,hours)
*     =E=
*     Heat_FromNG(months, daytypes,hours)
*     +
*     Heat_FromDG(months,daytypes,hours)
*     +
*     Heat_FromSolar(months,daytypes,hours)
*     +
*     Heat_FromStorage(months,daytypes,hours)
*     +
*     Heat_FromNGChill(months,daytypes,hours)
*     +
*     Heat_FromHeatPumps(months,daytypes,hours)
*     ;

Positive Variables
     HeatStored(years,months,daytypes,hours)
     HeatStorageInput(years,months,daytypes,hours)
     HeatStorageOutput(years,months,daytypes,hours)
     HeatStorageLosses(years,months,daytypes,hours)
     ;

Equation HeatStoredEq (years,months,daytypes,hours);
     HeatStoredEq(years,months,daytypes,hours)..
     HeatStored(years,months,daytypes,hours)
     =E=
     HeatStored(years,months,daytypes,hours--1)
     +
     HeatStorageInput(years,months,daytypes,hours)
     -
     HeatStorageOutput(years,months,daytypes,hours)
     -
     HeatStorageLosses(years,months,daytypes,hours)
     ;

Positive Variables
*    HeatConsumed(months,daytypes,hours)
     HT_HeatConsumed (years,months,daytypes,hours)
     LT_HeatConsumed (years,months,daytypes,hours)

     HeatForSpaceHeating(years,months,daytypes,hours)
     HeatForWaterHeating(years,months,daytypes,hours)
     HeatForStorage(years,months,daytypes,hours)
     ;

* NEW HEAT CONSUMED EQUATIONS
Equation HT_HeatConsumed_Eq (years,months,daytypes,hours);
        HT_HeatConsumed_Eq (years,months, daytypes, hours)..
        HT_HeatConsumed (years,months,daytypes,hours)
        =E=
        HeatForCooling (years,months,daytypes,hours)
        +
        HeatForRefrigeration (years,months,daytypes,hours)
        +
        HeatForStorage(years,months,daytypes,hours)
        ;

Equation LT_HeatConsumed_Eq (years,months,daytypes,hours);
     LT_HeatConsumed_Eq (years,months,daytypes,hours)..
     LT_HeatConsumed (years,months,daytypes,hours)
     =E=
     HeatForSpaceHeating(years,months,daytypes,hours)
     +
     HeatForWaterHeating(years,months,daytypes,hours)
     -
     sum(DemandResponseType,DemandResponseHeating(DemandResponseType,years,months,daytypes,hours))
     ;


* OLD HEAT CONSUMED EQUATION
* Equation HeatConsumedEq(months,daytypes,hours);
*     HeatConsumedEq(months,daytypes,hours)..
*     HeatConsumed(months,daytypes,hours)
*    =E=
*    HeatForSpaceHeating(months,daytypes,hours)
*    +
*    HeatForWaterHeating(months,daytypes,hours)
*    +
*    HeatForCooling(months,daytypes,hours)
*    +
*    HeatForRefrigeration(months,daytypes,hours)
*    +
*    HeatForStorage(months,daytypes,hours)
*    -sum(DemandResponseType,DemandResponseHeating(DemandResponseType,months,daytypes,hours))
*    ;

* NEW HEAT BALANCE EQUATIONS

Equation HT_HeatBalance_Eq (years,months,daytypes,hours);
        HT_HeatBalance_Eq (years,months,daytypes,hours)..
        HT_HeatProvided_for_HT (years,months,daytypes,hours)
        =E=
        HT_HeatConsumed (years,months,daytypes,hours)
        ;

Equation LT_HeatBalance_Eq (years,months,daytypes,hours);
        LT_HeatBalance_Eq (years,months,daytypes,hours)..
        HT_HeatProvided_for_LT (years,months,daytypes,hours)
        +
        LT_HeatProvided (years,months,daytypes,hours)
        =E=
        LT_HeatConsumed (years,months,daytypes,hours)
        ;


* OLD HEAT BALANCE EQUATION
* Equation HeatBalanceEq (months,daytypes,hours);
*      HeatBalanceEq (months,daytypes,hours)..
*      HeatProvided(months,daytypes,hours)
*      =E=
*
*      HeatConsumed(months,daytypes,hours)
*      ;


*********  thermal balance, lower level equations  **********


Equation Heat_FromNGEq(years,months,daytypes,hours);
     Heat_FromNGEq(years,months,daytypes,hours)..
     Heat_FromNG(years,months,daytypes,hours)
     =E=
     NG_ForHeat(years,months,daytypes,hours)*Beta('Space-heating');

Positive Variable     Heat_fromNo_SGIP_DG(years,months,daytypes,hours);
Positive Variable     Heat_from_SGIP_DG(years,months,daytypes,hours);


Equation Heat_fromDG_Eq(years,months,daytypes,hours);
         Heat_fromDG_Eq(years,months,daytypes,hours)..
         Heat_fromDG(years,months,daytypes,hours)
         =L=
         sum(AvailableCHPTechnologies, deropt(AvailableCHPTechnologies, 'alpha') *
                                     ( Generation_Use (AvailableCHPTECHNOLOGIES, years, months, daytypes, hours)
                                       + Generation_Sell (AvailableCHPTECHNOLOGIES, years, months, daytypes, hours)
                                      )
         );

Equation Heat_from_SGIP_DG_Eq(years,months,daytypes,hours);
         Heat_from_SGIP_DG_Eq(years,months,daytypes,hours)..
         Heat_from_SGIP_DG(years,months,daytypes,hours)
         =L=
         sum(AvailableSGIPTechnologies, deropt(AvailableSGIPTechnologies, 'alpha') *
                                     ( Generation_Use (AvailableSGIPTECHNOLOGIES, years, months, daytypes, hours)
                                       + Generation_Sell (AvailableSGIPTECHNOLOGIES, years, months, daytypes, hours)
                                      )
         );

Equation Heat_fromNo_SGIP_DG_Eq(years,months,daytypes,hours);
         Heat_fromNo_SGIP_DG_Eq(years,months,daytypes,hours)..
         Heat_fromNo_SGIP_DG(years,months,daytypes,hours)
         =E=
         Heat_fromDG(years,months,daytypes,hours) - Heat_from_SGIP_DG(years,months,daytypes,hours)
         ;


* for Equation Heat_FromSolarEq(months,daytypes,hours) see solar thermal modelling section


Equation Heat_FromStorageEq(years,months,daytypes,hours);
     Heat_FromStorageEq(years,months,daytypes,hours)..
     Heat_FromStorage(years,months,daytypes,hours)
    =E=
     HeatStorageOutput(years,months,daytypes,hours)
     *HeatStorageParameter('EfficiencyDischarge');

Equation Heat_FromNGChill_Eq (years,months,daytypes,hours);
     Heat_FromNGChill_Eq (years,months,daytypes,hours)..
     Heat_FromNGChill (years,months,daytypes,hours)
     =E=
     sum(NGChillTech,
          NGChill_Amount(NGChillTech,years,months,daytypes,hours)
          *NGChiller(NGChillTech,'CHPenable')
          *NGChiller(NGChillTech,'alpha')
         );

Equation Heat_FromHeatPumps_Eq(years,months,daytypes,hours);
     Heat_FromHeatPumps_Eq(years,months,daytypes,hours)..
     Heat_FromHeatPumps(years,months,daytypes,hours)
     =E=
     HeatingFromASHeatPump(years,MONTHS,DAYTYPES,HOURS)
     +
     HeatingFromGSHeatPump(years,MONTHS,DAYTYPES,HOURS);

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
Equation HeatingFromASHeatPump_Eq(years,months,daytypes,hours);
     HeatingFromASHeatPump_Eq(years,months,daytypes,hours)..
     HeatingFromASHeatPump(years,MONTHS,DAYTYPES,HOURS)
     =L=
     TotalCapacityInYearY('AirSourceHeatPump',years)*HeatPumpParameterValue('AirSourceHeatPump','COP_heating');

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
Equation HeatingFromGSHeatPump_Eq(years,months,daytypes,hours);
     HeatingFromGSHeatPump_Eq(years,months,daytypes,hours)..
     HeatingFromGSHeatPump(years,MONTHS,DAYTYPES,HOURS)
     =L=
     TotalCapacityInYearY('GroundSourceHeatPump',years)*HeatPumpParameterValue('GroundSourceHeatPump','COP_heating');

Equation HeatStorageInputEq(years,months,daytypes,hours);
     HeatStorageInputEq(years,months,daytypes,hours)..
     HeatStorageInput(years,months,daytypes,hours)
     =E=
     HeatForStorage(years,months,daytypes,hours)
     *HeatStorageParameter('EfficiencyCharge');

Equation HeatStorageLossesEq(years,months,daytypes,hours);
     HeatStorageLossesEq(years,months,daytypes,hours)..
     HeatStorageLosses(years,months,daytypes,hours)
     =E=
     HeatStored(years,months,daytypes,hours--1)
     *HeatStorageParameter('Decay');

Equation HeatForSpaceHeatingEq(years,months,daytypes,hours);
     HeatForSpaceHeatingEq(years,months,daytypes,hours)..
     HeatForSpaceHeating(years,months,daytypes,hours)
     =E=
     load (years,'space-heating', months, daytypes, hours);

Equation HeatForWaterHeatingEq(years,months,daytypes,hours);
     HeatForWaterHeatingEq(years,months,daytypes,hours)..
     HeatForWaterHeating(years,months,daytypes,hours)
     =E=
     load (years,'Water-heating', months, daytypes, hours);

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
Equation HeatStorageConstraint1Eq(years,months,daytypes,hours);
     HeatStorageConstraint1Eq(years,months,daytypes,hours)..
     HeatStored(years,months,daytypes,hours)
     =L=
     TotalCapacityInYearY('HeatStorage',years);

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
Equation HeatStorageConstraint2Eq(years,months,daytypes,hours);
     HeatStorageConstraint2Eq(years,months,daytypes,hours)..
     HeatStorageOutput(years,months,daytypes,hours)
     =L=
     TotalCapacityInYearY('HeatStorage',years)*HeatStorageParameter('MaxDischargeRate');

*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered.
Equation HeatStorageConstraint3Eq(years,months,daytypes,hours);
     HeatStorageConstraint3Eq(years,months,daytypes,hours)..
     HeatStorageInput(years,months,daytypes,hours)
     =L=
     (TotalCapacityInYearY('HeatStorage',years)-HeatStored(years,months,daytypes,hours--1))*HeatStorageParameter('MaxChargeRate');

* ------------------------------
* MAXIMUM ANNUAL HOURS CONSTRAINT
*2013/03. Lenaig added a year index to this equation.
*2013/05/31. Lenaig modified this equation to consider the total capacity available in the year considered thanks to the year-counter.
Equation MaximumAnnualHoursEq (TECHNOLOGIES,years);
MaximumAnnualHoursEq (AvailableTECHNOLOGIES,years)..
     sum((months, daytypes, hours), DER_CurrentlyOperating(AvailableTECHNOLOGIES,years,months,daytypes,hours)*NumberOfDays(Months,Daytypes))
     =L=
     sum(years_counter $(years_counter.val le deropt(AvailableTechnologies,'lifetime')),
         DER_Investment (AvailableTECHNOLOGIES,years - (years_counter.val-1))* GenConstraints(AvailableTECHNOLOGIES,'MaxAnnualHours')
     );

*----------Load Scheduling Constraints----------------
*2013/03. Lenaig added a year index to all load scheduling equations in this section.

Equation LoadSchedulingEq_1(years,months,daytypes,hours);
     LoadSchedulingEq_1(years,months,daytypes,hours)..
     LoadReduction(years,months,daytypes,hours)
     =L=
     ReductionOrAddition(years,months,daytypes,hours)*SchedulableLoadParameterTable('MaxLoadinHour','ParameterValue');

Equation LoadSchedulingEq_2(years,months,daytypes,hours);
     LoadSchedulingEq_2(years,months,daytypes,hours)..
     LoadIncrease(years,months,daytypes,hours)
     =L=
     (1-ReductionOrAddition(years,months,daytypes,hours))* SchedulableLoadParameterTable('MaxIncrease','ParameterValue');

Equation LoadSchedulingEq_3(years,months,daytypes);
     LoadSchedulingEq_3(years,months,daytypes)..
     sum(hours, LoadReduction(years,months,daytypes,hours))
     =L=
     MaxShiftableLoad(years,months,daytypes);

Equation LoadSchedulingEq_4 (years,months,daytypes);
         LoadSchedulingEq_4  (years,months,daytypes)..
         sum(hours,LoadReduction(years,months,daytypes,hours))
         =e=sum(hours,Loadincrease(years,months,daytypes,hours));

*************************************************************
* -------------  SGIP REQUIREMENTS --------------------------
*************************************************************
*2013/03. Lenaig added a year index to the variables and the equations in this SGIP section.

* --- Waste Heat & Electricity Utilization ------------------

Positive Variable AnnualDGSGIPElectricity(years);
Positive Variable AnnualDGSGIPRecHeat(years);
Positive Variable AnnualNGforDGSGIP(years);

Equation AnnualDGSGIPElectricityEq(years);
         AnnualDGSGIPElectricityEq(years)..
         AnnualDGSGIPElectricity(years)
         =E=
         sum((AvailableSGIPTECHNOLOGIES,months,daytypes,hours),
                 ( Generation_Use(AvailableSGIPTECHNOLOGIES,years,months,daytypes,hours) + Generation_NetworkSales(AvailableSGIPTECHNOLOGIES,years,months,daytypes,hours)
*2015/01/22 Dani changed Generation_Sell by Generation_NetworkSales
                 )* NumberOfDays(Months,Daytypes));


Equation AnnualDGSGIPRecHeatEq(years);
         AnnualDGSGIPRecHeatEq(years)..
         AnnualDGSGIPRecHeat(years)
         =E=
         sum((months,daytypes,hours), Heat_from_SGIP_DG(years,months,daytypes,hours)*NumberOfDays(months,daytypes));


Equation AnnualNGforDGSGIPEq(years);
         AnnualNGforDGSGIPEq(years)..
         AnnualNGforDGSGIP(years)
         =E=
         sum((AvailableSGIPTECHNOLOGIES,months,daytypes,hours)$(deropt(AvailableSGIPTECHNOLOGIES,'fuel')=FuelValue('NGforDG')),
         ( Generation_Use(AvailableSGIPTECHNOLOGIES,years,months,daytypes,hours) + Generation_Sell(AvailableSGIPTECHNOLOGIES,years,months,daytypes,hours) )* (1/deropt(AvailableSGIPTECHNOLOGIES,'efficiency'))
         * NumberOfDays(months,daytypes)
         );

* T / (T + E) >= 5%
Equation SGIP_Thermal_Efficiency_Req_Eq(years);
         SGIp_Thermal_Efficiency_Req_Eq(years)..
         AnnualDGSGIPRecHeat(years)
         =G=
         ( AnnualDGSGIPRecHeat(years) + AnnualDGSGIPElectricity(years) )
         *
         SGIPOptions('MinSGIPHeatRecovered', 'OptionValue');

* (E + 0.5 T) / F >= 42.5%
Equation SGIP_LHV_Requirement_Eq(years);
         SGIP_LHV_Requirement_Eq(years)..
         AnnualDGSGIPElectricity(years) + AnnualDGSGIPRecHeat(years) * 0.5
         =G=
         AnnualNGforDGSGIP (years)* SGIPOptions('MinSGIPLHVefficiency', 'OptionValue');

* (E+T) / F >= 60%
Equation SGIP_HHV_Requirement_Eq(years);
         SGIP_HHV_Requirement_Eq(years)..
         AnnualDGSGIPElectricity (years)+ AnnualDGSGIPRecHeat(years)
         =G=
         AnnualNGforDGSGIP(years) * SGIPOptions('MinSGIPHHVefficiency', 'OptionValue');

* E / F >= 40%
Equation SGIP_HHV_Electric_Requirement_Eq(years);
         SGIP_HHV_Electric_Requirement_Eq(years)..
         AnnualDGSGIPElectricity(years)
         =G=
         AnnualNGforDGSGIP(years) * SGIPOptions('MinSGIPHHVElectricEfficiency', 'OptionValue');

* S <= 25% * G
Equation SGIP_Sales_Limit_Eq(years);
         SGIP_Sales_Limit_Eq(years)..
         TotalElectricitySales(years) * SGIPOptions('enableSGIP', 'OptionValue')
         =L=
         SGIPOptions('MaxElectricityExport', 'OptionValue')
         *
         sum ((months, daytypes, hours), Electricity_Generation(years,months, daytypes, hours))
         ;

*2013/05/31. Lenaig modified this equation to consider the capacity from the total capacity available in the year considered thanks to the year-counter.
Equation SGIP_Max_CHP_Capacity_Eq(years);
         SGIP_Max_CHP_Capacity_Eq(years)..
         sum(AvailableCHPTECHNOLOGIES,
              sum(years_counter $(years_counter.val le deropt(AvailableCHPTechnologies,'lifetime')),
                 DER_Investment (AvailableCHPTECHNOLOGIES,years - (years_counter.val-1)) * deropt (AvailableCHPTECHNOLOGIES, 'maxp')))
         * SGIPOptions ('enableSGIP','OptionValue')
         =L=
         max_electric_load;
*
* --- PBI Payments -------------------------
*

* NPV Net Present Cost
* EAC Equivalent Annual Cost

*2013/03. Lenaig added a year index to the variable 'PBI_Payment(...)' and the equation 'PBI_Payment_EQ(...)'

Positive Variables
         PBI_Payment(Technologies, SGIP_Years, years)
*2013/05/31. Lenaig modified PBI_NPV(Technologies).
*        PBI_NPV(years)  needs to be declared before totalenergycosts
         PBI_EAC(Technologies);
*        PBI_INCENTIVE needs to be declared before totalenergycosts


Equation PBI_Payment_Eq(Technologies, SGIP_Years, years);
         PBI_Payment_Eq(AvailableSGIPTechnologies, SGIP_Years, years)..
         PBI_Payment(AvailableSGIPTechnologies, SGIP_Years, years)$(SGIP_Years.val eq years.val)
         =E=
         PBI_CO2_Adjustment(AvailableSGIPTechnologies) * 0.2 * 0.5 * SGIPIncentiveAmount(AvailableSGIPTechnologies)
         *
         sum((months,daytypes,hours), Generation_Use(AvailableSGIPTechnologies, years, months, daytypes, hours)* NumberOfDays(months, daytypes) )
         / ( DEROPT(AvailableSGIPTechnologies, 'maxp') * 8760 * 0.8 )
         ;

*2013/05/31. Lenaig modified this equation to get PBI_NPV(years).
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation PBI_NPV_Eq(years);
         PBI_NPV_Eq(years)..
         PBI_NPV(years)
         =E=
         sum(AvailableSGIPTechnologies,
             sum(SGIP_Years$(SGIP_Years.val eq years.val),
                 PBI_Payment(AvailableSGIPTechnologies, SGIP_Years, years)/((1+ParameterTable('IntRate','ParameterValue')) ** ord(years))
                 )
         );

*2013/05/31. Lenaig put the two following equations in text mode.
$ontext
Equation PBI_EAC_Eq(Technologies);
         PBI_EAC_Eq(AvailableSGIPTechnologies)..
         PBI_EAC(AvailableSGIPTechnologies)
         =E=
         PBI_NPV(AvailableSGIPTechnologies) * ParameterTable('IntRate','ParameterValue') / ( 1 - 1 / ( 1 + ParameterTable('IntRate','ParameterValue') ) ** 5 )
         ;

Equation PBI_INCENTIVE_Eq;
         PBI_INCENTIVE_Eq..
         PBI_INCENTIVE
         =E=
         sum(AvailableSGIPTechnologies, PBI_EAC(AvailableSGIPTechnologies))
         ;
$offtext

*****************************************************
*---------------Feed In Tariff Requirements----------
*****************************************************
*2013/03. Lenaig added a year index to all variables and equations in this section about feed-in tariff (except 'CapacityConstraintFeedingEq' equation).

Positive variable
Annual_Heat_from_CHP (years)
Annual_Electricity_from_CHP (years)
;

Equation Annual_Heat_from_CHP_Eq(years);
         Annual_Heat_from_CHP_Eq(years)..
         Annual_Heat_from_CHP(years)
         =E=
         sum((months, daytypes, hours), heat_fromDG(years,months,daytypes,hours)*NumberOfDays(months,daytypes));

Equation Annual_Electricity_from_CHP_Eq(years);
         Annual_Electricity_from_CHP_Eq(years)..
         Annual_Electricity_from_CHP(years)
         =E=
         sum( (AvailableCHPTECHNOLOGIES, months, daytypes, hours),
            ( Generation_Use (AvailableCHPTECHNOLOGIES, years, months, daytypes, hours)
               + Generation_NetworkSales (AvailableCHPTECHNOLOGIES, years, months, daytypes, hours) )
*2015/01/22 Dani changed Generation_Sell by Generation_NetworkSales
            * NumberOfDays(months,daytypes) );

* T / ( T + E ) >= 5%
Equation Minimum_Heat_Recovery_FeedIn_Eq(years);
         Minimum_Heat_Recovery_Feedin_Eq(years)..
         Annual_Heat_from_CHP (years)
         =G=
         OptionsTable ('Sales','OptionValue') * FeedInOptions('MinHeatRecovered', 'OptionValue') * ( Annual_Heat_from_CHP(years) + Annual_Electricity_from_CHP(years));

* ( E + 0.5 T ) / F >= 42.5%
Equation LHV_Efficiency_Constraint_Feedin_Eq(years);
         LHV_Efficiency_Constraint_Feedin_Eq(years)..
         Annual_Electricity_from_CHP(years) + 0.5 * Annual_Heat_from_CHP(years)
         =G=
         OptionsTable ('Sales','OptionValue') * FeedInOptions('MinLHVefficiency', 'OptionValue') * sum(months, NGforCHPDGConsumption(years,months));

* ( E + T ) / F >= 60%
Equation HHV_Efficiency_Constraint_Feedin_Eq(years);
         HHV_Efficiency_Constraint_Feedin_Eq(years)..
         Annual_Electricity_from_CHP(years) + Annual_Heat_from_CHP(years)
         =G=
         OptionsTable ('Sales','OptionValue') * FeedInOptions('MinHHVefficiency', 'OptionValue') * sum(months, NGforCHPDGConsumption(years,months));

* MAX EXPORT = 5MW
Equation ElectricSalesLimitEq (years, months, daytypes, hours);
         ElectricSalesLimitEq (years, months, daytypes, hours)..
         ElectricSales(years, months, daytypes, hours)
         =L=
         FeedInOptions('MaxExportCapacity', 'OptionValue');

*2013/05/31. Lenaig modified this equation to consider the capacity from the latest investments.
* MAX CHP CAPACITY = 20MW
Equation CapacityConstraintFeedinEq(years);
         CapacityConstraintFeedinEq(years)..
         sum(AvailableCHPTECHNOLOGIES,
              sum(years_counter $(years_counter.val le deropt(AvailableCHPTechnologies,'lifetime')),
                   DER_Investment(AvailableCHPTECHNOLOGIES,years - (years_counter.val - 1))
                   * deropt (AvailableCHPTECHNOLOGIES, 'maxp')
         ))*OptionsTable ('Sales','OptionValue')
         =L=
         FeedInOptions('MaxInstalledCapacity','OptionValue');

* ------------------

* -------------  INVESTMENT CONSTRAINTS  ---------------------------------------
*2013/03. Lenaig replaced the 'AnnualSavingsEq' equation that calculates savings over the typical year by an 'AllPeriodSavingsEq' equation that sums annual savings.

*2013/06/06. Lenaig did not calculate the present values of 'BaseCaseCost', 'TotalEnergyCosts(years)' and 'AnnualizedCapitalCost(years)' in this equation because they are already present values.
Equation AllPeriodSavingsEq;
     AllPeriodSavingsEq..
     AllPeriodSavings
         =E=
         sum(years,ParameterTable('BaseCaseCost','ParameterValue')
                   -
                   (TotalEnergyCosts(years) - AnnualizedCapitalCost(years))
         );

*2013/05/31. Lenaig put the payback constraint active and modified it by replacing UpfrontCapitalCost by UpfrontCapitalCost(years).
Equation PaybackConstraintEq;
PaybackConstraintEq..
      AllPeriodSavings / card(years)
      =G=
      sum(years,UpfrontCapitalCost(years))/ParameterTable('MaxPaybackPeriod','ParameterValue');

* ------------------
*2013/03. Lenaig added a year index to all equations in this section.

* Annual Electricity Output from Natural Gas fired units
Equation NGforDER_ElectricProductionEq (years);
         NGforDER_ElectricProductionEq(years) ..
         NGforDER_ElectricityProduction(years)
         =E=
         sum((AvailableTECHNOLOGIES,months,daytypes,hours)$(deropt(AvailableTECHNOLOGIES,'fuel')=4),
         Generation_Use(AvailableTECHNOLOGIES,years,months,daytypes,hours)*NumberOfDays(months,daytypes))
         +sum((AvailableTECHNOLOGIES,months,daytypes,hours)$(deropt(AvailableTECHNOLOGIES,'fuel')=4),
         Generation_Sell(AvailableTECHNOLOGIES,years,months,daytypes,hours)*NumberOfDays(months,daytypes));

* Annual Total NG Consumed for DER Generators
Equation NGforDER_ConsumedEnergyEq(years);
         NGforDER_ConsumedEnergyEq(years) ..
         NGforDER_ConsumedEnergy(years)
         =E=
         sum(  (AvailableTECHNOLOGIES,months,daytypes,hours)$(deropt(AvailableTECHNOLOGIES,'fuel')=4),
         Generation_Use(AvailableTECHNOLOGIES,years,months,daytypes,hours)*(1/deropt(AvailableTECHNOLOGIES,'efficiency'))*NumberOfDays(months,daytypes)  )
         + sum(         (AvailableTECHNOLOGIES,months,daytypes,hours)$(deropt(AvailableTECHNOLOGIES,'fuel')=4),
         Generation_Sell(AvailableTECHNOLOGIES,years,months,daytypes,hours)*(1/deropt(AvailableTECHNOLOGIES,'efficiency'))*NumberOfDays(months,daytypes)   )
         ;

*2013/05/31. Lenaig calculated the present value of electricity annual sales ($).
*2014/06/13. Lenaig changed "ord(years)-1" to "ord(years)".
Equation Electricity_AnnualSalesEq(years);
         Electricity_AnnualSalesEq(years) ..
         AnnualElectricitySales(years)
         =E=
         sum ((months, daytypes, hours), ElectricSales(years, months, daytypes, hours) * PX(years,months, daytypes, hours) * NumberOfDays (months, daytypes))
         *(1/(1+ParameterTable('IntRate','ParameterValue'))** ord(years))
         ;

Equation Electricity_TotalSalesEq(years);
         Electricity_TotalSalesEq(years) ..
         TotalElectricitySales(years)
         =E=
         sum ((months, daytypes, hours), ElectricSales(years,months, daytypes, hours) * NumberOfDays (months, daytypes))
         ;


Equation NetMeteringEq(years);
    NetMeteringEq(years)..
    AnnualElectricConsumption (years)=G=  TotalElectricitySales(years)*NetmeteringOnOff;

*2013/05/31. Lenaig added a year index and considered the total installed capacities that are available.
Equation CapacityConstraintEq(years);
    CapacityConstraintEq(years)..
    sum (AvailableTECHNOLOGIES,
         sum(years_counter $(years_counter.val le deropt(AvailableTechnologies,'lifetime')),
                 DER_Investment(AvailableTECHNOLOGIES,years -(years_counter.val-1))
                 * deropt (AvailableTECHNOLOGIES, 'maxp')))
    =L= smin((months,daytypes,hours),TotalELoad(years,months,daytypes,hours))*InvestmentConstOnOff;

* ------------------

* -------------  ZNEB CONSTRAINTS  ---------------------------------------
*2013/03. Lenaig added a year index.
Equation ZNEB_Balance(years);
ZNEB_Balance(years)..
        (AnnualElectricConsumption(years)-TotalElectricitySales(years))/ParameterTable('macroeff','ParameterValue')+AnnualNGConsume(years)
        =E= 0;

* ------------------

* ------------------ Solar thermal efficiency modeling  -------------------------------


set solarsettings /n0, a1, InletWaterTemp, OutletWaterTemp, epsilon/;
* n0 and a1 are the coefficients used in the calculation of solar thermal efficiency
* epsilon is used to get rid of a division by zero problem
* model based on http://www.solarenergy.ch/spf.php?lang=en&fam=1&tab=3
* Based on a dozen of collector reports, we obtained average values for n0, a1 and a2.
* Then we looked for the closest linear approximation and obtained n0 = 0.8212, a1 = 5.1614 .
* See also “calculation for solar thermal efficiency.xls” for more details.
* We used collectors that received SPF quality label from http://www.solarenergy.ch/spf.php?lang=en&fam=1&tab=1 until may 11th.
Parameter ParameterSolarThermal(solarsettings)
* Temp. in °Celsius
/          n0                          0.8212
           a1                          5.1614
           InletWaterTemp              18
           OutletWaterTemp             60
           epsilon                     0.0001/;

parameter SolarThermalEfficiency1(months,hours);
SolarThermalEfficiency1(months,hours)
     =
        ParameterSolarThermal('n0')-ParameterSolarThermal('a1')*((ParameterSolarThermal('InletWaterTemp')+ParameterSolarThermal('OutletWaterTemp'))/2-AmbientHourlyTemperature(months, hours))/(SolarInsolation(months,hours)*1000+ParameterSolarThermal('epsilon'));

* This avoids negative efficiencies
parameter SolarThermalEfficiency(months,hours);
SolarThermalEfficiency(months,hours)=(SolarThermalEfficiency1(months,hours)+abs(SolarThermalEfficiency1(months,hours)))/2;

scalar SolarRadiationThreshold /0.0/;
*if solar radiation > SolarRadiationThreshold then solar radiation is included in the calculation of the average efficiency

parameter DaysPerMonth(months);
DaysPerMonth(months)=sum (daytypes, NumberOfDays (months, daytypes));

scalar CounterForAveragedEfficiency  /0/;
scalar  SumForAverageEfficiency /0/;
*sum of hourly solar thermal efficiency when solar radiation > SolarRadiationThreshold
scalar SolarThermalAverageEfficiency /0/;

SumForAverageEfficiency = sum((months,hours)$(SolarInsolation(months,hours)>SolarRadiationThreshold), SolarThermalEfficiency(months,hours)*DaysPerMonth(months));
CounterForAveragedEfficiency  = sum((months,hours)$(SolarInsolation(months,hours)>SolarRadiationThreshold),DaysPerMonth(months));

SolarThermalAverageEfficiency =  SumForAverageEfficiency/(CounterForAveragedEfficiency+ParameterSolarThermal('epsilon'));

scalar PeakSolarThermalEfficiency             /.75/
scalar EffectiveAreaFactor  considers also not effective area (roughly 7% of the a solar panel is not used by the absorber)  /.9333/
positive variable SolarThermalArea(years);

*2013/05/31. Lenaig added a year index to this equation and considered the total capacity available in the year considered.
Equation SolarThermalAreaEq(years);
         SolarThermalAreaEq(years)..
         SolarThermalArea(years) =E= TotalCapacityInYearY('solarthermal',years)/(PeakSolarThermalEfficiency*EffectiveAreaFactor);

*2013/05/31. Lenaig added a year index to this equation and considered the total capacity available in the year considered.
Equation Heat_FromSolarEq(years,months,daytypes,hours);
     Heat_FromSolarEq(years,months,daytypes,hours)..
     Heat_FromSolar(years,months,daytypes,hours)
     =L= TotalCapacityInYearY('SolarThermal',years)/PeakSolarThermalEfficiency * SolarThermalEfficiency(months,hours) * SolarInsolation(months,hours);

* ------------------

* ------------------  PV efficiency modeling  -------------------------------
* Source : "Comparison of Predicted to Measured Photovoltaic Module Performance", A. Hunter et al., Journal of Solar Energy Engineering
* MAY 2009, Vol. 131 / 021011-1.
* Adapted by Nico Hotz, postdoc at the Mechanical Engineering department at UC Berkeley, hotz@berkeley.edu
* Please note some parameters from the original model are not used in this simplified model

set PVsettings / A, E0, T0, a0, a1, a2, a3, a4,  I_sc0, alfa_Isc, aPV, b, I_mp0,
                 alfa_Imp, c0, c1, V_oc0, n, Ns, beta_Voc, V_mp0, beta_Vmp, c2, c3, AMa, kBYq /;

* Sanyo H168 PSEL2115 PV cell characteristics are used from http://photovoltaics.sandia.gov/docs/Database.htm
* Area =1.19m^2, (35.2" x 51.9"). Weight = 23 kg  (51 lb).
* Bifacial module with 96  large-area (100 cm^2) HIT (heterojunction with intrinsic thin layer)
* high-efficiency crystalline silicon cells connected in series.
* Aluminum frame, tempered glass front sheet, glass  backsheet, module laminated with  EVA encapsulant. Pre-production.
Parameter ParameterPV(PVsettings)
* E0: reference solar spectrum, 1000 W/m2
* T0: reference cell temperature, 25°C
/   A           1.19
    E0          1000.00
    T0          25
    a0          0.92619
    a1          0.062356
    a2          -0.010119
    a3          0.00067031
    a4          -0.000016221
    I_sc0       4.104
    alfa_Isc    0.000458
    aPV         -3.27
    b           -0.107
    I_mp0       3.819
    alfa_Imp    0.000082
    c0          0.9981
    c1          0.0019
    V_oc0       67.1
    n           1.165
    Ns          96
    beta_Voc    -0.1915
    V_mp0       53.98
    beta_Vmp    -0.1682
    c2          -0.30396
    c3          -9.22773
    AMa         1.5
    kBYq        0.0000861738
/
;

* The original model also considers E_b= ParameterPV('E0')*cos(ParameterPV('AOI')) and
* E_diff(months,hours) = SolarInsolation*1000-E_b(months,hours);
* E_B and E_diff influences
* f2_AOI = ParameterPV('b0')+ParameterPV('b1')*ParameterPV('AOI')+ParameterPV('b2')*ParameterPV('AOI')**2+ParameterPV('b3')*ParameterPV('AOI')**3+ParameterPV('b4')*ParameterPV('AOI')**4+ParameterPV('b5')*ParameterPV('AOI')**5;
* But, f2_AOI is close to 1 so that we neglect it for our purpose and we set
* E_b(months,hours)*f2_AOI + ParameterPV('f_d')*E_diff(months,hours) in
* I_sc(months,hours) = ParameterPV('I_sc0')*f1_AMa*(E_b(months,hours)*f2_AOI + ParameterPV('f_d')*E_diff(months,hours))/ParameterPV('E0')*(1 + ParameterPV('alfa_Isc')*(T_c(months,hours) - ParameterPV('T0')));
* just to SolarInsolation(months,hours)!

parameter f1_AMa;
f1_AMa = ParameterPV('a0')+ParameterPV('a1')*ParameterPV('AMa')+ParameterPV('a2')*ParameterPV('AMa')**2+ParameterPV('a3')*ParameterPV('AMa')**3+ParameterPV('a4')*ParameterPV('AMa')**4;

parameter T_c(months,hours);
*cell temperature, rear insulated cell
T_c(months,hours) = SolarInsolation(months,hours)*ParameterPV('E0')*exp(ParameterPV('aPV')+ParameterPV('b')*OtherLocationData('WindSpeed'))+ AmbientHourlyTemperature(months, hours);

parameter I_sc(months,hours);
I_sc(months,hours) = ParameterPV('I_sc0')*f1_AMa*solarinsolation(months,hours)*ParameterPV('E0')/ParameterPV('E0')*(1 + ParameterPV('alfa_Isc')*(T_c(months,hours) - ParameterPV('T0')));
* Original: I_sc(months,hours) = ParameterPV('I_sc0')*f1_AMa*(E_b*f2_AOI + ParameterPV('f_d')*E_diff(months,hours))*(1 + ParameterPV('alfa_Isc')*(T_c(months,hours) - ParameterPV('T0')));

parameter E_e1(months,hours);
E_e1(months,hours) = I_sc(months,hours)/(ParameterPV('I_sc0')*(1 + ParameterPV('alfa_Isc')*(T_c(months,hours) - ParameterPV('T0'))));

parameter E_e(months,hours);
*to be bigger than 0 even w/o solar insolation since E_e is used in log functions
E_e(months,hours) = (E_e1(months,hours)+abs(E_e1(months,hours)))/2+0.000000000001;

parameter I_mp(months,hours);
I_mp(months,hours) = ParameterPV('I_mp0')*(ParameterPV('c0')*E_e(months,hours) + ParameterPV('c1')*E_e(months,hours)**2)*(1 + ParameterPV('alfa_Imp')*(T_c(months,hours) - ParameterPV('T0')));

parameter delta(months,hours);
delta(months,hours) = ParameterPV('n')*ParameterPV('kBYq')*(T_c(months,hours)+273.15);

parameter V_oc(months,hours);
V_oc(months,hours)= ParameterPV('V_oc0') + ParameterPV('Ns')*delta(months,hours)*log(E_e(months,hours)) + ParameterPV('beta_Voc')*(T_c(months,hours) - ParameterPV('T0'));

parameter V_mp(months,hours);
V_mp(months,hours) = ParameterPV('V_mp0') + ParameterPV('c2')*ParameterPV('Ns')*delta(months,hours)*log(E_e(months,hours)) + ParameterPV('c3')*ParameterPV('Ns')*(delta(months,hours)*log(E_e(months,hours))*(-1))**2 + ParameterPV('beta_Vmp')*(T_c(months,hours) - ParameterPV('T0'));

parameter W_mp(months,hours) maximum power;
* Power = I*V
W_mp(months,hours) = I_mp(months,hours) * V_mp(months,hours);

parameter PVEfficiency(months,hours);
PVefficiency(months,hours) = W_mp(months,hours)/(ParameterPV('A')*(SolarInsolation(months,hours)*ParameterPV('E0')+ParameterSolarThermal('epsilon')));

*This avoids negative efficiencies
PVefficiency(months,hours)=(PVefficiency(months,hours)+abs(PVefficiency(months,hours)))/2;

*2013/05/31. Lenaig added a year index to "PVArea" and considered the total capacity available in the year considered.
positive variable PVArea(years);
Equation PVAreaEq(years);
         PVAreaEq(years)..
         PVArea(years) =E=TotalCapacityInYearY('PV',years)/ParameterTable ('PeakPVEfficiency', 'ParameterValue');

*2013/05/31. Lenaig added a year index and considered the total capacity available in the year considered.
Equation Electricity_PV_ConstraintEq(years,months,daytypes,hours);
      Electricity_PV_ConstraintEq(years,months,daytypes,hours)..
      Electricity_PV_Export(years,months,daytypes,hours) + Electricity_PV_Onsite(years,months,daytypes,hours)
      =L= TotalCapacityInYearY('PV',years)
      * SolarInsolation(months,hours)/ParameterTable ('PeakPVEfficiency', 'ParameterValue')*PVefficiency(months,hours);

* ------------------

* -------------  Area constraint for PV and solar thermal  ---------------------------------------

*2013/05/31. Lenaig added a year index and considered the total capacities available in the year considered.
* capacities are peak outputs under lab conditions and not location specific
Equation AreaConstraintEq(years);
         AreaConstraintEq(years)..
         TotalCapacityInYearY('PV',years)/ParameterTable ('PeakPVEfficiency', 'ParameterValue')
         + TotalCapacityInYearY('solarthermal',years)/PeakSolarThermalEfficiency
         =L=
         ParameterTable ('MaxSpaceAvailablePVSolar',  'ParameterValue') ;

*Olivier : check for remaining space for PV
*2013/05/31. Lenaig added a year index to this variable.
variable RemainingSpacePVSolar(years);

*2013/05/31. Lenaig added a year index and considered the total capacities available in the year considered.
Equation RemainingSpacePVSolar_Eq(years);
         RemainingSpacePVSolar_Eq(years)..
         RemainingSpacePVSolar(years)
         =E=
         smax((months, hours),SolarInsolation (months, hours))
         * ParameterTable ('MaxSpaceAvailablePVSolar',  'ParameterValue')
         - ( TotalCapacityInYearY('PV',years)/ParameterTable ('PeakPVEfficiency',  'ParameterValue')
              + TotalCapacityInYearY('solarthermal',years)/PeakSolarThermalEfficiency );

* -------------

* -------------   Lifetime constraints for PV and solar thermal  -----------------------------------
*2013/05/31. Lenaig added new lifetime constraints for PV and solar thermal (set to 0 if no reinvestment after the lifetime is reached).
*            These constraints would probably not be used as the lifetime for PV and solar thermal is about 15-20 years or more
*            and it is not sure we want to minimize the building total energy cost over this period of time.
Heat_FromSolar.fx(years,months,daytypes,hours)$((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt ContinuousInvestParameter('SolarThermal','lifetime')) ) = 0;
Electricity_PV_Export.fx(years,months,daytypes,hours)$((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt ContinuousInvestParameter('PV','lifetime')) ) = 0;
Electricity_PV_Onsite.fx(years,months,daytypes,hours)$((OptionsTable('RenewInvestments','OptionValue')eq 0) And(years.val gt ContinuousInvestParameter('PV','lifetime')) ) = 0;

* -------------  Demand Response Constraints  ---------------------------------------
*2013/03. Lenaig added a year index to all equations in this section.
Equation DemandResponseEq(DemandResponseType,years,months,daytypes,hours);
DemandResponseEq(DemandResponseType,years,months,daytypes,hours)..
DemandResponse(DemandResponseType,years,months,daytypes,hours)=l= DemandResponseParameters(years,DemandResponseType,'MaxContribution')*Load(years,'electricity-only',months,daytypes,hours);

Equation TimeLimitDemandResponseEq(DemandResponseType,years);
TimeLimitDemandResponseEq(DemandResponseType,years)..
sum((months,daytypes,hours),demandResponseOnOff(DemandResponseType,years,months,daytypes,hours)*NumberOfDays (months, daytypes))=l=DemandResponseParameters1 (DemandResponseType,'MaxHours') ;

Equation DemandResponseHeatingEq(DemandResponseType,years,months,daytypes,hours);
DemandResponseHeatingEq(DemandResponseType,years,months,daytypes,hours)..
DemandResponseHeating(DemandResponseType,years,months,daytypes,hours)=l= DemandResponseParametersHeating(years,DemandResponseType,'MaxContribution')*Load(years,'space-heating',months,daytypes,hours);

Equation TimeLimitDemandResponseHeatEq(DemandResponseType,years);
TimeLimitDemandResponseHeatEq(DemandResponseType,years)..
sum((months,daytypes,hours),demandResponseOnOffHeating(DemandResponseType,years,months,daytypes,hours)*NumberOfDays (months, daytypes))=l=DemandResponseParametersHeating1 (DemandResponseType,'MaxHours');

***************************************************************************************
*--------------------   Static Switch   --------------------------
***************************************************************************************

PARAMETER AvailabilitySolarDay (months);
AvailabilitySolarDay(months)=sum(hours,SolarInsolation (months, hours))/24 ;
PARAMETER AvailabilitySolar;
AvailabilitySolar=sum(months,AvailabilitySolarDay(months))/12 ;

*2013/03. Lenaig added a year index to 'AvailabilityElectricStorage' parameter.
Parameter AvailabilityElectricStorage(years);
AvailabilityElectricStorage(years)=    ElectricityStorageStationaryParameter('MaxDischargeRate')*(24-(1/ElectricityStorageStationaryParameter('MaxChargeRate')))/24;
* Please note that the definition of AvailabilityElectricStorage assumes one charging / discharging cycle per day.

Parameter AvailabilityDERUnits;
AvailabilityDERUnits=ParameterTable ('ReliabilityDER', 'ParameterValue')

*2013/05/31. Lenaig modified this equation to consider the total capacities available in the year considered.
Equation StaticSwitchEq(years);
    StaticSwitchEq(years)..
       sum(AvailableTECHNOLOGIES,
             sum(years_counter $(years_counter.val le deropt(AvailableTechnologies,'lifetime')),
                  DER_Investment(AvailableTECHNOLOGIES,years - (years_counter.val-1))
                  * AvailabilityDERUnits * deropt(AvailableTECHNOLOGIES, 'SprintCap')) )
       + AvailabilitySolar * TotalCapacityInYearY ('PV',years)
       + TotalCapacityInYearY ('FlowBatteryPower',years)
       + AvailabilityElectricStorage(years) * TotalCapacityInYearY ('ElectricStorage',years)
       =g= switchsize ;

* --------------------------------------------------------------------------------------------------------------------------

* Solver Statement
MODEL CUSTADOP_ZNEB  /all/;

MODEL CUSTADOP_NO_ZNEB /
 continuouspurchaseconstrainteq
 electricfixedcost_eq
 standbycosteq
 electricpurchtoueq
 electrictoucostbytou_eq
 electrictoucost_eq
 electricconsumption_eq
 maxdemandmonthlyeq
 electricdemandcostbytype_eq
 electricdemandcost_eq
 maxdemanddailyeq
 dailydemandchargeeq
 electricdailydemandcost_eq
 electricCO2_eq
 electricCO2cost_eq
 annualelectricCO2_eq
 electrictotalcost_eq
 annualelectriccosteq
 annualelectricconsumption_eq
 ng_fordg_eq
 ngfordgconsumption_eq
 ngforheatconsumption_eq
 ngforngchillconsumption_eq
 ngtotalconsumption_eq
 CO2fromder_eq
 CO2fromnonder_eq
 CO2fromchillers_eq
 CO2fromng_eq
 ngfordgcost_eq
 ngforheatcost_eq
 ngforngchillcost_eq
 ngfixedcost_eq
 ngCO2cost_eq
 ngtotalcost_eq
 annualngcost_eq
 annualngconsume_eq
 annualngCO2der_eq
 annualngCO2nonder_eq
 annualngCO2chillers_eq
 annualngCO2_eq
 otherfuelconsumptioneq
 otherfuelcosteq
 annualotherfuelcosteq
 upfrontcapitalcost_disctech_eq
 upfrontcapitalcost_ngchill_eq
 upfrontcapitalcost_conttech_eq
 upfrontcapitalcost_switch_eq
 upfrontcapitalcost_eq
 annualizedcapcost_disctech_eq
 annualizedcapcost_conttech_eq
 annualizedcapcost_ngchill_eq
 annualizedcapcost_switch_eq
 annualizedcapcost_eq
 fixedmaintcost_disctech_eq
 fixedmaintcost_conttech_eq
 fixedmaintcost_ngchill_eq
 fixedmaintcost_eq
 variablemaintcost_disctech_eq
 variablemaintcost_ngchill_eq
 variablemaintcost_conttech_eq
 variablemaintcost_eq
 dercost_eq
 dertotalcost_eq
 totalenergycosts_eq
 totalannualCO2_eq
*2013/03. Lenaig added new equations.
 allperiodtotalenergycosts_eq
 allperiodtotalCO2_eq
*
 MultiObjective_eq
 der_currentlyoperatingeq
 der_currentlyoperatingmincapeq
 der_currentlyoperatingmaxcapeq
 ngchill_maxcapacity_eq
 absorptioncoolinglimiteq
 sprintamount_eq
 sprintlimit_eq
 electricityprovidedeq
 electricitystoredstationaryeq
 Electricity_Generation_TechnologyEq
 flowbatterystoredeq
 electricityconsumedeq
 electricitybalanceeq
 electricity_generationeq
 electricity_photovoltaicseq
 electricity_pv_constrainteq
 electricitystoragestationaryinputeq
 flowbatteryinputeq
 electricity_fromstationarybatteryeq
 electricity_fromflowbatteryeq
 electricitystoragestationarylosseseq
*2013/02/22. Lenaig added a new equation to represent battery degradation.
 electricitystoragestationarycapacityeq
 flowbatterylosseseq
 electstoragestationarychargingrateeq
 electstoragestationarydischargingrateeq
 electricitystoragestationaryconstrainteq
 electricitystoragestationaryconstraint2eq
 flowbatterychargingrateeq
 flowbatterydischargingrateeq
 flowbatterystorageconstrainteq
 flowbatterystorageconstraint2eq
 coolingprovisioneq
 electriccoolingeq
 coolingbyngchill_eq
 ng_forngchill_eq
 absorptioncoolingeq
* heatprovidedeq,
 heatstoredeq
* heatconsumedeq,
* heatbalanceeq,
 HT_HeatProvided_Eq
 LT_HeatProvided_Eq
 HT_HeatConsumed_Eq
 LT_HeatConsumed_Eq
 HT_HeatBalance_Eq
 LT_HeatBalance_Eq
 heat_fromngeq
 heat_fromdg_eq
 Heat_fromNO_SGIP_DG_Eq
 Heat_from_SGIP_DG_Eq
 heat_fromsolareq
 SolarThermalAreaEq
 PVAreaEq
 heat_fromstorageeq
 heat_fromngchill_eq
 heatstorageinputeq
 heatstoragelosseseq
 heatforspaceheatingeq
 heatforwaterheatingeq
 heatstorageconstraint1eq
 heatstorageconstraint2eq
 heatstorageconstraint3eq
 maximumannualhourseq
 annualdgSGIPelectricityeq
 annualdgSGIPrecheateq
 annualngfordgSGIPeq
*2013/03. Lenaig added a new equation.
 allperiodsavingseq
 paybackconstrainteq
 ngforder_electricproductioneq
 ngforder_consumedenergyeq
 electricity_annualsaleseq
 electricity_totalsaleseq,
 staticswitcheq,
 AreaConstraintEq,
 DemandResponseEq,
 DemandResponseonOffEq,
 TimeLimitDemandResponseEq,
 DemandResponseonOffHeatingEq,
 DemandResponseCostsHeatingEq,
 DemandResponseHeatingEq,
 TimeLimitDemandResponseHeatEq,
 RefrigerationByAbsorptionEq,
 RefrigerationProvisionEq,
 ElectricRefrigerationEq,
 AbsorptionRefrigerationEq,
 ElectricSalesEq,
 PurchaseEq,
 SaleEq,
 NetMeteringEq,
 CapacityConstraintEq,
 DemandResponseCostsEq,
 EitherChargeXOrDischarge_Eq,
 XORDischargeEVs_Eq,
 EitherChargeEVs_Eq,
 ElectricityStoredEVsEq,
 ElectricityStoredEVsLowerBoundaryEq,
 ElectricityStoredEVsUpperBoundaryEq,
 ElectricityStorageEVsInputEq,
 Electricity_FromEVsEq,
 ElectStorageEVsChargingRateEq,
 ElectStorageEVsDischargingRateEq,
 ElectricVehicleBilling_Eq,
 NetEVOutput_Eq,
 EV_Payment_Eq,
 Yearly_EV_Payment_Eq,
 Yearly_EV_Payment_Eq2,
 Daysinthisyear_Eq,
 MicrogridBenefit_Eq,
 EnergyprocessedEVsHourly_Eq,
 EnergyprocessedEVsMonthly_Eq,
 EnergyprocessedEVsYearly_Eq,
 YearlyBatteryDegradationEVs_Eq,
 ElectricityStorageEVsLossesEq,
 FlowBatteryChargingEq,
 FlowBatteryDischargingEq,
 ElecStationaryChargingEq,
 ElecStationaryDischargingEq,
 DiscreteElecStorageEq,
 EV_connection_payment_Eq,
 EVsElectricityFromHome_without_eff_Eq,
 CO2fromEVsHomeCharging_Eq,
 RemainingSpacePVSolar_Eq,
 EHToCar_Eq1,
 EHToHome_Eq1,
 EHToCar_Eq2,
 EHToHome_Eq2,
 EVsElectricityFromHome_without_eff_Eq2,
 EVsElectricityFromHome_Eq,
 EVHomeElectricityCO2Cost_Eq,
 NGforNGOnlyLoadConsumption_Eq,
 NGforNGOnlyLoadCost_Eq,
 CO2FromNGOnlyLoad_Eq,
 AnnualNGCO2NGOnly_Eq,
 LoadSchedulingEq_1,
 LoadSchedulingEq_2,
 LoadSchedulingEq_3,
 LoadSchedulingEq_4,
 UpfrontCapitalCostBoreHole_Eq1,
 UpfrontCapitalCostBoreHole_Eq2,
 ElectricityForHeatPumps_Eq,
 ElectricityForASHeatPump_Eq,
 ElectricityForGSHeatPump_Eq,
 Heat_FromHeatPumps_Eq,
 HeatingFromASHeatPump_Eq,
 HeatingFromGSHeatPump_Eq,
 CoolingByHeatPumps_Eq,
 CoolingFromASHeatPump_Eq,
 CoolingFromGSHeatPump_Eq,
 ASHP_Heat_Or_Cool_Eq,
 ASHP_Heating_max_Eq,
 ASHP_Cooling_max_Eq,
 GSHP_Heat_Or_Cool_Eq,
 GSHP_Heating_max_Eq,
 GSHP_Cooling_max_Eq,
 GSHP_Annual_Balance_Eq,
 CapacityConstraintFeedinEq,
 Annual_Heat_from_CHP_Eq,
 Minimum_Heat_Recovery_FeedIn_Eq,
 ng_forCHPdg_eq,
 ngforCHPdgconsumption_eq,
 LHV_Efficiency_Constraint_Feedin_Eq,
 HHV_Efficiency_Constraint_Feedin_Eq,
 SGIP_Thermal_Efficiency_Req_Eq,
 SGIP_LHV_Requirement_Eq,
 SGIP_HHV_Requirement_Eq,
 SGIP_HHV_Electric_Requirement_Eq,
 SGIP_Sales_Limit_Eq,
 SGIP_Max_CHP_Capacity_Eq,
 PBI_Payment_Eq,
 PBI_NPV_Eq,
*2013/05/31. Lenaig put the two following PBI equations in text mode.
* PBI_EAC_Eq,
* PBI_Incentive_Eq,
 Annual_Electricity_from_CHP_Eq,
 ElectricSalesLimitEq,
*MG
 FuelCellRunsWholeDay_Eq,
*2013/05/31. Lenaig added a new equation.
 DefineTotalCapacity_ContTech_Eq
*2014/10/25 José Capacity payment.
ContractCapacity_Eq
ContractCost_Eq
*2014/10/14 José tariff for the Spanish case
lin_fixed1
lin_fixed2
lin_fixed3
fixedtarif
*
*CapacityBidRegulationUpEqualDown
CapacityBidRegulationUpEq
CapacityBidRegulationDownEq
CapacityBidRegulationUpBatteryEq
CapacityBidRegulationDownBatteryEq
CapacityBidRegulationUpDiscreteTechnologyEq
CapacityBidRegulationDownDiscreteTechnologyEq
EnergyFlowFromBatteryToISOEq
DiscreteTechnologyRegulationUpEq
EnergyFlowFromISOToBatteryEq
DiscreteTechnologyRegulationDownEq
Electricity_FromStationaryBatteryEq2
ElectricityForStorageStationaryEq
Generation_SellEq
RampUp_Eq
RampDown_Eq
Aux1RampUp
Aux2RampUp
Aux3RampUp
Aux1RampDown
Aux2RampDown
Aux3RampDown
YearlyBatteryDegradationEq
RegulationCapacityUpCostEq
RegulationCapacityDownCostEq
RegulationEnergyCost1Eq
RegulationEnergyCost2Eq
RegulationTotalCostEq
*2015/01/15 Dani included regulation equations
/;

CUSTADOP_no_ZNEB.optfile = 1;
CUSTADOP_ZNEB.optfile = 1;

option MIP=CPLEX;

if ((OptionsTable('MinimizeCO2','OptionValue')  eq 0 ),
   if ((OptionsTable('ZNEB','OptionValue')  eq 0 ),
       if ((OptionsTable('MultiObjective','OptionValue') eq 0 ),
          SOLVE CUSTADOP_no_ZNEB USING MIP MINIMIZING AllPeriodTotalEnergyCosts;
       else
          SOLVE CUSTADOP_no_ZNEB USING MIP MINIMIZING MultiObjective;
       );
   else
       SOLVE CUSTADOP_ZNEB USING MIP MINIMIZING AllPeriodTotalEnergyCosts);
else
   if ((OptionsTable('ZNEB','OptionValue')  eq 0 ),
      SOLVE CUSTADOP_no_ZNEB USING MIP MINIMIZING AllPeriodTotalCO2;
   ELSE
      SOLVE CUSTADOP_ZNEB USING MIP MINIMIZING AllPeriodTotalCO2);
);

*2013/05/31. Lenaig added a year index to this equation.
InsCap(years) = sum (AvailableTECHNOLOGIES, DER_Investment.l(AvailableTECHNOLOGIES,years) * deropt (AvailableTECHNOLOGIES, 'maxp'));
*2013/05/31. Lenaig added a year index to this equation.
InsCHPCap(years) = sum(AvailableCHPTechnologies, DER_Investment.l(AvailableCHPTechnologies,years) * deropt (AvailableCHPTechnologies, 'maxp'));

*2013/03. Lenaig added a year index to the following variables reported as outputs.

AllPeriodElectGen =sum((years,months,daytypes,hours),(Electricity_Generation.l(years,months,daytypes,hours)+Electricity_photovoltaics.l(years,months,daytypes,hours))*NumberOfDays(months,daytypes));

* Calculation of all period Electricity-Only Demand (kWh)
AllPeriodElectD = sum((years,months,daytypes,hours),load(years,'electricity-only',months,daytypes,hours)*NumberOfDays(months,daytypes));

* Calculation of all period Cooling Load (kWh)
AllPeriodCoolD = sum((years,months,daytypes,hours),load(years,'cooling',months,daytypes,hours)*NumberOfDays(months,daytypes));

* Calculation of all period Refrigeration Load (kWh)
AllPeriodRefrD = sum((years,months,daytypes,hours),load(years,'refrigeration',months,daytypes,hours)*NumberOfDays(months,daytypes));

* All period Natural Gas-Only Demand (kWh)
AllPeriodNatGasOnlyD=sum((years,months,daytypes,hours), (Load(years,'naturalgas-only',months,daytypes,hours))*NumberOfDays(months,daytypes));

* All period Space Heating Demand (kWh)
AllPeriodSpaceD=sum((years,months,daytypes,hours), (Load(years,'space-heating',months,daytypes,hours))*NumberOfDays(months,daytypes));

* All period Water Heating Demand (kWh)
AllPeriodWaterD=sum((years,months,daytypes,hours), (Load(years,'water-heating',months,daytypes,hours))*NumberOfDays(months,daytypes));

AllPeriodNGforHeatConsumption=sum((years,months), NGforHeatConsumption.l(years,months));

AllPeriodNGChillers =sum((years,months,daytypes,hours),NG_ForNGChill.l(years,months,daytypes,hours)*NumberOfDays(months,daytypes));

* All period Gas Requirement for DER (kWh)
AllPeriodGasDER=sum((years,months), NGforDGConsumption.l(years,months));

* All period Gas Costs for DER ($)
AllPeriodGasDERCosts=sum((years,months), NGforDGCost.l(years,months));

* All period total energy consumption without diesel
AnnualTotalEnergyConsumption (years) = AnnualElectricConsumption.l(years)/ParameterTable('macroeff','ParameterValue') + AnnualNGConsume.l(years);
AllPeriodTotalEnergyConsumption = sum(years,AnnualTotalEnergyConsumption (years));

* Total system efficiency (on-site & off-site), without NG-only load
SystemEfficiency =(AllPeriodSpaced+AllPeriodWaterD+AllPeriodElectD+AllPeriodCoolD+AllPeriodRefrD) /  (AllPeriodTotalEnergyConsumption - sum((years,months),NGforNGOnlyLoadConsumption.l(years,months)));

* Total system efficiency (on-site & off-site), with NG-only load
SystemEfficiency2 =(AllPeriodSpaced+AllPeriodWaterD+AllPeriodNatGasOnlyD+AllPeriodElectD+AllPeriodCoolD+AllPeriodRefrD) /  AllPeriodTotalEnergyConsumption;

AllPeriodEnergyD = AllPeriodElectD + AllPeriodCoolD + AllPeriodRefrD+ AllPeriodNatGasOnlyD + AllPeriodSpaceD + AllPeriodWaterD;

* report of SGIP CHP efficiency
CHPSGIPEfficiency =sum(years,(AnnualDGSGIPElectricity.l(years) + AnnualDGSGIPRecHeat.l(years))) / sum(years,AnnualNGforDGSGIP.l(years));

file results /C:\Users\Daniel\Documents\gamsdir\projdir\DER-CAM\Regulation_Model.csv/ ;

results.pc = 5;
results.pw = 255;
put results;
put '+++++++++Summary+++++++++'/;
results.nd=4;
put 'Goal Function Value (= Total All Period Considered Energy Costs minus Electricity Sales) ($)', AllPeriodTotalEnergyCosts.l /;
put /;
put /;
put /;
put 'year','Sum';
     loop (years, put years.tl); put /;
put 'Total Energy Costs - Electricity Sales . Year($)', AllPeriodTotalEnergyCosts.l;
     loop (years, put TotalEnergyCosts.l(years)); put /;
put 'YearlyBatteryDegradationEVs($)', sum(years,YearlyBatteryDegradationEVs.l(years));
     loop (years, put YearlyBatteryDegradationEVs.l(years)); put/;
put 'ElectricTotalCost($)', sum((years,months),ElectricTotalCost.l(years,months));
     loop (years, put sum(months,ElectricTotalCost.l(years,months))); put/;
put 'NGTotalCost($)', sum((years,months),NGTotalCost.l(years,months));
     loop (years, put sum(months,NGTotalCost.l(years,months))); put/;
put 'DERCost($)', sum(years,DERCost.l(years));
     loop (years, put DERCost.l(years)); put/;
put 'DemandResponseCosts($)', sum(years,DemandResponseCosts.l(years));
     loop (years, put DemandResponseCosts.l(years)); put/;
put 'DemandResponseCostsHeating($)', sum(years,DemandResponseCostsHeating.l(years));
     loop (years, put DemandResponseCostsHeating.l(years)); put/;
put 'Tariff($)', sum(years,Fixedcomp*Exchangerate*b.l(years)*FixedTariff*(1+Taxes+Elect_tax));
     loop (years, put (Fixedcomp*Exchangerate*b.l(years)*FixedTariff*(1+Taxes+Elect_tax))); put/;
put 'AnnualElectricitySales($)', sum(years,AnnualElectricitySales.l(years));
     loop (years, put AnnualElectricitySales.l(years)); put/;
put 'PBI_NPV($)', sum(years,PBI_NPV.l(years));
     loop (years, put PBI_NPV.l(years)); put/;
put /;
put /;
put 'year','Sum';
     loop (years, put years.tl); put /;
put 'Total Energy Costs - Electricity Sales . Year($)', AllPeriodTotalEnergyCosts.l;
     loop (years, put TotalEnergyCosts.l(years)); put /;
put 'Installed Capacity, discrete technologies (kW)', sum(years,inscap(years));
     loop (years, put inscap(years)); put /;
put 'Installed CHP Capacity, discrete technologies (kWe)', sum(years,inschpcap(years));
     loop (years, put inschpcap(years));  put /;
*   , put$((inschpcap gt 1000) and (SGIPOptions('enableSGIP','OptionValue') eq 1)) '»»»» WARNING «««« INSTALLED CHP CAPACITY EXCEEDS 1MW! CHECK SGIP INCENTIVES! »»»» WARNING ««««', put /
put 'Installed Battery Capacity (kWh)', sum(years,CapacityAddedInYearY.l('ElectricStorage',years));
     loop (years, put CapacityAddedInYearY.l('ElectricStorage',years)); put /;
put 'Installed Flow Battery Capacity (kWh)', sum(years,CapacityAddedInYearY.l('FlowbatteryEnergy',years));
     loop (years, put CapacityAddedInYearY.l('FlowbatteryEnergy',years)); put /;
put 'Installed Flow Battery Power (kW)', sum(years,CapacityAddedInYearY.l('FlowbatteryPower',years));
     loop (years, put CapacityAddedInYearY.l('FlowbatteryPower',years)); put /;
put 'Installed Capacity: Photovoltaic (kW), peak power under test conditions', sum(years,CapacityAddedInYearY.l('PV',years));
     loop (years, put CapacityAddedInYearY.l('PV',years)); put /;
put 'Size of Photovoltaic (m^2)', ' ';
     loop (years, put PVArea.l(years)); put /;
put 'Installed Capacity: Solar Thermal (kW), peak power under test conditions', sum(years,CapacityAddedInYearY.l('solarthermal',years));
     loop (years, put CapacityAddedInYearY.l('solarthermal',years)); put /;
put 'Size of Solar Thermal (m^2)', ' ';
     loop (years, put SolarThermalArea.l(years)); put /;
put 'Installed Capacity: Air Source Heat Pump (kW)', sum(years,CapacityAddedInYearY.l('AirSourceHeatPump',years));
     loop (years, put CapacityAddedInYearY.l('AirSourceHeatPump',years)); put /;
put 'Installed Capacity: Ground Source Heat Pump (kW)', sum(years,CapacityAddedInYearY.l('GroundSourceHeatPump',years));
     loop (years, put CapacityAddedInYearY.l('GroundSourceHeatPump',years)); put /;
put 'Electricity Generated Onsite over all the period of time considered(kWh)', AllPeriodElectGen/
put 'Electricity Sales . Year(kWh)', sum(years, TotalElectricitySales.l(years)),
     loop (years, put TotalElectricitySales.l(years)); put /;
put 'Recommended Static Switch Size', switchSize; put /;
put 'Installed EV1 Battery Capacity (kWh)', sum(years,CapacityAddedInYearY.l('EVs1',years)) ;
     loop (years, put CapacityAddedInYearY.l('EVs1',years)); put /;
*
put /;
put 'Battery Degradation Cost'/;
put 'YearlyBattery Degradation Cost (€)', sum((years),YearlyBatteryDegradation.l(years)) ;
     loop (years, put YearlyBatteryDegradation.l(years)); put /;
put 'Regulation batteries Costs and Sales'/;
put 'Regulation Capacity Up Sale (€)', sum((years,months),RegulationCapacityUpCost.l(years,months)) ;
     loop (years, put sum(months,RegulationCapacityUpCost.l(years,months))); put /;
put 'Regulation Capacity Down Sale (€)', sum((years,months),RegulationCapacityDownCost.l(years,months)) ;
     loop (years, put sum(months,RegulationCapacityDownCost.l(years,months))); put /;
put 'Regulation Energy Sale (€)', sum((years,months),RegulationEnergyCost1.l(years,months)) ;
     loop (years, put sum(months,RegulationEnergyCost1.l(years,months))); put /;
put 'Regulation Energy Cost (€)', sum((years,months),RegulationEnergyCost2.l(years,months)) ;
     loop (years, put sum(months,RegulationEnergyCost2.l(years,months))); put /;
put 'Regulation Total Cost (€)', sum((years,months),RegulationTotalCost.l(years,months));
     loop (years, put sum(months,RegulationTotalCost.l(years,months))); put /;
put /;
*
*2015/01/16 Dani included regulation batteries costs and sales

put 'contract capacity kw',
loop (years, put years.tl ,
loop (months, put  ContractCapacity.l(years,months));
put /;
);
$ontext
*put 'Fraction of electricity generated onsite (without absorption chiller offset)', FractionElectricityOnsite/
*put 'Effective Fraction of electricity generated onsite (includes absorption chiller offset)', EffectiveFractionElecOnsite/
*put 'Heating Load Offset by CHP (kWh/a)',AnnualHeatingOffsetDG/
*put 'Cooling Load Offset by CHP (kWh/a)', AnnualAbsChillOffsetDG/
$offtext
put 'Utility Electricity Consumption . Year(kWh)',sum(years,AnnualElectricConsumption.l(years)),
    loop (years, put AnnualElectricConsumption.l(years)); put /;
put 'Utility Natural Gas Consumption . Year(kWh)',sum(years,AnnualNGConsume.l(years)),
    loop (years, put AnnualNGConsume.l(years)) ; put /;
put 'Total Fuel Consumption (onsite plus fuel for macrogrid electricity, without diesel) . Year (kWh)',AllPeriodTotalEnergyConsumption;
    loop (years, put AnnualTotalEnergyConsumption(years)) ; put /;
put 'All Period Savings ($)', AllPeriodSavings.l /
put 'UpfrontCapitalCost ($)', sum(years,UpfrontCapitalCost.l(years)),
    loop (years, put UpfrontCapitalCost.l(years)); put /;
put 'UpfrontCapitalCost Discrete Tech ($)', sum(years,sum(AvailableTechnologies,UpfrontCapitalCost_DiscTech.l(AvailableTechnologies,years))),
    loop (years, put sum(AvailableTechnologies,UpfrontCapitalCost_DiscTech.l(AvailableTechnologies,years))); put /;
put 'UpfrontCapitalCost NG Chillers($)', sum(years,sum(NGChillTech,UpfrontCapitalCost_NGChill.l(NGChillTech,years))),
    loop (years, put sum(NGChillTech,UpfrontCapitalCost_NGChill.l(NGChillTech,years))); put /;
put 'UpfrontCapitalCost Static Switch($)', sum(years,UpfrontCapitalCost_StaticSwitch.l(years)),
    loop (years, put UpfrontCapitalCost_StaticSwitch.l(years));

put //'+++++++++Efficiencies and Fractions+++++++++'/;
put 'Efficiency of Entire Energy Utilization (Onsite and Purchase), without NG-only load',put SystemEfficiency,'  Efficiency of Entire Energy Utilization (Onsite and Purchase), with NG-only load',SystemEfficiency2/;
put 'Achieved SGIP CHP efficiency',put CHPSGIPEfficiency/;
$ontext
put NGSystemEfficiency.ts ,NGSystemEfficiency/;
put NGFERCEfficiency.ts,  NGFERCEfficiency/;

* put 'Fraction of Energy Demand Met On-Site',put PctEnergyOnSite/;

*put 'Fraction of Electricity-Only End-Use Met by On-Site Generation',put PctElectOnSite/;
*put 'Fraction of Cooling End-Use Met by On-Site Generation',put PctCoolOnSite/;
*put 'Fraction of Cooling End-Use Met by Absorption Chiller',put PctCoolAbChill/;
*put 'Fraction of Cooling End-Use Met by Natural Gas',put PctCoolGas/;
*put 'Fraction of Space-Heating End-Use Met by CHP',put PctSpaceCHP/;
*put 'Fraction of Space-Heating End-Use Met by Natural Gas',put PctSpaceGas/;
*put 'Fraction of Water-Heating End-Use Met by CHP',put PctWaterCHP/;
*put 'Fraction of Water-Heating End-Use Met by Natural Gas',put PctWaterGas/;
*put 'Fraction of Natural Gas-Only End-Use Met by Natural Gas',put PctNaturalGasOnlyGas;
$offtext
put //;
results.nd=0;
put '+++++++++Model 0ptions+++++++++' /
loop (ModelOption, put ModelOption.tl, OptionsTable (ModelOption
, 'OptionValue')/);
put / '+++++++++Model Parameters+++++++++'/;
results.nd=4;
loop (ParameterOption, put ParameterOption.tl, ParameterTable (ParameterOption, 'ParameterValue')/);
put /;
results.nd = 0;
put '+++++++++Installed Units for each Technology++++++++++++'/
put 'Available Technologies are technologies with MaxAnnualHour values greater than 0'/;
put 'in table GenConstraints in folder Technology Data'/;
put 'Discrete technologies as Microturbines, Fuel Cells, etc.'/;
loop (TECHNOLOGIES, put TECHNOLOGIES.tl,
     loop(years, put DER_Investment.l(TECHNOLOGIES,years)); put /;
     )
put /;
put 'Continues technologies as PV, Solar thermal, storage, etc.'/;
put 'Installed capacity; For storage technologies the capacity is expressed in kWh' /;
put 'For PV, solar thermal, FlowBatteryPower and absorption chillers / refrigeration the capacity is expressed in kW'/;
loop (ContinuousInvestType   , put ContinuousInvestType.tl ,
     loop(years, put CapacityAddedInYearY.l (ContinuousInvestType,years)); put /;
     );
put /;

results.nd = 4;
put '+++++++++Reports on an Annual Basis+++++++++'/
put 'Loads (All Numbers in kWh)'/
put '1 kWh = 3412.14 BTU'//;
put 'AllPeriod Electricity-Only Load Demand', AllPeriodElectD/;
put 'AllPeriod Cooling Load Demand',AllPeriodCoolD/;
put 'AllPeriod Refrigeration Load Demand',AllPeriodRefrD/;
put 'AllPeriod Space Heating Load', AllPeriodSpaceD/;
put 'AllPeriod Water Heating Load', AllPeriodWaterD/;
put 'AllPeriod Natural Gas-Only Load',AllPeriodNatGasOnlyD/;
put 'AllPeriod Total Energy Demand (kWh)',put AllPeriodEnergyD;
put //'Generation (All Numbers in kWh)'/
put '1 kWh = 3412.14 BTU'//;
put 'Total AllPeriod Electricity Generation On Site', AllPeriodElectGen/;
$ontext
*put 'Annual Electricity Generation On-Site to Meet Electricity-Only Load', AnnElectSelfGen/;
*put 'Annual Electricity Generation On-Site to Meet Cooling Load', AnnCoolSelfGen/;
put 'Annual On-Site Production of Energy (Electricity + Utilized Waste Heat + Natural Gas) (kWh)',put AnnOnSiteEnergy;
$offtext
put //'Purchase (All Numbers in kWh)'/
$ontext
*put 'Annual Electricity Purchase to Meet Electricity-Only Load', AnnElectPurch/;
*put 'Annual Electricity Purchase to Meet Cooling Load', AnnCoolPurch/;
put //'Natural Gas (All Numbers in kWh)'/
*put 'Annual Natural Gas-Only Load which is met by Natural Gas',AnnNatGasOnlyGas/;
*put 'Annual Cooling Load which is met by Natural Gas,'AnnCoolGas/;
$offtext
put 'AllPeriod Natural Gas Consumption fo Space Heating and Water Heating', AllPeriodNGforHeatConsumption/;
$ontext
$offtext
put //'CHP (All Numbers in kWh)'/
$ontext
*put 'Annual Cooling Load which is met by Absorption Chiller', AnnAbChill/;
*put 'Annual Load of Water Heating which is met by CHP', AnnWaterCHP/;
*put 'Annual Load of Space Heating which is met by CHP',AnnSpaceCHP/;
$offtext
put /'Energy Carriers'/
put 'AllPeriod DER Natural Gas Purchases (kWh)', AllPeriodGasDER/;
put 'AllPeriod NON DER Natural Gas Purchases (kWh)', (AllPeriodNGforHeatConsumption + AllPeriodNatGasOnlyD)/;
put 'AllPeriod Natural Gas Purchases for Chillers (kWh)', AllPeriodNGChillers/;
put 'AllPeriod Grand Total Gas Purchase (kWh/a)',sum(years,AnnualNGConsume.l(years))/;
* Electric
put 'AllPeriod Natural Gas Costs for DER ($)', AllPeriodGasDERCosts /;
put 'AllPeriod Total Gas Costs (volumetric & fixed costs)($)', sum(years,AnnualNGCost.l(years))/;
put 'AllPeriod Costs Electricity ($)', sum (years,AnnualElectricCost.l(years))/;

$ontext
put 'Annual Net Diesel Purchase (kWh)', AnnNetDieselPe/;
put 'Annual Diesel Bill ($)', AnnDieselBill;

$offtext
put //'Emissions'/;
put /;
loop (years,put years.tl /;
put 'Annual On-site CO2 Emissions from Natural Gas for DER (kgCO2)',AnnualNGCO2DER.l(years)/;
put 'Annual On-site CO2 Emissions from Natural Gas for Space Heating & Hot Water (kgCO2)',AnnualNGCO2NonDER.l(years)/;
put 'Annual On-site CO2 Emissions from Natural Gas for Chillers (kgCO2)',AnnualNGCO2Chillers.l(years)/;
$ontext
put 'Annual On-site CO2 Emissions from Diesel DER (kg)',AnnCO2OnSiteDERDiesel/;
$offtext
put 'Annual On-site CO2 Emissions from all Natural Gas uses (kgCO2)',AnnualNGCO2.l(years)/;
put 'Annual Off-site CO2 Emissions (Macrogrid) (kgCO2)', AnnualElectricCO2.l(years)/;
put 'Annual CO2 Emissions (Grand Total) (kgCO2)'TotalAnnualCO2.l(years)/;
);

put //'+++++++++Detailed Analysis+++++++++'//

*2015/01/19 Dani changed variable order from Electricity_FromStationaryBattery, ElectricityStorageStationaryOutput, ElectricityStorageStationaryInput, ElectricityStoredStationary, ElectricityStorageStationaryLosses, ElectricitySorageStationaryCapacity to Capacity,Stored,Output,Input,Losses,_From,FromStaToBuil,FromStaToISO,For,ForStaFromBuil,ForStaFromISO
put /;
put //'++++++++++Discrete Technologies+++++++'//

put // 'Electricity Generation from DG (WITHOUT PV!) (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'Electricity_Generation'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put Electricity_Generation.l(years,months, daytypes, hours)
                 ) ;
            put /;
           );
      );
);

put 'Number of Discrete Technologies groups currently operating' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'DER_CurrentyOperating'
*2015/06/11 Dani included line above
loop (AvailableTECHNOLOGIES, put AvailableTECHNOLOGIES.tl /;
  loop (years,put years.tl/;
     put 'hour';
     loop (hours, put hours.tl);
     put /;
     loop (daytypes, put '', daytypes.tl /;
           loop (months, put months.tl ;
                 loop (hours, put DER_CurrentlyOperating.l(AvailableTECHNOLOGIES,years,months,daytypes,hours)
                      ) ;
                 put /;
                 );
           );
     put ''/;
  );
);

put 'Electricity Generation from discrete technology (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'Electricity_Generation_Technology'
*2015/06/11 Dani included line above
loop (AvailableTECHNOLOGIES, put AvailableTECHNOLOGIES.tl /;
  loop (years,put years.tl/;
     put 'hour';
     loop (hours, put hours.tl);
     put /;
     loop (daytypes, put '', daytypes.tl /;
           loop (months, put months.tl ;
                 loop (hours, put Electricity_Generation_Technology.l(AvailableTECHNOLOGIES,years,months,daytypes,hours)
                      ) ;
                 put /;
                 );
           );
     put ''/;
  );
);
*2015/01/23 Dani changed TECHNOLOGIES by AvailableTECHNOLOGIES

put 'Electricity Used from the Electricity Generation from discrete technology (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'Generation_Use'
*2015/06/11 Dani included line above
loop (AvailableTECHNOLOGIES, put AvailableTECHNOLOGIES.tl /;
  loop (years,put years.tl/;
     put 'hour';
     loop (hours, put hours.tl);
     put /;
     loop (daytypes, put '', daytypes.tl /;
           loop (months, put months.tl ;
                 loop (hours, put Generation_Use.l(AvailableTECHNOLOGIES,years,months,daytypes,hours)
                      ) ;
                 put /;
                 );
           );
     put ''/;
  );
);

put 'Electricity Sell to the Network Supply from the Electricity Generation from discrete technology (regulation and regular sale) (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'Generation_Sell'
*2015/06/11 Dani included line above
loop (AvailableTECHNOLOGIES, put AvailableTECHNOLOGIES.tl /;
  loop (years,put years.tl/;
     put 'hour';
     loop (hours, put hours.tl);
     put /;
     loop (daytypes, put '', daytypes.tl /;
           loop (months, put months.tl ;
                 loop (hours, put Generation_Sell.l(AvailableTECHNOLOGIES,years,months,daytypes,hours)
                      ) ;
                 put /;
                 );
           );
     put ''/;
  );
);

put 'Electricity Sell to the Network Supply from the Electricity Generation from discrete technology (regular sale) (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'Generation_NetworkSales'
*2015/06/11 Dani included line above
loop (AvailableTECHNOLOGIES, put AvailableTECHNOLOGIES.tl /;
  loop (years,put years.tl/;
     put 'hour';
     loop (hours, put hours.tl);
     put /;
     loop (daytypes, put '', daytypes.tl /;
           loop (months, put months.tl ;
                 loop (hours, put Generation_NetworkSales.l(AvailableTECHNOLOGIES,years,months,daytypes,hours)
                      ) ;
                 put /;
                 );
           );
     put ''/;
  );
);

put 'Energy flow from discrete technology to regulation (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'DiscreteTechnologyRegulationUp'
*2015/06/11 Dani included line above
loop (AvailableTECHNOLOGIES, put AvailableTECHNOLOGIES.tl /;
  loop (years,put years.tl/;
     put 'hour';
     loop (hours, put hours.tl);
     put /;
     loop (daytypes, put '', daytypes.tl /;
           loop (months, put months.tl ;
                 loop (hours, put DiscreteTechnologyRegulationUp.l(AvailableTECHNOLOGIES,years,months,daytypes,hours)
                      ) ;
                 put /;
                 );
           );
     put ''/;
  );
);

put 'Energy flow from regulation to discrete technology (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'DiscreteTechnologyRegulationDown'
*2015/06/11 Dani included line above
loop (AvailableTECHNOLOGIES, put AvailableTECHNOLOGIES.tl /;
  loop (years,put years.tl/;
     put 'hour';
     loop (hours, put hours.tl);
     put /;
     loop (daytypes, put '', daytypes.tl /;
           loop (months, put months.tl ;
                 loop (hours, put DiscreteTechnologyRegulationDown.l(AvailableTECHNOLOGIES,years,months,daytypes,hours)
                      ) ;
                 put /;
                 );
           );
     put ''/;
  );
);

put 'Capacity Bid Regulation Up at each hour from discrete technologies (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'CapacityBidRegulationUpDiscreteTechnology'
*2015/06/11 Dani included line above
loop (AvailableTECHNOLOGIES, put AvailableTECHNOLOGIES.tl /;
  loop (years,put years.tl/;
     put 'hour';
     loop (hours, put hours.tl);
     put /;
     loop (daytypes, put '', daytypes.tl /;
           loop (months, put months.tl ;
                 loop (hours, put CapacityBidRegulationUpDiscreteTechnology.l(AvailableTECHNOLOGIES,years,months,daytypes,hours)
                      ) ;
                 put /;
                 );
           );
     put ''/;
  );
);

put 'Capacity Bid Regulation Down at each hour from discrete technologies (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'CapacityBidRegulationDownDiscreteTechnology'
*2015/06/11 Dani included line above
loop (AvailableTECHNOLOGIES, put AvailableTECHNOLOGIES.tl /;
  loop (years,put years.tl/;
     put 'hour';
     loop (hours, put hours.tl);
     put /;
     loop (daytypes, put '', daytypes.tl /;
           loop (months, put months.tl ;
                 loop (hours, put CapacityBidRegulationDownDiscreteTechnology.l(AvailableTECHNOLOGIES,years,months,daytypes,hours)
                      ) ;
                 put /;
                 );
           );
     put ''/;
  );
);

put /;
put //'+++++++++Stationary Storage++++++++'//

put // 'Remaining capacity of Stationary Battery - Consequence of battery degradation (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'ElectricityStorageStationaryCapacity'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
   put /;
     loop (months, put months.tl,
         put ElectricityStorageStationaryCapacity.l (years,months)
         put /
     );
);

put // 'Electricity Stored in Stationary Batteries at each Hour (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'ElectricityStoredStationary'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (ElectricityStoredStationary.l (years,months,daytypes,hours) ) )
            put /
           )
      )
);

put // 'Energy from batteries sold to the network (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'EnergyFlowFromStationaryStorageToNetwork'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (EnergyFlowFromStationaryStorageToNetwork.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);
*2015/06/11 Dani included EnergyFlowFromStationaryStorageToNetwork

put // 'Capacity bid regulataion-up at each Hour (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'CapacityBidRegulationUpBattery'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (CapacityBidRegulationUpBattery.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Capacity bid regulation-down at each Hour (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'CapacityBidRegulationDownBattery'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (CapacityBidRegulationDownBattery.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity Output from Stationary Battery (All numbers in kW)'/
put 'Information: Electricity output from battery multiplied with Efficiency Discharge gives electricity provided by the battery' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'ElectricityStorageStationaryOutput'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityStoragestationaryOutput.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity Input to Stationary Battery (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'ElectricityStorageStationaryInput'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityStoragestationaryInput.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity Lost due to self-discharge in Stationary Battery  (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'ElectricityStorageStationaryLosses'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityStoragestationaryLosses.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity Provided by the Stationary Battery at each Hour (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'Electricity_FromStationaryBattery'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (Electricity_FromstationaryBattery.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Energy flow from Stationary Storage to Building (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'EnergyFlowFromStationaryStorageToBuilding'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (EnergyFlowFromStationaryStorageToBuilding.l (years,months,daytypes,hours)))
                    put /
                    )
          )
     ;
);

put // 'Energy flow from Stationary Storage to ISO (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'EnergyFlowFromBatteryToISO'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (EnergyFlowFromBatteryToISO.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity Provided by the System to the Batteries at each Hour (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'ElectricityForStorageStationary'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityForStorageStationary.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Energy flow from building to Stationary Storage at each Hour (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'EnergyFlowFromBuildingToStationaryStorage'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (EnergyFlowFromBuildingToStationaryStorage.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Energy flow from ISO to Stationary Storage at each Hour (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'EnergyFlowFromISOToBattery'
*2015/06/11 Dani included line above
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (EnergyFlowFromISOToBattery.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put /;

put //'+++++++++Demand Response+++++++++'/
put 'Electricity Measures'/
loop (years,put years.tl /;

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'//
put 'Low measures (All numbers in kW)' //
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put DemandResponse.l('low',years,months,daytypes,hours)
                 ) ;
            put /;
            );
     );

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'//
put 'Mid measueres (All numbers in kW)' //
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put DemandResponse.l('mid',years,months,daytypes,hours)
                 ) ;
            put /;
            );
     );

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'//
put 'High measueres (All numbers in kW)' //
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put DemandResponse.l('high',years,months,daytypes,hours)
                 ) ;
            put /;
            );
     );
);
put //'+++++++++Demand Response Heating+++++++++'/
put 'Heating Measures'/
loop (years,put years.tl /;

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'//
put 'Low Measueres (All numbers in kW)' //
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put DemandResponseheating.l('low',years,months,daytypes,hours)
            ) ;
            put /;
        );
     );

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'//
put 'Mid Measueres (All numbers in kW)' //
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put DemandResponseheating.l('mid',years,months,daytypes,hours)
            ) ;
            put /;
            );
     );

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'//
put 'High Measueres (All numbers in kW)' //
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put DemandResponseheating.l('high',years,months,daytypes,hours)
            ) ;
            put /;
        );
     );
);

* put //;
put /////;
put /'+++++++++Details for Electricity+++++++++'//
put 'Utility electricity consumption (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (Electricity_Purchase.l(years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

*2015/01/23 Dani moved up Electricity Generation from DG (WITHOUT PV!)
put // 'Electricity Generation from Photovoltaics (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put Electricity_Photovoltaics.l (years,months, daytypes, hours)
                 ) ;
            put /;
           );
      );
);

*2015/01/19 Dani moved up Electric Storage Variables

put // 'Electricity Input to Air Source Heat Pump (All numbers in kW)'
put 'Information: Electricity used by air source heat pump to provide both heat and cooling'/
put 'Check for peak, week and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
     loop (months,
                put months.tl,
                loop (hours,
                      put (ElectricityForASHeatPump.l (years,MONTHS,DAYTYPES,HOURS)))
                      put /
                      )
          )
      ;
);

put // 'Electricity Input to Ground Source Heat Pump (All numbers in kW)'
put 'Information: Electricity used by ground source heat pump to provide both heat and cooling'/
put 'Check for peak, week and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
     loop (months,
                put months.tl,
                loop (hours,
                      put (ElectricityForGSHeatPump.l (years, MONTHS,DAYTYPES,HOURS)))
                      put /
                      )
          )
      ;
);

put // 'Electricity Output from FLOW Battery (All numbers in kW)'/
put 'Information: Electricity output from battery multiplied with Efficiency Discharge gives electricity provided by the battery' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (FlowBatteryOutput.l (years, months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity Input to FLOW Battery (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (FlowBatteryInput.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity Lost due to self-discharge in FLOW Battery  (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (FlowBatteryLosses.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity Input to EV1 Batteries Taking into Sccount Charging Efficiency (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityStorageEVsInput.l (years, months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity Stored in EV1 Batteries at each Hour (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (ElectricityStoredEVs.l (years,months,daytypes,hours) ) )
            put /
           )
      );
);

put // 'Electricity from EVs Provided by the EV1 Batteries Accounting for Efficiency at each Hour (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (Electricity_FromEVs.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity for EV Charging at each Hour (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityForStorageEVs.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Electricity Output from EVs not Accounting for Efficiency at each Hour (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityStorageEVsOutput.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Net EV Output (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (NetEVOutput.l (years,months,daytypes,hours)  )
                    )
                    put /
                    )
          )
     ;
);
put // 'BinaryDecision Variable Indicating Charging of EVs'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (BinaryCharge.l (years,months,daytypes,hours)  )
                    )
                    put /
                    )
          )
     ;
);
put // 'BinaryDecision Variable Indicating Discharging of EVs'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (BinaryDischarge.l (years,months,daytypes,hours)  )
                    )
                    put /
                    )
          )
     ;
);

put // 'Building Cooling: Electric Load Offset from Absorption Chillers (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (coolingByAbsorption.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);

put // 'Refrigeration: Electric Load Offset from Absorption Chillers (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (RefrigerationByAbsorption.l (years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);
put //'Electricity Sales from PV and other DG (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/

loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricSales.l(years,months,daytypes,hours)))
                    put /
                    )
          )
     ;
);

put // 'Load reduction due to load scheduling' /
loop (years,put years.tl /;
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '',daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put  (LoadReduction.l(years,months,daytypes,hours))
                 ) ;
            put /;
            );
     );
);
put //;

       put // 'Load increase due to load scheduling' /
loop (years,put years.tl /;
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '',daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put  (Loadincrease.l(years,months,daytypes,hours))
                 ) ;
            put /;
            );
     );
);

put //;
put /'+++++++++Financial EV Results+++++++++'//
put  'Billing Costs (All numbers in monetary units)'/
loop (years,put years.tl /;
loop (months,
     put months.tl,
     put (ElectricVehicleBilling.l (years,months)  )
     put /);
);
put // 'EV Payment, Payments Received from the Microgrid (All numbers in $)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (EV_Payment.l (years,months,daytypes,hours)  )
                    )
                    put /
                    )
          )
     ;
);

put // 'Yearly EV Payments, Yearly Payments Received from the Microgrid ($)'/
loop (years,put years.tl,
put Yearly_EV_Payment.l(years);
);
put // 'Microgrid-Benefit per year ($)'/
loop (years,put MicrogridBenefit.l(years));

put // 'Energy Processed per year, Anual Net EV Output(kWh)'/
loop (years, put EnergyprocessedEVsYearly.l(years));
put // 'Battery Degradation Cost ($) per year, Covered by the Microgrid'/
loop (years, put YearlyBatteryDegradationEVs.l(years));

put //;
put /'+++++++++Details for Heat+++++++++'//

put  'Total fraction of Recovered Heat / Heat provided by DER over all the period of time considered (all numbers in kWh)' //;
loop (daytypes, put daytypes.tl/;
         loop (years,put years.tl/;
              loop (months, put months.tl, (sum((hours), Heat_FromDG.l ( years, months, daytypes, hours))*NumberOfDays(months,daytypes))/;
              );
         );
);
put 'Grand Total over all the period of time considered', sum((years,months,daytypes),sum((hours), Heat_FromDG.l ( years, months, daytypes, hours))*NumberOfDays(months,daytypes))/;


put //'Heat Collected from DG (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (Heat_FromDG.l(years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);
put //'Heat Collected from NG (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (Heat_FromNG.l(years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);
put //'Heat Collected from Solar Thermal (All numbers in kW)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (Heat_FromSolar.l(years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);
put // 'Heat collected from Air Source Heat Pump (All numbers in kW)'
put 'Information: Heat collected from air source heat pump to provide heating'/
put 'Check for peak, week and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
     loop (months,
                put months.tl,
                loop (hours,
                      put (HeatingFromASHeatPump.l(years,MONTHS,DAYTYPES,HOURS)))
                      put /
                      )
          )
      ;
);

put // 'Heat collected from Ground Source Heat Pump (All numbers in kW)'
put 'Information: Heat collected from ground source heat pump to provide heating'/
put 'Check for peak, week and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
     loop (months,
                put months.tl,
                loop (hours,
                      put (HeatingFromGSHeatPump.l(years,MONTHS,DAYTYPES,HOURS)))
                      put /
                      )
          )
      ;
);
put //'Heat Supplied to Storage (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (HeatStorageInput.l(years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);
put //'Heat taken from Storage (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (HeatStorageOutput.l(years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);
put //'Heat lost to Decay in Storage Tank (All numbers in kWh)'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (HeatStorageLosses.l(years,months,daytypes,hours)  ) )
                    put /
                    )
          )
     ;
);
put //;
put /'+++++++++Details for Cooling+++++++++'//

put // 'Cooling by Central Chiller (All numbers in kW)'
put 'Information: Cooling met by pre-installed central chiller, in terms of electric input'/
put 'Check for peak, week and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
     loop (months,
                put months.tl,
                loop (hours,
                      put (CoolingByElectric.l(years,MONTHS,DAYTYPES,HOURS))
                )
                put /
     )
 );
);
put // 'Cooling by Absorption (All numbers in kW)'
put 'Information: Cooling met by absorption chiller, in terms of electric input'/
put 'Check for peak, week and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
     loop (months,
                put months.tl,
                loop (hours,
                      put (CoolingByAbsorption.l(years,MONTHS,DAYTYPES,HOURS))
                )
                put /
     )
 )
);
put // 'Cooling by NG Chiller (All numbers in kW)'
put 'Information: Cooling met by NG chiller, in terms of electric input'/
put 'Check for peak, week and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
     loop (months,
                put months.tl,
                loop (hours,
                      put (CoolingByNGChill.l(years,MONTHS,DAYTYPES,HOURS))
                )
                put /
     )
 );
);
put // 'Cooling by Air Source Heat Pump (All numbers in kW)'
put 'Information: Cooling met by Air Source heat pumps, in terms of electric input'/
put 'Check for peak, week and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
     loop (months,
                put months.tl,
                loop (hours,
                      put (CoolingFromASHeatPump.l(years,MONTHS,DAYTYPES,HOURS))
                )
                put /
     )
 );
);
put // 'Cooling by Ground Source Heat Pump (All numbers in kW)'
put 'Information: Cooling met by Ground Source heat pumps, in terms of electric input'/
put 'Check for peak, week and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
     loop (months,
                put months.tl,
                loop (hours,
                      put (CoolingFromGSHeatPump.l(years,MONTHS,DAYTYPES,HOURS)))
                      put /
                      )
          )
      ;
);
put // 'Total KWh per year (All numbers in kW)'

parameter TotalKWH (TECHNOLOGIES,years);
loop (years,put years.tl/;
TotalKWH (AvailableTECHNOLOGIES,years)=
     sum ((months, daytypes,hours), (Generation_Use.l(AvailableTECHNOLOGIES, years, months, daytypes, hours)
     +    Generation_NetworkSales.l(AvailableTECHNOLOGIES, years, months, daytypes, hours)) * NumberOfDays(months,daytypes)
          );
);
*2015/01/23 Dani changed Generation_Sell by Generation_NetworkSales
put ///
$ontext
put 'Distributed Energy Sources (DER) Data'/
put 'Tech Name', 'Rated Capacity (kW)', 'number of units',
     'cost per kW', 'unit lifetime (years)', 'Interest Rate rate',
     'O&M Fixed Costs ($/kW/year)', 'O&M Variable Cost ($/kWh)', 'Total kWh produced over all the period of time considered'/
     loop (TECHNOLOGIES,  put TECHNOLOGIES.tl, DEROPT (TECHNOLOGIES, 'maxp'),
     DER_Investment.l(TECHNOLOGIES), DEROPT (TECHNOLOGIES, 'capcost'),
     DEROPT (TECHNOLOGIES, 'lifetime'), ParameterTable('IntRate','ParameterValue'),
     DEROPT (TECHNOLOGIES, 'OMFix'), DEROPT (TECHNOLOGIES, 'OMVar'),
     sum(years,TotalKWH(TECHNOLOGIES,years))/
     );
$offtext;

put / 'Annuity of Capital Costs ($/kW)' /
loop (TECHNOLOGIES, put TECHNOLOGIES.tl;
put   (AnnuityRate_DiscTech(TECHNOLOGIES)*DEROPT (TECHNOLOGIES, 'capcost'))/;
);


put ///
put 'CONTINUOUS TECHNOLOGIES'/
put 'Upfront capital costs (All numbers in $)'/
loop (ContinuousInvestType,
     put ContinuousInvestType.tl
     put '   '
     loop(years, put UpfrontCapitalCost_ContTech.l (ContinuousInvestType,years));put /;
     );

put /
put 'CONTINUOUS TECHNOLOGIES'/
put 'Annualized Capital Costs (All numbers in $)'/
put ' ',' ',loop (years,put years.tl);
put /
loop (ContinuousInvestType,
     put ContinuousInvestType.tl
     put '   '
     loop (years,
             put AnnualizedCapitalCost_ContTech.l (ContinuousInvestType,years))
             put /
)

put//;
put 'Volumetric Electric Costs (All numbers in $)'/
'on = on peak; mid = mid peak; off = off peak'/;
put '';
loop (years,put years.tl/;
put '',loop (TimeOfDay, put TimeOfDay.tl)
put /
loop (months,
        put months.tl,
        loop (TimeOfDay,
             put (ElectricTOUCostByTOU.l(years,months,TimeOfDay)  ) )
             put /
       )
     ;
);

put//;
put 'Daily Demand Charges (All numbers in $/kW)'/
put ' ',' ';
loop (DemandType, put DemandType.tl)
put /;
loop (years,put years.tl/;
loop (daytypes,
     loop (months,
          put months.tl, daytypes.tl,
          loop (DemandType, put DailyDemandCharge.l(years,months,daytypes,DemandType))
          put /
          )
     );
);

put//;
put 'Monthly Demand Charges (All numbers in $/kW)'/
put '';
loop (DemandType, put DemandType.tl)
put /;
loop(years, put '', put years.tl,
loop (months,
     put months.tl,
     loop (DemandType, put MonthlyDemandRates(years,months,DemandType))
     put /
     );
);

put ///'+++++++++Report of selected Input Data+++++++++'/

Put / 'Used COP absorption chillers',COPabs /;
Put  'Used COP electric chillers',COPelectric   //;

put 'Time of use electricity prices ($/kWH)'/
put 'on = on peak; mid = mid peak; off = off peak'/;
put '';
loop (TimeOfDay, put TimeOfDay.tl)
put / ;
loop (years,put years.tl/;
loop (months,
        put months.tl,
        loop (TimeOfDay,
             put sum(daytypes, sum(hours,(ElectricityRates(years,months,daytypes,hours)))))
             put /
      );
);

put  //'Fuel prices' /;
put ''
loop (fueltype,  put fueltype.tl);
put /;
loop (years,put years.tl/;
loop (months, put months.tl;
      loop (fueltype, put FuelPrice(years,months,fueltype)
           );
      put /;
      );
);

put  //'Monthly fixed fees' /;
loop (years, put years.tl/;
   loop (service, put service.tl,MonthlyFee (years,service)/;
         );
);

put //'TOU hours'/
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put HoursByMonth(hours, months, daytypes)
                 ) ;
            put /;
            );
     );

put ///'+++++++++Report of Load Profiles (Input Data)+++++++++'/
loop (years,put years.tl/;

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'//
put 'Electricity only Load (All numbers in kW)' //
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put load (years,'electricity-only', months, daytypes, hours)
                 ) ;
            put /;
            );
     );

put // 'Cooling Load for year ... (All numbers in kW)' /
put 'Please note that in DER-CAM cooling loads are expressed ' /
put 'in electricity needed to serve the cooling demand.'/
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '',daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put load (years,'cooling', months, daytypes, hours)
                 ) ;
            put /;
            );
     );

put // 'Refrigeration Load for year ...(All numbers in kW)' /
put 'Please note that in DER-CAM refrigeration loads are expressed ' /
put 'in electricity needed to serve the refrigeration demand.'/
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '',daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put load (years,'refrigeration', months, daytypes, hours)
                 ) ;
            put /;
            );
     );

put // 'Space Heating Load for year ...(All numbers in kW)' /
put 'Conversation factor: 1 kW = 3412.14 BTU/h' /
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '',daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put load (years,'space-heating', months, daytypes, hours)
                 ) ;
            put /;
            );
     );

put // 'Water Heating Load for year ...(All numbers in kW)' /
put 'Conversation factor: 1 kW = 3412.14 BTU/h' /
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '',daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put load (years,'water-heating', months, daytypes, hours)
                 ) ;
            put /;
            );
     );

put // 'Naturalgas only Load for year ...(All numbers in kW)' /
put 'Conversation factor: 1 kW = 3412.14 BTU/h' /
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '',daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put load (years,'naturalgas-only', months, daytypes, hours)
                 ) ;
            put /;
            );
     );

put // 'Total Load for year ...(All numbers in kW)' /
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '',daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put sum(enduse, load (years,enduse, months, daytypes, hours))
            ) ;
            put /;
      );
  );

);

put ///'+++++++++Control Outputs+++++++++'/
put // 'SolarThermalEfficiency'/
put 'hour';
loop (hours, put hours.tl);
put /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (SolarThermalEfficiency(months,hours)))
                    put /
                    )

     ;

put / 'Average Solar Thermal Efficiency', SolarThermalAverageEfficiency;

put // 'PV Efficiency'/
put 'hour';
loop (hours, put hours.tl);
put /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (PVefficiency(months,hours)))
                    put /
                    )
     ;


put // 'Purchases: Control Output' /
loop (years,put years.tl/;
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '',daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put  PurchaseOrSale.l(years,months,daytypes,hours)
                 ) ;
            put /;
            );
     );
);

put // 'Sales: Control Output' /
loop (years,put years.tl/;
put 'hour';
loop (hours,put hours.tl);
put /;
loop (daytypes, put '',daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours, put  (1-PurchaseOrSale.l(years,months,daytypes,hours))
                 ) ;
            put /;
            );
     );
);

put //;

put // 'SOC in EV batteries at each hour (All numbers in kW)' /
$ontext
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (ElectricityStoredEVs.l (years,months,daytypes,hours)/Capacity.l('EVs1') ) )
            put /
           )
      );
);
put // 'minSOC (for verification only)' /

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (MinimumStateofChargeEVs(years, months, daytypes, hours)  ) )
            put /
           )
      );
);

put // 'maxSOC (for verification only)' /

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (MaximumStateofChargeEVs(years,months, daytypes, hours)  ) )
            put /
           )
      );
);
$offtext
put // 'PV - total electricity consumption (building) + net from Evs [kWh]' /
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (Electricity_Photovoltaics.l (years,months, daytypes, hours)-sum(enduse, load (years,enduse, months, daytypes, hours))+NetEVOutput.l(years,months,daytypes,hours)  ) )
            put /
           )
      );
);

put // 'PV + grid - total electricity consumption (building) + net from Evs  [kWh]' /
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (Electricity_Photovoltaics.l (years,months, daytypes, hours)+Electricity_Purchase.l(years,months,daytypes,hours)-sum(enduse, load (years,enduse, months, daytypes, hours))+NetEVOutput.l(years,months,daytypes,hours)  ) )
            put /
           )
      );
);
put // 'PV - total electricity consumption (building)  [kWh]' /
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (Electricity_Photovoltaics.l (years,months, daytypes, hours)-sum(enduse, load (years,enduse, months, daytypes, hours))  ) )
            put /
           )
      );
);
*2013/06/28. Lenaig reorganised the way to present the results.
put // 'MonthlyNightlyMarginalCO2EmissionsResidential(years,months)  [kg/kWh ??] '/
put 'year', loop (years, put years.tl);
put /
loop (months, put months.tl,
      loop (years, put MonthlyNightlyMarginalCO2EmissionsResidential(years,months)
      )
      put /
);

put // 'EVHomeElectricityCO2Cost(years,months) [$]' /
put 'year', loop (years, put years.tl);
put /
loop (months, put months.tl,
      loop (years, put EVHomeElectricityCO2Cost.l(years,months)
      )
      put /
);

put // 'CO2fromEVsHomeCharging(years,months) [kg]' /
put 'year', loop (years, put years.tl);
put /
loop (months, put months.tl,
      loop (years, put CO2fromEVsHomeCharging.l(years,months)
      )
      put /
);

put // 'NetEVOutput(years,months,daytypes,hours)  (All numbers in kW)' /

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (NetEVOutput.l(years,months,daytypes,hours) ) )
            put /
           )
      );
);

put // 'NetEVOutput(years,months,daytypes,hours) aggregated per month [kWh per month]' /
put 'year', loop (years, put years.tl);
put /
loop (months, put months.tl,
      loop (years, put sum((daytypes,hours), numberofdays(months,daytypes)*NetEVOutput.l(years,months,daytypes,hours))
      )
      put /
);

put // 'EVsElectricityFromHome(years,months,daytypes) aggregated per month [kWh per month]' /
put 'year', loop (years, put years.tl);
put /
loop (months, put months.tl,
      loop (years,
           put sum((daytypes,hours)$(ord(hours) >= ElectricityStorageEVParameter('BeginingHomeCharge') or ord(hours) <= ElectricityStorageEVParameter('EndHomeCharge')), numberofdays(months,daytypes)*EVsElectricityFromHome.l(years,months,daytypes))
      )
      put /
);

put // 'NetEVOutput(years,months,daytypes,hours) aggregated per month DIVIDED by EVsElectricityFromHome(years,months,daytypes) [-]'
put  /'should be a constant ratio if charge/discharge pattern does not change over months, relatively similar otherwise' //
put 'year', loop (years, put years.tl);
put /
loop (months, put months.tl,
      loop (years,
         put (sum((daytypes,hours), numberofdays(months,daytypes)*NetEVOutput.l(years,months,daytypes,hours)) /
              sum((daytypes,hours)$(ord(hours) >= ElectricityStorageEVParameter('BeginingHomeCharge') or ord(hours) <= ElectricityStorageEVParameter('EndHomeCharge')), numberofdays(months,daytypes)*EVsElectricityFromHome.l(years,months,daytypes))
             )
      )
      put /
);

put // 'CO2fromEVsHomeCharging(years,months) / EVsElectricityFromHome(years,months,daytypes) aggregated per month [kWh per month] -  MonthlyNightlyMarginalCO2EmissionsResidential(years, months) [kg per month] /[kWh per month]' /
put 'should be 0'/
put 'year', loop (years, put years.tl);
put /
loop (months, put months.tl,
      loop (years,
         put(CO2fromEVsHomeCharging.l(years,months)/sum((daytypes,hours)$(ord(hours) >= ElectricityStorageEVParameter('BeginingHomeCharge') or ord(hours) <= ElectricityStorageEVParameter('EndHomeCharge')), numberofdays(months,daytypes)*EVsElectricityFromHome.l(years,months,daytypes))
         - MonthlyNightlyMarginalCO2EmissionsResidential(years,months) )
      )
      put /
);

put // 'positive part of NetEVOutput(years,months,daytypes,hours)  (All numbers in kW)' /
put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (NetEVOutput.l(years,months,daytypes,hours)$(NetEVOutput.l(years,months,daytypes,hours)>0) ) )
            put /
           )
      );
);

put // 'negative part of NetEVOutput(years,months,daytypes,hours)  (All numbers in kW)' /

put 'Note peakday, weekday, and weekendday profiles are available in this section.'/
put 'Check for peak, week, and weekend.'/
loop (years,put years.tl/;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes, put '', daytypes.tl /;
      loop (months, put months.tl ;
            loop (hours,
            put (NetEVOutput.l(years,months,daytypes,hours)$(NetEVOutput.l(years,months,daytypes,hours)<0) ) )
            put /
           )
      );
);
put //'Bloc of yearly data'/
put 'year', loop (years, put years.tl);
put /
put 'Yearly EV Payment, not including battery degradation',
    loop(years, put  Yearly_EV_Payment.l(years)) ; put /
put 'Yearly EV Payment per car, not including battery degradation',
    loop(years, put (Yearly_EV_Payment.l(years)/(CapacityAddedInYearY.l('EVs1','1')/16))) ; put /
put 'Yearly Battery Degradation EVs total',
    loop(years, put  YearlyBatteryDegradationEVs.l(years)) ; put /
put 'Yearly Battery Degradation EVs per car',
    loop(years, put (YearlyBatteryDegradationEVs.l(years)/(CapacityAddedInYearY.l('EVs1','1')/16))) ; put /
put 'Building to EV energy payment per car',
    loop(years, put sum((months), ElectricVehicleBilling.l(years,months)) /(CapacityAddedInYearY.l('EVs1','1')/16)) ; put /
put 'EV connection payment per car (for year 1)',
    loop(years, put (EV_connection_payment.l('1')/(CapacityAddedInYearY.l('EVs1','1')/16))) ; put /
put 'Building benefit (after battery degradation repayment and energy cost to EVs payment',
    loop(years, put MicrogridBenefit.l(years)) ; put /
put 'RemainingSpacePVSolar_Eq',
    loop(years, put RemainingSpacePVSolar.l(years)) ; put /
put 'Number Static Switch';
    loop(years, put switchpurchase.l(years)); put/;

put // 'Electricity_PV_Onsite'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (Electricity_PV_Onsite.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
put // 'Electricity_PV_Export'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (Electricity_PV_Export.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
put // 'Electricity_PV_Export'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (Electricity_Photovoltaics.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
*2015/01/23 Dani moved up Electricity Generation from discrete technology
put //'Battery Constraints'//
*2015/06/11 Dani included Battery Constraints to carry out a sensitivity analysis
put // 'StateOfCharge<Capacity'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityStorageStationaryCapacity.l(years,months)-ElectricityStoredStationary.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
put // 'Capacity*(1-MaxDepthDischarge)<StateOfCharge'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityStoredStationary.l(years,months,daytypes,hours)-ElectricityStorageStationaryCapacity.l(years,months)*(1-ElectricityStorageStationaryParameter('MaxDepthOfDischarge'))) )
                    put /
                    )
          )
     ;
);
put // 'Input<Capacity*MaxChargeRate'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityStorageStationaryCapacity.l(years,months)*ElectricityStorageStationaryParameter('MaxChargeRate')-ElectricityStorageStationaryInput.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
put // 'Output<Capacity*MaxDischargeRate'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityStorageStationaryCapacity.l(years,months)*ElectricityStorageStationaryParameter('MaxDischargeRate')-ElectricityStorageStationaryOutput.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
put // 'CapacityBidRegulationUp<StateOfCharge-Capacity*(1-MaxDepthOfDischarge)'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put ((ElectricityStoredStationary.l(years,months,daytypes,hours--1)+EnergyFlowFromBuildingToStationaryStorage.l(years,months,daytypes,hours)*ElectricityStorageStationaryParameter('EfficiencyCharge')-(EnergyFlowFromStationaryStorageToBuilding.l(years,months,daytypes,hours)+EnergyFlowFromStationaryStorageToNetwork.l(years,months,daytypes,hours))/ElectricityStorageStationaryParameter('EfficiencyDischarge')-ElectricityStorageStationaryLosses.l(years,months,daytypes,hours))-ElectricityStorageStationaryCapacity.l (years,months)*(1-ElectricityStorageStationaryParameter('MaxDepthOfDischarge'))-CapacityBidRegulationUpBattery.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
put // 'CapacityBidRegulationDown<Capacity-StateOfCharge'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElectricityStorageStationaryCapacity.l (years,months)-(ElectricityStoredStationary.l(years,months,daytypes,hours--1)+EnergyFlowFromBuildingToStationaryStorage.l(years,months,daytypes,hours)*ElectricityStorageStationaryParameter('EfficiencyCharge')-(EnergyFlowFromStationaryStorageToBuilding.l(years,months,daytypes,hours)+EnergyFlowFromStationaryStorageToNetwork.l(years,months,daytypes,hours))/ElectricityStorageStationaryParameter('EfficiencyDischarge')-ElectricityStorageStationaryLosses.l(years,months,daytypes,hours))-CapacityBidRegulationDownBattery.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
put // 'CapacityBidRegulationUp<ContractCapacity+ElectricityPurchase'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ContractCapacity.l(years,months)+(Electricity_Purchase.l(years,months,daytypes,hours)-sum(AvailableTECHNOLOGIES,Generation_NetworkSales.l(AvailableTECHNOLOGIES,years,months,daytypes,hours))-EnergyFlowFromStationaryStorageToNetwork.l(years,months,daytypes,hours)-Electricity_PV_Export.l(years,months,daytypes,hours))-CapacityBidRegulationUpBattery.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
put // 'CapacityBidRegulationDown<ContractCapacity-ElectricityPurchase'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ContractCapacity.l(years,months)-(Electricity_Purchase.l(years,months,daytypes,hours)-sum(AvailableTECHNOLOGIES,Generation_NetworkSales.l(AvailableTECHNOLOGIES,years,months,daytypes,hours))-EnergyFlowFromStationaryStorageToNetwork.l(years,months,daytypes,hours)-Electricity_PV_Export.l(years,months,daytypes,hours))-CapacityBidRegulationDownBattery.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
put // 'Input<ElecStationaryXORCharge*1000000'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put (ElecStationaryXORCharge.l(years,months,daytypes,hours)*1000000-ElectricityStorageStationaryInput.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
put // 'Output<(1-ElecStationaryXORCharge)*1000000'/
loop (years,put years.tl /;
put 'hour';
loop (hours, put hours.tl);
put /;
loop (daytypes,  put '', daytypes.tl /;
     loop (months,
               put months.tl,
               loop (hours,
                    put ((1-ElecStationaryXORCharge.l(years,months,daytypes,hours))*1000000-ElectricityStorageStationaryOutput.l(years,months,daytypes,hours)) )
                    put /
                    )
          )
     ;
);
