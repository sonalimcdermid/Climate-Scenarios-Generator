%			acr_agmip021
%
%       This script produces baseline .AgMIP files from the climate 
%       zones that come out of acr_agmip020.m for a given region.
%
%       This requires a seed file (in .AgMIP format) from within the 
%       region in order to calibrate the region.  Eventually this should
%       be able to take multiple seed files, but not yet.
%
%       This can produce strange values at high elevations, as humidities 
%       would be higher and orographic precipitation is not well captured.
%
%       Includes elements from acr_agmip004.m for delta method
%       and acr_agmip005.m to adjust moisture variables with new temperatures
%
%       Any seed file can be used (baseline or future scenario, provided 
%       the proper code is required in outend and that a .AgMIPm file exists).
%       Note that all of these should have an 'F' in the seventh digit to 
%       denote 2.5 minute WorldClim was used.
%      
%       All climate zones have the same latitude and longitude as the climate 
%       zones do not have a specific lat/lon, but elevation is noted in the file.
%
%				author: Alex Ruane
%                                       alexander.c.ruane@nasa.gov
%				date:	01/10/12
%
%
function acr_agmip021(rtitle,shortregion,rloc,seedfile,stnlat,stnlon,stnelev,refht,wndht,headerplus,outend,outloc);
%--------------------------------------------------
%--------------------------------------------------
%%%% start debug
%rtitle = 'Machakos2';
%shortregion = 'M2';
%rloc = 'C:\Users\aruane\Documents\_work\Matlab_Scripts\data\WorldClim\test\';
%seedfile = 'C:\Users\aruane\Documents\_work\GISS\AgMIP\ClimateData\Countries\Kenya\KEKA0XXX.AgMIPm';
%stnlat = -1.580;
%stnlon = 37.250;
%stnelev = 1556;
%refht = -99;
%wndht = -99;
%headerplus = 'Based from Katumani, Kenya -- Accra Workshop Test';
%outend = '0XFX';             %% F in seventh digit = Worldclim
%outloc = 'C:\Users\aruane\Documents\_work\Matlab_Scripts\data\WorldClim\test\';
%%%% end debug

%% Check outend
if (~strcmp(outend(3),'F'))
  disp('OUTEND SHOULD HAVE F IN 3RD DIGIT FOR WORLDCLIM CLIMATE ZONES');
end;

%% Data definitions to get out of the way
%% calculate saturation vapor pressure from T
%% Clausius-Clapeyron from Curry and Webster page 112
% es = eos*exp(Lv/Rv*(1/To - 1/T));
% Td = 1/((1/To)-(Rv/Lv)*log(e/eos));
% RH = e/es * 100;
eos = 6.11; %hPa;
Lv = 2.5e6; %J/kg
To = 273.16; %K
Rv = 461; %J/K/kg
eps = 0.622;  %%(=Mv/Md)
mmtick = [0 31 28 31 30 31 30 31 31 30 31 30 31];
mmcum = cumsum(mmtick);
mmcumleap = mmcum + [0 0 1 1 1 1 1 1 1 1 1 1 1];


base = load(seedfile);
load([rloc rtitle '_sublat']);
load([rloc rtitle '_sublon.mat']);
load([rloc rtitle '_superzonemean.mat']);
load([rloc rtitle '_overview.mat']);
climzones = overview(:,:,4);
nzones = max(max(climzones));

[thisi,thisj] = acr_findspot(stnlat,stnlon,sublat,sublon);

seedzone = overview(thisi,thisj,4);

%% calculate deltas from seed according to spatial pattern from Worldclim
for ii=1:nzones,
  superchange(ii,1:14) = superzonemean(ii,1:14)-superzonemean(12,1:14);
  superchange(ii,15:27) = superzonemean(ii,15:27)./superzonemean(12,15:27);
end;

%%% print out map of climate zones and seed location
%figure(100);
%acr_pcolormapr2_nocoast(overview(:,:,4),sublat,sublon,[1-0.5 nzones+0.5]);
%colormap('default');
%cmap = colormap;
%zonecmap = cmap(round(1:length(cmap)/nzones:length(cmap)),:);
%colormap(zonecmap);
%hold on;
%title(['Climate Zones and Seed Climate Series']);
%plotm(stnlat,stnlon,'ok','markerfacecolor','k');
%print(100,'-depsc',[outloc rtitle '_' shortregion '_ClimZonesAndSeed'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% print them out
for thiszone = 1:nzones,
  zonez = num2str(thiszone);
  if (thiszone<10)
    zonez = ['0' zonez];
  end;
  outfile = [outloc shortregion zonez outend '.AgMIP'];
  disp(outfile);
  Tdelt = superchange(thiszone,3:14);
  Pdelt = superchange(thiszone,16:27);
  %% cap rainfall deltas at 300% (likely for dry season or near mountain peaks)
  Pdelt = min(Pdelt,3);

  ddate = base(:,1);   %% correct for Y2K, etc., if necessary
  newscen = base;
  for dd=1:length(ddate),
    jd = mod(ddate(dd),1000);
    yy = floor(ddate(dd)/1000);
    thismm = max(find(jd>mmcum));
    if ~(mod(yy,4)),
      thismm = max(find(jd>mmcumleap));
    end;
    newscen(dd,6) = base(dd,6)+Tdelt(thismm);
    newscen(dd,7) = base(dd,7)+Tdelt(thismm);
    newscen(dd,8) = min(base(dd,8)*Pdelt(thismm),999.9); %ensure no formatting issue
    %% use RH to calculate vapor pressure
    es(dd) = eos*exp(Lv/Rv*(1/To - 1/(newscen(dd,6)+To)));
    newscen(dd,11) = newscen(dd,12)/100 .* es(dd);
    %% Calculate Dew Point Temperatures
    newscen(dd,10) = 1/((1/To)-(Rv/Lv)*log(newscen(dd,11)/eos)) - To;
  end;

  %% write it all out with proper station code in AgMIP format

  %% full AgMIP format: 
  Tave = mean(mean(newscen(:,6:7)));
  for thismm=1:12,
    Tmonth(thismm) = mean(mean(newscen(find(newscen(:,3)==thismm),6:7)));
  end;
  Tamp = (max(Tmonth)-min(Tmonth))/2;

  wthid = fopen(outfile,'wt');
  fprintf(wthid,'%s\n',['*WEATHER DATA : ' headerplus ' cast to WorldClim-derived climate zone ' zonez]);
  fprintf(wthid,'\n');
  fprintf(wthid,'%54s\n',['@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT']);
  %%% Don't forget to adjust reference height for temperature and winds
  fprintf(wthid,'%6s%9.3f%9.3f%6.0f%6.1f%6.1f%6.1f%6.1f\n',['  ' shortregion zonez],stnlat, stnlon, superzonemean(thiszone,1),Tave,Tamp,refht,wndht);
  fprintf(wthid,'%s\n',['@DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND  DEWP  VPRS  RHUM']);

  for dd=1:length(ddate),
    fprintf(wthid,'%7s%6s%4s%4s%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.0f\n',num2str(newscen(dd,1)),num2str(newscen(dd,2)),num2str(newscen(dd,3)),num2str(newscen(dd,4)),newscen(dd,5:12));
  end;

  fclose(wthid);
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
