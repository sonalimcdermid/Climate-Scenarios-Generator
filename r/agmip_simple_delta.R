###################################################################################################
#    	agmip_simple_delta
#
#  This script creates delta scenarios from CMIP5 GCMs and BCSD in the AgMIP standard format.
#
#  This can ingest files in both .AgMIP and .wthm/.wtgm formatted baselines.
#  
#  THIS WAS FORMERLY acr_agmip004_cmip5.R   --  May 24, 2013 by Nicholas Hudson
#    Updated to be used with the Guide for Running AgMIP Climate Scenario Generation Tools 
#    Updated for NaN rainfall               --  June 5, 2013 by Nicholas Hudson
#    Updated to ensure Tmax > Tmin          --  July 16, 2013 by Nicholas Hudson
#    Updated for Version 2.0 of the Guide   --  July 25, 2013 by Nicholas Hudson
#
#     Author: Alex Ruane
#   								alexander.c.ruane@nasa.gov
#    	Created:	11/09/2012
# 		Translated to R by Yunchul Jung: 11/15/2012
#
#
#       Here's my minimal key for a file
#
#       First 4 Digits describe location (e.g. OBRE, FL11)
#
#       Fifth Digit is time period and emissions scenario:
#       0 = 1980-2009 baseline 
#       1 = A2-2005-2035 (Near-term)
#       2 = B1-2005-2035 (Near-term)
#       3 = A2-2040-2069 (Mid-Century)
#       4 = B1-2040-2069 (Mid-Century)
#       5 = A2-2070-2099 (End-of-Century)
#       6 = B1-2070-2099 (End-of-Century)
#       S = sensitivity scenario
#       A = observational time period (determined in file)
#		    B = RCP 2.6	 2010-2039 (Near-term)
#		    C = RCP 4.5  2010-2039 (Near-term)
#		    D = RCP 6.0  2010-2039 (Near-term)
#		    E = RCP 8.5  2010-2039 (Near-term)
#		    F = RCP 2.6  2040-2069 (Mid-Century)
#		    G = RCP 4.5  2040-2069 (Mid-Century)
#		    H = RCP 6.0  2040-2069 (Mid-Century)
#		    I = RCP 8.5  2040-2069 (Mid-Century)
#		    J = RCP 2.6  2070-2099 (End-of-Century)
#		    K = RCP 4.5  2070-2099 (End-of-Century)
#		    L = RCP 6.0  2070-2099 (End-of-Century)
#		    M = RCP 8.5  2070-2099 (End-of-Century)
#
#       Sixth Digit is source of baseline data (if baseline scenario)::
#       X = no GCM used
#       0 = imposed values (sensitivity tests)
#       Q = Bias-corrected MERRA
#       T = NASA POWER
#       U = NARR
#       V = Bias-corrected CFSR
#       W = MERRA
#       Y = NCEP CFSR
#       Z = NCEP/DoE Reanalysis-2
#
#       Sixth Digit is GCM (if CMIP3 scenario)::
#       X = no GCM used
#       0 = imposed values (sensitivity tests)
#       A = bccr
#       B = cccma cgcm3
#       C = cnrm
#       D = csiro
#       E = gfdl 2.0
#       F = gfdl 2.1
#       G = giss er
#       H = inmcm 3.0
#       I = ipsl cm4
#       J = miroc3 2 medres
#       K = miub echo g
#       L = mpi echam5
#       M = mri cgcm2
#       N = ncar ccsm3
#       O = ncar pcm1
#       P = ukmo hadcm3
#
#       Sixth Digit is GCM (if CMIP5 scenario):
#       0 = imposed values (sensitivity tests)
#       A = ACCESS1-0
#       B = bcc-csm1-1
#       C = BNU-ESM
#       D = CanESM2
#       E = CCSM4
#       F = CESM1-BGC
#       G = CSIRO-Mk3-6-0
#       H = GFDL-ESM2G
#       I = GFDL-ESM2M
#       J = HadGEM2-CC
#       K = HadGEM2-ES
#       L = inmcm4
#       M = IPSL-CM5A-LR
#       N = IPSL-CM5A-MR
#       O = MIROC5
#       P = MIROC-ESM
#       Q = MPI-ESM-LR
#       R = MPI-ESM-MR
#       S = MRI-CGCM3
#       T = NorESM1-M
#
#       Seventh Digit is downscaling/scenario methodology
#       X = no additional downscaling
#       0 = imposed values (sensitivity tests)
#       1 = WRF
#       2 = RegCM3
#       3 = ecpc
#       4 = hrm3
#       5 = crcm
#       6 = mm5i
#       7 = RegCM4
#       A = GiST
#       B = MarkSIM
#       C = WM2
#       D = 1/8 degree BCSD
#       E = 1/2 degree BCSD
#       F = 2.5minute WorldClim
#       W = TRMM 3B42
#       X = CMORPH
#       Y = PERSIANN
#       Z = GPCP 1DD
#
#       Eighth Digit is Type of Scenario:
#       X = Observations (no scenario)
#       A = Mean Change from GCM
#       B = Mean Change from RCM
#       C = Mean Change from GCM modified by RCM
#       D = Mean Temperature Changes Only
#       E = Mean Precipitation Changes Only
#       F = Mean and daily variability change for Tmax, Tmin, and P
#       G = P, Tmax and Tmin daily variability change only
#       H = Tmax and Tmin daily variability and mean change only
#       I = P daily variability and mean change only
#       J = Tmax and Tmin daily variability change only
#       K = P daily variability change only
#
###################################################################################################

