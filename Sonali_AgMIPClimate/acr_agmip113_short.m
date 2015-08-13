%			acr_agmip113_short
%
%       This script creates the baseline and future mean and variaiblity scenarios 
%       in one fell swoop by calling acr_agmip112.m.
%
%       Starting with a file like PAEN0XXX.AgMIP that is already 
%       quality-controlled
%       
%				author: Alex Ruane
%                                       aruane@giss.nasa.gov
%				date:	12/27/12
%
%
%function acr_agmip113_short(shortfile,stnlat,stnlon,stnelev,refht,wndht,headerplus,inloc,outloc)
%--------------------------------------------------
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  
%% begin debug
shortfile = 'INTR';
stnlat = 10.750;
stnlon = 78.600;
stnelev = 85;
refht = -99;
wndht = -99;
headerplus = 'Trichy, India: Observed';
inloc = '/Users/sonalimcdermid/Research/R/data/Climate/Historical/';
outloc = '/Users/sonalimcdermid/Research/R/data/Climate/Simplescenario/';
%% end debug

disp(shortfile);
basefile = [inloc shortfile '0XXX.AgMIP'];

basedecs = [1980 2009];  %% these will take entire decades for delta calculations
gcmlist = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ123';

scencode = 'I';
scenlist = 5;
futdecs = [2040 2069];   %% these will take entire decades for delta calculations
for scen=1:length(scencode),
  for thisgcm=1:length(gcmlist),
    disp(['scen = ' scencode(scen) '    gcm = ' num2str(thisgcm)]);
    futname = [shortfile scencode(scen) gcmlist(thisgcm) 'XF'];
    acr_agmip112(basefile,outloc,futname,shortfile,stnlat,stnlon,stnelev,headerplus,basedecs,futdecs,scenlist(scen),thisgcm);
  end;
end;

%=================
%=================
% for thisscen=1:length(scencode),
%   for thisgcm=1:length(gcmlist),
%     disp(['scen = ' scencode(thisscen) '    gcm = ' num2str(thisgcm) '  AgMIP --> WTH']);
%     infile = [outloc shortfile scencode(thisscen) gcmlist(thisgcm) 'XF.AgMIP'];
%     outfile = [outloc shortfile scencode(thisscen) gcmlist(thisgcm) 'XF.WTH'];
%     acr_agmip2WTH(infile,outfile);
%   end;
% end;
