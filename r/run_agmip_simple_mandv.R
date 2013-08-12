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
#         run_agmip_simple_mandv.R
#
#  This script creates delta scenarios from CMIP5 GCMs with mean and variability shifts.  
#
#  General approach:    Need to call agmip_simple_mandv.R
#
#  THIS WAS FORMERLY acr_agmip112.R         --  June 19, 2013
#    Updated to be used with the Guide for Running AgMIP Climate Scenario Generation Tools 
#    Updated for Version 2.0 of the Guide   --  July 25, 2013 by Nicholas Hudson
#
#
#     Author: Alex Ruane
#         					alexander.c.ruane@nasa.gov
#    	Created:	09/04/2012
# 		Translated to R by Nicholas Hudson: June 19, 2013
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
###  These should be the only variables you will have to change for running the script for 
###    another file as long as all files are located in the correct folders
basefile    <- 'USAM0XXX'             ##  .AgMIP base file name in ~\\R\\data\\Climate\\Historical
basedecs 	  <- c(1980, 2009)          ##  Time period of basefile
headerplus  <- 'Ames, Iowa, USA with mean and daily variability changes for Tmax, Tmin, and P' 
                                      ##  Additional header information

###  run.gcms sets the GCM scenario loop.  Currently set to run all GCMs (1:20) where
###    1 = ACCESS1-0,      2 = bcc-csm1-1,     3 = BNU-ESM,          4 = CanESM2,         
###    5 = CCSM4,          6 = CESM1-BGC,      7 = CSIRO-Mk3-6-0,    8 = GFDL-ESM2,
###    9 = GGFDL-ESM2M,   10 = HadGEM2-CC,    11 = HadGEM2-ES,      12 = inmcm4,
###   13 = IPSL-CM5A-LR,  14 = IPSL-CM5A-MR,  15 = MIROC5,          16 = MIROC-ESM,
###   17 = MPI-ESM-LR,    18 = MPI-ESM-MR,    19 = MRI-CGCM3,       20 = NorESM1-M
run.gcms    <- 1:20

###  run.rcps sets the RCP scenario loop.  Currently set to run RCP 8.5 (5) where
###    1 = historical, 2 = RCP 2.6, 3 = RCP 4.5, 4 = RCP 6.0, 5 = RCP 8.5
run.rcps    <- 5   

###  run.decs sets the Time scenario loop.  Currently set to run End-of-Century time period (3)
###    where 1 = Near-term (2010-2039), 2 = Mid-Century (2040-2069), 3 = End-of-Century (2070-2099)
run.decs    <- 3

###  You must enter the location of the R folder into rootDir below using \\ between folders.
###  For example, 'C:\\Users\\Your Name Here\\Desktop\\R\\'
rootDir     <- '*** your directory here ***\\R\\'             ## <- Enter location here <-

###----------------------------------------------------------------------------------------------###
###############  You should not have to adjust any of the variables below this line  ###############
###----------------------------------------------------------------------------------------------###

##  Load required packages
library <- c('R.matlab','R.utils','MASS')
lapply(library, require, character.only = T)
rm(library)

##  Set directory paths
baseloc     <- paste(rootDir, 'data\\Climate\\Historical\\', sep='')
futloc      <- paste(rootDir, 'data\\Climate\\Simplescenario\\', sep='')
deltloc     <- paste(rootDir, 'data\\CMIP5\\climfiles\\', sep='')
latlonloc   <- paste(rootDir, 'data\\CMIP5\\latlon\\', sep='')

##  Source scripts
source(paste(rootDir, 'r\\acr_findspot.R', sep=''))
source(paste(rootDir, 'r\\agmip_simple_mandv.R', sep=''))

##  Define variables for function loop
baseinfo    <- read.table(paste(rootDir, 'data\\Climate\\Historical\\', basefile, '.AgMIP', sep=''), skip=3, nrows=1)
base        <- read.table(paste(rootDir, 'data\\Climate\\Historical\\', basefile, '.AgMIP', sep=''), skip=5, sep='')
rcpname     <- c('historical','rcp26','rcp45','rcp60','rcp85')
gcmname     <- c('ACCESS1-0','bcc-csm1-1','BNU-ESM','CanESM2','CCSM4','CESM1-BGC','CSIRO-Mk3-6-0','GFDL-ESM2G','GFDL-ESM2M','HadGEM2-CC','HadGEM2-ES','inmcm4','IPSL-CM5A-LR','IPSL-CM5A-MR','MIROC5','MIROC-ESM','MPI-ESM-LR','MPI-ESM-MR','MRI-CGCM3','NorESM1-M')
gcmlist     <- c('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T')
scencode    <- matrix(c('0','0','0','B','F','J','C','G','K','D','H','L','E','I','M'), ncol = 5)
decscode    <- matrix(c(2010,2039,2040,2069,2070,2099), ncol = 3)
basedecind  <- ceiling((basedecs-1979)/10)

