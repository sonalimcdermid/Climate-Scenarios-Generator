
readme.txt

######################################################################
#[update at Aug-28, 2012]

1. added acr_agmip0000.R and run_batch0000.R

- acr_agmip0000.R : it is converted but needed to test with bunch of data set


######################################################################

# by Yunchul Jung
# at 8/12/2012

[ Conversion from matlab script to R ]

1. folder structure
-> matlab : original matlab files
-> r : converted r files
-> data : input/output files


2. orginal matlab program

- acr_agmip004.m (size: 13 KB)
- acr_findspot.m (size: 2 KB)

- acr_agmip005.m (size: 4 KB)

- acr_agmipmetrics.m (size: 8 KB)
- acr_agmipload.m (size: 1 KB)

3. test

- run R script files in r folder
-> run_delta004.R
-> run_delta005.R
-> run_metrics.R

4. notes

- R.matlab package should be installed, and loaded when program runs

-> readMat() of R.matlab is used to load matrix file of matlab, epecially for multi-dimensional matrix, because read.table() of R supports only one dimension matix
-> pakage installation : enter "install.package("R.matlab")", and then enter again.

- running speed

-> generally, execution speed is slower than matlab code. 
-> Especially, acr_agmip005.R is much slow than others. It seems there is a problem at ln:66 where assigning a value to "newfut[mm,10]". It could not be improved yet.


