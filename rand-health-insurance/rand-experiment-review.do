* Chianvern Wong
* RAND Health Insurance Experiment, Three Decades Later
* Author(s): Aviva Aron-Dine, Liran Einav and Amy Finkelstein

clear all
set more off
cd "/Users/chianvernwong/Downloads/Coursework/14410/Project"
*log using 14410project.log, replace 

use "person_years", clear

// Question b: Duplicate Table 1
matrix table1 = J(6,3,.)
matrix rownames table1 = "Free Care" "25% Coinsurance" "Mixed Coinsurance" ///
	"50% Coinsurance" "95% Coinsurance" "Individual Deductible"
matrix colnames table1 = "Avg Annual Medical Spending" ///
	"Avg Out-of-pocket Share" "Percentage Exceeded MDE"

vl create t1 = (spending_infl share_oop hit_mde)	
local v = 1
local k = 1

foreach y in $t1{
	forvalues plan = 1/6{
		qui sum `y' if rand_plan_group`plan' == 1
		mat table1[`plan',`v'] = r(mean)
	}
	local v = `v' + 1
}
matrix list table1, format(%10.0f)
putexcel set Table1.xlsx, replace
putexcel A1 = matrix(table1), names nformat(number_d2)

// Question d: Regress annual spending on plan type
rename rand_plan_group rand_plan
reg spending_infl rand_plan_group2 rand_plan_group3 rand_plan_group4 ///
	rand_plan_group5 rand_plan_group6, robust
	
// Question f: Add female as control
reg spending_infl rand_plan_group2 rand_plan_group3 rand_plan_group4 ///
	rand_plan_group5 rand_plan_group6 female, robust
	
// Question g: Rerun d for hit_mde=0
reg spending_infl rand_plan_group2 rand_plan_group3 rand_plan_group4 ///
	rand_plan_group5 rand_plan_group6 if hit_mde == 0, robust

// Question h: Add age as control 
reg spending_infl rand_plan_group2 rand_plan_group3 rand_plan_group4 ///
	rand_plan_group5 rand_plan_group6 age if hit_mde == 0 & female == 0, robust

reg spending_infl rand_plan_group2 rand_plan_group3 rand_plan_group4 ///
	rand_plan_group5 rand_plan_group6 age if hit_mde == 0 & female == 1, robust
	
log close
