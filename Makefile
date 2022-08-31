knitopts = echo=F, warning=F, message=F

default: output

clean:
	rm -rf output

output: \
  output/md/overview.md

output_html: \
  output/html/overview.html

output/md:
	mkdir -p output/md

output/md/%.md: code/%.Rmd output/md
	Rscript -e "knitr::opts_knit\$$set(base.dir=here::here('output','md')); knitr::opts_chunk\$$set(fig.path = 'figures/'); knitr::opts_chunk\$$set($(knitopts)); knitr::knit('$<', output='$@')"

output/html:
	mkdir -p output/html

output/html/%.html: output/md/%.md output/html
	Rscript -e "markdown::markdownToHTML('$<', output='$@')"

.PHONY: clean
