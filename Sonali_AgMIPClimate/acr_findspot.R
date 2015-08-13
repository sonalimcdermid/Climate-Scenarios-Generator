
acr_findspot <- function(thislat,thislon,lat,lon){

	#    usage:
	#    [thisi,thisj] = acr_findspot(thislat,thislon,lat,lon);
	#
	#    where:
	#    thislat   = variable to be mapped
	#    thislon   = array of latitudes to match each point
	#    lat       = array of longitudes to match each point
	#    lon       = colorbar limits
	#
	#    returns:
	#    thisi     = i index of location 
	#    thisj     = j index of location

	# usage : y <- mysummary(x)
	# y$center is the median (4) 
	# y$spread is the median absolute deviation (1.4826)
	
	# Check for longitude convention
	if ((min(min(lon))>thislon)&&(min(min(lon))>0)&&(thislon<0)){  ## convert negative East longitude to postive
	  thislon = thislon+360;
	}

	if ((max(max(lon))<thislon)&&(max(max(lon))<0)&&(thislon>0)){  ## convert positive East longitude to negative
	  thislon = thislon-360;
	}

	# set error values
	thisi = -99;
	thisj = -99;

	#for i=1:size(lat,1),
	#  for j=1:size(lon,2),
	#    diffmap(i,j) = ((lat(i,j)-thislat)^2 + (lon(i,j)-thislon)^2)^0.5;
	#  end;
	#end;
	latdiff = (lat-thislat)^2;
	londiff = (lon-thislon)^2;
	diffmap = (latdiff+londiff)^0.5;


	for (i in 1:nrow(lat)){
	  for (j in 1:ncol(lon)){
		if(diffmap[i,j] == min(diffmap)){
		  thisi = i;
		  thisj = j;
		}
	  }
	}

	## Check for wrong sign by looking for end-point selections
	if ((thisi == 1)||(thisj == 1)||(thisi == nrow(lon))||(thisj == ncol(lon))){
	  print('WARNING -- END POINT SELECTED.  ARE LATITUDE/LONGITUDE SIGNS CORRECT?'); 
	}

	result <- list(thisi=thisi,thisj=thisj)
	return(result); 
}