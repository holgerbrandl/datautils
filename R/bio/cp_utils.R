install_package("clusterProfiler")


## todo move to diffex commons
guess_cp_species <- function(ensIds){
    an_id <-ensIds[1]

    if(str_detect(an_id, "ENSG")){
        return("human")
    }else if(str_detect(an_id, "ENSMUSG")){
        return("mouse")
    }else if(str_detect(an_id, "ENSDARG")){
        return("zebrafish")
    }else if(str_detect(an_id, "FBgn")){
        return("fly")
    }else{
        stop(paste("could not clusterProfiler species name from ", an_id))
    }
}

guess_anno_db <- function(ensIds){
    an_id <-ensIds[1]

    if(str_detect(an_id, "ENSG")){
        return("org.Hs.eg.db")
    }else if(str_detect(an_id, "ENSMUSG")){
        return("org.Mm.eg.db")
    }else if(str_detect(an_id, "ENSDARG")){
        return("org.Dr.eg.db")
    }else if(str_detect(an_id, "FBgn")){
        return("org.Dm.eg.db")
    }else{
        stop(paste("could not anno db mart from ", an_id))
    }
}

#source("http://bioconductor.org/biocLite.R")
#biocLite("org.Mm.eg.db")
#biocLite("org.Hs.eg.db")
#biocLite("org.Dr.eg.db")
#biocLite("org.Dm.eg.db")
#biocLite("KEGG.db")



load_pack(ReactomePA)

cp_test <- function(geneIds){
    # DEBUG geneIds <- glMapped %>% filter(cluster %in% c("cluster_9")) %$% entrez_gene_id %>% as.integer
    # DEBUG geneIds <- head(glMapped,30)$entrez_gene_id
    #    geneIds=.$entrez_gene_id

    if(length(geneIds)>1500){
        geneIds <- sample(geneIds) %>% head(1500)
    }

    echo("testing", length(geneIds), " genes for enrichment")

    #    PANTHER10_ontology <- read.delim("http://data.pantherdb.org/PANTHER10.0/ontology/Protein_Class_7.0")

    #    browser()
    #    pantherResults <-     enricher(gene = geneIds, organism = cpSpecies, qvalueCutoff = qCutoff, readable = TRUE, TERM2GENE = PANTHER10_ontology) %>% summary()
    keggResults <-        clusterProfiler::enrichKEGG(gene = geneIds, organism = cpSpecies, qvalueCutoff = qCutoff, use_internal_data=T) %>% summary()
    reactomeResults <-      enrichPathway(gene = geneIds, organism = cpSpecies, qvalueCutoff = qCutoff) %>% summary()
    goResultsCC <-          clusterProfiler::enrichGO(gene = geneIds, OrgDb = annoDb, qvalueCutoff = qCutoff, ont = "CC") %>% summary()
    goResultsMF <-          clusterProfiler::enrichGO(gene = geneIds, OrgDb = annoDb, qvalueCutoff = qCutoff, ont = "MF") %>% summary()
    goResultsBP <-          clusterProfiler::enrichGO(gene = geneIds, OrgDb = annoDb, qvalueCutoff = qCutoff, ont = "BP") %>% summary()

    #cp-bug: if no pathways are enriched odd strucuture is retured ##todo file issue
    if(!("data.frame" %in% class(keggResults))) keggResults <- filter(goResultsBP, Description="foobar")

    enrResults <- bind_rows(
    mutate(keggResults, ontology="kegg"),
    mutate(reactomeResults, ontology="reactome"),
    mutate(goResultsBP, ontology="go_bp"),
    mutate(goResultsMF, ontology="go_mf"),
    mutate(goResultsCC, ontology="go_cc")
    )
    enrResults
    #    echo("numResults", nrow(enrResults))
}


## example
if(F){

someGenes = c("") ## todo continue

cpSpecies <- guess_cp_species(someGenes)
annoDb <- guess_anno_db(someGenes) # e.g. "org.Hs.eg.db"


enrResults <- cp_test(someGenes)
## or for grouped data
#enrResults <-  quote(glMapped %>% do(cp_test(.$entrez_gene_id))) %>% cache_it(paste0("enrdata_", digest(glMapped)))

## test custom ontology
#enrichrFile_TFchip = "/projects/bioinfo/holger/data/enrichr_datasets/ENCODE_TF_ChIP-seq_2015.txt"
#tfChipOnt <- convert_enrichr_cp(enrichrFile_TFchip)

}