install_package("clusterProfiler")

.is_yeast = function(someIds){
    y_prefix_prop = str_sub(someIds,1,1) %>% {sum(.=="Y")/length(.)}
    length_7_prop = str_length(someIds) %>% {sum(.==7)/length(.)}
    y_prefix_prop> 0.8 & length_7_prop > 0.8
}

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
    }else if(.is_yeast(ensIds)){
        return("yeast")
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
    }else if(.is_yeast(ensIds)){
        return("org.Sc.sgd.db")
    }else{
        stop(paste("could not anno db mart from ", an_id))
    }
}

#guess_mart("ENSCAFG00000000043")


guess_pathview_species <- function(ensIds){
    an_id <-ensIds[1]

    ## see http://www.genome.jp/kegg-bin/find_org_www?mode=abbr&obj=mode.map

    if(str_detect(an_id, "ENSMUSG")){
        return("mmu")
    }else if(str_detect(an_id, "ENSDARG")){
        return("dre")
    }else if(str_detect(an_id, "ENSG")){
        return("hsa")
    }else if(str_detect(an_id, "FBgn")){
        return("dme")
    }else if(.is_yeast(ensIds)){
        return("sce")
    }else{
        stop(paste("could not guess mart from ", an_id))
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
# geneIds = glMapped %>% first() %>% pull(entrez_gene_id)

cp_test = function(geneIds, annoDb, cp_species, q_cutoff=0.05){
    # DEBUG geneIds <- glMapped %>% filter(cluster %in% c("cluster_9")) %$% entrez_gene_id %>% as.integer
    # DEBUG geneIds <- glMapped %>% filter(cluster_id %in% c("nr1")) %$% entrez_gene_id %>% as.integer
    # DEBUG geneIds <- head(glMapped,30)$entrez_gene_id
    # DEBUG geneIds <- glMapped %>% ungroup %>% filter(contrast==contrast[1])$entrez_gene_id
    #    geneIds=.$entrez_gene_id

    if(length(geneIds)>1500){
        geneIds <- sample(geneIds) %>% head(1500)
    }

    ## disable gene symbols output for yeast because it's not supported by undlying annotation db
    ## see also https://github.com/GuangchuangYu/clusterProfiler/issues/91
    readable=cp_species!="yeast"

    # browser()

    echo("testing", length(geneIds), " genes for enrichment")

    #    PANTHER10_ontology <- read.delim("http://data.pantherdb.org/PANTHER10.0/ontology/Protein_Class_7.0")
    #    pantherResults <-     enricher(gene = geneIds, organism = cp_species, qvalueCutoff = q_cutoff, readable = TRUE, TERM2GENE = PANTHER10_ontology) %>% summary()

    # keggResults <-          clusterProfiler::enrichKEGG(gene = geneIds, organism = cp_species, qvalueCutoff = q_cutoff, use_internal_data=T) %>% as.data.frame()
    keggResults <-          clusterProfiler::enrichKEGG(gene = geneIds, organism = cp_species, keyType="ncbi-geneid", qvalueCutoff = q_cutoff) %>% as.data.frame()
    reactomeResults <-      ReactomePA::enrichPathway(gene = geneIds, organism = cp_species, qvalueCutoff = q_cutoff, readable = readable) %>% as.data.frame()
    goResultsCC <-          clusterProfiler::enrichGO(gene = geneIds, OrgDb = annoDb, qvalueCutoff = q_cutoff, ont = "CC", readable = readable) %>% as.data.frame()
    goResultsMF <-          clusterProfiler::enrichGO(gene = geneIds, OrgDb = annoDb, qvalueCutoff = q_cutoff, ont = "MF", readable = readable) %>% as.data.frame()
    goResultsBP <-          clusterProfiler::enrichGO(gene = geneIds, OrgDb = annoDb, qvalueCutoff = q_cutoff, ont = "BP", readable = readable) %>% as.data.frame()

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



########################################################################################################################
########################################################################################################################
########################################################################################################################

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
#enrichrFile_TFchip = "/projects/bioinfo/brandl/data/enrichr_datasets/ENCODE_TF_ChIP-seq_2015.txt"
#tfChipOnt <- convert_enrichr_cp(enrichrFile_TFchip)
}


### Yeast Example
if(F){

# devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.42/R/core_commons.R")
devtools::source_url("https://www.dropbox.com/s/r6kim8kb8ohmptx/core_commons.R?dl=1")

# devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.42/R/bio/cp_utils.R")
devtools::source_url("https://www.dropbox.com/s/p2b8luxf7jteb63/cp_utils.R?dl=1")


# dput(geneLists %>% first_group() %$% ensembl_gene_id)
someGenes = c("YAL012W", "YAL039C", "YBL027W", "YBL028C", "YBL030C", "YBL045C",
"YBL059W", "YBR003W", "YBR054W", "YBR058C-A", "YBR078W", "YBR084C-A",
"YBR111W-A", "YBR120C", "YBR194W", "YBR255C-A", "YBR279W", "YCL005W-A",
"YCL025C", "YCL030C", "YCL037C", "YCR024C-A", "YCR053W", "YCR077C",
"YDL005C", "YDL080C", "YDL141W", "YDL168W", "YDL173W", "YDL181W",
"YDL182W", "YDL191W", "YDL202W", "YDL226C", "YDL237W", "YDR041W",
"YDR061W", "YDR083W", "YDR086C", "YDR098C", "YDR099W", "YDR238C",
"YDR248C", "YDR276C", "YDR345C", "YDR373W", "YDR380W", "YDR382W",
"YDR431W", "YDR450W", "YDR451C", "YDR470C", "YDR471W", "YDR476C",
"YDR497C", "YDR500C", "YDR510W", "YDR511W", "YDR529C", "YDR533C",
"YEL027W", "YEL054C", "YEL061C", "YER021W", "YER042W", "YER043C",
"YER081W", "YER091C", "YER110C", "YER127W", "YER139C", "YFL034C-A",
"YFL039C", "YFR005C", "YFR010W", "YFR028C", "YFR032C-A", "YFR040W",
"YFR051C", "YFR055W", "YGL031C", "YGL040C", "YGL062W", "YGL106W",
"YGL147C", "YGL200C", "YGL234W", "YGL241W", "YGR027C", "YGR037C",
"YGR052W", "YGR061C", "YGR063C", "YGR088W", "YGR090W", "YGR172C",
"YGR178C", "YGR204W", "YGR254W", "YHL017W", "YHL047C", "YHR001W-A",
"YHR007C", "YHR010W", "YHR021C", "YHR038W", "YHR051W", "YHR069C",
"YHR070W", "YHR094C", "YHR117W", "YHR138C", "YHR141C", "YIL009W",
"YIL053W", "YIL064W", "YIL148W", "YIL155C", "YJL001W", "YJL144W",
"YJL164C", "YJL173C", "YJL218W", "YJR008W", "YJR009C", "YJR048W",
"YJR063W", "YJR068W", "YJR090C", "YJR123W", "YJR133W", "YJR161C",
"YKL006W", "YKL013C", "YKL019W", "YKL023W", "YKL038W", "YKL043W",
"YKL047W", "YKL060C", "YKL096W-A", "YKL139W", "YKL175W", "YKL186C",
"YKR038C", "YKR049C", "YKR068C", "YKR080W", "YLL045C", "YLL050C",
"YLL061W", "YLR011W", "YLR027C", "YLR048W", "YLR058C", "YLR061W",
"YLR104W", "YLR199C", "YLR215C", "YLR259C", "YLR264W", "YLR287C-A",
"YLR355C", "YLR359W", "YLR363C", "YLR367W", "YLR388W", "YLR401C",
"YLR407W", "YLR410W", "YLR413W", "YLR431C", "YLR438C-A", "YML014W",
"YML027W", "YML072C", "YML073C", "YML092C", "YML124C", "YML126C",
"YML127W", "YMR002W", "YMR052W", "YMR098C", "YMR120C", "YMR131C",
"YMR158W", "YMR197C", "YMR200W", "YMR242C", "YMR243C", "YMR300C",
"YMR318C", "YNL003C", "YNL031C", "YNL036W", "YNL037C", "YNL041C",
"YNL058C", "YNL066W", "YNL084C", "YNL112W", "YNL115C", "YNL118C",
"YNL119W", "YNL162W", "YNL201C", "YNL248C", "YNL255C", "YNR001C",
"YNR007C", "YNR020C", "YNR041C", "YNR050C", "YOL086C", "YOL092W",
"YOL121C", "YOL127W", "YOR003W", "YOR008C", "YOR020C", "YOR076C",
"YOR077W", "YOR078W", "YOR096W", "YOR122C", "YOR132W", "YOR141C",
"YOR182C", "YOR221C", "YOR326W", "YOR367W", "YOR369C", "YPL014W",
"YPL015C", "YPL052W", "YPL079W", "YPL090C", "YPL106C", "YPL134C",
"YPL135W", "YPL143W", "YPL163C", "YPL195W", "YPL215W", "YPL218W",
"YPL240C", "YPL274W", "YPR002W", "YPR037C", "YPR097W", "YPR101W",
"YPR102C", "YPR133C", "YPR133W-A", "YPR167C")

annoDb = guess_anno_db(ensemblIds)
entrezMapped = clusterProfiler::bitr(ensemblIds, fromType="ENSEMBL", toType="ENTREZID", OrgDb=annoDb)



## the old-style way:
cpSpecies <- guess_cp_species(someGenes)
annoDb <- guess_anno_db(someGenes) # e.g. "org.Hs.eg.db"
enrResults <- cp_test(entrezMapped$ENTREZID, annoDb=annoDb, cp_species=cpSpecies)


goResultsCC = clusterProfiler::enrichGO(gene = entrezMapped$ENTREZID, OrgDb = "org.Sc.sgd.db", keytype = "ENTREZID", ont = "CC") %>% as.data.frame()
args(clusterProfiler::enrichGO)


## this works as well:
org.Sc.sgd.db


## related to https://github.com/GuangchuangYu/clusterProfiler/issues/91
columns(org.Sc.sgd.db)
columns(org.Mm.eg.db)

load_pack(VennDiagram)
vPlot <- venn.diagram(x = list(mouse=columns(org.Mm.eg.db), yeast=columns(org.Sc.sgd.db)), filename = NULL, fill = c("cornflowerblue", "darkorchid1"), euler.d=T, scaled=T)
grid.newpage(); grid.draw(vPlot)

which(columns(org.Mm.eg.db)=="SYMBOL")
which(columns(org.Sc.sgd.db)=="SYMBOL")

    ##  .. or using ensembl conveience wrapper
enrResults = find_enr_terms(someGenes)

# dput(glMapped %>% first_group %$% entrez_gene_id)
someEntrez = c("851221", "851192", "852254", "852379", "852253", "852250",
"852235", "852221", "852288", "852343", "852350", "852370", "852254",
"852379", "1466445", "852417", "852493", "852558", "852582",
"2732686", "850333", "850327", "850320", "850389", "850420",
"850440", "851559", "851479", "851414", "851386", "851381", "851347",
"851346", "851336", "851419", "851325", "851372", "851361", "851611",
"851633", "851656", "851659", "851672", "851676", "851824", "851835",
"851869", "851946", "851979", "851987", "851990", NA, "854982",
"852061", "852062", "852081", "852082", "852087", "852108", "852111",
"852122", "852123", "852142", "852146", "856686", "852026", "856656",
"856648", "856742", "856765", "856766", "856814", "856825", "856846",
"856864", "856882", "850509", "850504", "850555", "850562", "850585")


args(clusterProfiler::enrichGO)
goResultsCC = clusterProfiler::enrichGO(gene = someEntrez, OrgDb = "org.Sc.sgd.db", keytype = "ENTREZID", ont = "CC") %>% as.data.frame()

}