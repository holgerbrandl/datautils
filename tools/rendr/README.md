rend.R - A shell-wrapper for rmarkdown::render
===


Installation
---

Download a local copy and add it to your path using
```
targetDirectory=~/bin/rendr
mkdir -p $targetDirectory
wget -NP $targetDirectory --no-check-certificate https://raw.githubusercontent.com/holgerbrandl/datautils/master/tools/rendr/rend.R
chmod +x $targetDirectory/rend.R
echo 'export PATH='"$targetDirectory"':$PATH' >> ~/.bash_profile
```


Usage
---

To use it from a shell you can call rend.R directly with a script as argument.
```
rend.R MyScript.R
```
or for Rmd
```
rend.R MyScript.Rmd
```

The report will be created in the current working directory. To learn about options just call `rend.R --help`

In case you want to render R snippets you can source a small bash function that wraps rend.R
```
source <(curl https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/rendr/rendr_utils.sh 2>&1 2>/dev/null)
```
Now you can spin R snippets by piping them into `spinsnip`

```
echo "require(ggplot2); ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()" | rendr_snippet "my_report"
```




