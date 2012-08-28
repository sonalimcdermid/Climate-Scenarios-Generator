
	rootDir <- 'E:\\git-src\\AgMIP-Climate-IT-pilot-tools-R\\';
	programDir <- paste(rootDir, 'r\\', sep='');
	dataDir <- paste(rootDir, 'data\\', sep='');
	
	source(paste(programDir, 'acr_findspot.R', sep=''));
	source(paste(programDir, 'acr_agmip004.R', sep=''));
	
	## input variables
	basefile <- paste(dataDir, 'USAM0XXX.AgMIPm', sep='');
	futloc <- paste(dataDir, 'simple\\', sep='');
	futname <- 'USAM5PXA'; #'USAM5LXA'; #'NLHA5LXA';
	shortfile <- 'USAM'; #'NLHA';
	stnlat <- 42.017; #51+58/60;
	stnlon <- -93.750; #5+38/60;
	stnelev <- 329; #7;
	stntavg <- -99.0;
	stntamp <- -99.0;
	basedecs <- c(1980, 2009); #[1980 2009];
	futdecs <- c(2070, 2099); #[2070 2099];
	sres <- 1;
	thisgcm = 16; #12;
	deltatype <- 'GCM';
	intype <- 'AgMIPm';

	## run function
	acr_agmip004(basefile,futloc,futname,shortfile,stnlat,stnlon,stnelev,stntavg,stntamp,basedecs,futdecs,sres,thisgcm,deltatype,intype);

