%			acr_agmip020_multistart_windows
%
%       This script produces climatic zones from WorldClim data.
%
%       For convenience, this uses the same general .AgMIP format
%
%       Attempting to use Lloyd's algorithm -- a problem here is the 
%       assumption that all variables are of equal unit weight.  I 
%       included a parameter to increase or decrease the weight of 
%       any variable in the distancing algorithm.  Note that this uses 
%       log(altitude) and log(precip) but regular (Tmean) in weighting 
%       because the distributions are cleaner.
%
%				author: Alex Ruane
%                                       alexander.c.ruane@nasa.gov
%				date:	01/06/12
%                       01/19/12   modified for areas bordering oceans
%                       09/07/12   pre-subset for Africa
%
%
function acr_agmip020_multistart_windows(rtitle,slat,nlat,wlon,elon,altweight,tweight,pweight,nzones,outloc);
%--------------------------------------------------
%--------------------------------------------------
%%%% start debug
slat = -2.99;
nlat = -1.35;
wlon = 36.878;
elon = 39.084;
nzones = 18;
altweight = 1;
tweight = 1;
pweight = 15;
rtitle = 'Machakos3';
outloc = 'C:\Users\aruane\Documents\_work\Matlab_Scripts\data\WorldClim\test\';
%%%% end debug

%% load and subset
cd C:\Users\aruane\Documents\_work\Matlab_Scripts\data\WorldClim
lat = importdata('Africa_sublat.mat');
lon = importdata('Africa_sublon.mat');
%%% recall that (1,1) = NE corner
lat1 = max(find(lat(:,1)>nlat));
lat2 = min(find(lat(:,1)<slat));
lon1 = max(find(lon(1,:)<wlon));
lon2 = min(find(lon(1,:)>elon));
sublon = lon(lat1:lat2,lon1:lon2);
sublat = lat(lat1:lat2,lon1:lon2);
clear lat lon
alt = importdata('Africa_subalt.mat');
subAlt = alt(lat1:lat2,lon1:lon2,1);
clear alt
prec = importdata('Africa_subprec.mat');
subPrec = prec(lat1:lat2,lon1:lon2,:);
clear prec
tmean = importdata('Africa_subtmean.mat');
subTmean = tmean(lat1:lat2,lon1:lon2,:);
clear tmean

save([outloc rtitle '_sublat.mat'],'sublat');
save([outloc rtitle '_sublon.mat'],'sublon');
save([outloc rtitle '_subAlt.mat'],'subAlt');
save([outloc rtitle '_subTmean.mat'],'subTmean');
save([outloc rtitle '_subPrec.mat'],'subPrec');

%load WestAfrica1_subTmean
%load WestAfrica1_subPrec
%load WestAfrica1_subAlt
%load WestAfrica1_sublat
%load WestAfrica1_sublon

%% set map details
map1 = worldhi([slat nlat],[wlon elon]);

ssA = size(subAlt);
land = subAlt(:)*0+1;
subAltreal = subAlt;
subAlt = subAlt+100;   %% prevent log(0) problems

for ii=1:ssA(1),
  for jj=1:ssA(2),
    overview(ii,jj,1) = subAlt(ii,jj);
    overview(ii,jj,2) = mean(subTmean(ii,jj,:));
    overview(ii,jj,3) = mean(subPrec(ii,jj,:));
  end;
end;

