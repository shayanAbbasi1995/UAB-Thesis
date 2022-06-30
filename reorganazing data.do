* reorganazing data and doing the regressions of the original paper


cd "G:\My Drive\UAB UNI\Thesis\Competition\Codes\RMP_DLEU - Market power Jan eeckout code for data replication\data\"
use ult_df_trim1_1_trim2.dta, clear

bysort year:  	egen TOTSALES 	= sum(sale_d)
bysort year:	egen TOTCOST1	= sum(totcost1)
bysort year:	egen TOTCOST2	= sum(totcost2)
bysort year:	egen TOTEMP		= sum(emp)

bysort year:	egen TOTCOGS	= sum(cogs_d)
bysort year:	egen TOTSGA		= sum(xsga_d)
bysort year:	egen TOTK		= sum(capital_d)
bysort year:	egen TOTrK		= sum(kexp)


gen share_firm_agg 				= sale_d/TOTSALES
gen pr  = (sale_d - cogs_d - xsga_d - kexp)/sale_d
gen pr_alt  = (sale_d - cogs_d - xsga_d - .1*capital_d)/sale_d
bysort year: egen F = sum(xsga_d+kexp)
*1  WEIGHTED
	* 2.1.1 costshares
forvalues c=1/3 {
gen costshare`c'_w 					= costshare`c'*share_firm_agg
bysort year: egen COSTSHARE`c'_AGG 	= sum(costshare`c'_w)
}

gen mkvalt_AGG 	= mkvalt/TOTSALES
*replace mkvalt_AGG= . if mkvalt_AGG==0
label var mkvalt_AGG " Market Value/Sales 

gen div_ms_agg 					= share_firm_agg*dividend_d
bysort year: egen DIV_AGG 		= sum(dividend_d)
replace DIV_AGG					= DIV_AGG/TOTSALES
label var DIV_AGG "Dividend/Sales

*--------------------------------------------------------------------------------*
* 2.2 MARKUPS	
	
	* 2.2.A SALES WEIGHTS
forvalues i=3/16{
bysort year: egen MARKUP`i'_AGG 	= sum(share_firm_agg*mu_`i')
label var MARKUP`i'_AGG "Markup `i'[w=s]
}



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

bysort year ind2d: egen AD_D_AGG = sum(AD_D)
label var AD_D_AGG  "Advertisement aggregated by industry for each year"

bysort year ind2d: egen PEN_AGG = sum(penaltyamount)
label var PEN_AGG  "Penalty amount aggregated by industry for each year"

bysort year ind2d: egen RD_D_AGG = sum(RD_D)
label var RD_D_AGG  "Research and development amount aggregated by industry for each year" 

bysort year ind2d: egen XSGA_D_AGG = sum(XSGA_D)
label var RD_D_AGG  "General, admin amount aggregated by industry for each year" 

bysort year ind2d: egen tot_capex_AGG = sum(tot_capex)
label var RD_D_AGG  "General, admin amount aggregated by industry for each year"

bysort year ind2d: egen AD_D_mean = mean(AD_D)
label var AD_D_AGG  "Total capital (ppegt+intan) mean by industry for each year"

bysort year ind2d: egen PEN_mean = mean(penaltyamount)
label var PEN_AGG  "Penalty amount mean by industry for each year"

bysort year ind2d: egen RD_D_mean = mean(RD_D)
label var RD_D_AGG  "Research and development amount mean by industry for each year" 

bysort year ind2d: egen XSGA_D_mean= mean(XSGA_D)
label var RD_D_AGG  "General, admin amount mean by industry for each year" 

bysort year ind2d: egen tot_capex_mean= mean(tot_capex)
label var RD_D_AGG  "Total capital (ppegt+intan) amount mean by industry for each year" 

* data for firm-level regressions
preserve
keep gvkey year ind2d lrd lad lmu lpen lxsga PEN_dum RD_dum AD_dum tot_capex
save "firm_level_MU.dta", replace
restore

estimate store extensive
keep if xsga_d~=. 
keep if xrd~=.
keep if xad~=.
keep if xrd>0
keep if xad>0

