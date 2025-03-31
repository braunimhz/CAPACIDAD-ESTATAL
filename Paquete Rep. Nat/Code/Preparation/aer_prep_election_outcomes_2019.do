/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This code prepares the political outcome and control variables from the 2019 elections
			   at both municipality and candidate level.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Municipal-Level Election Outcomes 2019
			   B. Preparing Candidate-Level Election Outcomes and Covariates 2019
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
                            A. Preparing Municipal-Level Election Outcomes 2019
===============================================================================================*/

import delim "$raw_data/RESULTADOS_ELECTORALES_2019_ALCALDIA.csv", clear  delimiter(";", asstring) varnames(1)

ren depnombre departamento
ren munnombre municipio

replace votos=substr(votos, 1, strpos(votos,",")-1)
destring votos, replace

gen reg_code=string(dep, "%02.0f")+string(mun, "%003.0f")

merge n:1 reg_code using `codigos'

keep if _m==3
drop _m

bys ID: egen total_votes=sum(votos)
bys ID: egen valid_votes=sum(votos) if parnombre!="VOTOS NULOS" & parnombre!="VOTOS NO MARCADOS" 


tempfile main
save `main', replace


* 1. Margin of victory and number of candidates

keep if parnombre!="VOTOS NULOS" & parnombre!="VOTOS NO MARCADOS" & parnombre!="VOTOS EN BLANCO"

gen counter=1
bys ID: egen n_cand_real=sum(counter)
collapse (sum) votos (max) valid_votes total_votes counter, by(ID can)


bys ID: egen n_cand_real=sum(counter)

bys ID: egen max_vote=max(votos)
bys ID: egen second_vote=max(votos) if votos!=max_vote

collapse (max) max_vote second_vote valid_votes total_votes n_cand_real, by(ID)

gen win_marg2019=(max_vote-second_vote)*100/valid_votes

tempfile elect2019
save `elect2019', replace

* 2. Turnout rate

import delim "$raw_data/Potencial por puesto Elecciones Alcaldia 2019.csv", clear encoding("utf-8")

replace departamento="NORTE DE SANTANDER" if departamento=="NORTE DE SAN"

merge n:1 departamento municipio using `codigos'

keep if _m==3
drop _m

ren total registered_voters

collapse (sum) registered_voters, by(ID)

merge 1:1 ID using `elect2019'

gen turnout2019=total_votes*100/registered_voters

keep ID turnout2019 win_marg2019 n_cand_real

save "$intermediate_data/additional_election_outcomes_2019.dta", replace


/*===============================================================================================
                            B. Preparing Candidate-Level Election Outcomes and Covariates 2019
===============================================================================================*/

use `main', clear

keep if parnombre!="VOTOS NULOS" & parnombre!="VOTOS NO MARCADOS" & parnombre!="VOTOS EN BLANCO"

* 1. Generating covariates:

gen coalition=1 if strpos(parnombre, "COAL")
gen citizen_group=1 if strpos(parnombre, "G.S.C.")

collapse (sum) votos (max) valid_votes total_votes coalition citizen_group, by(ID can cannombre)

replace coalition=0 if coalition==.
replace citizen_group=0 if citizen_group==.

* 2. Vote per candidate:

gen pct_vote=votos*100/valid_votes

keep ID can cannombre pct_vote coalition citizen_group

save "$intermediate_data/election_outcomes_2019.dta", replace

