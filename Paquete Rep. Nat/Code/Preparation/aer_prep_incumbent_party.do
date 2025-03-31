/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Natalia Garbiras and Mateo Montenegro
Purpose:       This code prepares the indicators for whether a candidates' party was incumbent
			   using the strict and loose definitions described in the paper.
----------------------------------------------------------------------------------------------------
Index:		   A. Generating Strict Incumbent Party Indicators
      		   B. Generating Loose Incumbent Party Indicators
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
                                A. Generating Strict Incumbent Party Indicators
===============================================================================================*/

* 1. Preparing 2015 Winners:
* ----------------------------------------------------------------------------------------------

import delim "$raw_data/RESULTADOS_ELECTORALES_2015_ALCALDIA.csv", clear encoding("utf-8")

ren desc_depto departamento
ren desc_mpio municipio
 
* Keeping only candidates:
drop if  desc_partido=="VOTOS NULOS"  | desc_partido=="VOTOS NO MARCADOS" | desc_partido=="VOTOS EN BLANCO" 

* A few municipalities missing but they are not part of the experiment:
merge n:1 departamento municipio using `codigos'

keep if _m==3
drop _m

gen party = strtrim(desc_partido)

collapse (sum) votos, by(ID reg_code party)

bys ID: egen max_vote=max(votos)
bys ID: gen winner=(votos==max_vote)

keep if winner==1

keep ID reg_code party

tempfile winners2015
save `winners2015', replace

* 2. Preparing 2019 candidate data:
* ----------------------------------------------------------------------------------------------

import delim "$raw_data/RESULTADOS_ELECTORALES_2019_ALCALDIA.csv", clear  delimiter(";", asstring) varnames(1)

ren depnombre departamento
ren munnombre municipio

* Keeping only candidates:
drop if  parnombre=="VOTOS NULOS"  | parnombre=="VOTOS NO MARCADOS" | parnombre=="VOTOS EN BLANCO" 


gen reg_code=string(dep, "%02.0f")+string(mun, "%003.0f")
	
	
merge n:1 reg_code using `codigos'

keep if _m==3
drop _m

gen party = strtrim(parnombre)


gen one=1
collapse one, by(ID reg_code party can)

drop one

* 3. Coding strict incumbents from merge
* ----------------------------------------

merge 1:1 ID party using `winners2015'

gen incumbent = (_merge ==3)


/*===============================================================================================
                                B. Generating Loose Incumbent Party Indicators
===============================================================================================*/

destring reg_code, replace

*------------------------------------2.1: Replace coalitions ------------------------------------

clonevar incumbent_loose = incumbent

* Hand-coding each loosely-defined candidate from incumbent party:

