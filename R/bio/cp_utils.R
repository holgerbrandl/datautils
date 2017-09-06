install_package("clusterProfiler")


## species names according to http://www.genome.jp/kegg/catalog/org_list.html
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


## todo how to guess yeast ("org.Sc.sgd.db") from id?
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

## see http://bioconductor.org/packages/release/BiocViews.html#___OrgDb
#source("http://bioconductor.org/biocLite.R")
#biocLite("org.Mm.eg.db")
#biocLite("org.Hs.eg.db")
#biocLite("org.Dr.eg.db")
#biocLite("org.Dm.eg.db")
#biocLite("org.Sc.sgd.db")
#biocLite("KEGG.db")
#biocLite("ReactomePA")



#load_pack(ReactomePA)


## clusterProfiler convenience wrapper for ensembl ids
find_enr_terms = function(ensemblIds, ...){
    #browser()
    annoDb = guess_anno_db(ensemblIds)
    clusterProfiler::bitr(ensemblIds, fromType="ENSEMBL", toType="ENTREZID", OrgDb=annoDb) %>%
        with(cp_test(ENTREZID, annoDb=annoDb, cp_species=guess_cp_species(ensemblIds), ...))
}


## does not work because of dots
#find_enr_terms_cached = function(ensemblIds, ...){
#    quote({find_enr_terms(ensemblIds, ...)}) %>% cache_it(paste0("cp_id_cache", digest(ensemblIds)))
#}

#' TODO remove necessity for cp_species
geneIds = glMapped %>% first() %>% pull(entrez_gene_id)

cp_test = function(geneIds, annoDb, cp_species, q_cutoff=0.05){
    # DEBUG geneIds <- glMapped %>% filter(cluster %in% c("cluster_9")) %$% entrez_gene_id %>% as.integer
    # DEBUG geneIds <- glMapped %>% filter(cluster_id %in% c("nr1")) %$% entrez_gene_id %>% as.integer
    # DEBUG geneIds <- head(glMapped,30)$entrez_gene_id
    # DEBUG geneIds <- glMapped %>% ungroup %>% filter(contrast==contrast[1])$entrez_gene_id
    #    geneIds=.$entrez_gene_id

    if(length(geneIds)>1500){
        geneIds <- sample(geneIds) %>% head(1500)
    }

    echo("testing", length(geneIds), " genes for enrichment")

    #    PANTHER10_ontology <- read.delim("http://data.pantherdb.org/PANTHER10.0/ontology/Protein_Class_7.0")
    #    pantherResults <-     enricher(gene = geneIds, organism = cp_species, qvalueCutoff = q_cutoff, readable = TRUE, TERM2GENE = PANTHER10_ontology) %>% summary()

    # keggResults <-          clusterProfiler::enrichKEGG(gene = geneIds, organism = cp_species, qvalueCutoff = q_cutoff, use_internal_data=T) %>% as.data.frame()
    keggResults <-          clusterProfiler::enrichKEGG(gene = geneIds, organism = cp_species, keyType="ncbi-geneid", qvalueCutoff = q_cutoff) %>% as.data.frame()
    reactomeResults <-      ReactomePA::enrichPathway(gene = geneIds, organism = cp_species, qvalueCutoff = q_cutoff, readable = TRUE) %>% as.data.frame()
    goResultsCC <-          clusterProfiler::enrichGO(gene = geneIds, OrgDb = annoDb, qvalueCutoff = q_cutoff, ont = "CC", readable = TRUE) %>% as.data.frame()
    goResultsMF <-          clusterProfiler::enrichGO(gene = geneIds, OrgDb = annoDb, qvalueCutoff = q_cutoff, ont = "MF", readable = TRUE) %>% as.data.frame()
    goResultsBP <-          clusterProfiler::enrichGO(gene = geneIds, OrgDb = annoDb, qvalueCutoff = q_cutoff, ont = "BP", readable = TRUE) %>% as.data.frame()

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


## example usage
if(F){

devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.33/R/core_commons.R")
devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/bio/cp_utils.R")


someGenes = c("ENSMUSG00000002014", "ENSMUSG00000002015", "ENSMUSG00000008892",
"ENSMUSG00000015733", "ENSMUSG00000020720", "ENSMUSG00000020869",
"ENSMUSG00000022884", "ENSMUSG00000026202", "ENSMUSG00000026276",
"ENSMUSG00000028648", "ENSMUSG00000030432", "ENSMUSG00000030894",
"ENSMUSG00000032249", "ENSMUSG00000038286", "ENSMUSG00000038965",
"ENSMUSG00000038991")

## using ensembl conveience wrapper
#enrResults = find_enr_terms_cached(someGenes)
enrResults = find_enr_terms(someGenes)

## or the old-style way:
cpSpecies <- guess_cp_species(someGenes)
annoDb <- guess_anno_db(someGenes) # e.g. "org.Hs.eg.db"
enrResults <- cp_test(someGenes)

## or for grouped data
#enrResults <-  quote(glMapped %>% do(cp_test(.$entrez_gene_id))) %>% cache_it(paste0("enrdata_", digest(glMapped)))

## test custom ontology
#enrichrFile_TFchip = "/projects/bioinfo/holger/data/enrichr_datasets/ENCODE_TF_ChIP-seq_2015.txt"
#tfChipOnt <- convert_enrichr_cp(enrichrFile_TFchip)



}