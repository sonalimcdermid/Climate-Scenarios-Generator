%			acr_agmip100_ASApaper
%
%       This script adjusts a climate time series for 
%       climate scenarios (based on acr_giss250.m and acr_giss513.m)
%       This is designed for AgMIP mean and variablity scenarios
%       using the "stretched distribution" approach that is related to
%       quantile mapping
%
%       This is for the ASA chapter
%
%       This version aims for correct statistical paramaters for 
%       distribution matching.  Fixed bug where random spread was related to 
%       absolute value of variable.  Should be related to delt instead.
%
%       Here's my minimal key for a scenario directory (e.g. FL051NXA)  '
%
%       Seventh Digit is RCM:
%       X = no RCM used
%       0 = imposed values (sensitivity tests)
%       1 = crcm
%       2 = ecpc
%       3 = hrm3
%       4 = mm5i
%       5 = RegCM3
%       6 = WRF
%       7 = RegCM4
%       A = GFDL/ecpc
%       B = GFDL/hrm3
%       C = GFDL/RegCM3
%       D = CGCM3/crcm
%       E = CGCM3/RegCM3
%       F = CGCM3/WRF
%       G = HADCM3/ecpc
%       H = HADCM3/hrm3
%       I = HADCM3/mm5i
%       J = CCSM/crcm
%       K = CCSM/mm5i
%       L = CCSM/WRF
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
%       H = Tmax and Tmin daily variability and mean change
%       I = P daily variability and mean change
%       J = CO2 only
%       K = P daily variability change only
%       L = Direct GCM
%       M = Direct RCM
%
%       Now for the variability scenario file naming convention:
%
%       First place is "V" for variability scenario
%
%       Second digit is mean Tmax change
%       0 = No change
%       1 = Model imposed
%       2 = -4 K
%       3 = -3 K
%       4 = -2 K
%       5 = -1 K
%       6 = +1 K
%       7 = +2 K
%       8 = +3 K
%       9 = +4 K
%
%       Third digit is mean Tmin change
%       0 = No change
%       1 = Model imposed
%       2 = -4 K
%       3 = -3 K
%       4 = -2 K
%       5 = -1 K
%       6 = +1 K
%       7 = +2 K
%       8 = +3 K
%       9 = +4 K
%
%       Fourth digit is mean Precip factor
%       0 = No change
%       1 = Model imposed
%       2 = 0.25
%       3 = 0.5
%       4 = 0.75
%       5 = 0.9
%       6 = 1.1
%       7 = 1.25
%       8 = 1.5
%       9 = 2
%
%       Fifth digit is Tmax standard deviation factor
%       0 = No change (1)
%       1 = Model imposed
%       2 = 0.5
%       3 = 0.75
%       4 = 0.9
%       5 = 0.95
%       6 = 1.05
%       7 = 1.10
%       8 = 1.25
%       9 = 1.5
%       A = 2.0
%       B = 3.0
%
%       Sixth digit is Tmin standard deviation factor
%       0 = No change (1)
%       1 = Model imposed
%       2 = 0.5
%       3 = 0.75
%       4 = 0.9
%       5 = 0.95
%       6 = 1.05
%       7 = 1.10
%       8 = 1.25
%       9 = 1.5
%       A = 2.0
%       B = 3.0
%
%       Seventh digit is Precip alpha parameter factor
%       0 = No change (1)
%       1 = Model imposed
%       2 = 0.5
%       3 = 0.75
%       4 = 0.9
%       5 = 0.95
%       6 = 1.05
%       7 = 1.10
%       8 = 1.25
%       9 = 1.5
%       A = 2.0
%       B = 3.0
%
%       Eighth digit is Precip wetfactor (number of wet days)
%       0 = No change (1)
%       1 = Model imposed
%       2 = 0.5
%       3 = 0.75
%       4 = 0.9
%       5 = 0.95
%       6 = 1.05
%       7 = 1.10
%       8 = 1.25
%       9 = 1.5
%       A = 2.0
%       B = 3.0
%
%
%       NOTE: stdfactor is the fraction of the baseline standard deviation 
%             that is imposed in the future (12-element vector representing 
%             each month with 12 columns to represent DSSAT files
%             maxT(3), minT(4)). 
%             If stdfactor is negative, then it is the negative 
%             of the new standard deviation to be imposed (rather than a 
%             factor).
%             If stdfactor(col) == 1, no corrections are made.  
%             gamfactor provides the alpha changes for precipitation 
%             as a 12-element vector
%             Beta is determined according to the mean change (alpha*beta=mean)
%             If gamfactor is negative, then it is the negative 
%             of the new alpha to be imposed (rather than a factor).
%             newdelt(mm,col) are the mean change deltas to be imposed
%                                   (fractional factor for precip)
%             wetfactor(mm) is the fraction of baseline wet days in the future  
%
%				author: Alex Ruane
%                       alexander.c.ruane@nasa.gov
%				date:	03/25/14
%
%function acr_agmip100;
function acr_agmip100(basefile,outfile,headerplus,stnlat,stnlon,stnelev,stdfactor,gamfactor,wetfactor,meandelt);
%--------------------------------------------------
%--------------------------------------------------
%        &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
%--------------------------------------------------
%--------------------------------------------------
%%begin debug
%
% basefile = '/home/aruane/temp/AgMIP/ASAchapter/data/BOCH0XXX.AgMIP';
% outfile = 'BOCHIAXF';
% headerplus = 'Test';
% stnlat = -19.633;
% stnlon = -65.367;
% stnelev = 3292;
% stdfactor(:,6) = ones(12,1)*1.5;
% stdfactor(:,7) = ones(12,1)*1.5;
% gamfactor = ones(12,1)*0.75;
% wetfactor = ones(12,1)*0.75;
% meandelt = ones(12,12);
% meandelt(:,6:7) = 0;
%%%end debug
%%%%%%=====================================================
%%%%%%=====================================================
%%%%%%=====================================================

