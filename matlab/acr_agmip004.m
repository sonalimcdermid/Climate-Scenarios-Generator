%			acr_agmip004
%
%       This script creates delta scenarios from CMIP3 GCMs and BCSD for 
%       the AgMIP Pilot at Obregon, Mexico.  This can ingest files in 
%       both .AgMIPm and .wthm/.wtgm formatted baselines and spits out 
%       scenarios in the AgMIP standard format.  Input files must have 
%       4-digit years (e.g. 1993, not 93).  AgMIPm and wthm have their 
%       headers removed so that they begin with the climate numbers.
%
%       Formerly acr_giss531.m before  July 1, 2011
%
%
%				author: Alex Ruane
%                                       aruane@giss.nasa.gov
%				date:	03/14/11
%                  updated for Pdelt:   03/06/12 
%
%       Here's my minimal key for a file   '
%
%       First 4 Digits describe location (e.g. OBRE, FL11)
%
%       Fifth Digit is time period and emissions scenario:
%       0 = 1980-2009 baseline 
%	1 = A2-2005-2035 (Near-term)
%	2 = B1-2005-2035 (Near-term)
%	3 = A2-2040-2069 (Mid-Century)
%	4 = B1-2040-2069 (Mid-Century)
%	5 = A2-2070-2099 (End-of-Century)
%	6 = B1-2070-2099 (End-of-Century)
%       S = sensitivity scenario
%       A = observational time period (determined in file)
%
%       Sixth Digit is GCM:
%       X = no GCM used
%       0 = imposed values (sensitivity tests)
%	A = bccr
%	B = cccma cgcm3
%	C = cnrm
%	D = csiro
%	E = gfdl 2.0
%	F = gfdl 2.1
%	G = giss er
%	H = inmcm 3.0
%	I = ipsl cm4
%	J = miroc3 2 medres
%	K = miub echo g
%   	L = mpi echam5
%	M = mri cgcm2
%	N = ncar ccsm3
%	O = ncar pcm1
%	P = ukmo hadcm3
%       T = NASA POWER
%       U = NARR
%       V = ERA-INTERIM
%       W = MERRA
%       Y = NCEP CFSR
%       Z = NCEP/DoE Reanalysis-2
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
function acr_agmip004(basefile,futloc,futname,shortfile,stnlat,stnlon,stnelev,stntavg,stntamp,basedecs,futdecs,sres,thisgcm,deltatype,intype);
%--------------------------------------------------
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  

%% begin debug
%basefile = '/home/aruane/temp/AgMIP/WheatPilot/Netherlands/NLHA0XXX.AgMIPm';
%futloc = '/home/aruane/temp/AgMIP/WheatPilot/Delta/'
%futname = 'NLHA5LXA';
%shortfile = 'NLHA';
%stnlat = 51+58/60;
%stnlon = 5+38/60;
%stnelev = 7;
%stntavg = -99.0;
%stntamp = -99.0;
%basedecs = [1980 2009];  %% these will take entire decades for delta calculations
%futdecs = [2070 2099];   %% these will take entire decades for delta calculations
%sres = 1;
%thisgcm = 12;
%deltatype = 'GCM';
%intype = 'AgMIPm';
%% end debug

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check input data format and set appropriate data column locations
%if(~(strcmp(intype,'AgMIPm')&&(strcmp(intype,'WTHm'))))
%  error('Unkown input data type');
%end;

if(strcmp(intype,'AgMIPm'))
  dayloc  = 1;
  solar = 5;
  maxT = 6;
  minT = 7;
  prate = 8;
elseif (strcmp(intype,'WTHm'))
  dayloc  = 1;
  solar = 2;
  maxT = 3;
  minT = 4;
  prate = 5;
else
    error('Unkown input data type');
end; 

%% standards:
headerplus = [futname ' - baseline dates maintained for leap year consistency'];
%% 1=left, 2=centered, 3=right based on first longitude reading
%% not sure about this, nothing says it can't be centered on 0 degrees
lonorient = [1 1 1 1 2 2 2 1 1 1 1 1 1 1 1 1];

mmtick = [0 31 28 31 30 31 30 31 31 30 31 30 31];
mmcum = cumsum(mmtick);
mmcumleap = mmcum + [0 0 1 1 1 1 1 1 1 1 1 1 1];

