
#### Tophat Mapping Report from the logs
TophatMappingReport(){
## todo replace source with simple R script as for bowtie-report
echo '
devtools::source_url("http://dl.dropbox.com/u/113630701/rlibs/deepseq/ngs_tools.R")
createMappingReport()
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


