#!/usr/bin/env Rscript

# similar http://stackoverflow.com/questions/10943695/what-is-the-knitr-equivalent-of-r-cmd-sweave-myfile-rnw

#http://stackoverflow.com/questions/3433603/parsing-command-line-arguments-in-r-scripts
#https://github.com/edwindj/docopt.R
#http://www.slideshare.net/EdwindeJonge1/docopt-user2014

## a thin wrapper around spin to make it more useful with more custom output
#devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/core_commons.R")

# load the docopt library
suppressMessages(library(docopt))

# retrieve and parse the command-line arguments
doc <- '
Use knitr to spin R documents
Usage: spin.R [options] <r_script> [<quoted_script_args>]

Options:
-c        Cache results
-e        Show Code
-w        Show warnings
-m        Show Messages
--keep    Keep generated Rmd and md files
'
#!docopt(doc, "-w test  a b c ")$keep
#docopt(doc, "-w test  a b c ")$"-w"
#spin_opts <- docopt(doc, "$DGE_HOME/dge_analysis.R \"--undirected --qcutoff 0.05 --minfpkm 2 ..\"")

spin_opts <- docopt(doc)
#print(spin_opts)

r_script <- spin_opts$r_script
keep_markdown_files <- as.logical(spin_opts$keep)

if(keep_markdown_files){
    print("keeping markdown files")
}

if(!file.exists(r_script)){
     stop(paste("file does not exist\n", doc))
}


require(plyr)
require(knitr)
require(stringr)

options(width=150)

#https://groups.google.com/forum/#!topic/knitr/ojcnq5Nm298

## better table css: http://www.stat.ubc.ca/~jenny/STAT545A/topic10_tablesCSS.html
commandArgs <- function(trailingOnly = FALSE){ return(as.character(spin_opts$quoted_script_args)) }
#print("trimmed args are")
#print(commandArgs())
#print("end args")


## todo use temp-file-name here to allow for cocurring spin.R in same directory
## copy R-script to working directory and forget about the original one
#file.copy(r_script, basename(r_script))
system(paste("cat ", r_script," | grep -Ev '^#+$' | grep -Fv '#!/usr/bin/env Rscript' >", basename(r_script)))
r_script <- basename(r_script)

spin(r_script, knit=F)
file.remove(basename(r_script))

rmdScript <- str_replace(r_script, "[.]R$", ".Rmd")

# system(paste("mv", rmdScript, "tmp.Rmd"))
#system(paste("cat tmp.Rmd | grep -Ev '^#+$' | grep -Fv '#!/usr/bin/env Rscript' >", basename(rmdScript)))
#file.remove("tmp.Rmd")

cssHeader='
<style type="text/css">
  body {
      max-width: 90%;
  }
</style>


<!-- add jquery datatable support -->
<link rel="stylesheet" type="text/css" href="http://cdn.datatables.net/1.10.4/css/jquery.dataTables.css">
<script type="text/javascript" charset="utf8" src="http://code.jquery.com/jquery-2.1.2.min.js"></script>
<script type="text/javascript" charset="utf8" src="http://cdn.datatables.net/1.10.4/js/jquery.dataTables.js"></script>
'

#<!-- add bootstrap support -->
#<link href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
#<script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>


## custom title http://stackoverflow.com/questions/14124022/setting-html-meta-elements-with-knitr
opts_chunk$set(
    cache = spin_opts$c,
    message= spin_opts$m,
    warning= spin_opts$w,
    echo= spin_opts$e,
    fig.width=15,
    width=200
)

knit2html(basename(rmdScript), header=cssHeader)

## also remove the .md and the .Rmd files
if(is.logical(keep_markdown_files) & !keep_markdown_files){
    file.remove(basename(rmdScript))
    file.remove(basename(str_replace(r_script, "[.]R$", ".md")))
}

