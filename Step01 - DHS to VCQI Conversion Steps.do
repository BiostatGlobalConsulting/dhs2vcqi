/**********************************************************************
Program Name:               Step01- DHS to VCQI Converstion Steps 
Purpose:                    Take the datasets provided by the user and create one large dataset 
*													
Project:                    Q:\- WHO DHS VCQI-compatible\DHS manuals
Date Created:    			2016-06-09
Author:         Mary Kay Trimner
Stata version:    14.0
********************************************************************************/

*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-10-12			Dale			Change hid to hhid in line 162
*										(Thanks to David Brown)

********************************************************************************

* Create one large dataset
cd "${INPUT_FOLDER}"

********************************************************************************
********************************************************************************
********************************************************************************

* Create one large dataset

* There could be times when all the datasets are not provided. 
* This code makes a large dataset contingent on which Surveys were completed
* HH Data will always be provided, this is for TT,RI and RIHC

* If RI (child) survey and TT (womens) survey were both completed
if $RI_SURVEY ==1 & $TT_SURVEY==1 {
	use "${DHS_KR_DATA}", clear
	
	* drop if the child is no longer alive
	drop if b5==0
	
	* Create variable to show RI Survey date
	gen ri_survey_date=mdy(${RI_DATE_MONTH}, ${RI_DATE_DAY}, ${RI_DATE_YEAR})
	format %td ri_survey_date
	label variable ri_survey_date "Date of RI survey"

	* Create variable to show they were part of the Child Survey
	gen child_survey=1
	label variable child_survey "Participated in Child Survey"
	
	capture confirm variable $NUM_TT_PREGNANCY
	if _rc == 0 gen tt_survey = !missing($NUM_TT_PREGNANCY)
	if _rc != 0 gen tt_survey = .

	save "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", replace

	append using "${DHS_IR_DATA}"

	* Create variable to indicate Womens Survey
	replace tt_survey=1 if child_survey==. & !missing($NUM_TT_PREGNANCY)
	label variable tt_survey "Participated in Womens/TT survey"

	* Create line number variable for merging purposes
	gen ${HM_LINE}=${RI_LINE} 
	replace ${HM_LINE}=${TT_LINE} if missing(${RI_LINE}) & child_survey!=1
	label variable ${HM_LINE} "line number"
		
	* Rename the STRATUM_ID variable so a merge can occur with Household members and Household list datasets
	if "$STRATUM_ID"=="shstate" {
		rename sstate	$STRATUM_ID
	}
	
	else {
		rename `=substr("$STRATUM_ID",2,.)' $STRATUM_ID //rename since the variable names vary from dataset
	}
	rename `=substr("$HH_ID",2,.)' $HH_ID //rename since the variable names vary from dataset
	rename `=substr("$CLUSTER_ID",2,.)' $CLUSTER_ID //rename since the variable names vary from dataset
	
	* Rename reponsdent TT_LINE number for merging purposes
	gen h$RESPONDENT_LINE=$RESPONDENT_LINE
	label variable h$RESPONDENT_LINE "TT line number repeated for merging purposes to uniquely identify each person"

	* Determine if each persone can be uniquely identified
	sort $STRATUM_ID $CLUSTER_ID $HH_ID h$RESPONDENT_LINE $HM_LINE
	bysort $STRATUM_ID $CLUSTER_ID $HH_ID h$RESPONDENT_LINE $HM_LINE: gen not_unique=_n
	gen do_not_keep=1 if not_unique>1
	replace do_not_keep=1 if not_unique[_n+1]>1 & not_unique[_n+1]!=.	
	drop if do_not_keep==1
	
	* Merge in Household Member data
	merge 1:1 $STRATUM_ID $CLUSTER_ID $HH_ID h$RESPONDENT_LINE  $HM_LINE using "${DHS_PR_DATA}"

	drop _merge

	save, replace
	
	* Merge in HH data
	merge m:1 hhid $STRATUM_ID $HH_ID $CLUSTER_ID using "${DHS_HR_DATA}" 
	
	* Create variable to show the date of TT survey
	gen tt_survey_date=mdy(${HH_DATE_MONTH}, ${HH_DATE_DAY}, ${HH_DATE_YEAR}) if tt_survey==1
	format %td tt_survey_date
	label variable tt_survey_date "Date of TT survey"
	save, replace


	drop _merge

	save, replace
	
}

********************************************************************************
********************************************************************************
********************************************************************************

* If RI (child) survey completed but TT (womens) survey was NOT completed
if $RI_SURVEY ==1 & $TT_SURVEY!=1 {
	use "${DHS_KR_DATA}", clear

	* Create variable to show RI Survey date
	gen ri_survey_date=mdy(${RI_DATE_MONTH}, ${RI_DATE_DAY}, ${RI_DATE_YEAR})
	format %td ri_survey_date
	label variable ri_survey_date "Date of RI survey"

	* Create variable to show they were part of the Child Survey
	gen child_survey=1
	label variable child_survey "Participated in Child Survey"
	
	* drop if the child is no longer alive
	drop if b5==0
	
	
	save "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", replace
	
	* Create line number variable for merging purposes
	gen ${HM_LINE}= ${RI_LINE} 
	label variable ${HM_LINE} "line number"

	* Rename the STRATUM_ID variable so a merge can occur with Household members and Household list datasets
	if "$STRATUM_ID"=="shstate" {
		rename sstate	$STRATUM_ID
	}
	
	else {
		rename `=substr("$STRATUM_ID",2,.)' $STRATUM_ID //rename since the variable names vary from dataset
	}
	rename `=substr("$HH_ID",2,.)' $HH_ID //rename since the variable names vary from dataset
	rename `=substr("$CLUSTER_ID",2,.)' $CLUSTER_ID //rename since the variable names vary from dataset
	
	* Rename reponsdent TT_LINE number for merging purposes
	gen h$RESPONDENT_LINE=$RESPONDENT_LINE
	label variable h$RESPONDENT_LINE "TT line number repeated for merging purposes to uniquely identify each person"

	* Determine if each persone can be uniquely identified
	sort $STRATUM_ID $CLUSTER_ID $HH_ID h$RESPONDENT_LINE $HM_LINE
	bysort $STRATUM_ID $CLUSTER_ID $HH_ID h$RESPONDENT_LINE $HM_LINE: gen not_unique=_n
	gen do_not_keep=1 if not_unique>1
	replace do_not_keep=1 if not_unique[_n+1]>1 & not_unique[_n+1]!=.	
	drop if do_not_keep==1
	
	* Rename caseid so it can be merged with Household members and Household list datasets
	rename caseid hhid

	* Merge in Household Member data
	merge 1:1 hhid $STRATUM_ID $HH_ID $CLUSTER_ID $HM_LINE using "${DHS_PR_DATA}"

	drop _merge

	save, replace

	* Merge in Household data
	merge m:1 hhid $STRATUM_ID $HH_ID $CLUSTER_ID h$RESPONDENT_LINE using "${DHS_HR_DATA}" //Merge with HM

	drop _merge

	save, replace

}

