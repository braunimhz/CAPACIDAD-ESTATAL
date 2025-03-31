/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Natalia Garbiras and Mateo Montenegro
Purpose:       This code prepares the municipal socieconomic covariates coming from the CEDE dataset
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Socioeconomic Covariates from CEDE Panels
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                 A. Preparing Socioeconomic Covariates from CEDE Panels
===============================================================================================*/


* 1. Homicide data:

use "$raw_data/PANEL_CONFLICTO_Y_VIOLENCIA2017.dta", clear

keep if ano==2017
ren codmpio ID
keep ID homicidios

tempfile socioeconomic
save `socioeconomic', replace

* 2. Rurality rate:

use "$raw_data/PANEL_CARACTERISTICAS_GENERALES(2020).dta", clear

keep if ano==2017
ren codmpio ID

gen indruralildad2017=indru*100

keep ID indruralildad2017

merge 1:1 ID using `socioeconomic'
keep if _m==3
drop _m

save `socioeconomic', replace

* 3. Poverty rate:

use "$raw_data/PANEL_CARACTERISTICAS_GENERALES(2020).dta", clear

keep if ano==2005
ren codmpio ID

keep ID nbi
ren nbi nbi2005

* Filling in for missing data from external sources:
replace nbi2005=26.23 if ID==19300
replace nbi2005=56.20 if ID==70221
replace nbi2005=92.26 if ID==23815


merge 1:1 ID using `socioeconomic'
keep if _m==3
drop _m

save "$intermediate_data/socioeconomic_controls.dta", replace
