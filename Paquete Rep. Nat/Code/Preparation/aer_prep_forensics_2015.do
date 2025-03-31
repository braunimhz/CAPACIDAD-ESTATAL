/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This code computes the forensic tests and (simulated) p-values for the second digits
			   of the 2015 election counts at the voting booth level. 
----------------------------------------------------------------------------------------------------
Index:		   A. Auxiliary Functions
			   B. Set-up
			   C. Kuiper tests
			   D. Chi2 and Kolmogorov tests
			   E. Aggregating forensic outcomes
===================================================================================================*/

est clear
set more off

** ------------------------------------------------
** ------------------------------------------------
** A. Auxiliary Functions
** ------------------------------------------------
** ------------------------------------------------

cap mata mata drop pvals_exact()
mata:
void pvals_exact(real scalar reps, real scalar nn_second, real scalar true_kuiper_second ) {
		p_second=(.1196793,.1138901,.1088215, .1043296, .1003082,.0966772,.0933747,.090352,.0875701,.0849973)
		f_second=mm_colrunsum(p_second')

		p_kuiper_second=J(reps,1,.)
		
		y_second=J(10,1,.)
		for (i=1; i<=reps; i++){

			x_second=rdiscrete(nn_second, 1, p_second)
			x_second=x_second-J(nn_second, 1, 1)
			
			for (j=0; j<=9; j++){
				y_second[j+1,]= sum(x_second :== j)
				}
			y_second=y_second :/ nn_second
			fe_second=mm_colrunsum(y_second)
			
			kuiper_second=max(f_second-fe_second)+max(fe_second-f_second)
		
			p_kuiper_second[i,]=(kuiper_second>true_kuiper_second)
			
		}

		p_kuiper_second=sum(p_kuiper_second)/reps

		st_matrix("p_kuiper_second", p_kuiper_second[1,1])

}
end


capture program drop kuiper_second
program define kuiper_second , eclass

		quietly count if group==`1' & second_digit!=.
		local nn=`r(N)'
		local kuiper=0
		forvalues j=0(1)9{

		if "`3'"=="main"{
		quietly count if `2'==`j' & group==`1'
		}
		else{
		quietly count if `2'==`j' & `2'!=.
		}

		local r`j'=`r(N)'/`nn'
		
		local rr`j'=0
		forvalues l=0(1)`j'{
		local rr`j'=`rr`j''+`r`l''
		}
		local rrp`j'=`rr`j''-CDF_benf_s[`j'+1]
		local rrm`j'=CDF_benf_s[`j'+1]-`rr`j''
		}
		local kuiper=max(`rrp0',`rrp1',`rrp2', `rrp3', `rrp4', `rrp5', `rrp6', `rrp7', `rrp8', `rrp0')
		local kuiper=`kuiper'+max(`rrm0',`rrm1',`rrm2', `rrm3', `rrm4', `rrm5', `rrm6', `rrm7', `rrm8', `rrm0')
		*display `kuiper'

		ereturn scalar kuiper_second = `kuiper'

end 


** ------------------------------------------------
** ------------------------------------------------
** B. Set-up
** ------------------------------------------------
** ------------------------------------------------


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


** ---------------------------------------------------------
** Preparing voting data:
** ---------------------------------------------------------

import delim "$raw_data/RESULTADOS_ELECTORALES_2015_ALCALDIA.csv", clear encoding("utf-8")

ren desc_depto departamento
ren desc_mpio municipio
 
 * Droping invalid votes:

drop if desc_candidato=="VOTOS EN BLANCO ." | desc_candidato=="VOTOS NULOS ."  | desc_candidato=="VOTOS NO MARCADOS ." 

gen second_digit=substr(string(votos), 2, 1)
destring second_digit, replace


merge n:1 departamento municipio using `codigos'

keep if _m==3
drop _m

merge n:1 ID using "$intermediate_data/treatment_indicators.dta", force
drop _m 

keep ID T_FB second_digit votos


global digs "second_digit"

foreach v of global digs{
forvalues i=0(1)9{
gen n_dig_`v'`i'=(`v'==`i') if  `v'!=.
}
}

keep if T_FB!=.

** ------------------------------------------------
** ------------------------------------------------
** C. Kuiper test
** ------------------------------------------------
** ------------------------------------------------

