%			acr_agmip005
%
%       This script converts basic future scenarios (Srad, maxT, minT, P) 
%       into full scenarios with relative humidity-controlled vapor pressure
%       based upon daily Tmax
%
%       THIS WAS FORMERLY acr_giss535.m -- July 1, 2011
%       updated for new format, Tmax reference temperatures, and Td July 1, 2011
%
%				author: Alex Ruane
%                                       aruane@giss.nasa.gov
%				date:	06/14/11
%
%
function acr_agmip005(basefile,futfile,outfile,headerplus,shortfile,stnlat,stnlon,stnelev,refht,wndht);
%--------------------------------------------------
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  

%% begin debug
%basefile = '/home/aruane/temp/AgMIP/WheatPilot/Netherlands/NLHA0XXX.AgMIP';
%futfile = '/home/aruane/temp/AgMIP/WheatPilot/Netherlands/Delta/simple/NLHA5PXA.AgMIP';
%outfile = '/home/aruane/temp/AgMIP/WheatPilot/Netherlands/Delta/NLHA5PXA.AgMIP';
%headerplus = 'NLHA7PXA - baseline dates maintained for leap year consistency';
%shortfile = 'NLHA';
%stnlat = 51+58/60;
%stnlon = 5+38/60;
%stnelev = 7;
%refht = 1.5;
%wndht = 2;
%% end debug

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
base = acr_agmipload(basefile);
fut = acr_agmipload(futfile);
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

newfut = [fut(:,1:8) base(:,9:end)];
for ii=1:length(newfut(:,1)),
  %% calculate saturation vapor pressure from Tmax
  es(ii) = eos*exp(Lv/Rv*(1/To - 1/(newfut(ii,6)+To)));
end;

%% use RH to calculate vapor pressure
newfut(:,11) = newfut(:,12)/100 .* es';

%% Calculate Dew Point Temperatures
for ii=1:length(newfut(:,11)),
  newfut(ii,10) = 1/((1/To)-(Rv/Lv)*log(newfut(ii,11)/eos)) - To;
end;

%% Calculate Tave and Tamp
Tave = mean(mean(newfut(:,6:7)));
for thismm=1:12,
  Tmonth(thismm) = mean(mean(newfut(find(newfut(:,3)==thismm),6:7)));
end;
Tamp = (max(Tmonth)-min(Tmonth))/2;

%% Print it all out
ddate = newfut(:,1);
wthid = fopen(outfile,'wt');
fprintf(wthid,'%s\n',['*WEATHER DATA : ' headerplus]);
fprintf(wthid,'\n');
fprintf(wthid,'%54s\n',['@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT']);
%%% Don't forget to adjust reference height for temperature and winds
fprintf(wthid,'%6s%9.3f%9.3f%6.0f%6.1f%6.1f%6.1f%6.1f\n',['  ' shortfile],stnlat, stnlon, stnelev,Tave,Tamp,refht,wndht);
fprintf(wthid,'%s\n',['@DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND  DEWP  VPRS  RHUM']);

for dd=1:length(ddate),
  fprintf(wthid,'%7s%6s%4s%4s%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.0f\n',num2str(newfut(dd,1)),num2str(newfut(dd,2)),num2str(newfut(dd,3)),num2str(newfut(dd,4)),newfut(dd,5:12));
end;

fclose(wthid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
