/**********************************************************************
Program Name:               Step02 - DHS to VCQI Conversion Steps 
Purpose:                    Checks to make sure all necessary globals are populated 
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
* 2016-10-12			Dale			Added CHILD_IS_ALIVE and 
*										CHILD_BORN_ALIVE to varlist

********************************************************************************

* The below globals are required for all DHS to VCQI Conversion

foreach v in RI_SURVEY SIA_SURVEY TT_SURVEY HH_DOB DHS_NUM {
		if "$`v'"=="" {
			di as error "Global macro `v' must be defined to complete the any analysis"
		}
}

* Check to see that for PROVINCE_ID it is populated to 1 or a variable name.
* If it is a variable name, verify that the variable exists and change the global to reflect renamed variables.
if "$PROVINCE_ID"=="" {
		di as error "Global macro PROVINCE_ID must be defined to complete the any analysis"
}
else {
	capture confirm variable ${PROVINCE_ID}
		if !_rc {
			global PROVINCE_ID 	DHS_${DHS_NUM}_${PROVINCE_ID}	
		}
		else {
			if "$PROVINCE_ID"!="1" {
				di as error ///
				"Variable ${PROVINCE_ID} provided in global macro PROVINCE_ID does not exist" //Let the user know if a variable does not exist in dataset
			}
		}
}

* Level3id is a little different and may have two variables. You will need to check each variable
* Check to make sure the global is populated
if "$LEVEL_3_ID"=="" {
	di as error "Global macro LEVEL_3_ID must be defined to complete the any analysis"
}
else {
	foreach v in $LEVEL_3_ID {
		capture confirm variable `v'
			if !_rc {
				local l3list  `l3list' DHS_${DHS_NUM}_`v'	
			}
			else {
				di as error ///
				"Variable `v' provided in global macro LEVEL_3_ID does not exist" //Let the user know if a variable does not exist in dataset
			}
	}
	
	* Set the global to the new l3list
	global LEVEL_3_ID `l3list'
}

	
	
foreach v in STRATUM_ID STRATUM_NAME CLUSTER_ID CLUSTER_NAME HH_ID HH_DATE_MONTH ///
		HH_DATE_DAY HH_DATE_YEAR HM_LINE OVERALL_DISPOSITION PSWEIGHT_1YEAR ///		
		PSWEIGHT_SIA URBAN_CLUSTER SEX {			
	
	if "$`v'"=="" {
		di as error "Global macro `v' must be defined to complete the any analysis"
	}
	else {
		capture confirm variable ${`v'}
			if !_rc {
				global `v' 	DHS_${DHS_NUM}_${`v'}	
			}
			else {
				di as error ///
				"Variable ${`v'} provided in global macro `v' does not exist" //Let the user know if a variable does not exist in dataset
			}
	}
}

* These variables are not required in the surveys but if populated need to verify the variable exists
 foreach v in DATE_OF_BIRTH_MONTH DATE_OF_BIRTH_YEAR DATE_OF_BIRTH_DAY AGE_YEARS DATE_OF_BIRTH AGE_MONTHS ///
				CHILD_AGE_MONTHS CHILD_AGE_YEARS CHILD_DOB_CARD_MONTH CHILD_DOB_CARD_DAY CHILD_DOB_CARD_YEAR LEVEL_4_ID ///
				MOTHER_DOB_DAY MOTHER_AGE_YEARS TT_LAST_BIRTH_MONTHS LAST_TT_MONTH LAST_TT_YEAR CHILD_IS_ALIVE CHILD_BORN_ALIVE {
			if "$`v'"!="" {
			capture confirm variable ${`v'}
				if !_rc {
					global `v' 	DHS_${DHS_NUM}_${`v'}	
				}
				else {
					di as error ///
					"Variable ${`v'} provided in global macro `v' does not exist" //Let the user know if a variable does not exist in dataset
				}
		}
}
			
	

if $RI_SURVEY==1 {

* Check that all non-variable globals are populated if required
	foreach v in RI_MIN_AGE RI_MAX_AGE RI_LIST {
		if "$`v'"=="" {
			di as error "Global macro `v' must be defined to complete the RI analysis"
		}
	}
		
	foreach v in RI_DISPOSITION CARD_SEEN ///
				  RI_DATE_MONTH RI_DATE_DAY RI_DATE_YEAR CHILD_DOB_HIST_MONTH CHILD_DOB_HIST_DAY ///
				  CHILD_DOB_HIST_YEAR RI_LINE RESPONDENT_LINE {
			  
		if "$`v'"=="" {
			di as error "Global macro `v' must be defined to complete the RI analysis"
		}
		else {
			capture confirm variable ${`v'}
				if !_rc {
					global `v' 	DHS_${DHS_NUM}_${`v'}	
				}
				else {
					di as error ///
					"Variable ${`v'} provided in global macro `v' does not exist" //Let the user know if a variable does not exist in dataset
				}
		}

	}
	
	* check all the history variables
	foreach v in `=upper("${RI_LIST}")' {
		if "${`v'}"=="" {
		di as error "Global macro `v' must be defined to complete the RI analysis"
			}
		else {
			capture confirm variable ${`v'}
				if !_rc {
					global `v' 	DHS_${DHS_NUM}_${`v'}	
				}
				else {
					di as error ///
					"Variable ${`v'} provided in global macro `v' does not exist" //Let the user know if a variable does not exist in dataset
				}
		}
	}
	
	* Check all date variables
	foreach v in `=upper("${RI_LIST}")' {
		foreach m in MONTH DAY YEAR {
			if "${`v'_DATE_CARD_`m'}"=="" {
				di as error "Global macro `v'_DATE_CARD_`m' must be defined to complete the RI analysis"
			}
			else {
				capture confirm variable ${`v'_DATE_CARD_`m'}
					if !_rc {
						global `v'_DATE_CARD_`m' 	DHS_${DHS_NUM}_${`v'_DATE_CARD_`m'}	
					}
					else {
						di as error ///
						"Variable ${`v'_DATE_CARD_`m'} provided in global macro `v'_DATE_CARD_`m' does not exist" //Let the user know if a variable does not exist in dataset
					}
			}
		}
	}
}
	
 if $SIA_SURVEY==1 {
 			
	if "$SIA_DISPOSITION"=="" & "$RI_DISPOSITION"!="" {
		* If missing SIA_DISPOSITION set it to the RI_DISPOSITION as they are the same survey
		global SIA_DISPOSTION $RI_DISPOSITION
	}
	*If RI_DISPOSITION is still missing then show as an error
	if "$SIA_DISPOSITION"=="" {
		di as error "Global macro SIA_DISPOSITION must be defined to complete the SIA analysis"
	}
	else {
		capture confirm variable ${SIA_DISPOSITION}
			if !_rc {
				global SIA_DISPOSITION	DHS_${DHS_NUM}_${SIA_DISPOSITION}	
			}
			else {
				di as error ///
				"Variable ${SIA_DISPOSITION} provided for global SIA_DISPOSITION does not exist"

			}
	}

	if "$SIA_LIST"=="" {
		di as error "Global macro SIA_LIST must be defined to complete the SIA analysis"
	}
				
	foreach v in `=upper("${SIA_LIST}")' {
		if "$SIA_`v'"=="" {
			di as error "Global macro SIA_`v' must be defined to complete the SIA analysis"
		}
		else {
			capture confirm variable ${SIA_`v'}
				if !_rc {
					global SIA_`v'	DHS_${DHS_NUM}_${SIA_`v'}	
				}
				else {
					di as error ///
					"Variable ${SIA_`v'} provided in global macro SIA_`v' does not exist" //Let the user know if a variable does not exist in dataset
				}
		
			foreach g in MIN MAX {
				if "${SIA_`g'_AGE_`v'}"=="" {
					di as error "Global macro SIA_`g'_AGE_`v' must be defined to complete the SIA analysis"
				}
			}
		}
	}
}
			
if $TT_SURVEY==1 {
	foreach v in TT_MIN_AGE TT_MAX_AGE  MOTHER_DOB {				 
		if "$`v'"=="" {
			di as error "Global macro `v' must be defined to complete the TT analysis"
		}
	}
	
	
	* For the globals that will be populated with variable values confirm the variables exist
	foreach v in TT_LINE MOTHER_DOB_MONTH MOTHER_DOB_YEAR NUM_TT_PREGNANCY ///
				NUM_TT_ANYTIME YEARS_SINCE_LAST_TT TT_DISPOSITION {
		if "$`v'"=="" {
			di as error "Global macro `v' must be defined to complete the TT analysis"
		}
		else if "$`v'"!="" {
			if "$`v'"!="1" {
			capture confirm variable ${`v'}
				if !_rc {
					global `v' 	DHS_${DHS_NUM}_${`v'}	
				}
				else {
					di as error ///
					"Variable ${`v'} provided in global macro `v' does not exist" //Let the user know if a variable does not exist in dataset
				}
			}
		}
	}

}

										
				 
	
				
				
