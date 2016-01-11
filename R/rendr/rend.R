#!/usr/bin/env Rscript

# similar http://stackoverflow.com/questions/10943695/what-is-the-knitr-equivalent-of-r-cmd-sweave-myfile-rnw

#http://stackoverflow.com/questions/3433603/parsing-command-line-arguments-in-r-scripts
#https://github.com/edwindj/docopt.R
#http://www.slideshare.net/EdwindeJonge1/docopt-user2014

# load the docopt library
suppressMessages(if (!require("docopt")) install.packages("docopt"))
suppressMessages(if (!require("knitr")) install.packages("knitr"))
suppressMessages(if (!require("stringr")) install.packages("stringr"))
suppressMessages(if (!require("rmarkdown")) install.packages("rmarkdown"))
# disabled because user script will fail if they load plyr before dplyr
#suppressMessages(if (!require("dplyr")) install.packages("dplyr"))

## test invokation that mimics actual workflow: R --args -e "fsdf.R" "hello sdf" -e

## find the first r document and split up the arguments
allArgs = commandArgs(T)
rdocsInArgs = str_detect(allArgs, ".R$")

if(any(rdocsInArgs)){
    rmdDocIndex <- min(which(rdocsInArgs))
    rendrArgs <- allArgs[0:rmdDocIndex]
    scriptArgs <- allArgs[-(0:rmdDocIndex)]
}else{
    rendrArgs <- allArgs
}


# retrieve and parse the command-line arguments
doc <- '
Use rmarkdown to render R and Rmd into html documents
Usage: rend.R [options] <r_script> [<quoted_script_args>]

Options:
--toc     Add a table of contents
-c        Cache results
-e        Add collapsed code chunks
-E        Add uncollapsed code chunks
-w        Show warnings
-m        Show Messages
--keep    Keep generated Rmd and md files
'

opts <- docopt(doc, args=rendrArgs)


r_script <- opts$r_script
keep_markdown_files <- as.logical(opts$keep)


if(!file.exists(r_script)){
     stop(paste("file does not exist\n", doc))
}


## Create a temporary script in the current working directory to ensure that created resources plots etc can be inlined
## To allow for additional resoucrces from the scripts directory to be inlined into the final documents, the directory
## of the script is exposed as a variable called RENDR_SCRIPT_DIR
## Note:## Using the script-home-dir as wd does not work because plot pngs would not make it into the final document. Also
## It's better to not clutter the directory containing the script since it might be under version control.

RENDR_SCRIPT_DIR=dirname(normalizePath(r_script))
tmpScript <- tempfile(fileext=".R", tmpdir=getwd())
print(paste("compiling tmp-script in ",tmpScript, "'"))
#tmpScript <- "tt.R"


## remove sheband and comment-only lines from source document
#file.copy(r_script, tmpScript)

#system(paste("cat ", r_script," | sed 's/_TODAY_/'$(date +\"%m-%d-%Y\")'/g' | grep -Ev '^#+$' | grep -Fv '#!/usr/bin/env Rscript' >", tmpScript))

## see /Users/brandl/Dropbox/Public/datautils/R/rendr/test/header_after_md_text_fix.sh
system(paste("cat ", r_script," | sed 's/_TODAY_/'$(date +\"%m-%d-%Y\")'/g' | grep -Ev '^#####+$' | sed 's/#\\x27 #/#\\x27\\'$'\\n#\\x27 #/g' | grep -Fv '#!/usr/bin/env Rscript' >", tmpScript))

## add yaml header (will be ignored if already present
metadata <- paste0('#\'\n\n',
  '#\' ---\n',
  '#\' title: ""\n',
  '#\' author: ""\n',
  '#\' date: ""\n',
  '#\' ---\n\n')
cat("\n", file = tmpScript, append=TRUE)
cat(metadata, file = tmpScript, append=TRUE)


# see http://stackoverflow.com/questions/17341122/link-and-execute-external-javascript-file-hosted-on-github

jsAddons <- tempfile(fileext=".js")
#cat("<script src='https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/rendr/toggle_code_sections.js' type='application/javascript'></script>", file=jsAddons)
cat("<script src='https://code.jquery.com/jquery-2.1.4.min.js' type='application/javascript'></script>", file=jsAddons)

if(opts$e){
    cat("<script src='http://cdn.rawgit.com/holgerbrandl/datautils/master/R/rendr/toggle_code_sections.js' type='application/javascript'></script>", file=jsAddons, append=T)
}


## does not work yet
#cat("<style type='text/css'>
#.container-fluid {
#    max-width: 100% ;
##    color: blue;
#}
#</style>", file=jsAddons, append=T)


#https://groups.google.com/forum/#!topic/knitr/ojcnq5Nm298

commandArgs <- function(trailingOnly = TRUE){ scriptArgs } ## note trailingOnly is simply ignored


#system(paste("cat ", r_script," | grep -Ev '^#+$' | grep -Fv '#!/usr/bin/env Rscript' >", basename(r_script)))
#r_script <- basename(r_script)


## custom title http://stackoverflow.com/questions/14124022/setting-html-meta-elements-with-knitr
opts_chunk$set(
    cache = opts$c,
    message= opts$m,
    warning= opts$w,
    echo= opts$e | opts$E,
    out.width='100%'
)

## alternatively we could use tmpScript <- tempfile(fileext=".R", tmpdir=".") but it would require addtional cleanup
knitr::opts_knit$set(
    root.dir = getwd()
)

rmarkdown::render(input=tmpScript,output_file=str_replace(basename(r_script), ".R", ".html"),
    output_format=rmarkdown::html_document(toc = opts$toc, keep_md=keep_markdown_files, pandoc_args=paste0("--include-in-header=", jsAddons)),
    output_dir=getwd())

#if(!keep_markdown_files){
#    unlink(str_replace(basename(r_script), ".R", ".md"))
#}

## delete figures directory since all plots should be embedded anyway
#echo("deleteing", paste0(str_replace(basename(r_script), ".R", ""), "_files"))
unlink(paste0(str_replace(basename(r_script), ".R", ""), "_files"), recursive=T)
unlink(tmpScript)