base = acr_agmipload(basefile);

mmlist = {'jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec'};

ddate = mod(base(:,1),1000);

%% diagnostic shows just delta so far
mmtick = [0 31 28 31 30 31 30 31 31 30 31 30 31];
mmtickleap = [0 31 29 31 30 31 30 31 31 30 31 30 31];
mmcum = cumsum(mmtick);
mmcumleap = cumsum(mmtickleap);

%%% initialize month vectors;
jan = ones(0,1);
feb = ones(0,1);
mar = ones(0,1);
apr = ones(0,1);
may = ones(0,1);
jun = ones(0,1);
jul = ones(0,1);
aug = ones(0,1);
sep = ones(0,1);
oct = ones(0,1);
nov = ones(0,1);
dec = ones(0,1);

%% classify 30 years of daily record into monthly catgories
for dd=1:length(base);
  if(base(dd,3)==1),
     jan=[jan dd]; end;
  if(base(dd,3)==2),
     feb=[feb dd]; end;
  if(base(dd,3)==3),
     mar=[mar dd]; end;
  if(base(dd,3)==4),
     apr=[apr dd]; end;
  if(base(dd,3)==5),
     may=[may dd]; end;
  if(base(dd,3)==6),
     jun=[jun dd]; end;
  if(base(dd,3)==7),
     jul=[jul dd]; end;
  if(base(dd,3)==8),
     aug=[aug dd]; end;
  if(base(dd,3)==9),
     sep=[sep dd]; end;
  if(base(dd,3)==10),
     oct=[oct dd]; end;
  if(base(dd,3)==11),
     nov=[nov dd]; end;
  if(base(dd,3)==12),
     dec=[dec dd]; end;
end;

% set wide range for expected temperature coverage
tcov = -80:0.1:80;

%% standard deviation and mean increase = newscen
newscen = base;


%% do for max temperatures first 
col=6;

%% loop through months
for mm=1:12,
  monthfailed = 0;
  thismonth = eval(mmlist{mm});      %% vector of days in given month over all 30 years
  %% first increase standard deviation for temperature
  % calculate normal statistics for temperature and new mean for each month
  % produce new standard deviation with stdfactor
  basestd = std(base(thismonth,col));
  basemu = mean(base(thismonth,col));
  newmu(mm,col) = basemu+meandelt(mm,col);     
  newstd(mm,col) = basestd*stdfactor(mm,col);
  if (stdfactor(mm,col)<0)      %% directly imposed standard deviation
    newstd(mm,col) = -stdfactor(mm,col);
  end;
    
  %% rank baseline monthly series and find significant limits of baseline and new cdf
  ranklist = flipud(sort(base(thismonth,col)));

  basecdf = normcdf(tcov,basemu,basestd);
  newcdf = normcdf(tcov,newmu(mm,col),newstd(mm,col));
%%%% Old
%  basecdflims = [tcov(min(find(basecdf>1e-6))) tcov(max(find(basecdf<(1-1e-4))))];
%  newcdflims = [tcov(min(find(newcdf>1e-6))) tcov(max(find(newcdf<(1-1e-4))))];
%%%% New
  basecdflims = [tcov(max(find(basecdf<1e-10))+1) tcov(min(find(basecdf==1)))];
  newcdflims = [tcov(max(find(newcdf<1e-10))+1) tcov(min(find(newcdf==1)))];
  cdflims = [min([basecdflims(1) newcdflims(1)])-5 max([basecdflims(2) newcdflims(2)])+5];
  cdfvect = cdflims(1):0.1:cdflims(2);

  %% now regenerate only significant portion
  basecdf = normcdf(cdfvect,basemu,basestd);
  newcdf = normcdf(cdfvect,newmu(mm,col),newstd(mm,col));

  %% check for goodness of fit in baseline period as standard
  truebasecdf = 1/length(ranklist)*cumsum(hist(base(thismonth,col),cdfvect));

  %% check for initial goodness of fit in future period (newscen begins = base)
  truenewcdf = 1/length(ranklist)*cumsum(hist(newscen(thismonth,col),cdfvect));

  %% continue until future distribution, in comparison to theoretical future distribution, 
  %% looks like  baseline distribution.

  %% initially move directly with no spread (1:1)
  spread = 0;

