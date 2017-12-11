
## install as package

```bash
R -e "devtools::create('tt')" 
# move DESCRIPTION and NAMESPACE


```

in R we can load the package from sources with

```r
devtools::load_all()
```
will just load toplevel scripting directly under `R/`

further reading https://uoftcoders.github.io/studyGroup/lessons/r/packages/lesson/

https://github.com/jtleek/rpackages


## module system for namespace isolation

How to organize large R programs? https://stackoverflow.com/a/1319786/590437

```
util = new.env()

util$bgrep = function \[...\]

util$timeit = function \[...\]

while("util" %in% search())
  detach("util")
attach(util)

```


1. export nothing

http://r-pkgs.had.co.nz/namespace.html#exports

2. load

https://stackoverflow.com/questions/3094232/add-objects-to-package-namespace

```r
myfun <- function(x) print(x)
environment(myfun) <- as.environment("package:foo")



```

## how to install package with multiple namespaces


https://stackoverflow.com/questions/9002544/how-to-add-functions-in-an-existing-environment

`klmr`

docke testing

```bash
docker pull rocker/tidyverse
docker run --rm -it rocker/tidyverse /bin/bash
 

```

```r
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.43/R/core_commons.R")

devtools::install_github('klmr/modules')

## install the package
devtools::install_github("holgerbrandl/datautils")
## or install a specific tag within
install_github("holgerbrandl/datautils@v0.4")
## or from local dir
devtools::install_local("/Users/brandl/Dropbox/projects/datautils")

# options(import.path = "/Users/brandl/Library/R/3.4/library")
# options(import.path = .libPaths()[1])
options(import.path = .libPaths())

## load the package binaries (top-level scripts under R)
# modules::import_package('datautils')
## rather al
modules::import('datautils/stats/ci_commons')


## loadd it, which will export nothing by default
require(datautils) 

## import a source file from within the package
modules::import('bio/bioinfo_commons')

```

```
cd ~/Library/R/3.4/library/datautils/
```


## inst vs R

See https://stackoverflow.com/questions/954560/how-does-git-handle-symbolic-links

So maybe we can keep existing paths but also provide them via `inst`.

