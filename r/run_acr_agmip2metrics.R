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
#  General approach:    Required to call acr_agmip2metrics.R
#
#  THIS WAS FORMERLY run_metrics.R  --  September 30, 2013 by Nicholas Hudson
#    Updated to produce records for multiple .AgMIP files  -- October 2, 2013 by Nicholas Hudson
#    Updated to print output .csvs  --  July 11, 2014 by Nicholas Hudson
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
###  This script is designed to loop through multiple .AgMIP files as long as they are located in one
###    of the folders in '~/R/data/Climate/' (i.e., '~/Fullscenario/', '~/Historical/', or 
###    '~/Simplescenario/').  In the event that you select a file with the same name that can be
###    found in multiple folders, the script will prompt you to select which file to use.  This 
###    typically occurs if you have generated climate scenarios using 'run_agmip_simple_mandv.R' or
###    'run_agmip_simple_delta.R' and have then produced the full climate series using 
###    'run_agmip_simple2full.R'.
### The script will function correctly if you only select one .AgMIP file.
run_acr_agmip2metrics <- function(rootDir,jd.start,jd.end,clim.var,analysis.type,reference,special.operator,outfile){
AgMIPfiles<-list.files(rootDir,pattern="\\.AgMIP$")

all.files <- AgMIPfiles
infile.loc <- AgMIPfiles

infile<-unique(substring(AgMIPfiles,1,8))
#infile    <- 'USAM0XXX'
#infile    <- c('ZWNKITXF',
#               'PKFAMQXA',
#               'INMOIEXA',
#               'INMO0XXX')
# infile    <- c('XX010XXX',
#                'XX020XXX',
#                'XX030XXX',
#                'XX040XXX',
#                'XX050XXX')


##  Time interval variables
###  'jd.start' and 'jd.end' specify the time period over which the analysis is conducted.  These
###    variables should be defined by the Julian day number in a 365 day year (not a leap year) where 
###    1 = January 1, 32 = February 1, 335 = December 1.  If you are running the script to calculate
###    metrics for multiple .AgMIP files, make sure that the vectors 'jd.start' and 'jd.end' are of 
###    the same length as 'infile'.  If you are running multiple .AgMIP files which all have the same 
###    start and end dates, you can use the line: jd.start <- rep(XXX,Y) where XXX = the start date
###    and Y is the number of .AgMIP files. Note: The script uses these dates to
###    determine a period length, so periods that wrap-around leap years will end on jdend -1.
#jd.start <- 244
#jd.end 	<- 273
# jd.start <- c(1,32,60,91,121,152,182,213,244,274,304,335)
# jd.end   <- c(31,59,90,120,151,181,212,243,273,303,334,365)

##  Run specific variables
###  clim.var is the climate variable to analyze where 5 = Srad,  6 = Tmax,   7 = Tmin,   8 = Precip,
###    9 = Wind,  10 = Dewp,  11 = Vprs,  12 = Rhum,  13 = Tavg
#clim.var    <- 6

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
#analysis.type     <- 'meanconsecutivedays'

###  Unless explicitly mentioned in the above explanation for 'analysis.type', 'reference' and
###    'special.operator' are not used in this script.  However, these values should always be 
###    defined (as one '1' for example) even if the selected 'analysis.type' does no require these
###    inputs so that the script functions properly.  If you are running analysis.type
###    'count', 'exceedance', 'meanconsecutivedays', or 'maxconsecutivedays', make sure you have
###    defined 'reference' and 'special operator' as explained in the above explanation for 
###    'analysis.type'.  Also, you may select multiple values for 'reference' and 'special.operator'
###    if you are interested in determining multiple metrics.
#reference         <- 0
#special.operator  <- 1
# reference         <- c(25,30,35)
# special.operator  <- c(-1, 1,1)

##  Set root directory
###  You must enter the location of the R folder into rootDir below using \\ between folders.
###  For example, 'C:\\Users\\Your Name Here\\Desktop\\R\\'
#rootDir     <- '*** your directory here ***\\R\\'           ##  <- Enter location here <-

##  Create metrics.csv and save to ~\R\analysis\metrics
###  "print.csv <- 1" will print metrics report in .csv format
###  "print.csv <- 0" will not print metrics report in .csv format
print.csv <- 1

###----------------------------------------------------------------------------------------------###
###############  You should not have to adjust any of the variables below this line  ###############
###----------------------------------------------------------------------------------------------###

##  Confirm length(jd.start) == length(jd.end)
if (length(jd.start) != length(jd.end)) {
  stop('\tLength of jd.start and jd.end are not of equal lengths\n\n\n',call. = FALSE)
}
if (length(reference) != length(special.operator)) {
  stop('\tLength of reference and special.operator are not of equal lengths\n\n\n',call. = FALSE)
}

##  Turn echo off
options(echo = FALSE)

##  Find infiles in ~\data\Climate
#all.files <- list.files('C:\\Users\\Nicholas Hudson\\Desktop\\R\\data\\Climate\\',recursive = TRUE, pattern = '.AgMIP')
                        
#infile.loc <- infile

for (ii in 1:length(infile)) {
  jj <- grep(infile[ii],all.files)
  
  if (length(jj) <1) {            ##  If infile could not be found in ~\data\Climate
    options(echo = TRUE)
    cat('\n\n')
    stop(paste('Could not find ', infile[ii],' in ', rootDir,'data\\Climate\\.',
               '\n\nConfirm ', infile[ii],'.AgMIP is located in one of these folders:',
               '\n\t\t\'~\\data\\Climate\\Fullscenario\'',
               '\n\t\t\'~\\data\\Climate\\Historical\'',
               '\n\t\t\'~\\data\\Climate\\Simplescenario\'',
               '\n\nrun_acr_agmip2metrics.R was not completed due to this error.',
               '\n\n',sep=''))
    
  } else if(length(jj) > 1 ) {    ##  If multiple matches of infile exist
    message(paste('\n\nMultiple matches for ', infile[ii], 
              ' exist.  Select one of the matches by number below:', sep=''))
    print(matrix(all.files[jj],dimnames = list(c(1:length(jj)),'')))
    kk <- readline(paste('\nAlternatively, press any non-numeric key to exit.\n\n', sep=''))

    if (length(which(1:length(jj) == kk)) > 0) {
        #infile.loc[ii] <- gsub('/','\\\\',paste('data\\Climate\\', all.files[jj[as.numeric(kk)]], sep=''))
        infile.loc[ii]<-all.files[jj[as.numeric(kk)]]
    } else {
      options(echo = TRUE)
      stop(paste('You have stopped run_acr_agmip2metrics.R.',
                 '\n\nCheck location of ', infile[ii],' prior to rerunning run_acr_agmip2metrics.R.',
                 '\n\nAlternatively, consider temporarily moving or renaming files not currently in use.\n\n',sep=''))
    }
    
  } else {                        ##  If only one match exists for infile
      #infile.loc[ii] <- gsub('/','\\\\',paste('data\\Climate\\', all.files[jj], sep=''))
      infile.loc[ii]<-all.files[jj]
  }
}

##  Source scripts
source('/mnt/galaxyTools/agmip_sce_generator/1.0.0/acr_agmip2metrics.R')

##  Define variables for function loop
clim.var.names <- c('','','','','Srad', 'Tmax', 'Tmin', 'Precip', 'Wind', 'Dewp', 'Vprs', 'Rhum', 'Tavg')

##  Create metric file
metric      <- matrix(NaN,31,length(infile)*length(jd.start)*length(reference)+1)
metric[,1]  <- 1980:2010
#colnames(metric) <- c('Year', rep(rep(infile,each = length(jd.start)),length(reference)))

##  For loop to run different scenarios
for (ii in 1:length(reference)) {
  
  for (jj in 1:length(infile)) {
    
    for (kk in 1:length(jd.start)) {
      
      ##  Define matrix index
      idx <- ((ii-1)*(length(reference)+1)+(jj-1)*(length(jd.start))+kk+1)
#       idx <- idx + 1      ##  Alternative index counter, requires "idx <- 0" before loop
      
      ##  Run acr_agmip2metrics
      metric[,idx]  <- acr_agmip2metrics(infile.loc[jj], 
                                         jd.start[kk], 
                                         jd.end[kk], 
                                         clim.var, 
                                         analysis.type, 
                                         reference[ii], 
                                         special.operator[ii])
      
      ##  Display run info in Console
      cat('\n\nMetrics for ', infile[jj] , '.AgMIP files with parameters \n\tjd.start = ', 
          jd.start[kk], '\t\tjd.end = ', jd.end[kk], 
          '\n\tclim.var = ', clim.var ,' (', clim.var.names[clim.var], ')', 
          '\tanalysis.type = ', analysis.type, 
          '\n\treference = ', reference[ii] ,
          '\t\tspecial.operator = ', special.operator[ii], '\n',sep='')
      
      ##  Display run data in Console
      print(metric[,c(1,idx)])
      
      ##  Display in console
      flush.console()
    }
  }
}

##  Print metrics.csv as defined by "print.csv"
if (print.csv == 0) {
  
  message('\n\nacr_agmip2metrics.R complete!\n\nNo results file was created.  To print metrics.csv, set input variable "print.csv" equal to 1. \nView variable \'metric\' in workspace for complete results.\n\n')
  
} else {
    #dir.create(paste(rootDir, 'analysis', sep='\\'), showWarnings = FALSE)
    #dir.create(paste(rootDir, 'analysis\\metrics', sep='\\'), showWarnings = FALSE)
  
  #outfile <- paste(rootDir, '/metrics_', infile[1], '_', analysis.type,'_', clim.var.names[clim.var], '.csv', sep='')
  
  #file.create(output)
  file.create(outfile)
  
  #cat('Metrics for .AgMIP files created', format(Sys.time(),'%d/%m/%Y at %H:%M:%S %Z'), '\n\nFile locations:\n', file = outfile)

  #cat('Metrics for .AgMIP files created', format(Sys.time(),'%d/%m/%Y at %H:%M:%S %Z'), '\n\nFile locations:\n')
  
  #write.table(matrix(c(paste(rootDir, "/",infile.loc, sep='')), nrow = length(infile)), file = outfile, sep=",", row.names = FALSE, col.names = FALSE, append = TRUE)
  
  #cat('\n', file=outfile, append = TRUE)
 
  #cat('\n')

  #write.table(matrix(c('clim.var', 'clim.var.name', 'analysis.type', clim.var, clim.var.names[clim.var], analysis.type), nrow = 2, byrow = TRUE), file = outfile, sep=",", row.names = FALSE, col.names = FALSE, append = TRUE)
  
  #cat('\n', file=outfile, append = TRUE)
  
  #write.table(matrix(c('infile', rep(rep(infile,each = length(jd.start)),length(reference)),
  #                     'jd.start', rep(rep(jd.start,length(infile)), length(reference)),
  #                     'jd.end', rep(rep(jd.end,length(infile)), length(reference)),
  #                     'reference', rep(reference, each = (length(infile)*length(jd.start))),
  #                     'special.operator', 
  #                     rep(special.operator, each = (length(infile)*length(jd.start))),
  #                     rep('', (length(infile)*length(jd.start)*length(reference)+1)),
  #                     'Year',rep('', (length(infile)*length(jd.start)*length(reference)))),
  #                   nrow=7, byrow = TRUE),
  #            file=outfile, sep=",", row.names = FALSE, col.names = FALSE, append = TRUE)

  write.table(matrix(c('Year',infile),
                     nrow=1, byrow = TRUE),
                    file=outfile, sep=",", row.names = FALSE, col.names = FALSE, append = TRUE)

  suppressWarnings(write.table(metric, file=outfile, sep=",", row.names=FALSE, col.names = FALSE,
                               append = TRUE))
  
  message('\n\nacr_agmip2metrics.R complete! \n\nMetric results file saved as...\n\t', 
          paste(rootDir, 'analysis\\metrics\\metrics_', infile[1], '_', analysis.type, '_', 
                clim.var.names[clim.var], '.csv', sep=''), 
          '\n\nComplete results are also stored in variable \'metric\'.\n\n')
  
}

##  Clear all variables except 'metric'
#rm(list = setdiff(ls(),'metric'))

##  Turn echo on
options(echo = TRUE)
}

args<-commandArgs(trailingOnly=TRUE)
#rootDir,jd.start,jd.end,clim.var,analysis.type,reference,special.operator
rootDir<-args[1]
jd.start<-as.numeric(args[2])
jd.end<-as.numeric(args[3])
clim.var<-as.numeric(args[4])
analysis.type<-args[5]
reference<-as.numeric(args[6])
special.operator<-as.numeric(args[7])
outfile<-args[8]

run_acr_agmip2metrics(rootDir,jd.start,jd.end,clim.var,analysis.type,reference,special.operator,outfile)

