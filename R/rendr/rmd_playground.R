## [rmarkdown@rstudio](http://rmarkdown.rstudio.com/)

rmarkdown::render(input="/Users/brandl/Dropbox/projects/snippets/R/rmarkdown/test_doc.R",
    output_format=rmarkdown::html_document(toc = T, keep_md=F),
    output_dir=getwd(),
    output_options=list(toc="yes"))