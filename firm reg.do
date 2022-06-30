use firm_level_MU.dta, clear

pwcorr lad lrd lmu lpen 

* no good result with dummies
regress lmu PEN_dum AD_dum RD_dum

duplicates drop gvkey year, force

xtset gvkey year

xtreg lmu lrd
 
 
xtreg lmu lrd lad lpen i.year, fe vce(r)