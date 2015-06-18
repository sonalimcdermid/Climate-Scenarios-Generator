#####################################################################################################
#			acr_agmip2metrics
#
#  This script produces a record of climate metrics in a given season for a .AgMIP file.
#
#     Author: Alex Ruane
#     							alexander.c.ruane@nasa.gov
#    	Created:	02/16/2012
# 		Translated to R by Yunchul Jung: 8/12/2012
#
#  Inputs:
#    infile.loc (.AgMIP format)
#    jdstart
#    jdend
#    column (in .AgMIP file; 13 = Tave = average of columns 6-7)
#    analysistype ('mean', 'count', 'exceedance', 'max', 'min', 'std', 'meanconsecutivedays',
#      'maxconsecutivedays')
#    reference (e.g., 0.1 mm, 30^oC; not always needed)
#    specialoperator (e.g., -1 for negative exceedance; not always needed)
#
#  NOTE: This follows the period length, so periods that wrap-around leap years will end on jdend-1. 
#
#  Output:
#    metric (31-year record based upon planting year)
#           (first column year, second column value)
#           (NaN at end if wrap-around)
#
#####################################################################################################

acr_agmip2metrics <- function(infile.loc,jdstart,jdend,column,analysistype,reference,specialoperator){
  
  ##  Begin debug
#   rootDir         <- 'E:\\project-Agmip\\Climate-IT\\test2\\metrics\\'
# 	infile.loc      <- paste(rootDir, 'USAM0XXX.AgMIP', sep='')
# 	jdstart         <- 160
# 	jdend           <- 220
# 	column          <- 8
# 	analysistype    <- 'maxconsecutivedays'
# 	reference       <- 10
# 	specialoperator <- -1
	##  End debug
  
  ##  Read in .AgMIP file
  climdatainfo  <- read.table(paste(rootDir,"/", infile.loc, sep=''), skip=3, nrows=1)
  climdata      <- read.table(paste(rootDir,"/", infile.loc, sep=''), skip=5, sep='')
  
  ##  Calculate Tavg if necessary
  if (column==13)   climdata[,13] = rowMeans(climdata[,6:7])
  
  ##  Determine metrics period length
  periodlength  <- jdend-jdstart+1
	if(periodlength < 1)    periodlength  <- periodlength+365
  
  ##  Can derive the 31st year iff time period does not wrap-around into 32nd year
  if (jdstart<jdend) {
    years <- 1980:2010
  } else {
    years <- 1980:2009
  }
  
  ##  Create metric file
  metric      <- matrix(NaN,31,1)
  
  ##  Calculations
  for (yyyy in years) {
    firstday  <- which(climdata[,1] == (yyyy*1000+jdstart))
	  lastday   <- (firstday + periodlength -1)
    
    if (analysistype == 'mean') metric[yyyy-1979] <- mean(climdata[firstday:lastday, column])
    
	  if (analysistype == 'max')  metric[yyyy-1979] <- max(climdata[firstday:lastday, column])
    
	  if (analysistype == 'min')  metric[yyyy-1979] <- min(climdata[firstday:lastday, column])
    
	  if (analysistype == 'std')  metric[yyyy-1979] <- sd(climdata[firstday:lastday, column])
    
	  if (analysistype == 'count') {
      if (specialoperator == -1) {
        metric[yyyy-1979] <- length(which(climdata[firstday:lastday,column] < reference))
      } else {
        metric[yyyy-1979] <- length(which(climdata[firstday:lastday,column] > reference))
	    }
	  }
	  
	  if (analysistype == 'exceedance') {
      climdataexceed  <- (climdata[firstday:lastday,column] - reference)
      if (specialoperator == -1) {
        climdataexceed[which(climdataexceed > 0)] <- 0
      } else {
        climdataexceed[which(climdataexceed < 0)] <- 0
      }
      metric[yyyy-1979] <- sum(climdataexceed)
	  }

	  if (analysistype == 'meanconsecutivedays') {
      climdataexceed  <- (climdata[firstday:lastday,column] - reference)
      
      if (specialoperator == -1) {
        climdataexceed[which(climdataexceed > 0)] <- 0
        climdataexceed[which(climdataexceed < 0)] <- 1
      } else {
        climdataexceed[which(climdataexceed < 0)] <- 0
        climdataexceed[which(climdataexceed > 0)] <- 1
      }
      streak <- rep(1:length(climdataexceed))       ##  Initialize streaks
      
      for (ii in 2:length(climdataexceed)) {        ##  Start on second entry
        if(climdataexceed[ii] == 1) {
          streak[ii]    <- streak[ii-1] + climdataexceed[ii]  ##  Add to streak
          streak[ii-1]  <- 0                        ##  Previous entry wasn't end of streak
        } else {
          streak[ii]    <- 0
        }
      }
      metric[yyyy-1979] <- mean(streak[which(streak>0)])
	  }
	  
	  if (analysistype == 'maxconsecutivedays') {
      climdataexceed  <- (climdata[firstday:lastday,column] - reference)
      
      if (specialoperator == -1) {
        climdataexceed[which(climdataexceed > 0)] <- 0
        climdataexceed[which(climdataexceed < 0)] <- 1
      } else {
        climdataexceed[which(climdataexceed < 0)] <- 0
        climdataexceed[which(climdataexceed > 0)] <- 1
      }
      streak <- rep(1:length(climdataexceed))       ##  Initialize streaks
      
      for (ii in 2:length(climdataexceed)) {        ##   Start on second entry
        if(climdataexceed[ii] == 1) {
          streak[ii]    <- streak[ii-1] + climdataexceed[ii]  ##  Add to streak
          streak[ii-1]  <- 0                        ##  Previous entry wasn't end of streak
        } else {
          streak[ii]    <- 0
        }
      }
      metric[yyyy-1979] <- max(streak)
	  }
	}
  
  return(metric)
}