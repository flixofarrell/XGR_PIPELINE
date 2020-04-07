#enrichment: 
#Perform enrichment analysis using subnetwork created by subnet_maker.r

#Developer: Felix O'Farrell
#06/04/20 

library(XGR)
#args called in Nextflow script
args <- commandArgs(trailingOnly=TRUE)

#Store location of summary newtwork used by XGR
RData.location <- "http://galahad.well.ox.ac.uk/bigdata"

#read in stored edges of subnetwork (generated in subnet_maker.r)
subnet_stored_e <- read.csv(args[1])

#ensure formatting isn't changed when writing an reading dataframe
keeps <- c("from", "to")
subnet_stored_e <- subnet_stored_e[keeps]

#read in stored vertices of subnetwork (generated in subnet_maker.r)
subnet_stored_v <- read.csv(args[2])
#create igraph object from the edge and vertices dataframes 
subnet <- graph_from_data_frame(subnet_stored_e, directed = TRUE, vertices = subnet_stored_v)

##Enrichment analysis
#access reactome database
ontology <- "MsigdbC2CPall"

#take vector from subnetwork - list of SNPs of interest (from subnetwork)
e_data <- V(subnet)$name

#enrichment analysis with fisher test (user can stipulate other statistic tests)
eTerm <- xEnricherGenes(data=e_data, ontology=ontology, test=args[3], RData.location=RData.location)

#eTerm_im <- xEnrichConciser(eTerm)
bp <- xEnrichBarplot(eTerm, top_num='auto', displayBy=args[4])

print (bp)

#end