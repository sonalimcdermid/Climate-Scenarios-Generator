%			acr_agmip2WTH 
%
%       This script converts from the .AgMIP format to the dssat ICASA format
%
%				author: Alex Ruane
%                                       aruane@giss.nasa.gov
%				date:	03/22/12
%
%
function acr_agmip2WTH(infile,outfile)
%--------------------------------------------------
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%  

%% begin debug
%infile = '/home/aruane/temp/GulfCoast/ClimateFiles/basefiles/FL110WXX.AgMIP';
%outfile = '/home/aruane/temp/GulfCoast/ClimateFiles/basefiles/FL110WXX.WTH';
%% end debug

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

unix(['awk ''' 'NR<5 {print}'' ' infile ' > ' outfile]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
base = acr_agmipload(infile);
base(find(isnan(base))) = -99;

%% write it all out with proper station code

%% simple AgMIP format: 
wthid = fopen([outfile 'unix'],'wt');
fprintf(wthid,'%s\n',['@DATE  SRAD  TMAX  TMIN  RAIN']);

for dd=1:length(base),
  thisdate = num2str(base(dd,1));
  fprintf(wthid,'%5s%6.1f%6.1f%6.1f%6.1f\n',thisdate(3:end),base(dd,5:8));
end;

fclose(wthid);

eval(['!awk ''' 'sub(' '"' '$' '"' ',' '"' '\r' '"' ')''' ' ' outfile 'unix >> ' outfile]);

%%%% convert to windows notepad format and remove temp file
eval(['!rm ' outfile 'unix']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
