#require_auto(ggplot2)
#require_auto(scales)


scale_fill_redgreed <- function() scale_fill_manual(values = c("red","darkgreen"))

rot_x_lab <- function() theme(axis.text.x = element_text(angle = 90, hjust = 1))
rot_x_45 <- function() theme(axis.text.x = element_text(angle = 45, hjust = 1))
## DEPRACTED because of naming
rotXlab <- function() theme(axis.text.x = element_text(angle = 90, hjust = 1))


# allow for layer-wise subsetting
# http://stackoverflow.com/questions/35806310/ggplot-plotting-layers-only-if-certain-criteria-are-met
pick <- function(condition){
    function(d) d %>% filter_(condition)
}


# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, by.row=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    # Set up the page

    grid::grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


gg2Format="png"


## simplified save function for ggpltos
ggsave2 <- function(gplot=last_plot(), width=8, height=6, prefix="", saveData=FALSE, outputFormat=gg2Format, ...){
    title <- try(gplot$labels[["title"]])

    if(is.null(title)){
        varMapping <- gplot$labels
        varMapping <- varMapping[names(varMapping) %in% c("x", "y")]
#        if(varMapping==NULL){
#            varMapping <- gplot$mapping;
#        }

        if(length(varMapping) == 1){
            title= paste("distribution of", varMapping)
        }else{
            title = try(paste(varMapping, collapse=" vs "))
        # stop("last plot had no title. Use ggsave() and give it a manual title")
        }

        rawFacetDesc <- format(gplot$facet)
        if(rawFacetDesc!="facet_null()"){
            title <- paste(title, "by", str_replace_all(str_match(rawFacetDesc, "facet_.*[(](.*)[)]")[,2], "~", "and"))
        }
    }


    fileBaseName <- ifelse(nchar(prefix)>0, paste0(prefix, " - ", title), title)

    ## clean up weired characters
    fileBaseName <- str_replace_all(fileBaseName, "[$%/?]", "_")

    fileName = paste0(fileBaseName, paste0(".", outputFormat))

    ## remove line-breaks and trim spaces
    fileName = str_replace_all(str_replace_all(fileName, "\\n", ""), "[ ]{2,}", " ")
#    print(paste("saving plot to ", fileName))
    ggsave(fileName, width=width, height=height, ...)

    if(saveData){
        write_tsv(gplot$data, path=paste0(fileBaseName, ".txt"))
    }

    return(fileName)
}

## toggle active output device (see ggplot_devel.R for auto-toggeling plot)
toggle_plot_window = function() dev.set(dev.next())


########################################################################################################################
### pca plots (http://largedata.blogspot.de/2011/07/plotting-pca-results-in-ggplot2.html)



makePcaPlot = function(matrixData, color_by=NA, items=rownames(matrixData), title = NA, center=TRUE, scale=FALSE) {
    load_pack(ggplot2)
    load_pack(RColorBrewer)
    load_pack(ggrepel)

    if(is.na(color_by)){
        color_by_sorted = NA
    }else{
        color_by_sorted = items %>% map_chr(~color_by[[.x]])
    }

    mydata.pca = prcomp(matrixData, retx = TRUE, center = center, scale. = scale)

    percent <- round((((mydata.pca$sdev) ^ 2 / sum(mydata.pca$sdev ^ 2)) * 100)[1 : 2])

    scores <- mydata.pca$x
    pc12 <- data.frame(PCA1 = scores[, 1], PCA2 = scores[, 2], group = color_by_sorted)

    if(is.na(color_by)){
        pcaPlot = ggplot(pc12, aes(PCA1, PCA2)) + geom_point(alpha = .4)
    }else{
        pcaPlot = ggplot(pc12, aes(PCA1, PCA2, color = group)) + geom_point(alpha = .4)
    }

    if (!is.null(items)) {
        # pcaPlot = pcaPlot + geom_text(aes(label = items), alpha = 3 / 4, vjust = 1.5)
        pcaPlot = pcaPlot + geom_text_repel(aes(label = items), alpha = 3 / 4, vjust = 1.5)
    }

    ## make labels to be rendered within canvas bounds --> "inward" is better
    ## https://stackoverflow.com/questions/17241182/how-to-make-geom-text-plot-within-the-canvass-bounds#
    pcaPlot = pcaPlot + scale_x_continuous(expand = c(.2, .2)) +
        xlab(paste("PCA1 (", percent[1], "%)", sep = "")) +
        ylab(paste("PCA2 (", percent[2], "%)", sep = ""))


    if (! is.na(title)) pcaPlot = pcaPlot + ggtitle(title)

    pcaPlot
}


## example
# makePcaPlot(getData(30,4,2,distort = 0.7))

## todo learn from http://rpubs.com/sinhrks/plot_pca

########################################################################################################################
### ggpairs

#load_pack(GGally)
#ggpairs(tips, mapping = aes(color = sex), columns = c("total_bill", "time", "tip"))

gp_alpha <- function(data, mapping, ...) {
    ggplot(data = data, mapping=mapping) + geom_point(alpha = 0.1)
}

gp_bin2d <- function(data, mapping, ..., low = "#10721C", high = "#F11D05") {
    ggplot(data = data, mapping = mapping) +
    geom_bin2d(...) +
    scale_fill_gradient(low = low, high = high)
}
#qModelStats %>% ungroup() %>% select(-ensembl_gene_id) %>% ggpairs(lower=list(continuous=gp_bin2d), title="plot score as regressor")



########################################################################################################################
### Base-plot utils


plotPDF <- function(fileBaseName, expr, ...){ pdf(paste0(fileBaseName, ".pdf"), ...); expr; dev.off(); }
#plotPDF("test", plot(1:10))


## create a custom color palette for a fixed set of values
## scale_fill_manual(values = create_palette(unique(csWithTopoT1$t1_type)), drop = FALSE)
create_palette <- function(x, pal = 'Set1'){
  load_pack(RColorBrewer)

  ux <- sort(unique(x))
  n <-length(ux)

  if(n==0) return(c())

  setNames(brewer.pal(name = pal, n = n)[1:n], ux)
}

