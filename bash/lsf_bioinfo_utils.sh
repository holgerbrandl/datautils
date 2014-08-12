
## create fastq report for all fastq and fastq.gz files in the current directory
mmFastqc(){
    outputDir="fastqc_reports"
#    filePattern="fastq.gz"
#    outputDir=$1
#    filePattern=$2
    mkdir $outputDir
    for fastqFile in *fastq *fastq.gz ; do
        if [ ! -f $fastqFile ]; then
            continue;
        fi
        echo processing $fastqFile
#        bsub -q medium --J fastqc_$(basename $fastqFile) "fastqc -j /sw/bin/java -o $outputDir -f fastq $fastqFile" | joblist .fastqc_jobs
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



### Create a cuffdb on a network of lustre file-systen
MakeCuffdb() {
    if [ $# -ne 2 ]; then echo "Usage: MakeCuffdb <gtffile> <genomebuild>"; return; fi

echo '
devtools::source_url("http://dl.dropbox.com/u/113630701/rlibs/base-commons.R")
options(width=150)

require.auto(cummeRbund)

createCuffDbTrickyDisk <- function(dbDir, gtfFile, genome, ...){
    tmpdir <- tempfile()
    system(paste("cp -r", dbDir, tmpdir))
    oldWD <- getwd()
    setwd(tmpdir)
    cuff <- readCufflinks(rebuild=T, gtf=gtfFile, genome="mm10", ...)
#    cuff <- readCufflinks(gtf=gtfFile, genome="mm10", rebuild=T)

    system(paste("cp cuffData.db", dbDir))
    system(paste("rm -r", tmpdir))

    setwd(oldWD)
    return(cuff)
}

gtfFile=commandArgs(TRUE)[1]
genomeBuild=commandArgs(TRUE)[2]

createCuffDbTrickyDisk(getwd(), gtfFile, genomeBuild)
' | R -q --no-save --no-restore  --args $1 $2
}
export -f MakeCuffdb
