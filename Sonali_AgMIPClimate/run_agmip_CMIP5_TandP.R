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
#   			run_agmip_CMIP5_TandP.R
# 
#  Runs agmip_CMIP5_TandP_nobase.R to produce GCM #  This script analyzes CMIP5 Model output for a given location and 
#  makes a scatterplot showing which model is which.  This one doesn't need a baseline file, so everything is placed 
#  in deltaT, deltaP rather than raw values
#
# 		Author: Alex Ruane
# 									alexander.c.ruane@nasa.gov
#    	Created:date:  07/02/13
# 		Translated to R: 05/1/2015 by John Simmons (jms2402@columbia.edu)
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
shortname = 'INTR' #used for saving figures
stnname = 'Trichy, India';
stnlat = 10.750;
stnlon = 78.600;
mmstart = 9;
mmend = 12;
thisrcp = 'rcp45';
thisfut = 'mid';

# if Basefile exists and is located in baseloc, set to 1
# otherwise set to 0
Basefile = 1

#Optional Variables - for plotting - 
Tmin = NaN;
Tmax = NaN;
Pmin = NaN;
Pmax = NaN; 

### You must enter the location of the R folder into rootDir below using \\ between folders.
### For example, 'C:\\Users\\Your Name Here\\Desktop\\R\\'
rootDir     <- '/Users/sonalimcdermid/Research/R/'   

## <- Enter figure location here <-
figDir <- '/Users/sonalimcdermid/Desktop/' 

programDir  <- paste(rootDir, 'r/', sep='')
dataDir     <- paste(rootDir, 'data/', sep='')
baseloc  <- paste(dataDir, 'Climate/Historical/', sep='')
histfile    <- paste(baseloc,shortname,'0XXX.AgMIP', sep='') # Don't need whole filename here, as it pulls the shortname above. Make sure to note last 3 digits

############################ No need to edit beyond this line ######################
## Load required packages
library <- c("R.matlab","R.utils")
lapply(library, require, character.only = T)
rm(library)

## Source scripts
source(paste(programDir, 'acr_findspot.R', sep=''))
source(paste(programDir, 'agmip_CMIP5_TandP.R', sep=''))


# Plot deltT and deltP from Global Climate models
  agmip_CMIP5_TandP(rootDir,figDir,Basefile,histfile,shortname,stnname,stnlat,stnlon,
    mmstart,mmend,thisrcp,thisfut,Tmin,Tmax,Pmin,Pmax)


