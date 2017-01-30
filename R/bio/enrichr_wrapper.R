
## this needs to be refreshed once in a while (source http://amp.pharm.mssm.edu/Enrichr/#stats)
.ENRICHR_ONTOLOGIES = c("Achilles_fitness_decrease", "Achilles_fitness_increase", "Aging_Perturbations_from_GEO_down", "Aging_Perturbations_from_GEO_up", "Allen_Brain_Atlas_down", "Allen_Brain_Atlas_up", "BioCarta_2013", "BioCarta_2015", "BioCarta_2016", "Cancer_Cell_Line_Encyclopedia", "ChEA_2013", "ChEA_2015", "Chromosome_Location", "CORUM", "dbGaP", "Disease_Perturbations_from_GEO_down", "Disease_Perturbations_from_GEO_up", "Disease_Signatures_from_GEO_down_2014", "Disease_Signatures_from_GEO_up_2014", "Drug_Perturbations_from_GEO_2014", "Drug_Perturbations_from_GEO_down", "Drug_Perturbations_from_GEO_up", "ENCODE_and_ChEA_Consensus_TFs_from_ChIP", "ENCODE_Histone_Modifications_2013", "ENCODE_Histone_Modifications_2015", "ENCODE_TF_ChIP-seq_2014	", "ENCODE_TF_ChIP-seq_2015", "Epigenomics_Roadmap_HM_ChIP", "ESCAPE", "Genes_Associated_with_NIH_Grants", "GeneSigDB", "Genome_Browser_PWMs", "GO_Biological_Process_2013", "GO_Biological_Process_2015", "GO_Cellular_Component_2013", "GO_Cellular_Component_2015", "GO_Molecular_Function_2013", "GO_Molecular_Function_2015", "GTEx_Tissue_Sample_Gene_Expression_Profiles_down", "GTEx_Tissue_Sample_Gene_Expression_Profiles_up", "HMDB_Metabolites", "HomoloGene", "Human_Gene_Atlas", "Human_Phenotype_Ontology", "HumanCyc_2015", "Humancyc_2016", "KEA_2013", "KEA_2015", "KEGG_2013", "KEGG_2015", "KEGG_2016", "Kinase_Perturbations_from_GEO_down", "Kinase_Perturbations_from_GEO_up", "Ligand_Perturbations_from_GEO_down", "Ligand_Perturbations_from_GEO_up", "LINCS_L1000_Chem_Pert_down", "LINCS_L1000_Chem_Pert_up", "LINCS_L1000_Kinase_Perturbations_down", "LINCS_L1000_Kinase_Perturbations_up", "LINCS_L1000_Ligand_Perturbations_down", "LINCS_L1000_Ligand_Perturbations_up", "MCF7_Perturbations_from_GEO_down", "MCF7_Perturbations_from_GEO_up", "MGI_Mammalian_Phenotype_2013", "MGI_Mammalian_Phenotype_Level_3", "MGI_Mammalian_Phenotype_Level_4", "Microbe_Perturbations_from_GEO_down", "Microbe_Perturbations_from_GEO_up", "Mouse_Gene_Atlas", "MSigDB_Computational", "MSigDB_Oncogenic_Signatures", "NCI", "NCI", "NCI", "NURSA_Human_Endogenous_Complexome", "Old_CMAP_down", "Old_CMAP_up", "OMIM_Disease", "OMIM_Expanded", "Panther_2015", "Panther_2016", "Pfam_InterPro_Domains", "Phosphatase_Substrates_from_DEPOD", "PPI_Hub_Proteins", "Reactome_2013", "Reactome_2015", "Reactome_2016", "SILAC_Phosphoproteomics", "Single_Gene_Perturbations_from_GEO_down", "Single_Gene_Perturbations_from_GEO_up", "TargetScan_microRNA", "TF", "Tissue_Protein_Expression_from_Human_Proteome_Map", "Tissue_Protein_Expression_from_ProteomicsDB", "Transcription_Factor_PPIs", "TRANSFAC_and_JASPAR_PWMs", "Virus_Perturbations_from_GEO_down", "Virus_Perturbations_from_GEO_up", "VirusMINT", "WikiPathways_2013", "WikiPathways_2015", "WikiPathways_2016")



enrichr = function(geneSymbols, listName=NULL, ontologies=c("GO_Biological_Process_2015", "ENCODE_TF_ChIP", "ENCODE_Histone_Modifications_2015"), suppress_logs=T, keep_genes=F, padj_cutoff=0.05){
    ## todo remove listName from API
    listHash=digest(geneSymbols)

    if(system("which query_enrichr_py3.py", ignore.stdout=T) == 1){
        stop("query_enrichr_py3 is not in PATH")
    }

    if(!all(ontologies %in% .ENRICHR_ONTOLOGIES)){
        stop(paste0("the followling ontoligies are supported by enrichr: ", paste(setdiff(ontologies, .ENRICHR_ONTOLOGIES), collapse=",")))
    }

    ## DEBUG geneSymbols= c("rBAT", "IP3R", "caveolin", "Actin", "PA28", "CR3", "gp91", "iNOS", "IFNGR", "PKB", "TRAF6", "Jak", "LDLR", "CPE", "REST", "Htt", "GF"); ontology="GO_Biological_Process_2015"; listName="test"

    listFile = tempfile(fileext=".lst")
    writeLines(geneSymbols, listFile)

#    quote({
    enrReusults = ontologies %>% map_df(function(ontology){
        # ontology = "ENCODE_TF_ChIP"
        # enrichr-api/query_enrichr_py3.py ${geneList} "wgcna module ${geneList}" ENCODE_Histone_Modifications_2015 ${geneList}.encode_hist_meth_2015.enrresults.txt
        resultsFile = tempfile(fileext=".txt")

        system(paste0("query_enrichr_py3.py ", listFile, " '",listHash,"' ", ontology, " ", trim_ext(resultsFile, ".txt")), ignore.stderr=T, ignore.stdout=suppress_logs)

        if(file.exists(resultsFile)){
            read_tsv(resultsFile) %>%
                set_names("term", "overlap", "p_value", "adj_p_value", "z_score", "combined_score", "genes") %>%
                mutate(
#                    list_name=listName,
                    ontology=ontology
                )
        }else{
            data_frame()
        }
    })
#    }) %>% cache_it(digest(list(geneSymbols, listName, ontologies)))

    if(!keep_genes) enrReusults %<>% dplyr::select(-genes)

    enrReusults %>% filter(adj_p_value<padj_cutoff)
}

#enrichr_cached = function(...){ quote(enrichr(...)) %>% cache_it() }


#1:3       %>% map_df(~data_frame(x=1))
#list(1:3) %>% map_df(~data_frame(x=1))
#
#quote(map_df(ontologies, ~data_frame(x=1)))
#
#map_df(list(1:3), ~data_frame(x=1))
