/**********************************************************************
Program Name:               DHS to VCQI -TT dataset
Purpose:                    Code to create VCQI dataset using DHS questionnaire
Project:                    Q:\- WHO DHS VCQI-compatible\DHS manuals
Charge Number:  
Date Created:    			2016-04-28
Date Modified:  
Input Data:                 
Output2:                                
Comments: Take DHS combined dataset with new VCQI vaTTables and create datasets so that the data can be run through VCQI
Author:         Mary Kay TTTmner

Stata version:    14.0
**********************************************************************/
set more off

if $TT_SURVEY==1 {
	* Pull in DHS combined dataset and save as new dataset for VCQI
	use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear


	* cd to OUTPUT local
	cd "$OUTPUT_FOLDER"

	save DHS_${DHS_NUM}_to_VCQI_TT, replace 


	* Only keep the people who participated in the survey 
	keep if DHS_${DHS_NUM}_tt_survey==1

	* Only keep if the interview was completed
	keep if HM38==4
	
	* Drop all variables except TT
	keep TT* `dlist' tt_eligible
	aorder

	save, replace

	* Save dataset for each SIA survey
	foreach v in `=lower("${SIA_LIST}")' {
		use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_to_VCQI_TT", clear
		save DHS_${DHS_NUM}_VCQI_TT_SIA_`=upper("`v'")', replace
	}
}
