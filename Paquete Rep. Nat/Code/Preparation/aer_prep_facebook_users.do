/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This code prepares the covariate of the number of Facebook users per municipality.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Facebook User Covariate
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                 A. Preparing Facebook User Covariate
===============================================================================================*/

import delim "$raw_data/fb_pre_users.csv", clear encoding("utf-8")

ren id ID

keep ID fb_users_pre

save "$intermediate_data/fb_users_clean.dta", replace
