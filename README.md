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
