

## just knit R documents as they are, no markdown is required (but supported to some extent)
rknit(){
    ## rscript=/projects/project-raphael/Rcode/misc/DivisionPerpendicularity.R
    ## rscript=/home/brandl/mnt/mack/project-raphael/Rcode/misc/DivisionPerpendicularity.R
    rscript=$1
#    tmdRmd=$(mktemp  --suff .Rmd)
    tmdRmd=$(basename $rscript .R).Rmd

    echo '# '$(basename $rscript .R) > $tmdRmd

    ## alternatively we could use the header argument for knit2html
    echo '

<style type="text/css">

body {
 max-width: 80%;
}
</style>

```{r}
    ' >> $tmdRmd
    cat $rscript | grep -Fv "#!" | Rscript  -e 'require(stringr); require(dplyr); readLines(file("stdin")) %>% str_replace("##> ([^{]*)[{](.*)[}]", "```\n\\1\n```{r \\2}") %>% writeLines(stdout()) ' >> $tmdRmd
    echo '```' >> $tmdRmd

    echo 'require(knitr); options(width=150); opts_knit$set(cache = TRUE); knit2html("'$tmdRmd'", output="'$(basename $rscript .R)'")' | R --vanilla -q
}

echo '

##> # Prepare elongation data

' | Rscript  -e 'require(stringr); require(dplyr); readLines(file("stdin")) %>% str_replace("##> ([^{]*)[{](.*)[}]", "```\n\\1\n```{r \\2}") %>% writeLines(stdout()) '
