/**********************************************************************
Program Name:               DHS to VCQI - CM dataset
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
* Bring in Combined dataset
use "${OUTPUT_FOLDER}/DHS_${DHS_NUM}_combined_dataset", clear

* cd to Output folder
cd "$OUTPUT_FOLDER"

* Save as CM dataset
save DHS_${DHS_NUM}_to_VCQI_CM, replace 

****************************************************************
* Create expected_hh_to_visit VCQI variable
bysort HH03 : gen expected_hh_to_visit =(_N) // Double check to ensure this appropriately calculated.
label variable expected_hh_to_visit "Number of HH survey team expects to visit in cluster (or cluster segment)"

*****************************************************************

* Only keep the variables required for CM dataset
keep HH01 HH02 HH03 HH04 province_id expected_hh_to_visit urban_cluster psweight*

* Urban/Rural cluster can be missing; if there is a populated value for this cluster, use it
sort HH01 HH03 urban_cluster
bysort HH01 HH03: replace urban_cluster = urban_cluster[1]

* The weight can be missing for some observations; replace the weight with
* the maximum non-missing weight in each cluster 

bysort HH01 HH03: egen max_psweight_1year = max(psweight_1year)
replace psweight_1year = max_psweight_1year
drop max_psweight_1year

bysort HH01 HH03: egen max_psweight_sia = max(psweight_sia)
replace psweight_sia = max_psweight_sia
drop max_psweight_sia

*Only keep one row per cluster and stratum
bysort HH01 HH03 : keep if _n==1

* Save file
save, replace

