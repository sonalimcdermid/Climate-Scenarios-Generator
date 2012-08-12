%			acr_findspot
%
%    This function returns the i and j coordinates of a given location
%    given its latitude and longitude and a models lat and lon arrays.
%
%    i does not necessarily represent longitudes
%    j does not necessarily represent latitudes
%    both simply represent the 1st and 2nd dimensions, respectively
%
%    usage:
%    [thisi,thisj] = acr_findspot(thislat,thislon,lat,lon);
%
%    where:
%    thislat   = variable to be mapped
%    thislon   = array of latitudes to match each point
%    lat       = array of longitudes to match each point
%    lon       = colorbar limits
%
%    returns:
%    thisi     = i index of location 
%    thisj     = j index of location
%
% 
%	                	author: Alex Ruane
%                                       aruane@giss.nasa.gov
%				date:	12/07/2010
%
function [thisi,thisj] = acr_findspot(thislat,thislon,lat,lon);

%% begin debug
%thislat = 31.8830;
%thislon = -85.4830;
%load /mscale2/aruane/datasets/models/NARCCAP/keyfiles/rcmlat.mat
%load /mscale2/aruane/datasets/models/NARCCAP/keyfiles/rcmlon.mat
%% end debug

% Check for longitude convention
if ((min(min(lon))>thislon)&&(min(min(lon))>0)&&(thislon<0))  %% convert negative East longitude to postive
  thislon = thislon+360;
end;

if ((max(max(lon))<thislon)&&(max(max(lon))<0)&&(thislon>0))  %% convert positive East longitude to negative
  thislon = thislon-360;
end;

% set error values
thisi = -99;
thisj = -99;

%for i=1:size(lat,1),
%  for j=1:size(lon,2),
%    diffmap(i,j) = ((lat(i,j)-thislat)^2 + (lon(i,j)-thislon)^2)^0.5;
%  end;
%end;
latdiff = (lat-thislat).^2;
londiff = (lon-thislon).^2;
diffmap = (latdiff+londiff).^0.5;


for i=1:size(lat,1),
  for j=1:size(lon,2),
    if(diffmap(i,j) == min(min(diffmap)))
      thisi = i;
      thisj = j;
    end;
  end;
end;

%% Check for wrong sign by looking for end-point selections
if ((thisi == 1)||(thisj == 1)||(thisi == size(lon,1))||(thisj == size(lon,2)))
  disp('WARNING -- END POINT SELECTED.  ARE LATITUDE/LONGITUDE SIGNS CORRECT?'); 
end;
