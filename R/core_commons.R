########################################################################################################################
## set a default cran r mirror  and customize environment

#cat(".Rprofile: Setting Goettingen repository\n")
#todo consider to use chooseCRANmirror(graphics=FALSE, ind=10) instead

r = getOption("repos") # hard code the UK repo for CRAN 
r["CRAN"] = "http://ftp5.gwdg.de/pub/misc/cran/"
options(repos = r)
rm(r)


## user browser for help
options(help_type = "html")

## plot more characters per line
# options(width = 100)
# options(tibble.width = 110)  ## max width when not using toc
# options( tibble.width = 90) ## max width when using toc

## adjust dplyr printing settings
## http://stackoverflow.com/questions/22471256/overriding-variables-not-shown-in-dplyr-to-display-all-columns-from-df
## http://stackoverflow.com/questions/29396111/dplyrtbl-df-fill-whole-screen
# options(dplyr.print_min = 20) ## num rows
# options(dplyr.width = 130) ## width
# options(tibble.width  = 100)

#options(dplyr.width = 250); options(width=250) ## width

# for sqldf to avoid the use of tckl
options(gsubfn.engine = "R")

## fix annoying column name abbreviations in tibble/pillar
options(pillar.min_title_chars=10000)

########################################################################################################################
## automatic package installation


## externalized installer to also allow for installation without loading
install_package <- function(x){
    if (! isTRUE(x %in% .packages(all.available = TRUE)) && any(available.packages()[, 1] == x)) {
        # update.packages(ask=F) # update dependencies, if any.
        eval(parse(text = paste("install.packages('", x, "')", sep = "")))
    }

    ## if it's still missing check if it's on bioconductor
    if (! isTRUE(x %in% .packages(all.available = TRUE))) {
        bcPackages <- as.vector(read.dcf(url("https://bioconductor.org/packages/3.3/bioc/src/contrib/PACKAGES"), "Package"))

        if (any(bcPackages == x)) {
            source("http://bioconductor.org/biocLite.R")
            eval(parse(text = paste("biocLite('", x, "', ask=FALSE)", sep = "")))
        }
    }
}

load_pack <- function(x, warn_conflicts=T){
    x <- as.character(substitute(x));

    install_package(x)

    ## load it using a library function so that load_pack errors if package is still not ins
    eval(parse(text = paste("base::library(", x, ",  quietly=T, warn.conflicts=", warn_conflicts, ")", sep = "")))
}


