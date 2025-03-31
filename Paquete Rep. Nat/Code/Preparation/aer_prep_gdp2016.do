/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This code prepares the covariate of the 2016 municipal GDP. 
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing GDP 2016
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                  A. Preparing GDP 2016
===============================================================================================*/

import delim "$raw_data/anexo-2019-provisional-valor-agregado-municipio-2011-2019.csv", clear encoding("utf-8")

ren códigomunicipio ID
ren a2016 pib_num_2016 
keep ID pib_num_2016 

replace pib_num_2016=pib_num_2016*1000

save "$intermediate_data/gdp2016.dta", replace
