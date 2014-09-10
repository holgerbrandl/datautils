require(dplyr)
require(gplot)

##> test
ggplot(iris, aes(Species, Sepal.Length, fill=Species)) + geom_boxplot() + scale_fill_discrete(guide=F)



# source /Users/brandl/Dropbox/Public/datautils/R/rknit/rknit.sh ; rknit /Users/brandl/Dropbox/Public/datautils/R/rknit/rknit_example.R