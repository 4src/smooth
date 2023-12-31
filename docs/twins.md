![](https://img.shields.io/badge/tests-passing-green)
![](https://img.shields.io/badge/Lua-2C2D72?logo=lua&logoColor=white&style=plastic)
![](https://img.shields.io/badge/purpose-xai,_optimization-blue)
![](https://img.shields.io/badge/platform-mac,_linux-orange)
[![](https://img.shields.io/badge/license-BSD2-yellow)](LICENSE.md)
          
[home](/README.md) :: [make](/docs/make.md)

# Analysis Twins

_A is really B_
- stuff for _A_ can be used for _B_ (and vide versa)
_ there is a simpler way to do _A_ and _B_
- that simpler way is somehow better (easier to build, faster to run, better performance)

## Clutering and Naive Bayes


Clustering = grouping together similar rows.

NB = group together all the rows from each class.

NB + Clustering:
- data structures used for clustering can serve as the classifier.

## otpmization + classification
(see the duo paper)

## explanation = cluster + contrast

## test case generation = cluster + sub-sample

## fairness = cluster + sub-sample

## optimzation = cluster + chop

clustering over two spaces 

![](/etc/img/spaces.png)

## anomaly detection = cluster + outlier

## Naive Bayes = outlier

## explore = classify + boundary check

cluster data, 

theory (which we did not know). manifold. any high dimensional dataset can be randomly projected into a lower dimensional Euclidean space while controlling the distortion in the pairwise distances. 
<a href="https://scikit-learn.org/stable/auto_examples/miscellaneous/plot_johnson_lindenstrauss_bound.html">Examples</a>.

another point of theory (which i did not know) is that the space of relevant examples (where "relevant" means "other examples at distance d, or less) shrinks away to nothing as the dimnsionalirt gets higher. consider euclidean distance $d=\sqrt{ (x_1-y_1)^2 + (x_2-y_2)^2 + ...)}$. For constant distance (say $d=1$) and $n$ dimensions and 
points being  equidistant, this becomes r dots $1=\sqrt{ n(x_1-y_1)^2}$ which rearranges to
$(x_1-y_1)= \frac{1}{\sqrt{n}}$, which is to say that as the dimensionality grows, the space between points shrinks. 
history: classifiers have different goals (recall, false alarm, if we tune for those goals, we get a radically different and better result) 

<a href="https://www.google.com/search?q=plot+y%3D1%2Fsqrt%28n%29&sca_esv=587322845&rlz=1C5GCEM_enUS1034US1034&ei=qXdrZfidD9LHkPIPvqmymAY&ved=0ahUKEwi4lomVsfGCAxXSI0QIHb6UDGMQ4dUDCBA&uact=5&oq=plot+y%3D1%2Fsqrt%28n%29&gs_lp=Egxnd3Mtd2l6LXNlcnAiEHBsb3QgeT0xL3NxcnQobikyBRAhGKABSPkDUKoBWKoBcAF4AZABAJgBywGgAcsBqgEDMi0xuAEDyAEA-AEBwgIKEAAYRxjWBBiwA-IDBBgAIEGIBgGQBgg&sclient=gws-wiz-serp">
$z= \frac{1}{\sqrt{n}}$</a>

For data that is not uniformly distributed, the size of the space of relevant examples shrinks even faster. To see this, consider the volume of an $n$-dimensional sphere. $V_2( r )={\pi}r^2$ and $V_3( r )=\frac{4}{3}{\pi}r^3$ and, more geerally,  $V_{n>3}( r )= \frac{{2\pi}r^2}{n} V_{n-2}( r )$. Now consider the same definition of "relevant" used above,  i.e. $r=1$ (which is called the _unit sphere_) for $n>2\pi$. Observe how after $n=6$, the volume starts strinking 
<a href="https://ontopo.files.wordpress.com/2009/03/unit-hypersphere.png">(and hits zero at $n=20$)</a>.

To say that other ways: 

- the more dimensions you explore, the less likely you can find data to validate that model.  
- the more distinctions you make, the harder it becomes to valdiate your reasoning;
- trustable models are low dimensional
- if you have a high dimensional model, find ways to reduce that complexity into something you can manager or validate.

e.g. the [MOEA/D algorithm](https://sites.google.com/view/moead/) divides big problems into lots of simpler ones. 

- Each canidate solution is defined by a set of weights the show what that candidate cares about. 
- Before optiizing, each canidate finds its (say) $k=20$ nearest neighbors (where ``near'' means  similar set of goal wiehgts)
- During optimiztion, if anyone finds any improvement, it shouts to neighbors "hey follow me!" and that entire enighborhood takes a step in same direction

(If you want an analogy, suppose fans of Taylor Swift and Beyoncé’ all attend the same conference. If one fan finds across somewhere to buy a really cool t-shirt of their favorite star, they call over some their most like-minded friends.)

optimize: vide and conqueor. find groups with moea2 optimize each group sepraely . then a smistake, accidental. so clevre optimizing defeated by simple clustering

then labelling: classifeirs need labels, what if labels are wrong? lead to methods to reduce the labelling. cluster then one sample per cluster. better performance and, accidently, more fairness
