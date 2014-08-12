
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