replace incumbent_loose=1 if reg_code == 1022 & (party == "PARTIDO CONSERVADOR COLOMBIANO"| party == "COALICIÓN CREEMOS EN ANGELÓPOLIS")
replace incumbent_loose=1 if reg_code == 1052 & (party == "COALICIÓN BETANIA SIGUE AVANZANDO"| party == "COALICIÓN COMPROMISO POR BETANIA")
replace incumbent_loose=1 if reg_code == 1080 & (party == "PARTIDO ALIANZA VERDE"| party == "COALICIÓN ALCALDÍA DE CAREPA")
replace incumbent_loose=1 if reg_code == 1163 & (party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"| party == "COALICIÓN LA CEJA NOS UNE"| party == "COALICIÓN HAGAMOS LO CORRECTO POR LA CEJA")
replace incumbent_loose=1 if reg_code == 1168 & (party == "PARTIDO CAMBIO RADICAL"| party == "PARTIDO LIBERAL COLOMBIANO")
replace incumbent_loose=1 if reg_code == 1265 & (party == "PARTIDO LIBERAL COLOMBIANO"| party == "COALICIÓN UNIDOS POR EL PROGRESO DE SOPETRÁN")
replace incumbent_loose=1 if reg_code == 1271 & (party == "COALICIÓN PARTIDO CONSERVADOR- CENTRO DEMOCRÁTICO- PARTIDO DE LA U"| party == "COAL.TARSO, BIENESTAR Y PROGRESO PARA TODOS")
replace incumbent_loose=1 if reg_code == 1283 & (party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"| party == "PARTIDO LIBERAL COLOMBIANO")
replace incumbent_loose=1 if reg_code == 1292 & (party == "COALICIÓN COMPROMISO SOCIAL POR VENECIA"| party == "COALICIÓN CON AMOR POR VENECIA")
replace incumbent_loose=1 if reg_code == 5018 & (party == "COALICIÓN UNIDOS POR LA CLEMENCIA  QUE QUEREMOS"| party == "PARTIDO CAMBIO RADICAL")
replace incumbent_loose=1 if reg_code == 7121 & (party == "COAL.JENESANO UN PROPÓSITO DE TODOS"| party == "COALICIÓN UNA MISIÓN DE TODOS")
replace incumbent_loose=1 if reg_code == 7166 & (party == "COALICIÓN COMPROMISO NOBLE POR TRABAJO Y BIENESTAR PARA TODOS"| party == "COALICIÓN NOBSA UNIDA")
replace incumbent_loose=1 if reg_code == 7202 & (party == "COALICIÓN UNIDOS POR EL DESARROLLO DE PESCA"| party == "COALICIÓN UNIDOS CONSTRUYAMOS EL DESARROLLO DE PESCA")
replace incumbent_loose=1 if reg_code == 7214 & (party == "COALICIÓN PUERTO BOYACÁ PRIMERO"| party == "COALICIÓN LA VOZ DE UN PUEBLO")
replace incumbent_loose=1 if reg_code == 7226 & (party == "PARTIDO ALIANZA VERDE"| party == "COALICIÓN SABOYÁ SOMOS TODOS")
replace incumbent_loose=1 if reg_code == 7250 & (party == "PARTIDO CAMBIO RADICAL"| party == "COALICIÓN UNIDOS DE VERDAD")
replace incumbent_loose=1 if reg_code == 7304 & (party == "COALICIÓN ALCALDÍA TIBANÁ"| party == "COALICIÓN POR AMOR A TIBANÁ")
replace incumbent_loose=1 if reg_code == 7307 & (party == "PARTIDO CAMBIO RADICAL"| party == "COALICIÓN PARTIDO CONSERVADOR- PARTIDO DE LA U- PARTIDO LIBERAL")
replace incumbent_loose=1 if reg_code == 7313 & (party == "COALICIÓN AVANCEMOS JUNTOS POR TOCA"| party == "COALICIÓN EN EQUIPO HACEMOS MÁS")
replace incumbent_loose=1 if reg_code == 7328 & (party == "COALICIÓN TUTA COMPROMISO DE TODOS"| party == "COALICIÓN TUTA SIGUE ADELANTE")
replace incumbent_loose=1 if reg_code == 7337 & (party == "PARTIDO ALIANZA VERDE"| party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U")
replace incumbent_loose=1 if reg_code == 15004 & (party == "COALICIÓN AGUA DE DIOS CON DESARROLLO UN SUEÑO POSIBLE"| party == "COALICIÓN GRAN ALIANZA POR AGUA DE DIOS CON OPORTUNIDADES PARA TODOS"| party == "PARTIDO CAMBIO RADICAL")
replace incumbent_loose=1 if reg_code == 15031 & (party == "COALICIÓN CAJICÁ TRANSPARENTE"| party == "COALICIÓN CAJICÁ ES EL MOMENTO")
replace incumbent_loose=1 if reg_code == 15043 & (party == "COALICIÓN SENTIDO POR LO NUESTRO"| party == "COALICIÓN PARTIDO DE LA U- MOVIMIENTO AICO")
replace incumbent_loose=1 if reg_code == 15058 & (party == "COAL.HAGAMOS DE CHIPAQUE EL MEJOR"| party == "COALICIÓN PARTIDO CONSERVADOR- PARTIDO ASI- CENTRO DEMOCRÁTICO")
replace incumbent_loose=1 if reg_code == 15061 & (party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"| party == "COALICIÓN LA GENTE PRIMERO")
replace incumbent_loose=1 if reg_code == 15115 & (party == "PARTIDO LIBERAL COLOMBIANO"| party == "PARTIDO CONSERVADOR COLOMBIANO")
replace incumbent_loose=1 if reg_code == 15132 & (party == "COALICIÓN PARTIDO CONSERVADOR COL.- PARTIDO CAMBIO RADICAL-PARTIDO ASI"| party == "COAL.GRANADA CON PROYECCIÓN, GESTIÓN Y EXPERIENCIA")
replace incumbent_loose=1 if reg_code == 15151 & (party == "COAL.LA VEGA PARA SEGUIR AVANZANDO"| party == "COAL.EL FUTURO DEL CAMPO ES EL DESARROLLO DE MI PUEBLO"| party == "COAL.HONESTIDAD Y EXPERIENCIA MEJORAMOS LA VEGA")
replace incumbent_loose=1 if reg_code == 15169 & (party == "COAL.JUNTOS HACIA EL FUTURO DE MOSQUERA"| party == "COALICIÓN ALTERNATIVA POR MOSQUERA")
replace incumbent_loose=1 if reg_code == 15175 & (party == "COAL.POR LA ALCALDÍA DE NEMOCÓN"| party == "COAL.NEMOCÓN UN PROYECTO CON IDEAS")
replace incumbent_loose=1 if reg_code == 15178 & (party == "COALICIÓN AVANCEMOS JUNTOS POR NILO"| party == "COALICIÓN  UNIDOS POR NILO CON EQUIDAD")
replace incumbent_loose=1 if reg_code == 15199 & (party == "PARTIDO LIBERAL COLOMBIANO"| party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"| party == "COAL.LABRAMOS JUNTOS, COSECHAMOS TODOS")
replace incumbent_loose=1 if reg_code == 15217 & (party == "COALICIÓN JUNTOS VAMOS A LOGRARLO POR APULO"| party == "COALICIÓN LEALES CON APULO")
replace incumbent_loose=1 if reg_code == 15218 & (party == "COAL.RICAURTE CON EQUIDAD, SEGURIDAD Y COMPROMISO SOCIAL"| party == "MOVIMIENTO ALTERNATIVO INDÍGENA Y SOCIAL")
replace incumbent_loose=1 if reg_code == 15229 & (party == "COALICIÓN SAN FRANCISCO"| party == "PARTIDO ALIANZA VERDE")
replace incumbent_loose=1 if reg_code == 15238 & (party == "COALICIÓN PARTIDO  CONSERVADOR - PARTIDO ALIANZA VERDE - PARTIDO LIBERAL"| party == "COALICIÓN GESTIÓN Y APOYO TODOS POR UN MEJOR FUTURO")
replace incumbent_loose=1 if reg_code == 15241 & (party == "COALICIÓN UNIDOS SOMOS MÁS"| party == "COALICIÓN COMPROMISO SOCIAL")
replace incumbent_loose=1 if reg_code == 15250 & (party == "COALICIÓN SOPÓ"| party == "COALICIÓN YO SOY SOPÓ")
replace incumbent_loose=1 if reg_code == 15259 & (party == "COALICIÓN SUESCA SOMOS TODOS"| party == "PARTIDO LIBERAL COLOMBIANO")
replace incumbent_loose=1 if reg_code == 15277 & (party == "COALICIÓN TENA EN LAS MEJORES MANOS"| party == "COALICIÓN TENA RESPONSABILIDAD DE TODOS")
replace incumbent_loose=1 if reg_code == 15340 & (party == "COALICIÓN PARTIDO ALIANZA VERDE"| party == "PARTIDO CONSERVADOR COLOMBIANO")
replace incumbent_loose=1 if reg_code == 17001 & (party == "COALICIÓN PARTIDO CONSERVADOR- PARTIDO LIBERAL- PART.ALIANZA VERDE"| party == "COALICIÓN POR QUIBDÓ")
replace incumbent_loose=1 if reg_code == 17034 & (party == "PARTIDO LIBERAL COLOMBIANO"| party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U")
replace incumbent_loose=1 if reg_code == 17043 & (party == "COALICIÓN POR TADÓ ME LA JUEGO TODA"| party == "MOVIMIENTO ALTERNATIVO INDÍGENA Y SOCIAL")
replace incumbent_loose=1 if reg_code == 19004 & (party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO ALIANZA VERDE"| party == "PARTIDO CENTRO DEMOCRÁTICO")
replace incumbent_loose=1 if reg_code == 19022 & (party == "COALICIÓN RENOVACIÓN"| party == "PARTIDO CAMBIO RADICAL")
replace incumbent_loose=1 if reg_code == 19061 & (party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO DE LA U - PARTIDO ASI"| party == "MOVIMIENTO ALTERNATIVO INDÍGENA Y SOCIAL")
replace incumbent_loose=1 if reg_code == 19064 & (party == "COALICIÓN RIVERA PARA TODOS"| party == "COALICIÓN RIVERA SII")
replace incumbent_loose=1 if reg_code == 19067 & (party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"| party == "COALICIÓN UNIDOS SOMOS MÁS")
replace incumbent_loose=1 if reg_code == 23073 & (party == "COALICIÓN UNA MINGA PARA EL PROGRESO DE TODOS"| party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI")
replace incumbent_loose=1 if reg_code == 23080 & (party == "PARTIDO CONSERVADOR COLOMBIANO"| party == "PARTIDO ALIANZA VERDE")
replace incumbent_loose=1 if reg_code == 24008 & (party == "PARTIDO LIBERAL COLOMBIANO"| party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U")
replace incumbent_loose=1 if reg_code == 24078 & (party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"| party == "PARTIDO LIBERAL COLOMBIANO")
replace incumbent_loose=1 if reg_code == 25007 & (party == "PARTIDO CENTRO DEMOCRÁTICO"| party == "COALICIÓN PARTIDO CONSERVADOR- CAMBIO RADICAL- PARTIDO DE LA U")
replace incumbent_loose=1 if reg_code == 25054 & (party == "COALICIÓN LOS PATIOS AVANZA CON EL CAMBIO"| party == "COALICIÓN MEJOR PARA TODOS")
replace incumbent_loose=1 if reg_code == 25076 & (party == "PARTIDO ALIANZA VERDE"| party == "PARTIDO COLOMBIA HUMANA - UNIÓN PATRIÓTICA")
replace incumbent_loose=1 if reg_code == 26060 & (party == "PARTIDO CAMBIO RADICAL"| party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U")
replace incumbent_loose=1 if reg_code == 27074 & (party == "PARTIDO CONSERVADOR COLOMBIANO"| party == "COAL.AL PLAYÓN LE PONEMOS CORAZÓN")
replace incumbent_loose=1 if reg_code == 27130 & (party == "COALICIÓN PARTIDO DE LA U- LIBERAL- ADA- MOVIMIENTO AICO"| party == "COALICIÓN PARTIDO CONSERVADOR- CENTRO DEMOCRÁT.- CAMBIO RADICAL-ASI")
replace incumbent_loose=1 if reg_code == 29034 & (party == "PARTIDO LIBERAL COLOMBIANO"| party == "COALICIÓN COYAIMA")
replace incumbent_loose=1 if reg_code == 29061 & (party == "PARTIDO CONSERVADOR COLOMBIANO"| party == "PARTIDO CENTRO DEMOCRÁTICO")
replace incumbent_loose=1 if reg_code == 29073 & (party == "PARTIDO CAMBIO RADICAL"| party == "PARTIDO LIBERAL COLOMBIANO")
replace incumbent_loose=1 if reg_code == 29097 & (party == ""| party == "")
replace incumbent_loose=1 if reg_code == 29103 & (party == "PARTIDO CONSERVADOR COLOMBIANO"| party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"| party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI")
replace incumbent_loose=1 if reg_code == 31022 & (party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"| party == "COALICIÓN PARA LLEGAR MÁS LEJOS")
replace incumbent_loose=1 if reg_code == 31031 & (party == "COALICIÓN ADHESIÓN"| party == "PARTIDO CAMBIO RADICAL")
replace incumbent_loose=1 if reg_code == 31097 & (party == "PARTIDO LIBERAL COLOMBIANO"| party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U")
replace incumbent_loose=1 if reg_code == 40010 & (party == "COALICIÓN UNIDOS DE CORAZÓN"| party == "PARTIDO CONSERVADOR COLOMBIANO"| party == "COALICIÓN EL GOBIERNO DE LA GENTE")
replace incumbent_loose=1 if reg_code == 44007 & (party == "PARTIDO CONSERVADOR COLOMBIANO"| party == "COALICIÓN LA MONTAÑITA PARA TODOS")
replace incumbent_loose=1 if reg_code == 44009 & (party == "PARTIDO ALIANZA VERDE"| party == "COAL.PARA QUE VUELVA EL PROGRESO")
replace incumbent_loose=1 if reg_code == 72008 & (party == "COALICIÓN SOLUCIONES PARA LA PRIMAVERA"| party == "COALICIÓN MI COMPROMISO ES PRIMAVERA")
replace incumbent_loose=1 if reg_code == 1004 & party == "COALICIÓN JUNTOS POR EL PROGRESO"
replace incumbent_loose=1 if reg_code == 1013 & party == "COALICIÓN AMAGÁ"
replace incumbent_loose=1 if reg_code == 1019 & party == "COALICIÓN ANDES, ALIANZA POR EL DESARROLLO HUMANO"
replace incumbent_loose=1 if reg_code == 1037 & party == "COALICIÓN ARBOLETES ASUNTO DE TODOS"
replace incumbent_loose=1 if reg_code == 1043 & party == "COALICIÓN BARBOSA SOCIAL PARA VOLVER A CREER."
replace incumbent_loose=1 if reg_code == 1055 & party == "COALICIÓN PASIÓN POR BETULIA"
replace incumbent_loose=1 if reg_code == 1062 & party == "COALICIÓN MOVILIZANDO IDEAS POR UN TERRITORIO SOSTENIBLE"
replace incumbent_loose=1 if reg_code == 1067 & party == "COALICIÓN CAICEDO PARA TODOS"
replace incumbent_loose=1 if reg_code == 1073 & party == "COALICIÓN CAMPAMENTO PRÓSPERO, SOSTENIBLE E INCLUYENTE"
replace incumbent_loose=1 if reg_code == 1103 & party == "COALICIÓN PARTIDO DE LA U-PARTIDO CAMBIO RADICAL-PARTIDO ALIANZA VERDE"
replace incumbent_loose=1 if reg_code == 1106 & party == "COALICIÓN TODOS POR CHIGORODÓ"
replace incumbent_loose=1 if reg_code == 1112 & party == "COALICIÓN ALCALDÍA DONMATÍAS"
replace incumbent_loose=1 if reg_code == 1115 & party == "COALICIÓN RETOMANDO EL RUMBO"
replace incumbent_loose=1 if reg_code == 1118 & party == "PARTIDO CONSERVADOR COLOMBIANO"
replace incumbent_loose=1 if reg_code == 1124 & party == "COALICIÓN FREDONIA PARA TODOS"
replace incumbent_loose=1 if reg_code == 1127 & party == "COALICIÓN PARTIDO CONSERVADOR COL.- PARTIDO CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 1139 & party == "COALICIÓN PARTIDO CONSERVADOR COL.- PARTIDO CENTRO DEMOCRÁTICO"
replace incumbent_loose=1 if reg_code == 1142 & party == "PARTIDO CONSERVADOR COLOMBIANO"
replace incumbent_loose=1 if reg_code == 1160 & party == "COAL.P.CONSERVADOR-P.CAMBIO RADICAL P.ASI-MAIS"
replace incumbent_loose=1 if reg_code == 1166 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 1178 & party == "COALICIÓN JUNTOS POR MARINILLA"
replace incumbent_loose=1 if reg_code == 1187 & party == "COALICIÓN TODOS UNIDOS POR MUTATÁ"
replace incumbent_loose=1 if reg_code == 1196 & party == "COALICIÓN AVANZA PEÑOL"
replace incumbent_loose=1 if reg_code == 1214 & party == "COALICIÓN UNIDOS POR RIONEGRO"
replace incumbent_loose=1 if reg_code == 1229 & party == "COALICIÓN SIGAMOS CRECIENDO"
replace incumbent_loose=1 if reg_code == 1231 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 1237 & party == "COALICIÓN EN TODO TIEMPO CON LA COMUNIDAD"
replace incumbent_loose=1 if reg_code == 1241 & party == "COALICIÓN PARTIDO CONSERVADOR- PARTIDO LIBERAL COL.-PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 1247 & party == "COALICIÓN CONSTRUYAMOS FUTURO"
replace incumbent_loose=1 if reg_code == 1250 & party == "MOVIMIENTO ALTERNATIVO INDÍGENA Y SOCIAL"
replace incumbent_loose=1 if reg_code == 1253 & party == "COALICIÓN EL CAMBIO ES MARIO"
replace incumbent_loose=1 if reg_code == 1256 & party == "COALICIÓN EL SANTUARIO RUMBO CLARO"
replace incumbent_loose=1 if reg_code == 1274 & party == "COALICIÓN ¡TITIRIBÍ ES DE TODOS AVANCEMOS!"
replace incumbent_loose=1 if reg_code == 1290 & party == "COALICIÓN UNA PROPUESTA CLARA UN GOBIERNO PARA TODOS"
replace incumbent_loose=1 if reg_code == 1293 & party == "COALICIÓN MÁS OPORTUNIDADES PARA TODOS"
replace incumbent_loose=1 if reg_code == 1301 & party == "C.P.CONSERVADOR-P.CENTRO DEMOCRÁTICO P.CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 3004 & party == "COALICIÓN JUNTOS POR BARANOA"
replace incumbent_loose=1 if reg_code == 3013 & party == "COALICIÓN GALAPA A OTRO NIVEL"
replace incumbent_loose=1 if reg_code == 3028 & party == "COALICIÓN DESARROLLO SOCIAL CON SENTIDO HUMANO"
replace incumbent_loose=1 if reg_code == 3035 & party == "COALICIÓN MÁS ESPERANZA, MEJOR FUTURO"
replace incumbent_loose=1 if reg_code == 3046 & party == "COALICIÓN ESTOY CON SABANALARGA PLAN DE TODOS"
replace incumbent_loose=1 if reg_code == 3049 & party == "COALICIÓN UNA MUJER DE CONFIANZA"
replace incumbent_loose=1 if reg_code == 3055 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 5006 & party == "PARTIDO CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 5040 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 5043 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 5113 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 5121 & party == "PARTIDO CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 7008 & party == "COALICIÓN PARTIDO CONSERVADOR- PARTIDO ASI"
replace incumbent_loose=1 if reg_code == 7049 & party == "COALICIÓN LA INCLUSIÓN NUESTRO COMPROMISO"
replace incumbent_loose=1 if reg_code == 7067 & party == "COALICIÓN SÍ ES POSIBLE"
replace incumbent_loose=1 if reg_code == 7100 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 7106 & party == "COALICIÓN PACTO POR GUATEQUE"
replace incumbent_loose=1 if reg_code == 7139 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 7151 & party == "COALICIÓN ALCALDÍA MIRAFLORES BOYACÁ"
replace incumbent_loose=1 if reg_code == 7160 & party == "COALICIÓN PARTIDO DE LA U- PARTIDO LIBERAL COLOMBIANO"
replace incumbent_loose=1 if reg_code == 7163 & party == "C.P.CONSERVADOR C.-P.LIBERAL C.- P.DE LA U-P.CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 7176 & party == "COALICIÓN YO CREO EN OTANCHE"
replace incumbent_loose=1 if reg_code == 7181 & party == "COAL.EN PAIPA SOLO FALTA SUMERCÉ"
replace incumbent_loose=1 if reg_code == 7235 & party == "COALICIÓN SEGUIMOS COMPROMETIDOS CON SAMACÁ"
replace incumbent_loose=1 if reg_code == 7249 & party == "COALICIÓN PART. CONSERVADOR - CENTRO DEMOCRÁTICO - DE LA U - CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 7253 & party == "COALICIÓN AVANCEMOS POR SANTA ROSA DE VITERBO"
replace incumbent_loose=1 if reg_code == 7265 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO ASI"
replace incumbent_loose=1 if reg_code == 7271 & party == "COALICIÓN PROGRESAMOS CON EXPERIENCIA Y COMPROMISO SOCIAL"
replace incumbent_loose=1 if reg_code == 7277 & party == "COALICIÓN ESCRIBAMOS EL FUTURO DE SOGAMOSO"
replace incumbent_loose=1 if reg_code == 7334 & party == "COALICIÓN PARTIDO CONSERVADOR- CAMBIO RADICAL- CENTRO DEMOCRÁTICO"
replace incumbent_loose=1 if reg_code == 9004 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 9013 & party == "COALICIÓN UNIDOS POR ARANZAZU"
replace incumbent_loose=1 if reg_code == 9022 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 9034 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 9037 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 9049 & party == "COALICIÓN GRAN CONSENSO POR LA DORADA"
replace incumbent_loose=1 if reg_code == 9055 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 9058 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 9076 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 9079 & party == "COALICIÓN LA FUERZA DEL CAMBIO"
replace incumbent_loose=1 if reg_code == 9082 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 9103 & party == "MOVIMIENTO ALTERNATIVO INDÍGENA Y SOCIAL"
replace incumbent_loose=1 if reg_code == 9106 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 9109 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 9130 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 11004 & party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"
replace incumbent_loose=1 if reg_code == 11005 & party == "MOVIMIENTO AUTORIDADES INDÍGENAS DE COLOMBIA AICO"
replace incumbent_loose=1 if reg_code == 11007 & party == "PARTIDO LIBERAL COLOMBIANO"
replace incumbent_loose=1 if reg_code == 11019 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO LIBERAL COLOMBIANO"
replace incumbent_loose=1 if reg_code == 11022 & party == "COALICIÓN LA UNIÓN ES LA FUERZA"
replace incumbent_loose=1 if reg_code == 11028 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 11031 & party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"
replace incumbent_loose=1 if reg_code == 11034 & party == "MOVIMIENTO ALTERNATIVO INDÍGENA Y SOCIAL"
replace incumbent_loose=1 if reg_code == 11040 & party == "COALICIÓN GOBERNAR PARA SERVIR"
replace incumbent_loose=1 if reg_code == 11049 & party == "COALICIÓN SÍ PODEMOS"
replace incumbent_loose=1 if reg_code == 11052 & party == "PARTIDO LIBERAL COLOMBIANO"
replace incumbent_loose=1 if reg_code == 11053 & party == "COALICIÓN PARA SEGUIR AVANZANDO"
replace incumbent_loose=1 if reg_code == 11058 & party == "COALICIÓN PATIANOS ES AHORA"
replace incumbent_loose=1 if reg_code == 11064 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 11070 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 11076 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 11079 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 11082 & party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"
replace incumbent_loose=1 if reg_code == 11094 & party == "MOVIMIENTO ALTERNATIVO INDÍGENA Y SOCIAL"
replace incumbent_loose=1 if reg_code == 11097 & party == "COALICIÓN PACTO POR TOTORÓ"
replace incumbent_loose=1 if reg_code == 12200 & party == "COAL.ALIANZA DE UNIDAD POR BOSCONIA"
replace incumbent_loose=1 if reg_code == 12375 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 12608 & party == "COALICIÓN RECONCILIACIÓN Y UNIDAD JAGUERA"
replace incumbent_loose=1 if reg_code == 12700 & party == "COALICIÓN PARTIDO CONSERVADOR COL.- PARTIDO ASI-PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 12720 & party == "COALICIÓN PARTIDO CONSERVADOR- DE LA U- CAMBIO RADICAL-LIBERAL COL."
replace incumbent_loose=1 if reg_code == 12800 & party == "COALICIÓN ALIANZA POR TI SAN ALBERTO"
replace incumbent_loose=1 if reg_code == 12850 & party == "COALICIÓN SAN DIEGO TERRITORIO DE LO POSIBLE"
replace incumbent_loose=1 if reg_code == 12875 & party == "COALICIÓN ALCALDÍA DE SAN MARTÍN"
replace incumbent_loose=1 if reg_code == 12900 & party == "COALICIÓN TAMALAMEQUE AVANZA"
replace incumbent_loose=1 if reg_code == 13004 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 13009 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 13022 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 13024 & party == "COALICIÓN YO AMO A MOMIL"
replace incumbent_loose=1 if reg_code == 13028 & party == "COALICIÓN PARTIDO CONSERVADOR - PARTIDO CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 13037 & party == "COALICIÓN MI COMPROMISO ES CON SAHAGÚN"
replace incumbent_loose=1 if reg_code == 13040 & party == "MOVIMIENTO AUTORIDADES INDÍGENAS DE COLOMBIA AICO"
replace incumbent_loose=1 if reg_code == 13043 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 13046 & party == "COALICIÓN CON DIOS SOMOS MÁS  QUE VENCEDORES"
replace incumbent_loose=1 if reg_code == 13052 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 13055 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 13058 & party == "COALICIÓN TIERRALTA SÍ SE PUEDE"
replace incumbent_loose=1 if reg_code == 13061 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 15010 & party == "COALICIÓNPARTIDO LIBERAL- PARTIDO DE LA U- PARTIDO CONSERVADOR"
replace incumbent_loose=1 if reg_code == 15013 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 15016 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- MOVIMIENTO AICO"
replace incumbent_loose=1 if reg_code == 15025 & party == "COAL.EN BOJACÁ SEGUIMOS CREYENDO"
replace incumbent_loose=1 if reg_code == 15072 & party == "COALICIÓN EL ROSAL PARA VIVIR MEJOR"
replace incumbent_loose=1 if reg_code == 15079 & party == "COALICIÓN PARTIDO DE LA U- MOVIMIENTO MAIS"
replace incumbent_loose=1 if reg_code == 15100 & party == "COALICIÓN ALCALDÍA DE GACHANCIPÁ"
replace incumbent_loose=1 if reg_code == 15103 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- MOVIMIENTO AICO"
replace incumbent_loose=1 if reg_code == 15109 & party == "COALICIÓN JUNTOS PODEMOS"
replace incumbent_loose=1 if reg_code == 15112 & party == "COAL.UNIDOS POR EL DESARROLLO DE GUACHETÁ"
replace incumbent_loose=1 if reg_code == 15154 & party == "COALICIÓN PARTIDO CONSERVADOR- CENTRO DEMOCRÁTICO- LIBERAL"
replace incumbent_loose=1 if reg_code == 15160 & party == "COALICIÓN MADRID !JUNTOS CRECEMOS!"
replace incumbent_loose=1 if reg_code == 15184 & party == "COALICIÓN PARTIDO CONSERVADOR- CAMBIO RADICAL - PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 15211 & party == "COALICIÓN SEGUIMOS CRECIENDO"
replace incumbent_loose=1 if reg_code == 15214 & party == "COALICIÓN PARTIDO CONSERVADOR- CENTRO DEMOCRÁT.-LIBERAL-CAMBIO RAD."
replace incumbent_loose=1 if reg_code == 15220 & party == "COAL.SAN ANTONIO MISIÓN DE TODOS"
replace incumbent_loose=1 if reg_code == 15223 & party == "COALICIÓN SAN BERNARDO NOS UNE"
replace incumbent_loose=1 if reg_code == 15235 & party == "COALICIÓN PARTIDO CONSERVADOR- PARTIDO DE LA U-PARTIDO LIBERAL"
replace incumbent_loose=1 if reg_code == 15239 & party == "COALICIÓN EN CAMINO AL DESARROLLO"
replace incumbent_loose=1 if reg_code == 15244 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 15256 & party == "COALICIÓN PART.CONSERVADOR- LIBERAL CAMBIO RADICAL-DE LA U-ALIANZA VERDE"
replace incumbent_loose=1 if reg_code == 15274 & party == "COALICIÓN TAUSA...  ¡TRANSFORMACIÓN EN MARCHA!"
replace incumbent_loose=1 if reg_code == 15289 & party == "COALICIÓN FUTURO EN MARCHA"
replace incumbent_loose=1 if reg_code == 15304 & party == "COALICIÓN POR UNA NUEVA UBATÉ"
replace incumbent_loose=1 if reg_code == 15307 & party == "COALICIÓN NUESTRO COMPROMISO ES UNE"
replace incumbent_loose=1 if reg_code == 15319 & party == "COALICIÓN PARTIDO CONSERVADOR - CENTRO DEMOCRÁTICO- PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 15325 & party == "COALICIÓN VILLAPINZÓN PRIMERO LO NUESTRO"
replace incumbent_loose=1 if reg_code == 15328 & party == "COALICIÓN FIRMANDO POR VILLETA- PARTIDO CONSERVADOR COLOMBIANO"
replace incumbent_loose=1 if reg_code == 15331 & party == "PARTIDO CENTRO DEMOCRÁTICO"
replace incumbent_loose=1 if reg_code == 15334 & party == "COAL.EN ACCIÓN RENOVADORA POR YACOPÍ"
replace incumbent_loose=1 if reg_code == 17008 & party == "COALICIÓN CON LA FUERZA DE LA GENTE HACEMOS MÁS"
replace incumbent_loose=1 if reg_code == 17017 & party == "COALICIÓN PROSPERIDAD PARA MI GENTE"
replace incumbent_loose=1 if reg_code == 19013 & party == "COALICIÓN ALCALDÍA ALGECIRAS HUILA"
replace incumbent_loose=1 if reg_code == 19025 & party == "COALICIÓN VAMOS TODOS"
replace incumbent_loose=1 if reg_code == 19049 & party == "COAL.EXPERIENCIA GESTIÓN Y RESULTADOS"
replace incumbent_loose=1 if reg_code == 19051 & party == "COALICIÓN AMOR POR OPORAPA"
replace incumbent_loose=1 if reg_code == 19070 & party == "COALICIÓN PARTIDO DE LA U- MOVIMIENTO MAIS"
replace incumbent_loose=1 if reg_code == 19076 & party == "COALICIÓN PARTIDO DE LA U-PARTIDO CENTRO DEMOCRÁTICO"
replace incumbent_loose=1 if reg_code == 19079 & party == "COALICIÓN TODOS POR TARQUI"
replace incumbent_loose=1 if reg_code == 19085 & party == "COALICIÓN LIDERAZGO Y GESTIÓN"
replace incumbent_loose=1 if reg_code == 19094 & party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"
replace incumbent_loose=1 if reg_code == 21025 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 21052 & party == "COALICIÓN LA LLAVE ERES TÚ"
replace incumbent_loose=1 if reg_code == 21070 & party == "COALICIÓN TODOS UNIDOS POR SAN SEBASTIÁN DE BUENAVISTA"
replace incumbent_loose=1 if reg_code == 21076 & party == "COALICIÓN CONTIGO SANTA ANA AVANZA"
replace incumbent_loose=1 if reg_code == 21079 & party == "COALICIÓN UNIDOS POR SITIO NUEVO"
replace incumbent_loose=1 if reg_code == 23016 & party == "COALICIÓN MOVIMIENTO ALTERNATIVO SOCIAL MÁS"
replace incumbent_loose=1 if reg_code == 23019 & party == "COAL.PACTO CON EL PUEBLO Y CON EL CAMPO"
replace incumbent_loose=1 if reg_code == 23022 & party == "COALICIÓN GESTIÓN Y DESARROLLO POR COLÓN"
replace incumbent_loose=1 if reg_code == 23039 & party == "COALICIÓN CUMBITARA SOMOS TODOS"
replace incumbent_loose=1 if reg_code == 23041 & party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"
replace incumbent_loose=1 if reg_code == 23079 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO LIBERAL COLOMBIANO"
replace incumbent_loose=1 if reg_code == 23085 & party == "PARTIDO CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 23097 & party == "COAL.VOLVEMOS PARA SEGUIR CUMPLIENDO"
replace incumbent_loose=1 if reg_code == 23112 & party == "COALICIÓN PENSAMOS DIFERENTE"
replace incumbent_loose=1 if reg_code == 23115 & party == "COALICIÓN PARTIDO CONSERVADOR COL.- PARTIDO LIBERAL COL.-PARTIDO ASI"
replace incumbent_loose=1 if reg_code == 23121 & party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"
replace incumbent_loose=1 if reg_code == 23124 & party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"
replace incumbent_loose=1 if reg_code == 23127 & party == "MOVIMIENTO AUTORIDADES INDÍGENAS DE COLOMBIA AICO"
replace incumbent_loose=1 if reg_code == 23136 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 24062 & party == "MOVIMIENTO ALTERNATIVO INDÍGENA Y SOCIAL"
replace incumbent_loose=1 if reg_code == 24086 & party == "PARTIDO CONSERVADOR COLOMBIANO"
replace incumbent_loose=1 if reg_code == 25004 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 25019 & party == "PARTIDO CONSERVADOR COLOMBIANO"
replace incumbent_loose=1 if reg_code == 25028 & party == "COALICIÓN JUNTOS"
replace incumbent_loose=1 if reg_code == 25031 & party == "COAL.CREANDO MÁS OPORTUNIDADES PARA CHITAGÁ"
replace incumbent_loose=1 if reg_code == 25036 & party == "COALICIÓN POR LA PAZ Y DEMOCRACIA"
replace incumbent_loose=1 if reg_code == 25038 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 25051 & party == "PARTIDO CONSERVADOR COLOMBIANO"
replace incumbent_loose=1 if reg_code == 25061 & party == "COALICIÓN POR LA OCAÑA QUE QUERÉS"
replace incumbent_loose=1 if reg_code == 25064 & party == "COALICIÓN EL FUTURO NOS UNE"
replace incumbent_loose=1 if reg_code == 25085 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO DE LA U-PARTIDO LIBERAL"
replace incumbent_loose=1 if reg_code == 25093 & party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"
replace incumbent_loose=1 if reg_code == 25094 & party == "COALICIÓN TOLEDO NUESTRO COMPROMISO"
replace incumbent_loose=1 if reg_code == 26010 & party == "PARTIDO ALIANZA SOCIAL INDEPENDIENTE ASI"
replace incumbent_loose=1 if reg_code == 26020 & party == "COAL.LLEGÓ EL TIEMPO DE LA GENTE"
replace incumbent_loose=1 if reg_code == 26050 & party == "COALICIÓN PARTIDO DE LA U- LIBERAL- ASI - COLOMBIA JUSTA LIBRES"
replace incumbent_loose=1 if reg_code == 27013 & party == "COALICIÓN RENOVACIÓN"
replace incumbent_loose=1 if reg_code == 27045 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 27055 & party == "COALICIÓN UN COMPROMISO CON LA GENTE"
replace incumbent_loose=1 if reg_code == 27071 & party == "COALICIÓN PACTO POR EL CARMEN"
replace incumbent_loose=1 if reg_code == 27120 & party == "COALICIÓN CONSTRUYENDO EL CAMBIO"
replace incumbent_loose=1 if reg_code == 27121 & party == "COALICIÓN AVANCEMOS JUNTOS"
replace incumbent_loose=1 if reg_code == 27136 & party == "COALICIÓN PARTIDO CONSERVADOR COL.- PARTIDO DE LA U-PARTIDO ASI"
replace incumbent_loose=1 if reg_code == 27145 & party == "COALICIÓN SEMBRANDO DESARROLLO"
replace incumbent_loose=1 if reg_code == 27166 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 27169 & party == "COALICIÓN POR LA ALCALDÍA DE PUERTO WILCHES"
replace incumbent_loose=1 if reg_code == 27175 & party == "COALICIÓN SAN ANDRÉS COMPROMISO DE TODOS"
replace incumbent_loose=1 if reg_code == 27181 & party == "COALICIÓN AUTORIDAD, ORDEN Y SEGURIDAD POR SAN GIL"
replace incumbent_loose=1 if reg_code == 27193 & party == "COALICIÓN SAN VICENTE TIENE FUTURO"
replace incumbent_loose=1 if reg_code == 27202 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 27205 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO LIBERAL COLOMBIANO"
replace incumbent_loose=1 if reg_code == 27223 & party == "COALICIÓN PARTIDO CONSERVADOR- LIBERAL- CENTRO DEMOCRÁTICO- DE LA U"
replace incumbent_loose=1 if reg_code == 28040 & party == "COALICIÓN COROZAL TIENE DOLIENTE"
replace incumbent_loose=1 if reg_code == 28048 & party == "COALICIÓN ALCALDÍA DE GALERAS-SUCRE"
replace incumbent_loose=1 if reg_code == 28050 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 28060 & party == "COALICIÓN MAJAGUAL SUCRE"
replace incumbent_loose=1 if reg_code == 28080 & party == "COALICIÓN ALCALDÍA DE MORROA"
replace incumbent_loose=1 if reg_code == 28120 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO LIBERAL"
replace incumbent_loose=1 if reg_code == 28160 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 28240 & party == "COALICIÓN ALCALDÍA DE SAN PEDRO"
replace incumbent_loose=1 if reg_code == 28260 & party == "COALICIÓN UNIDOS PARA SERVIRLE A LA GENTE"
replace incumbent_loose=1 if reg_code == 29013 & party == "PARTIDO CONSERVADOR COLOMBIANO"
replace incumbent_loose=1 if reg_code == 29016 & party == "COALICIÓN PARA LA ALCALDÍA DE ARMERO GUAYABAL"
replace incumbent_loose=1 if reg_code == 29019 & party == "COAL.NUESTRO COMPROMISO ES ATACO"
replace incumbent_loose=1 if reg_code == 29022 & party == "COALICIÓN TODOS POR CAJAMARCA"
replace incumbent_loose=1 if reg_code == 29031 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 29037 & party == "COALICIÓN TODOS SOMOS CUNDAY PARA SEGUIR CREYENDO"
replace incumbent_loose=1 if reg_code == 29049 & party == "COALICIÓN POR FALAN"
replace incumbent_loose=1 if reg_code == 29052 & party == "COALICIÓN FLANDES AVANZARÁ"
replace incumbent_loose=1 if reg_code == 29055 & party == "COALICIÓN PORQUE TÚ CUENTAS,  SÚMATE"
replace incumbent_loose=1 if reg_code == 29067 & party == "COALICIÓN JUNTOS POR ICONONZO"
replace incumbent_loose=1 if reg_code == 29076 & party == "PARTIDO LIBERAL COLOMBIANO"
replace incumbent_loose=1 if reg_code == 29079 & party == "COALICIÓN ALCALDÍA DE MELGAR"
replace incumbent_loose=1 if reg_code == 29082 & party == "COALICIÓN LO HICIMOS BIEN...POR AMOR A NATAGAIMA LO HAREMOS MEJOR"
replace incumbent_loose=1 if reg_code == 29087 & party == "COAL.PARTIDO CONSERVADOR COL.- PARTIDO DE LA U-PARTIDO ASI"
replace incumbent_loose=1 if reg_code == 29089 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 29091 & party == "COALICIÓN FIRME POR PRADO"
replace incumbent_loose=1 if reg_code == 29094 & party == "COALICIÓN PURIFICACIÓN"
replace incumbent_loose=1 if reg_code == 29105 & party == "PARTIDO CONSERVADOR COLOMBIANO"
replace incumbent_loose=1 if reg_code == 29124 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 31004 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 31016 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 31037 & party == "COALICIÓN APOSTEMOS TODOS A CRECER POR DAGUA"
replace incumbent_loose=1 if reg_code == 31040 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- MOVIMIENTO MAIS-PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 31043 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 31046 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 31055 & party == "COALICIÓN PACTO POR FLORIDA"
replace incumbent_loose=1 if reg_code == 31064 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 31085 & party == "COALICIÓN UNIDOS ASI POR RESTREPO"
replace incumbent_loose=1 if reg_code == 31094 & party == "COALICIÓN FIRMES CON EL FUTURO DE SAN PEDRO"
replace incumbent_loose=1 if reg_code == 31103 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- MOVIMIENTO MAIS"
replace incumbent_loose=1 if reg_code == 31118 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 31124 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 44003 & party == "COALICIÓN UNIDOS POR TI CARTAGENA DEL CHAIRÁ"
replace incumbent_loose=1 if reg_code == 44005 & party == "COALICIÓN EL DONCELLO, LA FUERZA QUE NOS MUEVE"
replace incumbent_loose=1 if reg_code == 44006 & party == "COALICIÓN EL PAUJIL PRIMERO"
replace incumbent_loose=1 if reg_code == 44012 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 44020 & party == "COALICIÓN UNIDOS POR SAN JOSÉ"
replace incumbent_loose=1 if reg_code == 44022 & party == "MOVIMIENTO ALTERNATIVO INDÍGENA Y SOCIAL"
replace incumbent_loose=1 if reg_code == 46560 & party == "COAL.NUNCHÍA SOCIAL Y EMPRENDEDORA"
replace incumbent_loose=1 if reg_code == 46830 & party == "COAL.SAN LUIS DE PALENQUE UNIDO, PRODUCTIVO Y TURÍSTICO"
replace incumbent_loose=1 if reg_code == 48009 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 48013 & party == "COALICIÓN PRIMERO LA GENTE"
replace incumbent_loose=1 if reg_code == 48020 & party == "COALICIÓN VILLANUEVA MÍA"
replace incumbent_loose=1 if reg_code == 52010 & party == "COALICIÓN PART. CONSERVADOR- CAMBIO RADICAL - DE LA U - LIBERAL - ALIANZA VERDE"
replace incumbent_loose=1 if reg_code == 52035 & party == "COALICIÓN FE Y CONFIANZA POR UNA GRANADA IDEAL"
replace incumbent_loose=1 if reg_code == 52040 & party == "COALICIÓN GUAMAL SOMOS TODOS"
replace incumbent_loose=1 if reg_code == 52041 & party == "COAL.LA MACARENA ES MI COMPROMISO"
replace incumbent_loose=1 if reg_code == 52043 & party == "COALICIÓN JUNTOS LO HACEMOS POSIBLE"
replace incumbent_loose=1 if reg_code == 52045 & party == "COALICIÓN PUERTO LÓPEZ IMPARABLE"
replace incumbent_loose=1 if reg_code == 52049 & party == "PARTIDO CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 52050 & party == "COALICIÓN PARTIDO CONSERVADOR- PART. CAMBIO RADICAL - PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 52055 & party == "COALICIÓN TODOS POR EL PROGRESO"
replace incumbent_loose=1 if reg_code == 52058 & party == "COALICIÓN RECUPEREMOS SAN JUAN"
replace incumbent_loose=1 if reg_code == 52060 & party == "COALICIÓN SAN MARTÍN SOMOS TODOS"
replace incumbent_loose=1 if reg_code == 52074 & party == "COALICIÓN UNIDOS CONSTRUIMOS PAZ"
replace incumbent_loose=1 if reg_code == 54001 & party == "COAL.SAN JOSÉ MODERNA SOSTENIBLE E INCLUYENTE"
replace incumbent_loose=1 if reg_code == 54007 & party == "COALICIÓN UNIDOS POR EL PROGRESO Y DESARROLLO DEL RETORNO"
replace incumbent_loose=1 if reg_code == 54012 & party == "COAL.PARTIDO CONSERVADOR COLOMBIANO- PARTIDO CAMBIO RADICAL"
replace incumbent_loose=1 if reg_code == 64001 & party == "PARTIDO SOCIAL DE UNIDAD NACIONAL PARTIDO DE LA U"
replace incumbent_loose=1 if reg_code == 64002 & party == "COALICIÓN PUERTO ASÍS GANA 2020-2023"
replace incumbent_loose=1 if reg_code == 64004 & party == "COALICIÓN HAY RAZONES PARA CREER"
replace incumbent_loose=1 if reg_code == 64016 & party == "COALICIÓN FUERTES POR SANTIAGO"
replace incumbent_loose=1 if reg_code == 64018 & party == "COALICIÓN CONSTRUYENDO JUNTOS"
replace incumbent_loose=1 if reg_code == 64019 & party == "COALICIÓN SIBUNDOY HAGAMOS EQUIPO"
replace incumbent_loose=1 if reg_code == 64026 & party == "COALICIÓN POR UN PACTO POR PUERTO CAICEDO"
replace incumbent_loose=1 if reg_code == 64028 & party == "COAL.UNIDOS PODEMOS POR EL VALLE DEL GUAMUEZ"
replace incumbent_loose=1 if reg_code == 64030 & party == "COALICIÓN VILLAGARZON"
replace incumbent_loose=1 if reg_code == 72006 & party == "COALICIÓN CUMARIBO MERECE MÁS"
replace incumbent_loose=1 if reg_code == 1016 & party == "COALICIÓN LA GRAN ALIANZA POR AMALFI JUNTOS HACEMOS LA DIFERENCIA"


keep ID can incumbent incumbent_loose

save "$intermediate_data/incumbent_party_vars.dta", replace
