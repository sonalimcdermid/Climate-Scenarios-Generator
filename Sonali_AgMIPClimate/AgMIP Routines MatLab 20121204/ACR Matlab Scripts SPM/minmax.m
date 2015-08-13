%
%  returns max and min of the variable (up to 10 dimensions)
%
%
function result = minmax(vaar)

  mmax = max(max(max(max(max(max(max(max(max(max(vaar))))))))));
  mmin = min(min(min(min(min(min(min(min(min(min(vaar))))))))));
  result = [mmin mmax];
 
