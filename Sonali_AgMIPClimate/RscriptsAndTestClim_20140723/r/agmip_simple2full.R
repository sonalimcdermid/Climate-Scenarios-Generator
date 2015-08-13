####################################################################################################
#  		agmip_simple2full.R
#
#  This script converts basic future scenarios (Srad, Tmax, Tmin, P) into full scenarios with
#    relative humidity-controlled vapor pressure based upon daily Tmax.  The computations of this
#    script require the relative humidtity from the baseline data file.
#
#  THIS WAS FORMERLY acr_giss535.m -- July 1, 2011
#    Updated for new format, Tmax reference temperatures, and Td
#
#  THIS WAS FORMERLY acr_agmip005.R         --  May 24, 2013
#    Updated to be used with the Guide for Running AgMIP Climate Scenario Generation Tools 
#    Updated for Version 2.0 of the Guide   --  July 25, 2013 by Nicholas Hudson
#    Updated to ensure Vprs >= 0.1          --  November 20, 2013 by N. Hudson
#
#     Author: Alex Ruane
#   								alexander.c.ruane@nasa.gov
#    	Created:	06/14/2011
# 		Translated to R by Yunchul Jung: 08/12/2012
####################################################################################################

agmip_simple2full <- function(base, infile, outfile, headerplus, baseinfo) {
  
	## begin debug
#   rootDir     <- '*** your directory here ***\\R\\'           ##  <- Enter location here <-
#   basefile    <- 'USAM0XXX'
#   end.code    <- 'XA' 
#   baseloc     <- paste(rootDir, 'data\\Climate\\Historical\\', sep='')
#   base        <- read.table(paste(baseloc, basefile, '.AgMIP', sep=''), skip=5, sep="")
#   baseinfo    <- read.table(paste(baseloc, basefile, '.AgMIP', sep=''), skip=3, nrows=1)
#   scencode    <- c('C','E','G','I','K','M')
#   scen        <- 1
#   gcmlist     <- c('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T')
#   thisgcm     <- 1  
#   filename    <- paste(baseinfo$V1, scencode[scen], gcmlist[thisgcm], end.code, sep ='')
#   infile      <- paste(rootDir, 'data\\Climate\\Simplescenario\\', filename, '.AgMIP', sep ='')
#   outfile     <- paste(rootDir, 'data\\Climate\\Fullscenario\\',   filename, '.AgMIP', sep ='')
#   headerplus  <- paste(filename,' - baseline dates maintained for leap year consistency', sep ='')
	## end debug
  
  ##  Load data
  fut   <- read.table(infile,  skip=5, sep='')
  
	##  Calculate saturation vapor pressure from T
	###  Clausius-Clapeyron from Curry and Webster page 112
	###  es = eos*exp(Lv/Rv*(1/To - 1/T))
	###  Td = 1/((1/To)-(Rv/Lv)*log(e/eos))
	###  RH = e/es * 100
	eos   <- 6.11         # hPa
	Lv    <- 2.5e6        # J/kg
	To    <- 273.16       # K
	Rv    <- 461          # J/K/kg
	eps   <- 0.622        # = (Mv/Md)
  
	newfut      <- cbind(fut[,1:8], base[,9:length(base)])
  
	##  Calculate saturation vapor pressure from Tmax, Vprs = Rhum * es
  newfut[,11] <- (newfut[,12]/100) * eos * exp(Lv/Rv*(1/To - 1/(newfut[,6]+To)))
  
  ##  Add check to ensure Vprs >= 0.1
  newfut[which(newfut[,11]<0.1),11] <- 0.1
  
  ##  Calculate Dew Point Temperatures
  newfut[,10] <- (1/((1/To)-(Rv/Lv) * log(newfut[,11]/eos)) - To)
  
  ##  Calculate Tave and Tamp
	Tave    <- mean(colMeans(newfut[,6:7]))
	Tmonth  <- rep(1:12)
    
	for (thismm in 1:12)    Tmonth[thismm]  <- mean(colMeans(newfut[which(newfut[,3]==thismm),6:7]))
	Tamp    <- (max(Tmonth)-min(Tmonth))/2
  
	##  Print it all out
	ddate = newfut[,1]
  
	sink(outfile)
  
	cat(c('*WEATHER DATA :', headerplus))
	cat('\n')
	cat('\n')
	cat(sprintf('%54s', '@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT'),'\n')
	
  ###  Don't forget to adjust reference height for temperature and winds
	cat(sprintf('%6s%9.3f%9.3f%6.0f%6.1f%6.1f%6.1f%6.1f', baseinfo$V1, baseinfo$V2, baseinfo$V3, baseinfo$V4,Tave,Tamp,baseinfo$V7,baseinfo$V8),'\n')
	cat(sprintf('%s', '@DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND  DEWP  VPRS  RHUM'),'\n')
  
	for (dd in 1:length(ddate)) {
		cat(sprintf('%7s%6s%4s%4s%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.0f', as.character(newfut[dd,1]), as.character(newfut[dd,2]), as.character(newfut[dd,3]), as.character(newfut[dd,4]), newfut[dd,5], newfut[dd,6], newfut[dd,7], newfut[dd,8], newfut[dd,9], newfut[dd,10], newfut[dd,11], newfut[dd,12]),'\n')
	}
  
	sink()
	## Convert to windows notepad format and remove temp file
# 	eval(['!awk ''' 'sub(' ''' '$' ''' ',' ''' '\r' ''' ')' ''' ' outfile 'unix > ' outfile])
# 	eval(['!rm ' outfile 'unix'])
  
  ##  Remove all variables
  rm(list = ls(all = TRUE))
  invisible(gc())
}