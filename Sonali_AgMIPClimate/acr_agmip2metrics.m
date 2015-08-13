%			acr_agmip2metrics
%
%       This script produces a record of climate metrics in a given season
%       for a .AgMIP file
%
%       inputs:
%       infile (.AgMIP format)
%       jdstart
%       jdend
%       column (in .AgMIP file; 13 = Tave = average of columns 6-7)
%       analysistype ('mean','count','exceedance','max','min','std',
%                     'meanconsecutivedays','maxconsecutivedays')
%       reference (e.g., 0.1 mm, 30^oC; not always needed)
%       specialoperator (e.g., -1 for negative exceedance; not always needed)
%
%       Note that this follows the periodlength, so periods that wrap-around 
%       leap years will end on jdend-1; 
% 
%       returns:
%       metric (31-year record based upon planting year)
%              (first column year, second column value)
%              (NaN at end if wrap-around)
% 
%				author: Alex Ruane
%                                       alexander.c.ruane@nasa.gov
%				date:	02/16/12
%
%
function metric = acr_agmip2metrics(infile,jdstart,jdend,column,analysistype,reference,specialoperator);
%--------------------------------------------------
%--------------------------------------------------
%% debug begin
 %infile = '/Users/sonalimcdermid/Research/R/data/Climate/Historical/INCO0XXX.AgMIP';
%  jdstart = 305;
%  jdend = 31;
%  column = 6;
%  analysistype = 'mean';
%  reference = 1;
%  specialoperator = 1;
%% debug end

%% read in file
climdata = acr_agmipload(infile);

if (column==13)          %% calculate Tave if needed
  climdata(:,13) = mean(climdata(:,6:7),2);
end;

periodlength = jdend-jdstart+1;
if(periodlength<1)
  periodlength = periodlength+365;
end;

%% make metric file
metric = ones(31,2)*NaN;
metric(:,1) = 1980:2010;

%% calculations
for yyyy=1980:2009,
  firstday = find(climdata(:,1)==yyyy*1000+jdstart);
  lastday = firstday+periodlength-1;
  if (strcmp(analysistype,'mean')),
    metric(yyyy-1979,2) = mean(climdata(firstday:lastday,column));
  end;
  if (strcmp(analysistype,'max')),
    metric(yyyy-1979,2) = max(climdata(firstday:lastday,column));
  end;
  if (strcmp(analysistype,'sum')),
    metric(yyyy-1979,2) = sum(climdata(firstday:lastday,column));
  end;
  if (strcmp(analysistype,'min')),
    metric(yyyy-1979,2) = min(climdata(firstday:lastday,column));
  end;
  if (strcmp(analysistype,'std')),
    metric(yyyy-1979,2) = std(climdata(firstday:lastday,column));
  end;
  if (strcmp(analysistype,'count'))
    if (specialoperator == -1)
      metric(yyyy-1979,2) = length(find(climdata(firstday:lastday,column)<reference));
    else
      metric(yyyy-1979,2) = length(find(climdata(firstday:lastday,column)>reference));
    end;
  end;
  if (strcmp(analysistype,'exceedance'))
    climdataexceed = climdata(firstday:lastday,column)-reference;
    if (specialoperator == -1)
      climdataexceed(find(climdataexceed>0)) = 0;
    else
      climdataexceed(find(climdataexceed<0)) = 0;
    end;
    metric(yyyy-1979,2) = sum(climdataexceed);
  end;
  if (strcmp(analysistype,'meanconsecutivedays'))
    climdataexceed = climdata(firstday:lastday,column)-reference;
    if (specialoperator == -1)
      climdataexceed(find(climdataexceed>0)) = 0;
      climdataexceed(find(climdataexceed<0)) = 1;
    else
      climdataexceed(find(climdataexceed<0)) = 0;
      climdataexceed(find(climdataexceed>0)) = 1;
    end;
    streak(1) = climdataexceed(1);         %% initialize streaks
    for ii=2:length(climdataexceed),       %% start on second
      if(climdataexceed(ii)==1)
        streak(ii) = streak(ii-1) + climdataexceed(ii);    %% add to streak
        streak(ii-1) = 0;                  %% previous wasn't end of streak
      else
        streak(ii) = 0;
      end;
    end;
    metric(yyyy-1979,2) = mean(streak(find(streak>0)));
  end;
  if (strcmp(analysistype,'maxconsecutivedays'))
    climdataexceed = climdata(firstday:lastday,column)-reference;
    if (specialoperator == -1)
      climdataexceed(find(climdataexceed>0)) = 0;
      climdataexceed(find(climdataexceed<0)) = 1;
    else
      climdataexceed(find(climdataexceed<0)) = 0;
      climdataexceed(find(climdataexceed>0)) = 1;
    end;
    streak(1) = climdataexceed(1);         %% initialize streaks
    for ii=2:length(climdataexceed),       %% start on second
      if(climdataexceed(ii)==1)
        streak(ii) = streak(ii-1) + climdataexceed(ii);    %% add to streak
        streak(ii-1) = 0;                  %% previous wasn't end of streak
      else
        streak(ii) = 0;
      end;
    end;
    metric(yyyy-1979,2) = max(streak);
  end;
  clear streak
