%			acr_agmip004_cmip5
%
%       This script creates delta scenarios from CMIP5 GCMs and BCSD for 
%       the AgMIP Pilot at Obregon, Mexico.  This can ingest files in 
%       both .AgMIP and .wthm/.wtgm formatted baselines and spits out 
%       scenarios in the AgMIP standard format.  Input files must have 
%       4-digit years (e.g. 1993, not 93).  AgMIPm and wthm have their 
%       headers removed so that they begin with the climate numbers.
%
%
%				author: Alex Ruane
%                                       alexander.c.ruane@nasa.gov
%				date:	09/04/12
%
%       Here's my minimal key for a file   '
%
%       First 4 Digits describe location (e.g. OBRE, FL11)
%
%       Fifth Digit is time period and emissions scenario:
%       0 = 1980-2009 baseline 
%       1 = A2-2005-2035 (Near-term)
%       2 = B1-2005-2035 (Near-term)
%       3 = A2-2040-2069 (Mid-Century)
%       4 = B1-2040-2069 (Mid-Century)
%       5 = A2-2070-2099 (End-of-Century)
%       6 = B1-2070-2099 (End-of-Century)
%       S = sensitivity scenario
%       A = observational time period (determined in file)
%	    B = RCP3PD 2010-2039 (Near-term)
%	    C = RCP45  2010-2039 (Near-term)
%	    D = RCP60  2010-2039 (Near-term)
%	    E = RCP85  2010-2039 (Near-term)
%	    F = RCP3PD 2040-2069 (Mid-Century)
%	    G = RCP45  2040-2069 (Mid-Century)
%	    H = RCP60  2040-2069 (Mid-Century)
%	    I = RCP85  2040-2069 (Mid-Century)
%	    J = RCP3PD 2070-2099 (End-of-Century)
%	    K = RCP45  2070-2099 (End-of-Century)
%	    L = RCP60  2070-2099 (End-of-Century)
%	    M = RCP85  2070-2099 (End-of-Century)
%
%       Sixth Digit is source of baseline data (if baseline scenario)::
%       X = no GCM used
%       0 = imposed values (sensitivity tests)
%       Q = Bias-corrected MERRA
%       T = NASA POWER
%       U = NARR
%       V = ERA-INTERIM
%       W = MERRA
%       Y = NCEP CFSR
%       Z = NCEP/DoE Reanalysis-2

%       Sixth Digit is GCM (if CMIP3 scenario)::
%       X = no GCM used
%       0 = imposed values (sensitivity tests)
%       A = bccr
%       B = cccma cgcm3
%       C = cnrm
%       D = csiro
%       E = gfdl 2.0
%       F = gfdl 2.1
%       G = giss er
%       H = inmcm 3.0
%       I = ipsl cm4
%       J = miroc3 2 medres
%       K = miub echo g
%       L = mpi echam5
%       M = mri cgcm2
%       N = ncar ccsm3
%       O = ncar pcm1
%       P = ukmo hadcm3

%       Sixth Digit is GCM (if CMIP5 scenario):
%       0 = imposed values (sensitivity tests)
%       A = ACCESS1-0
%       B = bcc-csm1-1
%       C = BNU-ESM
%       D = CanESM2
%       E = CCSM4
%       F = CESM1-BGC
%       G = CSIRO-Mk3-6-0
%       H = GFDL-ESM2G
%       I = GFDL-ESM2M
%       J = HadGEM2-CC
%       K = HadGEM2-ES
%       L = inmcm4
%       M = IPSL-CM5A-LR
%       N = IPSL-CM5A-MR
%       O = MIROC5
%       P = MIROC-ESM
%       Q = MPI-ESM-LR
%       R = MPI-ESM-MR
%       S = MRI-CGCM3
%       T = NorESM1-M
%
%       Seventh Digit is downscaling/scenario methodology
%       X = no additional downscaling
%       0 = imposed values (sensitivity tests)
%       1 = WRF
%       2 = RegCM3
%       3 = ecpc
%       4 = hrm3
%       5 = crcm
%       6 = mm5i
%       7 = RegCM4
%       A = GiST
%       B = MarkSIM
%       C = WM2
%       D = 1/8 degree BCSD
%       E = 1/2 degree BCSD
%       F = 2.5minute WorldClim
%       W = TRMM 3B42
%       X = CMORPH
%       Y = PERSIANN
%       Z = GPCP 1DD
%
%       Eighth Digit is Type of Scenario:
%       X = Observations (no scenario)
%       A = Mean Change from GCM
%       B = Mean Change from RCM
%       C = Mean Change from GCM modified by RCM
%       D = Mean Temperature Changes Only
%       E = Mean Precipitation Changes Only
%       F = Mean and daily variability change for Tmax, Tmin, and P
%       G = P, Tmax and Tmin daily variability change only
%       H = Tmax and Tmin daily variability and mean change only
%       I = P daily variability and mean change only
%       J = Tmax and Tmin daily variability change only
%       K = P daily variability change only
%
function acr_agmip004_cmip5(basefile,futloc,futname,shortfile,stnlat,stnlon,stnelev,basedecs,futdecs,rcp,thisgcm);
%--------------------------------------------------
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  

