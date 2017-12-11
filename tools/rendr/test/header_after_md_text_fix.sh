
cat /Users/brandl/Dropbox/Public/datautils/R/rendr/test/simple_report.R | sed 's/#\x27 #/#\x27\'$'\n#\x27 #/g'
cat tt.R | sed 's/#\x27 #/#\x27\'$'\n#\x27 #/g'

## this works but the \ needs to be escaped in the R command as \\
cat /Users/brandl/Dropbox/Public/datautils/R/rendr/test/simple_report.R |  sed 's/_TODAY_/'$(date +\"%m-%d-%Y\")'/g' | sed 's/#\x27 #/#\x27\'$'\n#\x27 #/g' | grep -Fv '#!/usr/bin/env Rscript'


## resources
http://stackoverflow.com/questions/24509214/how-to-escape-single-quote-in-sed
http://stackoverflow.com/questions/723157/how-to-insert-a-newline-in-front-of-a-pattern