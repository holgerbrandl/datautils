#!/usr/bin/env Rscript

# similar http://stackoverflow.com/questions/10943695/what-is-the-knitr-equivalent-of-r-cmd-sweave-myfile-rnw

#http://stackoverflow.com/questions/3433603/parsing-command-line-arguments-in-r-scripts
#https://github.com/edwindj/docopt.R
#http://www.slideshare.net/EdwindeJonge1/docopt-user2014

# load the docopt library
suppressMessages(library(docopt))

# retrieve and parse the command-line arguments
doc <- '
Use rmarkdown to render R and Rmd into html documents
Usage: rend.R [options] <r_script> [<quoted_script_args>]

Options:
--toc     Add a table of contents
-c        Cache results
-e        Show Code
-w        Show warnings
-m        Show Messages
--keep    Keep generated Rmd and md files
'

opts <- docopt(doc)


r_script <- opts$r_script
keep_markdown_files <- as.logical(opts$keep)



if(!file.exists(r_script)){
     stop(paste("file does not exist\n", doc))
}


## postfix a default empty yaml header
tmpScript <- tempfile(fileext=".R")

metadata <- paste('\n',
  '#\'---\n',
  '#\'title: ""\n',
  '#\'author: ""\n',
  '#\'date: ""\n',
  '#\'---\n'
, sep = "")
file.copy(r_script, tmpScript)
cat(metadata, file = tmpScript, append = TRUE)


jsAddons <- tempfile(fileext=".js")
#cat("<script src='https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/rendr/toggle_code_sections.js' type='application/javascript'></script>", file=jsAddons)
cat("<script src='https://code.jquery.com/jquery-2.1.4.min.js' type='application/javascript'></script>", file=jsAddons)
cat("<script src='http://cdn.rawgit.com/holgerbrandl/datautils/master/R/rendr/toggle_code_sections.js' type='application/javascript'></script>", file=jsAddons, append=T)

#require(plyr)
require(knitr)
require(stringr)

options(width=150)

#https://groups.google.com/forum/#!topic/knitr/ojcnq5Nm298

commandArgs <- function(trailingOnly = FALSE){ return(as.character(opts$quoted_script_args)) }

#system(paste("cat ", r_script," | grep -Ev '^#+$' | grep -Fv '#!/usr/bin/env Rscript' >", basename(r_script)))
#r_script <- basename(r_script)


## custom title http://stackoverflow.com/questions/14124022/setting-html-meta-elements-with-knitr
opts_chunk$set(
    cache = opts$c,
    message= opts$m,
    warning= opts$w,
    echo= opts$e,
    fig.width=15,
    width=200
)

rmarkdown::render(input=tmpScript,output_file=str_replace(basename(r_script), ".R", ".html"),
    output_format=rmarkdown::html_document(toc = opts$toc, keep_md=T, pandoc_args=paste("--include-in-header=", tempfile)),
    output_dir=getwd(),
    output_options=list(toc="yes")
)

## also remove the .md and the .Rmd files
if(is.logical(keep_markdown_files) & !keep_markdown_files){
#    file.remove(basename(rmdScript))
#    file.remove(basename(str_replace(r_script, "[.]R$", ".md")))
}

