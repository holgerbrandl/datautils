
require.auto(cummeRbund)



getExpressedGenes <- function(cuff, minFPKM=1, logMode=F){
    fpkmMat<-repFpkmMatrix(genes(mmusCuff))

    if(logMode) fpkmMat<-log10(fpkmMat+1) ## add a pseudocount

    geneMax <- apply(fpkmMat, 1, max)

    rownames(fpkmMat[geneMax>minFPKM,])
}
