####################################################################################################
###----------------------------------------------------------------------------------------------###
#                     \    ||   /
#      AA             \    ||   /  MMM    MMM  IIII  PPPPP
#     AAAA            \\   ||   /   MMM  MMM    II    P  PP
#    AA  AA    ggggg  \\\\ ||  //   M  MM  M    II    PPPP
#   AAAAAAAA  gg  gg     \\ ////    M      M    II    P
#  AA      AA  ggggg  \\   //      MM      MM  IIII  PPP
#                  g  \\\\     //    
#              gggg      \\ ////     The Agricultural Model Intercomparison and Improvement Project
#                          //
###----------------------------------------------------------------------------------------------###
####################################################################################################
###----------------------------------------------------------------------------------------------###
#         run_acr_agmip2metrics.R
#
#  This script produces a record of climate metrics in a given season for a .AgMIP files.  
#
#  General approach:    Need to call acr_agmip2metrics.R
#
#  THIS WAS FORMERLY run_metrics.R  --  September 30, 2013 by Nicholas Hudson
#    Updated to produce records for multiple .AgMIP files
#    Updated to print output .csvs  --  October 2, 2013 by Nicholas Hudson
#
#
#     Author: Alex Ruane
#           				alexander.c.ruane@nasa.gov
#    	Created:	February 16, 2012
# 		Translated to R by Yunchul Jung: August 12, 2012
###----------------------------------------------------------------------------------------------###
####################################################################################################
###----------------------------------------------------------------------------------------------###
#
# This script and associated scripts have been developed collaboratively by the AgMIP Climate Team
#  and are to be used solely for the ongoing research efforts of AgMIP.
#
# There is ABSOLUTELY NO GUARANTEE that these scripts will produce accurate and precise results.
#  Accordingly, results should be confirmed and validated prior to publication.  Also, there is
#  ABSOLUTELY NO WARRANTY that comes with these scripts.
#
# Should you encounter any bugs or difficulties or have any suggestions or recommendations, please
#  feel free to contact us.
#
# Thank you for your contribution to AgMIP and best of luck with your research!
#
###----------------------------------------------------------------------------------------------###
####################################################################################################

##  Input variables
###  These should be the only variables you will have to adjust to run this script.

##  List .AgMIP files 
###  This script is designed to loop through multiple .AgMIP files as long as they are located in the
###    correct folder (~/R/data/Climate/Historical/).  The script will function correctly if you 
###    choose to only produce a record for one .AgMIP file.
infile    <- c('XX010XXX',
               'XX020XXX',
               'XX030XXX',
               'XX040XXX',
               'XX050XXX')
infile    <- 'INMOIEXA'
infile    <- c('NK010XFX','NK080XFX')
infile <- rep('NK010XFX',12)
infile <- sprintf('%s%02d%s','XX',seq(1,12),'XXXX')

##  Time interval variables
###  'jd.start' and 'jd.end' specify the time period over which the analysis is conducted.  These
###    variables should be defined by the Julian day number in a 365 day year (not a leap year) where 
###    1 = January 1, 32 = February 1, 335 = December 1.  If you are running the script to calculate
###    metrics for multiple .AgMIP files, make sure that the vectors 'jd.start' and 'jd.end' are of 
###    the same length as 'infile'.  If you are running multiple .AgMIP files which all have the same 
###    start and end dates, you can use the line: jd.start <- rep(XXX,Y) where XXX = the start date
###    and Y is the number of .AgMIP files. Note: The script uses these dates to
###    determine a period length, so periods that wrap-around leap years will end on jdend -1.
#jd.start    <- c(285, 110, 115, 100, 105)
#jd.end      <- c(105, 290, 295, 280, 285)
# jd.start <- 244
# jd.end <- 273
jd.start <- c(1,32,60,91,121,152,182,213,244,274,304,335)
jd.end   <- c(31,59,90,120,151,181,212,243,273,303,334,365)

##  Run specific variables
###  clim.var is the climate variable to analyze where 5 = Srad,  6 = Tmax,   7 = Tmin,   8 = Precip,
###    9 = Wind,  10 = Dewp,  11 = Vprs,  12 = Rhum,  13 = Tavg
clim.var    <- 8

###  analysis.type should be defined as one of the following calculations:
###    'mean'                 - the average of the selected climate variable
###    'max'                  - the maximum of the selected climate variable
###    'min'                  - the minimum of the selected climate variable
###    'std'                  - the standard deviation of the selected climate variable
###    'count'                - the number of days the selected climate variable is greater than the 
###                               value defined by the input variable 'reference'
###                             set 'special.operator' to '-1' to count the number of days that the
###                               selected climate variable is less than the value defined by the
###                               input variable 'reference'
###    'exceedance'           - totals the amount by which the selected climate variable is greater
###                               than the value defined by the input variable 'reference'
###                             set 'special.operator' to '-1' to total the amount by which the
###                               selected climate variable is less than the value defined by the
###                               input variable 'reference'
###    'meanconsecutivedays'  - calculates the mean number of consecutive days when the selected
###                               climate variable is greater than the value defined by the input 
###                               variable 'reference'
###                             set 'special.operator' to '-1' to calculate the mean number of
###                               consecutive days when the selected climate variable is less than
###                               the value defined by the input variable 'reference'
###    'maxconsecutivedays'   - calculates the maximum number of consecutive days when the selected
###                               climate variable is greater than the value defined by the input 
###                               variable 'reference'
###                             set 'special.operator' to '-1' to calculate the maximum number of
###                               consecutive days when the selected climate variable is less than
###                               the value defined by the input variable 'reference'
analysis.type     <- 'exceedance'

