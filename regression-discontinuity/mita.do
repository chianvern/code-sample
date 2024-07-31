* Regression Discontinuity Study based on MITA paper
clear all
cd "/Users/chianvernwong/Downloads/Coursework/14750/PS2"

use "mitaData.dta", clear

* Construct the polynomials
gen x2 = x^2
gen y2 = y^2
gen xy = x*y
gen x3 = x^3
gen y3 = y^3
gen x2y = (x^2)*y
gen xy2 = x*(y^2)

* Regression on cubic polynomials
* Distance below 100km
reg lhhequiv pothuan_mita x y x2 y2 xy x3 y3 x2y xy2 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd < 100, cluster(district)
* Distance below 75km
reg lhhequiv pothuan_mita x y x2 y2 xy x3 y3 x2y xy2 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd < 75, cluster(district)
* Distance below 50km
reg lhhequiv pothuan_mita x y x2 y2 xy x3 y3 x2y xy2 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd < 50, cluster(district)

* Regression on distance to potosi
gen dpot2 = dpot^2
gen dpot3 = dpot^3

* Distance below 100km
reg lhhequiv pothuan_mita dpot dpot2 dpot3 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd < 100, cluster(district)
* Distance below 75km
reg lhhequiv pothuan_mita dpot dpot2 dpot3 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd < 75, cluster(district)
* Distance below 50km
reg lhhequiv pothuan_mita dpot dpot2 dpot3 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd < 50, cluster(district)

