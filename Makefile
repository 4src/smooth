pull: ##               pull
	git pull

save: ##               commit
	git commit -am saving; git push; git status

%.md: %.lua ## file.md  insert snips from code into markdown
	gawk -f etc/snips.awk   PASS=1 $< PASS=2 $< > _tmp
	mv _tmp $@

bad='1c![](https://img.shields.io/badge/tests-failing-red)'
good='1c![](https://img.shields.io/badge/tests-passing-green)'
 tests: ##              run tests, update README badge
	if lua eg.lua  all; then  sed -i $(good)  README.md; else  sed -i $(bad)  README.md; fi 

help:  ##               show help
	@echo ""; echo "ACTIONS:"
	@gawk '/^[a-z].*:/ && /##/ { a=$$1; sub(/^.*##/,""); print "\t" a"  " $$0 }' Makefile  

install-codespaces: ## install packages on codespaces
	for x in gawk lua5.3 ispell; do (which $$x) > /dev/null || apt-get install $$x; done

install-mac: ##        install packages on codespaces
	@echo ""; echo "WARNING: this crashes inside vscode; best to run in standard terminal."; echo ""
	@for x in gawk lua@5.3 ispell; do (which $$x) > /dev/null || brew install $$x; done