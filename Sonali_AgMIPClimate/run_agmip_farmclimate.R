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
#     		run_agmip_farmclimate.R
# 
#  Runs agmip_farmclimate.R to produces baseline .AgMIP files for a series of locations (farms) in a
#    given region
#
# 	
# 		Author: Alex Ruane
# 									alexander.c.ruane@nasa.gov
#    	Created:	02/13/2013
# 		Translated to R: 05/31/2013 by Nicholas Hudson (nih2106@columbia.edu)
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
###  These should be the only variables you will have to change for running the script with 
###    another file as long as all files are located in the correct folders
seedfile    <- 'KEMB0XXX'                             ##  .AgMIP seed file name in 
                                                      ##      ~\\R\\data\\Climate\\Historical
shortregion <- 'MB'                                   ##  Short name for output file
headerplus  <- 'Embu, Kenya'                          ##  Additional header information

sitelat     <- c(-0.55, -00.70, -00.60, -00.75)       ##  Site latitudes,  1st site is station
sitelon     <- c(37.46,  37.54,  37.58,  37.69)       ##  Site longitudes, 1st site is station
refht       <- -99                                    ##  Station thermometer height
wndht       <- -99                                    ##  Station anemometer height

###  You must enter the location of the R folder into rootDir below using \\ between folders.
###  For example, 'C:\\Users\\Your Name Here\\Desktop\\R\\'
rootDir     <- '*** your directory here ***\\R\\'     ## <- Enter location here <-

###  Also, you must identify the WorldClim subregion where your met station and farm sites are
###    located with the input variable datashort.
datashort   <- 'EAfrica'                              ##  WorldClim subregion

###  All of these files should have an 'F' in the seventh digit to denote 2.5 minute WorldClim
###    was used.  You should not need to adjust this variable.
outend      <- '0XFX'                                 ##  F in seventh digit = WorldClim

##  Check outend
if (substr(outend,3,3)!='F') cat('OUTEND SHOULD HAVE F IN 3RD DIGIT FOR WORLDCLIM CLIMATE ZONES')

##  Load required packages
library <- c("R.matlab","R.utils")
lapply(library, require, character.only = T)
rm(library)

##  Source scripts
source(paste(rootDir, 'r\\agmip_farmclimate.R', sep=''))

##  Run function
starttime   <- format(Sys.time(), "%H:%M:%S ")
cat('***** Start time = ',starttime, ' *****\n')

agmip_farmclimate(seedfile,shortregion,headerplus,sitelat,sitelon,refht,wndht,outend,rootDir,datashort)

endtime     <- format(Sys.time(), "%H:%M:%S ")
cat('***** Start time = ',starttime, ' *****','\n***** End time   = ',endtime, ' *****','\n')