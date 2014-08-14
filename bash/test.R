devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/core_commons.R")
devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/ggplot_commons.R")




parseAlgnSummary_T2_0_11 <- function(alignSummary){
    #alignSummary="/projects/bioinfo/holger/projects/marta_rnaseq/human_leipzig/mapping/S5382_aRG_1b_rep1/align_summary.txt"
    algnData <- readLines(alignSummary)

    data.frame(
        condition=basename(dirname(alignSummary)),
        num_reads=as.numeric(str_match(algnData[2], " ([0-9]*$)")[,2]),
        mapped_reads=100*as.numeric(str_match(algnData[3], ":[ ]*([0-9]*) ")[,2][1])
    ) %>% transform(mapping_efficiency=mapped_reads/num_reads)
}


algnSummary <- ldply(list.files(".", "align_summary.txt", full.names=TRUE, recursive=T), parseAlgnSummary_T2_0_11, .progress="text")
write.delim(algnSummary, file="tophat_mapping_stats.txt")

scale_fill_discrete <- function (...){ scale_color_brewer(..., type = "seq", palette="Set1", "fill", na.value = "grey50") }


projectName=basename(dirname(getwd()))

ggplot(algnSummary, aes(condition, mapping_efficiency)) + geom_bar(stat="identity") +coord_flip() + ylim(0,100) + ggtitle(concat("mapping efficiency in ", projectName))
ggsave2(width=12)

ggplot(algnSummary, aes(condition, num_reads)) + geom_bar(stat="identity") + coord_flip() + ggtitle(concat("read counts in", projectName)) +scale_y_continuous(labels=comma)
ggsave2(width=12)

ggplot(algnSummary, aes(condition, mapped_reads)) + geom_bar(stat="identity") + coord_flip() + ggtitle(concat("alignments in", projectName)) +scale_y_continuous(labels=comma)
ggsave2(width=12)


ggplot(melt(algnSummary), aes(condition, value)) + geom_bar(stat="identity") +facet_wrap(~variable, scales="free") + ggtitle("mapping summary") + scale_y_continuous(labels=comma)  + theme(axis.text.x=element_text(angle=90, hjust=0))
ggsave2(w=10, h=10, p="mapstats")


