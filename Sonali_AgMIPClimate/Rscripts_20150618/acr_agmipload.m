%			acr_agmipload
%
%       This script reads in a .AgMIP file
%
%       inputs:
%       infile (.AgMIP format)
%
%       returns:
%       outfile (11323x12 AgMIP file contents)
% 
%				author: Alex Ruane
%                                       alexander.c.ruane@nasa.gov
%				date:	03/09/12
%
%
function outfile = acr_agmipload(infile);
%--------------------------------------------------
%--------------------------------------------------
%% debug begin
%infile = '/home/aruane/temp/AgMIP/SouthAsia/Bangladesh/BDJE0XXX.AgMIP';
%% debug end

%% read in file
fid = fopen(infile);
line1 = fgetl(fid);
line2 = fgetl(fid);
line3 = fgetl(fid);
line4 = fgetl(fid);
line5 = fgetl(fid);
out1 = fscanf(fid,'%f');
outfile = (reshape(out1,length(out1)/11323,11323))';
fclose(fid);

%%%%%% Old version with hard-wired 12 columns
%fid = fopen(infile);
%line1 = fgetl(fid);
%line2 = fgetl(fid);
%line3 = fgetl(fid);
%line4 = fgetl(fid);
%line5 = fgetl(fid);
%outfile = (fscanf(fid,'%f',[12,11323]))';
%fclose(fid);
