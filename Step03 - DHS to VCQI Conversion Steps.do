/**********************************************************************
Program Name:               Step03 - DHS to VCQI Conversion Steps 
Purpose:                    Rename variables and create VCQI required variables 
*													
Project:                    Q:\- WHO DHS VCQI-compatible\DHS manuals
Date Created:    			2016-04-28
Author:         Mary Kay Trimner
Stata version:    14.0
********************************************************************************/
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name			What Changed
* 2016-10-12			Dale			Fixed typo when SIA is off
* 2016-10-12			Dale			Do NOT use mother's DOB for eligibility
*										if they did a TT survey

********************************************************************************

use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear

*********************************************************************************
*********************************************************************************
* Rename all variables to have an DHS_#_ in front of the name to indicate DHS data
foreach v of varlist _all {
	rename `v' DHS_${DHS_NUM}_`v'
}

save, replace

********************************************************************************
* Create variables that use variables from across all datasets.
* Create overall dob variable to determine eligibility

local vlistMONTH
local vlistDAY
local vlistYEAR

foreach d in MONTH DAY YEAR {
	local vlist`d'_ri
	local vlist`d'_tt
	
	if ${RI_SURVEY}==1  { 
		* Currently this will also include the SIA participants as they can be found in RI survey...
		local vlist`d'_ri ${CHILD_DOB_HIST_`d'}
	}
	
	
	* Do NOT use the mother's birthday for eligibility...commented out for now...
	if ${TT_SURVEY}==1 {
		*local vlist`d'_tt ${MOTHER_DOB_`d'}
	}

	if $HH_DOB == 1 {
		local vlist`d'_hh ${DATE_OF_BIRTH_`d'}
	}
		
	local vlist`d' `vlist`d'_ri', `vlist`d'_tt', `vlist`d'_hh'
	
	* The local will need to be reformatted
	* If any value was not provided there will be an empty spot in the local. Remove the blank spot...
	if strpos("`vlist`d''",", ,")>0 {
		local vlist`d' `=subinstr("`vlist`d''"," ,","",.)'
	}
	
	* If it ends with a "," this will need to be removed
	if "`=substr("`vlist`d''",-1,1)'"=="," { 
		*  replace "," with missing "." if last character in string is ","
		local vlist`d' `=substr("`vlist`d''",1,length("`vlist`d''")-1)'
		
	}

	di "`vlist`d''"
	
	
	foreach v in `=subinstr("`vlist`d''",","," ",.)' { 
		* replace "," with space " " for purposes of doing replacement
		replace `v'=. if inlist(`v',99,98,97,9999,9998,9997) 
	}

	di "`vlist`d''"
	
	
	gen dob_`d'=.
	label variable dob_`d' "`d' used to determine eligibility"

	if wordcount(subinstr("`vlist`d''",","," ",.)) >= 2 { 
		* If there are more than 2 values provided, use the minimum value
		replace dob_`d'=min(`vlist`d'')
	}
	else if wordcount(subinstr("`vlist`d''",","," ",.)) == 1 { 
		* else if there is only 1 value, use that as the date component
		replace dob_`d'=`=subinstr("`vlist`d''",",","",.)'
	}
}


* if have a dob_MONTH and dob_YEAR for date of birth and dob_DAY is missing, replace day with 1 for purposes of determining age and survey eligibility.
replace dob_DAY=1 if !missing(dob_MONTH) & !missing(dob_YEAR) & missing(dob_DAY) 
//Change the above in DHS...  does not need to be separate...

tab dob_DAY,m

gen dob_for_eligibility=mdy(dob_MONTH, dob_DAY, dob_YEAR)
format %td dob_for_eligibility
label variable dob_for_eligibility "DOB to determine which survey people are eligible for"

* Create variable to show how old participant is in years and months
gen age_years=.
label variable age_years "Participant age in years"

gen age_months=.
label variable age_months "Participant age in months"

