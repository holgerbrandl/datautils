## a thin wrapper around spin to make it more useful with more custom output
require(knitr)
require(stringr)

options(width=150)

#https://groups.google.com/forum/#!topic/knitr/ojcnq5Nm298

## better table css: http://www.stat.ubc.ca/~jenny/STAT545A/topic10_tablesCSS.html

#setwd("/local/home/brandl/mnt/mack/project-raphael/reports/spin_report")
#setwd("/home/brandl/mnt/mack/project-raphael/reports/spin_report")

#rScript='/home/brandl/mnt/mack/project-raphael/Rcode/misc/DivisionPerpendicularity.R'
#rScript='/home/brandl/mnt/mack/project-raphael/Rcode/misc/Test.R'

#spinr <- function(rScript){
    print(Sys.getenv("TISSMORH_SCRIPTS"))
    spin(rScript, knit=F)

    mdScript <- str_replace(rScript, "[.]R$", ".Rmd")

    system(paste("mv", mdScript, "tmp.Rmd"))
    system(paste("cat tmp.Rmd | grep -Ev '^#+$' | grep -Fv '#!/usr/bin/env Rscript' >", basename(mdScript)))

    cssHeader='
    <style type="text/css">
      body {
          max-width: 90%;
      }
    </style>
    '
    ls()

    opts_chunk$set(cache = TRUE, fig.width=10, width=120)
    knit2html(basename(mdScript))

    #file.remove(mdScript)
#}

# spinr("/home/brandl/mnt/mack/project-raphael/Rcode/misc/DivisionPerpendicularity.R")
# spinr("/home/brandl/mnt/mack/project-raphael/Rcode/misc/Test.R")
