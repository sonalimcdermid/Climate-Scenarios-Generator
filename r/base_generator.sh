#! /bin/bash

#set -x

#if [$# -ne 3]
#then
#  echo "Usage: `basename $0` {acmofile} {xvariable} {yvariable} {group1} {group2} {pngoutput}"
#  exit -1
#fi
seedfiledata=$1
seedfile=$2
shortregion=$3
headplus=$4
lat=$5
lon=$6
datashort=$7
output=$8

rootDir=$PWD
INSTALL_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
dataDir=$INSTALL_DIR

mkdir $rootDir/input
mkdir $rootDir/output

cd $rootDir/input
cp $seedfiledata $seedfile



seedname=${seedfile%.*}
#echo $seedfile 
#echo $rootDir 
#echo $dataDir 
#echo $seedname 
#echo $shortregion 
#echo $headplus 
#echo $lat 
#echo $lon 
#echo $datashort 
#echo $output

command -v R >/dev/null 2>&1 || { echo >&2 "'R' is required by this tool but was not found on past";exit 1;}

run_agmip_farmclimate=$INSTALL_DIR/run_agmip_farmclimate.R

xvfb-run R --no-save --vanilla --slave --args $rootDir $dataDir $seedname $shortregion "$headplus" "$lat" "$lon" $datashort < $run_agmip_farmclimate

cd ../output
zip base.zip *
cp base.zip $output
rm -rf ../input
rm -rf ../output
exit