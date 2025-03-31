/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Natalia Garbiras and Mateo Montenegro
Purpose:       This code prepares the treatment indicators and strata fixed effects for each 
               municipality.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Treatment Indicators and Strata Fixed Effects
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                  A. Preparing Treatment Indicators and Strata Fixed Effects
===============================================================================================*/

import delim "$raw_data/treatment_assignment.csv", clear encoding("utf-8")

ren id ID

gen T_FB=(_assign>1 & _assign<=10) if _assign!=.
gen T_FB_info=(_assign==2 | _assign==5 | _assign==8 )  if _assign!=.
gen T_FB_call=(_assign==3 | _assign==6 | _assign==9 )  if _assign!=.
gen T_FB_both=(_assign==4 | _assign==7 | _assign==10 )  if _assign!=.
gen T_Letter=(_assign>4 & _assign<=10)  if _assign!=.
gen T_Letter_no_sj=(_assign==5 | _assign==6 | _assign==7)  if _assign!=.
gen T_Letter_sj=(_assign==8 | _assign==9 | _assign==10)  if _assign!=.

gen TT_FB=(T_FB==1 & T_Letter==0) if T_FB!=.

gen Treat_Letter=0 if T_FB==0
replace Treat_Letter=1 if TT_FB==1 
replace Treat_Letter=2 if T_Letter==1


gen Treat_Letters=0 if T_FB==0
replace Treat_Letters=1 if TT_FB==1 
replace Treat_Letters=2 if T_Letter_sj==1
replace Treat_Letters=3 if T_Letter_no_sj==1

gen Treat_Ads=0 if T_FB==0
replace Treat_Ads=1 if T_FB_info==1 
replace Treat_Ads=2 if T_FB_call==1
replace Treat_Ads=3 if T_FB_both==1

tab strata, gen(ss)

save "$intermediate_data/treatment_indicators.dta", replace