%% distributions are best for log(alt) and log(prec) due to 
%% heavily skewed distributions
%figure(100);
%a=overview(:,:,1);
%hist(a(:));
%figure(101);
%hist(log(a(:)));
%
%figure(200);
%a=overview(:,:,2);
%hist(a(:));
%figure(201);
%hist(log(a(:)));
%
%figure(300);
%a=overview(:,:,3);
%hist(a(:));
%figure(301);
%hist(log(a(:)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Lloyd's algorithm -- a heuristic approach to cluster analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% assign according to log(altitude) alone at first
%% this is an arbitrary start and doesn't have to be 
%% accurate other than the number of zones
altrange = max(log(subAlt(:))) - min(log(subAlt(:)));
altcats = [min(log(subAlt(:))):altrange/(nzones-1):max(log(subAlt(:)))];
for ii=1:ssA(1),
  for jj=1:ssA(2),
    overview(ii,jj,4) = NaN;
    if (~isnan(subAlt(ii,jj)))
      overview(ii,jj,4) = dsearchn(altcats',log(subAlt(ii,jj)));
%% random option produces a map which does not have an intelligent start
%% this tends to focus more on complex areas but increases apparent errors some
%    overview(ii,jj,4) = round(randi(nzones));       
    end;
  end;
end;

logalts = log(overview(:,:,1));
logalts = logalts(:);
Tmeans = overview(:,:,2);
Tmeans = Tmeans(:);
logPrecs = log(overview(:,:,3));
logPrecs = logPrecs(:);
zones = overview(:,:,4);
zones = zones(:);

for thiszone=1:nzones,
  zonemean(thiszone,1) = nanmean(logalts(find(zones==thiszone)));
  zonemean(thiszone,2) = nanmean(Tmeans(find(zones==thiszone)));
  zonemean(thiszone,3) = nanmean(logPrecs(find(zones==thiszone)));
end;

for spot=1:length(zones),
  zonebias(spot) = NaN;
  if(~isnan(logalts(spot)))
    thiszone = zones(spot);
    zonebias(spot) = (altweight*(logalts(spot)-zonemean(zones(spot),1))^2 + tweight*(Tmeans(spot)-zonemean(zones(spot),2))^2 + pweight*(logPrecs(spot)-zonemean(zones(spot),3))^2 )^0.5;
  end;
end;

oldzonebias = nanmean(zonebias);
de = 1e99;
niter = 1;

figure(10);
colormap('default');
cmap = colormap;
zonecmap = cmap(round(1:length(cmap)/nzones:length(cmap)),:);
colormap(zonecmap);
acr_pcolormapr2_nocoast(overview(:,:,4),sublat,sublon,[1-0.5 nzones+0.5]);
title(['#iter = ' num2str(niter) ';   dE = n/a']);
h=displaym(map1);
set(h,'facecolor','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% loop through until improvement is negligible
while((de>1e-6) && (niter<1000))
  niter = niter+1;

  for ii=1:ssA(1),
    for jj=1:ssA(2),
       if (~isnan(subAlt(ii,jj)))
         for thiszone=1:nzones,
           distance(thiszone) = (altweight*(log(overview(ii,jj,1))-zonemean(thiszone,1))^2 + tweight*(overview(ii,jj,2)-zonemean(thiszone,2))^2 + pweight*(log(overview(ii,jj,3))-zonemean(thiszone,3))^2 )^0.5;
         end;
         overview(ii,jj,4) = find(distance==min(distance));
      end;
    end;
  end;

  zones = overview(:,:,4);
  zones = zones(:);

  for thiszone=1:nzones,
    zonemean(thiszone,1) = nanmean(logalts(find(zones==thiszone)));
    zonemean(thiszone,2) = nanmean(Tmeans(find(zones==thiszone)));
    zonemean(thiszone,3) = nanmean(logPrecs(find(zones==thiszone)));
  end;

  for spot=1:length(zones),
    zonebias(spot) = NaN;
    if(~isnan(logalts(spot)))
      thiszone = zones(spot);
      zonebias(spot) = ((logalts(spot)-zonemean(zones(spot),1))^2 +(Tmeans(spot)-zonemean(zones(spot),2))^2 +(logPrecs(spot)-zonemean(zones(spot),3))^2 )^0.5;
    end;
  end;
  
  newzonebias = nanmean(zonebias);
  de = abs(oldzonebias - newzonebias);
  oldzonebias = newzonebias;
  
  acr_pcolormapr2_nocoast(overview(:,:,4),sublat,sublon,[1-0.5 nzones+0.5]);
  title(['#iter = ' num2str(niter) ';   dE = ' num2str(round(de*1e6)/1e6)]);
  h=displaym(map1);
  set(h,'facecolor','none');
  pause(0.2);

end;
disp('done');
if (niter>1000)
  disp('niter>1000 -- zones failed to converge');
end;

figure(1);
acr_pcolormapr2_nocoast(subAltreal,sublat,sublon,[0 3000]);
[cmap,clim] = demcmap(subAltreal*1.1,180);
colormap(cmap(2:end,:));
h=displaym(map1);
set(h,'facecolor','none');

figure(2);
acr_pcolormapr2_nocoast(overview(:,:,2),sublat,sublon,[10 30]);
h=displaym(map1);
set(h,'facecolor','none');

figure(3);
acr_pcolormapr2_nocoast(overview(:,:,3),sublat,sublon,[0 200]);
h=displaym(map1);
set(h,'facecolor','none');
%load /home/aruane/work/analysis/matlab_scripts/colormaps/cmapprecip.mat
%colormap(cmapprecip);

figure(20); colormap(zonecmap);
acr_pcolormapr2_nocoast(overview(:,:,4),sublat,sublon,[1-0.5 nzones+0.5]);
title(['Climate Zones for ' rtitle]);
h=displaym(map1);
set(h,'facecolor','none');

%% Calculate more extensive zonal averages (not used in climate zone definition)
alt_ = subAltreal(:);
Tann_ = mean(subTmean,3);
Tjan_ = subTmean(:,:,1);
Tfeb_ = subTmean(:,:,2);
Tmar_ = subTmean(:,:,3);
Tapr_ = subTmean(:,:,4);
Tmay_ = subTmean(:,:,5);
Tjun_ = subTmean(:,:,6);
Tjul_ = subTmean(:,:,7);
Taug_ = subTmean(:,:,8);
Tsep_ = subTmean(:,:,9);
Toct_ = subTmean(:,:,10);
Tnov_ = subTmean(:,:,11);
Tdec_ = subTmean(:,:,12);
Pann_ = mean(subPrec,3);
Pjan_ = subPrec(:,:,1);
Pfeb_ = subPrec(:,:,2);
Pmar_ = subPrec(:,:,3);
Papr_ = subPrec(:,:,4);
Pmay_ = subPrec(:,:,5);
Pjun_ = subPrec(:,:,6);
Pjul_ = subPrec(:,:,7);
Paug_ = subPrec(:,:,8);
Psep_ = subPrec(:,:,9);
Poct_ = subPrec(:,:,10);
Pnov_ = subPrec(:,:,11);
Pdec_ = subPrec(:,:,12);
for thiszone=1:nzones,
  zone_ = find(zones==thiszone);
  superzonemean(thiszone,1) = mean(alt_(zone_));
  superzonemean(thiszone,2) = mean(Tann_(zone_));
  superzonemean(thiszone,3) = mean(Tjan_(zone_));
  superzonemean(thiszone,4) = mean(Tfeb_(zone_));
  superzonemean(thiszone,5) = mean(Tmar_(zone_));
  superzonemean(thiszone,6) = mean(Tapr_(zone_));
  superzonemean(thiszone,7) = mean(Tmay_(zone_));
  superzonemean(thiszone,8) = mean(Tjun_(zone_));
  superzonemean(thiszone,9) = mean(Tjul_(zone_));
  superzonemean(thiszone,10) = mean(Taug_(zone_));
  superzonemean(thiszone,11) = mean(Tsep_(zone_));
  superzonemean(thiszone,12) = mean(Toct_(zone_));
  superzonemean(thiszone,13) = mean(Tnov_(zone_));
  superzonemean(thiszone,14) = mean(Tdec_(zone_));
  superzonemean(thiszone,15) = mean(Pann_(zone_));
  superzonemean(thiszone,16) = mean(Pjan_(zone_));
  superzonemean(thiszone,17) = mean(Pfeb_(zone_));
  superzonemean(thiszone,18) = mean(Pmar_(zone_));
  superzonemean(thiszone,19) = mean(Papr_(zone_));
  superzonemean(thiszone,20) = mean(Pmay_(zone_));
  superzonemean(thiszone,21) = mean(Pjun_(zone_));
  superzonemean(thiszone,22) = mean(Pjul_(zone_));
  superzonemean(thiszone,23) = mean(Paug_(zone_));
  superzonemean(thiszone,24) = mean(Psep_(zone_));
  superzonemean(thiszone,25) = mean(Poct_(zone_));
  superzonemean(thiszone,26) = mean(Pnov_(zone_));
  superzonemean(thiszone,27) = mean(Pdec_(zone_));
end;

%% store information about this zoning
info = [nzones altweight tweight pweight slat nlat wlon elon];
subAlt = subAltreal;

save([outloc rtitle '_sublat.mat'],'sublat');
save([outloc rtitle '_sublon.mat'],'sublon');
save([outloc rtitle '_subAlt.mat'],'subAlt');
save([outloc rtitle '_subTmean.mat'],'subTmean');
save([outloc rtitle '_subPrec.mat'],'subPrec');
save([outloc rtitle '_info.mat'],'info');
save([outloc rtitle '_superzonemean.mat'],'superzonemean');
save([outloc rtitle '_overview.mat'],'overview');
print(1,'-dpng',[outloc rtitle '_Alt_WorldClim_Ann']);
print(2,'-dpng',[outloc rtitle '_Tmean_WorldClim']);
print(3,'-dpng',[outloc rtitle '_Precip_WorldClim_Ann']);
print(20,'-dpng',[outloc rtitle '_ClimZones_WorldClim']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Print out ASCII files for analysis

%% Overview file with climate zones, latitudes, and longitudes
outfile = [outloc rtitle '_ClimZones.dat'];
fid = fopen(outfile,'wt');
fprintf(fid,'%s\n',[rtitle ' Climate Zones --  zones, latitudes, and longitudes']);
fprintf(fid,'%s\n\n',['nzones = ' num2str(nzones) '; nrows = ' num2str(ssA(1)) '; ncols = ' num2str(ssA(2))]);

fprintf(fid,'%s\n','Zones');
for mm=1:ssA(1),
  fprintf(fid,'%9.0f',overview(mm,:,4));
  fprintf(fid,'\n');
end;

fprintf(fid,'\n\n');
fprintf(fid,'%s\n','Latitudes');
for mm=1:ssA(1),
  fprintf(fid,'%9.4f',sublat(mm,1));
  fprintf(fid,'\n');
end;

fprintf(fid,'\n\n');
fprintf(fid,'%s\n','Longitudes');
fprintf(fid,'%9.4f',sublon(1,:));

fprintf(fid,'\n\n');
fprintf(fid,'%s\n','Climate Zone Means');
fprintf(fid,'%s\n',['Zone      Altitude     Tann     Tjan     Tfeb     Tmar     Tapr    Tmay      Tjun     Tjul     Taug     Tsep     Toct     Tnov     Tdec     Pann     Pjan     Pfeb     Pmar     Papr     Pmay     Pjun     Pjul     Paug     Psep     Poct     Pnov     Pdec']);
for thiszone=1:nzones,
  fprintf(fid,'%9.0f%9.0f',thiszone,superzonemean(thiszone,1));
  fprintf(fid,'%9.2f',superzonemean(thiszone,2:end));
  fprintf(fid,'\n');
end;

fclose(fid);
