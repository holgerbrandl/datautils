

spinr(){
    if [ $# -ne 1 ]; then
        echo -e "Usage: spinr <script.R>\nJust knit R documents as they are, no markdown is required (but supported to some extent)"
        return
    fi

    rscript=$1

    if [ ! -f $rscript ]; then
        >&2 echo  "$rscript does not exist"; exit;
    fi

    ## rscript=/Users/brandl/Dropbox/Public/datautils/R/rknit/rknit_example.R

#    echo 'devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/utils/spinr.R"); spinr("'$rscript'")' | R --vanilla -q
    echo 'rScript="'$rscript'"; devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/utils/spinr.R")' | R --vanilla -q

    rm *md
}

spinsnip(){
    if [ $# -ne 1 ]; then
         >&2 echo "Usage: spinsnip <report name>"
        return
    fi

    reportName=$1
    tmpR=$(tr " " "_" $reportName).R

    ## http://stackoverflow.com/questions/11454343/pipe-output-to-bash-function
    cat | sed 's/#>/#'"'"'/g'  > $tmpR

    echo "spining $tmpR..."


    spinr $tmpR
    rm $tmpR
}

#testsnip(){
#        cat > test.txt
#}

#' cd /home/brandl/mnt/mack/project-raphael/reports/spin_report
#' source <(curl https://dl.dropboxusercontent.com/u/113630701/datautils/R/utils/spinr.sh)

