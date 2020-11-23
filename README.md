
<!-- README.md is generated from README.Rmd. Please edit that file -->

# easytidymodels

<!-- badges: start -->

<!-- badges: end -->

The goal of easytidymodels is to make running analyses in R using the
tidymodels framework even easier.

## Installation

You can install easytidymodels like this

``` r
# install.packages("devtools")
devtools::install_github("easytidymodels")
```

## Example

This is a basic example of one function in the package:

``` r
library(easytidymodels)

df <- data.frame(var1 = c(rep(1, 50), rep(0, 50)),
                      var2 = rnorm(100),
                      var3 = c(rnorm(55), rnorm(45, 5)))

split <- trainTestSplit(data = df)

train_df <- split$train
test_df <- split$test
boot_df <- split$boot
```
