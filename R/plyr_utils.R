
require(data.table)

#   http://stackoverflow.com/questions/11792527/filtering-out-duplicated-non-unique-rows-in-data-table
unique_rows <- function(df, columns){
    unique(setkeyv(data.table(df), columns)) %>% as.df()
}
