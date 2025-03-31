/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Natalia Garbiras and Mateo Montenegro
Purpose:       This code prepares the media-based measures of irregularities.
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Media Irregularity Outcomes
      		   B. Excluding mentions of MOE reports
			   C. Including mentions of MOE reports
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                  A. Preparing Media Irregularity Outcomes
===============================================================================================*/

import delim "$raw_data/media_irregularities.csv", clear encoding("utf-8")

ren id ID

* Restricting to dates of the intervention:
keep if fechanoticia=="24oct2019" | fechanoticia=="25oct2019" | fechanoticia=="26oct2019" | fechanoticia=="27oct2019" | fechanoticia=="28oct2019"    | fechanoticia=="24/10/2019" | fechanoticia=="25/10/2019" | fechanoticia=="26/10/2019" | fechanoticia=="27/10/2019" | fechanoticia=="28/10/2019" 
* Removing news about voting registration cancellations (which occurs three months before the intervention):
drop if anulaciondecedulas==1

gen media_irreg=1 
gen media_irreg_disturbio=1 if  strpos(delito, "disturbio")
gen media_irreg_sin_disturbio=1 if  strpos(delito, "disturbio")==0
gen media_irreg_compra=1 if  strpos(delito, "compra")
gen media_irreg_sin_compra=1 if  strpos(delito, "compra")==0
gen media_irreg_cand_int=1 if (strpos(delito, "amenaza") | strpos(delito, "asesinato") | strpos(delito, "intimidacion can"))
gen media_irreg_sin_cand_int=1 if (strpos(delito, "amenaza")==0 & strpos(delito, "asesinato")==0 & strpos(delito, "intimidacion can")==0)
gen media_irreg_intimidacion=1 if  (strpos(delito, "intimidacion al votante"))
gen media_irreg_sin_intimidacion=1 if  (strpos(delito, "intimidacion al votante")==0)
gen media_irreg_trashumancia=1 if  (strpos(delito, "trashumancia"))
gen media_irreg_sin_trashumancia=1 if  (strpos(delito, "trashumancia")==0)
gen media_irreg_intervencion=1 if (strpos(delito, "intervencion"))
gen media_irreg_sin_intervencion=1 if (strpos(delito, "intervencion")==0)
gen media_irreg_publicidad=1 if (strpos(delito, "publicidad"))
gen media_irreg_sin_publicidad=1 if (strpos(delito, "publicidad")==0)
gen media_irreg_fraud=1 if (strpos(delito, "fraude elec") | strpos(delito, "otro - media_irregularidad en manejo"))
gen media_irreg_sin_fraud=1 if (strpos(delito, "fraude elec")==0 & strpos(delito, "otro - media_irregularidad en manejo")==0)
gen media_irreg_otro=1 if (strpos(delito, "no especifica") | delito=="otro")
gen media_irreg_sin_otro=1 if (strpos(delito, "no especifica")==0 & delito!="otro")

tempfile main
save `main', replace


/*===============================================================================================
                                  B. Excluding mentions of MOE reports
===============================================================================================*/
 
drop if moedenunciaciudadanos==1

* Only counting each type of irregularity once (to avoid several news about a same irregularity):
collapse (max) media_irreg*, by(ID delito)
collapse (sum) media_irreg*, by(ID)

merge n:1 ID using "$intermediate_data/treatment_indicators.dta", force
drop _m 

#d ;
global media_irreg "media_irreg  media_irreg_disturbio media_irreg_sin_disturbio media_irreg_compra media_irreg_sin_compra media_irreg_cand_int  media_irreg_sin_cand_int 
media_irreg_intimidacion media_irreg_sin_intimidacion media_irreg_trashumancia media_irreg_sin_trashumancia media_irreg_intervencion media_irreg_sin_intervencion 
media_irreg_publicidad media_irreg_sin_publicidad media_irreg_fraud media_irreg_sin_fraud media_irreg_otro media_irreg_sin_otro";
#d cr


foreach z of global media_irreg{
replace `z'=0 if `z'==.
 gen d_`z'=(`z'>0)
}

tempfile reports_nomoe
save `reports_nomoe', replace

/*===============================================================================================
                                  C. Including mentions of MOE reports
===============================================================================================*/

use `main', clear

ren media_irreg media_irreg_inclMOE

keep ID media_irreg_inclMOE delito

* Only counting each type of irregularity once (to avoid several news about a same irregularity):
collapse (max) media_irreg*, by(ID delito)
collapse (sum) media_irreg*, by(ID)

merge n:1 ID using "$intermediate_data/treatment_indicators.dta", force
drop _m 

replace media_irreg_inclMOE=0 if media_irreg_inclMOE==.
gen d_media_irreg_inclMOE=(media_irreg_inclMOE>0)

merge 1:1 ID using `reports_nomoe'
drop _m

save "$intermediate_data/media_irregularity_outcomes.dta", replace



