// -----------------------------------------------------------------------------
// Purpose: Paper Family Sociology and Social Inequality (SaSR02)
// -----------------------------------------------------------------------------
	version 14 
	clear all
	cls
	set more off
	cd "U:\SaSR2" // Change this working directory
// -----------------------------------------------------------------------------
	use EVS_WVS_Joint_v2_0.dta, clear
// -----------------------------------------------------------------------------

	codebook cntry
/*
    X003 = age
    cntry = country
    uniqid = ID_unique
    X001 = sex
    D059 = Men make better political leaders than women do
    D078 = Men make better business executives than women do
    D060 = University is more important for a boy than for a girl
    X025R = Highest educational level attained - Respondent (recoded)
    C001_01 = Men should have more right to a job than women (5-point scale) >>
              [not in US available > choose 3-point scale == C001] 
		      D061 =  Pre-school child suffers with working mother
    size_5c = Size of town, but can be dropped from the varlist because 
              Netherlands is Missing.
    X007 = marital status
    F034 = religious or not
*/

// Specify variables
    keep X003 cntry uniqid X001 D059 D078 D060 X025R C001 D061 size_5c ///
         X007 F034

/*Keep only Netherlands (528), Germany (276), China (156), 
  and United States (840)*/
    gen cntry_filter = 1 if (cntry==528 | cntry==276 | cntry==156 | cntry==840)
    tab cntry_filter cntry
    drop if (cntry_filter ==.)
    tab cntry_filter cntry

//Rename variables
    rename (X003 cntry uniqid X001 D059 D078 D060 X025R C001 D061 size_5c ///
            X007 F034) ///
	       (age cntry uniqid female F_Q1 F_Q2 F_Q3 educ F_Q4 F_Q5 townsize ///
	        marital_status religiosity)

//Inspecting variables
    codebook age cntry uniqid female F_Q1 F_Q2 F_Q3 educ F_Q4 F_Q5 townsize ///
	         marital_status religiosity
*wrong coding for missing values --> missing()
    mvdecode female, mv(-2)
    mvdecode F_Q1, mv(-2 -1)
    mvdecode F_Q2, mv(-2 -1)
    mvdecode F_Q3, mv(-2 -1)
    mvdecode F_Q4, mv(-5 -2 -1)
    mvdecode F_Q5, mv(-2 -1)
    mvdecode educ, mv(-5 -2 -1)
    mvdecode townsize, mv(-5 -4)
    mvdecode marital_status, mv(-5 -2 -1)
    mvdecode religiosity, mv(-2 -1)
    codebook age cntry uniqid female F_Q1 F_Q2 F_Q3 educ F_Q4 F_Q5 townsize ///
	         marital_status religiosity
*drop townsize, not available in the Netherlands
    drop townsize
*recode F_Q4: wrong direction
    codebook F_Q4
    recode F_Q4 (1=1) (2=3) (3=2)
    label define _F_Q4 1 "Agree" 2 "Neither" 3 "Disagree"	
    label value F_Q4 _F_Q4
    codebook F_Q4

//Missing dummy ~ casewise deletion
    egen count_missing = rowmiss(age cntry uniqid female F_Q1 F_Q2 F_Q3 /// 
	                     educ F_Q4 F_Q5 marital_status religiosity)
    tab count_missing 
    tab count_missing cntry
    keep if (count_missing==0)

    drop count_missing
    drop cntry_filter

// Dummy_coding marital status
    codebook marital_status // no missing values
    tab marital_status, gen(R)
/*
    R1 = married (1=1) ~ married
    R2 = living together as married (1=2) ~ cohabitation
    R3 = divorced (1=4) ~ other
    R4 = seperated (1=4) ~ other
    R5 = widowed (1=4) ~ other
    R6 = single/never married (1=3) ~ single
*/
    recode R1 (1=1)
    recode R2 (1=2) 
    recode R3 (1=4)
    recode R4 (1=4)
    recode R5 (1=4)
    recode R6 (1=3)
    egen marital_status_new = rowtotal(R1 R2 R3 R4 R5 R6)
    tab marital_status_new marital_status

    label variable marital_status_new "Marital status"

    label define _marital_status_new 1 "Married" 2 "Cohabitation" /// 
	                                 3 "Single" 4 "Other"	
    label value marital_status_new _marital_status_new
    codebook marital_status_new

    drop R1-R6
    drop marital_status
    rename marital_status_new marital_status

//Save new dataset
    save EVS_WVS_Joint_Clear.dta, replace

// -----------------------------------------------------------------------------
exit 


	 
