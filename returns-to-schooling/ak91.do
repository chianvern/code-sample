* Working with Angrist & Krueger 1991 data to estimate the economic returns to schooling

clear all
set more off
cd "/Users/chianvernwong/Downloads/Coursework/14320/14320 PS6"

// Year of schooling vs QOB
use "data/ak91", clear	

// Generate variable, yqob to combine yob and qob
gen yqob = yob
replace yqob = yob + 0.25 if qob == 2
replace yqob = yob + 0.50 if qob == 3
replace yqob = yob + 0.75 if qob == 4

// Generate average schooling by yqob
egen avg_schooling = mean(s), by(yqob)

// Plot avg year of schooling vs qob	
twoway (scatter avg_schooling yqob if qob == 1, mcolor(red))        	///
	   (scatter avg_schooling yqob if qob == 2, mcolor(gray))    		///
	   (scatter avg_schooling yqob if qob == 3, mcolor(gray))        	///
	   (scatter avg_schooling yqob if qob == 4, mcolor(blue)),		 	///
	   legend(label(1 "Q1") label(2 "Q2") label(3 "Q3") label(4 "Q4")) 	///
	   xtitle("Year-Quarter of Birth") ytitle("Average Schooling")  ///
	   title("Average Schooling vs Quarter of Birth")
graph export "Average Schooling.png", replace	

// Generate weekly wages by yqob
egen avg_wages = mean(lnw), by(yqob)

// Plot avg year of schooling vs qob	
twoway (scatter avg_wages yqob if qob == 1, mcolor(red))        		///
	   (scatter avg_wages yqob if qob == 2, mcolor(gray))    			///
	   (scatter avg_wages yqob if qob == 3, mcolor(gray))        		///
	   (scatter avg_wages yqob if qob == 4, mcolor(blue)),		 		///
	   legend(label(1 "Q1") label(2 "Q2") label(3 "Q3") label(4 "Q4")) 	///
	   xtitle("Year-Quarter of Birth") ytitle("Average Weekly Wages")  ///
	   title("Average Weekly Wages vs Quarter of Birth")
graph export "Average Wages.png", replace	

// Replicate MM Table 6.5
// Investigate the issue of over-identified model
mat table65 = J(5,5,.)
mat rownames table65 = "YOS" "SE" "FS F-stats" "Instruments" "YOB Control"
mat colnames table65 = "OLS (1)" "2SLS (2)" "OLS(3)" "2SLS (4)" "2SLS (5)"

// Generate dummy for qob
qui tab qob, gen(q)

// Col 1: OLS, no control
reg lnw s, r
mat table65[1,1] = round(_b[s], 0.001)
mat table65[2,1] = round(_se[s], 0.0001)

// Col 2: 2SLS, no control
ivregress 2sls lnw (s = q4), r
mat table65[1,2] = round(_b[s], 0.001)
mat table65[2,2] = round(_se[s], 0.0001)
estat firststage
mat table65[3,2] = round(r(singleresults)[1,4],1)

// Col 3: OLS, add yob control
reg lnw s i.yob, r
mat table65[1,3] = round(_b[s], 0.001)
mat table65[2,3] = round(_se[s], 0.0001)

// Col 4: 2SLS, add yob control
ivregress 2sls lnw (s = q4) i.yob, r
mat table65[1,4] = round(_b[s], 0.001)
mat table65[2,4] = round(_se[s], 0.0001)
estat firststage
mat table65[3,4] = round(r(singleresults)[1,4],1)

// Col 5: 2SLS, add yob control
ivregress 2sls lnw (s = q2 q3 q4) i.yob, r
mat table65[1,5] = round(_b[s], 0.001)
mat table65[2,5] = round(_se[s], 0.0001)
estat firststage
mat table65[3,5] = round(r(singleresults)[1,4],1)

// Add 30 instruments
mat C = J(5,1,.)
mat colnames C = "2SLS (6)"
mat table65 = (table65, C)

ivregress 2sls lnw (s = q2 q3 q4 i.yob#i.qob) i.yob, r
mat table65[1,6] = round(_b[s], 0.001)
mat table65[2,6] = round(_se[s], 0.0001)
estat firststage
mat table65[3,6] = round(r(singleresults)[1,4],1)

// Add 150 instruments
mat C = J(5,1,.)
mat colnames C = "2SLS (7)"
mat table65 = (table65, C)

ivregress 2sls lnw (s = q2 q3 q4 i.yob#i.qob i.sob#i.qob) i.yob i.sob, r
mat table65[1,7] = round(_b[s], 0.001)
mat table65[2,7] = round(_se[s], 0.0001)

mat list table65	
putexcel set Table65.xlsx, replace
putexcel A1 = matrix(table65), names