* Replace age_years/months is equal to the appropriate globals in the correct order based on survey...
if $RI_SURVEY==1 {
	if "$CHILD_AGE_YEARS"!="" {
		replace age_years=$CHILD_AGE_YEARS if DHS_${DHS_NUM}_child_survey==1 
	}
	if "$CHILD_AGE_MONTHS"!="" {
		replace age_months=$CHILD_AGE_MONTHS if DHS_${DHS_NUM}_child_survey==1  
	}
	replace age_years=int((DHS_${DHS_NUM}_ri_survey_date-dob_for_eligibility)/365.25) if missing(age_years) ///
						& DHS_${DHS_NUM}_child_survey==1 & !missing(DHS_${DHS_NUM}_ri_survey_date) & !missing(dob_for_eligibility) 
	replace age_months=mofd(DHS_${DHS_NUM}_ri_survey_date)-mofd(dob_for_eligibility) if missing(age_months) & ///
						DHS_${DHS_NUM}_child_survey==1 & !missing(DHS_${DHS_NUM}_ri_survey_date) & !missing(dob_for_eligibility)
}

if $TT_SURVEY==1 {
	if "$MOTHER_AGE_YEARS"!="" {
		replace age_years=$MOTHER_AGE_YEARS if DHS_${DHS_NUM}_tt_survey==1 & !missing(${MOTHER_AGE_YEARS}) 
	}
	replace age_years=int((DHS_${DHS_NUM}_tt_survey_date-dob_for_eligibility)/365.25) if DHS_${DHS_NUM}_tt_survey==1 & ///
						missing(age_years) & !missing(DHS_${DHS_NUM}_tt_survey_date) & !missing(dob_for_eligibility) 
	replace age_months=mofd(DHS_${DHS_NUM}_tt_survey_date)-mofd(dob_for_eligibility) if DHS_${DHS_NUM}_tt_survey==1 & ///
						missing(age_months) & !missing(DHS_${DHS_NUM}_tt_survey_date) & !missing(dob_for_eligibility)
}

if "${AGE_YEARS}"!="" {
	replace age_years=$AGE_YEARS if missing(age_years) //if age_years could not be calculated, use variable provided for AGE_YEARS if populated
}

if "${AGE_MONTHS}"!=""  {
	replace age_months=$AGE_MONTHS if missing(age_months) // if age_months could not be calculated, use the variable provided for AGE_MONTHS if populated
}

* Replace age_months equals the age in years*12 months to get the count of months if still missing age_months
replace age_months=int(age_years*12) if missing(age_months) & age_years!=. 


*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
* Create variables for HH dataset

* Generate VCQI variable HH01- Stratum ID based on user inputs for $STRATUM
clonevar HH01=$STRATUM_ID
label variable HH01 "Stratum ID"
save, replace
	
****************************************************************
* VCQI Variable HH02 will be contingent on if HH01 has a value label
	if ${STRATUM_ID}==${STRATUM_NAME} {
		describe HH01, replace

			if !missing(vallab) { 
				use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear
				decode (HH01), generate (HH02)
				save, replace
			}
			else if missing(vallab) {
				use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear
				gen HH02=HH01
				save, replace
			}
	}
	else if ${STRATUM_ID}!=${STRATUM_NAME} {
		clonevar HH02=$STRATUM_NAME
	}
	
use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear
label variable HH02 "Stratum name"

* Remove the value label from HH01
label value HH01

****************************************************************
* Create variable for VCQI HH03
clonevar HH03=$CLUSTER_ID
save, replace
****************************************************************
* Create HH04 Cluster Name... if no value label on HH03, just use HH03 values
	if ${CLUSTER_ID}==${CLUSTER_NAME} {
		describe HH03, replace

			if !missing(vallab) { 
				use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear
				decode (DHS_${DHS_NUM}_hh1), generate (HH04)
				save, replace
			}
			else if missing(vallab) {
				use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear
				gen HH04=HH03
				save, replace
			}
	}
	else if ${CLUSTER_ID}!=${CLUSTER_NAME} {
		clonevar HH04=${CLUSTER_NAME}
	}
	
