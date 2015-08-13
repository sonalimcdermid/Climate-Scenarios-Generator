###################################################################################################
#  		agmip_CMIP5_TandP_nobase.R
#
#  This script analyzes CMIP5 RCP8.5 output for a given location and 
#  makes a scatterplot showing which model is which.  This one doesn't 
#  need a baseline file, so everything is placed in deltaT, deltaP 
#  rather than raw values
#  This script creates delta scenarios from CMIP5 GCMs and BCSD in the AgMIP standard format.
#
#  This can ingest files in both .AgMIP and .wthm/.wtgm formatted baselines.
#  
#  THIS WAS FORMERLY acr_CMIP5_TandP_nobase.m -- May 24, 2013
#
#     Author: Alex Ruane
#     							alexander.c.ruane@nasa.gov
#    	Created:	07/02/13
# 		Translated to R by John Simmons: 11/15/2012
#
# This is similar to CMIP5_TandP

# This is similar to CMIP5_TandP
#       A = ACCESS1-0
#       B = bcc-csm1-1
#       C = BNU-ESM
#       D = CanESM2
#       E = CCSM4
#       F = CESM1-BGC
#       G = CSIRO-Mk3-6-0
#       H = GFDL-ESM2G
#       I = GFDL-ESM2M
#       J = HadGEM2-CC
#       K = HadGEM2-ES
#       L = inmcm4
#       M = IPSL-CM5A-LR
#       N = IPSL-CM5A-MR
#       O = MIROC5
#       P = MIROC-ESM
#       Q = MPI-ESM-LR
#       R = MPI-ESM-MR
#       S = MRI-CGCM3
#       T = NorESM1-M
#
#       acr_CMIP5_TandP_nobase(shortname,sitename,stnlat,stnlon,mmstart,mmend);
#
#  			author: Alex Ruane
#                                       alexander.c.ruane@nasa.gov
#				date:	07/02/13

