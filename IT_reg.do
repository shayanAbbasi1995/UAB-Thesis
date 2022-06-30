use ult_df_trim1_1_trim2, clear

forvalues s=95/99{
bysort year: egen mkvalt_`s' = pctile(mkvalt), p(`s')
}

forvalues s=95/99{
bysort year: egen mu_10_`s' = pctile(mu_10), p(`s')
}

forvalues s=95/99{
gen super`s'_mkvalt = 1 if mkvalt > mkvalt_`s'
replace super`s'_mkvalt = 0 if super`s'_mkvalt == .
}

forvalues s=95/99{
gen super`s'_mu_10 = 1 if mu_10 > mu_10_`s'
replace super`s'_mu_10  = 0 if super`s'_mu_10 == .
}

forvalues s=95/99{
gen super`s' = super`s'_mu_10 * super`s'_mkvalt
}

gen is_IT = 1 if ind2d == 51
replace is_IT = 0 if ind2d != 51
replace is_IT = 0 if ind2d == .

sort gvkey year 
gen RD = xrd*1000
gen RD_D = (RD/usgdp)*100
gen rd_s = RD/sale
gen AD = xad*1000
gen AD_D = (AD/usgdp)*100
gen lad = log(AD)
gen lrd = log(RD)
gen XSGA_D = (xsga/usgdp)*100
gen ad_s = AD/sale
gen lnrd_s = ln(rd_s)
gen lnad_s = ln(ad_s)
gen lnpen = penaltyamount/sale_d
gen lnpen_s = ln(lnpen)
bysort year: egen TRD = sum(RD_D)
bysort year: egen TAD = sum(AD_D)
gen RD_s = TRD/totsales
gen AD_s = TAD/totsales
gen lnsga_s 	= ln(xsga_d/sale_d)
gen AD_dum		= 1 if AD~=. & AD>0
replace AD_dum 	= 0 if AD_dum==.
gen RD_dum		= 1 if RD~=. & RD>0
replace RD_dum	= 0 if RD_dum==.
gen lmu = log(mu_3)
gen lxsga = log(xsga)
gen lpen = log(penaltyamount/usgdp)
gen tot_capex = log((ppegt + intan)/usgdp)
gen PEN_dum		= 1 if penaltyamount~=. & penaltyamount>0
replace PEN_dum	= 0 if PEN_dum==.

* check super firms within industries

pwcorr super99 is_IT AD_dum RD_dum PEN_dum, star(0.05)

forvalues s = 95/99{
logit super`s' is_IT AD_dum RD_dum PEN_dum
margins, dydx(*)

tabulate super`s' ind2d, cell chi2 column expected row
}



* Robustness through other markups
forvalues j = 3/9{

forvalues s=95/99{
bysort year: egen mu_`j'_`s' = pctile(mu_`j'), p(`s')
}

forvalues s=95/99{
gen super`s'_mu_`j' = 1 if mu_`j' > mu_`j'_`s'
replace super`s'_mu_`j'  = 0 if super`s'_mu_`j' == .
}

forvalues s=95/99{
gen super`s'_`j' = super`s'_mu_`j' * super`s'_mkvalt
}

}

forvalues s = 95/99{
forvalues j = 3/9{
logit super`s'_`j' is_IT AD_dum RD_dum PEN_dum
margins, dydx(*)

tabulate super`s'_`j' ind2d, cell chi2 column expected row
}
}

forvalues j = 11/14{

forvalues s=95/99{
bysort year: egen mu_`j'_`s' = pctile(mu_`j'), p(`s')
}

forvalues s=95/99{
gen super`s'_mu_`j' = 1 if mu_`j' > mu_`j'_`s'
replace super`s'_mu_`j'  = 0 if super`s'_mu_`j' == .
}

forvalues s=95/99{
gen super`s'_`j' = super`s'_mu_`j' * super`s'_mkvalt
}
}

forvalues s = 95/99{
forvalues j = 11/14{
logit super`s'_`j' is_IT AD_dum RD_dum PEN_dum
margins, dydx(*)

tabulate super`s'_`j' ind2d, cell chi2 column expected row
}
}
