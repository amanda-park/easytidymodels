
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

## Preparing Data for Analysis

This is a basic example of one splitting data in the package.

  - The function trainTestSplit is a wrapper for rsample’s function that
    allow you to nicely split up your data into training and testing
    sets. For reusability’s sake it has been put into a function here.
  - The function cvFolds is a wrapper for rsample’s vfold\_cv.
  - The function createRecipe just creates a simple recipe of your
    dataset. If more advanced recipes are required, I recommend calling
    recipe() and creating one specific to your dataset’s needs.

<!-- end list -->

``` r
library(easytidymodels)

#Simulate data
df <- data.frame(var1 = as.factor(c(rep(1, 50), rep(0, 50))),
                 var2 = rnorm(100),
                 var3 = c(rnorm(55), rnorm(45, 5)),
                 var4 = rnorm(100),
                 var5 = c(rnorm(60), rnorm(40, 3)),
                 var6 = as.factor(c(rep(0, 20), rep(1, 40), rep(2, 40))))

#Set response variable
resp <- "var6"


split <- trainTestSplit(data = df, 
                        responseVar = resp)

#Create simple recipe object
rec <- createRecipe(split$train, 
                    responseVar = resp)

#Create training, testing, and bootstrapped data sets
train_df <- recipes::bake(rec, split$train)
test_df <- recipes::bake(rec, split$test)
boot_df <- split$boot

#Create cross-validation folds
folds <- cvFolds(train_df, 5)
```

## Classification Examples

### Logistic Regression

Tunes both the penalty and mixture terms, fits a model based on the
classification evaluation metric specified (default bal\_accuracy), and
returns an evaluation of the model on both the training and testing
data.

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
```

### KNN Classification

``` r
# knnClass <- knnClassif(
#   recipe = rec,
#   response = resp,
#   folds = folds,
#   train = train_df,
#   test = test_df,
#   evalMetric = "bal_accuracy"
# )
```

### SVM Classification

``` r
# svmClass <- svmClassif(
#   recipe = rec,
#   response = resp,
#   folds = folds,
#   train = train_df,
#   test = test_df,
#   evalMetric = "bal_accuracy"
# )
```

### XGBoost

Tunes the following:

  - learn\_rate (or eta)

  - sample\_size (or subsample)

  - mtry (or colsample\_bytree)

  - min\_n (or min\_child\_weight)

  - tree\_depth (or max\_dept)

Fits a model based on the classification evaluation metric specified
(default bal\_accuracy), returns an evaluation of the model on both the
training and testing data, and also returns variable importance for the
model.

``` r
#XGBoost classification
# xgClass <- xgBinaryClassif(
#                    recipe = rec,
#                    response = resp,
#                    folds = folds,
#                    train = train_df,
#                    test = test_df,
#                    evalMetric = "roc_auc"
#                    )
# 
# #All the same functions for logistic regression work here, but also others:
# 
# #Feature importance plot
# xgClass$featImpPlot
# 
# #Feature importance variables
# xgClass$featImpVars
```

## Multiclass Classification

### Multinomial Regression

``` r
# mr <- logRegMulti(
#                    recipe = rec,
#                    response = resp,
#                    folds = folds,
#                    train = train_df,
#                    test = test_df
#                    )
```

### XGBoost Multiclass Classifcation

``` r
# xgMult <- xgMultiClassif(
#                    recipe = rec,
#                    response = resp,
#                    folds = folds,
#                    train = train_df,
#                    test = test_df
#                    )
```

## Regression

### Linear Regression

``` r
# linReg <- linearRegress(
#   response = resp,
#   data = df,
#   train = train_df,
#   test = test_df,
#   tidyModelVersion = TRUE,
#   recipe = rec,
#   folds = folds,
#   evalMetric = "rmse"
# )
```

### MARS

``` r
# mars <- marsRegress(
#   recipe = rec,
#   response = resp,
#   folds = folds,
#   train = train_df,
#   test = test_df,
#   evalMetric = "mae"
# )
```

### XGBoost

``` r
# xgReg <- xgRegress(
#   recipe = rec,
#   response = resp,
#   folds = folds,
#   train = train_df,
#   test = test_df,
#   calcFeatImp = TRUE,
#   evalMetric = "mae"
# )
# 
# #Show accuracy metrics testing data
# xgReg$testScore
# 
# #Feature importance plot
# xgReg$featImpPlot
```

### Random Forest Regression

``` r
# rfReg <- rfRegress(
#   recipe = rec,
#   response = resp,
#   folds = folds,
#   train = train_df,
#   test = test_df,
#   calcFeatImp = TRUE,
#   evalMetric = "mae"
# )
```

### Support Vector Machine

``` r
# svmReg <- svmRegress(
#   recipe = rec,
#   response = resp,
#   folds = folds,
#   train = train_df,
#   test = test_df,
#   evalMetric = "rmse"
# )
```

### KNN Regression

``` r
# knnReg <- knnRegress(
#   recipe = rec,
#   response = resp,
#   folds = folds,
#   train = train_df,
#   test = test_df,
#   evalMetric = "rmse"
# )
```
