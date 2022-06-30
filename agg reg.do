use agg_data.dta, clear

preserve
keep year ind2d MARKUP3_AGG MARKUP4_AGG MARKUP5_AGG MARKUP6_AGG MARKUP7_AGG MARKUP8_AGG MARKUP9_AGG MARKUP10_AGG MARKUP11_AGG MARKUP12_AGG PEN_AGG RD_D_AGG AD_D_AGG tot_capex_AGG AD_D_mean PEN_mean RD_D_mean XSGA_D_mean tot_capex_mean
duplicates drop year ind2d, force
save "agg_data_MU.dta"
restore


use agg_data_MU.dta, clear
merge 1:1 year ind2d using ind2d_agg_regulation
keep if MARKUP10_AGG ~= . 


pwcorr AD_D_mean PEN_mean RD_D_mean XSGA_D_mean tot_capex_mean

* WITH MEANS
gen lmu = log(MARKUP10_AGG)
gen lad = log(AD_D_mean)
gen lrd = log(RD_D_mean)
gen lpen = log(PEN_mean)
gen lxga = log(XSGA_D_mean)
gen lcapex = log(tot_capex_mean)
gen lrestric = log(industry_restrictions_1_0)
gen res_pen = lrestric*lpen
replace res_pen = 0 if res_pen==.

* MODEL for agg data

xtset ind2d year

qui reg lmu lrestric lpen, vce(r)
estimates store m0 

qui xtreg lmu lrestric lpen,fe vce(r)
estimates store m1

qui xtreg lmu lrestric lpen i.year,fe vce(r)
estimates store m2

qui xtreg lmu lrestric lrd lad lpen, vce(r)
estimates store m3

qui xtreg lmu lrestric lrd lad lpen, fe vce(r)
estimates store m4

qui xtreg lmu lrestric lrd lad lpen i.year, fe vce(r)
estimates store m5

estimates table m0 m1 m2 m3 m4 m5, star(0.10 .05 .01) 

estimates table m0 m1 m2 m3 m4 m5, se(%7.4f) stat(r2  N)


* Multicoliniearity
reg lmu lrestric lrd lad lpen, vce(r)
vif

* Non-linearity/ov
ovtest 

* we had Hetroscedasticity - solved with robust standard errors
reg lmu lrestric lrd lad lpen
hettest, rhs fstat

* visualization 
preserve
keep if ind2d==22
twoway (tsline MARKUP10_AGG)
restore


* Robustness with all other markups and the other regultion index
preserve
forvalues i=4/6{
drop lrestric
gen lmu`i' = log(MARKUP`i'_AGG)
gen lrestric = log(industry_restrictions_2_0)

xtset ind2d year

qui reg lmu lrestric lpen, vce(r)
estimates store m0 

qui xtreg lmu lrestric lpen,fe vce(r)
estimates store m1

qui xtreg lmu lrestric lpen i.year,fe vce(r)
estimates store m2

qui xtreg lmu lrestric lrd lad lpen, vce(r)
estimates store m3

qui xtreg lmu lrestric lrd lad lpen, fe vce(r)
estimates store m4

qui xtreg lmu lrestric lrd lad lpen i.year, fe vce(r)
estimates store m5

estimates table m0 m1 m2 m3 m4 m5, star(0.10 .05 .01) 

estimates table m0 m1 m2 m3 m4 m5, b(%7,3f) se(%7,3f) stat(r2  N)
}
restore

use agg_data_MU.dta, clear
merge 1:1 year ind2d using ind2d_agg_regulation
keep if MARKUP3_AGG ~= . 



