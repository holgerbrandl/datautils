#library(BiocGenerics, quietly=T, warn.conflicts=F )
#library(Biostrings, quietly=T)
#require.auto(BiocGenerics )x

require.auto(Biostrings)


read.fasta <- function(fileName){
    ## read a fasta file as data.fram

    fastaData <- readBStringSet(fileName, "fasta")
    #	fastaDataDF <- as.data.frame(as.character(fastaData), stringsAsFactors=FALSE)
    fastaDataDF <- data.frame(Sequence=as.character(fastaData), GeneDesc=names(fastaData), stringsAsFactors=FALSE)
    rownames(fastaDataDF) <- NULL
    #	names(fastaDataDF)[1] <- "Sequence"
    return(fastaDataDF)
}

getSeqLengthFromFasta <- function(fileName){
    assembly <- mutate(read.fasta(fileName), seq_len=nchar(Sequence))
    assembly$Sequence = NULL
    return(assembly)
}


write.fasta <- function(seq_names, sequences, file){
    fastaData <- AAStringSet(sequences)
    names(fastaData) <- seq_names;
    writeXStringSet(fastaData, file=file, format="fasta", width=80)
}

