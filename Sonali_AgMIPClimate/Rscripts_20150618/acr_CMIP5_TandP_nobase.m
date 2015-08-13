%			acr_CMIP5_TandP_nobase.m
%
%  This script analyzes CMIP5 RCP8.5 output for a given location and 
%  makes a scatterplot showing which model is which.  This one doesn't 
%  need a baseline file, so everything is placed in deltaT, deltaP 
%  rather than raw values
%
%  This is similar to CMIP5_TandP
%
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
%       acr_CMIP5_TandP_nobase(shortname,sitename,stnlat,stnlon,mmstart,mmend);
%
%				author: Alex Ruane
%                                       alexander.c.ruane@nasa.gov
%				date:	07/02/13
%
%
function [deltT deltP] = acr_CMIP5_TandP_nobase(shortname,sitename,stnlat,stnlon,mmstart,mmend,thisrcp,thisfut);
%--------------------------------------------------
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin debug
%shortname = 'FRLA';
%sitename = 'Laqueuille';
%stnlat = 45.65;
%stnlon = 2.75;
%mmstart = 1;
%mmend = 12;
%thisrcp = 'rcp85';
%thisfut = 'mid';
%% end debug

darkgreen = hsv2rgb([0.3,1,0.5]);
brown = hsv2rgb([0.3,1,0.5]);
orange = [255 138 0]./255;
purple = hsv2rgb([0.8,0.6,0.8]);
pink = hsv2rgb([0.8,0.3,1]);
gray = [1 1 1]*0.7;
darkyellow = hsv2rgb([0.15,1,0.7]);
darkred = hsv2rgb([1,1,0.5]);

if (strcmp(thisrcp,'rcp85')),
  bigrcp = 'RCP8.5';
end;
if (strcmp(thisrcp,'rcp45')),
  bigrcp = 'RCP4.5';
end;

if (strcmp(thisfut,'near')),
  decrange = 1:3;
  bigfut = 'Near-Term';
end;
if (strcmp(thisfut,'mid')),
  decrange = 4:6;
  bigfut = 'Mid-Century';
end;
if (strcmp(thisfut,'end')),
  decrange = 7:9;
  bigfut = 'End-of-Century';
end;


gcmname = {'ACCESS1-0','bcc-csm1-1','BNU-ESM','CanESM2','CCSM4','CESM1-BGC','CSIRO-Mk3-6-0','GFDL-ESM2G','GFDL-ESM2M','HadGEM2-CC','HadGEM2-ES','inmcm4','IPSL-CM5A-LR','IPSL-CM5A-MR','MIROC5','MIROC-ESM','MPI-ESM-LR','MPI-ESM-MR','MRI-CGCM3','NorESM1-M'};
gcmlist = 'ABCDEFGHIJKLMNOPQRST';
mmname = 'JFMAMJJASONDJFMAMJJASOND';

%% set chronological months of interest
mmrange = mmstart:mmend;
if(mmend<mmstart)
  mmrange = [mmstart:12 1:mmend];
end;


if(stnlon<0)
    stnlon = stnlon+360;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% First calculate metrics
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mmtick = [0 31 28 31 30 31 30 31 31 30 31 30 31];
mmcum = cumsum(mmtick);

%% Since there is no baseline, create temperature change 
%% and precipitation percentage change metrics

for mm=1:12,
  basetavg(mm) = 0;
  basepr(mm) = 100;
end;

