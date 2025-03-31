/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Natalia Garbiras and Mateo Montenegro
Purpose:       This code prepares the outcomes and covariates of citizen reports to the MOE in 2019,
			   2018 and 2015.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing MOE report variables
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                 A. Preparing MOE report variables
===============================================================================================*/

* 1. Reports in the intervention period:

import delim "$raw_data/moe_reportes_24_a_28_octubre2019.csv", clear encoding("utf-8")

ren codciud ID
ren reportes_ciudadanos reportMOE_any
ren reportes_ciudadanos_calidad_medi reportMOE_any_quality

gen d_reportMOE_any=(reportMOE_any>0)
gen d_reportMOE_any_quality=(reportMOE_any_quality>0)

tempfile main
save `main', replace

* 2. Reports in the intervention period:

import delim "$raw_data/moe_reportes_despues_28_octubre2019.csv", clear encoding("utf-8")

ren codciud ID
ren reportes_ciudadanos reportMOE_late_any
ren reportes_ciudadanos_calidad_medi reportMOE_late_any_quality

gen d_reportMOE_late_any=(reportMOE_late_any>0)
gen d_reportMOE_late_any_quality=(reportMOE_late_any_quality>0)

merge 1:1 ID using `main'
drop _m
save `main', replace

* 3. Reports in congressional elections 2018:

import delim "$raw_data/moe_reportes_congreso_2018.csv", clear encoding("utf-8")

ren codciud ID
ren reportes_ciudadanos reports_any_MOE_c2018

merge 1:1 ID using `main'
drop _m
save `main', replace

* 4. Reports in mayoral elections 2015:

import delim "$raw_data/moe_reportes_alcaldia_2015.csv", clear encoding("utf-8")

ren codciud ID
ren reportes_ciudadanos reports_any_MOE_a2015

merge 1:1 ID using `main'
drop _m

save "$intermediate_data/moe_reports.dta", replace
