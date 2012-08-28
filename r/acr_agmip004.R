## comments

acr_agmip004 <- function(basefile,futloc,futname,shortfile,stnlat,stnlon,stnelev,stntavg,stntamp,basedecs,futdecs,sres,thisgcm,deltatype,intype){

	## begin debug
	#rootDir <- 'E:\\project-Agmip\\Climate-IT\\test2\\delta004\\';
	#basefile <- paste(rootDir, 'USAM0XXX.AgMIPm', sep='');
	#futloc <- paste(rootDir, sep='');
	#futname <- 'USAM5LXA'; #'NLHA5LXA';
	#shortfile <- 'USAM'; #'NLHA';
	#stnlat <- 51+58/60;
	#stnlon <- 5+38/60;
	#stnelev <- 7;
	#stntavg <- -99.0;
	#stntamp <- -99.0;
	#basedecs <- c(1980, 2009); ## these will take entire decades for delta calculations
	#futdecs <- c(2070, 2099); ## these will take entire decades for delta calculations
	#sres <- 1;
	#thisgcm = 16; #12;
	#deltatype <- 'GCM';
	#intype <- 'AgMIPm';	
	## end debug

	##############################################################
	## check input	
	{

	# input : intype
	if( intype == 'AgMIPm' ){
	  dayloc  = 1;
	  solar = 5;
	  maxT = 6;
	  minT = 7;
	  prate = 8;
	}else if( intype == 'WTHm' ){
	  dayloc  = 1;
	  solar = 2;
	  maxT = 3;
	  minT = 4;
	  prate = 5;
	}else{
		stop('Unkown input data type');
	}
	
	## standards:
	headerplus <- c(futname, ' - baseline dates maintained for leap year consistency');
	### 1=left, 2=centered, 3=right based on first longitude reading
	### not sure about this, nothing says it can't be centered on 0 degrees
	lonorient <- c(1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1);

	mmtick <- c(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	mmcum = cumsum(mmtick);
	mmcumleap <- mmcum + c(0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);

	sresname = c('A2','B1');
	gcmname = c('bccrBCM2_0_','cccmaCGCM3_1_','cnrmCM3_','csiroMK3_0_','gfdlCM2_0_','gfdlCM2_1_','gissMODEL_E_R_','inmcm30_','ipslCM4_','miroc32_MEDRES_','miubECHO_G_','mpiECHAM5_','mriCGCM2_3_2a_','ncarCCSM3_0_','ncarPCM1_','ukmoHADCM3_');

	###
	base <- read.table(basefile);
	
	## default is to assume full decades
	fiveyearsbase = 0;
	basedecind = ceiling((basedecs-1969)/10);
	fiveyearsfut = 0;
	futdecind = ceiling((futdecs-2009)/10);
	
	## check for half-decades
	if( (basedecs[1] %% 10) == 5 ){
	  fiveyearsbase = 1;
	  basedecind = ceiling((basedecs-1964)/10);
	}
	if( (futdecs[1] %% 10) == 5 ){
	  fiveyearsfut = 1;
	  futdecind = ceiling((futdecs-2004)/10);
	}

	if ((futdecind[2]-futdecind[1]) != 2){
	  print('Future period is not 3 decades');
	}
	if ((basedecind[2]-basedecind[1]) != 2){
	  print('Baseline reference period is not 3 decades');
	}
	
	}
	
	{
	## delta type
	if(deltatype =='GCM'){
	  if(stnlon<0){      ##convention here is [0 360]
		stnlon = stnlon+360;
	  }

	  ##YJ: 1. tried to transform *.mat to *.csv, and works
	  #lat <- read.table( paste(futloc, gcmname[thisgcm], 'lat.csv', sep=''), header=FALSE, sep=',' );
	  #lon <- read.table( paste(futloc, gcmname[thisgcm], 'lon.csv', sep=''), header=FALSE, sep=',' );
	  ##YJ: 2. this was tested, but not work
	  #lat <- read.table( paste(futloc, gcmname[thisgcm], 'lat.mat', sep=''));
	  #lon <- read.table( paste(futloc, gcmname[thisgcm], 'lon.mat', sep=''));
	  ##YJ: 3. use readMat(). To use it, need to install R.matlab package and load, 
	  # works for multi-dim matrix while read.table supports only 1-dimension
	  filepath <- file.path(paste(futloc, gcmname[thisgcm], 'lat.mat', sep=''));
	  lat <- readMat(filepath)$lat;
	  
	  filepath <- file.path(paste(futloc, gcmname[thisgcm], 'lon.mat', sep=''));
	  lon <- readMat(filepath)$lon;

	  ### check for gridbox being defined on edge:
	  ### not sure about this at this time, leave commented out
	  ### I thought they were all centered
	  #if(lonorient(thisgcm) == 1)
	  #  lon = lon+mean(lon(1,1:2));
	  #end;


	  findspot <- acr_findspot(stnlat,stnlon,lat,lon);
	  thisi <- findspot$thisj; # YJ: i <- j
	  thisj <- findspot$thisi;


	  if (fiveyearsbase){
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tbase5.mat",sep=''));
		Tbase <- readMat(filepath)$clim;
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pbase5.mat",sep=''));
		Pbase <- readMat(filepath)$clim;
	  }else{
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tbase.mat",sep=''));
		Tbase <- readMat(filepath)$clim;	
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pbase.mat",sep=''));
		Pbase <- readMat(filepath)$clim;		
	  }

	  if (fiveyearsfut){
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tfutr5.mat",sep=''));
		Tfut <- readMat(filepath)$clim;
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pfutr5.mat",sep=''));
		Pfut <- readMat(filepath)$clim;
	  }else{
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tfutr.mat",sep=''));
		Tfut <- readMat(filepath)$clim;
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pfutr.mat",sep=''));
		Pfut <- readMat(filepath)$clim;		
	  }
	}

	else if( deltatype =='Global_BCSD'){
	  if(stnlon>180){      ##convention here is [-180 180]
		stnlon = stnlon-360;
	  }
	  
	  filepath <- file.path(paste(futloc, 'Global_BCSD_lat.mat',sep=''));
	  lat <- readMat(filepath)$lat;

	  filepath <- file.path(paste(futloc, 'Global_BCSD_lon.mat',sep=''));
	  lon <- readMat(filepath)$lon;

	  ### check for gridbox being defined on edge:
	  ### not sure about this at this time, leave commented out
	  ### I thought they were all centered
	  #if(lonorient(thisgcm) == 1)
	  #  lon = lon+mean(lon(1,1:2));
	  #end;

	  findspot <- acr_findspot(stnlat,stnlon,lat,lon);
	  thisi <- findspot$thisj; # YJ: i <- j
	  thisj <- findspot$thisi;

	  if (fiveyearsbase){
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tbase5.mat",sep=''));
		Tbase <- readMat(filepath)$clim;
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pbase5.mat",sep=''));
		Pbase <- readMat(filepath)$clim;
	  }else{
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tbase.mat",sep=''));
		Tbase <- readMat(filepath)$clim;
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pbase.mat",sep=''));
		Pbase <- readMat(filepath)$clim;		
	  }

	  if (fiveyearsfut){
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tfutr5.mat",sep=''));
		Tfut <- readMat(filepath)$clim;
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pfutr5.mat",sep=''));
		Pfut <- readMat(filepath)$clim;
	  }else{
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tfutr.mat",sep=''));
		Tfut <- readMat(filepath)$clim;
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pfutr.mat",sep=''));
		Pfut <- readMat(filepath)$clim;		
	  }
	}

	else if( deltatype == 'US_BCSD'){
	  if(stnlon>180){      ##convention here is [-180 180]
		stnlon = stnlon-360;
	  }

	  filepath <- file.path(paste(futloc, 'US_BCSD_lat.mat',sep=''));
	  lat <- readMat(filepath)$lat;

	  filepath <- file.path(paste(futloc, 'US_BCSD_lon.mat',sep=''));
	  lon <- readMat(filepath)$lon;

	  ### check for gridbox being defined on edge:
	  ### not sure about this at this time, leave commented out
	  ### I thought they were all centered
	  #if(lonorient(thisgcm) == 1)
	  #  lon = lon+mean(lon(1,1:2));
	  #end;

	  findspot <- acr_findspot(stnlat,stnlon,lat,lon);
	  thisj <- findspot$thisj; # YJ: i <- j
	  thisi <- findspot$thisi;

	  if (fiveyearsbase){
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tbase5.mat",sep=''));
		Tbase <- readMat(filepath)$clim;
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pbase5.mat",sep=''));
		Pbase <- readMat(filepath)$clim;
	  }else{
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tbase.mat",sep=''));
		Tbase <- readMat(filepath)$clim;	  
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pbase.mat",sep=''));
		Pbase <- readMat(filepath)$clim;
	  }

	  if (fiveyearsfut){
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tfutr5.mat",sep=''));
		Tfut <- readMat(filepath)$clim;
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pfutr5.mat",sep=''));
		Pfut <- readMat(filepath)$clim;
	  }else{
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Tfutr.mat",sep=''));
		Tfut <- readMat(filepath)$clim;
		filepath <- file.path(paste(futloc, gcmname[thisgcm], "Pfutr.mat",sep=''));
		Pfut <- readMat(filepath)$clim;		
	  }
	}

	Tdelt <- rowMeans( drop( Tfut[thisj,thisi,,futdecind[1]:futdecind[2],sres, drop=FALSE] ) - drop( Tbase[thisj,thisi,,basedecind[1]:basedecind[2], drop=FALSE] ) );

	### Old, erroneous version took average of ratio rather than ratio of averages
	###Pdelt = mean(squeeze(Pfut(thisj,thisi,:,futdecind(1):futdecind(2),sres))./squeeze(Pbase(thisj,thisi,:,basedecind(1):basedecind(2))),2);
	## corrected version
	Pdelt <- rowMeans( drop(Pfut[thisj,thisi,,futdecind[1]:futdecind[2],sres, drop=FALSE]) )/ rowMeans(drop(Pbase[thisj,thisi,,basedecind[1]:basedecind[2], drop=FALSE]) );

	## cap rainfall deltas at 300% (likely for dry season)
	Pdelt <- pmin(Pdelt,3);

	#ddate <- base(:,dayloc);   ## correct for Y2K, etc., if necessary
	ddate <- base[,dayloc];   ## correct for Y2K, etc., if necessary
	dummy <- base[,dayloc];  #YJ

	newscen = cbind(base[,dayloc], base[,solar], base[,maxT], base[,minT], base[,prate], dummy);

	for (dd in 1:length(ddate)){

	  jd = (ddate[dd] %% 1000);
	  yy = floor(ddate[dd]/1000);
	  thismm <- max(which(jd>mmcum));

	  if ((yy %% 4)){

	  }else{
		thismm = max(which(jd>mmcumleap));
	  }
	  newscen[dd,3] = base[dd,maxT]+Tdelt[thismm];
	  newscen[dd,4] = base[dd,minT]+Tdelt[thismm];
	  newscen[dd,5] = min(base[dd,prate]*Pdelt[thismm],999.9);  # ensure no formatting issue

	}

	## Calculate Tave and Tamp
	Tave = mean(mean(newscen[,3:4]));
	mmtick = c(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	mmcum = cumsum(mmtick);
	mmcum = mmcum[1:12];

	for (dd in 1:max(dim(newscen))){
	  newscen[dd,6] <- max(which(mmcum<((newscen[dd,1] %% 1000))));
	}
	Tmonth <- c(0,0,0,0,0,0,0,0,0,0,0,0);

	for (thismm in 1:12){
	  Tmonth[thismm] = mean(mean(newscen[which(newscen[,6]==thismm),3:4]));
	}
	Tamp = (max(Tmonth)-min(Tmonth))/2;

	## write it all out with proper station code

	## simple AgMIP format: 
	sink(paste(futloc, futname, '.AgMIP', sep=''));

	cat(c('*WEATHER DATA : ', headerplus));
	cat('\n');
	cat('\n');
	cat(sprintf("%54s", "@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT"),"\n");
	cat(sprintf("%6s%9.3f%9.3f%6.0f%6.1f%6.1f%6.1f%6.1f", shortfile, stnlat, stnlon, stnelev,Tave,Tamp,-99.0,-99.0),"\n");
	cat(sprintf("%s", "@DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND  DEWP  VPRS  RHUM"),"\n");

	for (dd in 1:length(ddate)){

	  jd = (ddate[dd] %% 1000);
	  yy = floor(ddate[dd]/1000);
	  thismm = max(which(jd>mmcum));
	  day = jd-mmcum[thismm];
	  if(yy %% 4){
	  
	  }else{
		thismm = max(which(jd>mmcumleap));
		day = jd-mmcumleap[thismm];
	  }
	  cat(sprintf("%7s%6s%4s%4s%6.1f%6.1f%6.1f%6.1f", as.character(newscen[dd,1]), as.character(yy), as.character(thismm), as.character(day), newscen[dd,2], newscen[dd,3], newscen[dd,4], newscen[dd,5]),"\n");

	}

	sink();
	#### convert to windows notepad format and remove temp file
	#cd(futloc)
	# #setwd(futloc);	
	#eval(['!awk ''' 'sub(' '"' '$' '"' ',' '"' '\r' '"' ')' ''' ' futname '.AgMIPunix > ' futname '.AgMIP']);
	# #eval(parse(text=c('!awk ','', 'sub(', '"', '$', '"', ',', '"', '\r', '"', ')', '',' ', futname, '.AgMIPunix > ', futname, '.AgMIP')));
	#eval(['!rm ' futname '.AgMIPunix']);
	# #eval(parse(text=c('!rm ', futname, '.AgMIPunix')));
	
	}
	
}


