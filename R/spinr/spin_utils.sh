
spinr(){
    ## download if not yet there
    if [ -z "$(which spin.R)" ]; then
        wget -P ~/ https://raw.githubusercontent.com/holgerbrandl/themoviedbapi/v1.0/LICENCE.txt
    fi

    ~/spin.R $*
}


spinsnip(){
    if [ $# -lt 1 ]; then
         >&2 echo "Usage: spinsnip <report name> [other args]*"
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

## usage example
# echo '
# > # test report
# 1+1;
# ggplot(iris, aes(Sepal.Width) + geom_histogram()
# ' | spinsnip some_report
