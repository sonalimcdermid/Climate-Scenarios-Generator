%			acr_agmip0000_cmip5
%
%       This script creates the baseline and future delta scenarios 
%       in one fell swoop by calling the other acr_agmip00* routines.
%
%       Starting with a file like PAEN0XXX.AgMIP that is already 
%       quality-controlled
%       
%				author: Alex Ruane
%                                       aruane@giss.nasa.gov
%				date:	09/05/12
%
%
function acr_agmip0000_cmip5(shortfile,stnlat,stnlon,stnelev,refht,wndht,headerplus,inloc,outloc,lineoffset,yyoffset)
%--------------------------------------------------
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  
%% begin debug
%shortfile = 'KEKA';
%stnlat = -1.580;
%stnlon = 37.250;
%stnelev = 1556;
%refht = -99;
%wndht = -99;
%headerplus = 'Katumani, Kenya';
%inloc = 'C:\Users\aruane\Documents\_work\GISS\AgMIP\ClimateData\Countries\Kenya\';
%outloc = 'C:\Users\aruane\Documents\_work\GISS\AgMIP\ClimateData\Countries\Kenya\';
%lineoffset = 5;
%yyoffset = 1900;
%% end debug

disp(shortfile);
basefile = [outloc shortfile '0XXX.AgMIP'];

simpleloc = [outloc 'Delta\simple\'];
basedecs = [1980 2009];  %% these will take entire decades for delta calculations
gcmlist = 'ABCDEFGHIJKLMNOPQRST';

scencode = 'CE';
scenlist = [3 5];
futdecs = [2010 2039];   %% these will take entire decades for delta calculations
for scen=1:2,
  for thisgcm=[1:4 6:14 16:18 20],
%  for thisgcm=1:length(gcmlist),
    disp(['scen = ' scencode(scen) '    gcm = ' num2str(thisgcm)]);
    futname = [shortfile scencode(scen) gcmlist(thisgcm) 'XA'];

    acr_agmip004_cmip5_windows(basefile,simpleloc,futname,shortfile,stnlat,stnlon,stnelev,basedecs,futdecs,scenlist(scen),thisgcm);
  end;
end;
scencode = 'GI';
scenlist = [3 5];
futdecs = [2040 2069];   %% these will take entire decades for delta calculations
for scen=1:2,
  for thisgcm=[1:4 6:14 16:18 20],
%  for thisgcm=1:length(gcmlist),
    disp(['scen = ' scencode(scen) '    gcm = ' num2str(thisgcm)]);
    futname = [shortfile scencode(scen) gcmlist(thisgcm) 'XA'];

    acr_agmip004_cmip5_windows(basefile,simpleloc,futname,shortfile,stnlat,stnlon,stnelev,basedecs,futdecs,scenlist(scen),thisgcm);
  end;
end;
scencode = 'KM';
scenlist = [3 5];
futdecs = [2070 2099];   %% these will take entire decades for delta calculations
for scen=1:2,
  for thisgcm=[1:4 6:14 16:18 20],
%  for thisgcm=1:length(gcmlist),
    disp(['scen = ' scencode(scen) '    gcm = ' num2str(thisgcm)]);
    futname = [shortfile scencode(scen) gcmlist(thisgcm) 'XA'];

    acr_agmip004_cmip5_windows(basefile,simpleloc,futname,shortfile,stnlat,stnlon,stnelev,basedecs,futdecs,scenlist(scen),thisgcm);
  end;
end;

%=================
%=================
deltaloc = [outloc 'Delta/'];
scencode = 'CEGIKM';

for thisscen=1:length(scencode),
  for thisgcm=[1:4 6:14 16:18 20],
%  for thisgcm=1:length(gcmlist),
    disp(['scen = ' scencode(thisscen) '    gcm = ' num2str(thisgcm)]);
    futfile = [simpleloc shortfile scencode(thisscen) gcmlist(thisgcm) 'XA.AgMIP'];
    outfile = [deltaloc shortfile scencode(thisscen) gcmlist(thisgcm) 'XA.AgMIP'];
    headerplus3 = [shortfile scencode(thisscen) gcmlist(thisgcm) 'XA - baseline dates maintained for leap year consistency; ' gcmlist(thisgcm)];

    acr_agmip005_windows(basefile,futfile,outfile,headerplus3,shortfile,stnlat,stnlon,stnelev,refht,wndht);
  end;
end;
