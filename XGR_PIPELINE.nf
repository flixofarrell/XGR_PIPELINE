#!/usr/bin/env nextflow

/*
 * Pipeline to take lead SNPs from EBI summary statistics 
 */




/*
 * XGR pipeline input parameters
 */

params.sum_data = "test_files/astle_NC.tsv"
params.nsig = 0.0000001
params.ncol = "jet"
params.etest = "fisher"
params.stype = "pvalue"
params.outdir = "my_results"

println """\
----------------------------------------------------------------------------------

           F O F  X G R  P I P E L I N E (1.0)
          =====================================
         input data       : ${params.sum_data}
         
         network sig      : ${params.nsig}
         network col      : ${params.ncol}            
         
         enrich test      : ${params.etest}
         enrich sig type  : ${params.stype}

         outdir	          : ${params.outdir}	
        
----------------------------------------------------------------------------------
         """
         .stripIndent()


/*
 * create a summary file object given the summary string parameter
 */

summary_file = file(params.sum_data)

/*
 * extract lead SNPs from summary data
 */

process lead_SNP_extraction {
  publishDir "$params.outdir/LSNPs", pattern: "*.csv"


    input:
    path summary from summary_file

    output:
    file 'LSNPs.csv' into lead_ch

    script:
    """
    Rscript ../../../lead_SNP_extractor.r $summary LSNPs.csv
    """
}

/*
 * create subnetwork from lead SNPs
 */

process subnetwork_construction {
  publishDir "$params.outdir/networks/visuals", pattern: "*.pdf"
  publishDir "$params.outdir/networks/dataframes", pattern: "*.csv"
    
    input:
    path lead from lead_ch
    

    output:
    file 'subnet_stored_e.csv' into edges_ch 
    file 'subnet_stored_v.csv' into vertices_ch

    script:
    """
    Rscript ../../../subnet_maker.r $lead ${params.nsig} ${params.ncol}
    """
}

/*
 * Perform enrichment analyis on significant genes 
 */

process enrichment_analysis {
  publishDir "$params.outdir/encrichment/visuals", pattern: "*.pdf"
  publishDir "$params.outdir/encrichment/dataframes", pattern: "*.csv"

    input:
    file sub_e from edges_ch
    file sub_v from vertices_ch

    output:
    file "*"

    script:
    """
    Rscript ../../../enrichment.r $sub_e $sub_v ${params.etest} ${params.stype}
    """
}