********************************************************************************
********************************************************************************
********************************************************************************
* If RI (child) survey was NOT completed but TT (womens) survey was completed

if $RI_SURVEY !=1 & $TT_SURVEY==1 {
	use "${DHS_IR_DATA}", clear

	save "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", replace

	* Create variable to indicate Womens Survey
	gen tt_survey=1 
	label variable tt_survey "Participated in Womens/TT survey"


	* Create line number variable for merging purposes
	gen ${HM_LINE}= ${TT_LINE} 
	label variable ${HM_LINE} "line number"

	* Rename the STRATUM_ID variable so a merge can occur with Household members and Household list datasets
	if "$STRATUM_ID"=="shstate" {
		rename sstate	$STRATUM_ID
	}
	
	else {
		rename `=substr("$STRATUM_ID",2,.)' $STRATUM_ID //rename since the variable names vary from dataset
	}
	rename `=substr("$HH_ID",2,.)' $HH_ID //rename since the variable names vary from dataset
	rename `=substr("$CLUSTER_ID",2,.)' $CLUSTER_ID //rename since the variable names vary from dataset
	
	* Rename caseid so it can be merged with Household members and Household list datasets
	rename caseid hhid

	* Merge in Household Member data
	merge 1:1 hhid $STRATUM_ID $HH_ID $CLUSTER_ID $HM_LINE using "${DHS_PR_DATA}"

	drop _merge

	save, replace
	
	* Merge in Household data
	merge m:1 hhid $STRATUM_ID $HH_ID $CLUSTER_ID using "${DHS_HR_DATA}" //Merge with HM
	
	* Create variable to show the date of TT survey
	gen tt_survey_date=mdy(${HH_DATE_MONTH}, ${HH_DATE_DAY}, ${HH_DATE_YEAR}) if tt_survey==1
	format %td tt_survey_date
	label variable tt_survey_date "Date of TT survey"
	save, replace


	drop _merge

	save, replace


}
