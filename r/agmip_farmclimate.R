###################################################################################################
#    	agmip_farmclimate
#
#  This script produces baseline .AgMIP files for a series of locations (farms) in a given region.
#
#  This requires a seed file (in .AgMIP format) from within the region in order to calibrate the
#    region.  Any seed file can be used (baseline or future scenario, provided that a .AgMIPm file
#    exists).  The seed station where met. observations are made should be the first site listed in
#    the input variable sitelist.
#
#  This can produce strange values at high elevations, as humidities would be higher and orographic 
#    precipitation is not well captured.
#
#  Includes elements from agmip_simple_delta.R (formerly acr_agmip004.m) for delta method and
#    agmip_simple2full.R (formerly acr_agmip005.m) to adjust moisture variables with new 
#    temperatures.
#
#  Note that all of these should have an 'F' in the seventh digit to denote 2.5 minute WorldClim
#    was used.
#
#  THIS WAS FORMERLY acr_agmip022.m and acr_agmip021.m  --  May 31, 2013
#    Updated to be used with the Guide for Running AgMIP Climate Scenario Generation Tools 
#    Updated for Version 2.0 of the Guide   --  July 25, 2013 by N. Hudson
#    Updated to handle negative Vprs values and NaN Dewp values  -- August 13, 2013 by N. Hudson
#    Updated to correct NaNs created in sitechangeP calculation -- August 29, 2013  by N. Hudson
#    Updated to ensure Vprs >= 0.1          --  November 20, 2013 by N. Hudson
#      
#
#     Author: Alex Ruane
#       						alexander.c.ruane@nasa.gov
#    	Created:	02/13/2013 (acr_agmip022.m) and 01/10/12 (acr_agmip021.m)
# 		Translated to R and compiled by Nicholas Hudson: May 31, 2013
#
###################################################################################################

