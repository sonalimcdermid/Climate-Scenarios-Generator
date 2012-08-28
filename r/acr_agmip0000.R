

acr_agmip0000 <- function(shortfile,stnlat,stnlon,stnelev,refht,wndht,headerplus,inloc,outloc,ending,lineoffset,yyoffset){


	## begin debug
	#shortfile = 'BRPF';
	#stnlat = -28.25;
	#stnlon = -52.4;
	#stnelev = 684;
	#refht = -99;
	#wndht = -99;
	#headerplus = 'Passo Fundo, Brazil';
	#inloc = '/home/aruane/temp/AgMIP/SouthAmerica/Brazil/';
	#outloc = '/home/aruane/temp/AgMIP/SouthAmerica/Brazil/';
	#ending = '.WTH';
	#lineoffset = 5;
	#yyoffset = 1900;
	## end debug

	##############################################################
	#disp(shortfile);

	#infile = [inloc shortfile '0XXX'];  
	#outfile = [outloc shortfile '0XXX']; 
	#acr_agmip000(infile,ending,outfile,lineoffset,yyoffset);

	#=================
	## acr_agmip002 must be run in advance
	## acr_agmip002point5 must be run in advance
	#=================

	#=================
	#=================
	#cd(outloc)
	#unix(['awk ''NR>5 {print}'' ' shortfile '0XXX.AgMIP > ' shortfile '0XXX.AgMIPm']);
	#=================
	#=================
	#basefile = [outloc shortfile '0XXX.AgMIPm'];
	basefile = paste(outloc, shortfile, '0XXX.AgMIPm', sep='');
	
	#merrafile = ['/home/aruane/temp/MERRA/AgMIPvect/' shortfile '_agmipmerra.mat'];
	#headerplus2 = [headerplus ' + MERRA'];
	#acr_agmip003(shortfile,basefile,merrafile,outfile,stnlat,stnlon,stnelev,refht,wndht,headerplus2);
	#=================
	#=================
	#cd(outloc)
	#unix(['awk ''NR>5 {print}'' ' shortfile '0XXX.AgMIP > ' shortfile '0XXX.AgMIPm']);
	#=================
	#=================

	##############################################################
	
	simpleloc = c(outloc, 'simple/');
	stntavg = -99.0;
	stntamp = -99.0;
	basedecs = c(1980, 2009);  ## these will take entire decades for delta calculations
	gcmlist <- c('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P');
	deltatype = 'GCM';
	intype = 'AgMIPm';

	scenlist = c('1','2');
	futdecs = c(2005, 2034);   ## these will take entire decades for delta calculations
	for (sres in 1:2) {
	  for (thisgcm in 1:16){
		print(paste('sres = ', scenlist[sres], '    gcm = ', as.character(thisgcm), sep=''));
		futname = paste(shortfile, scenlist[sres], gcmlist[thisgcm], 'XA', sep='');

		acr_agmip004(basefile,simpleloc,futname,shortfile,stnlat,stnlon,stnelev,stntavg,stntamp,basedecs,futdecs,sres,thisgcm,deltatype,intype);
	  }
	}

	scenlist = c('3','4');
	futdecs = c(2040, 2069);   ## these will take entire decades for delta calculations
	
	for (sres in 1:2) {
	  for (thisgcm in 1:16){
		print(paste('sres = ', scenlist[sres], '    gcm = ', as.character(thisgcm), sep=''));
		futname = paste(shortfile, scenlist[sres], gcmlist[thisgcm], 'XA', sep='');

		acr_agmip004(basefile,simpleloc,futname,shortfile,stnlat,stnlon,stnelev,stntavg,stntamp,basedecs,futdecs,sres,thisgcm,deltatype,intype);
	  }
	}

	scenlist = c('5','6');
	futdecs = c(2070, 2099);   ## these will take entire decades for delta calculations
	
	for (sres in 1:2) {
	  for (thisgcm in 1:16){
		print(paste('sres = ', scenlist[sres], '    gcm = ', as.character(thisgcm), sep=''));
		futname = paste(shortfile, scenlist[sres], gcmlist[thisgcm], 'XA', sep='');

		acr_agmip004(basefile,simpleloc,futname,shortfile,stnlat,stnlon,stnelev,stntavg,stntamp,basedecs,futdecs,sres,thisgcm,deltatype,intype);
	  }
	}

	#=================
	#=================
	#cd(simpleloc);

	#for sres=1:6,
	#  for thisgcm=1:16,
	#	unix(['awk ''NR>5 {print}'' ' shortfile num2str(sres) gcmlist[thisgcm] 'XA.AgMIP > ' shortfile num2str(sres) gcmlist[thisgcm] 'XA.AgMIPm']);
	#  end;
	#end;
	#=================
	#=================
	deltaloc = c(outloc,'Delta/');
	scenlist = c('1','2','3','4','5','6');

	for (thisscen in 1:length(scenlist)){
	  for (thisgcm in 1:16){
		print(paste('sres = ', scenlist[thisscen], '    gcm = ', as.character(thisgcm), sep=''));
		futfile = paste(simpleloc, shortfile, scenlist[thisscen], gcmlist[thisgcm], 'XA.AgMIPm', sep='');
		outfile = paste(deltaloc, shortfile, scenlist[thisscen], gcmlist[thisgcm], 'XA.AgMIP', sep='');
		headerplus3 = paste(shortfile, scenlist[thisscen], gcmlist[thisgcm], 'XA - baseline dates maintained for leap year consistency', sep='');

		acr_agmip005(basefile,futfile,outfile,headerplus3,shortfile,stnlat,stnlon,stnelev,refht,wndht);
	  }
	}


}



