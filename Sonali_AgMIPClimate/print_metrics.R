##  Print metrics.csv

yesno <- readline('\n\nPrint metrics.csv? Yes(1)/No(2): ')
if (yesno == 2 || yesno == 'n' || yesno == 'N' || yesno == 'no' || yesno == 'No' || yesno == 'NO') {
  
  message('\n\nagmip2metrics complete! No results file was created.  \nView variable \'metric\' in workspace for complete results.\n\n')
  
} else {
  #dir.create(paste(rootDir, 'analysis', sep='/'), showWarnings = FALSE)
  #dir.create(paste(rootDir, 'analysis/metrics', sep='/'), showWarnings = FALSE)
  
  outfile <- paste(rootDir,'data/Climate/Metrics/', infile[1], '_', analysis.type, '_', clim.var.names[clim.var], '.csv', sep='')
  file.create(outfile)
  
  cat('Metrics for .AgMIP files created', format(Sys.time(),'%d/%m/%Y at %H:%M:%S %Z'), '\n\n', file=outfile)
  write.table(matrix(c('clim.var', 'clim.var.name', 'analysis.type', 'reference', 'special.operator',clim.var, clim.var.names[clim.var], analysis.type, reference, special.operator), nrow = 2, byrow = TRUE), file=outfile, sep=",", row.names = FALSE, col.names = FALSE, append = TRUE)
  
  cat('\n', file=outfile, append = TRUE)
  write.table(matrix(c('', infile, 'jd.start', jd.start, 'jd.end', jd.end), nrow=3, byrow = TRUE), file=outfile, sep=",", row.names = FALSE, col.names = FALSE, append = TRUE)
  
  cat('\n', file=outfile, append = TRUE)
  suppressWarnings(write.table(metric, file=outfile, sep=",", row.names=FALSE, col.names = TRUE, append = TRUE))
  
  message('\n\nagmip2metrics complete! Metric results file saved as...\n\t', paste(rootDir, 'analysis/metrics/metrics_', infile[1], '_', analysis.type, '_', clim.var.names[clim.var], '.csv', sep=''), '\nYou can also view variable \'metric\' in workspace for complete results.\n\n')
}