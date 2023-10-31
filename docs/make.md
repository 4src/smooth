![](https://img.shields.io/badge/tests-passing-green)
![](https://img.shields.io/badge/Lua-2C2D72?logo=lua&logoColor=white&style=plastic)
![](https://img.shields.io/badge/purpose-xai,_optimization-blue)
![](https://img.shields.io/badge/platform-mac,_linux-orange)
[![](https://img.shields.io/badge/license-BSD2-yellow)](LICENSE.md)
          
[home](/README.md) :: [make](/docs/make.md)

# Making it Automatic (with Makefiles)

There is no trick to being a better programmer. Just don't waste your time
on repeatitive tasks.  Once you find yourself doing the same thing over and over and over 
again, code it up so that the next time you need that, it can be done automatically.

(Aside: remember the rule of three. First time, just do it. Second time, just remember
you've done this before. But if you get there a third time, then stop and refactor
and automate so that from now on, you can work faster by reusing something pre-coded.)

## Makefiles

Once trick for doing that is `Makefiles`. A `Makefile` is a set of rules of the form 

```
target: prerequistes
    code
```

If `target` is older than `prerequistes`, then `code` is run to rebuild the target.
This means that the **second** time you run a `Makefile`, it only updates the least
number of things that need changing.

To learn more on `Makefile`, see 
[Alex Tan's great short tutorial](https://alextan.medium.com/makefile-101-56ba4590025b)
or some [longer notes](https://swcarpentry.github.io/make-novice/index.html).

I use `Makefile`s since they are available on most platforms but if you prefer
something more modern, then check out the 
 [`just`](https://github.com/casey/just) command favored by some
RUST-ifarians.

## Example1 : Making Github Easier

 I save to my private working branch about a hundred times a day.
So to save my fingers, I create a `Makefile` so I can just `make saved`. And
while I'm doing that, I may as well add an `ok` rule for updating the local files:
```makefile
help:  ## show help
	gawk 'BEGIN {FS = ":.*?## "} \
	     /^[a-zA-Z_-]+:.*?## / {  \
		    printf "\033[36m%-20s\033[0m : %s\n", $$1, $$2} \
		 ' $(MAKEFILE_LIST)make tested

saved: ## commit
	git commit -am saving; git push; git status

ok: ## pull
	git pull
```

The `help` rule on top is the standard "self-documenting Makefile" trick
where comments after a `##` are pretty pretty to the terminal. So now if I just
type `make`:

```
> make
help       show help
saved      commit
ok         pull
```

## Example2 : Making Installs Easier

Installing things on different platforms is a little tricky since each plaform
has its quirks. So I write one install rule for each:

```makefile
install-codespaces: ## install deppendancies on codespaces
	for x in gawk lua5.3 ispell; do (which $$x) > /dev/null || apt-get install $$x; done

install-mac: ## install deppendancies on mac
	printf "\nWARNING: can crash inside vscode; maybe run in standard terminal?\n\n"
	for x in gawk lua@5.3 ispell; do (which $$x) > /dev/null || brew install $$x; done
```

Just to be complete, the following code (at the **TOP** of the `Makefile`), aborts
the make if  something important is missing 

```makefile
NEED = lua gawk
OK := $(foreach x,$(NEED),$(if $(shell which $(x)),"",$(error no $(x) in PATH)))
```

## Example3 : Making Testing Easier

Another more interesting example is running a local test suite then updating
the badges on the main `README.md` file to (e.g.)  
![](https://img.shields.io/badge/tests-passing-green) (if all the tests pass).

So, its back to that `Makefile`. 
With a few little tweaks, if I type `make tested`, then I get all my tests executed and
the `README.md` badge update.

```makefile
n="![](https://img.shields.io/badge/tests-failing-red)"
y="![](https://img.shields.io/badge/tests-passing-green)"

tested: ## run tests, update README badge
	cd $(smooth)/src ;                \
	if lua eg.lua all; then echo $y > _tmp ; else echo $n > _tmp; fi; \
	sed 1d $(smooth)/README.md >> _tmp;  \
 	mv _tmp $(smooth)/README.md 
```

To explain the above,
there is a standard UNIX command called `sed`
which we can use to skip over the first line (using `sed 1d`, where `d` is short
for `delete`). Then we add an `all` flag to our `lua eg.lua` test suite which

- runs all tests
- returns the number of failures 

The `if-then-else` in this rule uses that result to decide which badge
to place on top of `README.md`.

