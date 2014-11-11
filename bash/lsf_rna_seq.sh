
## create fastq report for all fastq and fastq.gz files in the current directory
dge_fastqc(){

while getopts "o:" curopt; do
    case $curopt in
    o) outputDir=$OPTARG;
    esac
done
shift $(($OPTIND - 1))

fastqFiles=$*

#if [ -z "$fastqFiles" ]; then
if [ $# -lt 1 ]; then
     echo "Usage: dge_fastqc [-o <output_directory>] [<fastq.gz file>]+" >&2 ; return;
fi

## use default directory if not specified
if [ -z "$outputDir" ]; then
     outputDir="fastqc_reports"
fi

if [ ! -d "$outputDir" ]; then
    echo "creating output directory '$outputDir'"
    mkdir $outputDir
fi


for fastqFile in $fastqFiles ; do
    echo "fastqcing $fastqFile"

    if [ ! -f $fastqFile ]; then
        continue;
    fi
    

    mysub "fastqc__$(basename $fastqFile)" "fastqc -j /sw/bin/java -o $outputDir -f fastq $fastqFile" -q medium  | joblist .fastqc_jobs
done


wait4jobs .fastqc_jobs

mailme "fastqc done for $outputDir"

# todo create some summary report here
}
export -f dge_fastqc



#http://wiki.bash-hackers.org/howto/getopts_tutorial
dge_tophat_se(){

# http://stackoverflow.com/questions/18414054/bash-getopts-reading-optarg-for-optional-flags

while getopts "i:" curopt; do
    case $curopt in
    i) IGENOME=$OPTARG;
    esac
done
shift $(($OPTIND - 1))


fastqFiles=$*

if [ -z "$IGENOME" ] || [ -z "$fastqFiles" ];
     then echo "Usage: dge_tophat_se -i <path to igenome> [<fastq.gz file>]+" >&2 ; return;
fi



export bowtie_gindex="$IGENOME/Sequence/Bowtie2Index/genome"
export gtfFile="$IGENOME/Annotation/Genes/genes.gtf"
#head $gtfFile

if [ ! -f $gtfFile ]; then
    >&2 echo "gtf '$gtfFile' does not exis"; return;
fi

if [ -z "$(which tophat)" ]; then
    >&2 echo "no tomcat binary in PATH"; return;
fi


echo "running tophat using igenome '$IGENOME' for the following files"

#fastqFiles=$(ls $baseDir/treps_pooled/*fastq.gz)

for fastqFile in $fastqFiles ; do
    echo "submitting tophat job for $fastqFile"

    # DEBUG fastqFile=/projects/bioinfo/holger/projects/eric/trimmed/a1_ca.fastq.gz
    fastqBaseName=$(basename ${fastqFile%%.fastq.gz})
    outputdir=$fastqBaseName

    ## uniquely mapping reads only:   http:/seqanswers.com/forums/showthread.php?s=93da11109ae12a773a128a637d69defe&t=3464
#    mysub "${project}__tophat__${fastqBaseName}" "
#    tophat -p6  -G $gtfFile -g1 -o $outputdir $bowtie_gindex $fastqFile
#
#    mv $outputdir/accepted_hits.bam $outputdir/$(basename $outputdir).bam
#    samtools index $outputdir/$(basename $outputdir).bam
#    " -n 5 -R span[hosts=1] -q long | joblist .tophatjobs
done

wait4jobs .tophatjobs

## create tophat mapping report
source <(curl https://dl.dropboxusercontent.com/u/113630701/datautils/bash/bioinfo_utils.sh 2>&1 2>/dev/null)
TophatMappingReport


}

# dge_tophat_se
# dge_tophat_se -i