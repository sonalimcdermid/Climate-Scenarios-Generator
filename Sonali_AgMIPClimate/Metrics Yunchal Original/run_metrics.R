# Program test script for agmip2metrics
# by Yunchul Jung
# at 8/12/2012

	rootDir <- '/Users/sonalimcdermid/Desktop/R';
	programDir <- paste(rootDir, '/r/', sep='');
	dataDir <- paste(rootDir, '/data/', sep='');
	
	source(paste(programDir, 'acr_agmipload.R', sep=''));
	source(paste(programDir, 'acr_agmip2metrics.R', sep=''));

	## input variables	
	infile <- paste('/Users/sonalimcdermid/Desktop/R/data/Climate/Fullscenario/', 'INMHIHXA.AgMIP', sep='');
	#infile <- paste('/Users/sonalimcdermid/Desktop/R/data/Climate/Fullscenario/', 'INHYGEXA.AgMIP', sep='');
	
	
	jdstart = 152;
	jdend = 273;
	column = 6;
	analysistype = 'mean';
	reference = 0;
	specialoperator = 1;
	
	acr_agmip2metrics(infile,jdstart,jdend,column,analysistype,reference,specialoperator)
	