agmip_farmclimate <- function(seedfile,shortregion,headerplus,sitelat,sitelon,rootDir,dataDir,datashort) {
  
  ##  Begin debug
#   seedfile    <- 'KEMB0XXX'                             ##  .AgMIP seed file name in 
#                                                         ##      ~\\R\\data\\Climate\\Historical
#   shortregion <- 'MB'                                   ##  Short name for output file
#   headerplus  <- 'Embu, Kenya'                          ##  Additional header information
#   sitelat     <- c(-00.70, -00.60, -00.75)              ##  Latitudes of farm sites
#   sitelon     <- c( 37.54,  37.58,  37.69)              ##  Longitudes of farm sites
#   rootDir     <- '*** your directory here ***\\R\\'     ##  <- Enter location here <-
#   datashort   <- 'EAfrica'                              ##  WorldClim subregion
#     
#   ## Load required packages
#   library <- c("R.matlab","R.utils")
#   lapply(library, require, character.only = T)
#   rm(library)
#     
  ##  End debug
  
  ##  Check that the number of sites to be produced is <100 and that the # of sites are the same
  if (length(sitelat) > 99 || length(sitelon) > 99) stop('>99 sites entered.  There must be <100 sites for this naming convention.  Divide region and assign different "shortregion" codes to ensure the number of sites is <100.')
  if (length(sitelat)  != length(sitelon)) stop('The variables sitelat (', length(sitelat) ,') and sitelon (', length(sitelon) ,') are of different lengths.  Check these vectors to ensure latitudes and longitudes correctly correspond to the desired site locations.')
  
  ##  Load data
  subTmean  <- readMat(paste(dataDir, '/data/WorldClim/', datashort, '_subTmean.mat', sep=''))$subTmean
  subPrec   <- readMat(paste(dataDir, '/data/WorldClim/', datashort, '_subPrec.mat' , sep=''))$subPrec
  subAlt    <- readMat(paste(dataDir, '/data/WorldClim/', datashort, '_subAlt.mat'  , sep=''))$subAlt
  sublat    <- readMat(paste(dataDir, '/data/WorldClim/', datashort, '_sublat.mat'  , sep=''))$sublat
  sublon    <- readMat(paste(dataDir, '/data/WorldClim/', datashort, '_sublon.mat'  , sep=''))$sublon
  baseinfo  <- read.table(paste(rootDir, '/input/', seedfile, '.AgMIP', sep=''), skip=3, nrows=1)
  base      <- read.table(paste(rootDir, '/input/', seedfile, '.AgMIP', sep=''), skip=5, sep="")
  
  ##  Create vector with station lat/lon
  full.lat  <- c(baseinfo$V2, sitelat)
  full.lon  <- c(baseinfo$V3, sitelon)
  
  ##  For each site, extract the mean climatology
  subT      <- matrix(NaN,12,length(full.lat))
  subP      <- matrix(NaN,12,length(full.lat))
  subA      <- matrix(NaN,   length(full.lat))
  
  for (thissite in 1:length(full.lat)){
    stni    <- which.min(abs(sublon[1,] - full.lon[thissite]))
    stnj    <- which.min(abs(sublat[,1] - full.lat[thissite]))
    if ((stni == 1)||(stnj == 1)||(stni == ncol(sublon))||(stnj == nrow(sublat))){
      cat('WARNING -- END POINT SELECTED.  ARE LATITUDE/LONGITUDE SIGNS CORRECT?')
    }
    for (mm in 1:12){
      subT[mm,thissite] <- subTmean[stnj,stni,mm]
      subP[mm,thissite] <- subPrec [stnj,stni,mm]
    }
    subA[thissite]      <- subAlt[stnj,stni]
  }
  
  ##  Calculate saturation vapor pressure from T
  ###  Clausius-Clapeyron from Curry and Webster page 112
  ###  es = eos*exp(Lv/Rv*(1/To - 1/T))
  ###  Td = 1/((1/To)-(Rv/Lv)*log(e/eos))
  ###  RH = e/es * 100
  eos <- 6.11         # hPa
  Lv  <- 2.5e6        # J/kg
  To  <- 273.16       # K
  Rv  <- 461          # J/K/kg
  eps <- 0.622        # =(Mv/Md)
  
  ##  Set number of days/month
  mmtick    <- c(0,31,28,31,30,31,30,31,31,30,31,30,31)
  mmcum     <- cumsum(mmtick)
  mmcumleap <- mmcum + c(0,0,1,1,1,1,1,1,1,1,1,1,1)
  
  ##  Calculate deltas from seed for each site
  sitechangeT <- matrix(NaN,dim(subT)[1],length(sitelat))
  sitechangeP <- matrix(NaN,dim(subT)[1],length(sitelat))         
  
  for (thissite in 1:length(sitelat)){
    sitechangeT[,thissite]  <- subT[,thissite + 1]-subT[,1]
    sitechangeP[,thissite]  <- subP[,thissite + 1]/subP[,1]                    
  }
  
    ##  Check for whole months of missing rainfall in seed (if so, don't change rainfall)
  sitechangeP[is.infinite(sitechangeP)] <- 1
  sitechangeP[is.na(sitechangeP)]       <- 0 
  
  ###--------------------------------------------------------------------------------------------###
  ##################################################################################################
  ###--------------------------------------------------------------------------------------------###
  
  ##  Print .AgMIP files
  cat('Printing .AgMIP files to ', rootDir, '/output/ ...\n\n', sep='')
  flush.console()
  for (thissite in 1:length(sitelat)) {
    if ((thissite)<10)    sitez <- paste(0, as.character(thissite), sep='')
    if ((thissite)>10)    sitez <- as.character(thissite)
    filename  <- paste(shortregion, sitez, substr(seedfile,5,6), 'F', substr(seedfile,8,8), sep='')
    outfile   <- paste(rootDir, '/output/', filename, '.AgMIP', sep='')
    Tdelt     <- sitechangeT[,thissite]
    Pdelt     <- sitechangeP[,thissite]
    
    ##  Cap rainfall deltas at 300% (likely for dry season or near mountain peaks)
    Pdelt   <- pmin(Pdelt,3)
    
    ##  Correct for Y2K, etc., if necessary
    ddate   <- base[,1]
    newscen <- base
    es      <- matrix(NaN,length(ddate))
    
    for (dd in 1:length(ddate)){
      jd      <- ddate[dd] %% 1000
      yy      <- floor(ddate[dd]/1000)
      thismm  <- max(which(jd>mmcum))
      
      if ((yy %% 4)==0)   thismm <- max(which(jd>mmcumleap))
      
      newscen[dd,6]   <- base[dd,6] + Tdelt[thismm]
      newscen[dd,7]   <- base[dd,7] + Tdelt[thismm]
      newscen[dd,8]   <- min(base[dd,8] * Pdelt[thismm],999.9)  #  Ensure no formatting issue
      
      ##  Use Relative Humidity to calculate Vapor Pressure and Dew Point Temperature
      if (newscen[dd,12] != -99) {
        es[dd] <- eos*exp(Lv/Rv*(1/To - 1/(newscen[dd,6]+To)))
        newscen[dd,11]  <- newscen[dd,12]/100 * es[dd]
		
		##  Add check to ensure Vprs >= 0.1
		if (newscen[dd,11] < 0.1) newscen[dd,11] <- 0.1
		
        newscen[dd,10]  <- 1/((1/To)-(Rv/Lv)*log(newscen[dd,11]/eos)) - To
      } else {
        newscen[dd,11]  <- -99.0
        newscen[dd,10]  <- -99.0
      }     
    }
    
    ##  Calculate Tave and Tamp
    Tave    <- mean(c(newscen[,6],newscen[,7]))
    Tmonth  <- matrix(NaN,length(thismm))
    
    for (thismm in 1:12){
      Tmonth[thismm] <- mean(c(newscen[which(newscen[,3]==thismm),6],newscen[which(newscen[,3]==thismm),7]))
    }    
    
    Tamp    <- (max(Tmonth)-min(Tmonth))/2
    
    ## Write it all out with proper station code in basic AgMIP format 
    sink(outfile)
    
    cat('*WEATHER DATA : ', headerplus,', ', seedfile,', cast to site ', sitez, ' using WorldClim-derived climatological differences \n',sep='')
    cat('\n')
    cat(sprintf('%54s', '@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT'),'\n')
    
    ##  Don't forget to adjust reference height for temperature and winds
    cat(sprintf('%4s%0s%9.3f%9.3f%6.0f%6.1f%6.1f%6.1f%6.1f', shortregion, sitez, sitelat[thissite], sitelon[thissite], subA[thissite + 1], Tave, Tamp, -99.0, -99.0),'\n')
    cat(sprintf("%s", "@DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND  DEWP  VPRS  RHUM"),"\n")
    
    ##  And add the newly created data...
    for (dd in 1:length(ddate)){
      cat(sprintf('%7s%6s%4s%4s%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.0f\n',as.character(newscen[dd,1]),as.character(newscen[dd,2]),as.character(newscen[dd,3]),as.character(newscen[dd,4]),newscen[dd,5],newscen[dd,6],newscen[dd,7],newscen[dd,8],newscen[dd,9],newscen[dd,10],newscen[dd,11],newscen[dd,12]))
    }
    
    sink()
    cat('\t', paste(shortregion, sitez, substr(seedfile,5,6), 'F', substr(seedfile,8,8), '.AgMIP created\n', sep=''))
    flush.console()
  }
}