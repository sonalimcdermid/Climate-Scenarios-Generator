%			acr_agmip110_windows
%
%       This script adjusts a climate time series with missing values (-99)
%       according to biases between the background dataset and the observed
%       periods.
%
%				author: Alex Ruane
%                       alexander.c.ruane@nasa.gov
%				date:	09/12/12
%
function acr_agmip110_windows(rawfile,backgroundfile,outfile,headerplus,stnlat,stnlon,stnelev);

%% debug begin
rawfile = 'C:\Users\aruane\Documents\_work\GISS\AgMIP\climateData\Countries\Kenya\KEKA0XXX.AgMIP';
backgroundfile = 'C:\Users\aruane\Documents\_work\Matlab_Scripts\data\bcMERRA\KEKA0QXX.AgMIP';
outfile = 'C:\Users\aruane\Documents\_work\GISS\AgMIP\climateData\Countries\Kenya\test\KEKA0XXX.AgMIP';
headerplus = 'Katumani, Kenya - Gap filling test';
stnlat = -1.580;
stnlon = 37.250;
stnelev = 1556;
%% debug end

%% load in files
raw = acr_agmipload(rawfile);
orig = raw;
back = acr_agmipload(backgroundfile);

%% destroy periods of baseline dataset for test
raw(1500:2000,5:12) = -99;
raw(1:365*3+182,5) = -99;
raw(end-365*3:end,5) = -99;
raw(2000:2000,10:11) = -99;
raw(2100:2100,12) = -99;
raw(3500:3503,5:12) = -99;
raw(4000:6040,8) = -99;
raw(6000:6040,8) = -99;
raw(7000:7025,5:12) = -99;
raw(8000:8100,5:12) = -99;
raw(9000:9017,5:12) = -99;
raw(10000:10000,9:12) = -99;
raw(11000:11000,5:8) = -99;

%% replace missing data with NaNs
raw(raw==-99) = NaN;
%% start with this file
newscen = raw;

%% Check out original data
plot(orig(:,5),'r');
hold on;
plot(raw(:,5),'k');

%% Find all good days in each month and each col for bias correction
for thiscol = 5:12,
  for mm=1:12,
    goodvect = ~isnan(raw(:,thiscol));
    goodraw = raw(goodvect,[thiscol 3]);
    goodback = back(goodvect,[thiscol 3]);
    meanraw(mm,thiscol) = mean(goodraw((goodraw(:,2)==mm),1));
    meanback(mm,thiscol) = mean(goodback((goodback(:,2)==mm),1));
  end;
end;

%% Test
raw_replacebc = raw;
raw_replace = raw;

%% Loop through all days
for dd=1:length(raw),
  %% Classify all gaps  
  if(length(find(isnan(raw(dd,:)))))
    miss(dd) = length(find(isnan(raw(dd,:))));
  end;
   if(miss(dd)==8),
    fullmiss(dd) = 1;
  end;

  %% replace missing with background at first
  %% srad
  for thiscol = [5 6 7 9 10 11 12];
    if(isnan(raw(dd,thiscol))),
      raw_replacebc(dd,thiscol) = back(dd,thiscol)+meanraw(raw(dd,3),thiscol)-meanback(raw(dd,3),thiscol);    
      raw_replace(dd,thiscol) = back(dd,thiscol);   %%test with no BC
    end;
  end;
  for thiscol = [8];
    if(isnan(raw(dd,thiscol))),
      raw_replacebc(dd,thiscol) = back(dd,thiscol) * meanraw(raw(dd,3),thiscol)/meanback(raw(dd,3),thiscol);    
      raw_replace(dd,thiscol) = back(dd,thiscol);   %%test with no BC
    end;
  end;  
end;

%% Diagnostics
thiscol=9;

figure(thiscol); hold on;
plot(orig(:,thiscol),'c');
plot(raw(:,thiscol));
plot(raw_replace(:,thiscol),'r');
plot(raw_replacebc(:,thiscol),'k');
