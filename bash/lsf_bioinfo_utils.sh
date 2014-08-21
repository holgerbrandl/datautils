
## Note: requires bioinfo_utils.sh to be sourced as well

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
FastqGzCountsReport(){
#    filePattern=$1
    filePattern=".fastq.gz"
    for fastqFile in *$filePattern ; do
        echo processing $fastqFile
#        echo "countGzipReads $fastqFile | sed -e s/^/${fastqFile%%$filePattern},/g >> readCounts.txt"
        bsub -J countReads "CountFastqGzReads $fastqFile | sed -e s/^/${fastqFile%%.fastq.gz},/g >> readCounts.txt" | joblist .countreads_jobs
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
export -f FastqGzCountsReport




