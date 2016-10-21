#library(BiocGenerics, quietly=T, warn_conflicts=F )
#library(Biostrings, quietly=T)
#require_auto(BiocGenerics x

#load_pack(Biostrings)

## install Biostrings if not yet there
install_package("Biostrings")


read.fasta <- function(fileName){
    warning("Deprecated: use read_fasta instead!")
    read_fasta(fileName)
}


read_fasta <- function(fileName){
    ## read a fasta file as data.fram

    fastaData <- Biostrings::readBStringSet(fileName, "fasta")
    #	fastaDataDF <- as.data.frame(as.character(fastaData), stringsAsFactors=FALSE)
    fastaDataDF <- data.frame(Sequence=as.character(fastaData), GeneDesc=names(fastaData), stringsAsFactors=FALSE)
    rownames(fastaDataDF) <- NULL
    #	names(fastaDataDF)[1] <- "Sequence"
    return(fastaDataDF)
}



write.fasta <- function(fileName){
    warning("Deprecated: use write_fasta instead!")
    write_fasta(fileName)
}


write_fasta <- function(seq_names, sequences, file){
    fastaData <- Biostrings::AAStringSet(sequences)
    names(fastaData) <- seq_names;
    Biostrings::writeXStringSet(fastaData, file=file, format="fasta", width=80)
}


get_sequence_lengths <- function(fileName){
    assembly <- mutate(read_fasta(fileName), seq_len=nchar(Sequence))
    assembly$Sequence = NULL
    return(assembly)
}


## necessary to disable scientific number formats for long integers
#options(scipen=100)

## writes a table in bed format expecting columns being ordered according to bed spec already
#write.bed <- function(bedData, file){
#    write.table(bedData, file=file, quote=FALSE, sep ="\t", na="NA", row.names=FALSE, col.names=FALSE)
#}

write_bed <- function(bedData, file){
    oldScipen<-getOption("scipen")

    ## necessary to disable scientific number formats for long integers
    options(scipen=100)

    write.table(bedData, file=file, quote=FALSE, sep ="\t", na="NA", row.names=FALSE, col.names=FALSE)

    ## restore old scipen value
    options(scipen=oldScipen)

}

## reload to fix rename overloading
#reload_dplyr()



fetch_go_term = function(termId){
    paste0("http://golr.geneontology.org/select?defType=edismax&qt=standard&indent=on&wt=csv&rows=100000&start=0&fl=source,bioentity_internal_id,bioentity_label,qualifier,annotation_class,reference,evidence_type,evidence_with,aspect,bioentity_name,synonym,type,taxon,date,assigned_by,annotation_extension_class,bioentity_isoform&facet=true&facet.mincount=1&facet.sort=count&json.nl=arrarr&facet.limit=25&csv.encapsulator=&csv.separator=%09&csv.header=false&csv.mv.separator=%7C&fq=document_category:%22annotation%22&fq=regulates_closure:%22",termId, "%22&facet.field=aspect&facet.field=taxon_subset_closure_label&facet.field=evidence_subset_closure_label&facet.field=regulates_closure_label&facet.field=annotation_class_label&facet.field=qualifier&facet.field=annotation_extension_class_closure_label&facet.field=assigned_by&facet.field=panther_family_label&q=*:*") %>% read_tsv(col_names=F) %>%
    set_names("source", "bioentity_internal_id", "bioentity_label", "qualifier", "annotation_class", "reference", "evidence_type", "evidence_with", "aspect", "bioentity_name", "synonym", "type", "taxon", "date", "assigned_by", "annotation_extension_class", "bioentity_isoform") %>% filter_count(source=="UniProtKB") %>% rename(uniprot_id= bioentity_internal_id)
}

## example
#ndc80 = fetch_go_term("GO:0031262")


read_bm = function(query){
    query %>% paste0("wget -O - 'http://www.ensembl.org/biomart/martservice?query=", . , "' 2>/dev/null") %>% pipe %>% read_tsv %>% pretty_columns
}

## example
#ndc80Ens = read_bm('<?xml version="1.0" encoding="UTF-8"?>
#<!DOCTYPE Query>
#<Query  virtualSchemaName = "default" formatter = "TSV" header = "1" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" >
#<Dataset name = "hsapiens_gene_ensembl" interface = "default" >
#<Filter name = "go_parent_term" value = "GO:0031262"/>
#<Attribute name = "ensembl_gene_id" />
#<Attribute name = "description" />
#<Attribute name = "uniprot_genename" />
#<Attribute name = "external_gene_name" />
#</Dataset>
#</Query>')

