/**********************************************************************
Program Name:               DHS to VCQI - RI dataset
Purpose:                    Code to create VCQI dataset using DHS questionnaire
Project:                    Q:\- WHO DHS VCQI-compatible\DHS manuals
Charge Number:  
Date Created:    			2016-04-28
Date Modified:  
Input Data:                 
Output2:                                
Comments: Take DHS combined dataset with new VCQI variables and create datasets so that the data can be run through VCQI
Author:         Mary Kay Trimner

Stata version:    14.0
**********************************************************************/
set more off

if $RI_SURVEY==1 {
	* Pull in DHS combined dataset and save as new dataset for VCQI
	use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear


	* cd to Output folder
	cd "$OUTPUT_FOLDER"

	save DHS_${DHS_NUM}_to_VCQI_RI, replace 

	* Only keep the people who participated in the survey 
	keep if DHS_${DHS_NUM}_child_survey==1 
	
	* Only keep if the interview was completed
	keep if HM33==4

	
	* Drop all variables except RI
	local dlist
	foreach v in `=lower("${RI_LIST}")' {
		local dlist `dlist' `v'_date_card_* `v'_history `v'_tick_card dob_date_card_* dob_date_hist* 
	}
	
	* Keep bcg_scar_history if bcg is part of the RI_LIST
	if strpos("`=lower("$RI_LIST")'","bcg")!=0 {
		local dlist `dlist' bcg_scar_history
	}
	
	* Make a list of the additional variables to include with the dataset
	foreach v in $RI_ADDITIONAL_VARS {
		capture confirm variable DHS_${DHS_NUM}_`v'
		if _rc == 0 local dlist `dlist' DHS_${DHS_NUM}_`v'
	}

	keep  RI* `dlist' ri_eligible age_months $CHILD_AGE_YEARS $CHILD_AGE_MONTHS
	order RI* `dlist' ri_eligible age_months $CHILD_AGE_YEARS $CHILD_AGE_MONTHS


	save, replace
	
	* Save dataset for age groups
	* Age 12-23m
	use "DHS_${DHS_NUM}_to_VCQI_RI", clear
	keep if  $CHILD_AGE_YEARS == 1
	save "DHS_${DHS_NUM}_to_VCQI_RI_12_to_23", replace 

	
	* If max age is greather than 23m 
	* Make a second dataset that captures 24m to $RI_MAX_AGE
	if $RI_MAX_AGE >23 {
		use "DHS_${DHS_NUM}_to_VCQI_RI", clear
		keep if  $CHILD_AGE_YEARS > 1
		save "DHS_${DHS_NUM}_to_VCQI_RI_24_to_${RI_MAX_AGE}", replace 
	}

	
	* If min age does not equal 12
	* Make a dataset with the ages provided
	if $RI_MIN_AGE != 12 { 
		use "DHS_${DHS_NUM}_to_VCQI_RI", clear
		keep if  $CHILD_AGE_YEARS < 1
		save "DHS_${DHS_NUM}_to_VCQI_RI_${RI_MIN_AGE}_to_${RI_MAX_AGE}", replace 
	}

}