%% begin debug
basefile = '/Users/sonalimcdermid/Desktop/SIndia/Weather/AgMIPClimate/BDBH0QXX.AgMIP';
futloc = '/Users/sonalimcdermid/Desktop/SIndia/Weather/Delta/simple/';
futname = 'BDBH0QXA';
shortfile = 'BDBH';
stnlat = 22.680;
stnlon = 90.650;
stnelev = 1556;
basedecs = [1980 2009];  %% these will take entire decades for delta calculations
futdecs = [2040 2069];   %% these will take entire decades for delta calculations
rcp = 3;
thisgcm = 1;
%% end debug

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check input data format and set appropriate data column locations
%if(~(strcmp(intype,'AgMIPm')&&(strcmp(intype,'WTHm'))))
%  error('Unkown input data type');
%end;
%% Assumes AgMIP Format
dayloc  = 1;
solar = 5;
maxT = 6;
minT = 7;
prate = 8;

%% standards:
headerplus = [futname ' - baseline dates maintained for leap year consistency'];

mmtick = [0 31 28 31 30 31 30 31 31 30 31 30 31];
mmcum = cumsum(mmtick);
mmcumleap = mmcum + [0 0 1 1 1 1 1 1 1 1 1 1 1];

rcpname = {'historical','rcp26','rcp45','rcp60','rcp85'};
gcmname = {'ACCESS1-0','bcc-csm1-1','BNU-ESM','CanESM2','CCSM4','CESM1-BGC','CSIRO-Mk3-6-0','GFDL-ESM2G','GFDL-ESM2M','HadGEM2-CC','HadGEM2-ES','inmcm4','IPSL-CM5A-LR','IPSL-CM5A-MR','MIROC5','MIROC-ESM','MPI-ESM-LR','MPI-ESM-MR','MRI-CGCM3','NorESM1-M'}; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
base = acr_agmipload(basefile);

%% default is to assume full decades
basedecind = ceil((basedecs-1979)/10);
futdecind = ceil((futdecs-2009)/10);

if ((futdecind(2)-futdecind(1)) ~= 2)
  disp('Future period is not 3 decades');
end;
if ((basedecind(2)-basedecind(1)) ~= 2)
  disp('Baseline reference period is not 3 decades');
end;

if(stnlon<0),      %%convention here is [0 360]
  stnlon = stnlon+360;
end;

