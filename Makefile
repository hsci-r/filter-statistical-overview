knitopts = echo=F, warning=F, message=F

default: output

clean:
	rm -rf docs

output: \
  docs/overview.html \
  code/overview.nb.html

docs/%.html: code/%.Rmd
	mkdir -p docs
	Rscript -e "rmarkdown::render(here::here('$<'),output_format='html_document',output_file=here::here('$@'))"

code/%.nb.html: code/%.Rmd
	Rscript -e "rmarkdown::render(here::here('$<'),output_format='html_notebook',output_file=here::here('$@'))"

.PHONY: clean
