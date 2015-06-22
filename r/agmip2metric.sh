#! /bin/bash

#set -x

#if [$# -ne 3]
#then
#  echo "Usage: `basename $0` {acmofile} {xvariable} {yvariable} {group1} {group2} {pngoutput}"
#  exit -1
#fi
inputzipfile=$1
start=$2
end=$3
climvar=$4
analysistype=$5
refer=$6
operator=$7
output=$8

rootDir=$PWD
INSTALL_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $PWD
cp $inputzipfile 1.zip
unzip 1.zip   

command -v R >/dev/null 2>&1 || { echo >&2 "'R' is required by this tool but was not found on past";exit 1;}


run_acr_agmip2metrics=$INSTALL_DIR/run_acr_agmip2metrics.R


#cp $baseclimate $PWD/input/1.zip
#cd $INSTALL_DIR/input
#unzip 1.zip 

#cp $futurescefile $INSTALL_DIR/input/2.zip
#unzip 2.zip


xvfb-run R --no-save --vanilla --slave --args $rootDir $start $end $climvar $analysistype $refer $operator $output< $run_acr_agmip2metrics

rm -f 1.zip

exit