clear meantasmaxbase meantasminbase meanprbase meantasmaxfut meantasminfut meanprfut
load(['C:\Users\aruane\Documents\_work\Matlab_Scripts\data\CMIP5\latlon\' gcmname{thisgcm} '_lat.mat']);
load(['C:\Users\aruane\Documents\_work\Matlab_Scripts\data\CMIP5\latlon\' gcmname{thisgcm} '_lon.mat']);
if (min(lon(1,:))<0)
  disp('WARNING -- Longitude may have wrong orientation'); 
end;

thisi = dsearchn(([lon(1,:) lon(1,1)+360])',stnlon);
% look for wrap-arond
if(thisi==(length(lon(1,:))+1))
  thisi = 1;
end;

thisj = dsearchn(lat(:,1),stnlat);   
if ((thisi == 1)||(thisj == 1)||(thisi == size(lon,1))||(thisj == size(lon,2)))
  disp('WARNING -- END POINT SELECTED.  ARE LATITUDE/LONGITUDE SIGNS CORRECT?'); 
end;

cd C:\Users\aruane\Documents\_work\Matlab_Scripts\data\CMIP5\climfiles\
load(['meantasmax_' gcmname{thisgcm} '_historical.mat']);
meantasmaxbase = meantasmax;
load(['meantasmin_' gcmname{thisgcm} '_historical.mat']);
meantasminbase = meantasmin;
load(['meanpr_' gcmname{thisgcm} '_historical.mat']);
meanprbase = meanpr;

load(['meantasmax_' gcmname{thisgcm} '_' rcpname{rcp} '.mat']);
meantasmaxfut = meantasmax;
load(['meantasmin_' gcmname{thisgcm} '_' rcpname{rcp} '.mat']);
meantasminfut = meantasmin;
load(['meanpr_' gcmname{thisgcm} '_' rcpname{rcp} '.mat']);
meanprfut = meanpr;



meantasmaxdelt = mean(squeeze(meantasmaxfut(thisj,thisi,:,futdecind(1):futdecind(2))) - squeeze(meantasmaxbase(thisj,thisi,:,basedecind(1):basedecind(2))),2);
meantasmindelt = mean(squeeze(meantasminfut(thisj,thisi,:,futdecind(1):futdecind(2))) - squeeze(meantasminbase(thisj,thisi,:,basedecind(1):basedecind(2))),2);

meanprdelt = mean(squeeze(meanprfut(thisj,thisi,:,futdecind(1):futdecind(2))),2)./mean(squeeze(meanprbase(thisj,thisi,:,basedecind(1):basedecind(2))),2);

%% cap rainfall deltas at 300% (likely for dry season)
meanprdelt = min(meanprdelt,3);

ddate = base(:,dayloc);   %% correct for Y2K, etc., if necessary
newscen = [base(:,dayloc) base(:,solar) base(:,maxT) base(:,minT) base(:,prate)];
for dd=1:length(ddate),
  jd = mod(ddate(dd),1000);
  yy = floor(ddate(dd)/1000);
  thismm = max(find(jd>mmcum));
  if ~(mod(yy,4)),
    thismm = max(find(jd>mmcumleap));
  end;
  newscen(dd,3) = base(dd,maxT)+meantasmaxdelt(thismm);
  newscen(dd,4) = base(dd,minT)+meantasmindelt(thismm);
  newscen(dd,3) = max([newscen(dd,3) newscen(dd,4)+0.1]);  %% ensure Tmax>Tmin
  newscen(dd,5) = min(base(dd,prate)*meanprdelt(thismm),999);  % ensure no formatting issue
end;


%% Calculate Tave and Tamp
Tave = mean(mean(newscen(:,3:4)));
mmtick = [0 31 28 31 30 31 30 31 31 30 31 30 31];
mmcum = cumsum(mmtick);
mmcum = mmcum(1:12);
for dd=1:length(newscen),
  newscen(dd,6) = max(find(mmcum<(mod(newscen(dd,1),1000))));
end;
for thismm=1:12,
  Tmonth(thismm) = mean(mean(newscen(find(newscen(:,6)==thismm),3:4)));
end;
Tamp = (max(Tmonth)-min(Tmonth))/2;

%% write it all out with proper station code

%% simple AgMIP format: 
wthid = fopen([futloc futname '.AgMIP'],'wt');
fprintf(wthid,'%s\n',['*WEATHER DATA : ' headerplus ' from ' gcmname{thisgcm}]);
fprintf(wthid,'\n');
fprintf(wthid,'%54s\n',['@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT']);
fprintf(wthid,'%6s%9.3f%9.3f%6.0f%6.1f%6.1f%6.1f%6.1f\n',['  ' shortfile],stnlat, stnlon, stnelev,Tave,Tamp,-99.0,-99.0);
fprintf(wthid,'%s\n',['@DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND  DEWP  VPRS  RHUM']);

for dd=1:length(ddate),
  jd = mod(ddate(dd),1000);
  yy = floor(ddate(dd)/1000);
  thismm = max(find(jd>mmcum));
  day = jd-mmcum(thismm);
  if ~(mod(yy,4)),
    thismm = max(find(jd>mmcumleap));
    day = jd-mmcumleap(thismm);
  end;
  fprintf(wthid,'%7s%6s%4s%4s%6.1f%6.1f%6.1f%6.1f\n',num2str(newscen(dd,1)),num2str(yy),num2str(thismm),num2str(day),newscen(dd,2:5));
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
