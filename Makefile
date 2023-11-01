# shorter tutorial on make https://alextan.medium.com/makefile-101-56ba4590025b
# longer notes tut https://swcarpentry.github.io/make-novice/index.html
# https://hoelz.ro/ref/makefile-tips-and-tricks
# an alternative to make: https://github.com/casey/just

ifndef LOUD # disable with make LOUD=1
.SILENT: 
endif

NEED = lua gawk
OK := $(foreach x,$(NEED),$(if $(shell which $(x)),"",$(error no $(x) in PATH)))

SHELL     := bash 
MAKEFLAGS += --warn-undefined-variables
smooth=$(shell git rev-parse --show-toplevel)
.PHONY: help run ready saved tested install-codespaces install-mac
#------------------------------------------------------------------------------
help:  ## show help
	gawk 'BEGIN {FS = ":.*?## "}                                               \
	     /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m : %s\n", $$1, $$2} \
		 ' $(MAKEFILE_LIST)
	
#------------------------------------------------------------------------------
it ?= all
run: ## it=eg run
	lua eg.lua $(it) 
#------------------------------------------------------------------------------
ready: ## pull
	git pull

saved: ## commit
	git commit -am saving; git push; git status
#------------------------------------------------------------------------------
BODY='BEGIN {RS=""; FS="\n"} NR==1 { next } { print($$0 "\n")  }'
HEAD='BEGIN {RS=""; FS="\n"} NR==1 { print($$0 "\n"); exit }'

%.md: ## file.md  insert snips from code into markdown
	echo "# filling in $@ ..."
	gawk --source $(HEAD) $(smooth)/README.md >  _in
	gawk --source $(BODY) $@                  >> _in
	awk -f $(smooth)/etc/snips.awk PASS=1 $(smooth)/src/*.lua  PASS=2 _in > _out
	mv _out $@; rm _in

#------------------------------------------------------------------------------
n="![](https://img.shields.io/badge/tests-failing-red)"
y="![](https://img.shields.io/badge/tests-passing-green)"

tested: ## run tests, update README badge
	cd $(smooth)/src ;                                                \
	if lua eg.lua all; then echo $y > _tmp ; else echo $n > _tmp; fi; \
	sed 1d $(smooth)/README.md >> _tmp;                                  \
 	mv _tmp $(smooth)/README.md 
#------------------------------------------------------------------------------
install-codespaces: ## install deppendancies on codespaces
	for x in gawk lua5.3 ispell; do (which $$x) > /dev/null || apt-get install $$x; done

install-mac: ## install deppendancies on mac
	printf "\nWARNING: can crash inside vscode; maybe run in standard terminal?\n\n"
	for x in gawk lua@5.3 ispell; do (which $$x) > /dev/null || brew install $$x; done
