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
%function acr_pickGCM(shortname,stnname,stnlat,stnlon,mmstart,mmend,thisrcp,thisfut,Tmin,Tmax,Pmin,Pmax);
%--------------------------------------------------
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin debug
%shortname = 'AUNR';      %% will eventually be used for saving figures
%stnname = 'GRAZPLAN-APSIM, Australia';
%stnlat = -23.688;
%stnlon = 150.869;
%mmstart = 1;
%mmend = 12;
%thisrcp = 'rcp85';
%thisfut = 'mid';
%Tmin = 0.5;
%Tmax = 3.5;
%Pmin = 70;
%Pmax = 130;
%% end debug

shortname = 'INCO';
stnname = 'Coimbatore, India';
stnlat = 11.000;
stnlon = 77.000;
mmstart = 6;
mmend = 9;
thisrcp = 'rcp85';
thisfut = 'mid';
Tmin = -0.5;
Tmax = 3.5;
Pmin = 60;
Pmax = 200;
%acr_pickGCM(shortname,stnname,stnlat,stnlon,mmstart,mmend,thisrcp,thisfut,Tmin,Tmax,Pmin,Pmax);


darkgreen = hsv2rgb([0.3,1,0.5]);
brown = hsv2rgb([0.3,1,0.5]);
orange = [255 138 0]./255;
purple = hsv2rgb([0.8,0.6,0.8]);
pink = hsv2rgb([0.8,0.3,1]);
gray = [1 1 1]*0.7;
darkyellow = hsv2rgb([0.15,1,0.7]);
darkred = hsv2rgb([1,1,0.5]);

mmrange = mmstart:mmend;
if(mmend<mmstart)
  mmrange = [mmstart:12 1:mmend];
end;
mmname = 'JFMAMJJASONDJFMAMJJASOND';

gcmlist = 'ABCDEFGHIJKLMNOPQRST';


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

deltT = ones(1,20)*NaN;
deltP = ones(1,20)*NaN;

[deltT deltP] = acr_CMIP5_TandP_nobase(shortname,stnname,stnlat,stnlon,mmstart,mmend,thisrcp,thisfut);

%%%%%%% Scatter plot of growing season
f=figure; hold on;
plot(0,100,'ks','Markerfacecolor','k','Markersize',12);

axis([Tmin Tmax Pmin Pmax]);

medT = median(deltT);
medP = median(deltP);

stdfact = 0.5;

top = medP+stdfact*std(deltP);
bottom = medP-stdfact*std(deltP);
right = medT+stdfact*std(deltT);
left = medT-stdfact*std(deltT);

%p=plot(medT,medP,'kp');
%set(p,'markerfacecolor','k');
plot([left right],[top top],'--','color',[0.7 0.7 0.7]);
plot([left right],[bottom bottom],'--','color',[0.7 0.7 0.7]);
plot([left left],[bottom top],'--','color',[0.7 0.7 0.7]);
plot([right right],[bottom top],'--','color',[0.7 0.7 0.7]);
plot([medT medT],[top Pmax],'--','color',[0.7 0.7 0.7]);
plot([medT medT],[Pmin bottom],'--','color',[0.7 0.7 0.7]);
plot([Tmin left],[medP medP],'--','color',[0.7 0.7 0.7]);
plot([right Tmax],[medP medP],'--','color',[0.7 0.7 0.7]);

middle = 0;
hotwet = 0;
hotdry = 0;
coolwet = 0;
cooldry = 0;
gcmcat = deltT*NaN;

for thisgcm=1:length(gcmlist),
  thisdeltT = deltT(thisgcm);
  thisdeltP = deltP(thisgcm);
  t=text(thisdeltT,thisdeltP,gcmlist(thisgcm));
  if((thisdeltT>left)&&(thisdeltT<right)&&(thisdeltP>bottom)&&(thisdeltP<top))
    set(t,'color','k');
    middle = middle+1;
    gcmcat(thisgcm) = 1;
  elseif((thisdeltT<medT)&&(thisdeltP>medP))
    set(t,'color','g');
    coolwet = coolwet+1;
    gcmcat(thisgcm) = 2;
  elseif((thisdeltT>medT)&&(thisdeltP>medP))
    set(t,'color',darkyellow);
    hotwet = hotwet+1;
    gcmcat(thisgcm) = 3;
  elseif((thisdeltT<medT)&&(thisdeltP<medP))
    set(t,'color','c');
    cooldry = cooldry+1;
    gcmcat(thisgcm) = 4;
  elseif((thisdeltT>medT)&&(thisdeltP<medP))
    set(t,'color','r');
    hotdry = hotdry+1;
    gcmcat(thisgcm) = 5;
  end;
  xlabel([mmname(mmstart:(mmstart+length(mmrange)-1)) ' Temperature Change (^oC)'])
  ylabel([mmname(mmstart:(mmstart+length(mmrange)-1)) ' Precipitation (% of Current)']);
end;

p=plot(mean(deltT(gcmcat==1)),mean(deltP(gcmcat==1)),'ko');
set(p,'markerfacecolor','k');
p=plot(mean(deltT(gcmcat==2)),mean(deltP(gcmcat==2)),'go');
set(p,'markerfacecolor','g');
p=plot(mean(deltT(gcmcat==3)),mean(deltP(gcmcat==3)),'o');
set(p,'color',darkyellow);
set(p,'markerfacecolor',darkyellow);
p=plot(mean(deltT(gcmcat==4)),mean(deltP(gcmcat==4)),'co');
set(p,'markerfacecolor','c');
p=plot(mean(deltT(gcmcat==5)),mean(deltP(gcmcat==5)),'ro');
set(p,'markerfacecolor','r');

title(['T and P from 20 Mid-Century RCP8.5 GCMs (' stnname ')']);

t=text(Tmin+0.7*(Tmax-Tmin),Pmin+0.9*(Pmax-Pmin),['cool/wet=' num2str(coolwet)]);
set(t,'color','g');
t=text(Tmin+0.85*(Tmax-Tmin),Pmin+0.9*(Pmax-Pmin),['hot/wet=' num2str(hotwet)]);
set(t,'color',darkyellow);
t=text(Tmin+0.77*(Tmax-Tmin),Pmin+0.85*(Pmax-Pmin),['middle=' num2str(middle)]);
set(t,'color','k');
t=text(Tmin+0.7*(Tmax-Tmin),Pmin+0.8*(Pmax-Pmin),['cool/dry=' num2str(cooldry)]);
set(t,'color','c');
t=text(Tmin+0.85*(Tmax-Tmin),Pmin+0.8*(Pmax-Pmin),['hot/dry=' num2str(hotdry)]);
set(t,'color','r');

print(f,'-depsc',['/Users/sonalimcdermid/Research/R/Figures/CMIP5_TandP/' shortname '_pickGCM']);
