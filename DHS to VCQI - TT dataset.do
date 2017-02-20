/**********************************************************************
Program Name:               DHS to VCQI - TT dataset
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

if $TT_SURVEY==1 {
	* Pull in DHS combined dataset and save as new dataset for VCQI
	use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear

	* cd to Output folder
	cd "$OUTPUT_FOLDER"

	save DHS_${DHS_NUM}_to_VCQI_TT, replace 

	* Only keep the people who participated in the survey 
	keep if DHS_${DHS_NUM}_tt_survey==1
	
	* Only keep if the child has not reached the first birthday
	keep if ${CHILD_AGE_YEARS} == 0
	
	* Only keep if the child was born alive
	keep if ${CHILD_IS_ALIVE} == 1 | ${CHILD_BORN_ALIVE} == 1

	* Only keep if the interview was completed
	keep if !missing(TT37) | !missing(TT41)
	
	* Drop all variables except TT
	keep TT* `dlist' tt_eligible
	aorder

	save, replace

}
