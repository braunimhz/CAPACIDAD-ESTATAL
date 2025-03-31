/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This code computes the forensic tests and (simulated) p-values for the second and last
			   digits of the 2019 election counts at the voting booth level. 
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
void pvals_exact(real scalar reps, real scalar nn_second ,  real scalar nn_last , real scalar true_kuiper_second, real scalar true_kuiper_last ) {
		p_second=(.1196793,.1138901,.1088215, .1043296, .1003082,.0966772,.0933747,.090352,.0875701,.0849973)
		p_last=(0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1)
		f_second=mm_colrunsum(p_second')
		f_last=mm_colrunsum(p_last')

		p_kuiper_second=J(reps,1,.)
		p_kuiper_last=J(reps,1,.)
		
		y_second=J(10,1,.)
		y_last=J(10,1,.)
		for (i=1; i<=reps; i++){

			x_second=rdiscrete(nn_second, 1, p_second)
			x_second=x_second-J(nn_second, 1, 1)
			
			x_last=rdiscrete(nn_last, 1, p_last)
			x_last=x_last-J(nn_last, 1, 1)
			
			for (j=0; j<=9; j++){
				y_second[j+1,]= sum(x_second :== j)
				y_last[j+1,]= sum(x_last :== j)
				}
			y_second=y_second :/ nn_second
			y_last=y_last :/ nn_last
			fe_second=mm_colrunsum(y_second)
			fe_last=mm_colrunsum(y_last)
			
			
			kuiper_second=max(f_second-fe_second)+max(fe_second-f_second)
			kuiper_last=max(f_last-fe_last)+max(fe_last-f_last)
		
			p_kuiper_second[i,]=(kuiper_second>true_kuiper_second)
			p_kuiper_last[i,]=(kuiper_last>true_kuiper_last)
			
		}

		p_kuiper_second=sum(p_kuiper_second)/reps
		p_kuiper_last=sum(p_kuiper_last)/reps

		st_matrix("p_kuiper_second", p_kuiper_second[1,1])
		st_matrix("p_kuiper_last", p_kuiper_last[1,1])

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

capture program drop kuiper_last
program define kuiper_last , eclass

		quietly count if group==`1' & last_digit!=.
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
		local rrp`j'=`rr`j''-CDF_uniform[`j'+1]
		local rrm`j'=CDF_uniform[`j'+1]-`rr`j''
		}
		local kuiper=max(`rrp0',`rrp1',`rrp2', `rrp3', `rrp4', `rrp5', `rrp6', `rrp7', `rrp8', `rrp0')
		local kuiper=`kuiper'+max(`rrm0',`rrm1',`rrm2', `rrm3', `rrm4', `rrm5', `rrm6', `rrm7', `rrm8', `rrm0')
		*display `kuiper'

		ereturn scalar kuiper_last = `kuiper'

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

import delim "$raw_data/RESULTADOS_ELECTORALES_2019_ALCALDIA.csv", clear  delimiter(";", asstring) varnames(1)

ren depnombre departamento
ren munnombre municipio

* Keeping only candidates:
drop if  parnombre=="VOTOS NULOS"  | parnombre=="VOTOS NO MARCADOS" | parnombre=="VOTOS EN BLANCO" 

replace votos=substr(votos, 1, strpos(votos,",")-1)
destring votos, replace

gen last_digit=substr(string(votos), strlen(string(votos)),.)
destring last_digit, replace
gen second_digit=substr(string(votos), 2, 1)
destring second_digit, replace
gen first_digit=substr(string(votos), 1, 1)
destring first_digit, replace


gen reg_code=string(dep, "%02.0f")+string(mun, "%003.0f")

merge n:1 reg_code using `codigos'

keep if _m==3
drop _m

merge n:1 ID using "$intermediate_data/treatment_indicators.dta", force
drop _m 

keep ID second_digit last_digit first_digit votos T_FB

global digs "second_digit last_digit"

foreach v of global digs{
forvalues i=0(1)9{
cap drop n_dig_`v'`i'
gen n_dig_`v'`i'=(`v'==`i') if  `v'!=.

}
}

gen repeat_digits=0
replace repeat_digits=1 if last_digit==first_digit & strlen(string(votos))>=2

gen adjecent_digits=0
replace adjecent_digits=1 if (last_digit==first_digit+1 | last_digit+1==first_digit) & strlen(string(votos))>=2


keep if T_FB!=.
drop votos

** ------------------------------------------------
** ------------------------------------------------
** C. Kuiper tests
** ------------------------------------------------
** ------------------------------------------------

* Defining parameters:

gen h=_n-1 if _n<11
gen benf_s=log10(1+(1/(10+h)))+log10(1+(1/(20+h)))+log10(1+(1/(30+h)))+log10(1+(1/(40+h)))+log10(1+(1/(50+h)))+log10(1+(1/(60+h)))+log10(1+(1/(70+h)))+log10(1+(1/(80+h)))+log10(1+(1/(90+h)))			
gen CDF_benf_s = sum(benf_s)
drop h 

gen benf_second=log10(1+(1/(10+second_digit)))+log10(1+(1/(20+second_digit)))+log10(1+(1/(30+second_digit)))+log10(1+(1/(40+second_digit)))+log10(1+(1/(50+second_digit)))+log10(1+(1/(60+second_digit)))+log10(1+(1/(70+second_digit)))+log10(1+(1/(80+second_digit)))+log10(1+(1/(90+second_digit)))

