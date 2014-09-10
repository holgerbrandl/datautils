require(stringr);
require(dplyr);

#readLines(file("stdin")) %>%
mdRegex <- "^#([#]*)> ([^{]*)([{]+(.+)[}])?"


#str_match("##> test heading", mdRegex)
#str_match("##> test heading {fig.width=10}", mdRegex)
#str_match("#> simple markup", mdRegex)
#str_match("#>  {fig.width=10}", mdRegex)

readLines(file("/Users/brandl/Dropbox/Public/datautils/R/rknit/rknit_example.R")) %>%
    str_replace(mdRegex, "```\n\\1 \\2\n```{r \\4}") %>% paste(collapse="\n") %>% cat(stdout())

