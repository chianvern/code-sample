* Event Study Design
* Chianvern Wong

// Building Nations through Shared Experiences
// Author(s): Emilio Depetris-Chauvin, Ruben Durante and Filipe Campante

clear all
set more off
cd "/Users/chianvernwong/Downloads/Coursework/14750/PS5"
log using 14750ps5.log, replace 

import delimited "SportsNationBuilding.csv", clear

//(a) Create strong ethnic indicator
gen ethnic = 0 
replace ethnic = 1 if ethnic_sentiment == "Ethnic id more than national" | ethnic_sentiment == "Ethnic id only"

//(b) Create indicator for interview after match
// Dist_match = Match date - Interview date
// Interview after match, Dist_match < 0
gen post = 0
replace post = 1 if dist_match < 0

//(c) Regress Ethnic on post and post_victory with FEs
reghdfe ethnic post post_victory male age age_sq unemployed rural education, ///
	absorb(country_match_fe language_year_id dayweek month day) ///
	vce(cluster country_year_fe)

sum ethnic if post == 0
	
//(d) Timing of effects
//(i) Create 9 dummy variables
// Interview before match, Dist_match > 0
gen b15 = 0
replace b15 = 1 if dist_match >= 13 & dist_match <= 15
gen b12 = 0
replace b12 = 1 if dist_match >= 10 & dist_match <= 12
gen b9 = 0
replace b9 = 1 if dist_match >= 7 & dist_match <= 9
gen b6 = 0
replace b6 = 1 if dist_match >= 4 & dist_match <= 6
// Interview after match, Dist_match < 0
gen x3 = 0
replace x3 = 1 if dist_match >= -3 & dist_match <= -1
gen x6 = 0
replace x6 = 1 if dist_match >= -6 & dist_match <= -4
gen x9 = 0
replace x9 = 1 if dist_match >= -9 & dist_match <= -7
gen x12 = 0
replace x12 = 1 if dist_match >= -12 & dist_match <= -10
gen x15 = 0
replace x15 = 1 if dist_match >= -15 & dist_match <= -13

//Interact with victory terms
gen vb15 = b15*future_victory
gen vb12 = b12*future_victory
gen vb9 = b9*future_victory
gen vb6 = b6*future_victory
gen vb3 = 0
gen va3 = x3*post_victory
gen va6 = x6*post_victory
gen va9 = x9*post_victory
gen va12 = x12*post_victory
gen va15 = x15*post_victory

//(iii) Regress ethnic on newly created victory terms
reghdfe ethnic v* male age age_sq unemployed rural education, ///
	absorb(country_match_fe language_year_id dayweek month day) ///
	vce(cluster country_year_fe)
			
//(iii) Plot key coefficients. Replicate Figure 2
coefplot , vertical drop(_cons male age age_sq unemployed rural education) ///
	yline(0) xtitle(Distance to the match) ytitle(Impact on ethnic identification) ///
	xlabel(1 "-15" 2 "-12" 3 "-9" 4 "-6" 5 "-3" 6 "3" 7 "6" 8 "9" 9 "12" 10 "15") ///
	xline(5.5) omitted 
	
graph export "eventstudy.png", replace	
	
log close





