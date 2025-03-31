/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Natalia Garbiras and Mateo Montenegro
Purpose:       This code prepares the irregularity outcomes from the post-treatment survey, as well
			   as the number of respondents and their demographic characteristics.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Irregularity Outcomes from Post-Treatment Survey
               B. Preparing Number of Responses from Post-Treatment Survey
			   C. Preparing Respondent Demographics from Pre-Treatment Survey
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                  A. Preparing Irregularity Outcomes from Post-Treatment Survey
===============================================================================================*/

import delim "$raw_data/post_svy_irregularity_outcomes.csv", clear encoding("utf-8")

ren id ID

* Generating index:

merge 1:1 ID using "$intermediate_data/treatment_indicators.dta"
drop _m 

global misdeeds "likelihood_misdeed_1 likelihood_misdeed_2 likelihood_misdeed_3 likelihood_misdeed_4 likelihood_misdeed_5 likelihood_misdeed_6"

gen misdeeds_index=0
foreach y of global misdeeds{
sum `y' if T_FB==0
gen z_`y'=(`y'-`r(mean)')/`r(sd)' if `r(sd)'>0
replace misdeeds_index=misdeeds_index+((`y'-`r(mean)')/`r(sd)') if `r(sd)'>0
}

sum misdeeds_index if T_FB==0
gen z_misdeeds_index=(misdeeds_index-`r(mean)')/`r(sd)' if `r(sd)'>0

keep ID z_*

save "$intermediate_data/post_svy_irregularity_outcomes_clean.dta", replace

/*===============================================================================================
                                  B. Preparing Number of Responses from Post-Treatment Survey
===============================================================================================*/

import delim "$raw_data/post_svy_number_respondents.csv", clear encoding("utf-8")

ren id ID

save "$intermediate_data/post_svy_number_respondents_clean.dta", replace

/*===============================================================================================
                                 C. Preparing Respondent Demographics from Pre-Treatment Survey
===============================================================================================*/

if $confidential == 1 {
import delim "$raw_data/post_svy_respondent_vars.csv", clear encoding("utf-8")

ren id ID

save "$intermediate_data/post_svy_respondent_vars_clean.dta", replace
}
