#' Support Vector Machine Regression
#'
#' Fits a radial basis Support Vector Machine Regression.
#'
#' Note - tunes the following parameters:
#' * cost: The cost of predicting a sample within or on the wrong side of the margin.
#' * rbf_sigma: The precision parameter for the radial basis function.
#' * margin: The epsilon in the SVM insensitive loss function (regression only).
#'
#' @param response Character. The variable that is the response for analysis.
#' @param recipe A recipes::recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param train Data frame/tibble. The training data set.
#' @param test Data frame/tibble. The testing data set.
#' @param gridNumber Numeric. The size of the grid to tune on. Default is 15.
#' @param evalMetric Character. The regression metric you want to evaluate the model's accuracy on. Default is RMSE. Can choose from the following:
#'
#' * rmse
#' * mae
#' * rsq
#' * mase
#' * ccc
#' * icc
#' * huber_loss
#'
#' @return A list with the following elements:
#'
#' * Training set predictions
#' * Training set evaluation on RMSE and MAE
#' * Testing set predictions
#' * Testing set evaluation on RMSE and MAE
#' * Tuned model object
#'
#' @export
#'
#' @examples
#' library(easytidymodels)
#' library(dplyr)
#' library(recipes)
#' utils::data(penguins, package = "modeldata")
#'
#' #Define your response variable and formula object here
#' resp <- "bill_length_mm"
#' formula <- stats::as.formula(paste(resp, ".", sep="~"))
#'
#' #Split data into training and testing sets
#' split <- trainTestSplit(penguins, responseVar = resp)
#'
#' #Create recipe for feature engineering for dataset, varies based on data working with
#' rec <- recipe(formula, split$train) %>% prep()
#' train_df <- bake(rec, split$train)
#' test_df <- bake(rec, split$test)
#' folds <- cvFolds(train_df)
#'
#' #Fit an SVM regression object (commented out only due to long run time)
#' #svmReg <- svmRegress(recipe = rec, response = resp,
#' #folds = folds, train = train_df, test = test_df, evalMetric = "rmse")
#'
#' #Visualize training data and its predictions
#' #svmReg$trainPred %>% select(.pred, !!resp)
#'
#' #View how model metrics for RMSE, R-Squared, and MAE look for training data
#' #svmReg$trainScore
#'
#' #Visualize testing data and its predictions
#' #svmReg$testPred %>% select(.pred, !!resp)
#'
#' #View how model metrics for RMSE, R-Squared, and MAE look for testing data
#' #svmReg$testScore
#'
#' #See the final model chosen by SVM based on optimizing for your chosen evaluation metric
#' #svmReg$final
#'
#' #See how model fit looks based on another evaluation metric
#' #svmReg$tune %>% tune::show_best("mae")
#' @importFrom magrittr "%>%"

svmRegress <- function(response = response,
                       recipe = rec,
                       folds = folds,
                       train = train_df,
                       test = test_df,
                       gridNumber = 15,
                       evalMetric = "rmse") {

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  mod <- parsnip::svm_rbf(
    cost = tune::tune(),
    rbf_sigma = tune::tune(),
    margin = tune::tune()
  ) %>%
    parsnip::set_engine("kernlab") %>%
    parsnip::set_mode("regression")

  params <- dials::parameters(
    dials::cost(),
    dials::rbf_sigma(),
    dials::svm_margin()
  )

  grid <- dials::grid_max_entropy(params, size = gridNumber)

  wflow <- workflowFunc(mod = mod,
                        formula = formula,
                        folds = folds,
                        grid = grid,
                        evalMetric = evalMetric,
                        type = "regress")

  output <- trainTestEvalRegress(final = wflow$final,
                                 train = train,
                                 test = test,
                                 response = response)

  output$tune <- wflow$tune

  return(output)

}
