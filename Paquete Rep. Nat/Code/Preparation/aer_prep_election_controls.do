/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This code prepares the political controls from the 2014, 2015 and 2018 elections.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Electoral Controls 2018
			   B. Preparing Electoral Controls 2015
			   C. Preparing Electoral Controls 2014
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
                                A. Preparing Electoral Controls 2018
===============================================================================================*/

* 1. Voting Per Party:

import delim "$raw_data/RESULTADOS_ELECTORALES_2018_SENADO_DE_LA_REPUBLICA.csv", clear encoding("utf-8")

ren ndepto departamento
ren nmpio municipio

replace departamento="NORTE DE SANTANDER" if departamento=="NORTE DE SAN"

merge n:1 departamento municipio using `codigos'

keep if _m==3
drop _m

* Votes by party:
bys ID: egen total_votes=sum(votos)
bys ID: egen valid_votes=sum(votos) if candidato!="VOTOS NULOS" & candidato!="VOTOS NO MARCADOS"
bys ID partido: egen votes_blanco_c2018=sum(votos) if candidato=="VOTOS EN BLANCO"
bys ID partido: egen votes_cambioradical_c2018=sum(votos) if partido=="PARTIDO CAMBIO RADICAL"
bys ID partido: egen votes_centrodem_c2018=sum(votos) if partido=="PARTIDO CENTRO DEMOCRÁTICO"
bys ID partido: egen votes_conservador_c2018=sum(votos) if partido=="PARTIDO CONSERVADOR COLOMBIANO"
bys ID partido: egen votes_decentes_c2018=sum(votos) if partido=="COALICIÓN LISTA DE LA DECENCIA (ASI,UP,MAIS)"
bys ID partido: egen votes_liberal_c2018=sum(votos) if partido=="PARTIDO LIBERAL COLOMBIANO"
bys ID partido: egen votes_partU_c2018=sum(votos) if partido=="PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
bys ID partido: egen votes_polo_c2018=sum(votos) if partido=="PARTIDO POLO DEMOCRÁTICO ALTERNATIVO"
bys ID partido: egen votes_verde_c2018=sum(votos) if partido=="PARTIDO ALIANZA VERDE"


collapse (max) votes_* valid_votes total_votes, by(ID)

global party_votes_c2018 "blanco_c2018 cambioradical_c2018 centrodem_c2018 conservador_c2018 decentes_c2018 liberal_c2018 partU_c2018 polo_c2018 verde_c2018"



foreach y of global party_votes_c2018{
gen pct_`y'=votes_`y'*100/valid_votes
replace pct_`y'=0 if pct_`y'==.
}


tempfile elections_c2018

save `elections_c2018', replace

* 2. Turnout:

import delim "$raw_data/Potencial por mesa Elecciones Congreso 2018.csv", clear encoding("utf-8")


replace departamento="NORTE DE SANTANDER" if departamento=="NORTE DE SAN"

ren total registered_voters

merge n:1 departamento municipio using `codigos'

keep if _m==3
drop _m

keep ID registered_voters

collapse (sum) registered_voters, by(ID)

merge 1:1 ID using `elections_c2018'
drop _m

gen part_c2018=total_votes*100/registered_voters



* Replacing average values for municipality that did not participate in elections:

merge 1:1 ID using "$intermediate_data/treatment_indicators.dta"
drop _m 

#delimit ;
global political  part_c2018 pct_blanco_c2018
pct_cambioradical_c2018 pct_centrodem_c2018 pct_conservador_c2018 pct_decentes_c2018
pct_liberal_c2018 pct_partU_c2018 pct_polo_c2018 pct_verde_c2018;
#delimit cr

foreach y of global political{
sum `y' if T_FB!=.
replace `y'=`r(mean)' if ID==52520
}

keep ID pct_* part_c2018

save "$intermediate_data/election_controls_c2018.dta", replace


/*===============================================================================================
                                B. Preparing Electoral Controls 2015
===============================================================================================*/

import delim "$raw_data/RESULTADOS_ELECTORALES_2015_ALCALDIA.csv", clear encoding("utf-8")

ren desc_depto departamento
ren desc_mpio municipio
 
 * Droping invalid votes:
drop if  desc_partido=="VOTOS NULOS"  | desc_partido=="VOTOS NO MARCADOS" | desc_partido=="VOTOS EN BLANCO"

* A few municipalities missing but they are not part of the experiment:
merge n:1 departamento municipio using `codigos'

keep if _m==3
drop _m

collapse (sum) votos, by(ID candidato)

bys ID: egen max_vote=max(votos)
bys ID: egen second_vote=max(votos) if votos!=max_vote
bys ID: egen valid_votes=sum(votos)

collapse (max) max_vote second_vote valid_votes, by(ID)

gen win_margin_a2015=(max_vote-second_vote)*100/valid_votes
replace win_margin_a2015=(max_vote)*100/valid_votes if second_vote==.

keep ID win_margin_a2015

save "$intermediate_data/election_controls_a2015.dta", replace

/*===============================================================================================
                                C. Preparing Electoral Controls 2014
===============================================================================================*/


import delim "$raw_data/RESULTADOS_ELECTORALES_2014_PRESIDENCIA_SEGUNDA_VUELTA.csv", clear encoding("utf-8")

ren desc_depto departamento
ren desc_mpio municipio

replace departamento="NORTE DE SANTANDER" if departamento=="NORTE DE SAN"
 
 * Droping invalid votes:
drop if  desc_candidato=="VOTOS NULOS ."  | desc_candidato=="VOTOS NO MARCADOS ." 


merge n:1 departamento municipio using `codigos'

keep if _m==3
drop _m

* Votes by candidate:
bys ID: egen valid_votes=sum(votos)
bys ID partido: egen votes_santos_2p2014=sum(votos) if desc_candidato=="JUAN MANUEL SANTOS CALDERÓN"
bys ID partido: egen votes_zuluaga_2p2014=sum(votos) if desc_candidato=="ÓSCAR IVÁN ZULUAGA"

collapse (max) votes_* valid_votes, by(ID)


gen pct_santos_2p2014=votes_santos_2p2014*100/valid_votes
gen pct_zuluaga_2p2014=votes_zuluaga_2p2014*100/valid_votes

keep ID pct_santos_2p2014 pct_zuluaga_2p2014

save "$intermediate_data/election_controls_2p2014.dta", replace