check_version = function(pkg_name, min_version) {
    cur_version = packageVersion(pkg_name)
    if (cur_version < min_version) stop(sprintf("Package %s needs a newer version,
               found %s, need at least %s", pkg_name, cur_version, min_version))
}
#check_version("dplyr", "0.4-1")

########################################################################################################################
## load core packages

#if(!any(.packages(all.available=TRUE)=="biomaRt")){
#    source("http://bioconductor.org/biocLite.R")
#    biocLite("biomaRt", ask=FALSE)
#}

#load_pack(plyr)
#load_pack(reshape2)
#load_pack(reshape2, quietly=T, warn_conflicts=F)

load_pack(conflicted)

## common plotting requirements since they are omnipresent
load_pack(ggplot2)
load_pack(scales, warn_conflicts = F) # note this has a known conflit with purrr::discard
load_pack(grid)


## load on purpose after plyr
load_pack(purrr)
load_pack(tibble)
load_pack(dplyr, warn_conflicts = F)
load_pack(magrittr, warn_conflicts = F)
load_pack(tidyr, warn_conflicts = F)
load_pack(stringr)
load_pack(readr)
load_pack(forcats)
load_pack(readxl) ## supress differring build number

## needed for caching
load_pack(digest)

#suppressWarnings(load_pack(readxl)) ## supress differring build number

#load_pack(readxl) ## supress differring build number

## for table exploration without using Rstudio
install_package("knitr")
load_pack(DT)

## cli development
install_package("docopt")

## enviroment persistence
install_package("session")


## moved into datatable_commons because replaced almost everywhere with dplyr
#load_pack(data.table)



########################################################################################################################
#### Convenience aliases


echo <- function(...) cat(paste(...), fill = T)

ac <- function(...) as.character(...)

# string concatenation without space gaps (could/should use paste0 instead)
## Deprecated: use paste0 instead
#concat <- function(...) paste(..., sep="")

unlen <- function(x) length(unique(x))

pp <- function(dat) page(dat, method = "print")

# TODO .Deprecated and .Defunct (see http://ropensci.org/blog/technotes/2017/01/05/package-evolution)

# as.df <- function(dt){ warning("DEPRECATED: use as_df instead of as.df"); as.data.frame(dt)}
as_df <- function(dt) as.data.frame(dt)


install_package("tibble")

## restore pre-tibble-v1.2 naming to creating data-frame in place
frame_data = function(...) tibble::tribble(...)


add_rownames = function(...){ warning("DEPRECATED: Use tibble::rownames_to_column directly"); tibble::rownames_to_column(...)}


## redefine dply::splat to allow for more streamlined rowwise df-processing
## see https://groups.google.com/forum/?utm_source=digest&utm_medium=email#!topic/manipulatr/E6WOcHlRJcw
#splat = function (flat) {
#    function(args, ...) {
#        do.call(flat, c(args, list(...)))
#    }
#}
## for now simply import just splat from plyr namespace
install_package("plyr")
splat = plyr::splat


########################################################################################################################
#### data.frame manipulation


shuffle <- function(df) df[sample(nrow(df)),]

first <- function(x, n=1) head(x, n)
first_group = function(x, which=1) x %>% nest %>% slice(which) %>% unnest(data)



vec_as_df <- function(namedVec, row_name="name", value_name="value"){
    data_frame(name = names(namedVec), value = namedVec) %>% set_names(row_name, value_name)
}


column2rownames <- function(df, colname){
    warning("DEPRECATED: Use tibble::column_to_rownames directly")
    #browser()
    ## force into df to avoid dplyr problems
    df <- as_df(df)

    rownames(df) <- ac(df[, colname])
    df[colname] <- NULL
    return(df)
}

## pushing some columns to the end of a data.frame
## TBD how to make this possible without quoting column names?
push_right <- function(df, pushColNames){
    df[, c(setdiff(names(df), pushColNames), pushColNames)]
}


## pushing some columns to the beginning of a data.frame
push_left <- function(df, pushColNames){
    df[, c(pushColNames, setdiff(names(df), pushColNames))]
}


#http://astrostatistics.psu.edu/datasets/R/html/base/html/formals.html
## conflicts with purrr::set_names but does not work with ....
set_names <- function(df, ...){
    newnames <- as.character(unlist(list(...)))

    ## automatically convert matrices to data.frames (otherwise the names set would fail
    if (is.matrix(df))df %<>% as.data.frame()

    names(df) <- newnames;
    return(df)
}
# iris %>% purrr::set_names(paste(names(iris), "__")) %>% glimpse
# iris %>% set_names(paste(names(iris), "__")) %>% glimpse
#
#iris %>% set_names(c("setosa", "hallo")) %>% head
#iris %>% set_names("setosa", "hallo") %>% head


# devtools::source_url("https://www.dropbox.com/s/r6kim8kb8ohmptx/core_commons.R?dl=1")

pretty_names = function(some_names, make_unique=FALSE){
    new_names = some_names %>%
        str_replace_all("[#+=.,()/*: -]+", "_") %>%
        str_replace(fixed("["), "") %>%
        str_replace(fixed("]"), "") %>%
    ## remove leading and tailing underscores
        str_replace("[_]+$", "") %>%
        str_replace("^[_]+", "") %>%
    ## remove unicode characters
        iconv(to = 'ASCII', sub = '') %>% ## http://stackoverflow.com/questions/24807147/removing-unicode-symbols-from-column-names
        tolower

    if(make_unique){
    ## make duplicates unqiue
      new_names %<>% make.unique(sep = "_")
    }

    new_names
}

pretty_columns = function(df){
    names(df) <- names(df) %>% pretty_names(make_unique=TRUE)
    df
}

# http://stackoverflow.com/questions/23188900/view-entire-dataframe-when-wrapped-in-tbl-df
print_all <- function(df) df %>% tbl_df %>% print(n = nrow(.))

head_html <- function(df, n=5) head(df, n) %>%
    knitr::kable(format = "html") %>%
    print()

print_head <- function(df, desc=NULL){
    print(head(df))
    print(nrow(df))
    return(df)
}


fac2char <- function(mydata, convert=names(mydata)[sapply(mydata, is.factor)]){
    if (length(convert) == 0) {
        return(mydata)
    }

    inputColOrder <- names(mydata)

    convertData <- subset(mydata, select = names(mydata) %in% convert)
    convertData <- as.data.frame(lapply(convertData, as.character), stringsAsFactors = FALSE)

    keepData <- subset(mydata, select = ! (names(mydata) %in% convert))
    newdata <- cbind(convertData, keepData)
    newdata <- newdata[, inputColOrder]

    return(newdata)
}

## convenience method to sort factor levels with decreasing frequencies
fct_revfreq = function(x) fct_infreq(x) %>% fct_rev


## replace R within pipe change just use ... %>% do(replaceNA(0)) %>% ...
replaceNA <- function(x, withValue) {
    warning("DEPRECATED Use replace_NA instead")
    x[is.na(x)] <- withValue
    x
}

replace_NA <- function(x, withValue) { x[is.na(x)] <- withValue; x}




## see http://stackoverflow.com/questions/17288222/r-find-value-in-multiple-data-frame-columns/40586572#40586572
## case-insenstive search all columns of a data-frame with a fixed search term
search_df = function(df, search_term){
    apply(df, 1, function(r){
        any(str_detect(as.character(r), fixed(search_term, ignore_case = T)))
    }) %>% subset(df, .)
}


## filter a data-frame for those rows where at least one column is matching the given expression (that must evaluate to a boolean vector for each row).
match_df = function(df, search_expr){
    filter_fun = eval(substitute(function(x){search_expr}))

    apply(df, 1, function(r) any(filter_fun(r))) %>% subset(df, .)
}



## for na instead use mutate_each with:
#empty_as_na <- function(x) safe_ifelse(x=="", NA, x)
#empty_as_na <- function(x) ifelse(class(x)  %in% c("factor", "character") & x=="", NA, x)
empty_as_na <- function(x){
    if ("factor" %in% class(x))x <- as.character(x) ## since ifelse wont work with factors
    ifelse(as.character(x) != "", x, NA)
}

#if(F){ ## DEBUG of empty_as_na
#cond <- allJobs %>% head %$% submit_time %>% c("")
#empty_as_na( cond)
#cond <- allJobs %>% head %$% resubmission_of
#empty_as_na( cond)
#
#empty_as_na( c(1, 2, NA))
#empty_as_na( c("sdf", "sdf2", NA))
#empty_as_na( c("sdf", "sdf2", ""))
#
#myFac <- as.factor(c("sdf", "sdf2", NA))
#empty_as_na( myFac)
#ifelse(as.character(myFac)!="", myFac, NA)
#
#empty_as_na( c("sdf", "sdf2", ""))
#
#iris[1,1] <- ""
#apply(iris, 2, function(x) gsub("^$|^ $", NA, x))
#}


## see http://stackoverflow.com/questions/24172111/change-the-blank-cells-to-na/33952598#33952598


## apply dplyr::filter to df but use filter criterions for cross-tabulation beforehand
filter_count <- function(df, ...){
    print(count(df, ...))
    filter(df, ...)
}


n_as = function(df, name){
    names(df)[length(names(df))] = name
    df
}

#count_occ = function(df, ...) count(df, ...) %>% n_as("num_occ")

dcount = function(df, ...) count(df, ...) %>%
    n_as("num_occ") %>%
    count(num_occ)

count_as = function(df, n_name, ...) count(df, ...) %>% n_as(n_name)
#iris %>% count_as("num_occ", Species)
#iris %>% dcross_tab(Species)




distinct_all = function (x, ...) distinct(x, ..., .keep_all = T)

#' Return <code>true</code> if the data.frame is distinct with respect to the provided unqoted variabled names/expressions
is_distinct = function(x, ...){
    distinct(x) %>% nrow == nrow(x)
}


## fetch a column of a matrix in a magrittr pipe. Useful along with str_*
get_col = function(data, col_index) data[, col_index] ## also could use magrittr::extract here


## convience method to extract a column, defaults to _ as separator and the first column
extract_col = function(x, col_index=1, sep="_", num_cols=10){ str_split_fixed(x, sep, num_cols)[, col_index]}


## Extract the first group of a grouped data-frame
first_group = function(groupedDF){
    # groupedDF = geneLists
    # groupedDF = iris %>% group_by(Species)
    # https://stackoverflow.com/questions/33775239/emulate-split-with-dplyr-group-by-return-a-list-of-data-frames
    (groupedDF %>% do(data = (.)) %$% map(data, identity))[[1]]
}


mutate_inplace <- function(data, var, expr){
    load_pack("rlang")

    var <- enexpr(var)
    var_name <- quo_name(var)
    expr <- enexpr(expr)

    call <- quo(UQ(var) %>% UQ(expr))
    # print(call)
    mutate(data, !!var_name := UQ(call))
}

# mutate_inplace( iris, Species, str_replace("vir", "foo") )


# from https://stackoverflow.com/questions/34096162/dplyr-mutate-replace-on-a-subset-of-rows
mutate_cond <- function(.data, condition, ..., envir = parent.frame()) {
    condition <- eval(substitute(condition), .data, envir)
    .data[condition, ] <- .data[condition, ] %>% mutate(...)
    .data
}




reload_dplyr <- function(){
    unloadNamespace('tidyr')
    unloadNamespace('dplyr')
    require(tidyr);require(dplyr)
}


## from http://stackoverflow.com/questions/7505547/detach-all-packages-while-working-in-r
unload_packages <- function() {
    basic.packages <- c("package:stats", "package:graphics", "package:grDevices", "package:utils", "package:datasets", "package:methods", "package:base")
    package.list <- search()[ifelse(unlist(gregexpr("package:", search())) == 1, TRUE, FALSE)]
    package.list <- setdiff(package.list, basic.packages)
    if (length(package.list) > 0)for (package in package.list) detach(package, character.only = TRUE)
}


## workaround for biomart
## Deprecated: load dplyr after biomart to avoid this problem
#dselect <- function(...) dplyr::select(...)


########################################################################################################################
#### Result Caching for long running tasks

## related: http://cran.r-project.org/web/packages/R.cache/R.cache.pdf

cache_it <- function(expr, filePrefix="cache"){
    cacheFile <- paste0(filePrefix, "_", substr(digest::digest(deparse(expr)), 1, 6)) %>% paste0(".", ., ".RData")

    if (file.exists(cacheFile)) {
        local(get(load(cacheFile)))
    } else {
        result <- eval(expr)
        save(result, file = cacheFile)
        result
    }
}

## Examples
#mydata <- quote(iris %>% filter(Species=="setosa")) %>% cache_it("tt")
#mydata <- quote(iris %>% filter(Species=="setosa")) %>% cache_it()
#mydata <- quote( { print("evaluate expr"); iris %>% filter(Species=="setosa") } ) %>% cache_it()

########################################################################################################################
#### File System

is.directory <- function(dirname) ! is.na(file.info(dirname)$isdir)


mcdir <- function(dirname){
    if (! file.exists(dirname)) {
        dir.create(dirname)
    }

    setwd(dirname)
}

locload <- function(fileName) local(get(load(fileName)))


## tbd: it would be more efficient to use Reduce here (see http://stackoverflow.com/questions/34344214/how-to-join-multiple-data-frames-using-dplyr)
rmerge <- function(LDF, by, ...){
    DF <- LDF[[1]]
    for (i in 2 : length(LDF)) {
        DF <- merge(DF, LDF[[i]], by = by)
    }
    DF
}


trim_ext <- function(fileNames, ...){
    for (fileExt in list(...)) {
        fileNames <- str_replace(fileNames, paste(fileExt, "$", sep = ""), "")
    }

    fileNames
}


# see https://stackoverflow.com/questions/7201341/how-can-2-strings-be-concatenated
'%s+%' <- function(x, y)paste0(x,y)

rmSomeElements <- function(vec, toDel) vec[! (vec %in% toDel)]

rmLastElement <- function(vec) vec[- length(vec)]


########################################################################################################################
## Memory management


# improved list of objects
lsos <- function (pos = 1, pattern, order.by, decreasing=FALSE, head=FALSE, n=5) {
    napply <- function(names, fn) sapply(names, function(x) fn(get(x, pos = pos)))
    names <- ls(pos = pos, pattern = pattern)

    obj.class <- napply(names, function(x) as.character(class(x))[1])
    obj.mode <- napply(names, mode)
    obj.type <- ifelse(is.na(obj.class), obj.mode, obj.class)
    obj.size <- napply(names, object.size) / 1000000
    obj.dim <- t(napply(names, function(x)

    as.numeric(dim(x))[1 : 2]))
    vec <- is.na(obj.dim)[, 1] & (obj.type != "function")
    obj.dim[vec, 1] <- napply(names, length)[vec]

    out <- data.frame(obj.type, obj.size, obj.dim)
    names(out) <- c("Type", "Size", "Rows", "Columns")

    if (! missing(order.by))
    out <- out[order(out[[order.by]], decreasing = decreasing),]

    if (head)out <- head(out, n)

    out <- transform(out, var_name = rownames(out))
    rownames(out) <- NULL
    arrange(out, Size)
}

# shorthand that just shows top 1 results
lsosh <- function(..., n=10) {
    lsos(..., order.by = "Size", decreasing = TRUE, head = TRUE, n = n)
}

########################################################################################################################
### Statistics


## outlier handling
trim_outliers <- function(values, probs=c(0.05, 0.95)){
    # values = deResults$pvalue
    stopifnot(length(probs) == 2)
    quantiles = quantile(values, probs, na.rm = TRUE)

    pmax(quantiles[1], pmin(quantiles[2], values))
}

## use trim_outliers instead
#limit_range <- function(values, range)  pmax(range[1], pmin(range[2], values))

se <- function(x) sd(x, na.rm = TRUE) / sqrt(sum(! is.na(x)))

# https://stackoverflow.com/questions/43627679/round-any-equivalent-for-dplyr/46489816#46489816
round_any = function(x, accuracy, f=round){f(x/ accuracy) * accuracy}


########################################################################################################################
### Misc

## inspired by http://stackoverflow.com/questions/8343509/better-error-message-for-stopifnot
assert <- function (expr, error) {
    if (! expr) stop(error, call. = FALSE)
}

all_unique = function(elements) length(unique(elements)) == length(elements)

### table rendering
table_browser <- function(df, caption=deparse(substitute(df)), ...){
    install_package("data.table")
    datatable(df, filter = "bottom", extensions = 'Buttons', options = list(dom = 'Bfrtip', buttons = c('copy', 'csv', 'excel')), caption = caption, ...)
}

#results_prefix = "env_data_prep"
add_prefix = function(filename) {
    ## prefix a name with a project-prefix. Requires that results_prefix to be defined
    prefixName=if_else(str_length(results_prefix)==0, basename(filename), paste0(results_prefix, ".", basename(filename)))

    file.path(dirname(filename), prefixName)
}

## https://stackoverflow.com/questions/18669886/how-to-unfold-user-and-environment-variable-in-r-language/46240642#46240642
interp_from_env = function(path){
    # DEBUG path="${genomeFasta}.algncounts.txt"
    e <- new.env()
    env = Sys.getenv() %>% purrr::discard(~ str_detect(.x, fixed("()")))
    paste0(make.names(names(env)), "='", gsub("'", '', env) %>% str_replace_all(fixed("\\"), ""), "'") %>%
        map(~eval(parse(text=.), envir=e))
    # (system("export", intern=T) %>% str_split_fixed(" ", 2))[,2] %>% map(~eval(parse(text=.), envir=e))
    glue::glue(path, .envir=e, .open="${")
}

# #usage examples
# require(stringr)
# read.delim(interp_from_env("${PRJ_DATA}/foo.txt") )
# source(interp_from_env("${HOME}/bar.R"))