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
#    Updated to be used with the Guide for Running AgMIP Climate Scenario Generation Tools 
#    Updated for Version 2.0 of the Guide   --  July 25, 2013 by Nicholas Hudson
#
# 	
# 		Author: Alex Ruane
# 									alexander.c.ruane@nasa.gov
#    	Created:	02/13/2013
# 		Translated to R: May 31, 2013 by Nicholas Hudson (nih2106@columbia.edu)
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
###  These should be the only variables you will have to change to run the script
run_agmip_farmclimate <- function(rootDir,dataDir,seedfile,shortregion,headerplus,sitelat,sitelon,datashort){
#seedfile    <- 'KEMB0XXX'                             ##  .AgMIP seed file name in 
                                                      ##      ~\\R\\data\\Climate\\Historical
#shortregion <- 'MB'                                   ##  Short name for output file
#headerplus  <- 'Embu, Kenya'                          ##  Additional header information, fill in the
                                                      ##    name of the station location here
#sitelat     <- c(-00.70, -00.60, -00.75)              ##  Latitudes of farm sites
#sitelon     <- c( 37.54,  37.58,  37.69)              ##  Longitudes of farm sites

###  You must enter the location of the R folder into rootDir below using \\ between folders.
###    For example, 'C:\\Users\\Your Name Here\\Desktop\\R\\'
#rootDir     <- '*** your directory here ***\\R\\'     ##  <- Enter location here <-
#rootDir<-'/mnt/galaxyTools/agmip_sce_generator/1.0.0'

###  You must also identify the WorldClim subregion where your met station and farm sites are
###    located with the input variable datashort described in the Guide.
#datashort   <- 'EAfrica'                              ##  WorldClim subregion

###----------------------------------------------------------------------------------------------###
###############  You should not have to adjust any of the variables below this line  ###############
###----------------------------------------------------------------------------------------------###

##  Load required packages
library <- c("R.matlab","R.utils")
lapply(library, require, character.only = T)
rm(library)

##  Source scripts
#source(paste(rootDir, 'r/agmip_farmclimate.R', sep=''))
source('/mnt/galaxyTools/agmip_sce_generator/1.0.0/agmip_farmclimate.R')

##  Run function
starttime   <- Sys.time()
cat('\n***** Loop start time = ',format(starttime,'%H:%M:%S'), '\t*****\n\n')
flush.console()

agmip_farmclimate(seedfile,shortregion,headerplus,sitelat,sitelon,rootDir,dataDir,datashort)

endtime     <- Sys.time()
cat('\nPrinted .AgMIP files to ', rootDir, '/output/ ...', '\n\n', sep='')
cat('***** Loop start time = ',format(starttime,'%H:%M:%S'), '\t*****\n***** Loop end time   = ',format(endtime,'%H:%M:%S'), '\t*****\n***** Loop run time   = ',round(as.numeric(endtime-starttime, units = 'mins'),digits = 0),' mins\t\t*****\n\n\n', sep='')
}

args<-commandArgs(trailingOnly=TRUE)
rootDir<-args[1]
dataDir<-args[2]
seedfile<-args[3]
shortregion<-args[4]
headerplus<-args[5]
sitelat<-c(-00.70, -00.60, -00.75)#args[6]#
sitelon<-c( 37.54,  37.58,  37.69)#args[7]#
datashort<-"EAfrica"#args[8]
run_agmip_farmclimate(rootDir,dataDir,seedfile,shortregion,headerplus,sitelat,sitelon,datashort)