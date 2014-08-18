
## create fastq report for all fastq and fastq.gz files in the current directory
mmFastqc(){
    outputDir="fastqc_reports"

    mkdir $outputDir

    for fastqFile in *fastq *fastq.gz ; do
        if [ ! -f $fastqFile ]; then
            continue;
        fi

        mysub "fastqc__$(basename $fastqFile)" "fastqc -j /sw/bin/java -o $outputDir -f fastq $fastqFile" -q medium  | joblist .fastqc_jobs
    done

    wait4jobs .fastqc_jobs
}
export -f mmFastqc


## count reads in all  fastq and fastq.gz files in the current directory
mmCountFastGzReads(){
#    filePattern=$1
    filePattern=".fastq.gz"
    for fastqFile in *$filePattern ; do
        echo processing $fastqFile
#        echo "countGzipReads $fastqFile | sed -e s/^/${fastqFile%%$filePattern},/g >> readCounts.txt"
        bsub -J countReads "countGzipReads $fastqFile | sed -e s/^/${fastqFile%%.fastq.gz},/g >> readCounts.txt" | joblist .countreads_jobs
#        countGzipReads $fastqFile | sed -e s/^/${fastqFile%%.fastq.gz},/g >> readCounts.txt
    done
    wait4jobs .countreads_jobs

    ## create a plot
    echo '
    devtools::source_url("http://dl.dropbox.com/u/113630701/rlibs/base-commons.R")

    readCounts <- subset(read.csv("readCounts.txt", h=F), select=-2)
    names(readCounts) <- c("file", "num_reads")
    gg <- ggplot(readCounts, aes(file, num_reads)) + geom_bar(stat="identity") + ggtitle(paste("read counts in\n", getwd())) + coord_flip() + scale_y_continuous(labels=comma)
    ggsave("read_counts.png", gg, width=8)
    ' | R -q --vanilla
}
export -f mmCountFastGzReads




##http://www.biostars.org/p/16471/
## estimate blast progress for fasta-query files. Result files are assumed to have the fasta id in column 1
BlastProgress(){
    if [ $# -eq 0 ]; then echo "Usage: BlastProgress <blast_query_fasta>+"; return; fi


   for query in $* ; do
#        query=$1
        blast=$query.blast.out
    #    echo "the blast out is: "$blast
        #echo "the fasta query is: "$query

        #curquery=$(tail -1 $blast | cut -f 1)
        # http://tldp.org/LDP/abs/html/fto.html
        if [ -s $blast ]; then
    #        echo "file exists and has non-zero size"
            curquery=$(tail -1 $blast | cut -f 1)
            curline=$(grep -n $curquery"$" $query |  cut -f 1 -d ':')
        else
    #        echo "file does not yet exist or is empty"
            curline=0
        fi

        nblines=$(wc -l $query | cut -f 1 -d " ")
        percent=$(echo "($curline/$nblines) *100" | bc -l | cut -c 1-4)
        echo "Approximately $percent % of $query were processed."
    done
}
export -f BlastProgress
