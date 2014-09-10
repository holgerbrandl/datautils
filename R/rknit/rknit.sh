

## just knit R documents as they are, no markdown is required (but supported to some extent)
rknit(){
    ## rscript=/projects/project-raphael/Rcode/misc/DivisionPerpendicularity.R
    ## rscript=/home/brandl/mnt/mack/project-raphael/Rcode/misc/DivisionPerpendicularity.R
    ## rscript=/Users/brandl/Dropbox/Public/datautils/R/rknit/rknit_example.R
    rscript=$1

#    tmdRmd=$(mktemp  --suff .Rmd)
    tmdRmd=$(basename $rscript .R).Rmd

#    echo '# '$(basename $rscript .R) > $tmdRmd

    ## alternatively we could use the header argument for knit2html
    echo '
<style type="text/css">
    body {
        max-width: 80%;
    }
</style>
```{r}
    ' > $tmdRmd

#    cat $rscript | grep -Fv '#!' | Rscript --vanilla  - 'require(stringr); require(dplyr); readLines(file("stdin")) %>% str_replace("^#([#]*)> ([^{]*)([{]+.+[}])?", "```\n\\1 \\2\n```{r \\3}") %>% collapsewriteLines(stdout())' # >> $tmdRmd
    cat $rscript | grep -Fv '#!' | Rscript --vanilla -e 'source("/Users/brandl/Dropbox/Public/datautils/R/rknit/rknit_preprocessor.R")'  >> $tmdRmd

    echo '```' >> $tmdRmd

    echo 'require(knitr); options(width=150); opts_chunk$set(cache = TRUE, fig.width=10, width=100); knit2html("'$tmdRmd'", output="'$(basename $rscript .R)'")' | R --vanilla -q
}

