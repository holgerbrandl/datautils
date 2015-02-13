
spinr(){
    ## download if not yet there
    if [ -z "$(which spin.R)" ]; then
        >&2 echo "spin.R is not installed. See https://github.com/holgerbrandl/datautils/tree/master/R/spinr for details"
    fi

    ~/spin.R $*
}
export -f spinr


spinsnip(){
    if [ $# -lt 1 ]; then
         >&2 echo "Usage: spinsnip <report name> [other args]*"
         >&2 echo "The R snippet to be spinned will be read from standard input."
        return
    fi

    reportName=$1
    tmpR=$(echo $reportName | tr " " "_").R

    ## http://stackoverflow.com/questions/11454343/pipe-output-to-bash-function
    cat | sed 's/#>/#'"'"'/g'  > $tmpR

    echo "spining $tmpR..."

    shift
    spinr $tmpR $*

    rm $tmpR
}
export -f spinsnip

## usage example
# echo '
# > # test report
# 1+1;
# ggplot(iris, aes(Sepal.Width) + geom_histogram()
# ' | spinsnip some_report
