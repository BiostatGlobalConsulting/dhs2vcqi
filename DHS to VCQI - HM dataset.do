/**********************************************************************
Program Name:               DHS to VCQI -HM dataset
Purpose:                     Code to create VCQI dataset using DHS questionnaire
Project:                    Q:\- WHO DHS VCQI-compatible\DHS manuals
Charge Number:  
Date Created:    			2016-04-27
Date Modified:  
Input Data:                 
Output2:                                
Comments: Take DHS combined dataset with new VCQI variables and create datasets so that the data can be run through VCQI
Author:         Mary Kay Trimner

Stata version:    14.0
**********************************************************************/
set more off

* Pull in DHS combined dataset and save as new dataset for VCQI
use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear


* cd to OUTPUT local
cd "$OUTPUT_FOLDER"

save DHS_${DHS_NUM}_to_VCQI_HM, replace 

* Drop all variables except HM

keep HM* 
aorder

* Only keep observations where survey was completed
drop if HM19!=4

save, replace

* Save dataset for each SIA survey and rename each HM25 variable
foreach v in `=lower("${SIA_LIST}")' {
	use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_to_VCQI_HM", clear
	rename HM41_`v' HM41
	drop HM41_*
	
	rename HM42_`v' HM42
	drop HM42_*
	
	save DHS_${DHS_NUM}_VCQI_HM_SIA_`=upper("`v'")', replace
}

