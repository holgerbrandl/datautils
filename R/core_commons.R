
## automatic package installation
require.auto <-  function(x){
    x <- as.character(substitute(x))

    if(isTRUE(x %in% .packages(all.available=TRUE))) {
        eval(parse(text=paste("require(", x, ",  quietly=T)", sep="")))
    } else {
    #        update.packages(ask=F) # update dependencies, if any.
        eval(parse(text=paste("install.packages('", x, "')", sep="")))
    }

    if(isTRUE(x %in% .packages(all.available=TRUE))) {
        eval(parse(text=paste("require(", x, ",  quietly=T)", sep="")))
    } else {
        source("http://bioconductor.org/biocLite.R")
        biocLite(character(), ask=FALSE) # update dependencies, if any.
        eval(parse(text=paste("biocLite('", x, "')", sep="")))
        eval(parse(text=paste("require(", x, ",  quietly=T)", sep="")))
    }
}

require.auto(plyr)
require.auto(stringr)
require.auto(reshape2)
#require.auto(reshape2, quietly=T, warn.conflicts=F)
require.auto(scales)

require.auto(dplyr)


#require.auto(data.table)

options(help_type="html")
options(width=150)

# for sqldf to avoid the use of tckl
options(gsubfn.engine = "R")


##### set the r mirror
#cat(".Rprofile: Setting Goettingen repository\n")
r = getOption("repos") # hard code the UK repo for CRAN 
r["CRAN"] = "http://ftp5.gwdg.de/pub/misc/cran/"
options(repos = r)
rm(r)




#qlibrary <- function(libname) {library(as.character(substitute(libname)), quietly=T, warn.conflicts=F, character.only=T )}




########################################################################################################################
#### Small aliases


#praste <- function(...) print(paste(...))
echo <- function(...) print(paste(...))


ac <- function(...) as.character(...)

qns <- function() quit(save="no")


# string concatenation without space gaps (could/should use paste0 instead)
concat <- function(...) paste(..., sep="")


se<-function(x)	sd(x, na.rm=TRUE) / sqrt(sum(!is.na(x)))

unlen <- function(x) length(unique(x))

pp <- function(dat) page(dat, method = "print")



########################################################################################################################
#### File System

is.directory <- function(dirname) !is.na(file.info(dirname)$isdir)


mcdir <- function(dirname){
    if(!file.exists(dirname)){
        dir.create(dirname)
    }

    setwd(dirname)
}

locload <- function(fileName) local(get(load(fileName)))


rmerge <- function(LDF, by, ...){
    DF <- LDF[[1]]
    for (i in 2:length(LDF)) {
        DF <- merge(DF, LDF[[i]], by=by)
    }
    DF
}




trimEnd <-function(fileNames, exts=c()){
    for(fileExt in exts){
        fileNames <- str_replace(fileNames, paste(fileExt, "$",sep=""), "")
    }

    fileNames
}

chopFileExt <-function(fileNames, exts=c()){
    warning("this method is deprecated. use trimEnd instead")
    for(fileExt in exts){
        fileNames <- str_replace(fileNames, paste(".", fileExt, "$",sep=""), "")
    }

    fileNames
}

write.delim <- function(df, header=TRUE,...){
    write.table(df, row.names=FALSE, col.names=header, sep="\t", ...)
}

## writes a table in bed format expecting columns being ordered according to bed spec already
write.bed <- function(bedData, file){
    write.table(bedData, file=file, quote=FALSE, sep ="\t", na="NA", row.names=FALSE, col.names=FALSE)
}
#options(scipen=100) ## necessary to disable scientific number formats for long integers




rmSomeElements <- function(vec, toDel) vec[!(vec %in% toDel)]

rmLastElement <- function(vec) vec[-length(vec)]


########################################################################################################################
#### File System

## Memory management

# improved list of objects
lsos <- function (pos = 1, pattern, order.by,
                        decreasing=FALSE, head=FALSE, n=5) {
    napply <- function(names, fn) sapply(names, function(x)
                                         fn(get(x, pos = pos)))
    names <- ls(pos = pos, pattern = pattern)
    obj.class <- napply(names, function(x) as.character(class(x))[1])
    obj.mode <- napply(names, mode)
    obj.type <- ifelse(is.na(obj.class), obj.mode, obj.class)
    obj.size <- napply(names, object.size)/1000000
    obj.dim <- t(napply(names, function(x)
                        as.numeric(dim(x))[1:2]))
    vec <- is.na(obj.dim)[, 1] & (obj.type != "function")
    obj.dim[vec, 1] <- napply(names, length)[vec]
    out <- data.frame(obj.type, obj.size, obj.dim)
    names(out) <- c("Type", "Size", "Rows", "Columns")
    if (!missing(order.by))
        out <- out[order(out[[order.by]], decreasing=decreasing), ]
    if (head)
        out <- head(out, n)
#        out
    out <- transform(out, var_name=rownames(out))
    rownames(out) <- NULL
    arrange(out, Size)
}

# shorthand
lsosh <- function(..., n=10) {
    lsos(..., order.by="Size", decreasing=TRUE, head=TRUE, n=n)
}

