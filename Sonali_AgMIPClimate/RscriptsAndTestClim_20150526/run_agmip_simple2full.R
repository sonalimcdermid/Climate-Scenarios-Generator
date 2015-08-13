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
#     			run_agmip_simple2full.R
# 
#  Runs agmip_simple2full.R to produce converted full future scenario files with relative humidity-
#    controlled vapour pressure based upon daily Tmax in .AgMIP format.
#
#  THIS WAS FORMERLY run_cdelta005.R -- May 24, 2013
#    Updated to be used with Guide for running AgMIP Climate Scenario GenerationTools
# 	
# 		Author: Alex Ruane
# 									alexander.c.ruane@nasa.gov
#    	Created:	08/20/2012
# 		Translated to R: 05/12/2013 by Nicholas Hudson (nih2106@columbia.edu)
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

## Input variables
### These should be the only variables you will have to change for running the script for 
###  another file as long as all files are located in the correct folders
shortfile   <- 'USAM'
stnlat 	<- 42.017
stnlon 	<- -93.750
stnelev 	<- 329
refht 	<- -99;
wndht 	<- -99;

### You must enter the location of the R folder into rootDir below using \\ between folders.
### For example, 'C:\\Users\\Your Name Here\\Desktop\\R\\'
rootDir     <- '*** your directory here ***\\R\\'             ## <- Enter location here <-
programDir  <- paste(rootDir, 'r\\', sep='')
dataDir     <- paste(rootDir, 'data\\Climate\\', sep='')
baseloc	<- paste(dataDir, 'Historical\\', sep='')

## Source scripts
source(paste(programDir, 'agmip_simple2full.R', sep=''))

## Run function loop
basefile    <- paste(baseloc,shortfile,'0XXX.AgMIP', sep='')
gcmlist     <- c('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T')
scencode    <- c('C','E','G','I','K','M')
starttime   <- format(Sys.time(), "%H:%M:%S ")
cat('***** Loop start time = ',starttime, ' *****\n')
for (scen in 1:length(scencode)){
  cat('\nScenario code = ',scencode[scen],'\nStart  time = ',as.character(format(Sys.time(), "%H:%M:%S ")),'\n')
  for (thisgcm in 1:length(gcmlist)){
    futname     <- paste(shortfile,scencode[scen],gcmlist[thisgcm],'XA', sep ='')
    futfile     <- paste(dataDir, 'Simplescenario\\', futname, '.AgMIP', sep ='')
    outfile     <- paste(dataDir, 'Fullscenario\\',futname, '.AgMIP', sep ='')
    headerplus  <- paste(futname, ' - baseline dates maintained for leap year consistency', sep ='')
    cat('Future name = ',futname,'\n', sep ='')
    agmip_simple2full(basefile,futfile,outfile,headerplus,shortfile,stnlat,stnlon,stnelev,refht,wndht)
  }
}
endtime     <- format(Sys.time(), "%H:%M:%S ")
cat('***** Loop start time = ',starttime, ' *****','\n***** Loop end time   = ',endtime, ' *****','\n')