

##
rknit(){
    if [ $# -ne 1 ]; then
        echo -e "Usage: rknit <script.R>\nJust knit R documents as they are, no markdown is required (but supported to some extent)"
        return
    fi

    ## rscript=/Users/brandl/Dropbox/Public/datautils/R/rknit/rknit_example.R
    rscript=$1

#    tmpRmd=$(mktemp  --suff .Rmd)
    tmpRmd=$(basename $rscript .R).Rmd

#    echo '# '$(basename $rscript .R) > $tmpRmd

    ## alternatively we could use the header argument for knit2html
    echo '
<style type="text/css">
    body {
        max-width: 90%;
    }
</style>
```{r}
    ' > $tmpRmd

#    cat $rscript | grep -Fv '#!' | Rscript --vanilla  - 'require(stringr); require(dplyr); readLines(file("stdin")) %>% str_replace("^#([#]*)> ([^{]*)([{]+.+[}])?", "```\n\\1 \\2\n```{r \\3}") %>% collapsewriteLines(stdout())' # >> $tmpRmd
#    cat $rscript | grep -Fv '#!' | Rscript --vanilla -e 'source("/Users/brandl/Dropbox/Public/datautils/R/rknit/rknit_preprocessor.R")'  >> $tmpRmd
#    cat $rscript | sed 's/^#>$//g'| grep -Fv '#!' | Rscript --vanilla -e 'devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/rknit/rknit_preprocessor.R")' | grep -v "^#>" >> $tmpRmd

    cat $rscript | sed 's/^#>$//g' | grep -Fv '#!'| grep -Ev '^#+$' | Rscript --vanilla -e 'devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.9/R/rknit/rknit_preprocessor.R")' >> $tmpRmd

    echo '```' >> $tmpRmd

    echo 'require(knitr); options(width=150); opts_chunk$set(cache = TRUE, fig.width=10, width=100); knit2html("'$tmpRmd'", output="'$(basename $rscript .R)'")' | R --vanilla -q

    rm $(basename $rscript .R) $tmpRmd
}


## notes
# http://yihui.name/knitr/options --> strip.white:
