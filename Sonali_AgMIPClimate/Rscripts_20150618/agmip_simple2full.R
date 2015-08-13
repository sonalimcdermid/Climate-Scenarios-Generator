####################################################################################################
#  		agmip_simple2full.R
#
#  This script converts basic future scenarios (Srad, maxT, minT, P) into full scenarios with
#    relative humidity-controlled vapor pressure based upon daily Tmax
#
#  THIS WAS FORMERLY acr_giss535.m -- July 1, 2011
#    Updated for new format, Tmax reference temperatures, and Td
#
#  THIS WAS FORMERLY acr_agmip005.R -- May 24, 2013
#    Updated to be used with Guide for running AgMIP Climate Scenario GenerationTools
#
#     Author: Alex Ruane
#   								alexander.c.ruane@nasa.gov
#    	Created:	06/14/2011
# 		Translated to R by Yunchul Jung: 08/12/2012
####################################################################################################

agmip_simple2full <- function(basefile,futfile,outfile,headerplus,shortfile,stnlat,stnlon,stnelev,refht,wndht){
  
	## begin debug : YJ
# 	rootDir     <- 'E:\\project-Agmip\\Climate-IT\\test2\\delta005\\'
# 	basefile    <- paste(rootDir, 'NLHA0XXX.AgMIPm', sep='')
# 	futfile     <- paste(rootDir, 'NLHA5PXA.AgMIPm', sep='')
# 	outfile     <- paste(rootDir, 'NLHA5PXA.AgMIP', sep='')
# 	headerplus  <- 'NLHA5PXA - baseline dates maintained for leap year consistency'
# 	shortfile   <- 'NLHA'
# 	stnlat      <- 51+58/60
# 	stnlon      <- 5+38/60
# 	stnelev     <- 7
# 	refht       <- 1.5
# 	wndht       <- 2
	## end debug
  
  base  <- read.table( basefile, skip=5,sep="")
  fut   <- read.table( futfile, skip=5,sep="")
  
	##  Calculate saturation vapor pressure from T
	###  Clausius-Clapeyron from Curry and Webster page 112
	###  es = eos*exp(Lv/Rv*(1/To - 1/T))
	###  Td = 1/((1/To)-(Rv/Lv)*log(e/eos))
	###  RH = e/es * 100
	eos <- 6.11         # hPa
	Lv  <- 2.5e6        # J/kg
	To  <- 273.16       # K
	Rv  <- 461          # J/K/kg
	eps <- 0.622        # = (Mv/Md)
  
	newfut  <- cbind( fut[,1:8], base[,9:length(base)] )
  
	es  <- rep(1:length(newfut[,1]))
  
	##  Calculate saturation vapor pressure from Tmax
  for ( ii in 1:length(newfut[,1]) ){
	  es[ii] = eos*exp(Lv/Rv*(1/To - 1/(newfut[ii,6]+To)))
	}
  
	## Use RH to calculate vapor pressure
	newfut[,11] = (newfut[,12]/100) * es        # Elementwise production

	## Calculate Dew Point Temperatures
	for (mm in 1:length(newfut[,11]) ){
	  # YJ: it seems assigning to newfut make speed slow down, don't know why	  
	  newfut[mm,10] <- (1/((1/To)-(Rv/Lv)*log(newfut[mm,11]/eos)) - To) 
	}
  
	## Calculate Tave and Tamp
	Tave = mean(colMeans(newfut[,6:7]))
	Tmonth <- rep(1:12)
  
	for ( thismm in 1:12 ){
	  Tmonth[thismm] = mean(colMeans(newfut[which(newfut[,3]==thismm),6:7]))
	}
	Tamp = (max(Tmonth)-min(Tmonth))/2
  
	## Print it all out
	ddate = newfut[,1]
  
	sink(outfile)
  
	cat(c('*WEATHER DATA : ', headerplus))
	cat('\n')
	cat('\n')
	cat(sprintf("%54s", "@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT"),"\n")
	
  ### Don't forget to adjust reference height for temperature and winds
	cat(sprintf("%6s%9.3f%9.3f%6.0f%6.1f%6.1f%6.1f%6.1f", shortfile, stnlat, stnlon, stnelev,Tave,Tamp,refht,wndht),"\n")
	cat(sprintf("%s", "@DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND  DEWP  VPRS  RHUM"),"\n")
  
	for (dd in 1:length(ddate)){
		cat(sprintf("%7s%6s%4s%4s%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.0f", as.character(newfut[dd,1]), as.character(newfut[dd,2]), as.character(newfut[dd,3]), as.character(newfut[dd,4]), newfut[dd,5], newfut[dd,6], newfut[dd,7], newfut[dd,8], newfut[dd,9], newfut[dd,10], newfut[dd,11], newfut[dd,12]),"\n")
	}
  
	sink()
	## Convert to windows notepad format and remove temp file
# 	eval(['!awk ''' 'sub(' '"' '$' '"' ',' '"' '\r' '"' ')' ''' ' outfile 'unix > ' outfile])
# 	eval(['!rm ' outfile 'unix'])
  
}