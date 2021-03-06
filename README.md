
<!-- README.md is generated from README.Rmd. Please edit that file -->

# easytidymodels

<!-- badges: start -->

<!-- badges: end -->

The goal of easytidymodels is to make running analyses in R using the
tidymodels framework both easier and more reproducible. This is a
wrapper for the tidymodels packages so that, after your data
pre-processing steps, it all runs in one line of code and automatically
tunes all the hyperparameters that are offered.

If you are not familiar with tidymodels, I recommend learning more
[here](https://www.tidymodels.org/) or [here](https://www.tmwr.org/).

For more details on how the functions work in this package, I recommend
checking out the reference page, referencing the vignettes on this site,
or calling help on the function of interest in R to learn more. Here I
will just give a brief overview of the workflow of this package.

## Installation

You can install easytidymodels like this:

``` r
# install.packages("devtools")
devtools::install_github("amanda-park/easytidymodels")
```

## Preparing Data for Analysis

There are three main functions to prepare your data for analysis:

  - **trainTestSplit** lets you split data into training and testing
    sets, with the ability to stratify on a variable and split based on
    a point in time.
  - **cvFolds** splits your data into cross-validation folds to allow
    the model’s hyperparameters to be tuned.
  - **createRecipe** does some basic data preprocessing on your dataset.
    NOTE: I recommend calling recipe() and creating a recipe object
    specific to your dataset’s needs, as every dataset will require its
    own preprocessing prior to analysis.

## Classification Functions

The binary classification machine learning models available are as
follows:

  - XGBoost (function **xgBinaryClassif**)
  - Logistic Regression (function **logRegBinary**)
  - K-Nearest Neighbors (function **knnClassif**)
  - Support Vector Machine (function **svmClassif**)

The multiclass classifications available are as follows:

  - XGBoost (function **xgMultiClassif**)
  - Multinomial Regression (function **logRegMulti**)
  - K-Nearest Neighbors (function **knnClassif**)
  - Support Vector Machine (function **svmClassif**)

Each of these models will tune the appropriate hyperparameters in the
mode. However, these models allow for optimizing hyperparameters based
on a specific evaluation metric. The list of metrics are as follows:

  - [Balanced
    Accuracy](https://yardstick.tidymodels.org/reference/bal_accuracy.html)
    (Average of Sensitivity and Specificity, call “bal\_accuracy”)
  - [Mean Log
    Loss](https://yardstick.tidymodels.org/reference/mn_log_loss.html)
    (Call “mn\_log\_loss”)
  - [ROC AUC](https://yardstick.tidymodels.org/reference/roc_auc.html)
    (Area Under the Receiver Operating Curve, call “roc\_auc”)
  - [MCC](https://yardstick.tidymodels.org/reference/mcc.html)
    (Matthew’s Correlation Coefficient, call “mcc”)
  - [Kappa](https://yardstick.tidymodels.org/reference/kap.html)
    (Normalized Accuracy, call “kap”)
  - [Sensitivity](https://yardstick.tidymodels.org/reference/sens.html)
    (Call “sens”)
  - [Specificity](https://yardstick.tidymodels.org/reference/spec.html)
    (Call “spec”)
  - [Precision](https://yardstick.tidymodels.org/reference/precision.html)
    (Call “precision”)
  - [Recall](https://yardstick.tidymodels.org/reference/recall.html)
    (Call “recall”)

Save the model output to an object; the model will return the following
in a list (can be accessed using $):

  - Confusion matrix on training data
  - Accuracy evaluation on training data
  - Confusion matrix on testing data
  - Accuracy evaluation on testing data
  - Description of final model chosen
  - A tuned version of the model (in the case you want to try model
    stacking or seeing the optimal model fit based on a different
    evaluation metric)

## Regression Functions

The regression functions available are as follows:

  - Random Forest (function **rfRegress**)
  - XGBoost (function **xgRegress**)
  - Linear Regression (function **linearRegress**)
  - MARS (function **marsRegress**)
  - K-Nearest Neighbor Regression (function **knnRegress**)
  - Support Vector Machine Regression (function **svmRegress**)

These models allow for optimizing hyperparameters based on a specific
evaluation metric as well. The list of metrics are as follows:

  - [RMSE](https://yardstick.tidymodels.org/reference/rmse.html) (Root
    Mean Squared Error, call “rmse”)
  - [MAE](https://yardstick.tidymodels.org/reference/mae.html) (Mean
    Absolute Error, call “mae”)
  - [RSQ](https://yardstick.tidymodels.org/reference/rsq.html)
    (R-Squared, call “rsq”)
  - [MASE](https://yardstick.tidymodels.org/reference/mase.html) (Mean
    Absolute Scaled Error, call “mase”)
  - [CCC](https://yardstick.tidymodels.org/reference/ccc.html)
    (Concordance Correlation Coefficient, call “ccc”)
  - [IIC](https://yardstick.tidymodels.org/reference/iic.html) (Index of
    Ideality of Correlation, call “iic”)
  - [HUBER\_LOSS](https://yardstick.tidymodels.org/reference/huber_loss.html)
    (Huber loss, call “huber\_loss”)

Save the model output to an object; the model will return the following
in a list (can be accessed using $):

  - Predictions on training data
  - RMSE and MAE evaluation on training data
  - Predictions on testing data
  - RMSE and MAE evaluation on testing data
  - Description of final model chosen
  - A tuned version of the model (in the case you want to try model
    stacking or seeing the optimal model fit based on a different
    evaluation metric)
