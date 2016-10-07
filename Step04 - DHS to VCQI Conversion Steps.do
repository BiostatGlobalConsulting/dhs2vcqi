/**********************************************************************
Program Name:               Step04- DHS to VCQI Converstion Steps 
Purpose:                    Create the datasets 
*													
Project:                    Q:\- WHO DHS VCQI-compatible\DHS manuals
Date Created:    			2016-04-28
Author:         Mary Kay Trimner
Stata version:    14.0
********************************************************************************/

set more off



do "${RUN_FOLDER}/DHS to VCQI -HH dataset.do"
do "${RUN_FOLDER}/DHS to VCQI -HM dataset.do"
do "${RUN_FOLDER}/DHS to VCQI -CM dataset.do"
do "${RUN_FOLDER}/DHS to VCQI -RI dataset.do"
do "${RUN_FOLDER}/DHS to VCQI -SIA dataset.do"
do "${RUN_FOLDER}/DHS to VCQI -TT dataset.do"
do "${RUN_FOLDER}/DHS to VCQI -levels of datasets.do" // Creates the levels of datasets
