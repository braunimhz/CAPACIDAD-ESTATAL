/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This code prepares the measures of engagement and reach of the Facebook ads.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Facebook Metric Variables 2018
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                  A. Preparing Facebook Metric Variables 2018
===============================================================================================*/

import delim "$raw_data/facebook_ad_metrics.csv", clear encoding("utf-8")

gen ID=substr(adsetname,strlen(adsetname)-4,strlen(adsetname))
destring ID, replace

merge 1:1 ID using "$intermediate_data/treatment_indicators.dta", force
drop _m 

global metrics "reach impressions uniqueoutboundclicks postcomments postreactions postshares"

foreach y of global metrics{
replace `y'=0 if `y'==. & T_FB!=.
}

gen no_Reach=(reach==0)
keep ID reach impressions uniqueoutboundclicks postcomments postreactions postshares

gen no_Reach=(reach==0)
ren reach Reach

replace Reach=Reach/1000

save "$intermediate_data/facebook_ad_metrics.dta", replace
