
#require(cummeRbund)

getExpressedGenes <- function(cuff, ...){
    fpkmMat<-cummeRbund::repFpkmMatrix(genes(cuff))

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
    }else if(str_detect(an_id, "ENSDARG")){
        return("drerio_gene_ensembl")
    }else if(str_detect(an_id, "ENSG")){
        return("hsapiens_gene_ensembl")
    }else if(str_detect(an_id, "FBgn")){
        return("dmelanogaster_gene_ensembl")
    }else{
        stop(paste("could not guess mart from ", an_id))
    }
}

get_ensembl_build <- function(){
    biomaRt::listMarts() %>% as.data.frame() %>% filter(biomart=="ensembl") %>% with(str_match(version, " ([0-9]*) ")) %>% subset(select=2)
}

guess_pathview_species <- function(gene_id){
    an_id <-gene_id[1]

   ## see http://www.genome.jp/kegg-bin/find_org_www?mode=abbr&obj=mode.map

   if(str_detect(an_id, "ENSMUSG")){
        return("mmu")
    }else if(str_detect(an_id, "ENSDARG")){
        return("dre")
    }else if(str_detect(an_id, "ENSG")){
        return("hsa")
    }else if(str_detect(an_id, "FBgn")){
        return("dme")
    }else{
        stop(paste("could not guess mart from ", an_id))
    }
}
#guess_mart("ENSCAFG00000000043")


retainExprGenes <- function(df, id_col="ensembl_gene_id", ...){
    ## allows to filter for expressed genes

     exprGenes <- df %>% column2rownames(id_col) %>%
        ## see https://github.com/hadley/dplyr/issues/497
        #iris %>% select(., which(sapply(., is.numeric))) %>% head
        select(., which(sapply(., is.numeric))) %>%
        filterByExpression(...) %>%
        rownames()

#    exprGenes %>% head %>% print
#    df %>% filter_(id_col %in% exprGenes)

    ## see http://stackoverflow.com/questions/26492280/non-standard-evaluation-nse-in-dplyrs-filter-pulling-data-from-mysql
    which_column <- get(id_col, df)
    df %>% filter_(~ which_column %in% exprGenes)
}



getGeneInfo <- function(gene_ids){
    martName <- guess_mart(gene_ids[1])

    cacheFile <- paste0("geneInfo.",martName, ".RData")

    if(!file.exists(cacheFile)){
        require(biomaRt)

        mousemart = useDataset(martName, mart=useMart("ensembl"))
        geneInfo <- getBM(attributes=c('ensembl_gene_id', 'external_gene_name', 'description', 'gene_biotype'), mart=mousemart);
        save(geneInfo, file=cacheFile)
        unloadNamespace('biomaRt')
    }else{
        geneInfo <- local(get(load(cacheFile)))
    }

    return(geneInfo)
}



########################################################################################################################
### Hit list interscection utilities (see e.g Helin project for examples)



extractHits <- function(deData, s1, s2, s1Overexpressed=T){
  # note one of the two sets will always be empty; Example:  s1="small_cyst"; s2="liver_polar_stage1"
  forward <- subset(deData, sample_1==s1 & sample_2==s2 & sample_1_overex==s1Overexpressed)  %$% ac(gene_id)
  reverse <- subset(deData, sample_1==s2 & sample_2==s1 & sample_1_overex==!s1Overexpressed) %$% ac(gene_id)

  return(c(forward, reverse))
}


## genes that are significantly higher expressed in sample1 compared to sample2
s1_gt_s2 <- function(deData, sample_1, sample_2){
    extractHits(deData, sample_1, sample_2, s1Overexpressed=T) %>%
        data_frame(gene_id=., list_id = paste(sample_1, ">", sample_2))

}

## genes that are significantly less expressed in sample1 compared to sample2
s1_lt_s2 <- function(deData, sample_1, sample_2){
    extractHits(deData, sample_1, sample_2, s1Overexpressed=F) %>%
        data_frame(gene_id=., list_id = paste(sample_1, "<", sample_2))
}

## undirected, just differentially expressed
s1_de_s2 <- function(deData, sample_1, sample_2){
    c(extractHits(deData, sample_1, s2, s1Overexpressed=F), extractHits(deData, s1, sample_2, s1Overexpressed=T)) %>%
        data_frame(gene_id=., list_id = paste(sample_1, "!=", sample_2))
}

## not differentially expressed
s1_eq_s2 <- function(deData, sample_1, sample_2, gene_background=all_genes){
    c(
        extractHits(deData, sample_1, sample_2, s1Overexpressed=F, ...),
        extractHits(deData, sample_1, sample_2, s1Overexpressed=T, ...)
    ) %>%
        setdiff(gene_background, .) %>%
        mutate(list_id = paste(sample_1, "==", sample_2))
}


