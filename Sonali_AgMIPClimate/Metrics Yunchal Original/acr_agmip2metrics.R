#%			acr_agmip2metrics
#%
#%       This script produces a record of climate metrics in a given season
#%       for a .AgMIP file
#%
#%       inputs:
#%       infile (.AgMIP format)
#%       jdstart
#%       jdend
#%       column (in .AgMIP file; 13 = Tave = average of columns 6-7)
#%       analysistype ('mean','count','exceedance','max','min','std',
#%                     'meanconsecutivedays','maxconsecutivedays')
#%       reference (e.g., 0.1 mm, 30^oC; not always needed)
#%       specialoperator (e.g., -1 for negative exceedance; not always needed)
#%
#%       Note that this follows the periodlength, so periods that wrap-around 
#%       leap years will end on jdend-1; 
#% 
#%       returns:
#%       metric (31-year record based upon planting year)
#%              (first column year, second column value)
#%              (NaN at end if wrap-around)
#% 
#%				author: Alex Ruane
#%                                       alexander.c.ruane@nasa.gov
#%				date:	02/16/12
#%
#%

# Conversion from Matlab to R
# by Yunchul Jung
# at 8/12/2012

acr_agmip2metrics <- function(infile,jdstart,jdend,column,analysistype,reference,specialoperator){

	#%--------------------------------------------------
	#%--------------------------------------------------
	#%% debug begin
	#rootDir <- 'E:\\project-Agmip\\Climate-IT\\test2\\metrics\\'
	#infile <- paste(rootDir, 'USAM0XXX.AgMIP', sep='');
	#jdstart = 160;
	#jdend = 220;
	#column = 8;
	#analysistype = 'maxconsecutivedays';
	#reference = 10;
	#specialoperator = 1;
	#%% debug end

	#%% read in file
	climdata <- list();
	climdata <- acr_agmipload(infile);

	if (column==13){          #%% calculate Tave if needed
	  climdata[,13] = rowMeans(climdata[,6:7]);
	}

	periodlength = jdend-jdstart+1;
	if(periodlength<1){
	  periodlength = periodlength+365;
	}

	#%% make metric file
	metric = matrix(NaN,31,2);
	metric[,1] = 1980:2010;

	#%% calculations
	for ( yyyy in 1980:2009 ){

	  firstday = which(climdata[,1]==yyyy*1000+jdstart);
	  lastday = firstday+periodlength-1;
	  if ((analysistype=='mean')){
		metric[yyyy-1979,2] = mean(climdata[firstday:lastday,column]);
	  }
	  if ((analysistype=='max')){
		metric[yyyy-1979,2] = max(climdata[firstday:lastday,column]);
	  }
	  if ((analysistype=='min')){
		metric[yyyy-1979,2] = min(climdata[firstday:lastday,column]);
	  }
	  if ((analysistype=='std')){
		metric[yyyy-1979,2] = sd(climdata[firstday:lastday,column]);
	  }
	  if ((analysistype=='count')){
		if (specialoperator == -1){
		  metric[yyyy-1979,2] = length(which(climdata[firstday:lastday,column]<reference));
		}else{
		  metric[yyyy-1979,2] = length(which(climdata[firstday:lastday,column]>reference));
	    }
	  }
	  
	  if ((analysistype=='exceedance')){
		climdataexceed = climdata[firstday:lastday,column]-reference;
		if (specialoperator == -1){
		  climdataexceed[which(climdataexceed>0)] = 0;
		}else{
		  climdataexceed[which(climdataexceed<0)] = 0;
		}
		metric[yyyy-1979,2] = sum(climdataexceed);
	  }

	  if ((analysistype=='meanconsecutivedays')){
	  
		climdataexceed = climdata[firstday:lastday,column]-reference;
		if (specialoperator == -1){
		  climdataexceed[which(climdataexceed>0)] = 0;
		  climdataexceed[which(climdataexceed<0)] = 1;
		}else{
		  climdataexceed[which(climdataexceed<0)] = 0;
		  climdataexceed[which(climdataexceed>0)] = 1;
		}

		streak <- rep(1:length(climdataexceed)); #%% initialize streaks
		for (ii in 2:length(climdataexceed)){       #%% start on second
		  if(climdataexceed[ii]==1){
			streak[ii] = streak[ii-1] + climdataexceed[ii];    #%% add to streak
			streak[ii-1] = 0;                  #%% previous wasn't end of streak
		  }else{
			streak[ii] = 0;
		  }
		}
		metric[yyyy-1979,2] = mean(streak[which(streak>0)]);
	  }
	  
	  if ((analysistype=='maxconsecutivedays')){
		climdataexceed = climdata[firstday:lastday,column]-reference;
		if (specialoperator == -1){
		  climdataexceed[which(climdataexceed>0)] = 0;
		  climdataexceed[which(climdataexceed<0)] = 1;
		}else{
		  climdataexceed[which(climdataexceed<0)] = 0;
		  climdataexceed[which(climdataexceed>0)] = 1;
		}
		
		streak <- rep(1:length(climdataexceed)); #%% initialize streaks
		for (ii in 2:length(climdataexceed)){       #%% start on second
		  if(climdataexceed[ii]==1){	  
			streak[ii] = streak[ii-1] + climdataexceed[ii];             
			streak[ii-1] = 0;
		  }else{
			streak[ii] = 0;
		  }
		}
		metric[yyyy-1979,2] = max(streak);
	  }
	  
	  rm(streak);
	}

	#%===========
	#%===========

	if (jdstart<jdend){        #%% we can do the 31st year because no wrap-around

	  yyyy=2010;
	  firstday = which(climdata[,1]==yyyy*1000+jdstart);
	  lastday = firstday+periodlength-1;
	  if ((analysistype=='mean')){
		metric[yyyy-1979,2] = mean(climdata[firstday:lastday,column]);
	  }
	  if ((analysistype=='max')){
		metric[yyyy-1979,2] = max(climdata[firstday:lastday,column]);
	  }
	  if ((analysistype=='min')){
		metric[yyyy-1979,2] = min(climdata[firstday:lastday,column]);
	  }
	  if ((analysistype=='std')){
		metric[yyyy-1979,2] = sd(climdata[firstday:lastday,column]);
	  }
	  if ((analysistype=='count')){
		if (specialoperator == -1){
		  metric[yyyy-1979,2] = length(which(climdata[firstday:lastday,column]<reference));
		}else{
		  metric[yyyy-1979,2] = length(which(climdata[firstday:lastday,column]>reference));
		  }
	  }
	  
	  if ((analysistype=='exceedance')){
		climdataexceed = climdata[firstday:lastday,column]-reference;
		if (specialoperator == -1){
		  climdataexceed[which(climdataexceed>0)] = 0;
		}else{
		  climdataexceed[which(climdataexceed<0)] = 0;
		}
		metric[yyyy-1979,2] = sum(climdataexceed);
	  }
	  
	  if ((analysistype=='meanconsecutivedays')){
		climdataexceed = climdata[firstday:lastday,column]-reference;
		if (specialoperator == -1){
		  climdataexceed[which(climdataexceed>0)] = 0;
		  climdataexceed[which(climdataexceed<0)] = 1;
		}else{
		  climdataexceed[which(climdataexceed<0)] = 0;
		  climdataexceed[which(climdataexceed>0)] = 1;
		}

		streak <- rep(1:length(climdataexceed));	#%% initialize streaks
		for( ii in 2:length(climdataexceed)){       #%% start on second
		  if(climdataexceed[ii]==1){
			streak[ii] = streak[ii-1] + climdataexceed[ii];    #%% add to streak
			streak[ii-1] = 0;                  #%% previous wasn't end of streak
		  }else{
			streak[ii] = 0;
		  }
		}
		metric[yyyy-1979,2] = mean(streak[which(streak>0)]);
	  }
	  
	  if ((analysistype=='maxconsecutivedays')){
		climdataexceed = climdata[firstday:lastday,column]-reference;
		if (specialoperator == -1){
		  climdataexceed[which(climdataexceed>0)] = 0;
		  climdataexceed[which(climdataexceed<0)] = 1;
		}else{
		  climdataexceed[which(climdataexceed<0)] = 0;
		  climdataexceed[which(climdataexceed>0)] = 1;
		}

		streak <- rep(1:length(climdataexceed));		#%% initialize streaks	
		for (ii in 2:length(climdataexceed)){       #%% start on second
		  if(climdataexceed[ii]==1){	  
			streak[ii] = streak[ii-1] + climdataexceed[ii];    #%% add to streak
			streak[ii-1] = 0;                  #%% previous wasn't end of streak
		  }else{
			streak[ii] = 0;
		  }
		}
		metric[yyyy-1979,2] = max(streak);
	  }
	}
	print(metric);
}



