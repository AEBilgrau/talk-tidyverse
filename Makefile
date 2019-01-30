
# Makefile for talk-tidyverse --------------------------------------------------

# Main file
SLIDES = talk-tidyverse

# Directories
SUBDIR = input
FIGDIR = figs

# R flags
R_OPTS = --slave --vanilla

# Files
# Rmd Child files
RMD_INPUT := $(wildcard $(SUBDIR)/*.Rmd)

# Output files
# SVG figures
SVGFIGS := $(wildcard $(FIGDIR)/*.svg)


# Rules ------------------------------------------------------------------------

slides: $(SLIDES).html

$(SLIDES).html: $(SLIDES).Rmd $(RMD_INPUT)
	Rscript $(R_OPTS) -e "rmarkdown::render('$<', 'xaringan::moon_reader')"

# Delete figures and out-files
clean:
	rm -fv $(SVGFIGS)
	rm -fv $(SLIDES).html

# Set phony targets
.PHONY: slides clean