##  Check that header of basefile matches basefile name
if (substr(basefile,1,4) != baseinfo$V1) {
  cat('\n\nFirst 4 digits of basefile name, ', substr(basefile,1,4), ', are not the same as the header in the file, ', as.character(baseinfo$V1), '\n', sep='')
  yesno <- readline('Proceed anyways? Yes(1)/No(2): ')
  if (yesno == 2 || yesno == 'n' || yesno == 'N' || yesno == 'no' || yesno == 'No' || yesno == 'NO') {
    stop('Run script stopped.  Consider updating header information.', call. = FALSE)
  } else {
    baseinfo$V1 <- substr(basefile,1,4)
  }
}

##  Check baseline period is 3 decades
if ((basedecind[2]-basedecind[1]) != 2)  stop('Baseline reference period is not 3 decades')

##  Run function loop
starttime   <- Sys.time()
cat('\n***** Loop start time = ',format(starttime,'%H:%M:%S'), '\t*****\n\n')
cat('Printing .AgMIP files to ', futloc, ' ...\n\n', sep='')
flush.console()

for (thisgcm in run.gcms) {                   ##  GCM scenario loop
  cat('\nGCM = ', gcmname[thisgcm], '(', gcmlist[thisgcm], ')\t\t\t\tStart time = ',as.character(format(Sys.time(), '%H:%M:%S ')),'\n', sep='')
  flush.console()
  
  ##  Set latitude and longitude
  if(baseinfo$V3 < 0)  baseinfo$V3  <- baseinfo$V3 + 360       ##  Convention here is [0 360]
  
  filepath  <- file.path(paste(latlonloc, gcmname[thisgcm], '_lat.mat', sep=''))
  lat       <- readMat(filepath)$lat
  
  filepath  <- file.path(paste(latlonloc, gcmname[thisgcm], '_lon.mat', sep=''))
  lon       <- readMat(filepath)$lon
  
  findspot  <- acr_findspot(baseinfo$V2, baseinfo$V3, lat, lon)
  thisi     <- findspot$thisj                 ##  YJ: i <- j
  thisj     <- findspot$thisi
  
  ## Historical data
  filepath        <- file.path(paste(deltloc, 'meantasmax_', gcmname[thisgcm], '_historical.mat', sep=''))
  meantasmaxbase  <- readMat(filepath)$meantasmax
  
  filepath        <- file.path(paste(deltloc, 'meantasmin_', gcmname[thisgcm], '_historical.mat', sep=''))
  meantasminbase  <- readMat(filepath)$meantasmin
  
  filepath        <- file.path(paste(deltloc, 'meanpr_', gcmname[thisgcm], '_historical.mat', sep=''))
  meanprbase      <- readMat(filepath)$meanpr
  
  filepath        <- file.path(paste(deltloc, 'stdtasmax_', gcmname[thisgcm], '_historical.mat', sep=''))
  stdtasmaxbase   <- readMat(filepath)$stdtasmax
  
  filepath        <- file.path(paste(deltloc, 'stdtasmin_', gcmname[thisgcm], '_historical.mat', sep=''))
  stdtasminbase   <- readMat(filepath)$stdtasmin
  
  filepath        <- file.path(paste(deltloc, 'fwetpr1_', gcmname[thisgcm], '_historical.mat', sep=''))
  fwetpr1base     <- readMat(filepath)$fwetpr1
  
  for (rcp in run.rcps) {                     ##  RCP scenario loop
    filepath        <- file.path(paste(deltloc, 'meantasmax_', gcmname[thisgcm], '_', rcpname[rcp], '.mat', sep=''))
    meantasmaxfut   <- readMat(filepath)$meantasmax
    
    filepath        <- file.path(paste(deltloc, 'meantasmin_', gcmname[thisgcm], '_', rcpname[rcp], '.mat', sep=''))
    meantasminfut   <- readMat(filepath)$meantasmin
    
    filepath        <- file.path(paste(deltloc, 'meanpr_', gcmname[thisgcm], '_', rcpname[rcp], '.mat', sep=''))
    meanprfut       <- readMat(filepath)$meanpr
    
    filepath        <- file.path(paste(deltloc, 'stdtasmax_', gcmname[thisgcm], '_', rcpname[rcp], '.mat', sep=''))
    stdtasmaxfut    <- readMat(filepath)$stdtasmax
    
    filepath        <- file.path(paste(deltloc, 'stdtasmin_', gcmname[thisgcm], '_', rcpname[rcp], '.mat', sep=''))
    stdtasminfut    <- readMat(filepath)$stdtasmin
    
    filepath        <- file.path(paste(deltloc, 'fwetpr1_', gcmname[thisgcm], '_', rcpname[rcp], '.mat', sep=''))
    fwetpr1fut      <- readMat(filepath)$fwetpr1
    
    for (scendecs in run.decs) {              ##  Time scenario loop
      futdecs       <- c(decscode[1,scendecs],decscode[2,scendecs])
      futdecind     <- ceiling((futdecs-2009)/10)
      outfile       <- paste(substr(basefile,1,4), scencode[scendecs,rcp], gcmlist[thisgcm], substr(basefile,7,7), 'F', sep ='')
      
      ##  Calculate changes in min and max temperature and precipitation
      meantasmaxdelt  <- rowMeans( meantasmaxfut[thisj,thisi,,futdecind[1]:futdecind[2]] - meantasmaxbase[thisj,thisi,,basedecind[1]:basedecind[2]] )
      
      meantasmindelt  <- rowMeans( meantasminfut[thisj,thisi,,futdecind[1]:futdecind[2]] - meantasminbase[thisj,thisi,,basedecind[1]:basedecind[2]] )
      
      meanprdelt      <- rowMeans( meanprfut[thisj,thisi,,futdecind[1]:futdecind[2]] ) / rowMeans(meanprbase[thisj,thisi,,basedecind[1]:basedecind[2]] )
      
      stdtasmaxdelt   <- rowMeans( stdtasmaxfut[thisj,thisi,,futdecind[1]:futdecind[2]] ) / rowMeans(stdtasmaxbase[thisj,thisi,,basedecind[1]:basedecind[2]] )
      
      stdtasmindelt   <- rowMeans( stdtasminfut[thisj,thisi,,futdecind[1]:futdecind[2]] ) / rowMeans(stdtasminbase[thisj,thisi,,basedecind[1]:basedecind[2]] )
      
      fwetpr1delt     <- rowMeans( fwetpr1fut[thisj,thisi,,futdecind[1]:futdecind[2]] ) / rowMeans(fwetpr1base[thisj,thisi,,basedecind[1]:basedecind[2]] )
      
      ##  Cap rainfall deltas at 300% (likely for dry season)
      meanprdelt[is.nan(meanprdelt)] <- 1             ##  Change NaNs to ones
      meanprdelt      <- pmin(meanprdelt,3)
      
      ##  Cap fwetpr1 deltas at 1000% (likely for dry season)
      fwetpr1delt[is.nan(fwetpr1delt)] <- 1           ##  Change NaNs to ones
      fwetpr1delt     <- pmin(fwetpr1delt,10)
      
      ##  Limit minimum fwetpr1 deltas at 25% (likely for dry season)
      fwetpr1delt     <- pmax(fwetpr1delt,0.25)
      
      ##  Set mean and variability change factors
      stdfactor       <- matrix(1,12,12)
      stdfactor[,6]   <- stdtasmaxdelt
      stdfactor[,7]   <- stdtasmindelt
      gamfactor       <- rep(1,12)
      wetfactor       <- fwetpr1delt
      meandelt        <- matrix(1,12,12)
      meandelt[,6]    <- meantasmaxdelt
      meandelt[,7]    <- meantasmindelt
      meandelt[,8]    <- meanprdelt
      
      ##  Remove future scenario delta variables
      rm(meantasmaxdelt, meantasmindelt, meanprdelt, stdtasmaxdelt, stdtasmindelt, fwetpr1delt)
      invisible(gc())
      
      ##  Run agmip_simple_mandv.R
      agmip_simple_mandv(base, outfile, futloc, headerplus, baseinfo, stdfactor, gamfactor, wetfactor, meandelt)
      cat('\t', as.character(outfile), ' created\n', sep='')
      flush.console()
    }  ##  Time scenario loop
    
    ##  Remove future scenario variables
    rm(meantasmaxfut, meantasminfut, meanprfut, stdtasmaxfut, stdtasminfut, fwetpr1fut)
    invisible(gc())
    
  }  ##  RCP scenario loop
  
  ##  Remove base scenario variables
  rm(meantasmaxbase, meantasminbase, meanprbase, stdtasmaxbase, stdtasminbase, fwetpr1base)
  invisible(gc())
  
}  ##  GCM scenario loop

endtime     <- Sys.time()
cat('\nPrinted .AgMIP files to ', futloc, '\n\n', sep='')
cat('***** Loop start time = ',format(starttime,'%H:%M:%S'), '\t*****\n***** Loop end time   = ',format(endtime,'%H:%M:%S'), '\t*****\n***** Loop run time   = ',round(as.numeric(endtime-starttime, units = 'mins'),digits = 0),' mins\t\t*****\n\n\n', sep='')