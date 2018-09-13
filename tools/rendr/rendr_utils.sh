
## test if present in PATH
if [ -z "$(which rend.R  2>/dev/null)" ]; then
    echo "rendr.R is not installed. See https://github.com/holgerbrandl/datautils/tree/master/R/rendr for details" >&2
    exit 1
fi


rendr_snippet(){
    if [ $# -lt 1 ]; then
         >&2 echo "Usage: rendr_snippet <report name> [other args]*"
         >&2 echo "The R snippet to be rendered will be read from standard input."
        return
    fi

    reportName=$1
    tmpR=$(mktemp -d /tmp/rendr.XXXX)/$(echo $reportName | tr " " "_").R

    ## http://stackoverflow.com/questions/11454343/pipe-output-to-bash-function
    cat | sed 's/#>/#'"'"'/g'  > $tmpR

    echo "rendering $tmpR..."

    shift
    rend.R --resprefix "$reportName" $tmpR $*

#    rm -r $(dirname $tmpR)
    rm ${tmpR}
}
export -f rendr_snippet

## usage example
# echo '
# > # test report
# 1+1;
# ggplot(iris, aes(Sepal.Width) + geom_histogram()
# ' | rendr_snippet some_report


rendr_md(){
mdFile=$1
if [[ ${mdFile: -3} != ".md" ]]; then
    echo "input '${mdFile}' is not a mardkdown file. quitting..." 1>&2;
    return;
fi

cd $(dirname ${mdFile})
tmpRmd=$(basename ${mdFile} .md).Rmd
sed 's/```r/```{r}/g' ${mdFile} > ${tmpRmd}
rend.R --toc ${tmpRmd}
rm ${tmpRmd}
open $(basename $1 .md).html
}
export -f rendr_md

#rendr_md /Users/brandl/Dropbox/documents/regression/regression_basics.md
#sed 's/```r/```{r}'  /Users/brandl/Dropbox/documents/regression/regression_basics.md


just_spin(){

echo '
require(knitr)
spin(commandArgs(T)[1], knit=F)
' | Rscript - $1

}
