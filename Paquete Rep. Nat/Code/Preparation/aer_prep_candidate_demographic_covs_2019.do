/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This code prepares the candidate demographic variables (age and sex).
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Demographic Candidate Covariates 2019
===================================================================================================*/

est clear
set more off

** ---------------------------------------------------------
** Preparing crosswalk between Registraduria and DANE codes:
** ---------------------------------------------------------

import delim "$raw_data/identifier_crosswalk.csv", clear encoding("utf-8")
ren code_dane ID
ren code_regis reg_code
tostring reg_code, replace 
replace reg_code="0"+reg_code if strlen(reg_code)<5


tempfile codigos 
save `codigos', replace


/*===============================================================================================
                            A. Preparing Demographic Candidate Covariates 2019
===============================================================================================*/

import delim "$raw_data/Registraduria - Datos Personales Candidatos.csv", clear encoding("utf-8") varnames(1)

keep if corporacion_cargo=="ALCALDIA"
destring cod_dpto, replace
destring cod_mcpio, replace
gen reg_code=string(cod_dpto, "%02.0f")+string(cod_mcpio, "%003.0f")

merge n:1 reg_code using `codigos'

keep if _m==3
drop _m

* Keeping only candidates in municipalities in the sample:

merge n:1 ID using "$intermediate_data/treatment_indicators.dta"
drop _m 
keep if T_FB!=.


* Cleaning up names:

gen cannombre=nombre1+" "+nombre2+" "+apellido1+" "+apellido2
replace cannombre=subinstr(cannombre, "Ã‘", "Ñ", .)
replace cannombre=subinstr(cannombre, "  ", " ", .)
replace cannombre=trim(cannombre)


* Fuzzy merge with voting data (with manual check):

gen idm=_n
tempfile master
save `master', replace


use "$intermediate_data/election_outcomes_2019.dta", clear 

keep ID cannombre can
replace cannombre=trim(cannombre)
gen idu=_n

tempfile using
save `using', replace

use `master', clear

reclink ID cannombre using `using' , idm(idm) idu(idu)  gen(score) required(ID) orbloc(ID)
* A few candidates dropped out of the race:
keep if _m==3
drop _m

gen female=(genero=="F")
destring edad, gen(age)
gen l_age=log(age)
keep ID cannombre can female l_age

save "$intermediate_data/candidate_demographic_covariates_2019.dta", replace
