
rendr(){
    ## test if present in PATH
    if [ -z "$(which rendr.R)" ]; then
        >&2 echo "rendr.R is not installed. See https://github.com/holgerbrandl/datautils/tree/master/R/rendr for details"
    fi

    spin.R $*
}
export -f rendr


rendr_snippet(){
    if [ $# -lt 1 ]; then
         >&2 echo "Usage: rendr_snippet <report name> [other args]*"
         >&2 echo "The R snippet to be spinned will be read from standard input."
        return
    fi

    reportName=$1
    tmpR=$(mktemp -d)/$(echo $reportName | tr " " "_").R

    ## http://stackoverflow.com/questions/11454343/pipe-output-to-bash-function
    cat | sed 's/#>/#'"'"'/g'  > $tmpR

    echo "rendering $tmpR..."

    shift
    rendr -e $tmpR $*

#    rm -r $(dirname $tmpR)
    rm ${tmpR}
}
export -f rendr_snippet

## usage example
# echo '
# > # test report
# 1+1;
# ggplot(iris, aes(Sepal.Width) + geom_histogram()
# ' | spinsnip some_report
