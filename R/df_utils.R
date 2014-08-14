

subsample <- function(df, sampleSize, ...){
    df[sample(1:nrow(df), min(sampleSize, nrow(df)), ...),]
}

shuffle <- function(df) df[sample(nrow(df)),]

first <- function(x, n=1) head(x,n)

as.df <- function(dt) as.data.frame(dt)


## small wrappers




rownames2column <- function(df, colname){
    df <- as.df(df)
    df$tttt <- rownames(df);
    rownames(df) <- NULL;
    rename(df, c(tttt=colname))
}

column2rownames<- function(df, colname){
#browser()
    rownames(df) <- ac(df[,colname])
    df[colname] <- NULL
    return(df)
}

## pushing some columns to the right end of a data.frame
push_right <- function(df, pushColNames){
    df[,c(setdiff(names(df),pushColNames), pushColNames)]
}

push_left <- function(df, pushColNames){
    df[,c(pushColNames, setdiff(names(df),pushColNames))]
}

set_names <- function(df, newnames){
    df<- as.df(df)
    names(df) <- newnames;
    return(df)
}


## dplyr utilities

print_head <- function(df, desc=NULL){
    print(head(df))
    return(df)
}


fac2char <- function(mydata, convert=names(mydata)[sapply(mydata, is.factor)]){
    if(length(convert)==0)
        return(mydata)

    inputColOrder <- names(mydata)

    convertData <- subset(mydata, select= names(mydata)%in%convert)
    convertData <- as.data.frame(lapply(convertData, as.character), stringsAsFactors = FALSE)

    keepData <-  subset(mydata, select=!(names(mydata)%in%convert))
    newdata <- cbind(convertData, keepData)
    newdata <- newdata[,inputColOrder]

    return(newdata)
}


## workaround for biomart
dselect <- function(...) dplyr::select(...)


