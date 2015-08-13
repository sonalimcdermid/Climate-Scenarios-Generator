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

# Sonali edit 11/26/2014. # Want to construct a loop to go through files in a directory. Use this to loop. If you don't want to loop, then comment out the full loop and specify "shortfile" to "basedecs"
# lat <- matrix(c(26.222,24.806,24.160,22.722,22.750,22.060,22.080,21.830,21.833,23.840,23.330,22.600,23.334,24.030,25.670,23.280,23.520,22.080,23.830,24.396), ncol=1)
# lon <- matrix(c(78.178,78.863,80.830,75.866,77.720,78.940,79.530,76.340,77.833,79.450,77.800,75.300,75.037,75.080,78.470,81.350,77.810,73.330,78.710,81.880), ncol=1)
# shortname <- c('MP01','MP02','MP03','MP04','MP05','MP06','MP07','MP08','MP09','MP10','MP11','MP12','MP13','MP14','MP15','MP16','MP17','MP18','MP19','MP20')
# #files <- list.files(path="/Users/sps246/Research/R/data/Climate/Historical/", pattern="MP*.AgMIP", full.names=T, recursive=FALSE)
# files = matrix(c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20),ncol=1)
	# for(i in 1:length(files)) {

# shortfile 	<- shortname[i]
# stnlat 	<- lat[i]
# stnlon 	<- lon[i]
# stnelev 	<- 0 #For Mohanty's MP sites, none was provided
# basedecs 	<- c(1980, 2009)



 shortfile 	<- 'INCO'
 stnlat 	<- 11.000
 stnlon 	<- 77.000
 stnelev 	<- 427
 refht 	<- -99;
 wndht 	<- -99;


### You must enter the location of the R folder into rootDir below using \\ between folders.
### For example, 'C:\\Users\\Your Name Here\\Desktop\\R\\'
rootDir     <- '/Users/sps246/Research/R/'             ## <- Enter location here <-
programDir  <- paste(rootDir, '/r/', sep='')
dataDir     <- paste(rootDir, '/data/Climate/', sep='')
baseloc	<- paste(dataDir, '/Historical/', sep='')

## Source scripts
source(paste(programDir, 'agmip_simple2full.R', sep=''))

## Run function loop
basefile    <- paste(baseloc,shortfile,'0XXX.AgMIP', sep='')
gcmlist     <- c('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T')
scencode    <- c('C','E','G','I','K','M')
##scencode    <- c('E','I','M')
starttime   <- format(Sys.time(), "%H:%M:%S ")
cat('***** Loop start time = ',starttime, ' *****\n')
for (scen in 1:length(scencode)){
  cat('\nScenario code = ',scencode[scen],'\nStart  time = ',as.character(format(Sys.time(), "%H:%M:%S ")),'\n')
  for (thisgcm in 1:length(gcmlist)){
    futname     <- paste(shortfile,scencode[scen],gcmlist[thisgcm],'XA', sep ='')
    futfile     <- paste(dataDir, '/Simplescenario/', futname, '.AgMIP', sep ='')
    outfile     <- paste(dataDir, '/Fullscenario/',futname, '.AgMIP', sep ='')
    headerplus  <- paste(futname, ' - baseline dates maintained for leap year consistency', sep ='')
    cat('Future name = ',futname,'\n', sep ='')
    agmip_simple2full(basefile,futfile,outfile,headerplus,shortfile,stnlat,stnlon,stnelev,refht,wndht)
  }
}
endtime     <- format(Sys.time(), "%H:%M:%S ")
cat('***** Loop start time = ',starttime, ' *****','\n***** Loop end time   = ',endtime, ' *****','\n')

#}