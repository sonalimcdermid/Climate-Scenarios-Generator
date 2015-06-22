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
#    controlled vapour pressure based upon daily Tmax in .AgMIP format.  The computations of this
#    script require the relative humidtity from the baseline data file.
#
#  THIS WAS FORMERLY run_cdelta005.R        --  May 24, 2013
#    Updated to be used with the Guide for Running AgMIP Climate Scenario Generation Tools 
#    Updated for Version 2.0 of the Guide   --  July 25, 2013 by Nicholas Hudson
# 	
# 		Author: Alex Ruane
# 									alexander.c.ruane@nasa.gov
#    	Created:	08/20/2012
# 		Translated to R: May 12, 2013 by Nicholas Hudson (nih2106@columbia.edu)
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
run_agmip_simple2full <- function(basefile,rootDir,code,gcms,rcps,decs) {
## Input variables
### These should be the only variables you will have to change for running the script for 
###  another file as long as all files are located in the correct folders

#basefile    <- 'MEDI0XXX'                 ##  .AgMIP basefile name in ~\\R\\data\\Climate\\Historical
end.code    <- paste(substr(basefile,7,7),code,sep='') #'XF'#'XA'                       ##  7th and 8th digit code of future scenario files to be
                                          ##    changed. 1st-4th are determined by basefile, 5th
                                          ##    by run.rcps and run.decs, and 6th by run.gcm
###  run.gcms sets the GCM scenario loop.  Currently set to run all GCMs (1:20) where
###    1 = ACCESS1-0,      2 = bcc-csm1-1,     3 = BNU-ESM,          4 = CanESM2,         
###    5 = CCSM4,          6 = CESM1-BGC,      7 = CSIRO-Mk3-6-0,    8 = GFDL-ESM2,
###    9 = GGFDL-ESM2M,   10 = HadGEM2-CC,    11 = HadGEM2-ES,      12 = inmcm4,
###   13 = IPSL-CM5A-LR,  14 = IPSL-CM5A-MR,  15 = MIROC5,          16 = MIROC-ESM,
###   17 = MPI-ESM-LR,    18 = MPI-ESM-MR,    19 = MRI-CGCM3,       20 = NorESM1-M
run.gcms    <- as.numeric(unlist(strsplit(gcms,',')))#1:20

###  run.rcps sets the RCP scenario loop.  Currently set to run RCP 4.5 (3) and RCP 8.5 (5) where
###    1 = historical, 2 = RCP 2.6, 3 = RCP 4.5, 4 = RCP 6.0, 5 = RCP 8.5
run.rcps    <- as.numeric(unlist(strsplit(rcps,',')))#c(3,5)

###  run.decs sets the Time scenario loop.  Currently set to run all time periods (1:3)
###    where 1 = Near-term (2010-2039), 2 = Mid-Century (2040-2069), 3 = End-of-Century (2070-2099)
run.decs    <- as.numeric(unlist(strsplit(decs,',')))#:3

### You must enter the location of the R folder into rootDir below using \\ between folders.
### For example, 'C:\\Users\\Your Name Here\\Desktop\\R\\'
#rootDir     <- '/Users/weixiong/Development/face-it/RIA/AgMIP_Scenarios_Generator/'           ##  <- Enter location here <- #'*** your directory here ***\\R\\'

###----------------------------------------------------------------------------------------------###
###############  You should not have to adjust any of the variables below this line  ###############
###----------------------------------------------------------------------------------------------###

##  Set directory paths
baseloc     <- paste(rootDir, '/input/', sep='')

##  Source scripts
source('/mnt/galaxyTools/agmip_sce_generator/1.0.0/agmip_simple2full.R')
#source(paste(rootDir, 'r/agmip_simple2full.R', sep=''))

##  Define variables for function loop
baseinfo    <- read.table(paste(baseloc, basefile, '.AgMIP', sep=''), skip=3, nrows=1)
base        <- read.table(paste(baseloc, basefile, '.AgMIP', sep=''), skip=5, sep="")
gcmlist     <- c('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T')
scencode    <- matrix(c('0','0','0','B','F','J','C','G','K','D','H','L','E','I','M'), ncol = 5)
decscode    <- matrix(c(2010,2039,2040,2069,2070,2099), ncol = 3)

##  Check that header of basefile matches basefile name
if (substr(basefile,1,4) != baseinfo$V1) {
  cat('\n\nFirst 4 digits of basefile name, ', substr(basefile,1,4), ', are not the same as the header in the file, ', as.character(baseinfo$V1), '\n', sep='')
  yesno <- readline('Proceed anyways? Yes(1)/No(2): ')
  if (yesno == 2 || yesno == 'n' || yesno == 'N' || yesno == 'no' || yesno == 'No' || yesno == 'NO')
    stop('Run script stopped.  Consider updating header information.', call. = FALSE)
}

##  Run function loop
starttime   <- Sys.time()
cat('\n***** Loop start time = ',format(starttime,'%H:%M:%S'), '\t*****\n\n')
cat('Printing full .AgMIP files to ', rootDir, '/output2/ ...\n', sep='')

for (scendecs in run.decs) {
  futdecs       <- c(decscode[1,scendecs],decscode[2,scendecs])
  
  for (rcp in run.rcps) {
    cat('\nFuture decades = ',futdecs[1], ' to ', futdecs[2], '\nRCP # = ', rcp ,'\nStart  time = ',as.character(format(Sys.time(), "%H:%M:%S ")),'\n')
    flush.console()
    
    for (thisgcm in run.gcms) {
      filename    <- paste(baseinfo$V1, scencode[scendecs,rcp], gcmlist[thisgcm], end.code, sep ='')
      infile      <- paste(rootDir, '/output1/', filename, '.AgMIP', sep ='')
      outfile     <- paste(rootDir, '/output2/',   filename, '.AgMIP', sep ='')
      headerplus  <- paste(filename,' - baseline dates maintained for leap year consistency', sep ='')
      agmip_simple2full(base, infile, outfile, headerplus, baseinfo)
      cat('\t', filename, ' created\n', sep ='')
      flush.console()
    }
  }
}

endtime     <- Sys.time()
cat('\nPrinted full .AgMIP files to ', rootDir, '/output2/ ...', '\n\n', sep='')
cat('***** Loop start time = ',format(starttime,'%H:%M:%S'), '\t*****\n***** Loop end time   = ',format(endtime,'%H:%M:%S'), '\t*****\n***** Loop run time   = ',round(as.numeric(endtime-starttime, units = 'mins'),digits = 0),' mins\t\t*****\n\n\n', sep='')
}
args<-commandArgs(trailingOnly=TRUE)
basefile<-args[2]#'MEDI0XXX'
rootDir<- args[1] #$PWD'/Users/weixiong/Development/face-it/RIA/AgMIP_Scenarios_Generator'
code<-args[3]
gcms<- args[4]
rcps<- args[5]
decs<- args[6]
run_agmip_simple2full(basefile,rootDir,code,gcms,rcps,decs)
