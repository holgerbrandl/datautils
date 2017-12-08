
dt.merge <- function(dfA, dfB, by=intersect(names(dfA), names(dfB)) , ...)  {
    warning("Deprecated: use dplyr instead!")

    load_pack(data.table)

    #    require(data.table)
    as.df(merge(data.table(dfA, key=by), data.table(dfB, key=by), ...))
#    unloadNameSpace(data.table)
}



#   http://stackoverflow.com/questions/11792527/filtering-out-duplicated-non-unique-rows-in-data-table
unique_rows <- function(df, columns){
    warning("Deprecated: use dplyr instead!")

    load_pack(data.table)

    unique(setkeyv(data.table(df), columns)) %>% as.df()
}
