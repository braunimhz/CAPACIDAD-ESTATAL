/*==================================================================================================
Project:       All Eyes on Them: A Field Experiment on Citizen Oversight and Electoral Integrity
Author:        Mateo Montenegro 
Purpose:       This is the master code to replicate all of the tables and figures in the paper.
----------------------------------------------------------------------------------------------------
Index:		   A. Setting Path Directories
			   B. Setting Options for Replication
			   C. Executing Programs
===================================================================================================*/

clear all
set more off
set matsize 10000
global seed "20192810"
set seed $seed

/*===============================================================================================
                                  A. Setting Path Directories
===============================================================================================*/

global replication_dir "/Users/mateomontenegro/Dropbox (CEMFI)/Facebook Project 2/Submission/Replication Public" // Set the path to the main replication folder
global code "$replication_dir/Code"
global analysis_code "$code/Analysis"
global prep_code "$code/Preparation"
global raw_data "$replication_dir/Data/Raw"
global intermediate_data "$replication_dir/Data/Intermediate"
global final_data "$replication_dir/Data/Final"
global out "$replication_dir/Output"
global out_balance "$out/Balance"

/*===============================================================================================
                                  B. Setting Options for Replication
===============================================================================================*/


local stata_programs=1 // Switch this option to zero if you do not want to run installing the required Stata programs

local preparation=1 // Switch this option to zero if you do not want to run the code preparing the variables

local tables=1 // Switch this option to zero if you do not want to run the code replicating the tables

local figures=1 // Switch this option to zero if you do not want to run the code replicating the figures

global confidential=0 // Switch this option to one if you have access to the confidential survey data


/*===============================================================================================
                                  C. Executing Programs
===============================================================================================*/

* Note: The following lines of code must be run in order

if `stata_programs' == 0 {
do "$prep_code/aer_prep_installing_stata_programs.do"
}

if `preparation' == 0 {
do "$analysis_code/aer_build_main_datasets.do"
}

if `tables' == 1 {
do "$analysis_code/aer_tables.do"
}

if `figures' == 1 {
do "$analysis_code/aer_figures.do"
}

