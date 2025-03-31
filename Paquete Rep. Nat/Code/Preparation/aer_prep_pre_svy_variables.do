/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Natalia Garbiras and Mateo Montenegro
Purpose:       This code prepares the measures reflecting the likelihood that candidates will engage 
			   in irregularities and their popularity from the pre-treatment survey, as well as the
			   number of respondents to the survey, their demographic characteristics, and their 
			   individual responses about candidate irregularity likelihood.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Candidate Covariates from Pre-Treatment Survey
               B. Preparing Number of Responses from Pre-Treatment Survey
			   C. Preparing Respondent Demographics from Pre-Treatment Survey
			   D. Preparing Individual-level Responses for Bootstrap
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                            A. Preparing Candidate Covariates from Pre-Treatment Survey
===============================================================================================*/

import delim "$raw_data/pre_svy_candidate_variables.csv", clear encoding("utf-8")

ren id ID

bys ID: egen mu_p_d_misdeed=mean(p_d_misdeed)
gen d_mean_p_d_misdeed=p_d_misdeed-mu_p_d_misdeed

gen above_mean_p_d_misdeed=(d_mean_p>0) if d_mean_p!=.

drop mu_p_d_misdeed

save "$intermediate_data/pre_svy_candidate_variables_clean.dta", replace

/*===============================================================================================
                             B. Preparing Number of Responses from Pre-Treatment Survey
===============================================================================================*/

import delim "$raw_data/pre_svy_number_respondents.csv", clear encoding("utf-8")

ren id ID

save "$intermediate_data/pre_svy_number_respondents_clean.dta", replace

/*===============================================================================================
                             C. Preparing Respondent Demographics from Pre-Treatment Survey
===============================================================================================*/

if $confidential == 1 {
import delim "$raw_data/pre_svy_respondent_vars.csv", clear encoding("utf-8")

ren id ID

save "$intermediate_data/pre_svy_respondent_vars_clean.dta", replace
}

/*===============================================================================================
                             D. Preparing Individual-level Responses for Bootstrap
===============================================================================================*/

if $confidential == 1 {
import delim "$raw_data/pre_svy_bootstrap_data.csv", clear encoding("utf-8")

ren id ID

save "$intermediate_data/pre_svy_bootstrap_data_clean.dta", replace
}