use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear
label variable HH04 "Cluster name"

* Remove the value label from HH03
label value HH03

****************************************************************
* Create variable for HH14 household number
clonevar HH14=$HH_ID

****************************************************************
* Create VCQI Variable HH12
gen HH12=1 
	replace HH12=2 if inlist(${OVERALL_DISPOSITION},6,7,8,9) //Dwelling vacant/address not a dwelling, dwelling destroyed, dwelling not found

label variable HH12 "Occupied: Does this structure contain any households?"
label define yesno 1 "Yes" 2 "No", replace
label value HH12 yesno

****************************************************************
* Create VCQI Variable HH18
gen HH18=. 
		replace HH18=1 if inlist(${OVERALL_DISPOSITION},1) //Completed
		replace HH18=3 if inlist(${OVERALL_DISPOSITION},2,3,4,6,7,8,9,.) //No member home/ no competent respondent at home, Entire household absent for extended time
																	 //Postponed/Dwelling vacant/address not a dwelling, dwelling destroyed, dwelling not found, Other
		replace HH18=4 if inlist(${OVERALL_DISPOSITION},5) //Refused

		label define enumerate 1 "Resident" 2 "Neighbor" 3 "Unable to Enumerate" 4 "Refused", replace
label value HH18 enumerate
label variable HH18 "Is the data from a resident, or a neighbor?"

*******************************************************************************************
	* Create variables to show which survey participant was eligible for
if $RI_SURVEY==1 {	
	gen ri_eligible=age_months >= $RI_MIN_AGE & age_months <= $RI_MAX_AGE
	label variable ri_eligible "Is the participant eligible for RI survey?"
	label define noyes 0 "No" 1 "Yes", replace
	label value ri_eligible noyes
}

if $SIA_SURVEY==1 {
	foreach v in `=upper("${SIA_LIST}")' {
		gen sia_`=lower("`v'")'_eligible=(age_months >= ${SIA_MIN_AGE_`v'}) & (age_months <= ${SIA_MAX_AGE_`v'})
		label variable sia_`=lower("`v'")'_eligible "Is the participant eligible for SIA `v' survey?"
		label define noyes 0 "No" 1 "Yes", replace
		label value sia_`=lower("`v'")'_eligible noyes
	}
}

if $TT_SURVEY==1 {
	* If child birthdate is not provided, set all participants to eligible
		gen tt_eligible=1 if !missing($TT_DISPOSITION) 
		gen tt_last_birth=${TT_LAST_BIRTH_MONTHS} // Set to missing if not able to calculate the date.
	
		label variable tt_eligible "Is the participant eligible for TT survey- Did they give birth in the last 2 years?"
		label define noyes 0 "No" 1 "Yes", replace
		label value tt_eligible noyes
		
		label variable tt_last_birth "Months since last birth of child"

}

* Create HH23 variable for HH dataset
	if $RI_SURVEY==1 {
		egen HH23=total(ri_eligible)
	} 
	else {
		gen HH23=0
	}
label variable HH23 "# of Eligible Respondents: 12-23 Months"
 
* Create HH24 variable for HH dataset
	if $TT_SURVEY==1 {
		egen HH24=total(tt_eligible)
	}
	else {
		gen HH24=0
	}
	
label variable HH24 "# of Eligible Respondents: Gave Live Birth in Last 12 Months"

