/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Natalia Garbiras and Mateo Montenegro
Purpose:       This code prepares the 2018 population variables.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Population Variables 2018
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                 A. Preparing Population Variables 2018
===============================================================================================*/

import delim "$raw_data/proyecciones-poblacion-Municipal_2018-2026.csv", clear encoding("utf-8")

ren dpmp ID
ren año year
keep if year==2018
keep if áreageográfica=="Total"
keep ID total total_* year 

gen pop2018_18older=0
forvalues i=18(1)99{
replace pop2018_18older=pop2018_18older+total_`i'
}
replace pop2018_18older=pop2018_18older+total_100ymás

ren total pop2018

gen l_pop2018=log(pop2018)

keep ID pop2018_18older pop2018 l_pop2018

save "$intermediate_data/population.dta", replace