agmip_CMIP5_TandP<- function(rootDir,figDir,Basefile,shortname,sitename,stnlat,stnlon,
                                    mmstart,mmend,thisrcp,thisfut,Tmin,Tmax,Pmin,Pmax){
 ## begin debug
 # shortname = 'FRLA';
 # sitename = 'Laqueuille';
 # stnname = 'Laqueuille';
 # stnlat = 45.65;
 # stnlon = 2.75;
 #mmstart = 4;
 # mmend = 6;
 # thisrcp = 'rcp85';
 # thisfut = 'mid'; 
 # Tmin = NA

  programDir  <- paste(rootDir, 'r/', sep='')
  dataDir     <- paste(rootDir, 'data/', sep='')
  baseloc  <- paste(dataDir, 'Climate/Historical/', sep='')
#rootDir<- '/cypress2/aruane/datasets/'
  programDir  <- paste(rootDir, 'r/', sep='')
  dataDir     <- paste(rootDir, 'data/', sep='')
  futloc      <- paste(dataDir, 'Climate/Simplescenario/', sep='')
  deltloc     <- paste(dataDir, 'Climate/CMIP5/climfiles/', sep='')
deltloc <- paste(rootDir,'data/CMIP5/climfiles/',sep='')
  latlonloc   <- paste(dataDir, 'CMIP5/latlon/', sep='') 
latlonloc<- paste(rootDir,'data/CMIP5/latlon/',sep='') 

if(identical(thisrcp, 'rcp85')){
    rcpname<-'RCP8.5';
}
if(identical(thisrcp,'rcp45')){
  rcpname <- 'RCP4.5';
}

if(identical(thisfut,'near')){
  decrange<- seq(1,3)
  bigrcp <- 'Near-Term';
}
if(identical(thisfut,'mid')){
  decrange<- seq(4,6)
  bigrcp <- 'Mid-Century';
}
if(identical(thisfut,'end')){
  decrange<- seq(7,9)
  bigrcp <- 'End-of-Century';
}
if(Basefile == 0) {
  BaseFile = 'No Base File'
  bigrcp <- 'Mid-Century';
}

gcmname<-c('ACCESS1-0','bcc-csm1-1','BNU-ESM','CanESM2','CCSM4','CESM1-BGC','CSIRO-Mk3-6-0','GFDL-ESM2G','GFDL-ESM2M','HadGEM2-CC','HadGEM2-ES','inmcm4','IPSL-CM5A-LR','IPSL-CM5A-MR','MIROC5','MIROC-ESM','MPI-ESM-LR','MPI-ESM-MR','MRI-CGCM3','NorESM1-M')
gcmlist <- 'ABCDEFGHIJKLMNOPQRST';
mmname <- 'JFMAMJJASONDJFMAMJJASOND';
gcmnum<- strsplit(gcmlist,'')
mmname <- 'JFMAMJJASOND'
mmname_str<- paste(strsplit(mmname,'')[[1]][seq(mmstart,mmend)],collapse='')
mmtick <- c(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
mmcum = cumsum(mmtick);
mmrange = seq(mmstart,mmend)

if(mmend<mmstart){
  mmrange <- cat(seq(mmstart:12),seq(1:mmend))
}

if(stnlon<0){
  stnlon <- stnlon+360
}

basetavg = rep(1,12)*0
basepr = rep(1,12)*0

for (mm in seq(1,12)){
  basetavg[mm] <- 0
  basepr[mm] <-100
}

meantasmaxdeltfull = matrix(data = NA, nrow = length(gcmname), ncol = 1)
meantasmindeltfull = matrix(data = NA, nrow = length(gcmname), ncol = 1)
meanprdeltfull = matrix(data = NA, nrow = length(gcmname), ncol = 1)
meanprdeltfull = matrix(data = NA, nrow = length(gcmname), ncol = 1)
meanprdelt_adjusted = matrix(data = NA, nrow = length(gcmname), ncol = 1)

#this is where it should start
if(Basefile ==0){
  for (thisgcm in seq(1,length(gcmname))){
  	cat('\nGCM #',thisgcm,sep = '')
  	
  	filename<- file.path(paste(latlonloc,gcmname[thisgcm],'_lat.mat',sep=''))
  	lat<- readMat(filename)$lat
  	
  	filename<- file.path(paste(latlonloc,gcmname[thisgcm],'_lon.mat',sep=''))
  	lon<- readMat(filename)$lon

  	findspot  <- acr_findspot(stnlat,stnlon,lat,lon)
  	thisi     <- findspot$thisj 
  	thisj     <- findspot$thisi

 	## Historical data
  	filepath  <- file.path(paste(deltloc, "meantasmax_", gcmname[thisgcm], "_historical.mat", sep=''))
  	meantasmaxbase  <- readMat(filepath)$meantasmax	
   	filepath  <- file.path(paste(deltloc, "meantasmin_", gcmname[thisgcm], "_historical.mat", sep=''))
  	meantasminbase  <- readMat(filepath)$meantasmin
  	filepath    <- file.path(paste(deltloc, "meanpr_", gcmname[thisgcm], "_historical.mat", sep=''))
  	meanprbase  <- readMat(filepath)$meanpr
  
	 ## RCP data
 	  filepath  <- file.path(paste(deltloc, "meantasmax_", gcmname[thisgcm], "_", thisrcp, ".mat", sep=''))
 	  meantasmaxfut   <- readMat(filepath)$meantasmax
 	  filepath  <- file.path(paste(deltloc, "meantasmin_", gcmname[thisgcm], "_", thisrcp, ".mat", sep=''))
 	  meantasminfut   <- readMat(filepath)$meantasmin
 	  filepath  <- file.path(paste(deltloc, "meanpr_", gcmname[thisgcm], "_", thisrcp, ".mat", sep=''))
 	  meanprfut <- readMat(filepath)$meanpr

 	  meantasmaxdelt  <- rowMeans( meantasmaxfut[thisj,thisi,,decrange] - meantasmaxbase[thisj,thisi,,seq(1,3)])
	  meantasmindelt  <- rowMeans( meantasminfut[thisj,thisi,,decrange] - meantasminbase[thisj,thisi,,seq(1,3)])
	  meanprdelt      <- rowMeans( meanprfut[thisj,thisi,,decrange] ) / rowMeans(meanprbase[thisj,thisi,,seq(1,3)] )
  
  	meantasmaxdeltfull[thisgcm]<- mean( rowMeans( meantasmaxfut[thisj,thisi,seq(mmstart,mmend),decrange]))-mean( rowMeans( meantasmaxbase[thisj,thisi,seq(mmstart,mmend),seq(1,3)]))
  	meantasmindeltfull[thisgcm]<- mean( rowMeans( meantasminfut[thisj,thisi,seq(mmstart,mmend),decrange]))-mean( rowMeans( meantasminbase[thisj,thisi,seq(mmstart,mmend),seq(1,3)]))
	  meanprdeltfull[thisgcm]<- mean( rowMeans( meanprfut[thisj,thisi,seq(mmstart,mmend),decrange]))/mean( rowMeans( meanprbase[thisj,thisi,seq(mmstart,mmend),seq(1,3)]))

  	remove(meanprdelt)
  	remove(meantasmaxdelt)
  	remove(meantasmindelt)

  }

  deltT<- matrix(data = NA, nrow= length(gcmlist),1)
  deltP<- matrix(data = NA, nrow= length(gcmlist),1)

  for (thisgcm in seq(1,length(gcmname))){
	
  	deltT[thisgcm]<- (meantasmaxdeltfull[thisgcm] + meantasmindeltfull[thisgcm])/2
  	deltP[thisgcm]<- meanprdeltfull[thisgcm]*mean(basepr[mmrange])
  }
}

if(Basefile ==1){
  for (thisgcm in seq(1,length(gcmname))){
    cat('\nGCM #',thisgcm,sep = '')
  
    filename<- file.path(paste(latlonloc,gcmname[thisgcm],'_lat.mat',sep=''))
    lat<- readMat(filename)$lat
  
    filename<- file.path(paste(latlonloc,gcmname[thisgcm],'_lon.mat',sep=''))
    lon<- readMat(filename)$lon
  
    findspot  <- acr_findspot(stnlat,stnlon,lat,lon)
    thisi     <- findspot$thisj 
    thisj     <- findspot$thisi
  
    ## Historical data
    filepath  <- file.path(paste(deltloc, "meantasmax_", gcmname[thisgcm], "_historical.mat", sep=''))
    meantasmaxbase  <- readMat(filepath)$meantasmax	
    filepath  <- file.path(paste(deltloc, "meantasmin_", gcmname[thisgcm], "_historical.mat", sep=''))
    meantasminbase  <- readMat(filepath)$meantasmin
    filepath    <- file.path(paste(deltloc, "meanpr_", gcmname[thisgcm], "_historical.mat", sep=''))
    meanprbase  <- readMat(filepath)$meanpr
  
    ## RCP data
    filepath  <- file.path(paste(deltloc, "meantasmax_", gcmname[thisgcm], "_", thisrcp, ".mat", sep=''))
    meantasmaxfut   <- readMat(filepath)$meantasmax
    filepath  <- file.path(paste(deltloc, "meantasmin_", gcmname[thisgcm], "_", thisrcp, ".mat", sep=''))
    meantasminfut   <- readMat(filepath)$meantasmin
    filepath  <- file.path(paste(deltloc, "meanpr_", gcmname[thisgcm], "_", thisrcp, ".mat", sep=''))
    meanprfut <- readMat(filepath)$meanpr
  
    meantasmaxdelt  <- rowMeans( meantasmaxfut[thisj,thisi,,decrange] - meantasmaxbase[thisj,thisi,,seq(1,3)])
    meantasmindelt  <- rowMeans( meantasminfut[thisj,thisi,,decrange] - meantasminbase[thisj,thisi,,seq(1,3)])
    meanprdelt      <- rowMeans( meanprfut[thisj,thisi,,decrange] ) / rowMeans(meanprbase[thisj,thisi,,seq(1,3)] )
    
    meantasmaxdeltfull[thisgcm]<- mean( rowMeans( meantasmaxfut[thisj,thisi,seq(mmstart,mmend),decrange]))-mean( rowMeans( meantasmaxbase[thisj,thisi,seq(mmstart,mmend),seq(1,3)]))
    meantasmindeltfull[thisgcm]<- mean( rowMeans( meantasminfut[thisj,thisi,seq(mmstart,mmend),decrange]))-mean( rowMeans( meantasminbase[thisj,thisi,seq(mmstart,mmend),seq(1,3)]))
    meanprdeltfull[thisgcm]<- mean( rowMeans( meanprfut[thisj,thisi,seq(mmstart,mmend),decrange]))/mean( rowMeans( meanprbase[thisj,thisi,seq(mmstart,mmend),seq(1,3)]))
    
    base <- read.table(Basefile,skip = 5, sep = "")
    newscen<- cbind(base[,dayloc],base[,solar],base[,maxT],base[,minT],base[,prate])
    average_precip <- mean(newscen[,5])
    month1 = matrix(NA, length(ddate),1)
    ddate<- base[,dayloc]
  
    for (dd in 1:length(ddate)){
      jd <- (ddate[dd] %% 1000)
      yy <- floor(ddate[dd]/1000)
      thismm <- max(which(jd>mmcum))
      
      if ((yy%%4)){
      }
      else{
        thismm = max(which(jd>mmcumleap))
        }
      newscen[dd,5] = min(base[dd,prate]*meanprdelt[thismm],999.9)
      month1[dd] = thismm
    }
  
    P_monthly_newscen = matrix(NA,12)
    P_monthly_base = matrix(NA, 12)
    for (thismm in 1:12){
      P_monthly_newscen[thismm] = mean(newscen[which(month1 ==thismm),5])
      P_monthly_base[thismm] = mean(base[which(month1 ==thismm),prate])
    }
    
    meanprdelt_adjusted[thisgcm] =  mean(P_monthly_newscen[seq(mmstart,mmend)])/mean(P_monthly_base[seq(mmstart,mmend)])*100
  
    remove(meanprdelt)
    remove(meantasmaxdelt)
    remove(meantasmindelt)
  }

  deltT<- matrix(data = NA, nrow= length(gcmlist),1)
  deltP<- matrix(data = NA, nrow= length(gcmlist),1)

  for (thisgcm in seq(1,length(gcmname))){
    deltT[thisgcm]<- (meantasmaxdeltfull[thisgcm] + meantasmindeltfull[thisgcm])/2
  }
  
  deltP = meanprdelt_adjusted
}

medT<-  median(deltT)
medP<- median(deltP)
stdfact<- 0.5
top <- medP+stdfact*sd(deltP)
bottom = medP-stdfact*sd(deltP)
right = medT+stdfact*sd(deltT)
left = medT-stdfact*sd(deltT)

##initialize counts for categories
middle = 0;
hotwet = 0;
hotdry = 0;
coolwet = 0;
cooldry = 0;
colors = deltT*NaN;

##initialize colors for categories 
CW = 3
CD = 4
HW = 'darkgoldenrod2'
HD = 2
MI = 1

##categorize outputs
for (thisgcm in seq(1,length(gcmnum[[1]]))){
    thisdeltT<- deltT[thisgcm]
    thisdeltP<- deltP[thisgcm]

    if((thisdeltT>left)&&(thisdeltT<right)&&(thisdeltP>bottom)&&(thisdeltP<top)){
   	middle = middle+1
    	colors[thisgcm] = MI
   	}
    else if((thisdeltT<medT)&&(thisdeltP>medP)){
    	coolwet = coolwet+1
   	colors[thisgcm] = CW
    	}
    else if((thisdeltT>medT)&&(thisdeltP>medP)){
    	hotwet = hotwet+1
    	colors[thisgcm]=HW
    	}
    else if((thisdeltT<medT)&&(thisdeltP<medP)){
    	cooldry = cooldry+1
    	colors[thisgcm] = CD
   	 }
    else if((thisdeltT>medT)&&(thisdeltP<medP)){
    	hotdry = hotdry+1
    	colors[thisgcm] = HD
   	 }
    }

if (is.na(Tmin)){
  Tmin = min(deltT)-0.2
	Tmax = max(deltT)+0.2
	Pmin = min(deltP)-10
	Pmax = max(deltP)+10
}

##plotting 
jpeg(filename = paste(figDir,shortname,'_',thisrcp,'_',thisfut,'_nobase','.jpg', sep = ''))
plot(append(left,right), append(top, top),type='l',
lwd =2, lty = 4, col = 'black',
xlim = c(Tmin, Tmax), ylim=  c(Pmin,Pmax),
 xlab= substitute(paste(mmname,' ',Temperature,' ',Change,', ',B* degree,'C',' '),
list(mmname=mmname_str,B = '')),
ylab= substitute(paste(mmname,' ',Precipitation,' ','%',' ',Change,' ','From',' ',Baseline),list(mmname=mmname_str)),
main= substitute(paste('T and P from',' ',Howmany,' ', When,' ', RCP,' ', 'GCMs ',(Place)),list(Howmany=length(gcmnum[[1]]),When = bigrcp,RCP =rcpname,Place  =stnname )))
lines(append(left,right), append(bottom, bottom),
lwd =2, lty = 4, col = 'black')
lines(append(left,left), append(bottom, top),
lwd =2, lty = 4, col = 'black')
lines(append(right,right), append(bottom, top),
lwd =2, lty = 4, col = 'black')
lines(append(medT, medT), append(top, Pmax),
lwd =2, lty = 4, col = 'black')
lines(append(medT,medT),append(Pmin,bottom),
lwd =2, lty = 4, col = 'black')
lines(append(Tmin,left),append(medP,medP),
lwd =2, lty = 4, col = 'black')
lines(append(right, Tmax), append(medP,medP),
lwd =2, lty = 4, col = 'black')
text(deltT,deltP,gcmnum[[1]],col = colors,cex = 1)
text(Tmin+0.65*(Tmax-Tmin),Pmin+0.9*(Pmax-Pmin),paste('cool/wet=',coolwet),col
= CW)
text(Tmin+0.85*(Tmax-Tmin),Pmin+0.9*(Pmax-Pmin),paste('hot/wet=',hotwet),col = HW)
text(Tmin+0.77*(Tmax-Tmin),Pmin+0.85*(Pmax-Pmin),paste('middle=',middle),col=MI)
text(Tmin+0.65*(Tmax-Tmin),Pmin+0.8*(Pmax-Pmin),paste('cool/dry=',cooldry),col=CD)
text(Tmin+0.85*(Tmax-Tmin),Pmin+0.8*(Pmax-Pmin),paste('hot/dry=',hotdry),col=HD)
points(mean(deltT[colors==HW]),mean(deltP[colors==HW]), col = HW,
pch = 19)
points(mean(deltT[colors==MI]),mean(deltP[colors==MI]), col = MI,
pch = 19)
points(mean(deltT[colors==CW]),mean(deltP[colors==CW]), col = CW,
pch = 19)
points(mean(deltT[colors==CD]),mean(deltP[colors==CD]), col = CD,
pch = 19)
points(mean(deltT[colors==HD]),mean(deltP[colors==HD]), col = HD,
pch = 19)
points(0,100,col = 'black',pch = 18, cex = 1.75)
dev.off()
return()

}

