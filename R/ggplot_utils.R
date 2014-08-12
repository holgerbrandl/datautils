


########################################################################################################################
### pca plots (http://largedata.blogspot.de/2011/07/plotting-pca-results-in-ggplot2.html)

makePcaPlot <- function(x = getData(), group = NA, items=rownames(x), title = "") {
  require(ggplot2)
  require(RColorBrewer)

#  data <- x
#  data <- t(apply(data, 1, scale))
#  rownames(data) <- rownames(x)
#  colnames(data) <- colnames(x)
#  mydata <- t(data)
  mydata <-x
  mydata.pca <- prcomp(mydata, retx=TRUE, center=TRUE, scale.=TRUE)

  percent <- round((((mydata.pca$sdev)^2 / sum(mydata.pca$sdev^2))*100)[1:2])

  scores <- mydata.pca$x
  pc12 <- data.frame(PCA1=scores[,1], PCA2=scores[,2], group=group)

#  ggplot(pc12, aes(PCA1, PCA2, colour = group)) + geom_point(size = 6, alpha = 3/4)
  ggplot(pc12, aes(PCA1, PCA2, colour = group, label=items)) +
    geom_point(size = 6, alpha = 3/4)   +
    geom_text(size = 6, alpha = 3/4)    +
    xlab(paste("PCA1 (", percent[2], "%)", sep = "")) +
    ylab(paste("PCA2 (", percent[2], "%)", sep = ""))

  qplot(PCA2, PCA1, geom="blank", main = title, xlab = paste("PCA2 (", percent[2], "%)", sep = ""), ylab = paste("PCA1 (", percent[1], "%)", sep = "")) +
    geom_point(aes(colour = group), size = 6, alpha = 3/4)
#    theme(
#      axis.text.x = element_text(size = base_size * 1.3 , lineheight = 0.9, colour = "grey50", hjust = 1, angle = 90),
#      axis.text.y = element_text(size = base_size * 1.3, lineheight = 0.9, colour = "grey50", hjust = 1)
#    )
}


## example
# makePcaPlot(getData(30,4,2,distort = 0.7))
