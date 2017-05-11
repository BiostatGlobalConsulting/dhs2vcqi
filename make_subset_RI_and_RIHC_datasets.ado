/**********************************************************************
Program Name:               make_subset_RI_and_RIHC_datasets
Purpose:                    Code to create VCQI RI subset dataset based on user input
Project:                    Q:\- WHO mics VCQI-compatible\mics manuals
Charge Number:  
Date Created:    			2017-03-28
Date Modified:  
Input Data:                 
Output2:                                
Comments: Take DHS dataset provided with new VCQI variables and create subset RI dataset with children in age range provided
Author:         Mary Kay Trimner

Stata version:    14.0
**********************************************************************/
**********************************************************************/
* This program is used to create a new dataset that contains a specific subset of RI participants
* For example: If you only want to run an analysis on children age 12-23 months

********************************************************************************
* Program Syntax
*
* Required Option:
*
* INPUTPATH --	format: 		string
*				description:	path and name of RI or RIHC dataset
*				note1:			RI or RIHC dataset must be created through the mics2vcqi conversion program
*				
*
********************************************************************************
********************************************************************************
* General Notes:
* This program will need to be ran on RI and RIHC datasets seperately
* This program will only keep children if variable in global CHILD_AGE_YEARS==1
* global CHILD_AGE_YEARS is typically variable b8 found in KR dataset.
********************************************************************************
capture program drop make_subset_RI_and_RIHC_datasets
program define make_subset_RI_and_RIHC_datasets

	syntax , INPUTpath(string asis)
	
	quietly {
	
		no di "Open `inputpath'..."
		use "`inputpath'", clear
		
		no di "Only keep the child if their age in years is equal to 1. Determined on variable $CHILD_AGE_YEARS..."
		keep if $CHILD_AGE_YEARS == 1
	
		no di "Save subset file as `inputpath'_12_to_23"
		save "`inputpath'_12_to_23", replace 
	}
end	
