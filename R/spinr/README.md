spin.R: A shell-wrapper for knitr::spin
===


Installation
---

Download a local copy and add it to your path using
```
targetDirectory=~/bin
wget -P $targetDirectory https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/spinr/spin.R
chmod +x $targetDirectory/spin.R
export PATH=$targetDirectory:$PATH
```


Usage
---

To use it from a shell you can call spin.R directly with a script as argument.
```
spin.R MyScript.R
```
The report will be created in the current working directory. To learn about options just call `spin.R --help`

In case you want to spin snippets you can source a small bash function that wraps spin.R
```
source <(curl https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/spinr/spin_utils.sh 2>&1 2>/dev/null)
```
Now you can spin R snippets by piping them into `spinsnip`

```
echo "require(ggplot2); ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()" | spinsnip "my_report"
```