sresname = {'A2','B1'};
gcmname = {'bccrBCM2_0_','cccmaCGCM3_1_','cnrmCM3_','csiroMK3_0_','gfdlCM2_0_','gfdlCM2_1_','gissMODEL_E_R_','inmcm30_','ipslCM4_','miroc32_MEDRES_','miubECHO_G_','mpiECHAM5_','mriCGCM2_3_2a_','ncarCCSM3_0_','ncarPCM1_','ukmoHADCM3_'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
base = load(basefile);

%% default is to assume full decades
fiveyearsbase = 0;
basedecind = ceil((basedecs-1969)/10);
fiveyearsfut = 0;
futdecind = ceil((futdecs-2009)/10);

%% check for half-decades
if(mod(basedecs(1),10)==5)
  fiveyearsbase = 1;
  basedecind = ceil((basedecs-1964)/10);
end;
if(mod(futdecs(1),10)==5)
  fiveyearsfut = 1;
  futdecind = ceil((futdecs-2004)/10);
end;

if ((futdecind(2)-futdecind(1)) ~= 2)
  disp('Future period is not 3 decades');
end;
if ((basedecind(2)-basedecind(1)) ~= 2)
  disp('Baseline reference period is not 3 decades');
end;

if(strcmp(deltatype,'GCM'))
  if(stnlon<0),      %%convention here is [0 360]
    stnlon = stnlon+360;
  end;

  cd /home/aruane/temp/CMIP3/deltas
  clear clim Tbase Pbase Tfut Pfut
  load(['/home/aruane/temp/CMIP3/latlon/' gcmname{thisgcm} 'lat.mat']);
  load(['/home/aruane/temp/CMIP3/latlon/' gcmname{thisgcm} 'lon.mat']);

  %%% check for gridbox being defined on edge:
  %%% not sure about this at this time, leave commented out
  %%% I thought they were all centered
  %if(lonorient(thisgcm) == 1)
  %  lon = lon+mean(lon(1,1:2));
  %end;

  [thisj thisi] = acr_findspot(stnlat,stnlon,lat,lon);

  if ~(fiveyearsbase)
    load([gcmname{thisgcm} 'Tbase.mat']);
    Tbase = clim;
    load([gcmname{thisgcm} 'Pbase.mat']);
    Pbase = clim;
  end;
  if (fiveyearsbase)
    load([gcmname{thisgcm} 'Tbase5.mat']);
    Tbase = clim;
    load([gcmname{thisgcm} 'Pbase5.mat']);
    Pbase = clim;
  end;
  if ~(fiveyearsfut)
    load([gcmname{thisgcm} 'Tfutr.mat']);
    Tfut = clim;
    load([gcmname{thisgcm} 'Pfutr.mat']);
    Pfut = clim;
  end;
  if (fiveyearsfut)
    load([gcmname{thisgcm} 'Tfutr5.mat']);
    Tfut = clim;
    load([gcmname{thisgcm} 'Pfutr5.mat']);
    Pfut = clim;
  end;
end;

if(strcmp(deltatype,'Global_BCSD'))
  if(stnlon>180),      %%convention here is [-180 180]
    stnlon = stnlon-360;
  end;

  cd /home/aruane/temp/CMIP3/deltas/Global_BCSD
  clear clim Tbase Pbase Tfut Pfut
  load(['/home/aruane/temp/CMIP3/latlon/Global_BCSD_lat.mat']);
  load(['/home/aruane/temp/CMIP3/latlon/Global_BCSD_lon.mat']);

  %%% check for gridbox being defined on edge:
  %%% not sure about this at this time, leave commented out
  %%% I thought they were all centered
  %if(lonorient(thisgcm) == 1)
  %  lon = lon+mean(lon(1,1:2));
  %end;

  [thisj thisi] = acr_findspot(stnlat,stnlon,lat,lon);

  if ~(fiveyearsbase)
    load([gcmname{thisgcm} 'Tbase.mat']);
    Tbase = clim;
    load([gcmname{thisgcm} 'Pbase.mat']);
    Pbase = clim;
  end;
  if (fiveyearsbase)
    load([gcmname{thisgcm} 'Tbase5.mat']);
    Tbase = clim;
    load([gcmname{thisgcm} 'Pbase5.mat']);
    Pbase = clim;
  end;
  if ~(fiveyearsfut)
    load([gcmname{thisgcm} 'Tfutr.mat']);
    Tfut = clim;
    load([gcmname{thisgcm} 'Pfutr.mat']);
    Pfut = clim;
  end;
  if (fiveyearsfut)
    load([gcmname{thisgcm} 'Tfutr5.mat']);
    Tfut = clim;
    load([gcmname{thisgcm} 'Pfutr5.mat']);
    Pfut = clim;
  end;
end;

if(strcmp(deltatype,'US_BCSD'))
  if(stnlon>180),      %%convention here is [-180 180]
    stnlon = stnlon-360;
  end;

  cd /home/aruane/temp/CMIP3/deltas/US_BCSD
  clear clim Tbase Pbase Tfut Pfut
  load(['/home/aruane/temp/CMIP3/latlon/US_BCSD_lat.mat']);
  load(['/home/aruane/temp/CMIP3/latlon/US_BCSD_lon.mat']);

  %%% check for gridbox being defined on edge:
  %%% not sure about this at this time, leave commented out
  %%% I thought they were all centered
  %if(lonorient(thisgcm) == 1)
  %  lon = lon+mean(lon(1,1:2));
  %end;

  [thisj thisi] = acr_findspot(stnlat,stnlon,lat,lon);

  if ~(fiveyearsbase)
    load([gcmname{thisgcm} 'Tbase.mat']);
    Tbase = clim;
    load([gcmname{thisgcm} 'Pbase.mat']);
    Pbase = clim;
  end;
  if (fiveyearsbase)
    load([gcmname{thisgcm} 'Tbase5.mat']);
    Tbase = clim;
    load([gcmname{thisgcm} 'Pbase5.mat']);
    Pbase = clim;
  end;
  if ~(fiveyearsfut)
    load([gcmname{thisgcm} 'Tfutr.mat']);
    Tfut = clim;
    load([gcmname{thisgcm} 'Pfutr.mat']);
    Pfut = clim;
  end;
  if (fiveyearsfut)
    load([gcmname{thisgcm} 'Tfutr5.mat']);
    Tfut = clim;
    load([gcmname{thisgcm} 'Pfutr5.mat']);
    Pfut = clim;
  end;
end;


Tdelt = mean(squeeze(Tfut(thisj,thisi,:,futdecind(1):futdecind(2),sres)) - squeeze(Tbase(thisj,thisi,:,basedecind(1):basedecind(2))),2);

%%% Old, erroneous version took average of ratio rather than ratio of averages
%%%%Pdelt = mean(squeeze(Pfut(thisj,thisi,:,futdecind(1):futdecind(2),sres))./squeeze(Pbase(thisj,thisi,:,basedecind(1):basedecind(2))),2);

%% corrected version
Pdelt = mean(squeeze(Pfut(thisj,thisi,:,futdecind(1):futdecind(2),sres)),2)./mean(squeeze(Pbase(thisj,thisi,:,basedecind(1):basedecind(2))),2);

%% cap rainfall deltas at 300% (likely for dry season)
Pdelt = min(Pdelt,3);

ddate = base(:,dayloc);   %% correct for Y2K, etc., if necessary
newscen = [base(:,dayloc) base(:,solar) base(:,maxT) base(:,minT) base(:,prate)];
for dd=1:length(ddate),
  jd = mod(ddate(dd),1000);
  yy = floor(ddate(dd)/1000);
  thismm = max(find(jd>mmcum));
  if ~(mod(yy,4)),
    thismm = max(find(jd>mmcumleap));
  end;
  newscen(dd,3) = base(dd,maxT)+Tdelt(thismm);
  newscen(dd,4) = base(dd,minT)+Tdelt(thismm);
  newscen(dd,5) = min(base(dd,prate)*Pdelt(thismm),999.9);  % ensure no formatting issue
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
wthid = fopen([futloc futname '.AgMIPunix'],'w');
fprintf(wthid,'%s\n',['*WEATHER DATA : ' headerplus]);
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

fclose(wthid);
%%%% convert to windows notepad format and remove temp file
cd(futloc)
eval(['!awk ''' 'sub(' '"' '$' '"' ',' '"' '\r' '"' ')' ''' ' futname '.AgMIPunix > ' futname '.AgMIP']);
eval(['!rm ' futname '.AgMIPunix']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
