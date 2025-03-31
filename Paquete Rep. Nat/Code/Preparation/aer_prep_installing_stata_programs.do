/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This code installs of the Stata programs necessary to run the rest of the replication
			   code.
----------------------------------------------------------------------------------------------------
Index:		   A. Installing Stata Programs
===================================================================================================*/

est clear
set more off

/*===============================================================================================
                                  A. Installing Stata Programs
===============================================================================================*/

ssc install egenmore, replace
ssc install outreg, replace
ssc install reclink, replace
ssc install estout, replace
ssc install mgof, replace
ssc install moremata, replace
ssc install ritest, replace
ssc install lassopack, replace
ssc install mat2txt, replace
ssc install distinct, replace

