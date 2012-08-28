
	rootDir <- 'E:\\git-src\\AgMIP-Climate-IT-pilot-tools-R\\';
	programDir <- paste(rootDir, 'r\\', sep='');
	dataDir <- paste(rootDir, 'data\\', sep='');
	
	source(paste(programDir, 'acr_findspot.R', sep=''));
	source(paste(programDir, 'acr_agmip004.R', sep=''));
	source(paste(programDir, 'acr_agmip005.R', sep=''));
	
	source(paste(programDir, 'acr_agmip0000.R', sep=''));
	
	## input variables

	shortfile <- 'USAM'; #'NLHA';
	stnlat <- 42.017; #51+58/60;
	stnlon <- -93.750; #5+38/60;
	stnelev <- 329; #7;
	
	refht = -99;
	wndht = -99;
	headerplus = 'Ames, USA';

	inloc <- paste(dataDir, 'USAM0XXX.AgMIPm', sep='');
	outloc <- paste(dataDir, 'simple\\', sep='');
	
	ending = '.WTH';
	lineoffset = 5;
	yyoffset = 1900;
	
	## run function
	acr_agmip0000(shortfile,stnlat,stnlon,stnelev,refht,wndht,headerplus,inloc,outloc,ending,lineoffset,yyoffset);
	