library(cluster)
library(reshape)
library(ggplot2)

#open file
df <- read.csv(file.choose())

# set up data frame with ids as row names and all variables as factors
df <- data.frame(df[,-1], row.names=df[,1])
df[] <- lapply(df, factor)

# make dissimilarity matrix, including actual locus count (instead of proportion)
dissmat <- ncol(df) * as.matrix(daisy(df, metric ="gower"))

# write matrix to file
write.csv(dissmat, file ='/Volumes/sofia/Mycobacterium/MTBC allelic diversity/temp-matrix.csv')

# write pairwise to file
pairs <- melt(dissmat)[melt(upper.tri(dissmat))$value,]
names(pairs) <- c("c1", "c2", "distance")

write.csv(pairs, file ='/Volumes/sofia/Mycobacterium/MTBC allelic diversity/temp-pairs.csv')

# plot to see cutoff
ggplot(pairs, aes(distance)) + geom_histogram(binwidth=10) + geom_vline(xintercept=c(850), linetype="dotted")

# continue with separate-lineages-s2.pl