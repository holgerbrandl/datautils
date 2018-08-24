# rnblight

Update markdown result chunks in markdown documents

```bash
cd /Users/brandl/Dropbox/projects/datautils/R/rnblight
#cp /Users/brandl/Dropbox/documents/datascience/chi2.md rerender/
#cp -r /Users/brandl/Dropbox/documents/datascience/.chi2_images rerender/
#
#git init
#git add chi2.md
#git commit -m "initial commit"

mdInput=example.md
mdBase=$(basename $mdInput .md)

cp $mdInput ${mdBase}.Rmd


kscript --idea strip_chunk_results.kts
kscript  strip_chunk_results.kts ${mdBase}.md

Rscript - <<"EOF"
knitr::knit('${mdBase}.Rmd', '${mdBase}.md')
EOF

idea .


```