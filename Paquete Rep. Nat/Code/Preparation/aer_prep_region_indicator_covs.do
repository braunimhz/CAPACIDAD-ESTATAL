/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Natalia Garbiras and Mateo Montenegro
Purpose:       This code prepares the geographic region indicators for each municipality
----------------------------------------------------------------------------------------------------
Index:		   A. Preparing Region Variables
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                  A. Preparing Region Variables
===============================================================================================*/

use "$intermediate_data/treatment_indicators.dta", clear 

gen region="Caribe" if departamento=="ATLANTICO"
replace region="Caribe" if departamento=="BOLIVAR"
replace region="Caribe" if departamento=="CESAR"
replace region="Caribe" if departamento=="CORDOBA"
replace region="Caribe" if departamento=="LA GUAJIRA"
replace region="Caribe" if departamento=="MAGDALENA"
replace region="Caribe" if departamento=="SAN ANDRES"
replace region="Caribe" if departamento=="SUCRE"


replace region="Centro Oriente" if departamento=="BOGOTA D.C."
replace region="Centro Oriente" if departamento=="BOYACA"
replace region="Centro Oriente" if departamento=="CUNDINAMARCA"
replace region="Centro Oriente" if departamento=="NORTE DE SANTANDER"
replace region="Centro Oriente" if departamento=="SANTANDER"

replace region="Centro Sur" if departamento=="AMAZONAS"
replace region="Centro Sur" if departamento=="CAQUETA"
replace region="Centro Sur" if departamento=="HUILA"
replace region="Centro Sur" if departamento=="PUTUMAYO"
replace region="Centro Sur" if departamento=="TOLIMA"


replace region="Eje Cafetero" if departamento=="ANTIOQUIA"
replace region="Eje Cafetero" if departamento=="CALDAS"
replace region="Eje Cafetero" if departamento=="QUINDIO"
replace region="Eje Cafetero" if departamento=="RISARALDA"

replace region="Llano" if departamento=="ARAUCA"
replace region="Llano" if departamento=="CASANARE"
replace region="Llano" if departamento=="GUAINIA"
replace region="Llano" if departamento=="GUAVIARE"
replace region="Llano" if departamento=="META"
replace region="Llano" if departamento=="VAUPES"
replace region="Llano" if departamento=="VICHADA"

replace region="Pacifico" if departamento=="CAUCA"
replace region="Pacifico" if departamento=="CHOCO"
replace region="Pacifico" if departamento=="NARIÑO"
replace region="Pacifico" if departamento=="VALLE"

tab region, gen(rr)
keep ID region rr*

save "$intermediate_data/region_indicators.dta", replace

