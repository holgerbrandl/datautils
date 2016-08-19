#' # Test Report

#' The args were `r commandArgs(T)`. There were `r length(commandArgs(T))` arguments in total

#' ## Fancy plot

require(ggplot2)
require(DT)
ggplot(iris, aes(Sepal.Width, Sepal.Width)) + geom_point()

#' ## And here comes a table

require(DT)
datatable(iris)


#' # wait here
cat("waiting...")
Sys.sleep(2)
cat("done! ")


## cd Desktop; export PATH=/Users/brandl/Dropbox/Public/datautils/R/rendr:$PATH
## rend.R -e /Users/brandl/Dropbox/Public/datautils/R/rendr/test/simple_report.R --fancy_arg 3 -E "foo bar"

## cd ~/Desktop/cache_test
## export PATH=/Users/brandl/Dropbox/Public/datautils/R/rendr:$PATH; which rend.R
## rend.R -e -c /Users/brandl/Dropbox/Public/datautils/R/rendr/test/simple_report.R --fancy_arg 3 -E "foo bar"

## R --args -e -c /Users/brandl/Dropbox/Public/datautils/R/rendr/test/simple_report.R --fancy_arg 3 -E "foo bar"
## rend.R /Users/brandl/Dropbox/Public/datautils/R/rendr/test/simple_report.R

#' ![image inlineing failed](`r file.path(RENDR_SCRIPT_DIR, "inline_test.png")`)

1+1