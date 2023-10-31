![](https://img.shields.io/badge/tests-passing-green)
![](https://img.shields.io/badge/Lua-2C2D72?logo=lua&logoColor=white&style=plastic)
![](https://img.shields.io/badge/purpose-xai,_optimization-blue)
![](https://img.shields.io/badge/platform-mac,_linux-orange)
[![](https://img.shields.io/badge/license-BSD2-yellow)](LICENSE.md)

# Automated Everything

There is no trick to being a better programming. Just find repeated patterns 
in your processing and automated them.

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

So, its back to that `Makefile`