

## just knit R documents as they are, no markdown is required (but supported to some extent)
rknit(){
    ## rscript=/projects/project-raphael/Rcode/misc/DivisionPerpendicularity.R
    ## rscript=/projects/project-raphael/Rcode/misc/DivisionPerpendicularity.R
    rscript=$1
#    tmdRmd=$(mktemp  --suff .Rmd)
    tmdRmd=$(basename $rscript .R).Rmd

    echo '# '$(basename $rscript .R) > $tmdRmd
    echo '```{r} ' >> $tmdRmd
    cat $rscript | Rscript  -e 'require(stringr); require(dplyr); readLines(file("stdin")) %>% str_replace("##> (.*)", "```\n\\1\n```{r}") %>% writeLines(stdout()) ' >> $tmdRmd
    echo '```' >> $tmdRmd

    echo 'require(knitr); opts_knit$set(cache = TRUE); knit2html("'$tmdRmd'", output="'$(basename $rscript .R)'")' | R --vanilla -q
}


