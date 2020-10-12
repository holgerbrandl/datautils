# `datautils`

Some little [R](http://r-project.org/) helpers to work with data, and bio-data in particular.

To use them just source them when needed.

Use the issue tracker to suggest changes or to report problems. Feel welcome to suggest changes to or send pull requests.

R
===

The R bits are split up into tools for
* general data handling, see [`core_commons.R`](R/core_commons.R)
* plotting using ggplot2, see [`ggplot_commons.R`](R/ggplot_commons.R)
* bioinformatics using various bioconductor packages, see [`bioinfo_commons.R`](R/bio/bioinfo_commons.R)

and some more.

```
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/core_commons.R")
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/ggplot_commons.R")
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/bio/bioinfo_commons.R")
```


Installation
============

To install as package run
```
install.packages("remotes")
remotes::install_github("holgerbrandl/datautils")
```

or from local working copy with

```
devtools::install_local("/path/to/workingcopy")
# devtools::install_local("d:/projects/misc/datautils")
```

To allow for reproducible research, we prefer [version tags](https://github.com/holgerbrandl/datautils/releases) over cran deployment. You can use these tags to write our workflows. Eg. you could use the stable `v1.45` tag

```
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.45/R/core_commons.R")
```

Instead to use the latest master-branch version (which is subject of constant change) use

```
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/datatable_commons.R")
```


### How to serve locally?


Launch local file server in directory where files are located
```
python -m http.server & 
```

Use the local server to source the files

```
devtools::source_url("http://localhost:8000/core_commons.R")
```


### Install development version locally

```
devtools::install(".")
```