
## Tophat Mapping Report from the logs
TophatMappingReport(){
echo '
devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/core_commons.R")
devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/ggplot_commons.R")


parseAlgnSummary_T2_0_11 <- function(alignSummary){
    #alignSummary="/projects/bioinfo/holger/projects/marta_rnaseq/human_leipzig/mapping/S5382_aRG_1b_rep1/align_summary.txt"
    algnData <- readLines(alignSummary)

    data.frame(
        condition=basename(dirname(alignSummary)),
        num_reads=as.numeric(str_match(algnData[2], " ([0-9]*$)")[,2]),
        mapped_reads=as.numeric(str_match(algnData[3], ":[ ]*([0-9]*) ")[,2][1])
    ) %>% transform(mapping_efficiency=100*mapped_reads/num_reads)
}


algnSummary <- ldply(list.files(".", "align_summary.txt", full.names=TRUE, recursive=T), parseAlgnSummary_T2_0_11, .progress="text")
write.delim(algnSummary, file="tophat_mapping_stats.txt")

scale_fill_discrete <- function (...){ scale_color_brewer(..., type = "seq", palette="Set1", "fill", na.value = "grey50") }


projectName=basename(dirname(getwd()))

devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/mdreport/master/R/mdreport-package.r")

md_new(paste("Mapping Summary for ", projectName))


md_plot(ggplot(algnSummary, aes(condition, mapping_efficiency)) + geom_bar(stat="identity") +coord_flip() + ylim(0,100) + ggtitle("mapping efficiency"))

md_plot(ggplot(algnSummary, aes(condition, num_reads)) + geom_bar(stat="identity") + coord_flip() + ggtitle("read counts") +scale_y_continuous(labels=comma))

md_plot(ggplot(algnSummary, aes(condition, mapped_reads)) + geom_bar(stat="identity") + coord_flip() + ggtitle("alignments counts") +scale_y_continuous(labels=comma))


#ggplot(melt(algnSummary), aes(condition, value)) + geom_bar(stat="identity") +facet_wrap(~variable, scales="free") + ggtitle("mapping summary") + scale_y_continuous(labels=comma)  + theme(axis.text.x=element_text(angle=90, hjust=0))
#ggsave2(w=10, h=10, p="mapstats")


md_report("tophat_mapping_report", open=F)
' | R -q --vanilla
}
export -f TophatMappingReport


#### Bowtie Mapping Report from the logs
Bowtie2MappingReport(){

echo '

devtools::source_url("http://dl.dropbox.com/u/113630701/rlibs/base-commons.R")

logSuffix=".logs"
parseAlgnSummary <- function(alignSummary){
    #alignSummary="./H2Az_Rep1_Lane1_Lib4454.bowtie.log"
    algnData <- readLines(alignSummary)

    data.frame(
        condition=trimEnd(basename(alignSummary), logSuffix),
        num_reads=as.numeric(str_split_fixed(algnData[3], " ", 2)[1]),
        unique_mappers=as.numeric(str_split_fixed(str_trim(algnData[6]), " ", 2)[1]),
        mapping_efficiency=as.numeric(str_replace(str_split_fixed(algnData[8], " ", 2)[1], "%", "")),
        multi_mappers=as.numeric(str_split_fixed(str_trim(algnData[7]), " ", 2)[1])
    )
}

mapStats <- ldply(list.files(".", logSuffix, full.names=TRUE, recursive=T), parseAlgnSummary, .progress="text")
write.delim(mapStats, file="mapStats.txt")

ggplot(melt(mapStats), aes(condition, value)) + geom_bar(stat="identity") +facet_wrap(~variable, scales="free") + ggtitle("mapping summary") + scale_y_continuous(labels=comma)  + theme(axis.text.x=element_text(angle=90, hjust=0))
ggsave2(w=10, h=10, p="mapstats")

ggplot(mapStats, aes(condition, mapping_efficiency)) + geom_bar(stat="identity") +coord_flip() + ylim(0,100) + ggtitle("mapping efficiency")
ggsave2(p="mapstats")
ggplot(mapStats, aes(condition, num_reads)) + geom_bar(stat="identity") + coord_flip() + ggtitle("read counts")
ggsave2(p="mapstats")

ggplot(mapStats, aes(condition, unique_mappers)) + geom_bar(stat="identity") + coord_flip() + ggtitle("unique alignment") + scale_fill_discrete()
ggsave2(p="mapstats")
' | R --vanilla
}
export -f Bowtie2MappingReport



### Create a cuffdb on a network of lustre file-systen
MakeCuffDB() {
    if [ $# -ne 2 ]; then echo "Usage: MakeCuffDB <gtffile> <genomebuild>"; return; fi

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
export -f MakeCuffDB

CountSeqs(){
    grep ">" $1 | wc -l
}
export -f CountSeqs
