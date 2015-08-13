
# Program test script for agmip2metrics
# by Yunchul Jung
# at 8/12/2012

	rootDir <- 'C:\\Users\\aruane\\Documents\\_work\\GISS\\AgMIP\\Climate-IT\\R-Yunchul\\';
	programDir <- paste(rootDir, 'r\\', sep='');
	dataDir <- paste(rootDir, 'data\\', sep='');
	
	source(paste(programDir, 'acr_agmipload.R', sep=''));
	source(paste(programDir, 'acr_agmip2metrics.R', sep=''));

	## input variables	
	infile <- paste('C:\\Users\\aruane\\Documents\\_work\\GISS\\AgMIP\\SouthAsia\\StationLocations\\SouthAsiaSeries\\', 'BDSY0QXX.AgMIP', sep='');
	jdstart = 160;
	jdend = 220;
	column = 8;
	analysistype = 'mean';
	reference = 10;
	specialoperator = 1;

	acr_agmip2metrics(infile,jdstart,jdend,column,analysistype,reference,specialoperator)