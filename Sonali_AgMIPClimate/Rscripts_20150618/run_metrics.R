
# Program test script for agmip2metrics
# by Yunchul Jung
# at 8/12/2012

	rootDir <- '/Users/sonalimcdermid/Research/R';
	programDir <- paste(rootDir, '/r/', sep='');
	dataDir <- paste(rootDir, '/data/', sep='');
	
	source(paste(programDir, 'acr_agmipload.R', sep=''));
	source(paste(programDir, 'acr_agmip2metrics.R', sep=''));

	## input variables	
	#infile <- paste('/Users/sonalimcdermid/Desktop/R/data/Climate/Historical/', 'INHY0QXX.AgMIP', sep='');
	#infile <- paste('/Users/sonalimcdermid/Desktop/R/data/Climate/Fullscenario/', 'INHYGEXA.AgMIP', sep='');
	
	files <- list.files(path="/Users/sonalimcdermid/Research/R/data/Climate/Metrics/", pattern="*.AgMIP", full.names=T, recursive=FALSE)
	for(i in 1:length(files)) {
	infile = files[i];
	jdstart = 274;
	jdend = 365;
	column = 8;
	analysistype = 'sum';
	reference = 0.1;
	specialoperator = 1;
	acr_agmip2metrics(infile,jdstart,jdend,column,analysistype,reference,specialoperator)
	}
	

