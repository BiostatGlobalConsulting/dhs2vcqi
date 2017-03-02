/**********************************************************************
Program Name:               VCQI Conversion and Global Macro List – DHS to VCQI  
Purpose:                    User populates the below globals and the values are used to conver the dataset to VCQI 
*							
Project:                    Q:\- WHO DHS VCQI-compatible\DHS manuals
Date Created:    			2016-06-08
Author:         Mary Kay Trimner
Stata version:    14.0
********************************************************************************/
* This program converts DHS survey data to VCQI compatible datasets. 
* Before running this program, you will need to convert the DHS survey data (SPSS Datasets) to a Stata dataset through StatTransfer
* All date components will need to be broken into 3 separate variables; month, day and year.

* Set maxvar so there are no issues with the size of the dataset
clear 				// Need to clear out any existing data to run the next command
clear mata		 	// Need to clear out mata to avoid errors.
set maxvar 32767	// Change maxvar to the largest possible value to avoid errors while importing data.

* The majority of the globals listed below are required in order to run this program.
* However, some are not needed but if populated can help provide additional information to the dataset. These will be noted as optional.

* Populate the below global with the version of DHS survey (Phase number) that is being used (example 4, 5, 6,7)
global DHS_NUM  

* Path where DHS to VCQI conversion programs are saved
global RUN_FOLDER Q:\- WHO DHS VCQI-compatible\Stata Programs

* Path where STATA will grab the original DHS datasets
global INPUT_FOLDER 
	
* Path where you would like STATA to put the new datasets that can be run through VCQI
global OUTPUT_FOLDER 
	
* Name of DHS Datasets that will be used to create the VCQI Datasets
global DHS_HR_DATA 	HR.dta //Household dataset (HR)
global DHS_PR_DATA 	PR.dta //Household list/member dataset (PR)
global DHS_IR_DATA 	IR.dta //Womens /TT dataset (IR)
global DHS_KR_DATA 	KR.dta //Child dataset/RI & SIA (KR)


********************************************************************************
********************************************************************************
********************************************************************************

*  The below global macros need to be defined to create HH, CM HM, RI, RIHC, SIA, TT DATASET
*  Populate with corresponding variable name 
*  Populate the below 5 globals with the variables from HR or PR datasets(begining with hv)

global STRATUM_ID 				hv024
global STRATUM_NAME				hv024
global CLUSTER_ID 				hv001
global CLUSTER_NAME 			hv001

* Household ID 
global HH_ID 					hv002

* The below are used to populate the levels of datasets that VCQI uses.
* They are not required but will be used to create level1 and level4 datasets if populated.
* Level 2 will be populated with PROVINCE_ID provided below
* Level 3 will be populated with STRATUM_ID provided above 
* You can edit the DHS to VCQI -levels of datasets program if you do not want to use these values for Level2 and Level3.
* If the below globals are not populated, you will need to edit the program DHS to VCQI -levels of datasets to create these datasets.

* You will also need to edit the program DHS to VCQI -levels if you want to change the order. Current order is _n by levelid.
* See user guide for specifics around each level

* Name of Nation to be used in LEVEL1 dataset name
global LEVEL1_NAME				DHS_TEST // OPTIONAL- If you do not populate you need to edit program to create the dataset

* Provide the variable for Province ID (Level2 name)
global PROVINCE_ID 				1		// OPTIONAL- If you do not populate you need to edit program to create the dataset

* Name of Level3 stratifier
global LEVEL_3_ID				hv024	//OPTIONAL- If you do not populate you need to edit program to create the dataset

* Names for level 4
global LEVEL_4_ID 				hv025	// OPTIONAL- If you do not populate you need to edit program to create the dataset
*
********************************************************************************
********************************************************************************
********************************************************************************

* * The below need to be defined to create HH DATASET

* Date of HH interview
global HH_DATE_MONTH 			hv006
global HH_DATE_DAY 				hv016
global HH_DATE_YEAR 			hv007

********************************************************************************
********************************************************************************
********************************************************************************

* * The below need to be defined to create HM DATASET

* House member line number in HM dataset
global HM_LINE 					hvidx // take from household member dataset (PR)

* Variable that provides the outcome of the overall survey
* Example completed, refused, incomplete
global OVERALL_DISPOSITION 		hv015


* Populate the below with the variable names that correspond to the global names
global SEX 						hv104 //take from household member dataset (PR)

* Set the below global if date of birth data was collected in the HH/HM survey 1==yes 0==NO
global HH_DOB					1
global DATE_OF_BIRTH_MONTH		hc30 	// OPTIONAL -can be blank if not available
global DATE_OF_BIRTH_YEAR		hc31 	// OPTIONAL -can be blank if not available
global DATE_OF_BIRTH_DAY		hc16 	// OPTIONAL -can be blank if not available
global AGE_YEARS 				hv105	// OPTIONAL -can be blank if not available
global AGE_MONTHS 				 		// OPTIONAL -can be blank if not available
	