diff_intersect <- function(deData, sample_1, sample_twoes, .intersect_method, ...){
    ## Example: diff_intersect(degs, "VZ", c("ISVZ", "OSVZ", "CP"), s1_gt_s2)

#   rec_intersect sample_twoes = list(...)
#    sample_twoes <- list(); sample_1="VZ"
#browser()
    rec_intersect <- .intersect_method(deData, sample_1, sample_twoes[1], ...)$gene_id

    for (i in 2:length(sample_twoes)) {
        rec_intersect <- intersect(rec_intersect, .intersect_method(deData, sample_1, sample_twoes[i], ...)$gene_id)
    }


    ## try to add a list id column
    if(identical(.intersect_method, s1_gt_s2)){
       list_id = paste(sample_1, ">", paste(sample_twoes, collapse=","))
    }else if(identical(.intersect_method, s1_lt_s2)){
       list_id = paste(sample_1, "<", paste(sample_twoes, collapse=","))
    }else if(identical(.intersect_method, s1_de_s2)){
        list_id = paste(sample_1, "!=", paste(sample_twoes, collapse=","))
    }else if(identical(.intersect_method, s1_eq_s2)){
         list_id = paste(sample_1, "==", paste(sample_twoes, collapse=","))
    }else{
      list_id = paste(sample_1, "vs", paste(sample_twoes, collapse=","))
       warning("could not determine list id type. using generic id")
    }

    ## todo maybe it's better to return an empty table here and use factors to indicate the level without genes
    ## to make sure that we don't loose an empty list, use NA as placeholder
    if(length(rec_intersect)==0) rec_intersect=NA;

    data_frame(gene_id=rec_intersect, list_id=list_id);
}





## todo add helper to test for equality (s1 and s2 not differentially expressed)
## from marta:
#s1_eq_s2 <- function(s1, s2, degData=degs) subset(degData, sample_1==s1 & sample_2==s2 & sample_1_overex==F)$gene_id
#AeqBexpr <-subset(allDiff, sample_1=="aRG" & sample_2=="bRG") %>% filter(pmin(value_1, value_2)>1) %>% filter(!isHit)
#hitdata <- rbind(hitdata, data.frame(ensembl_gene_id=AeqBexpr$gene_id, set="aRG==bRG"))


## varargs: http://stackoverflow.com/questions/3057341/how-to-use-rs-ellipsis-feature-when-writing-your-own-function
## DEPRECATED
rintersect <- function(...){
    LDF <- list(...)
    rintersect.list(LDF)
}


rintersect.list <- function(LDF){
    rec_intersect <- LDF[[1]]
    for (i in 2:length(LDF)) {
        rec_intersect <- intersect(rec_intersect, LDF[[i]])
    }
    rec_intersect
}


########################################################################################################################
### enrichment analysis


## http://www.bioconductor.org/packages/release/bioc/vignettes/RDAVIDWebService/inst/doc/RDavidWS-vignette.pdf
## e.g. getClusterReport --> plot2D

DEF_DAVID_ONTOLOGIES=ontologies=c("GOTERM_CC_FAT", "GOTERM_MF_FAT", "GOTERM_BP_FAT", "PANTHER_PATHWAY", "PANTHER_FAMILY", "PANTHER_PATHWAY", "KEGG_PATHWAY", "REACTOME_PATHWAY")

davidAnnotationChart <- function( someGenes, ontologies=DEF_DAVID_ONTOLOGIES ){

    require.auto(RDAVIDWebService) ## just works if installed on non-network-drive (e.g. /tmp/)

    ## expexted to have a column with gene_id
#    echo("processing list with", length(someGenes), "genes")
#    someGenes <- degs$ensembl_gene_id[1:100]


    if(length(someGenes)>1500){
        someGenes <- sample(someGenes) %>% head(1500)
    }

    david<-DAVIDWebService$new(email="brandl@mpi-cbg.de")

#    ## list all ontologies
#    getAllAnnotationCategoryNames(david)


#    getTimeOut(david)
    setTimeOut(david, 80000) ## http://www.bioconductor.org/packages/release/bioc/vignettes/RDAVIDWebService/inst/doc/RDavidWS-vignette.pdf

    result<-addList(david, someGenes, idType="ENSEMBL_GENE_ID", listName=paste0("list_", sample(10000)[1]), listType="Gene")

    david %>% setAnnotationCategories(ontologies)

    annoChart <-getFunctionalAnnotationChart(david)

#    clusterReport <-getClusterReport(david)

    unloadNamespace('RDAVIDWebService')

    ## remove gene colum
#    browser()
    annoChart <- as.data.frame(unclass(annoChart))

    # http://stackoverflow.com/questions/25271856/cannot-coerce-class-typeof-is-double-to-a-data-frame
#    if(nrow(annoChart) >0) annoChart <-  annoChart %>%  dplyr::select(select=-Genes)

    return(annoChart)
}

