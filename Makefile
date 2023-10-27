SHELL = /bin/bash
MAKEFLAGS += --silent
ok: ##               pull
	git pull

saved: ##               commit
	git commit -am saving; git push; git status

%.md: %.lua ## file.md  insert snips from code into markdown
	gawk -f etc/snips.awk PASS=1 $< PASS=2 $< > _tmp
	mv _tmp $@

n=--source 'NR==1{ print "![](https://img.shields.io/badge/tests-failing-red)"; next}   1'  
y=--source 'NR==1{ print "![](https://img.shields.io/badge/tests-failing-green)"; next} 1' 

 tested: ##              run tests, update README badge
	if lua eg.lua all 1>&2; then gawk  $y README.md;  else gawk  $n README.md; fi> _tmp
	mv _tmp README.md
	
help:  ##               show help
	@echo ""; echo "ACTIONS:"
	@gawk '/^[a-z].*:/ && /##/ { a=$$1; sub(/^.*##/,""); print "\t" a"  " $$0 }' Makefile  

install-codespaces: ## install packages on codespaces
	for x in gawk lua5.3 ispell; do (which $$x) > /dev/null || apt-get install $$x; done

install-mac: ##        install packages on mac
	@echo ""; echo "WARNING: this crashes inside vscode; best to run in standard terminal."; echo ""
	@for x in gawk lua@5.3 ispell; do (which $$x) > /dev/null || brew install $$x; done