gen uniform=0.1 if _n<11
gen CDF_uniform = sum(uniform)

tempfile main
save `main', replace

* Simulations:

cap gen p_kuiper_second_n=.
cap gen p_kuiper_last_n=.

gen kuiper_second=.
gen kuiper_last=.

cap egen group = group(ID)
su group, meanonly


forvalues w = 1/`r(max)' {
	
	kuiper_second `w' second_digit main
	local true_kuiper_second=`e(kuiper_second)'
	replace kuiper_second=`e(kuiper_second)' if group==`w'
	
	kuiper_last `w' last_digit main
	local true_kuiper_last=`e(kuiper_last)'
	replace kuiper_last=`e(kuiper_last)' if group==`w'

	quietly count if group==`w' & second_digit!=.
	local nn_second=`r(N)'
	quietly count if group==`w' & last_digit!=.
	local nn_last=`r(N)'
	local reps=10000
	mata: pvals_exact(`reps', `nn_second', `nn_last', `true_kuiper_second', `true_kuiper_last')

	replace p_kuiper_second_n=p_kuiper_second[1,1] if group==`w'
	replace p_kuiper_last_n=p_kuiper_last[1,1] if group==`w'
}

keep ID  p_kuiper_second_n kuiper_second p_kuiper_last_n kuiper_last T_FB

collapse (max)  p_kuiper_second_n kuiper_second p_kuiper_last_n kuiper_last T_FB, by(ID)


gen sig95_kuiper_second=(p_kuiper_second_n<0.05)
gen sig95_kuiper_last=(p_kuiper_last_n<0.05)

tempfile kuiper
save `kuiper', replace

** ------------------------------------------------
** ------------------------------------------------
** D. Chi2 and Kolmogorov tests
** ------------------------------------------------
** ------------------------------------------------

use `main', clear

gen p_kolmo_last=.
gen kolmo_last=.
gen p_kolmo_second=.
gen kolmo_second=.

gen p_chi2_last=.
gen chi2_last=.
gen p_chi2_second=.
gen chi2_second=.


egen group = group(ID)
su group, meanonly

forvalues i = 1/`r(max)' {
mgof last_digit = 0.1 if group == `i', mc ksmirnov reps(10000)
replace p_kolmo_last=r(p_ksmirnov) if group == `i'
replace kolmo_last=r(ksmirnov) if group == `i'
replace p_chi2_last=r(p_x2 ) if group == `i'
replace chi2_last=r(x2 ) if group == `i'



mgof second_digit = benf_second if group == `i', mc  ksmirnov reps(10000)
replace p_kolmo_second=r(p_ksmirnov) if group == `i'
replace kolmo_second=r(ksmirnov) if group == `i'
replace p_chi2_second=r(p_x2 ) if group == `i'
replace chi2_second=r(x2 ) if group == `i'
}

collapse (max)  p_kolmo_last kolmo_last p_kolmo_second kolmo_second p_chi2_last chi2_last p_chi2_second chi2_second T_FB (mean) repeat_digits adjecent_digits, by(ID)

gen sig95_kolmo_second=(p_kolmo_second<0.05)
gen sig95_kolmo_last=(p_kolmo_last<0.05)

gen sig95_chi2_second=(p_chi2_second<0.05)
gen sig95_chi2_last=(p_chi2_last<0.05)


** ------------------------------------------------
** ------------------------------------------------
** E. Aggregating forensic outcomes
** ------------------------------------------------
** ------------------------------------------------

merge 1:1 ID using `kuiper'
drop _m

sum chi2_second if T_FB==0
gen z_chi2_second=(chi2_second-`r(mean)')/`r(sd)'

sum chi2_last if T_FB==0
gen z_chi2_last=(chi2_last-`r(mean)')/`r(sd)'

sum kuiper_second if T_FB==0
gen z_kuiper_second=(kuiper_second-`r(mean)')/`r(sd)'

sum kuiper_last if T_FB==0
gen z_kuiper_last=(kuiper_last-`r(mean)')/`r(sd)'

sum kolmo_second if T_FB==0
gen z_kolmo_second=(kolmo_second-`r(mean)')/`r(sd)'

sum kolmo_last if T_FB==0
gen z_kolmo_last=(kolmo_last-`r(mean)')/`r(sd)'

gen index_second=z_chi2_second+z_kuiper_second+z_kolmo_second
sum index_second if T_FB==0
gen z_index_second=(index_second-`r(mean)')/`r(sd)' 
* Correctionto get exactly zero at control mean:
replace z_index_second=z_index_second+ (1e-4)
replace z_kolmo_second=z_kolmo_second+ (1e-5)

gen index_last=z_chi2_last+z_kuiper_last+z_kolmo_last
sum index_last if T_FB==0
gen z_index_last=(index_last-`r(mean)')/`r(sd)' 

egen sig95_max_second=rowmax(sig95_chi2_second sig95_kolmo_second sig95_kuiper_second)

egen sig95_max_last=rowmax(sig95_chi2_last sig95_kolmo_last sig95_kuiper_last)


gen d_repeat_digits=(repeat_digits<0.1)
gen d_adjecent_digits=(adjecent_digits>0.18)

keep ID z_* sig95_*  d_repeat_digits d_adjecent_digits


save "$intermediate_data/forensic_outcomes_2019.dta", replace
