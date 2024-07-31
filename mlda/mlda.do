// MLDA

clear all
set more off
cd "/Users/chianvernwong/Downloads/Coursework/14320/14320 PS6"
use "data/deaths_pset6", clear

// Replicate Mastering Metrics Table 5.2
keep if year >= 1970 & year <= 1983
drop age beertaxa beerpercap winepercap spiritpercap totpercap
preserve

keep if agegr == 2
mat table52 = J(4,4,.)
mat rownames table52 = "All deaths" "SE" "MV Accidents" "SE"
mat colnames table52 = "(1)" "(2) State" "(3)Weight" "(4)State & Weight"

local v = 1
local w = 2	
forvalues i = 1/2 {
	reg mrate legal i.state i.year if dtype == `i', cluster(state)
	mat table52[`v',1] = round(_b[legal], 0.01)
	mat table52[`w',1] = round(_se[legal], 0.01)
	xi: reg mrate legal i.state*year i.year if dtype == `i', cluster(state)
	mat table52[`v',2] = round(_b[legal], 0.01)
	mat table52[`w',2] = round(_se[legal], 0.01)	
	reg mrate legal i.state i.year if dtype == `i' [aw=pop], cluster(state)
	mat table52[`v',3] = round(_b[legal], 0.01)
	mat table52[`w',3] = round(_se[legal], 0.01)
	xi: reg mrate legal i.state*year i.year if dtype == `i' [aw=pop], cluster(state)
	mat table52[`v',4] = round(_b[legal], 0.01)
	mat table52[`w',4] = round(_se[legal], 0.01)
	local v = `v' + 2
	local w = `w' + 2
}

mat list table52
putexcel set Table52.xlsx, replace
putexcel A1 = matrix(table52), names

// Check effect on other age group
restore
preserve
reshape wide legal mrate count pop, i(year state dtype) j(agegr)

// Effect of 18-20yo on 15-17yo
reg mrate1 legal2 i.state i.year, cluster(state)

// Effect of 18-20yo on 21-24yo
reg mrate3 legal2 i.state i.year, cluster(state)

// Repeat (a) with manually coded legal dummy
gen legal_dm = (legal2>0 | legal1>0)

mat table7c = J(4,4,.)
mat colnames table7c = "(1)" "(2) State" "(3)Weight" "(4)State & Weight"
mat rownames table7c = "All deaths new" "SE" "MV Accidents new" "SE"

local v = 1
local w = 2	
forvalues i = 1/2 {
	reg mrate2 legal_dm i.state i.year if dtype == `i', cluster(state)
	mat table7c[`v',1] = round(_b[legal], 0.01)
	mat table7c[`w',1] = round(_se[legal], 0.01)
	xi: reg mrate2 legal_dm i.state*year i.year if dtype == `i', cluster(state)
	mat table7c[`v',2] = round(_b[legal], 0.01)
	mat table7c[`w',2] = round(_se[legal], 0.01)	
	reg mrate2 legal_dm i.state i.year if dtype == `i' [aw=pop2], cluster(state)
	mat table7c[`v',3] = round(_b[legal], 0.01)
	mat table7c[`w',3] = round(_se[legal], 0.01)
	xi: reg mrate2 legal_dm i.state*year i.year if dtype == `i' [aw=pop2], cluster(state)
	mat table7c[`v',4] = round(_b[legal], 0.01)
	mat table7c[`w',4] = round(_se[legal], 0.01)
	local v = `v' + 2
	local w = `w' + 2
}

mat rowjoinbyname table52new = table52 table7c
mat list table52new
putexcel set Table52new.xlsx, replace
putexcel A1 = matrix(table52new), names

// Event study estimates
restore

keep if agegr == 2
keep if dtype == 2
drop if state == 17 | state == 26  

//use "data/deaths_pset6", clear

gen legal_dm = 0
replace legal_dm = 1 if legal > 0
tsset state year

gen rt_0 = legal_dm - L.legal_dm
gen year_rt0 = year if rt_0 == 1
egen year_switch = max(year_rt0), by(state)
gen relative_year = year - year_switch // Event time
gen post_event = 0
replace post_event = 1 if year >= year_switch

* Generating 3 leads and 5 lags
gen lead3 = (year <= year_switch - 3)
gen lead2 = (year == year_switch - 2)
gen lead1 = (year == year_switch - 1)
gen lag0 = (year == year_switch)
gen lag1 = (year == year_switch + 1)
gen lag2 = (year == year_switch + 2)
gen lag3 = (year == year_switch + 3)
gen lag4 = (year == year_switch + 4)
gen lag5 = (year >= year_switch + 5)

* Event study estimates
// Without weighting
reg mrate lead3 lead2 o.lead1 lag* i.year i.state, cluster(state)
 
coefplot, vertical keep(lead* lag*) ///
	order (lead3 lead2 lead2 lead1 lag0 lag1 lag2 lag3 lag4 lag5) ///
	title("Effect of reducing the MLDA on MVA mortality (unweighted)") ///
	xtitle("Relative year") ytitle("Effect on MVA mortality") ///
	xlabel(1 "-3" 2 "-2" 3 "-1" 4 "0" 5 "1" 6 "2" 7 "3" 8 "4" 9 "5") ///	
	xline(3.5) omitted
graph export "Unweighted.png", replace	

// With weighting
reg mrate lead3 lead2 o.lead1 lag* i.year i.state [aw=pop], cluster(state)
 
coefplot, vertical keep(lead* lag*) ///
	order (lead3 lead2 lead2 lead1 lag0 lag1 lag2 lag3 lag4 lag5) ///
	title("Effect of reducing the MLDA on MVA mortality (Weighted)") ///
	xtitle("Relative year") ytitle("Effect on MVA mortality") ///
	xlabel(1 "-3" 2 "-2" 3 "-1" 4 "0" 5 "1" 6 "2" 7 "3" 8 "4" 9 "5") ///	
	xline(3.5) omitted
graph export "Weighted.png", replace
