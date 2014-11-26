## a thin wrapper around spin to make it more useful with more custom output

require(plyr)
require(knitr)
require(stringr)

options(width=150)

#https://groups.google.com/forum/#!topic/knitr/ojcnq5Nm298

## better table css: http://www.stat.ubc.ca/~jenny/STAT545A/topic10_tablesCSS.html
spin(rScript, knit=F)

rmdScript <- str_replace(rScript, "[.]R$", ".Rmd")

system(paste("mv", rmdScript, "tmp.Rmd"))
system(paste("cat tmp.Rmd | grep -Ev '^#+$' | grep -Fv '#!/usr/bin/env Rscript' >", basename(rmdScript)))
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

## tell knitr to stop on errors https://github.com/yihui/knitr/issues/344 and http://yihui.name/knitr/options
opts_knit$set(stop_on_error = 2L)

knit2html(basename(rmdScript), header=cssHeader)

file.remove(basename(rmdScript))
file.remove(basename(str_replace(rScript, "[.]R$", ".md")
))