for thisgcm=1:length(gcmname),
  disp(thisgcm);
  load(['/Users/sonalimcdermid/Research/R/data/CMIP5/latlon/' gcmname{thisgcm} '_lat.mat']);
  load(['/Users/sonalimcdermid/Research/R/data/CMIP5/latlon/' gcmname{thisgcm} '_lon.mat']);
  thisi = dsearchn(([lon(1,:) lon(1,1)+360])',stnlon);
  % look for wrap-arond
  if(thisi==(length(lon(1,:))+1))
    thisi = 1;
  end;
  thisj = dsearchn(lat(:,1),stnlat);
  if ((thisi == 1)||(thisj == 1)||(thisi == size(lon,1))||(thisj == size(lon,2)))
    disp('WARNING -- END POINT SELECTED.  ARE LATITUDE/LONGITUDE SIGNS CORRECT?');
  end;
  cd /Users/sonalimcdermid/Research/R/data/CMIP5/climfiles/
  load(['meantasmax_' gcmname{thisgcm} '_historical.mat']);
  meantasmaxbase = meantasmax;
  load(['meantasmin_' gcmname{thisgcm} '_historical.mat']);
  meantasminbase = meantasmin;
  load(['meanpr_' gcmname{thisgcm} '_historical.mat']);
  meanprbase = meanpr;
  load(['meantasmax_' gcmname{thisgcm} '_' thisrcp '.mat']);
  meantasmaxfut = meantasmax;
  load(['meantasmin_' gcmname{thisgcm} '_' thisrcp '.mat']);
  meantasminfut = meantasmin;
  load(['meanpr_' gcmname{thisgcm} '_' thisrcp '.mat']);
  meanprfut = meanpr;

%% by month (does not weight precip appropriately)
  meantasmaxdelt = mean(squeeze(meantasmaxfut(thisj,thisi,:,decrange)) - squeeze(meantasmaxbase(thisj,thisi,:,1:3)),2);
  meantasmindelt = mean(squeeze(meantasminfut(thisj,thisi,:,decrange)) - squeeze(meantasminbase(thisj,thisi,:,1:3)),2);
  meanprdelt = mean(squeeze(meanprfut(thisj,thisi,:,decrange)),2)./mean(squeeze(meanprbase(thisj,thisi,:,1:3)),2);

  %% by growing season (mmstart:mmend)
    meantasmaxdeltfull(thisgcm) = mean(mean(squeeze(meantasmaxfut(thisj,thisi,mmstart:mmend,decrange)),2),1) - mean(mean(squeeze(meantasmaxbase(thisj,thisi,mmstart:mmend,1:3)),2),1);
  meantasmindeltfull(thisgcm) = mean(mean(squeeze(meantasminfut(thisj,thisi,mmstart:mmend,decrange)),2),1) - mean(mean(squeeze(meantasminbase(thisj,thisi,mmstart:mmend,1:3)),2),1);
  meanprdeltfull(thisgcm) = mean(mean(squeeze(meanprfut(thisj,thisi,mmstart:mmend,decrange)),2),1)./mean(mean(squeeze(meanprbase(thisj,thisi,mmstart:mmend,1:3)),2),1);

  %% Diagnostics:
  %baseprtest(thisgcm,:) = mean(squeeze(meanprbase(thisj,thisi,:,1:3)),2);
  %basetmaxtest(thisgcm,:) = mean(squeeze(meantasmaxbase(thisj,thisi,:,1:3)),2);

  for mm=1:12,
    newtavg(thisgcm,mm) = (meantasmaxdelt(mm)+meantasmindelt(mm))/2+basetavg(mm);
    newpr(thisgcm,mm) = min(meanprdelt(mm),3)*basepr(mm);
  end;
  clear meanprdelt meantasmaxdelt meantasmindelt
end;




%% Diagnostic figure
%figure(1002);
%plot(basetmaxtest');
%figure(1003);
%plot(baseprtest');

%%%%%%% Scatter plot of growing season

f=figure; hold on;
%plot(mean(basetavg(mmrange)),mean(basepr(mmrange)),'ks','Markerfacecolor','k','Markersize',12);
plot(0,100,'ks','Markerfacecolor','k','Markersize',12);
axis([mean(basetavg(mmrange))-1.5 mean(basetavg(mmrange))+6 mean(basepr(mmrange))*0.5 mean(basepr(mmrange))*2]);

for thisgcm=1:length(gcmlist),
  deltT(thisgcm) = (meantasmaxdeltfull(thisgcm) + meantasmindeltfull(thisgcm))/2;
  deltP(thisgcm) = meanprdeltfull(thisgcm)*mean(basepr(mmrange));
  t=text(deltT(thisgcm),deltP(thisgcm),gcmlist(thisgcm));
  xlabel([mmname(mmstart:(mmstart+length(mmrange)-1)) ' Temperature (^oC)'])
  ylabel([mmname(mmstart:(mmstart+length(mmrange)-1)) ' Precipitation (mm/day)']);
end;
title(['T and P from 20 ' bigfut ' ' bigrcp ' GCMs (' sitename ')']);



%% annual
basetavg(13) = mean(basetavg(1:12));
basepr(13) = mean(basepr(1:12));
%% JFM
basetavg(14) = mean(basetavg(1:3));
basepr(14) = mean(basepr(1:3));
%% AMJ
basetavg(15) = mean(basetavg(4:6));
basepr(15) = mean(basepr(4:6));
%% JAS
basetavg(16) = mean(basetavg(7:9));
basepr(16) = mean(basepr(7:9));
%% OND
basetavg(17) = mean(basetavg(10:12));
basepr(17) = mean(basepr(10:12));

for thisgcm=1:length(gcmlist),
  %% annual
  newtavg(thisgcm,13) = mean(newtavg(thisgcm,1:12));
  newpr(thisgcm,13) = mean(newpr(thisgcm,1:12));
  %% JFM
  newtavg(thisgcm,14) = mean(newtavg(thisgcm,1:3));
  newpr(thisgcm,14) = mean(newpr(thisgcm,1:3));
  %% AMJ
  newtavg(thisgcm,15) = mean(newtavg(thisgcm,4:6));
  newpr(thisgcm,15) = mean(newpr(thisgcm,4:6));
  %% JAS
  newtavg(thisgcm,16) = mean(newtavg(thisgcm,7:9));
  newpr(thisgcm,16) = mean(newpr(thisgcm,7:9));
  %% OND
  newtavg(thisgcm,17) = mean(newtavg(thisgcm,10:12));
  newpr(thisgcm,17) = mean(newpr(thisgcm,10:12));
end;


g=figure('units','inches','pos',[.3,.3,7.9,12],'paperpos', ...
   [.3,.3,7.9,12],'paperor','portrait');

  b=subplot(4,1,1);
  boxplot(newtavg);
  hold on;
  plot(1:12,basetavg(1:12),'k-*');
  plot(13:17,basetavg(13:17),'k*');
  title([bigrcp ' ' bigfut ' Temperature Scenarios for All GCMs (' sitename ')']); 
  axis([0.5 17.5 min(floor(min(min(newtavg))),floor(min(basetavg))) max(ceil(max(max(newtavg))),ceil(max(basetavg)))]);
  xlabel('');
  ylabel('^oC');
  hold on;
  plot([12.5 12.5],[-1000 1000],'k','linewidth',2.001);
  hold off;
  set(b,'TickLength',[-0.005 0]);
  set(b,'xTickLabel',{'J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D' 'ann' 'JFM' 'AMJ' 'JAS','DJF'});

  b=subplot(4,1,2);
  boxplot(newpr);
  hold on;
  plot(1:12,basepr(1:12),'k-*');
  plot(13:17,basepr(13:17),'k*');
  title([bigrcp ' ' bigfut ' Temperature Scenarios for All GCMs (' sitename ')']); 
  axis([0.5 17.5 min(floor(min(min(newpr))),floor(min(basepr))) max(ceil(max(max(newpr))),ceil(max(basepr)))]);
  xlabel('');
  ylabel('^oC');
  hold on;
  plot([12.5 12.5],[-1000 1000],'k','linewidth',2.001);
  hold off;
  set(b,'TickLength',[-0.005 0]);
  set(b,'xTickLabel',{'J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D' 'ann' 'JFM' 'AMJ' 'JAS','DJF'});

  %print(f,'-depsc',['/home/aruane/temp/AgMIP/Figures/CMIP5_TandP/' shortname '_CMIP5_TandP_' mmname(mmstart:(mmstart+length(mmrange)-1))]);
  %print(g,'-depsc',['/home/aruane/temp/AgMIP/Figures/CMIP5_TandP/' shortname '_CMIP5_TandPseasons']);