end;

%===========
%===========

if (jdstart<jdend)        %% we can do the 31st year because no wrap-around
  yyyy=2010;
  firstday = find(climdata(:,1)==yyyy*1000+jdstart);
  lastday = firstday+periodlength-1;
  if (strcmp(analysistype,'mean')),
    metric(yyyy-1979,2) = mean(climdata(firstday:lastday,column));
  end;
  if (strcmp(analysistype,'max')),
    metric(yyyy-1979,2) = max(climdata(firstday:lastday,column));
  end;
   if (strcmp(analysistype,'sum')),
    metric(yyyy-1979,2) = sum(climdata(firstday:lastday,column));
  end;
  if (strcmp(analysistype,'min')),
    metric(yyyy-1979,2) = min(climdata(firstday:lastday,column));
  end;
  if (strcmp(analysistype,'std')),
    metric(yyyy-1979,2) = std(climdata(firstday:lastday,column));
  end;
  if (strcmp(analysistype,'count'))
    if (specialoperator == -1)
      metric(yyyy-1979,2) = length(find(climdata(firstday:lastday,column)<reference));
    else
      metric(yyyy-1979,2) = length(find(climdata(firstday:lastday,column)>reference));
    end;
  end;
  if (strcmp(analysistype,'exceedance'))
    climdataexceed = climdata(firstday:lastday,column)-reference;
    if (specialoperator == -1)
      climdataexceed(find(climdataexceed>0)) = 0;
    else
      climdataexceed(find(climdataexceed<0)) = 0;
    end;
    metric(yyyy-1979,2) = sum(climdataexceed);
  end;
  if (strcmp(analysistype,'meanconsecutivedays'))
    climdataexceed = climdata(firstday:lastday,column)-reference;
    if (specialoperator == -1)
      climdataexceed(find(climdataexceed>0)) = 0;
      climdataexceed(find(climdataexceed<0)) = 1;
    else
      climdataexceed(find(climdataexceed<0)) = 0;
      climdataexceed(find(climdataexceed>0)) = 1;
    end;
    streak(1) = climdataexceed(1);         %% initialize streaks
    for ii=2:length(climdataexceed),       %% start on second
      if(climdataexceed(ii)==1)
        streak(ii) = streak(ii-1) + climdataexceed(ii);    %% add to streak
        streak(ii-1) = 0;                  %% previous wasn't end of streak
      else
        streak(ii) = 0;
      end;
    end;
    metric(yyyy-1979,2) = mean(streak(find(streak>0)));
  end;
  if (strcmp(analysistype,'maxconsecutivedays'))
    climdataexceed = climdata(firstday:lastday,column)-reference;
    if (specialoperator == -1)
      climdataexceed(find(climdataexceed>0)) = 0;
      climdataexceed(find(climdataexceed<0)) = 1;
    else
      climdataexceed(find(climdataexceed<0)) = 0;
      climdataexceed(find(climdataexceed>0)) = 1;
    end;
    streak(1) = climdataexceed(1);         %% initialize streaks
    for ii=2:length(climdataexceed),       %% start on second
      if(climdataexceed(ii)==1)
        streak(ii) = streak(ii-1) + climdataexceed(ii);    %% add to streak
        streak(ii-1) = 0;                  %% previous wasn't end of streak
      else
        streak(ii) = 0;
      end;
    end;
    metric(yyyy-1979,2) = max(streak);
  end;
end;
