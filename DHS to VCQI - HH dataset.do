/**********************************************************************
Program Name:               DHS to VCQI -HH dataset
Purpose:                     Code to create VCQI dataset using DHS questionnaire
Project:                    Q:\- WHO DHS VCQI-compatible\DHS manuals
Charge Number:  
Date Created:    			2016-04-06
Date Modified:  
Input Data:                 
Output2:                                
Comments: Take DHS combined dataset with new VCQI variables and create datasets so that the data can be run through VCQI
Author:         Mary Kay Trimner

Stata version:    14.0
******************************************************************************/
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

* cd to OUTPUT local
cd "$OUTPUT_FOLDER"

save DHS_${DHS_NUM}_to_VCQI_HH, replace 

* Only variables required are HH01, HH02, HH03, HH04, HH12, HH14, HH18, HH23, HH24, HH25 

* Drop all lines so there is only one line per household
bysort HH01 HH03 HH14: keep if _n==1

keep HH* 
aorder

save, replace

* Save dataset for each SIA survey and rename each HH25 variable
if $SIA_SURVEY==1 {
	foreach v in `=lower("${SIA_LIST}")' {
		use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_to_VCQI_HH", clear
		rename HH25_`v' HH25
		
		drop HH25_* 
		save DHS_${DHS_NUM}_VCQI_HH_SIA_`=upper("`v'")', replace
	}
}
