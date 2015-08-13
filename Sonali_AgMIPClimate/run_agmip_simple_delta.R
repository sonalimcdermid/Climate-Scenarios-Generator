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
#   			run_agmip_simple_delta.R
# 
#  Runs agmip_simple_delta.R to produce converted basic future scenario files in .AgMIP format
#
#  THIS WAS FORMERLY run_agmip004_cmip5.R -- May 24, 2013
#    Updated to be used with Guide for running AgMIP Climate Scenario GenerationTools
#
# 	
# 		Author: Alex Ruane
# 									alexander.c.ruane@nasa.gov
#    	Created:	08/20/2012
# 		Translated to R: 05/10/2013 by Nicholas Hudson (nih2106@columbia.edu)
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

# Sonali Edit 11/26/2014 Want to construct a loop to go through files in a directory. Use this to loop. If you don't want to loop, then comment out the full loop and specify "shortfile" to "basedecs"
#-------------------------------------------------------

# If you are doing multiple files, you can load the site info in here to aid in constructing the loop (and that way each file does not need to be done "by hand" separately.)
#lat <- matrix(c(23.25,23.1667,23.2000,24.640,24.270,21.9667,22.9500,22.9167,22.7700,24.450,21.8231,25.4300,26.5000), ncol=1)
#lon <- matrix(c(77.4167,79.933,77.080,77.320,80.1700,80.333,81.083,79.1667,74.600,74.8700,75.6103,77.6500,78.0000), ncol=1)
#shortname <- c('MO01','MO02','MO03','MO04','MO05','MO06','MO07','MO08','MO09','MO10','MO11','MO12','MO13')
#files = matrix(c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20),ncol=1)

# Alternatively, you can load your lat, lons, and shortnames into a csv file (check the file for new line endings - press return after last value if in doubt in generic text editor). Make sure that your lats, lons, and shortnames are in the same order of the files in your directory (which are read into R). If in doubt, check "files" below to see the order in which they are being read in. 
# info <- read.csv('/Users/sonalimcdermid/Research/R/data/Climate/Historical/siteinfo.csv', head=TRUE,sep=",")
# lat <- info$lat
# lon <- info$lon
# shortname <- info$shortname
# files <- list.files(path="/Users/sonalimcdermid/Research/R/data/Climate/Historical/", pattern="*0XXX.AgMIP", full.names=T, recursive=FALSE)

	# for(i in 1:length(files)) {

# shortfile 	<- shortname[i]
# stnlat 	<- lat[i]
# stnlon 	<- lon[i]
# stnelev 	<- 427 #For Mohanty's MP sites, none was provided
# basedecs 	<- c(1980, 2009)
#-------------------------------------------------------

# Use this to just specify one site, and remove the full loop above and at the end of the script	
shortfile 	<- 'INCO'
stnlat 	<- 11.000
stnlon 	<- 77.000
stnelev 	<- 0 #For Mohanty's MP sites, none was provided
basedecs 	<- c(1980, 2009)

### You must enter the location of the R folder into rootDir below using \\ between folders.
### For example, 'C:\\Users\\Your Name Here\\Desktop\\R\\'
rootDir     <- '/Users/sonalimcdermid/Research/R/'             ## <- Enter location here <-
programDir  <- paste(rootDir, '/r/', sep='')
dataDir     <- paste(rootDir, '/data/', sep='')
baseloc	<- paste(dataDir, '/Climate/Historical/', sep='')
futloc      <- paste(dataDir, '/Climate/Simplescenario/', sep='')
deltloc     <- paste(dataDir, '/CMIP5/climfiles/', sep='')
latlonloc   <- paste(dataDir, '/CMIP5/latlon/', sep='')

## Load required packages
library <- c("R.matlab","R.utils")
lapply(library, require, character.only = T)
rm(library)

## Source scripts
source(paste(programDir, 'acr_findspot.R', sep=''))
source(paste(programDir, 'agmip_simple_delta.R', sep=''))

## Run function loop
basefile    <- paste(baseloc,shortfile,'0XXX.AgMIP', sep='') # Don't need whole filename here, as it pulls the shortname above. Make sure to note last 3 digits
gcmlist     <- c('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T')
scencode    <- c('C','E','G','I','K','M')
scengcm     <- c(3,5)
decscode    <- matrix(c(2010,2039,2040,2069,2070,2099), ncol = 3)
starttime   <- format(Sys.time(), "%H:%M:%S ")
cat('***** Loop start time = ',starttime, ' *****\n')
for (scen in 1:length(scencode)){
  futdecs   <- c(decscode[1,ceiling(scen/2)],decscode[2,ceiling(scen/2)])
  rcp       <- scengcm[(scen%%2 == 0)+1]
  cat('\nFuture decades = ',futdecs[1], ' to ', futdecs[2], '\nRCP # = ', rcp ,'\nStart  time = ',as.character(format(Sys.time(), "%H:%M:%S ")),'\n')
  for (thisgcm in 1:length(gcmlist)){
    futname <- paste(shortfile,scencode[scen],gcmlist[thisgcm],'XA', sep ='')
    cat('Future name = ',as.character(futname),'\n')
    agmip_simple_delta(basefile,deltloc,latlonloc,futloc,futname,shortfile,stnlat,stnlon,stnelev,basedecs,futdecs,rcp,thisgcm)
  }
}
endtime     <- format(Sys.time(), "%H:%M:%S ")
cat('***** Loop start time = ',starttime, ' *****','\n***** Loop end time   = ',endtime, ' *****','\n')

#Make sure to comment this out when not looping through all files in the directory
#}