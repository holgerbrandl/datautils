
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



### Hit List Interscection Utilitities (see e.g Helin project for examples)



extractHits <- function(s1, s2, s1Overexpressed=T, degData=degs){
  # note one of the two sets will always be empty; Example:  s1="small_cyst"; s2="liver_polar_stage1"
  forward <- subset(degData, sample_1==s1 & sample_2==s2 & sample_1_overex==s1Overexpressed)$ensembl_gene_id %>% ac()
  reverse <- subset(degData, sample_1==s2 & sample_2==s1 & sample_1_overex==!s1Overexpressed)$ensembl_gene_id %>% ac()

  return(c(forward, reverse))
}


s1_gt_s2 <- function(s1, s2, ...) extractHits(s1, s2, s1Overexpressed=T, ...)
s1_lt_s2 <- function(s1, s2, ...) extractHits(s1, s2, s1Overexpressed=F, ...)
s1_ne_s2 <- function(s1, s2, ...) c(extractHits(s1, s2, s1Overexpressed=F, ...), extractHits(s1, s2, s1Overexpressed=T, ...))


## todo add helper to test for equality (s1 and s2 not differentially expressed)
## from marta:
#s1_eq_s2 <- function(s1, s2, degData=degs) subset(degData, sample_1==s1 & sample_2==s2 & sample_1_overex==F)$gene_id
#AeqBexpr <-subset(allDiff, sample_1=="aRG" & sample_2=="bRG") %>% filter(pmin(value_1, value_2)>1) %>% filter(!isHit)
#hitdata <- rbind(hitdata, data.frame(ensembl_gene_id=AeqBexpr$gene_id, set="aRG==bRG"))


rintersect <- function(...){
    LDF <- list(...)
    rec_intersect <- LDF[[1]]
    for (i in 2:length(LDF)) {
        rec_intersect <- intersect(rec_intersect, LDF[[i]])
    }
    rec_intersect
}