%  newranklist = flipud(sort(newscen(thismonth,col)));

  meanerr = abs(mean(newscen(thismonth,col)) - newmu(mm,col));
  stderr = abs(std(newscen(thismonth,col))/newstd(mm,col) -1);

  %% good fit if mean is within 0.1K and standard deviation is within 0.2% of desired
  meanfitstandard(mm,col) = 0.1;
  stdfitstandard(mm,col) = 0.002;

  while(((meanerr>meanfitstandard(mm,col))||(stderr>stdfitstandard(mm,col)))&&(monthfailed==0))
    %disp(['meanerr = ' num2str(meanerr) '  stderr = '  num2str(100*stderr)]);
    %% find new value in ranked list
    ii=1;
    while (ii<length(ranklist)+1)  
      thisval = ranklist(ii);

      %% Find shift in value corresponding to this quantile in both cdfs
      baseprctile = basecdf(dsearchn(cdfvect',thisval));
      newvalue = cdfvect(dsearchn(newcdf',baseprctile));
      delt = newvalue-thisval;

      %% find all occurrances with same value    -- this could be more efficient
      while((ii<length(ranklist)+1)&&(ranklist(ii)==thisval))  
        ii=ii+1;
      end;

      thischunk = find(base(thismonth,col)==thisval);
 
      %% now adjust each of these members randomly to new location
      %% assign according to random sequence and from center out in the spread
      sequence = randperm(length(thischunk));
      for jj=1:length(thischunk)
        origloc = thismonth(thischunk(sequence(jj)));
        %% only change mean if stdfactor is 1
        if (stdfactor(mm,col)==1)
          newscen(origloc,col) = thisval+delt;
        else 
          newscen(origloc,col) = thisval+delt + spread*randn;
        end;
      end;
    end;

    %% check for initial goodness of fit in future period (newscen begins = base)
    truenewcdf = 1/length(ranklist)*cumsum(hist(newscen(thismonth,col),cdfvect));
    meanerr = abs(mean(newscen(thismonth,col)) - newmu(mm,col));
    stderr = abs(std(newscen(thismonth,col))/newstd(mm,col) -1);

    spread = spread + 0.1; %% increase spread for next round of cdf casting
    if(spread>1.5)   % revise standard for fit
      spread=0;
      if(meanerr>meanfitstandard(mm,col))
        meanfitstandard(mm,col) = meanfitstandard(mm,col)+0.05;
%        disp(['meanfitstandard for month ' num2str(mm) ' set to ' num2str(meanfitstandard(mm,col)) '  column=' num2str(col)]);
      end;
      if(stderr>stdfitstandard(mm,col))
        stdfitstandard(mm,col) = stdfitstandard(mm,col)+0.002;
%        disp(['stdfitstandard for month ' num2str(mm) ' set to ' num2str(100*stdfitstandard(mm,col)) '%  column=' num2str(col)]);
      end;

      if((meanfitstandard(mm,col)>0.3)||(stdfitstandard(mm,col)>0.1))
        disp(['POOR FIT FOR month ' num2str(mm) '  column=' num2str(col)]);
        disp(['Meanerr = ' num2str(meanerr) '  stderr = ' num2str(stderr)]);
        monthfailed = 1;
        newscen(thismonth,col) = -99;
      end;
      meanerr = 1234;   %% make sure you give a chance for tighter spread 
      stderr = 1234;   %% make sure you give a chance for tighter spread 
                               %% to be successful at new fit standard
    end;
  end;
end;


figure(1);
plot(cdfvect,truebasecdf,'b','Linewidth',2) 
hold on
plot(cdfvect,basecdf,'c','Linewidth',2) 
plot(cdfvect,truenewcdf,'r','Linewidth',2) 
plot(cdfvect,newcdf,'g','Linewidth',2) 
plot(cdfvect,truenewcdf,'r','Linewidth',2) 
plot(cdfvect,truebasecdf,'b','Linewidth',2) 
axis([7 33 -0.05 1.05]);
%legend('1980-2010 Baseline Observations','Baseline Theoretical Distribution',Imposed Theoretical Distribution','Final Scenario','4);
t=title('CDF of December Maximum Temperatures');
set(t,'Fontsize',16);
xlabel('^oC');
print(1,'-depsc','/Users/sonalimcdermid/Research/R/data/BOCH_TmaxStretchCDF');


%% do for min temperatures next 
col=7;

%% loop through months
for mm=1:12,
  monthfailed = 0;
  thismonth = eval(mmlist{mm});
    
  %% First impose diurnal temperature range according to new maxTs as intermediate scenario
  intermscen(thismonth,col) = newscen(thismonth,col-1) - (base(thismonth,col-1)-base(thismonth,col));
  newscen(thismonth,col) = intermscen(thismonth,col);

  %% first increase standard deviation for temperature
  % calculate normal statistics for temperature and new mean for each month
  % produce new standard deviation with stdfactor
  basestd = std(base(thismonth,col));
  basemu = mean(base(thismonth,col));
  intermstd = std(intermscen(thismonth,col));
  intermmu = mean(intermscen(thismonth,col));
  newmu(mm,col) = basemu+meandelt(mm,col);
  newstd(mm,col) = basestd*stdfactor(mm,col);
  if (stdfactor(mm,col)<0)      %% directly imposed standard deviation
    newstd(mm,col) = -stdfactor(mm,col);
  end;
    
  %% rank baseline monthly series and find significant limits of baseline and new cdf
  ranklist = flipud(sort(intermscen(thismonth,col)));

  basecdf = normcdf(tcov,basemu,basestd);
  intermcdf = normcdf(tcov,intermmu,intermstd);
  newcdf = normcdf(tcov,newmu(mm,col),newstd(mm,col));
%%%% Old
%  basecdflims = [tcov(min(find(basecdf>1e-6))) tcov(max(find(basecdf<(1-1e-4))))];
%  intermcdflims = [tcov(min(find(intermcdf>1e-6))) tcov(max(find(intermcdf<(1-1e-4))))];
%  newcdflims = [tcov(min(find(newcdf>1e-6))) tcov(max(find(newcdf<(1-1e-4))))];
%  cdflims = [min([basecdflims(1) newcdflims(1) intermcdflims(1)]) max([basecdflims(2) newcdflims(2) intermcdflims(2)])];
%%%% New
  basecdflims = [tcov(max(find(basecdf<1e-10))+1) tcov(min(find(basecdf==1)))];
  intermcdflims = [tcov(max(find(intermcdf<1e-10))+1) tcov(min(find(intermcdf==1)))];
  newcdflims = [tcov(max(find(newcdf<1e-10))+1) tcov(min(find(newcdf==1)))];
  cdflims = [min([basecdflims(1) newcdflims(1) intermcdflims(1)])-5 max([basecdflims(2) newcdflims(2) intermcdflims(2)])+5];
%
  cdfvect = cdflims(1):0.1:cdflims(2);

  %% now regenerate only significant portion
  basecdf = normcdf(cdfvect,basemu,basestd);
  intermcdf = normcdf(cdfvect,intermmu,intermstd);
  newcdf = normcdf(cdfvect,newmu(mm,col),newstd(mm,col));

  %% check for goodness of fit in baseline period as standard
  truebasecdf = 1/length(ranklist)*cumsum(hist(base(thismonth,col),cdfvect));

  %% check for initial goodness of fit in intermediate scenario
  trueintermcdf = 1/length(ranklist)*cumsum(hist(intermscen(thismonth,col),cdfvect));

  %% check for initial goodness of fit in future period (newscen begins = intermscen)
  truenewcdf = 1/length(ranklist)*cumsum(hist(newscen(thismonth,col),cdfvect));

%  %% diagnostic
%  figure(100); hold on;
%  plot(cdfvect,basecdf,'b')
%  plot(cdfvect,truebasecdf,'c')
%  plot(cdfvect,intermcdf,'g')
%  plot(cdfvect,newcdf,'r')
%  plot(cdfvect,trueintermcdf,'k')
%  plot(cdfvect,truenewcdf,'m')


  %% continue until future distribution, in comparison to theoretical future distribution, 
  %% looks like  baseline distribution (MSE does not increase by more than 5%).

  %% initially move directly with no spread (1:1)
  spread = 0;
  meanerr = abs(mean(newscen(thismonth,col)) - newmu(mm,col));
  stderr = abs(std(newscen(thismonth,col))/newstd(mm,col) -1);

  %% good fit if mean is within 0.1K and standard deviation is within 0.2% of desired
  meanfitstandard(mm,col) = 0.1;
  stdfitstandard(mm,col) = 0.002;
  while(((meanerr>meanfitstandard(mm,col))||(stderr>stdfitstandard(mm,col)))&&(monthfailed==0))
%    disp(['meanerr = ' num2str(meanerr) '  stderr = '  num2str(100*stderr)]);
    %% find new value in ranked list
    ii=1;
    while (ii<length(ranklist)+1)  
      thisval = ranklist(ii);

      %% Find shift in value corresponding to this percentile in both cdfs
      intermprctile = intermcdf(dsearchn(cdfvect',thisval));
      newvalue = cdfvect(dsearchn(newcdf',intermprctile));
      delt = newvalue-thisval;

      %% find all occurrances with same value    -- this could be more efficient
      while((ii<length(ranklist)+1)&&(ranklist(ii)==thisval))  
        ii=ii+1;
      end;

      thischunk = find(intermscen(thismonth,col)==thisval);
 
      %% now adjust each of these members randomly to new location
      %% assign according to random sequence and from center out in the spread
      sequence = randperm(length(thischunk));
      for jj=1:length(thischunk)
        origloc = thismonth(thischunk(sequence(jj)));
        %% only change mean if stdfactor is 1
        if (stdfactor(mm,col)==1)
          newscen(origloc,col) = thisval+delt;
        else 
          newscen(origloc,col) = thisval+delt + spread*randn;
        end;
      end;
    end;

    %% check for initial goodness of fit in future period (newscen begins = base)
    truenewcdf = 1/length(ranklist)*cumsum(hist(newscen(thismonth,col),cdfvect));
    meanerr = abs(mean(newscen(thismonth,col)) - newmu(mm,col));
    stderr = abs(std(newscen(thismonth,col))/newstd(mm,col) -1);

    spread = spread + 0.1; %% increase spread for next round of cdf casting
    if(spread>1.5)   % revise standard for fit (wider for mm/day rainfall)
      spread=0;
      if(meanerr>meanfitstandard(mm,col))
        meanfitstandard(mm,col) = meanfitstandard(mm,col)+0.05;
%        disp(['meanfitstandard for month ' num2str(mm) ' set to ' num2str(meanfitstandard(mm,col)) '  column=' num2str(col)]);
      end;
      if(stderr>stdfitstandard(mm,col))
        stdfitstandard(mm,col) = stdfitstandard(mm,col)+0.002;
%        disp(['stdfitstandard for month ' num2str(mm) ' set to ' num2str(100*stdfitstandard(mm,col)) '%  column=' num2str(col)]);
      end;

      if((meanfitstandard(mm,col)>0.3)||(stdfitstandard(mm,col)>0.1))
        disp(['POOR FIT FOR month ' num2str(mm) '  column=' num2str(col)]);
        monthfailed = 1;
        disp(['Meanerr = ' num2str(meanerr) '  stderr = ' num2str(stderr)]);
        newscen(thismonth,col) = -99;
      end;
      meanerr = 1234;   %% make sure you give a chance for tighter spread 
      stderr = 1234;   %% make sure you give a chance for tighter spread 
                               %% to be successful at new fit standard
    end;
  end;
end;



a=newscen(:,6)-newscen(:,7);    
b = find(a<0);
%disp(['Number of minT>maxT  =  ' num2str(length(b)) '    mean error = ' num2str(mean(a(b)))]);

if (length(b)>0)
  for ii=1:length(find(a<0))
    newscen(b(ii),6) = mean(newscen(b(ii),6:7))+0.1;
    newscen(b(ii),7) = newscen(b(ii),6)-0.2;
  end;
end;

    %% Tmax diagnostic
    figure(98); hold on;
    plot(newscen(1:366,6),'r')
    plot(base(1:366,6))
    axis([1 366 5 31]);
    t=title('1980 Maximum Temperature');
    xlabel('Julian Day');
    ylabel('^oC');
    print(98,'-depsc','/Users/sonalimcdermid/Research/R/data/BOCH_TmaxStretch');



%% reset base precip for debugging
%newscen(:,8) = base(:,8);

%% do for precipitation next 
col=8;

%% loop through months
for mm=1:12,
%  disp(['Month = ' num2str(mm)]);
  monthfailed = 0;
  thismonth = eval(mmlist{mm});

  %% first calculate baseline distribution of precipitation
  basemu = mean(base(thismonth,col));
  basewetdays = thismonth(base(thismonth,col)>0);
  nbasewetdays = length(basewetdays);
  basealpha = NaN;
  basebeta = NaN;

  %% Only works if there is at least one rainy day to work with   
  if (nbasewetdays>0)

    if (nbasewetdays>31)   %% need to have enough wet days over 31 years for gamma fit
      [gamma,ci] = gamfit(base(basewetdays,col));
      basealpha = gamma(1);
      basebeta = gamma(2);
    end;

    % calculate statistics for rainfall and new mean for each month
    newmu(mm,col) = basemu*meandelt(mm,col);

    if(~isnan(basealpha))
       newalpha = basealpha*gamfactor(mm);
       if (gamfactor(mm)<0)      %% directly imposed alpha
         newalpha = -gamfactor(mm);
       end;
    end;        

    %% check for all rain events dropping below 1 mm in GCM--ACR; 11/19/13
    if (wetfactor<0.2)
      wetfactor = 1;
    end;

    %% cannot have more wet days than days
    %% number of rainy days I want
    nnewwetdays = min([round(nbasewetdays*wetfactor(mm)) length(thismonth)]);
    %% number of rainy days I currently have in future scenario
    newwetdays = thismonth(newscen(thismonth,col)>0);
    
    if(~isnan(basealpha))
      %% set beta so that mean change is imposed (mean of wet days = alpha*beta)
      %% accounting for changing number of wet days
      newbeta = newmu(mm,col)*length(thismonth)/nnewwetdays/newalpha;
    end;
    
    %% Set new dry days according to smallest rainfall totals
    while(nnewwetdays<length(newwetdays))
      wetrank = sort(newscen(newwetdays,col));
      newdry = length(newwetdays)-nnewwetdays;
      drizdays = find(newscen(newwetdays,col)==wetrank(1));
      if(length(drizdays)<newdry)
        newscen(newwetdays(drizdays),col) = 0;
        newscen(newwetdays(drizdays),5) = newscen(newwetdays(drizdays),5) * 1.1;       %% increase radiation on new dry days by 10% following Mearns et al., 1996
      else
        sequence = randperm(length(drizdays));
        newscen(newwetdays(drizdays(sequence(1:newdry))),col) = 0;
        newscen(newwetdays(drizdays(sequence(1:newdry))),5) = newscen(newwetdays(drizdays(sequence(1:newdry))),5) * 1.1;       %% increase radiation on new dry days by 10% following Mearns et al., 1996
      end;
      newwetdays = thismonth(newscen(thismonth,col)>0);
    end;

    %% Set new wet days according to smallest solar radiation (cloudiness)
    if(nnewwetdays>length(newwetdays))
      cloudyrank = sort(newscen(thismonth,5));
      newwet = nnewwetdays-length(newwetdays);
      ncloudyrank=0;
      while(newwet>0)
        cloudydays = find(newscen(thismonth,5)==cloudyrank(ncloudyrank+1));
        ncloudyrank=ncloudyrank+length(cloudydays);
        newwetcandidates = find(newscen(thismonth(cloudydays),col)==0);
        if(length(newwetcandidates)<=newwet)
          newscen(thismonth(cloudydays(newwetcandidates)),col) = 0.3;
          newscen(thismonth(cloudydays(newwetcandidates)),5) = newscen(thismonth(cloudydays(newwetcandidates)),5) * 0.9;       %% reduce radiation on new rain days by 10% following Mearns et al., 1996
        elseif(length(newwetcandidates)>0)
          sequence = randperm(length(newwetcandidates));
          newscen(thismonth(cloudydays(newwetcandidates(sequence(1:newwet)))),col) = 0.3;
          newscen(thismonth(cloudydays(newwetcandidates(sequence(1:newwet)))),5) = newscen(thismonth(cloudydays(newwetcandidates(sequence(1:newwet)))),5) * 0.9;       %% reduce radiation on new rain days by 10% following Mearns et al., 1996
        end;
        newwetdays = thismonth(newscen(thismonth,col)>0);
        newwet = nnewwetdays-length(newwetdays);
      end;
    end;

    %% calculate theoretical distributions for use in shifting
    cdfvect=0:0.1:1000;
    startscen = newscen;
    truestartcdf = 1/nnewwetdays * cumsum(hist(startscen(newwetdays,col),cdfvect));
    truebasecdf = 1/nbasewetdays * cumsum(hist(base(basewetdays,col),cdfvect));
    truenewcdf = 1/nnewwetdays * cumsum(hist(newscen(newwetdays,col),cdfvect));
    startcdf = cdfvect*NaN; %% initialize as missing for months too dry for gamma distribution
    basecdf = cdfvect*NaN;  %% initialize as missing for months too dry for gamma distribution
    newcdf = cdfvect*NaN;   %% initialize as missing for months too dry for gamma distribution

    if(~isnan(basealpha))
      %% Re-calculate base cdf with new starting point now that the number of wet days has changed
      [gamstart,ci] = gamfit(startscen(newwetdays,col));
      startalpha = gamstart(1);
      startbeta = gamstart(2);
      startcdf = gamcdf(cdfvect,startalpha,startbeta);
      basecdf = gamcdf(cdfvect,basealpha,basebeta);
      newcdf = gamcdf(cdfvect,newalpha,newbeta);
 
      %% initially move directly with no spread (1:1)
      %% spread for rainfall is a percentage of the imposed value
      spread = 0;    

      %% sort rainy days by rainfall from starting scenario after wet day adjustment
      ranklist = flipud(sort(startscen(newwetdays,col)));
    end;

%% formatting issue here?

    %% make sure no days are rainier than 999 mm
    newscen(thismonth(newscen(thismonth,col)>999),col)=999;
  
    %% make sure future period monthly means are correct
    %% this is the only thing done when gamma distribution cannot be fit 
    %% because there aren't enough wet days
    meanerrfact = newmu(mm,col)/mean(newscen(thismonth,col));
%  disp(['target: ' num2str(newmu(mm,col)) ' start: ' num2str(mean(newscen(thismonth,col))) '  revised: ' num2str(mean(newscen(thismonth,col)*meanerrfact))]);
    newscen(thismonth,col) = newscen(thismonth,col)*meanerrfact;

    meanerr = abs(mean(newscen(thismonth,col)) - newmu(mm,col));
    alphaerr = 0;    %% no gamma error if distribution can't be fit
    betaerr = 0;     %% no gamma error if distribution can't be fit

    if(~isnan(basealpha))
      %% check for initial goodness of fit in future period
      [gg,ci] = gamfit(newscen(newwetdays,col));
      alphaerr = abs(gg(1)/newalpha -1);
      betaerr = abs(gg(2)/newbeta -1);
    end;
    %% good fit if mean is within 0.1 mm/day and gamma parameters are within 0.2% of desired
    meanfitstandard(mm,col) = 0.05;
    alphafitstandard(mm,col) = 0.002;
    betafitstandard(mm,col) = 0.002;

%    disp(['new mm = ' mmlist{mm} '; meanerr = ' num2str(meanerr) '  alphaerr = '  num2str(100*alphaerr) '  betaerr = '  num2str(100*betaerr)]);

    while(((meanerr>meanfitstandard(mm,col))||(alphaerr>alphafitstandard(mm,col))||(betaerr>betafitstandard(mm,col)))&&(monthfailed==0))

      %% find new value in ranked list
      ii=1;
      while (ii<(length(ranklist)+1))  
        thisval = ranklist(ii);

        %% Find shift in value corresponding to this percentile in both cdfs
        startprctile = startcdf(dsearchn(cdfvect',thisval));
        newvalue = cdfvect(dsearchn(newcdf',startprctile));
        delt = newvalue-thisval;
  
        %% find all occurrances with same value    -- this could be more efficient
        while((ii<length(ranklist)+1)&&(ranklist(ii)==thisval))  
          ii=ii+1;
        end;

        thischunk = find(startscen(thismonth,col)==thisval);

        %% now adjust each of these members randomly to new location
        %% assign according to random sequence and from center out in the spread
        sequence = randperm(length(thischunk));
        for jj=1:length(thischunk)
          origloc = thismonth(thischunk(sequence(jj)));
%%          old
%%          newscen(origloc,col) = thisval+delt + (thisval+delt)*spread*randn;
%%          fixed
          newscen(origloc,col) = thisval+delt + delt*spread*randn;
          if(newscen(origloc,col)<0.1)
            newscen(origloc,col) = 0.1;
          end;
        end;
      end;

      %% make sure future period monthly means are correct
      meanerrfact = newmu(mm,col)/mean(newscen(thismonth,col));
%      disp(['target: ' num2str(newmu(mm,col)) ' start: ' num2str(mean(newscen(thismonth,col))) '  revised: ' num2str(mean(newscen(thismonth,col)*meanerrfact))]);
      newscen(thismonth,col) = newscen(thismonth,col)*meanerrfact;

      %% check for initial goodness of fit in future period (newscen begins = startcdf ~= base)
      truenewcdf = 1/nnewwetdays * cumsum(hist(newscen(newwetdays,col),cdfvect));
      meanerr = abs(mean(newscen(thismonth,col)) - newmu(mm,col));
      alphaerr = 0;    %% no gamma error if distribution can't be fit
      betaerr = 0;     %% no gamma error if distribution can't be fit
 
      if(~isnan(basealpha))
        [gg,ci] = gamfit(newscen(newwetdays,col));
        alphaerr = abs(gg(1)/newalpha -1);
        betaerr = abs(gg(2)/newbeta -1);
      end;
%      disp(['mm = ' mmlist{mm} '; meanerr = ' num2str(meanerr) '  alphaerr = '  num2str(100*alphaerr) '  betaerr = '  num2str(100*betaerr)]);
      
      spread = spread + 0.05; %% increase spread for next round of cdf casting
%   spread check was 0.4
      if(spread>0.2) % revise standard for fit (if >20% shift/(random standard deviation))
        spread=0;
        if(meanerr>meanfitstandard(mm,col))  
          meanfitstandard(mm,col) = meanfitstandard(mm,col)+0.05;
%          disp(['meanfitstandard for month ' num2str(mm) ' set to ' num2str(meanfitstandard(mm,col)) '  column=' num2str(col)]);
        end;
        if(alphaerr>alphafitstandard(mm,col))
          alphafitstandard(mm,col) = alphafitstandard(mm,col)+0.005;
%          disp(['alphafitstandard for month ' num2str(mm) ' set to ' num2str(100*alphafitstandard(mm,col)) '%  column=' num2str(col)]);
        end;
        if(betaerr>betafitstandard(mm,col))
          betafitstandard(mm,col) = betafitstandard(mm,col)+0.005;
%          disp(['betafitstandard for month ' num2str(mm) ' set to ' num2str(100*betafitstandard(mm,col)) '%  column=' num2str(col)]);
        end;
                          
        if((meanfitstandard(mm,col)>0.3)||(alphafitstandard(mm,col)>0.075)||(betafitstandard(mm,col)>0.075))
          disp(['POOR FIT FOR month ' num2str(mm) '  column=' num2str(col)]);
          monthfailed = 1;
          disp(['Meanerr = ' num2str(meanerr) '  alphaerr = ' num2str(alphaerr) '  betaerr = ' num2str(betaerr)]);
          newscen(thismonth,col) = -99;
        end;
        %% to be successful at new fit standard
        meanerr = 1234;   %% make sure you give a chance for tighter spread 
        alphaerr = 1234;   %% make sure you give a chance for tighter spread 
        betaerr = 1234;   %% make sure you give a chance for tighter spread 
      end;       %% spread
    end;         %% while error is above standard
  end;       %% at least one wet day in baseline
end;     %% month

figure(1000); hold on
plot(cdfvect,truebasecdf,'b','Linewidth',2) 
plot(cdfvect,basecdf,'c','Linewidth',2) 
plot(cdfvect,newcdf,'g','Linewidth',2) 
plot(cdfvect,truenewcdf,'r','Linewidth',2) 
axis([-1 50 -0.05 1.05]);
l=legend('1980-2010 Baseline Observations','Baseline Theoretical Distribution','Imposed Theoretical Distribution','Final Scenario',4);
%set(l,'Fontsize',16)
t=title('CDF of December Precipitation Events');
set(t,'Fontsize',16);
xlabel('mm/day');
print(1000,'-depsc','/Users/sonalimcdermid/Research/R/data/BOCH_PStretchCDF');


    %%% Precip Diagnostic
    figure(99); hold on;
    plot(newscen(1:90,8),'r');
    plot(base(1:90,8),'b');
    t=title('1980 JFM Precipitation');
    ylabel('mm/day');
    xlabel('Julian Day');
    print(99,'-depsc','/Users/sonalimcdermid/Research/R/data/BOCH_PStretch');


%%% diagnostic
%plot(cdfvect,basecdf,'c')   
%hold on
%plot(cdfvect,truebasecdf,'b')                                                              
%%plot(cdfvect,intermcdf,'g')
%%plot(cdfvect,trueintermcdf,'k');                                                              
%%plot(cdfvect,startcdf,'g')
%%plot(cdfvect,truestartcdf,'k')
%plot(cdfvect,newcdf,'m')                                                       
%plot(cdfvect,truenewcdf,'r')                                                       
%%hold off

%% write it all out with proper station code

  %% full AgMIP format: 
  Tave = mean(mean(newscen(:,6:7)));
  for thismm=1:12,
    Tmonth(thismm) = mean(mean(newscen(find(newscen(:,3)==thismm),6:7)));
  end;
  Tamp = (max(Tmonth)-min(Tmonth))/2;

  %% treat missing values appropriately, even if they've been moved a little
  newscen(find(newscen(:,5)<0),5)=-99;
  newscen(find(newscen(:,6)<-70),6)=-99;
  newscen(find(newscen(:,7)<-70),7)=-99;
  newscen(find(newscen(:,8)<0),8)=-99;
  
  wthid = fopen([outfile '.AgMIP'],'wt');
  fprintf(wthid,'%s\n',['*WEATHER DATA : ' headerplus]);
  fprintf(wthid,'\n');
  fprintf(wthid,'%54s\n',['@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT']);
  %%% Don't forget to adjust reference height for temperature and winds
  fprintf(wthid,'%6s%9.3f%9.3f%6.0f%6.1f%6.1f%6.1f%6.1f\n',['  ' basefile(end-13:end-10)],stnlat, stnlon, stnelev,Tave,Tamp,2,2);
  fprintf(wthid,'%s\n',['@DATE    YYYY  MM  DD  SRAD  TMAX  TMIN  RAIN  WIND  DEWP  VPRS  RHUM']);

  for dd=1:length(ddate),
    fprintf(wthid,'%7s%6s%4s%4s%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.1f%6.0f\n',num2str(newscen(dd,1)),num2str(newscen(dd,2)),num2str(newscen(dd,3)),num2str(newscen(dd,4)),newscen(dd,5:12));
  end;

  fclose(wthid);
