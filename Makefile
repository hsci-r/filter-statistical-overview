knitopts = echo=F, warning=F, message=F

default: output

output: \
  docs/overview.nb.html

docs/%.nb.html: docs/%.Rmd
	Rscript -e "rmarkdown::render(here::here('$<'),output_format='html_notebook',output_file=here::here('$@'))"
