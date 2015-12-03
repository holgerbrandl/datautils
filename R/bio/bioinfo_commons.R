#library(BiocGenerics, quietly=T, warn.conflicts=F )
#library(Biostrings, quietly=T)
#require_auto(BiocGenerics )x

require_auto(Biostrings)


read.fasta <- function(fileName){
    ## read a fasta file as data.fram

    fastaData <- readBStringSet(fileName, "fasta")
    #	fastaDataDF <- as.data.frame(as.character(fastaData), stringsAsFactors=FALSE)
    fastaDataDF <- data.frame(Sequence=as.character(fastaData), GeneDesc=names(fastaData), stringsAsFactors=FALSE)
    rownames(fastaDataDF) <- NULL
    #	names(fastaDataDF)[1] <- "Sequence"
    return(fastaDataDF)
}


write.fasta <- function(seq_names, sequences, file){
    fastaData <- AAStringSet(sequences)
    names(fastaData) <- seq_names;
    writeXStringSet(fastaData, file=file, format="fasta", width=80)
}


getSeqLengthFromFasta <- function(fileName){
    assembly <- mutate(read.fasta(fileName), seq_len=nchar(Sequence))
    assembly$Sequence = NULL
    return(assembly)
}


## necessary to disable scientific number formats for long integers
#options(scipen=100)

## writes a table in bed format expecting columns being ordered according to bed spec already
#write.bed <- function(bedData, file){
#    write.table(bedData, file=file, quote=FALSE, sep ="\t", na="NA", row.names=FALSE, col.names=FALSE)
#}

write_bed <- function(bedData, file) write.bed(bedData, file)

write.bed <- function(bedData, file){
    oldScipen<-getOption("scipen")

     ## necessary to disable scientific number formats for long integers
    options(scipen=100)

    write.table(bedData, file=file, quote=FALSE, sep ="\t", na="NA", row.names=FALSE, col.names=FALSE)

    ## restore old scipen value
    options(scipen=oldScipen)
}

## reload to fix rename overloading
unloadNamespace('dplyr'); require(dplyr)
