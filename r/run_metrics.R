
# Program test script for agmip2metrics
# by Yunchul Jung
# at 8/12/2012

	rootDir <- 'E:\\agmip-src\\AgMIP-Climate-IT-pilot-tools-R\\';
	programDir <- paste(rootDir, 'r\\', sep='');
	dataDir <- paste(rootDir, 'data\\', sep='');
	
	source(paste(programDir, 'acr_agmipload.R', sep=''));
	source(paste(programDir, 'acr_agmip2metrics.R', sep=''));

	## input variables	
	infile <- paste(dataDir, 'USAM0XXX.AgMIP', sep='');
	jdstart = 160;
	jdend = 220;
	column = 8;
	analysistype = 'maxconsecutivedays';
	reference = 10;
	specialoperator = 1;

	acr_agmip2metrics(infile,jdstart,jdend,column,analysistype,reference,specialoperator)