* Create HH25 variable for HH dataset for each SIA survey
	if $SIA_SURVEY==1 {
		foreach v in `=lower("${SIA_LIST}")' {
			egen HH25_`v'=total(sia_`v'_eligible)
			label variable HH25_`v' "# of Eligible Respondents: Post-Campaign Survey"
		}
	}
	else {
		gen HH25=0
		label variable HH25 "# of Eligible Respondents: Post-Campaign Survey"
		
	}

save, replace 
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
* Create HM variables

* HM01, HM02, HM03, HM04 HM09 will copy the variables that were created for the HH dataset
clonevar HM01=HH01
clonevar HM02=HH02
clonevar HM03=HH03
clonevar HM04=HH04
clonevar HM09=${HH_ID}
clonevar HM22=${HM_LINE}

* Create variables for HM27(sex), HM29(age years) and HM30(age months) 
* using the previously calculated age_years and age_months even if populated with 1 for day as this will not impact these numbers
clonevar HM27=${SEX}

* replace the values to missing if not male or female
replace HM27=. if !inlist(HM27,1,2)


clonevar HM29=age_years
clonevar HM30=age_months

* Create variables for HM31(RI Eligible), HM32(RI Selected), HM36(TT Eligible), HM37(TT Selected), HM41(SIA Eligible), HM42(SIA Selected),

	if $RI_SURVEY==1 {
		clonevar HM31=ri_eligible

		gen HM32=DHS_${DHS_NUM}_child_survey==1
	}
	else {
		gen HM31=2
		gen HM32=.
	}
	
	label variable HM31 "Eligible for RI Coverage Survey"
	label variable HM32 "Selected for RI Coverage Survey"
	label value HM31 yesno
	label value HM32 yesno

	if $TT_SURVEY==1 {
		clonevar HM36=tt_eligible

		gen HM37=DHS_${DHS_NUM}_tt_survey==1 
	}
	else {
		gen HM36=2
		gen HM37=.
	}
	
	label variable HM36 "Eligible for TT Survey"
	label variable HM37 "Selected for TT Survey"
	label value HM36 yesno
	label value HM37 yesno

	if $SIA_SURVEY==1 {
	
		foreach v in `=lower("${SIA_LIST}")' {
			clonevar HM41_`v'=sia_`v'_eligible
			label variable HM41_`v' "Eligible for Post-SIA `=upper("`v'")' Survey"
			
			if "${SIA_`=upper("`v'")'}"!="" {
				capture confirm variable ${SIA_`=upper("`v'")'} 
					if !_rc {
						gen HM42_`v'=!missing(${SIA_`=upper("`v'")'}==1)
					}
					else {
						gen HM42_`v'=HM41_`v'==1
					}
			}
			if "${SIA_`=upper("`v'")'}"=="" {
				gen HM42_`v'=HM41_`v'==1
			}
			label variable HM42_`v' "Selected for Post-SIA `=upper("`v'")' Survey"
		}
	}
	else {
		gen HM41=2
		label variable HM41 "Eligible for Post-SIA Survey"
		label value HM41 yesno
		
		gen HM42=-.
		label variable HM42 "Selected for Post-SIA Survey"
		label value HM42 yesno
	}
	
		
		


* Create variable for HM19 overall disposition code 
gen HM19=.
		replace HM19=4 if inlist(${OVERALL_DISPOSITION},1) //Completed
		replace HM19=1 if !inlist(${OVERALL_DISPOSITION},1,5) //No member home/ no competent respondent at home, Entire household absent for extended time
																	 //Dwelling vacant/address not a dwelling, dwelling destroyed, dwelling not found, Other
		replace HM19=3 if inlist(${OVERALL_DISPOSITION},5) //Refused

label define disposition 1 "Return later, no one home" 2 "Come back later; interview started but could not complete" 3 "Refused; someone is home but refused to participate" 4 "Complete; collected all necessary information", replace
label value HM19 disposition
label variable HM19 "Disposition Code: Visit 1"

* Create HM33 (RI), HM38(TT) and HM43 (SIA) disposition codes
label define survey_disposition 2 "Come back later; caregiver not available" 3 "Refused interview for this respondent" 4 "Completed interview", replace
gen HM33=.
label variable HM33 "Disposition code for RI Survey: Visit 1"
gen HM38=.
label variable HM38 "Disposition code for TT Survey: Visit 1"

gen HM43=.
label variable HM43 "Disposition code for Post-SIA Survey: Visit 1"


