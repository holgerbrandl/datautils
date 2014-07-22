
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
