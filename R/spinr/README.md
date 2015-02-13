A tiny wrapper around knitr::spin to use it from the terminal
===


Installation
---

Download it using
```
wget -P ~/bin https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/spinr/spin.R
```
and add it to your PATH if necessary.

To prepare a shell just source in the script which will simply define 2 bash functions.
```
source <(curl https://raw.githubusercontent.com/holgerbrandl/datautils/master/R/spinr/spin_utils.sh 2>&1 2>/dev/null)
```

Usage
---

You can spin R scripts with
```
spinr MyScript.R
```
or rsnippets with
```
echo "require(ggplot); ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()" | spinsnip "my_report" "
```




