
require(cummeRbund)


getExpressedGenes <- function(cuff, ...){
    fpkmMat<-repFpkmMatrix(genes(cuff))

    rownames(filterByExpression(fpkmMat, ...))
}


filterByExpression <- function(fpkmMat, minFPKM=1, logMode=F){
    if(logMode) fpkmMat<-log10(fpkmMat+1) ## add a pseudocount

    geneMax <- apply(fpkmMat, 1, max)

    fpkmMat[geneMax>minFPKM,]
}


guess_mart <- function(gene_id){
    an_id <-gene_id[1]
    if(str_detect(an_id, "ENSCAFG")){
        return("cfamiliaris_gene_ensembl")
    }else if(str_detect(an_id, "ENSMUSG")){
        return("mmusculus_gene_ensembl")
    }else if(str_detect(an_id, "ENSG")){
        return("hsapiens_gene_ensembl")
    }else{
        stop(paste("could not guess mart from ", an_id))
    }
}
#guess_mart("ENSCAFG00000000043")
