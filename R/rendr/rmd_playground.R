
## see ?compile_notebook

## [rmarkdown@rstudio](http://rmarkdown.rstudio.com/)

rmarkdown::render(input="/Users/brandl/Dropbox/projects/snippets/R/rmarkdown/test_doc.R",
#    output_format=rmarkdown::html_document(toc = T, keep_md=T, pandoc_args="--include-in-header=/var/folders/n4/vdks_qcx54db16yj2lg665lm0000gp/T//RtmpysrYQU/file202b60316743.js"),
    output_format=rmarkdown::html_document(toc = T, keep_md=T, pandoc_args="-H/var/folders/n4/vdks_qcx54db16yj2lg665lm0000gp/T//RtmpysrYQU/file202b60316743.js"),
    output_dir=getwd(),
    output_options=list(toc="yes"))



#' # Pandoc

#' All options are listed at http://pandoc.org/README.html and can be used as "pandoc_args" in html_document

#' yaml header is parsed in https://github.com/rstudio/rmarkdown/blob/a46a78fa241e86170a6bb3db02cfb9342ccc86a2/R/render.R