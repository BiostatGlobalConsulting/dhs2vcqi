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
capture program drop make_subset_RI_and_RIHC_datasets
program define make_subset_RI_and_RIHC_datasets

	syntax ,  MINage(string asis) MAXage(string asis) INPUTpath(string asis)
	
	quietly {
	
		no di "Open `inputpath'..."
		use "`inputpath'", clear
		
		no di "Only keep the child if their age in months is greater than `minage' and less than `maxage'..."
		keep if $CHILD_AGE_YEARS == 1
	
		no di "Save subset file as `inputpath'_`minage'_to_`maxage'"
		save "`inputpath'_`minage'_to_`maxage'", replace 
	}
end	
