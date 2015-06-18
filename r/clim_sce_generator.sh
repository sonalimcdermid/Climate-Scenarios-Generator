#! /bin/bash

#set -x

#if [$# -ne 3]
#then
#  echo "Usage: `basename $0` {acmofile} {xvariable} {yvariable} {group1} {group2} {pngoutput}"
#  exit -1
#fi
baseclimate=$1
futuresce=$2
emission=$3
period=$4
method=$5
output=$6


currentDir=$PWD
INSTALL_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir $PWD/input
mkdir $PWD/output1
mkdir $PWD/output2

cd input
cp $baseclimate 1.zip
unzip 1.zip   


command -v R >/dev/null 2>&1 || { echo >&2 "'R' is required by this tool but was not found on past";exit 1;}


dataDir=$INSTALL_DIR/data
run_agmip_simple_delta=$INSTALL_DIR/run_agmip_simple_delta.R
run_agmip_simple_mandv=$INSTALL_DIR/run_agmip_simple_mandv.R
run_agmip_simple2full=$INSTALL_DIR/run_agmip_simple2full.R

#cp $baseclimate $PWD/input/1.zip
#cd $INSTALL_DIR/input
#unzip 1.zip 

#cp $futurescefile $INSTALL_DIR/input/2.zip
#unzip 2.zip


for f in *.AgMIP
do
basefilename=${f%.*}
if [ $method -eq "1" ]
then
code="A"
xvfb-run R --no-save --vanilla --slave --args $currentDir $dataDir $basefilename $futuresce $emission $period< $run_agmip_simple_delta
xvfb-run R --no-save --vanilla --slave --args $currentDir $basefilename $code $futuresce $emission $period< $run_agmip_simple2full
else
code="F"
xvfb-run R --no-save --vanilla --slave --args $currentDir $dataDir $basefilename $futuresce $emission $period< $run_agmip_simple_mandv
xvfb-run R --no-save --vanilla --slave --args $currentDir $basefilename $code $futuresce $emission $period< $run_agmip_simple2full
fi
done

cd ../output2
zip futsce.zip *
cp futsce.zip $output
cd ..
rm -rf input
rm -rf output1
rm -rf output2

exit
