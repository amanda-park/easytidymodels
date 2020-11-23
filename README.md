
<!-- README.md is generated from README.Rmd. Please edit that file -->

# easytidymodels

<!-- badges: start -->

<!-- badges: end -->

The goal of easytidymodels is to make running analyses in R using the
tidymodels framework even easier. This is custom code I wrote to make
the code more reproducible and avoid copy-pasting so often. Note: this
is currently a work in progress\!

## Installation

You can install easytidymodels like this:

``` r
# install.packages("devtools")
devtools::install_github("amanda-park/easytidymodels")
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

#Set response variable
resp <- "var1"


split <- trainTestSplit(data = df, 
                        responseVar = resp)

#Create training, testing, and bootstrapped data sets
train_df <- split$train
test_df <- split$test
boot_df <- split$boot

#Create cross-validation folds
folds <- cvFolds(train_df, 5)

#Create simple recipe object
rec <- createRecipe(train_df, 
                    responseVar = resp)
```

## Classification Examples

### Logistic Regression

``` r
# #Run logistic regression - only commented to avoid readme error
# lr <- logRegBinary(recipe = rec,
#                    response = resp,
#                    folds = folds,
#                    train = train_df,
#                    test = test_df)

# #Shows training and testing data confusion matrix
# lr$trainConfMat
# lr$testConfMat
# 
# #Shows training data confusion matrix plot
# lr$trainConfMatPlot
# lr$testConfMatPlot
# 
# #Shows training data score based on classification metrics
# lr$trainScore
# lr$testScore
# 
# #Shows actual predictions for training and testing
# lr$trainPred
# lr$testPred
# 
# #Shows tuned model optimized on evaluation metric chosen
# lr$final

# #XGBoost classification
# xgClass <- xgBinaryClassif(
#                    recipe = rec,
#                    response = resp,
#                    folds = folds,
#                    train = train_df,
#                    test = test_df,
#                    evalMetric = "roc_auc"
#                    )
```

### XGBoost
