#lead_SNP_extractor: 
#Take significant SNP genomic loci and P-values from ebi GWAS summary statistics and
#format for input to XGR

#Developer: Felix O'Farrell
#06/04/20 

#args called in Nextflow script
args <- commandArgs(trailingOnly=TRUE)

#read in EBI summary statistics as dataframe
prac_df <- read.csv(args[1])

#XGR input requires loci format of 'chrX'+'locus' e.g.(chr3:13576878)
#Create new collumn in dataframe called 'location' and merge CHR_ID with CHR_POS 
#and separate with ':'
prac_df <- transform(prac_df, location = paste(CHR_ID,CHR_POS, sep = ":"))

#Add string 'chr' to every elememtn in location collumn
prac_df <- transform(prac_df, location = sprintf('chr%s', location))

#drop all unused collumns - keep only leadSNPs and their respectve P-VALUES
keeps <- c("location","P.VALUE")
df_use <- prac_df[keeps]

#write dataframe to csv
write.csv(x=df_use, file=args[2])

#end