********************************************************************************
********************************************************************************
********************************************************************************

* * The below need to be defined to create CM DATASET
* Provide the variable for the Post-stratified sampling weight for one-year cohorts (RI & TT)

global PSWEIGHT_1YEAR 			hv005

* Provide the variable for the Post-stratified sampling weight for SIA cohort
global PSWEIGHT_SIA 			hv005

* Provide the variable that indicates if the area is urban or cluster
global URBAN_CLUSTER 			hv025

********************************************************************************
********************************************************************************
********************************************************************************

* * The below need to be defined to create RI DATASET 

* Was the RI Survey completed? 1 yes, 0 no
global RI_SURVEY				1

* House member line number in Child (KR) dataset
global RI_LINE 					b16 	// take from children dataset (KR)

* Line number for respondent(caretaker of child)
global RESPONDENT_LINE 			v003	

* Outcome for each RI survey if survey completed
* Example completed, refused, incomplete
global RI_DISPOSITION 			v015

* Populate the below with the appropriate ages in months for the Child Survey if RI Survey completed
global RI_MIN_AGE				9
global RI_MAX_AGE				`=12*5'

* Populate the below with the variable names that correspond to the global name if the RI Survey was completed
global CARD_SEEN 				h1

* Date of RI interview
global RI_DATE_MONTH 			v006	
global RI_DATE_DAY 				v016
global RI_DATE_YEAR 			v007

* Child Date of Birth per history
* NOTE either History or Card date of birth must be populated.
* Both cannot be left blank.
global CHILD_DOB_HIST_MONTH		b1 		// OPTIONAL -can be blank if not available if CHILD_DOB_CARD_MONTH is provided
global CHILD_DOB_HIST_DAY		hw16 	// OPTIONAL -can be blank if not available if CHILD_DOB_CARD_DAY is provided
global CHILD_DOB_HIST_YEAR		b2 		// OPTIONAL -can be blank if not available if CHILD_DOB_CARD_YEAR is provided

* Child Age in Years
global CHILD_AGE_YEARS			b8 		// OPTIONAL -can be blank if not available
global CHILD_AGE_MONTHS			hw1		// OPTIONAL -can be blank if not available

* Is the child alive?
global CHILD_IS_ALIVE			b5

* Provide a complete list of the RI doses, use the same dose names as the globals below
* all dose numbers must be provided, so if there are three doses provide the dose1 dose2 dose3.

global RI_LIST 		bcg opv0 opv1 opv2 opv3 dpt1 dpt2 dpt3

* Populate the below doses with the proper variable name per CARD DATA and HIST DATA
* Global DOSE_NAME should be the variable that indicates if the dose was received, but is NOT the date.
* The dates from the card should populate the globals immediately following.
* NOTE: If the vaccine is not part of the survey, leave it bank
* BCG 
global BCG								h2
global BCG_DATE_CARD_MONTH				h2m
global BCG_DATE_CARD_DAY				h2d
global BCG_DATE_CARD_YEAR				h2y


* DPT or PENTA doses 1-3
global DPT1								h3
global DPT1_DATE_CARD_MONTH				h3m
global DPT1_DATE_CARD_DAY				h3d
global DPT1_DATE_CARD_YEAR				h3y

global DPT2								h5
global DPT2_DATE_CARD_MONTH				h5m
global DPT2_DATE_CARD_DAY				h5d
global DPT2_DATE_CARD_YEAR				h5y

global DPT3								h7			
global DPT3_DATE_CARD_MONTH				h7m
global DPT3_DATE_CARD_DAY				h7d
global DPT3_DATE_CARD_YEAR				h7y


* OPV at Birth
global OPV0								h0
global OPV0_DATE_CARD_MONTH				h0m
global OPV0_DATE_CARD_DAY				h0d
global OPV0_DATE_CARD_YEAR				h0y


* OPV doses 1-3 (polio)
global OPV1								h4 
global OPV1_DATE_CARD_MONTH				h4m
global OPV1_DATE_CARD_DAY				h4d
global OPV1_DATE_CARD_YEAR				h4y

global OPV2								h6
global OPV2_DATE_CARD_MONTH				h6m
global OPV2_DATE_CARD_DAY				h6d
global OPV2_DATE_CARD_YEAR				h6y

global OPV3								h8
global OPV3_DATE_CARD_MONTH				h8m
global OPV3_DATE_CARD_DAY				h8d
global OPV3_DATE_CARD_YEAR				h8y


* Measles or MMR or MR
global MCV								h9
global MCV_DATE_CARD_MONTH				h9m
global MCV_DATE_CARD_DAY				h9d
global MCV_DATE_CARD_YEAR				h9y


* Vitamin A doses 1-2
global VITA1							h33
global VITA1_DATE_CARD_MONTH			h33m
global VITA1_DATE_CARD_DAY				h33d
global VITA1_DATE_CARD_YEAR				h33y

* Additional variables to keep (usually multiple choice questions)
* e.g. religion, education etc
global RI_ADDITIONAL_VARS

*******************************************************************************
********************************************************************************
********************************************************************************
* * The below need to be defined to create SIA DATASET

* Was the SIA Survey completed? 1 yes, 0 no
global SIA_SURVEY				1

* Outcome for SIA survey if survey completed
* Example completed, refused, incomplete
global SIA_DISPOSITION 			v015

* Populate the below global with the list of vaccines received in SIA campaign if the SIA Survey was completed
* These should be consistent with the SIA_MIN/MAX_AGE_* globals, and include either the Campaign letter or the dose name.
global SIA_LIST 				A B C D E F

* For all global macros specific to a campaign:
* Make sure the global name is consistent with the Doses provided in global SIA_LIST.
* If SIA_LIST is populated with the Campaign letter (A, B, or C) the global macros must have the letter in their name.
* If SIA_LIST is populated with the dose name, the global macros must have the Dose name and not Campaign letter.
* NOTE Additional globals may need to be created if there are more than 3 campaigns. 
* Create them with the same format and the appropriate campaign name (dose name or letter)

* Populate the below with the appropriate ages in months for the Campaign Survey if SIA Survey completed
* Fill in the appropriate global for which dose the campaign was for
global SIA_MIN_AGE_A				12
global SIA_MAX_AGE_A				`=15*12'

