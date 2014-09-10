

## just knit R documents as they are, no markdown is required (but supported to some extent)
rknit(){
    rscript=$1
    tmdRmd=$(mktemp  --suff .Rmd)

    echo '# '$(basename $rscript .R) >> $tmdRmd
    echo '```{r} ' >> $tmdRmd
    cat $rscript >> $tmdRmd
    echo '```' >> $tmdRmd

    echo "require(knitr); knit2html('$tmdRmd')" | R --vanilla -q
}
