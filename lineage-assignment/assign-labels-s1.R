library(cluster) # for creating matrix
library(reshape) # for breaking down matrix into pairs
library(ggplot2) # for plots

#open file, a table of isolates as columns and loci as rows
in.file <- file.choose()
df <- read.csv(in.file)

# set up data frame with locus ids as row names and all allele numbers as factors
df <- data.frame(df[,-1], row.names=df[,1])
df[] <- lapply(df, factor)

# build dissimilarity matrix, including actual locus count (instead of proportion)
dissmat <- ncol(df) * as.matrix(daisy(df, metric ="gower"))

# write matrix to file (so can avoid this lengthy step in future) 
matrix.file <- paste(gsub(".csv","", in.file),"_matrix.csv",sep="")
write.csv(dissmat, file = matrix.file)

# create pairwise table and write it to file
pairs <- melt(dissmat)[melt(upper.tri(dissmat))$value,]
names(pairs) <- c("c1", "c2", "distance")

out.file <- paste(gsub(".csv","", in.file),"_pairs.csv",sep="")
write.csv(pairs, file=out.file)

# plot to see cutoff
ggplot(pairs, aes(distance)) + 
  geom_histogram(binwidth=10) + # change histogram to 
  geom_vline(xintercept=c(850), linetype="dotted") # change intercept to choose cut-off

# continue with assign-labels-s2.pl
