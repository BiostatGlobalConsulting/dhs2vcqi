/**********************************************************************
Program Name:               DHS to VCQI - levels of datasets
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
* 2016-10-17			Dale Rhoda		Strip missing ids from levelX_order
* 										datasets

********************************************************************************

* Bring in Combined dataset
use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear

* cd to Output folder
cd "$OUTPUT_FOLDER"

* Create level1name dataset
clear
set obs 1
generate level1id = 1 in 1
generate level1name = "${LEVEL1_NAME}" in 1
save level1name, replace

* Create level2names dataset
use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear
bysort $PROVINCE_ID: keep if _n == 1
keep $PROVINCE_ID
sort $PROVINCE_ID
rename $PROVINCE_ID level2id
decode level2id, generate(level2name)
label value level2id
save level2names, replace

* Create level2order dataset
clear
use level2names
drop level2name
gen level2order = _n
drop if missing(level2id)
save level2order, replace

* Create level3name dataset
//get rid of unique global and do word count
clear
use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear
if wordcount("$LEVEL_3_ID") > 1 {
	egen level3id=group(${LEVEL_3_ID}), label lname(l3id)
	gen level3name=""
	forvalue i = 1/`=_N' {
		replace level3name="`:label l3id `=level3id[`i']''" in `i'
	}
	bysort level3id: keep if _n==1
	sort level3id
	keep level3*
	label value level3id
	save level3names, replace

}
else {
	bysort $LEVEL_3_ID: keep if _n == 1 & !missing($LEVEL_3_ID)
	keep $LEVEL_3_ID 
	sort $LEVEL_3_ID
	rename $LEVEL_3_ID level3id
	decode level3id, generate(level3name)
	label value level3id 
	save level3names, replace
}
* Create level3order dataset
clear
use level3names
drop level3name
gen level3order = _n
save level3order, replace

**********************************************************************