gen mu_spec1	= mu_10
label var mu_spec1 "markup red tech 
gen mu_spec2 	= mu_11
label var mu_spec2 "markup blue tech
gen MARKUP_spec1 = MARKUP10_AGG
label var MARKUP_spec1 "AGG MARKUP (Trad. PF)
gen MARKUP_spec2 = MARKUP11_AGG
label var MARKUP_spec2 "AGG MARKUP (Mod. PF)
gen MARKUP_spec1_w = MARKUP10_AGG_w1
label var MARKUP_spec1_w "AGG MARKUP (Trad. PF w=input)
gen MARKUP_spec2_w = MARKUP11_AGG_w2
label var MARKUP_spec2_w "AGG MARKUP (Mod. PF w=input)
bysort year: egen MARKUP_cal_s 	= sum(.85*share_firm_agg*sale_d/cogs_d)
bysort year: egen MARKUP_cal_tc = sum(.85*m_totcost*sale_d/cogs_d)
gen MARKUP_spec1_wtc = MARKUP10_AGG_w6
label var MARKUP_spec1_wtc "AGG MARKUP (Mod. PF w=totcost)


* FIGURES
cd "G:\My Drive\UAB UNI\Thesis\Competition\Codes\RMP_DLEU - Market power Jan eeckout code for data replication/output/figures/"
*---------------------------------------------------------------------------------------------------------------------------*
* Fig 1. 	MAIN FACT - Weighted aggregate Markup
preserve
sort year
drop if year==year[_n-1]
sort year
scatter MARKUP_spec1 year, c(l) lcolor(red ) lpattern(solid) symbol(none) lwidth(thick) ytitle("") xlabel(2000 2005 2010 2015) xtitle("") legend(ring(0)  pos(5) ) 
graph export Fig1.eps, replace
scatter MARKUP_spec1 year, c(l) lcolor(black ) lpattern(solid) symbol(none) lwidth(thick) ytitle("") xlabel(2000 2005 2010 2015) xtitle("") legend(ring(0)  pos(5) ) 
graph export BW/Fig1.eps, replace


* Fig 2a and 2b. Aggregate Markup
scatter MARKUP_spec1 MARKUP3_AGG year, c(l l) lcolor(red green) lpattern(solid dash) msymbol(none none) lwidth(thick thick) ytitle("") xlabel(2000 2005 2010 2015) xtitle("") legend(ring(0)  pos(11) ) 
graph export Fig2a.eps, replace
scatter MARKUP_spec1 MARKUP3_AGG year, c(l l) lcolor(black black) lpattern(solid dash) msymbol(none none) lwidth(thick thick) ytitle("") xlabel(2000 2005 2010 2015) xtitle("") legend(ring(0)  pos(11) ) 
graph export BW/Fig2a.eps, replace
scatter MARKUP_spec1  MARKUP10_AGG_w2 year, c(l l l) lcolor(red green)  lpattern(solid dash) msymbol(none none) lwidth(thick thick) ytitle("") xlabel(2000 2005 2010 2015) xtitle("") legend(ring(0)  pos(11) ) 
graph export Fig2b.eps, replace
scatter MARKUP_spec1  MARKUP10_AGG_w2 year, c(l l l) lcolor(black black)  lpattern(solid dash) msymbol(none none) lwidth(thick thick) ytitle("") xlabel(2000 2005 2010 2015) xtitle("") legend(ring(0)  pos(11) ) 
graph export BW/Fig2b.eps, replace




cd "G:\My Drive\UAB UNI\Thesis\Competition\Codes\RMP_DLEU - Market power Jan eeckout code for data replication\data\"

* aggregated data for restriction regressions
preserve
keep gvkey year ind2d xad xrd xsga tot_capex AD_D RD_D PEN_dum PEN_AGG mkvalt xsga_d mkvalt_d capital_d intan_d xlr_d MARKUP3_AGG MARKUP4_AGG MARKUP5_AGG MARKUP6_AGG MARKUP7_AGG MARKUP8_AGG MARKUP9_AGG MARKUP10_AGG MARKUP11_AGG MARKUP12_AGG MARKUP13_AGG  AD_D_AGG RD_D_AGG tot_capex_AGG AD_D_mean PEN_mean RD_D_mean XSGA_D_mean tot_capex_mean
save "agg_data.dta", replace
restore
