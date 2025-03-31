/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This code prepares the indicator for whether candidates have a history of past 
               malfeasance acording to the NGO PARES.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Past Malfeasance Variable From NGO PARES
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                  A. Preparing Past Malfeasance Variable From NGO PARES
===============================================================================================*/

import delim "$raw_data/PARES_candidate_past_malfeasance.csv", clear encoding("utf-8") varnames(1)

ren id ID

merge n:1 ID using "$intermediate_data/treatment_indicators.dta"
drop _m


keep ID can cuestionado

save "$intermediate_data/candidate_past_malfeasance.dta", replace