global SIA_MIN_AGE_B				9
global SIA_MAX_AGE_B				`=15*12'

global SIA_MIN_AGE_C				
global SIA_MAX_AGE_C	
	
global SIA_MIN_AGE_D				
global SIA_MAX_AGE_D			

global SIA_MIN_AGE_E				
global SIA_MAX_AGE_E	

global SIA_MIN_AGE_F				
global SIA_MAX_AGE_F
	

* Populate the below with the variable names that correspond to the global name
* Variable that indicates if child was vaccinated in SIA campaign.
* NOTE These only need to be populated for the campaigns that were completed.
global SIA_A					h36a
global SIA_B					h36b
global SIA_C					h36c
global SIA_D					h36d
global SIA_E					h36e
global SIA_F					h36f
********************************************************************************
********************************************************************************
********************************************************************************

* * The below need to be defined to create tt  DATASET
* Was the TT(IR)/Womens survey completed? 1 yes, 0 no
global TT_SURVEY				1

* Outcome for TT(IR) survey if survey completed
* Example completed, refused, incomplete
global TT_DISPOSITION 			ha65

* Populate the below with the appropriate ages in months for the Womens TT(IR) Survey if TT Survey completed
global TT_MIN_AGE				`=15*12'
global TT_MAX_AGE				`=50*12'	

* Populate the below with the variable names that correspond to the global name if the TT Survey was completed

* House member line number in Womens(IR) dataset
global TT_LINE 					v003

* Populate the below if Mother DOB was collected 1==yes, 0==no
global MOTHER_DOB				1

* Womens Date of birth
global MOTHER_DOB_MONTH			v009
global MOTHER_DOB_YEAR			v010
global MOTHER_DOB_DAY					// OPTIONAL -can be blank if not available

* Age of Mother in years
global MOTHER_AGE_YEARS			 v012 	// OPTIONAL -can be blank if not available

* When was the last birth in months? 
global TT_LAST_BIRTH_MONTHS		v222  	// OPTIONAL -can be blank if not available

* Number of TT doses received during last pregnancy
global NUM_TT_PREGNANCY 		m1

* Number of TT doses received prior to last pregnancy
global NUM_TT_ANYTIME 			m1a

* Month and Year of tt dose
global LAST_TT_MONTH			m1b 	// OPTIONAL -can be blank if not available
global LAST_TT_YEAR				m1c 	// OPTIONAL -can be blank if not available

* Last year of TT dose
global YEARS_SINCE_LAST_TT		m1d

* Was the child born alive?
global CHILD_BORN_ALIVE

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
* Delete any existing combined dataset files in this folder 
capture confirm file "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset.dta" 
if !_rc {
	erase "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset.dta" 
}


set more off

* Run the program to create the datasets
do "${RUN_FOLDER}/Step00 - VCQI Conversion Steps.do" // Runs all the necessary steps to make dataset VCQI compatible
