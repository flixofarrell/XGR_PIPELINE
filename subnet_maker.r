#subnet_maker: 
#Create gene subnetwork from lead SNPs 

#Developer: Felix O'Farrell
#06/04/20 


library(XGR)
#library(RCircos)

#args called in Nextflow script
args <- commandArgs(trailingOnly=TRUE)

#read in formatted EBI summary statistics as dataframe (created by lead_SNP_extractor.r script)
df_SNPs <- read.csv(args[1])

#read sig argument
n <- as.double(args[2])

#Store location of summary newtwork used by XGR
RData.location <- "http://galahad.well.ox.ac.uk/bigdata"

#ensure format is not changed when reading and writing dataframe
keeps <- c("location", "P.VALUE")
df_SNPs <- df_SNPs[keeps]

#create subnetwork using user input significance cut-off (defualt is 0.00001)
subnet <- xSubneterSNPs(data=df_SNPs, network="STRING_high", seed.genes=F,
subnet.significance= n , scoring.scheme="max", RData.location=RData.location)

#Visualise subnetwork with nodes colored according to the significance
net_sig <- xVisNet(g=subnet, pattern=-log10(as.numeric(V(subnet)$significance)),
vertex.shape="sphere", colormap=args[3])
print (net_sig)

#Visualise subnetwork with nodes colored according to transformed scores
net_scrs <- xVisNet(g=subnet, pattern=as.numeric(V(subnet)$score),
vertex.shape="sphere")
print (net_scrs)

#storing network as 2 dataframs
#edge df

subnet_stored_e <- as_data_frame(subnet, what = c("edges"))
write.csv(x=subnet_stored_e, file="subnet_stored_e.csv")
#vertices df

subnet_stored_v <- as_data_frame(subnet, what = c("vertices"))
write.csv(x=subnet_stored_v, file="subnet_stored_v.csv")

#end

