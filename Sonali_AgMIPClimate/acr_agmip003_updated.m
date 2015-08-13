%			acr_agmip003_updated
%
%    This script reads in a simple .AgMIP file and uses 
%    AgMERRA to fill in winds, RH, Tdew, and vapor pressure.
%    This should only be used when we do not have winds or humidity 
%    information.  Solar radiation can be replaced or not. 
%
%    AgMERRA(:,9) = winds (m/s)
%    AgMERRA(:,10) = Tdew (^oC)
%    AgMERRA(:,11) = RH (%)
%    AgMERRA(:,12) = vapor pressure (hPa)
%    AgMERRA(:,6) = max temperatures (^oC)  -- for reference / qc only
%
%    .AgMIP columns          5                              10
%     @DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND   DEWP  VPRS  RHUM
%
%
%    replacesolar = 1 if you want it to be replaced
%
%				author: Alex Ruane
%                                       aruane@giss.nasa.gov
%				date:	12/19/14
%
%   function acr_agmip003_updated(shortfile,basefile,merrafile,outfile,stnlat,stnlon,stnelev,refht,wndht,headerplus,replacesolar);
%--------------------------------------------------
%--------------------------------------------------
%%% Begin debug
shortfile = 'INCO';
basefile = '/Users/sonalimcdermid/Research/R/data/Climate/Historical/INCO0XXI.AgMIP';
merrafile = '/Users/sonalimcdermid/Research/R/data/Climate/Historical/INCO0QXX.AgMIP';
outfile = '/Users/sonalimcdermid/Research/R/data/Climate/Historical/INCO0XXX.AgMIP';
stnlat = 11.000;
stnlon = 77.000;
stnelev = 437;
refht = 2;
wndht = 2;
headerplus = 'Coimbatore, India';
replacesolar = 0;
%%% End debug
%--------------------------------------------------
%--------------------------------------------------
%--------------------------------------------------
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



%% Bring in basic file
baseobs = acr_agmipload(basefile);
if(strcmp(basefile,outfile))
  error('ERROR: outfile cannot be the same as basefile');
end;


%% Bring in agmipmerra file created by acr_agmip002.m
QXX = acr_agmipload(merrafile);         %% creates AgMERRA

%% Create larger file
new = baseobs;

%% solar radiation if desired
if(replacesolar)
  new(:,5) = QXX(:,5);
end;

%% winds
new(:,9) = QXX(:,9);

%% Relative Humidity at Tmax 
new(:,12) = QXX(:,12);

%% set minimum RH on rainy days to 50%
new(find(new(:,8)>0),12) = max(50,new(find(new(:,8)>0),12));  

%% set minimum RH as 1% (no 0% Humidities)
new(find(new(:,12)<1),12) = 1;  


%% Vapor Pressure
for ii=1:length(new(:,1)),
  %% calculate saturation vapor pressure from Tmax
  %% Clausius-Clapeyron from Curry and Webster page 112
  es(ii) = eos*exp(Lv/Rv*(1/To - 1/(new(ii,6)+To)));
end;

%% Relative Humidity at Tmax
new(:,11) = new(:,12)/100 .* es';   %% relative humidity

%% Calculate Dew Point Temperatures
for ii=1:length(new(:,11)),
  new(ii,10) = 1/((1/To)-(Rv/Lv)*log(new(ii,11)/eos)) - To;
end;


%% Calculate Tave and Tamp
Tave = mean(mean(new(:,6:7)));
for thismm=1:12,
  Tmonth(thismm) = mean(mean(new(find(new(:,3)==thismm),6:7)));
end;
Tamp = (max(Tmonth)-min(Tmonth))/2;


%% print it all out
mmtick = [0 31 28 31 30 31 30 31 31 30 31 30 31];
mmtickleap = [0 31 29 31 30 31 30 31 31 30 31 30 31];
mmcum = cumsum(mmtick);
mmcumleap = cumsum(mmtickleap);

ddate = new(:,1);
%% save fixed 1980-2010 baseline in AgMIP format: 
wthid = fopen([outfile 'unix'],'w');
fprintf(wthid,'%s\n',['*WEATHER DATA : ' headerplus]);
fprintf(wthid,'\n');
fprintf(wthid,'%54s\n',['@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT']);
%%% Don't forget to adjust reference height for temperature and 
fprintf(wthid,'%6s%9.3f%9.3f%6.0f%6.1f%6.1f%6.1f%6.1f\n',['  ' shortfile],stnlat, stnlon, stnelev,Tave,Tamp,refht,wndht);
fprintf(wthid,'%s\n',['@DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND  DEWP  VPRS  RHUM']);

for dd=1:length(ddate),
  fprintf(wthid,'%7s%6s%4s%4s%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.0f\n',num2str(new(dd,1)),num2str(new(dd,2)),num2str(new(dd,3)),num2str(new(dd,4)),new(dd,5:12));
end;

fclose(wthid);
%%%% convert to windows notepad format and remove temp file
eval(['!awk ''' 'sub(' '"' '$' '"' ',' '"' '\r' '"' ')' ''' ' outfile 'unix > ' outfile]);
eval(['!rm ' outfile 'unix']);
