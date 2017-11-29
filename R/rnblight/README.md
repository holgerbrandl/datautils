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

mdInput=chi2.md
mdBase=$(basename $mdInput .md)

mv $mdInput ${mdBase}.Rmd

Rscript - <<EOF
knitr::knit('${mdBase}.Rmd', '${mdBase}.md')
EOF

idea .

```