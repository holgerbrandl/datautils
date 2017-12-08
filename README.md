Some little helpers to work with data, and bio-data in particular.

To use them just source them when needed.

Use the issue tracker to suggest changes or to report problems. Feel welcome to suggest changes to or send pull requests.

R
===

The R bits are split up into tools for
* general data handling
* plotting using ggplot2
* bioinformatics using various bioconductor packages

```
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/core_commons.R")
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/ggplot_commons.R")
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/bio/bioinfo_commons.R")
```

Bash
===

LSF Cluster Utils:
```
source <(curl https://raw.githubusercontent.com/holgerbrandl/datautils/master/bash/lsf_utils.sh 2>&1 2>/dev/null)
```

Tools to simplify bio-dataprocessing in bash
```
source <(curl https://raw.githubusercontent.com/holgerbrandl/datautils/master//bash/bioinfo_utils.sh 2>&1 2>/dev/null)
```


Versioning
===

To allow for reproducible research, we regularly create [version tags](https://github.com/holgerbrandl/datautils/releases).

Eg. you could use the stable `v1.3` tag

```
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.3/R/core_commons.R")
```

instead of the development copy form the master-branch copy

```
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/datatable_commons.R")
```

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



## how to install package with multiple namespaces


https://stackoverflow.com/questions/3094232/add-objects-to-package-namespace

```r
myfun <- function(x) print(x)
environment(myfun) <- as.environment("package:foo")



```

https://stackoverflow.com/questions/9002544/how-to-add-functions-in-an-existing-environment

docke testing

```bash
docker pull rocker/tidyverse
docker run --rm -it rocker/tidyverse /bin/bash
 

```

```r
devtools::install_github("vqv/ggbiplot")
```