foreach v in HM33 HM38 HM43 {
	if "`v'"=="HM33" {
		local s RI
	}
	else if "`v'"=="HM38" {
		local s TT
	}
	else if "`v'"=="HM43" {
		local s SIA
	}
	label value `v' survey_disposition
	
* NOTE: Keep as missing if there is no value in the survey specific disposition
	capture confirm variable ${`=upper("`s'")'_DISPOSITION}
	if !_rc {

		replace `v'=4 if inlist(${`=upper("`s'")'_DISPOSITION},1) //Completed
		replace `v'=2 if !inlist(${`=upper("`s'")'_DISPOSITION},1,4) //No member home/ no competent respondent at home, Entire household absent for extended time
																	 //Dwelling vacant/address not a dwelling, dwelling destroyed, dwelling not found, Other
		replace `v'=3 if inlist(${`=upper("`s'")'_DISPOSITION},4) //Refused
	}
}	

* Create variables missing for HM20, HM21, HM34, HM35 HM39, HM40, HM44 HM45 disposition codes for additional visits
* These are set to missing because based on the dataset we cannot tell if follow-up visits occurred
foreach v in HM20 HM21 HM34 HM35 HM39 HM40 HM44 HM45 {
	gen `v'=.
}
label variable HM20 "Disposition Code: Visit 2"
label variable HM21 "Disposition Code: Visit 3"
label variable HM34 "Disposition code for RI Survey: Visit 2"
label variable HM35 "Disposition code for RI Survey: Visit 3"
label variable HM39 "Disposition code for TT Survey: Visit 2"
label variable HM40 "Disposition code for TT Survey: Visit 3"
label variable HM44 "Disposition code for Post-SIA Survey: Visit 2"
label variable HM45 "Disposition code for Post-SIA Survey: Visit 3"

save, replace 
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
* Create the CM variables
* If there is no value for the global PROVINCE_ID or the value is equal to 1, create the variable
if "$PROVINCE_ID"=="" | "$PROVINCE_ID"=="1" {
	gen province_id=1
	label variable province_id "Level2"
	global PROVINCE_ID	province_id
}
else {
	* Create province_id VCQI variable
	clonevar province_id=$PROVINCE_ID
}

* Create variable for urban_cluster
clonevar urban_cluster=$URBAN_CLUSTER

* Create psweight_1year variable
clonevar psweight_1year=$PSWEIGHT_1YEAR

* Create psweight_sia variable
clonevar psweight_sia=$PSWEIGHT_SIA

save, replace
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
if $RI_SURVEY==1 {
	* Create RI variables and RIHC variables

	* Create variable RI01 Stratum ID number
	clonevar RI01=HH01

	* Create variable RI03 Cluster ID number
	clonevar RI03=HH03

	* Create variable RI11 Household ID
	clonevar RI11=HH14

	* Create RI12 Individual Number
	*gen RI12=string(${RI_LINE}) + "_"  + string(${TT_LINE})
	*label variable RI12  "Unique number for child using the Respondent's line number and child line number"
	gen RI12 = ${HM_LINE}
	label variable RI12 "Respondent line number from HM dataset"
	* Create RI26 Vaccination Card ever received?
		gen RI26=.
		
		* Replace RI26=1 if ${CARD_SEEN} equals 1,2,3 as these indicate there was a card 1-Yes, Seen| 2 - Yes, not seen | 3 No longer has card
		replace RI26=1 if inlist(${CARD_SEEN},1,2,3)
		
		* Replace RI26=2 (No) if $CARD_SEEN==0 (No card)
		replace RI26=2 if ${CARD_SEEN}==0

		* Replace all other values to missing
		replace RI26=. if !inlist(RI26,1,2,99)
		
	
	*label to correspond to VCQI
	label define yesno 1 "Yes" 2 "No" 99 "Do Not Know", replace
	label value RI26 yesno
	label variable RI26 "Ever receive vaccination card?"
	
	
	* Create RI27 Vaccination Card seen
	clonevar RI27=${CARD_SEEN}
	
	* Replace the idk and other values with "." 
	replace RI27=. if !inlist(RI27,1,2) //respondents with value 3 No card, should not be included in this question they will have a response of 2 in RI26
	
	* Relabel RI27 so labels align with VCQI
	label define card_seen 1 "Yes, Card Seen" 2 "No, Card Not Seen", replace
	label value RI27 card_seen
	

	**********************************************************************************
	*Create dob for child history and card register if RIHC records sought
	local g history card 

	foreach v in `g' {
		if "`v'"=="history" {
			local i HIST
		}
		else if "`v'"=="card" {
			local i CARD
		}
			
		foreach d in m d y {
			if "`d'"=="m" {
				local c MONTH
			}
			else if "`d'"=="d" {
				local c DAY
			}
			else if "`d'"=="y" {
				local c YEAR
			}
		
			gen dob_date_`v'_`d'=.
			label variable dob_date_`v'_`d' "Date of Birth from `v' - `c'"
			
			if "${CHILD_DOB_`i'_`c'}"!="" {
				replace dob_date_`v'_`d'=${CHILD_DOB_`i'_`c'} 
				replace dob_date_`v'_`d'=. if inlist(dob_date_`v'_`d',44,4444,66,6666)
			}
		}
	}

	* If no card dob data provided, replace with history dob information 
	foreach d in m d y {
		replace dob_date_card_`d'=dob_date_history_`d' if missing(dob_date_card_`d') & !missing(dob_date_history_`d')
		
	}

	* Create all card and register variables
	local s card

	foreach v in `s' {
		if "`v'"=="card" {
			local b "CARD"
		}
		foreach d in `=lower("${RI_LIST}")' {
			foreach m in m d y {
				if "`m'"=="m" {
					local i MONTH
				}
				else if "`m'"=="d" {
					local i DAY
				}
				else if "`m'"=="y" {
					local i YEAR
				}
				
				* Create each date variable
				gen `d'_date_`v'_`m'=${`=upper("`d'")'_DATE_`b'_`i'}
				label variable `d'_date_`v'_`m' "`d' date on `v' -`i'"

			}
			
			* Create tick marks for each dose 
			gen `d'_tick_`v'=.
			replace `d'_tick_`v'=1 if inlist(`d'_date_`v'_m,44,4444) | inlist(`d'_date_`v'_d,44,4444) | inlist(`d'_date_`v'_y,44,4444)
			
			*also replace tick to be 1 if $`v' is set to 3- Vacc marked on card
			replace `d'_tick_`v'=1 if ${`=upper("`d'")'}==3
			
			label variable `d'_tick_`v' "`d' tick mark on `v'"
			

		}
	}


	* Create variable for dose history
	foreach d in `=upper("${RI_LIST}")' {
		gen `=lower("`d'")'_history=.
		label variable `=lower("`d'")'_history "`d' - history"
		label value `=lower("`d'")'_history yesno
		
		* replace to a "no" or "do not know" value if history is set to that
		replace `=lower("`d'")'_history=1 if ${`d'}==2
		replace `=lower("`d'")'_history=99 if ${`d'}==8
		replace `=lower("`d'")'_history=2 if ${`d'}==0
		replace `=lower("`d'")'_history=. if !inlist(`=lower("`d'")'_history,1,2,99)
		
	}
	
	* Create variable for bcg_scar_history if bcg is part of RI_LIST
	if "$BCG_SCAR"!="" {
		gen bcg_scar_history=$BCG_SCAR
		label variable bcg_scar_history "BCG scar seen"
	}
	else {
		if "$BCG_SCAR"=="" {
			if strpos("`=lower("$RI_LIST")'","bcg")!=0 {
				gen bcg_scar_history=.
			label variable bcg_scar_history "BCG scar seen"
			}
		}
	}

	* Replace dates with missing values if set to 0 |44 |4444 |97| 9997 | 9999 | 99 |98 |9998
	local s card

	foreach g in `s' {
		di "`s'"
		foreach v in `=lower("${RI_LIST}")' {
			foreach m in m d y {
				replace `v'_date_`s'_`m'=. if inlist(`v'_date_`s'_`m',0,44,4444,97,9997,99,9999,98,9998)
			}
		}
	}
}

save, replace

*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************

if $SIA_SURVEY==1 {
* Create variables for SIA dataset SIA01, SIA03 SIA11, SIA12, SIA20

	* Stratum ID
	clonevar SIA01=HH01
	
	* Cluster ID
	clonevar SIA03=HH03
	
	*Household ID
	clonevar SIA11=HH14
	
	*Individual ID
	clonevar SIA12=RI12
	
	* Did the child receive the measles/rubella vaccine during the recent campaign?
	* Need to create a variable for each campaign
	foreach v in `=lower("${SIA_LIST}")' {
		gen SIA20_`v'=${SIA_`=upper("`v'")'}
		
		* Replace values to align with VCQI
		replace SIA20_`v'=99 if inlist(SIA20_`v',8)
		replace SIA20_`v'=3 if inlist(SIA20_`v',0)
		replace SIA20_`v'=. if !inlist(SIA20_`v',1,2,99)
		replace SIA20_`v'=2 if SIA20_`v'==1 & RI27==2
		replace SIA20_`v'=1 if SIA20_`v'==1 & RI27==1
		label variable SIA20_`v' "Did the child receive the `=upper("`v'")' vaccine during the recent campaign? "
		
		label define sia_card 1 "Yes, Card Seen" 2 "Yes, Card Not Seen" 3 "No" 99 "Do Not Know", replace
		label value SIA20_`v' sia_card
		

	}


	* Create these variables set to "do not know" as they do not exist in the DHS surveys
	* And they cannot take on a value of missing.
	foreach v in 27 {
		gen SIA`v'=99
	}
	
	* Create these variables set to "missing" as they do not exist in the DHS surveys.
	foreach v in 21 22 28 29 30 31 32 33 {
		gen SIA`v'=.
	}
	
	label variable SIA21 "Did child receive a campaign card?"
	label variable SIA22 "Was the child's finger marked?"
	label variable SIA27 "Had the child received measles vaccine before campaign?"
	label variable SIA28 "Date of 1st measles Vaccination, if record available"
	label variable SIA29 "1st measles vaccination recorded with a tick mark"
	label variable SIA30 "Date of 2nd measles Vaccination, if record available"
	label variable SIA31 "2nd measles vaccination recorded with a tick mark?"
	label variable SIA32 "Date of 1st measles campaign vaccination"
	label variable SIA33 "Date of 2nd measles vaccination"

	save, replace
}

*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************

if $TT_SURVEY==1 {
* Create variables for TT dataset TT01, TT03, TT09, TT11, TT12, TT16, TT27, TT30, TT31, TT32, TT34, TT35
* TT36, TT37, TT38, TT39, TT40, TT41, TT42

	* Stratum Id
	clonevar TT01=HH01
	
	* Cluster ID
	clonevar TT03=HH03
	
	*Start date of interview
	clonevar TT09=DHS_${DHS_NUM}_tt_survey_date
	
	*Household ID
	clonevar TT11=HH14
	
	* Individual mother ID
	clonevar TT12 =${TT_LINE}
	
	* Age of Mother in years
	clonevar TT16=age_years
	
	* Do you have a card or document with vaccinations
	gen TT27=.
	label variable TT27 "Do you have a card or other documents with your own immunizations listed?  May I see it?"
	label value TT27 yesno
	
	* The TT dose dates are not provided in DHS survey.
	* Create these variables and set them to missing
	local i 1
	
	foreach v in TT30 TT31 TT32 TT33 TT34 TT35 {
		gen `v'=.		
		label variable `v' "TT`i' dose date"
		local i `=`i' + 1'
	}
	
	* TT36 - TT injection received during pregnancy
	* TT37 - how many times TT received
	
	gen TT36=.
	
	* Replace values to align with VCQI
	replace TT36=2 if ${NUM_TT_PREGNANCY}==0
	replace TT36=1 if inlist(${NUM_TT_PREGNANCY},1,2,3,4,5,6,7) 
	replace TT36=99 if ${NUM_TT_PREGNANCY}==8
	replace TT36=. if !inlist(TT36,1,2,99) //Replace all other values to missing
	
	label define yesnodnk 1 "Yes" 2 "No" 99 "Do Not Know", replace
	label value TT36 yesnodnk 
	label variable TT36 "Did you receive a TT dose during last pregnancy?"
	
	clonevar TT37=${NUM_TT_PREGNANCY}
	
	* Replace values to align with VCQI
	replace TT37=99 if TT37==8
	replace TT37=3 if TT37>=3 & TT37!=99 & !missing(TT37)
	replace TT37=. if !inlist(TT37,0,1,2,3,99) // Replace all other values to missing
	
	label define dnk 99 "Do Not Know", replace
	label value TT37 dnk
	
	* TT38 and TT39 are not provided in any DHS surveys... are included in the Anytime questions TT40 and TT41
	* These will be set to missing
	gen TT38=.
	label variable TT38 ///
	"During a previous pregnancy (previous to the pregnancy with (name)), did you receive any injection in the arm or shoulder to prevent the baby from getting tetanus after birth?"
	
	gen TT39=.
	label variable TT39 ///
	"How many times did you receive this injection in the arm (tetanus vaccination) during your pregnancies previous to the pregnancy with (name)?"
	
	* TT40- TT received at any time during life
	* TT41- Number of times TT received
	* TT42- How many years since last TT vaccination
	gen TT40=.
		
	replace TT40=2 if ${NUM_TT_ANYTIME}==0
	replace TT40=1 if inlist(${NUM_TT_ANYTIME},1,2,3,4,5,6,7) 
	replace TT40=99 if ${NUM_TT_ANYTIME}==8
	replace TT40=. if !inlist(TT40,1,2,99) //Replace all other values to missing
	
	label define yesnodnk 1 "Yes" 2 "No" 99 "Do Not Know", replace
	label value TT40 yesnodnk 
	label variable TT40 "Did you receive a TT dose any time prior to last pregnancy?"
	
	clonevar TT41=${NUM_TT_ANYTIME}
	
	* Replace values to align with VCQI
	replace TT41=99 if TT41==8
	replace TT41=7 if TT41>=7 & TT41!=99 & !missing(TT41)
	replace TT41=. if !inlist(TT41,0,1,2,3,4,5,6,7,99) // Replace all other values to missing
	
	label define dnk 99 "Do Not Know", replace
	label value TT41 dnk
	
	gen TT42=.
	replace TT42=${YEARS_SINCE_LAST_TT}
			
	* Replace values to align with VCQI
	replace TT42=. if TT42>40 //change the word missing to an actual missing value
	label define tt_years 98 "Never had one" 99 "Do Not Know", replace
	label value TT42 tt_years
	label variable TT42 "When did you receive your last tetanus vaccination (How many years ago)?"
	
	* If missing TT42 but received TT during last pregnancy, determine the years since last dose by 
	replace TT42=int(tt_last_birth/12) if !missing(tt_last_birth) & missing(TT42) & TT36==1 
	
	* If DHS num==3, there are two additional variables that can be used TT7m and TT7y... use this to determine date for variable TT42 if missing
	if "$LAST_TT_MONTH"!="" & "$LAST_TT_YEAR"!=""{
		gen last_tt_dose=mdy(${LAST_TT_MONTH}, 1, ${LAST_TT_YEAR})
		format %td  last_tt_dose
		label variable last_tt_dose "Date of last tt dose if month and year provided"
		
		gen years_since_tt=int((DHS_${DHS_NUM}_tt_survey_date-last_tt_dose)/365.25)
		label variable years_since_tt "Number of years between last tt dose and survey date"
		
		replace TT42=years_since_tt if missing(TT42) & !missing(years_since_tt)
	}
	
}

save, replace
