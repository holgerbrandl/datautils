A tiny wrapper around knitr::spin to use it from the terminal
===

To prepare a shell source in the script
source <(curl https://dl.dropboxusercontent.com/u/113630701/datautils/bash/bioinfo_utils.sh 2>&1 2>/dev/null)


To use them just source them when needed.

Use the issue tracker to suggest changes or to report problems

Bash
===

LSF Cluster Utils:
```
source <(curl https://dl.dropboxusercontent.com/u/113630701/datautils/bash/lsf_utils.sh 2>&1 2>/dev/null)
```

Tools to simplify bio-dataprocessing in bash
```
```


R
===

The R bits are split up into tools for
* general data handling
* plotting using ggplot2
* bioinformatics using various bioconductor packages

```
devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/core_commons.R")
devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/ggplot_commons.R")
devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/bio/bioinfo_commons.R")
devtools::source_url("https://dl.dropboxusercontent.com/u/113630701/datautils/R/datatable_commons.R")
```
