## a thin wrapper around spin to make it more useful with more custom output

require(knitr)
require(stringr)

options(width=150)

#https://groups.google.com/forum/#!topic/knitr/ojcnq5Nm298

## better table css: http://www.stat.ubc.ca/~jenny/STAT545A/topic10_tablesCSS.html
spin(rScript, knit=F)

mdScript <- str_replace(rScript, "[.]R$", ".Rmd")

system(paste("mv", mdScript, "tmp.Rmd"))
system(paste("cat tmp.Rmd | grep -Ev '^#+$' | grep -Fv '#!/usr/bin/env Rscript' >", basename(mdScript)))
file.remove("tmp.Rmd")

cssHeader='
<style type="text/css">
  body {
      max-width: 90%;
  }
</style>
'

## custom title http://stackoverflow.com/questions/14124022/setting-html-meta-elements-with-knitr
opts_chunk$set(cache = TRUE, fig.width=10, width=120)
knit2html(basename(mdScript), header=cssHeader)

file.remove(basename(mdScript))
