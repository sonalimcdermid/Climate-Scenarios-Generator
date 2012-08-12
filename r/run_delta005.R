
	rootDir <- 'E:\\agmip-src\\AgMIP-Climate-IT-pilot-tools-R\\';
	programDir <- paste(rootDir, 'r\\', sep='');
	dataDir <- paste(rootDir, 'data\\', sep='');
	
	source(paste(programDir, 'acr_agmip005.R', sep=''));

	## input variables	
	basefile <- paste(dataDir, 'NLHA0XXX.AgMIPm', sep='');
	futfile <- paste(dataDir, 'NLHA5PXA.AgMIPm', sep='');
	outfile <- paste(dataDir, 'NLHA5PXA.AgMIP', sep='');
	headerplus = 'NLHA5PXA - baseline dates maintained for leap year consistency';
	shortfile = 'NLHA';
	stnlat = 51+58/60;
	stnlon = 5+38/60;
	stnelev = 7;
	refht = 1.5;
	wndht = 2;

	## run function
	acr_agmip005(basefile,futfile,outfile,headerplus,shortfile,stnlat,stnlon,stnelev,refht,wndht);