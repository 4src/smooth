![](https://img.shields.io/badge/tests-passing-green)
![](https://img.shields.io/badge/Lua-2C2D72?logo=lua&logoColor=white&style=plastic)
![](https://img.shields.io/badge/purpose-xai,_optimization-blue)
![](https://img.shields.io/badge/platform-mac,_linux-orange)
[![](https://img.shields.io/badge/license-BSD2-yellow)](LICENSE.md)
          
[home](/README.md) :: [make](/docs/make.md)

# Homeworks



1. DSL for data. Load csv files into a _DATA_ object. Report `DATA(file):stats()`
2. Naive Byaes for data. Load data into multiple _DATA_ objects (one for class).
   Read the data one row at time, adding it different class tables. After 20 rows, then BEFORE adding, gues which class it most
   likely belongs to. Add 1 to an `accuracy` counter if that guess is correct. At the end, divide that counter by the number of guesses.
   Report your accuracies. 
3. Lazy learning (Knn). Add distance functions. Load all data into one DATA object. When new daa arrives, find its five closest items.
   Classify the new data via the mode of the k=5 nearest. Score accuracy as per hw2. Report which results in higher accuracies? Naive Bayes or kNN?
