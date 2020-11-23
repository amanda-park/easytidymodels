
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

This is a basic example of one splitting data in the package. The
function trainTestSplit is a wrapper for rsample’s function that allow
you to nicely split up your data into training and testing sets. For
reusability’s sake it has been put into a function here.

``` r
library(easytidymodels)

#Simulate data
df <- data.frame(var1 = as.factor(c(rep(1, 50), rep(0, 50))),
                 var2 = rnorm(100),
                 var3 = c(rnorm(55), rnorm(45, 5)),
                 var4 = rnorm(100))

split <- trainTestSplit(data = df, 
                        responseVar = var1)

#Create training, testing, and bootstrapped data sets
train_df <- split$train
test_df <- split$test
boot_df <- split$boot

#Create cross-validation folds
folds <- cvFolds(train_df, 5)
```