agmip_simple_delta <- function(base,deltloc,latlonloc,futloc,futname,baseinfo,basedecs,futdecs,rcp,thisgcm){
  
  ## begin debug
#   rootDir     <- '*** your directory here ***\\R\\'           ##  <- Enter location here <-
#   basefile    <- 'USAM0XXX'
#   deltloc     <- paste(rootDir, 'data\\CMIP5\\climfiles\\', sep='')
#   latlonloc   <- paste(rootDir, 'data\\CMIP5\\latlon\\', sep='')
#   futloc      <- paste(rootDir, 'data\\Climate\\Simplescenario\\', sep='')
#   baseloc     <- paste(rootDir, 'data\\Climate\\Historical\\', sep='')
#   base        <- read.table(paste(baseloc, basefile, '.AgMIP', sep=''), skip=5, sep='')
#   baseinfo    <- read.table(paste(baseloc, basefile, '.AgMIP', sep=''), skip=3, nrows=1)
#   scencode    <- c('C','E','G','I','K','M')
#   scen        <- 1
#   gcmlist     <- c('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T')
#   thisgcm     <- 1
#   futname     <- paste(baseinfo$V1, scencode[scen], gcmlist[thisgcm], 'XA', sep ='')
#   basedecs    <- c(1980, 2009)
#   decscode    <- matrix(c(2010,2039,2040,2069,2070,2099), ncol = 3)
#   futdecs     <- c(decscode[1,ceiling(scen/2)], decscode[2,ceiling(scen/2)])
#   scengcm     <- c(3,5)
#   rcp         <- scengcm[(scen%%2 == 0)+1]
#     
#   ## Load required packages
#   library <- c('R.matlab','R.utils')
#   lapply(library, require, character.only = T)
#   rm(library)
# 
	## end debug
  
	##  Input : intype
	dayloc  <- 1
	solar   <- 5
	maxT    <- 6
	minT    <- 7
	prate   <- 8
  
	##  Standards
	headerplus  <- paste(futname, ' - baseline dates maintained for leap year consistency')
	mmtick      <- c(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
	mmcum       <- cumsum(mmtick)
	mmcumleap   <- mmcum + c(0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	rcpname     <- c('historical','rcp26','rcp45','rcp60','rcp85')
	gcmname     <- c('ACCESS1-0','bcc-csm1-1','BNU-ESM','CanESM2','CCSM4','CESM1-BGC','CSIRO-Mk3-6-0','GFDL-ESM2G','GFDL-ESM2M','HadGEM2-CC','HadGEM2-ES','inmcm4','IPSL-CM5A-LR','IPSL-CM5A-MR','MIROC5','MIROC-ESM','MPI-ESM-LR','MPI-ESM-MR','MRI-CGCM3','NorESM1-M')
  
  ##  Default is to assume full decades
	basedecind  <- ceiling((basedecs-1979)/10)
	futdecind   <- ceiling((futdecs-2009)/10)
	
  ##  Check for 30-year Climatological Period (WMO)
	if ((futdecind[2]-futdecind[1]) != 2){
	  print('Future period is not 3 decades')
	}
  
	if ((basedecind[2]-basedecind[1]) != 2){
	  print('Baseline reference period is not 3 decades')
	}
	
	##  Delta type
	if(baseinfo$V3<0){                             ##  Convention here is [0 360]
		baseinfo$V3 = baseinfo$V3+360
	}
  
	filepath  <- file.path(paste(latlonloc, gcmname[thisgcm], '_lat.mat', sep=''))
	lat       <- readMat(filepath)$lat
	  
	filepath  <- file.path(paste(latlonloc, gcmname[thisgcm], '_lon.mat', sep=''))
	lon       <- readMat(filepath)$lon
  
	findspot  <- acr_findspot(baseinfo$V2,baseinfo$V3,lat,lon)
	thisi     <- findspot$thisj               ##  YJ: i <- j
	thisj     <- findspot$thisi
  
  ##  Historical data
	filepath  <- file.path(paste(deltloc, 'meantasmax_', gcmname[thisgcm], '_historical.mat', sep=''))
	meantasmaxbase  <- readMat(filepath)$meantasmax	
	filepath  <- file.path(paste(deltloc, 'meantasmin_', gcmname[thisgcm], '_historical.mat', sep=''))
	meantasminbase  <- readMat(filepath)$meantasmin
	filepath    <- file.path(paste(deltloc, 'meanpr_', gcmname[thisgcm], '_historical.mat', sep=''))
	meanprbase  <- readMat(filepath)$meanpr
  
  ##  RCP data
	filepath  <- file.path(paste(deltloc, 'meantasmax_', gcmname[thisgcm], '_', rcpname[rcp], '.mat', sep=''))
	meantasmaxfut   <- readMat(filepath)$meantasmax
	filepath  <- file.path(paste(deltloc, 'meantasmin_', gcmname[thisgcm], '_', rcpname[rcp], '.mat', sep=''))
	meantasminfut   <- readMat(filepath)$meantasmin
	filepath  <- file.path(paste(deltloc, 'meanpr_', gcmname[thisgcm], '_', rcpname[rcp], '.mat', sep=''))
	meanprfut <- readMat(filepath)$meanpr
	
	##  Calculate changes in min and max temperature and precipitation
	meantasmaxdelt  <- rowMeans( meantasmaxfut[thisj,thisi,,futdecind[1]:futdecind[2]] - meantasmaxbase[thisj,thisi,,basedecind[1]:basedecind[2]] )
	
  meantasmindelt  <- rowMeans( meantasminfut[thisj,thisi,,futdecind[1]:futdecind[2]] - meantasminbase[thisj,thisi,,basedecind[1]:basedecind[2]] )
  
  meanprdelt      <- rowMeans( meanprfut[thisj,thisi,,futdecind[1]:futdecind[2]] ) / rowMeans(meanprbase[thisj,thisi,,basedecind[1]:basedecind[2]] )
  
	##  Cap rainfall deltas at 300% (likely for dry season)
	meanprdelt[is.nan(meanprdelt)] <- 1       ##  Change NaNs to ones
	meanprdelt      <- pmin(meanprdelt,3)
  
	ddate   <- base[,dayloc]                  ##  Correct for Y2K, etc., if necessary
	dummy   <- base[,dayloc]                  ##  YJ
  
	newscen <- cbind(base[,dayloc], base[,solar], base[,maxT], base[,minT], base[,prate], dummy)
  
  ##  Run for loop to define new scenario
  for (dd in 1:length(ddate)) {
    jd      <- (ddate[dd] %% 1000)
	  yy      <- floor(ddate[dd]/1000)
	  thismm  <- max(which(jd>mmcum))
    
	  if ((yy %% 4)) {
      
	  } else { thismm = max(which(jd>mmcumleap)) }
    
	  newscen[dd,3] = base[dd,maxT]+meantasmaxdelt[thismm]
	  newscen[dd,4] = base[dd,minT]+meantasmindelt[thismm]
	  newscen[dd,5] = min(base[dd,prate]*meanprdelt[thismm],999.9)  #  Ensure no formatting issue
  }
  
  ##  Check to ensure Tmax > Tmin
	aa <- newscen[,3]-newscen[,4]
	bb <- which(aa < 0)
# 	cat('Number of Tmin > Tmax  =  ', as.character(length(bb)), '\n')
	
	if (length(bb) > 0){
	  for(ii in 1:length(bb)){
	    newscen[bb[ii],3] <- mean(newscen[bb[ii],3:4]) + 0.1
	    newscen[bb[ii],4] <- newscen[bb[ii],3] - 0.2
	  }
	}
  
	##  Calculate Tave and Tamp
	Tave    <- mean(mean(newscen[,3:4]))
	mmtick  <- c(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
	mmcum   <- cumsum(mmtick)
	mmcum   <- mmcum[1:12]
  
	for (dd in 1:max(dim(newscen))){
	  newscen[dd,6] <- max(which(mmcum<((newscen[dd,1] %% 1000))))
	}
	Tmonth  <- c(0,0,0,0,0,0,0,0,0,0,0,0)
  
	for (thismm in 1:12){
	  Tmonth[thismm] = mean(mean(newscen[which(newscen[,6]==thismm),3:4]))
	}
  
	Tamp    <- (max(Tmonth)-min(Tmonth))/2

	##  Write it all out with proper station code in basic AgMIP format 
	sink(paste(futloc, futname, '.AgMIP', sep=''))
  
	cat(c('*WEATHER DATA :', headerplus))
	cat('\n')
	cat('\n')
	cat(sprintf('%54s', '@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT'),'\n')
	cat(sprintf('%6s%9.3f%9.3f%6.0f%6.1f%6.1f%6.1f%6.1f', baseinfo$V1, baseinfo$V2, baseinfo$V3, baseinfo$V4,Tave,Tamp,baseinfo$V7,baseinfo$V8), '\n')
	cat(sprintf('%s', '@DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND  DEWP  VPRS  RHUM'),'\n')
  
	for (dd in 1:length(ddate)){
	  jd = (ddate[dd] %% 1000)
	  yy = floor(ddate[dd]/1000)
	  thismm = max(which(jd>mmcum))
	  day = jd-mmcum[thismm]
	  if(yy %% 4){
	  
	  }else{
		thismm = max(which(jd>mmcumleap))
		day = jd-mmcumleap[thismm]
	  }
	  cat(sprintf('%7s%6s%4s%4s%6.1f%6.1f%6.1f%6.1f', as.character(newscen[dd,1]), as.character(yy), as.character(thismm), as.character(day), newscen[dd,2], newscen[dd,3], newscen[dd,4], newscen[dd,5]),'\n')
	}
  
	sink()
  
	##  Remove all variables
	rm(list = ls(all = TRUE))
	invisible(gc())
}