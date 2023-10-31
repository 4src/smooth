![](https://img.shields.io/badge/tests-passing-green)
![](https://img.shields.io/badge/Lua-2C2D72?logo=lua&logoColor=white&style=plastic)
![](https://img.shields.io/badge/purpose-xai,_optimization-blue)
![](https://img.shields.io/badge/platform-mac,_linux-orange)
[![](https://img.shields.io/badge/license-BSD2-yellow)](LICENSE.md)
          
[home](/README.md) :: [automate](/docs/automated.md)

# Automated Everything

There is no trick to being a better programmer. Just find repeated patterns 
in your processing and automated them. Here are some examples of that. None of the
following are very profound but when ten million programmers all get together
to automate all their tiny tasks, well, then you get the modern software world.
 

## Example1 : faster github-ing

For example, I save to my private working branch about a hundred times a day.
So to save my fingers, I create a `Makefile`[^make] so I can just `make saved`. And
while I'm doing that, I may as well add an `ok` rule for updating the local files:
```makefile
help:  ## show help
	gawk 'BEGIN {FS = ":.*?## "} \
	     /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m : %s\n", $$1, $$2} \
		 ' $(MAKEFILE_LIST)

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

## Example1 : pre-commit hooks

Another more interesting example is running a local test suite then updating
the badges on the main `README.md` file to (e.g.) include
![](https://img.shields.io/badge/tests-passing-green) (if all the tests pass).

So, its back to that `Makefile`. There is a standard UNIX command called `sed`
which we can use to skip over the first line (using `sed 1d`, where `d` is short
for `delete`). Then we add an `all` flag to our `lua eg.lua` test suite which

- runs all tests
- returns the number of failures 

The `if-then-else` in this rule uses that result to decide which badge
to place on top of `README.md`.

```makefile
n="![](https://img.shields.io/badge/tests-failing-red)"
y="![](https://img.shields.io/badge/tests-passing-green)"

tested: ## run tests, update README badge
	cd $(smooth)/src ;                                                \
	if lua eg.lua all; then echo $y > _tmp ; else echo $n > _tmp; fi; \
	sed 1d $(smooth)/README.md >> _tmp;                                  \
 	mv _tmp $(smooth)/README.md 
```
Long story short, now if I type `make tested`, I get all my tests run and
the `README.md` badge update.

[^make]:  A `Makefile` is a set of rules of the form `target: prerequistes; code`.
If `target` is older than `prerequistes`, then `code` is run to rebuild the target.
This means that the **second** time you run a `Makefile`, it only updates the least
number of things that need changing.
I use `Makefile`s since they are available on most platforms
(and for something more  modern,
see the [`just`](https://github.com/casey/just) command favored by some
RUST programmers). To learn more on `Makefile`, see 
[Alex Tan's great short tutorial](https://alextan.medium.com/makefile-101-56ba4590025b)
or some [longer notes](https://swcarpentry.github.io/make-novice/index.html).

