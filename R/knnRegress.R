#' KNN Regression
#'
#' Fits a K-Nearest Neighbors Regression Model.
#'
#' Note: tunes the following parameters:
#' * neighbors: The number of neighbors considered at each prediction.
#' * weight_func: The type of kernel function that weights the distances between samples.
#' * dist_power: The parameter used when calculating the Minkowski distance. This corresponds to the Manhattan distance with dist_power = 1 and the Euclidean distance with dist_power = 2.
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
#' #Fit a KNN regression object (commented out only due to long run time)
#' #knnReg <- knnRegress(recipe = rec, response = resp,
#' #folds = folds, train = train_df, test = test_df, evalMetric = "rmse")
#'
#' #Visualize training data and its predictions
#' #knnReg$trainPred %>% select(.pred, !!resp)
#'
#' #View how model metrics for RMSE, R-Squared, and MAE look for training data
#' #knnReg$trainScore
#'
#' #Visualize testing data and its predictions
#' #knnReg$testPred %>% select(.pred, !!resp)
#'
#' #View how model metrics for RMSE, R-Squared, and MAE look for testing data
#' #knnReg$testScore
#'
#' #See the final model chosen by KNN based on optimizing for your chosen evaluation metric
#' #knnReg$final
#'
#' #See how model fit looks based on another evaluation metric
#' #knnReg$tune %>% tune::show_best("mae")
#' @importFrom magrittr "%>%"

knnRegress <- function(response = response,
                       recipe = rec,
                       folds = folds,
                       train = train_df,
                       test = test_df,
                       gridNumber = 15,
                       evalMetric = "rmse") {

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  mod <- parsnip::nearest_neighbor(
    mode = "regression",
    neighbors = tune::tune(),
    weight_func = tune::tune(),
    dist_power = tune::tune()
  ) %>%
    parsnip::set_engine("kknn")

  params <- dials::parameters(
    dials::neighbors(),
    dials::weight_func(),
    dials::dist_power()
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
