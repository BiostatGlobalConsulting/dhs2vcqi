/**********************************************************************
Program Name:               DHS to VCQI - HM dataset
Purpose:                    Code to create VCQI dataset using DHS questionnaire
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
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-10-12			Dale			Only generate SIA files if user 
*										wants to analyze the SIA datasets

********************************************************************************

* Pull in DHS combined dataset and save as new dataset for VCQI
use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear


* cd to Output folder
cd "$OUTPUT_FOLDER"

save DHS_${DHS_NUM}_to_VCQI_HM, replace 

* Drop all variables except HM
keep HM* 
aorder

* Only keep observations where survey was completed
drop if HM19!=4

save, replace

* Save dataset for each SIA survey and rename each HM41 and HM42 variables
if $SIA_SURVEY==1 {
	foreach v in `=lower("${SIA_LIST}")' {
		use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_to_VCQI_HM", clear
		rename HM41_`v' HM41
		rename HM42_`v' HM42

		* Only drop HM41_* & HM42_* if there is more than 1 campaign
		if `=wordcount("${SIA_LIST}")'>1 {
			drop HM41_*
			drop HM42_*
		}
		save DHS_${DHS_NUM}_VCQI_HM_SIA_`=upper("`v'")', replace
	}
}
