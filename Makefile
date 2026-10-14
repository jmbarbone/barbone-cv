.PHONY: help $(MAKECMDGOALS) # make everything run
.ONESHELL:

help: ## Display this help screen
# 	@cat $(MAKEFILE_LIST) | docker run --rm -i xanders/make-help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'
# 	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done


all: ## Runs 'setup', 'refresh', and 'render' in order 
	$(MAKE) setup
	$(MAKE) refresh
	$(MAKE) render

setup: ## Install required packages and load the package
	Rscript - << 'EOF'
	pak::pak(c("pandoc", "devtools"))
	pandoc::pandoc_install("3.4", force = TRUE)
	devtools::load_all()
	EOF

refresh: ## Update the bibliography files and download the citation style file
	Rscript - << 'EOF'
	pak::pak(c("devtools", "pak", "knitr", "RefManageR", "fs", "here"))
	devtools::load_all()
	file.remove(list.files("bib", full.names = TRUE))
	update_packages_bib()
	update_references_bib()
	EOF
	curl -fsSL \
	  https://raw.githubusercontent.com/citation-style-language/styles/master/apa-cv.csl \
	  -o csl/apa-cv.csl

render: ## Render the resume and CV
	Rscript - << 'EOF'
	library(scribe, lib = Sys.getenv("R_LIBS_SCRIBE"))
	devtools::load_all()
	pandoc::pandoc_activate("3.4")
	quarto::quarto_render("resume.qmd")
	quarto::quarto_render("cv.qmd")
	withr::with_options(list(cli.width = 80), sessioninfo::session_info(to_file = TRUE))
	EOF

cv: ## Render the CV
	Rscript - << 'EOF'
	library(scribe, lib = Sys.getenv("R_LIBS_SCRIBE"))
	devtools::load_all()
	pandoc::pandoc_activate("3.4")
	quarto::quarto_render("cv.qmd")
	withr::with_options(list(cli.width = 80), sessioninfo::session_info(to_file = TRUE))
	EOF

resume: ## Render the resume
	Rscript - << 'EOF'
	library(scribe, lib = Sys.getenv("R_LIBS_SCRIBE"))
	devtools::load_all()
	pandoc::pandoc_activate("3.4")
	quarto::quarto_render("resume.qmd")
	withr::with_options(list(cli.width = 80), sessioninfo::session_info(to_file = TRUE))
	EOF

clean: ## Remove generated files
	rm -f Barbone-CV.pdf Barbone-Resume.pdf sessioninfo.txt