###  Unless explicitly mentioned in the above explanation for 'analysis.type', 'reference' and
###    'special.operator' are not used in this script.  However, you should define these values (as 
###    one (1) for example) so that the script functions properly.  If you are running analysis.type
###    'count', 'exceedance', 'meanconsecutivedays', or 'maxconsecutivedays', make sure you have
###    defined 'reference' and 'special operator' as explained in the above explanation for 
###    'analysis.type'.
reference         <- 0
special.operator  <- 1

###  You must enter the location of the R folder into rootDir below using \\ between folders.
###  For example, 'C:\\Users\\Your Name Here\\Desktop\\R\\'
rootDir     <- '*** your directory here ***\\R\\'           ##  <- Enter location here <-
rootDir     <- 'C:\\Users\\Nicholas Hudson\\Desktop\\R\\'

###----------------------------------------------------------------------------------------------###
###############  You should not have to adjust any of the variables below this line  ###############
###----------------------------------------------------------------------------------------------###

##  Source scripts
source(paste(rootDir, 'r\\acr_agmip2metrics.R', sep=''))

##  Define variables for function loop
clim.var.names <- c('','','','','Srad', 'Tmax', 'Tmin', 'Precip', 'Wind', 'Dewp', 'Vprs', 'Rhum', 'Tavg')

##  Create metric file
metric      <- matrix(NaN,31,length(infile)+1)
metric[,1]  <- 1980:2010
colnames(metric) <- c('Year', infile)

##  Run function loop
for (ii in 1:length(infile)) {
  

  metric[,ii+1] <- acr_agmip2metrics(infile[ii], jd.start[ii], jd.end[ii], clim.var, analysis.type, reference, special.operator)
  
  cat('\n\nMetrics for ', infile[ii] , '.AgMIP files with parameters \n\tjd.start = ', jd.start[ii], '\t\tjd.end = ', jd.end[ii], '\n\tclim.var = ', clim.var ,' (', clim.var.names[clim.var], ')', '\t\tanalysis.type = ', analysis.type, '\n\treference = ', reference ,'\t\tspecial.operator = ', special.operator, '\n',sep='')
  print(metric[,c(1,ii+1)])
  
}

##  Print metrics.csv

yesno <- readline('\n\nPrint metrics.csv? Yes(1)/No(2): ')
if (yesno == 2 || yesno == 'n' || yesno == 'N' || yesno == 'no' || yesno == 'No' || yesno == 'NO') {
  
  message('\n\nagmip2metrics complete! No results file was created.  \nView variable \'metric\' in workspace for complete results.\n\n')
  
} else {
  dir.create(paste(rootDir, 'analysis', sep='\\'), showWarnings = FALSE)
  dir.create(paste(rootDir, 'analysis\\metrics', sep='\\'), showWarnings = FALSE)
  
  outfile <- paste(rootDir, 'analysis\\metrics\\metrics_', infile[1], '_', analysis.type, '_', clim.var.names[clim.var], '.csv', sep='')
  file.create(outfile)
  
  cat('Metrics for .AgMIP files created', format(Sys.time(),'%d/%m/%Y at %H:%M:%S %Z'), '\n\n', file=outfile)
  write.table(matrix(c('clim.var', 'clim.var.name', 'analysis.type', 'reference', 'special.operator',clim.var, clim.var.names[clim.var], analysis.type, reference, special.operator), nrow = 2, byrow = TRUE), file=outfile, sep=",", row.names = FALSE, col.names = FALSE, append = TRUE)
  
  cat('\n', file=outfile, append = TRUE)
  write.table(matrix(c('', infile, 'jd.start', jd.start, 'jd.end', jd.end), nrow=3, byrow = TRUE), file=outfile, sep=",", row.names = FALSE, col.names = FALSE, append = TRUE)
  
  cat('\n', file=outfile, append = TRUE)
  suppressWarnings(write.table(metric, file=outfile, sep=",", row.names=FALSE, col.names = TRUE, append = TRUE))
  
  message('\n\nagmip2metrics complete! Metric results file saved as...\n\t', paste(rootDir, 'analysis\\metrics\\metrics_', infile[1], '_', analysis.type, '_', clim.var.names[clim.var], '.csv', sep=''), '\nYou can also view variable \'metric\' in workspace for complete results.\n\n')
}