* Defining parameters:

gen h=_n-1 if _n<11
gen benf_s=log10(1+(1/(10+h)))+log10(1+(1/(20+h)))+log10(1+(1/(30+h)))+log10(1+(1/(40+h)))+log10(1+(1/(50+h)))+log10(1+(1/(60+h)))+log10(1+(1/(70+h)))+log10(1+(1/(80+h)))+log10(1+(1/(90+h)))			
gen CDF_benf_s = sum(benf_s)
drop h 

gen benf_second=log10(1+(1/(10+second_digit)))+log10(1+(1/(20+second_digit)))+log10(1+(1/(30+second_digit)))+log10(1+(1/(40+second_digit)))+log10(1+(1/(50+second_digit)))+log10(1+(1/(60+second_digit)))+log10(1+(1/(70+second_digit)))+log10(1+(1/(80+second_digit)))+log10(1+(1/(90+second_digit)))

drop if ID==52520
tempfile main
save `main', replace

* Simulations:

cap gen p_kuiper_second_n=.

gen kuiper_second=.

cap egen group = group(ID)
su group, meanonly


forvalues w = 1/`r(max)' {
	
	kuiper_second `w' second_digit main
	local true_kuiper_second=`e(kuiper_second)'
	replace kuiper_second=`e(kuiper_second)' if group==`w'
	
	quietly count if group==`w' & second_digit!=.
	local nn_second=`r(N)'

	local reps=10000
	mata: pvals_exact(`reps', `nn_second', `true_kuiper_second')

	replace p_kuiper_second_n=p_kuiper_second[1,1] if group==`w'
}

keep ID  p_kuiper_second_n kuiper_second T_FB

collapse (max)  p_kuiper_second_n kuiper_second T_FB, by(ID)


gen sig95_kuiper_second=(p_kuiper_second_n<0.05)

tempfile kuiper
save `kuiper', replace

** ------------------------------------------------
** ------------------------------------------------
** D. Chi2 and Kolmogorov tests
** ------------------------------------------------
** ------------------------------------------------

use `main', clear

gen p_kolmo_second=.
gen kolmo_second=.
gen p_chi2_second=.
gen chi2_second=.

egen group = group(ID)
su group, meanonly

forvalues i = 1/`r(max)' {
mgof second_digit = benf_second if group == `i', mc  ksmirnov reps(10000)
replace p_kolmo_second=r(p_ksmirnov) if group == `i'
replace kolmo_second=r(ksmirnov) if group == `i'
replace p_chi2_second=r(p_x2 ) if group == `i'
replace chi2_second=r(x2 ) if group == `i'
}

collapse (max)  p_kolmo_second kolmo_second  p_chi2_second chi2_second T_FB, by(ID)

gen sig95_kolmo_second=(p_kolmo_second<0.05)
gen sig95_chi2_second=(p_chi2_second<0.05)



** ------------------------------------------------
** ------------------------------------------------
** E. Aggregating forensic outcomes
** ------------------------------------------------
** ------------------------------------------------

merge 1:1 ID using `kuiper'
drop _m

sum chi2_second if T_FB==0
gen z_chi2_second=(chi2_second-`r(mean)')/`r(sd)'

sum kuiper_second if T_FB==0
gen z_kuiper_second=(kuiper_second-`r(mean)')/`r(sd)'

sum kolmo_second if T_FB==0
gen z_kolmo_second=(kolmo_second-`r(mean)')/`r(sd)'

gen index_second=z_chi2_second+z_kuiper_second+z_kolmo_second
sum index_second if T_FB==0
gen z_index_second_a2015=(index_second-`r(mean)')/`r(sd)' 


egen sig95_max_second_a2015=rowmax(sig95_chi2_second sig95_kolmo_second sig95_kuiper_second)


* Completing data for missing municipality:
global vars "z_index_second_a2015 sig95_max_second_a2015"

merge 1:1 ID using "$intermediate_data/treatment_indicators.dta", force

foreach y of global vars{
sum `y' if T_FB!=.
replace `y'=`r(mean)' if ID==52520
}

keep  ID z_index_second_a2015 sig95_max_second_a2015

save "$intermediate_data/forensics_2015_covs.dta", replace




