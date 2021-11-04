// -----------------------------------------------------------------------------
// Purpose: Paper Family Sociology and Social Inequality (SaSR02)
// -----------------------------------------------------------------------------
	version 14 
	clear all
	cls
	set more off
	cd "U:\SaSR2" // Change this working directory
// -----------------------------------------------------------------------------
	use EVS_WVS_Joint_Clear.dta, clear
// -----------------------------------------------------------------------------

// Factor analysis - only rely on 1 factor
    codebook cntry
	factor F_Q* if cntry==528
	factor F_Q* if cntry==156
	factor F_Q* if cntry==276
	factor F_Q* if cntry==840

// Reliability - if we drop the F_Q5, alpha value will increase
	bys cntry: alpha F_Q*, std item

	drop F_Q5

	bys cntry: alpha F_Q*, std item 

// Gender attitude
	egen GA = rowmean(F_Q*)
	label variable GA "Average Gender attitudes"

// OLS models by country 
	bys cntry: reg GA c.educ i.female c.age i.religiosity, allbase
    bys cntry: reg GA c.educ i.female i.marital_status c.age i.religiosity, ///
	           allbase
	bys cntry: reg GA c.educ i.female i.marital_status c.age i.religiosity ///
					  c.educ#i.marital_status, allbase
					  
// OLS models singles in the Netherlands by gender
    bys female: reg GA c.educ c.age i.religiosity if (marital_status==3 & ///
	                                                  cntry==528), allbase

// Interaction graphs by country
   /* 528==Netherlands
      156==China
	  276==Germany
	  840==United States
   */
   
  //Netherlands
   quietly reg GA c.educ i.female i.marital_status c.age i.religiosity ///
					  c.educ#i.marital_status if cntry==528
   quietly margins, at(educ=(1 2 3)) over(marital_status)
   marginsplot, title("Netherlands", size(medium)) ///
				xtitle(" ", size(small)) /// 
				ytitle("Pr(Gender attitudes)", size(small)) ///
				xlabel(1 "lower" 2 "middle" 3 "higher") ///
				legend(label(1 "married") label(2 "cohabitation") ///
					   label(3 "single") label(4 "others") /// 
					   lpattern(blank) row(1) size(small)) ///				
				graphregion(fcolor(white)) ///
				name(graph_netherlands, replace)
   
   //China
   quietly reg GA c.educ i.female i.marital_status c.age i.religiosity ///
					  c.educ#i.marital_status if cntry==156
   quietly margins, at(educ=(1 2 3)) over(marital_status)
   marginsplot, title("China", size(medium)) ///
				xtitle(" ", size(small)) /// 
				ytitle("Pr(Gender attitudes)", size(small)) ///
				xlabel(1 "lower" 2 "middle" 3 "higher") ///
				graphregion(fcolor(white)) ///
				name(graph_china, replace)
   
   //Germany
   quietly reg GA c.educ i.female i.marital_status c.age i.religiosity ///
					  c.educ#i.marital_status if cntry==276
   quietly margins, at(educ=(1 2 3)) over(marital_status)
   marginsplot, title("Germany", size(medium)) ///
				xtitle(" ", size(small)) /// 
				ytitle("Pr(Gender attitudes)", size(small)) ///
				xlabel(1 "lower" 2 "middle" 3 "higher") ///
				graphregion(fcolor(white)) ///
				name(graph_germany, replace)
   
   //United States
   quietly reg GA c.educ i.female i.marital_status c.age i.religiosity ///
					  c.educ#i.marital_status if cntry==840
   quietly margins, at(educ=(1 2 3)) over(marital_status)
   marginsplot, title("United States", size(medium)) ///
				xtitle(" ", size(small)) /// 
				ytitle("Pr(Gender attitudes)", size(small)) ///
				xlabel(1 "lower" 2 "middle" 3 "higher") ///
				graphregion(fcolor(white)) ///
				name(graph_US, replace)
	
	ssc install grc1leg2 // If not working typ: 'findit grc1leg2'
	grc1leg2 graph_netherlands graph_china graph_germany graph_US ///
			 , graphregion(fcolor(white)) legendfrom(graph_netherlands)

// Model Assumptions
   ** Check assumption of linearity of the relationship
   twoway (scatter GA educ) ///
          (lfit GA educ, lcolor(red)) ///
		  (qfit GA educ, lcolor(green))
   reg GA c.educ i.female i.marital_status c.age i.religiosity ///
          i.marital_status
   predict resid1, resid
   qnorm resid1 // Not completely normal distributed

   ** Check normality of residuals
   reg GA c.educ i.female i.marital_status c.age i.religiosity ///
		  i.marital_status
   histogram resid1, normal // Not completely normal distributed
 
   // Check Homoskedacity (H0: Homoskedacity)
   estat hettest /* No homoskedacity (i.e. Errors do not have
                    constant variance across different levels of IV's).
				    If OLS is performed on a heteroscedastic dataset, we might 
					fail to reject a null hypothesis at a given significance 
					level, when that null hypothesis was actually 
					uncharacteristic of the actual population (making a type 
					II error). 
				 */
 
   // Check random errors (Independency)
   summ resid1 // Approximately zero
   drop resid1

   /* Marital status is likely to be a supressor, but this claim still remains
   weak */
   anova GA i.educ i.female c.age i.religiosity i.marital_status
   //partial eta2 is SSEffect/(SSEffect+SSError)
   dis (354.85152/(354.85152+3448.5299)) + (58.407718/(58.407718+3448.5299))

   /* We found multicollinearity between Education and Marital status,
   which implies that the full model did not have enough power (i.e.
   not enough control variables) to see the 'real' effect between Y~X */
   reg GA c.educ i.female i.marital_status c.age i.religiosity ///
		  i.marital_status
   estat vif
   reg GA c.educ i.female i.marital_status c.age i.religiosity ///
		  i.marital_status c.educ#i.marital_status
   estat vif
   
// -----------------------------------------------------------------------------
exit			  
				  