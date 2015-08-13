####################################################################################################
#    	acr_findspot
#
#  This function returns the i and j coordinates of a given location given its latitude and
#    longitude and a models lat and lon arrays.
#
#  i does not necessarily represent longitudes
#  j does not necessarily represent latitudes
#  Both simply represent the 1st and 2nd dimensions, respectively
#
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
#
#    usage : y <- mysummary(x)
#    y$center is the median (4) 
#    y$spread is the median absolute deviation (1.4826)
#
#     Author: Alex Ruane
#   								alexander.c.ruane@nasa.gov
#    	Created:	12/07/2010
# 		Translated to R by Yunchul Jung: 08/12/2012
####################################################################################################

acr_findspot <- function(thislat,thislon,lat,lon){
  	
	##  Check for longitude convention
  ##  Convert negative East longitude to postive
	if ((min(min(lon))>thislon)&&(min(min(lon))>0)&&(thislon<0)){
	  thislon = thislon+360
	}
  
	##  Convert positive East longitude to negative
	if ((max(max(lon))<thislon)&&(max(max(lon))<0)&&(thislon>0)){
	  thislon = thislon-360
	}
  
	##  Set error values
	thisi   <- -99
	thisj   <- -99
  
  ##  Find differences
	latdiff <- (lat-thislat)^2
	londiff <- (lon-thislon)^2
	diffmap <- (latdiff+londiff)^0.5
  
  ##  Error checking for loop
	for (i in 1:nrow(lat)){
	  for (j in 1:ncol(lon)){
      if(diffmap[i,j] == min(diffmap)){
        thisi <- i
        thisj <- j
      }
	  }
	}

	##  Check for wrong sign by looking for end-point selections
	if ((thisi == 1)||(thisj == 1)||(thisi == nrow(lon))||(thisj == ncol(lon))){
	  print('WARNING -- END POINT SELECTED.  ARE LATITUDE/LONGITUDE SIGNS CORRECT?')
	}

	result <- list(thisi=thisi,thisj=thisj)
	return(result)
}