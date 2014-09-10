#> {message=F, echo=F}
require(dplyr)
require(ggplot2)

##> test heading

#> ... followed by some markup
head(iris)

#> some markup
#> * or list
#> * elements
ggplot(iris, aes(Species, Sepal.Length, fill=Species)) + geom_boxplot() + scale_fill_discrete(guide=F)


#> {fig.width=14}
## just chunk definition without markdown text or header

ggplot(iris, aes(Species, Sepal.Length, fill=Species)) + geom_boxplot() + scale_fill_discrete(guide=F)

# source /Users/brandl/Dropbox/Public/datautils/R/rknit/rknit.sh
# rknit /Users/brandl/Dropbox/Public/datautils/R/rknit/rknit_example.R
