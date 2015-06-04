library(cluster) # for creating matrix
library(reshape) # for breaking down matrix into pairs
library(ggplot2) # for plots

#open file
in.file <- file.choose()
df <- read.csv(in.file)

# set up data frame with ids as row names and all variables as factors
df <- data.frame(df[,-1], row.names=df[,1])
df[] <- lapply(df, factor)

# build dissimilarity matrix, including actual locus count (instead of proportion)
dissmat <- ncol(df) * as.matrix(daisy(df, metric ="gower"))

# write matrix to file if wanted (so can avoid this lengthy step in future)
# 
# fileName1 <- file.choose(new=TRUE)
# write.csv(dissmat, file =fileName1)

# create pairwise table and write it to file
pairs <- melt(dissmat)[melt(upper.tri(dissmat))$value,]
names(pairs) <- c("c1", "c2", "distance")

out.file <- paste(gsub(".csv","", in.file),"_pairs.csv",sep="")
write.csv(pairs, file=out.file)

# plot to see cutoff
ggplot(pairs, aes(distance)) + 
  geom_histogram(binwidth=10) + # change histogram to 
  geom_vline(xintercept=c(850), linetype="dotted") # change intercept to choose cut-off

# continue with separate-lineages-s2.pl