# shorter tutorial on make https://alextan.medium.com/makefile-101-56ba4590025b
# longer notes tut https://swcarpentry.github.io/make-novice/index.html

SHELL = /bin/bash
MAKEFLAGS += --silent
.PHONY: help do ready saved tested install-codespaces install-mac
root=$(shell git rev-parse --show-toplevel)
#------------------------------------------------------------------------------
C1 = '\033[34m'# blue
C2 = '\033[32m'# green
C0 = '\033[0m'#  reset

help:  ##               show help
	echo ""; echo -e $(C1)"ACTIONS:"$(C0)
	gawk '/^[a-z].*:/ && /##/ { \
	          a=$$1; sub(/^.*##/,""); print "   '$(C2)'"a"'$(C0)'  " $$0 } \
		  ' $(MAKEFILE_LIST) 
#------------------------------------------------------------------------------
it ?= all
run:    ##                it=eg run
	lua eg.lua $(it) 
#------------------------------------------------------------------------------
ready: ##              pull
	git pull

saved: ##              commit
	git commit -am saving; git push; git status
#------------------------------------------------------------------------------
../docs/%.md: ../src/%.lua ## file.md  insert snips from code into markdown
	gawk -f $(root)etc/snips.awk PASS=1 $< PASS=2 $< > _tmp
	mv _tmp $@
#------------------------------------------------------------------------------
n="![](https://img.shields.io/badge/tests-failing-red)"
y="![](https://img.shields.io/badge/tests-passing-green)"

tested: ##             run tests, update README badge
	if   cd ../src/; lua eg.lua all 1>&2;        \
	then gawk --source 'NR==1 {print $y; next} 1' $(root)/README.md;  \
	else gawk --source 'NR==1 {print $n; next} 1' $(root)/README.md; fi > _tmp
	mv _tmp $(root)/README.md 
#------------------------------------------------------------------------------
install-codespaces: ## install packages on codespaces
	for x in gawk lua5.3 ispell; do (which $$x) > /dev/null || apt-get install $$x; done

install-mac: ##        install packages on mac
	printf "\nWARNING: can crash inside vscode; maybe run in standard terminal?\n\n"
	for x in gawk lua@5.3 ispell; do (which $$x) > /dev/null || brew install $$x; done