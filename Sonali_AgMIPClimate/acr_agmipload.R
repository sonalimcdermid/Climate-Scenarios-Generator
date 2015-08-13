#%			acr_agmipload
#%
#%       This script reads in a .AgMIP file
#%
#%       inputs:
#%       infile (.AgMIP format)
#%
#%       returns:
#%       outfile (11323x12 AgMIP file contents)
#% 
#%				author: Alex Ruane
#%                                       alexander.c.ruane@nasa.gov
#%				date:	03/09/12
#%
#%

# Conversion from Matlab to R
# by Yunchul Jung
# at 8/12/2012

acr_agmipload <-  function(infile){
 
 	## begin debug : YJ
	#infile = 'E:\\project-Agmip\\Climate-IT\\test\\USAM0XXX.AgMIP';
	#table <- acr_agmipload(infile);
	#print(table);	
	## end debug
	
	## read in file
	con <- file(infile, "r");

	## read input file and then save it into table format by excluding header information
	line_num_counter <- 1;# need to skip 5 first lines with including a blank line
	tempfilename <- 'temptable.txt';#temp file
	sink(tempfilename);
	while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {	
		if(line_num_counter < 6){
			line_num_counter <- line_num_counter + 1;
		}else{		
			cat(oneLine,'\n');		
		}
	}	
	sink();
	## read input as table
	outfile <- read.table(tempfilename);

	close(con);
	#YJ: delete temp file
	unlink(tempfilename, recursive = FALSE, force = FALSE);

	return(outfile); 
}

