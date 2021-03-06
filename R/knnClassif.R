#' K-Nearest Neighbors Classification
#'
#' Fits a K-Nearest Neighbors Classification Model.
#'
#' Note: tunes the following parameters:
#' * neighbors: The number of neighbors considered at each prediction.
#' * weight_func: The type of kernel function that weights the distances between samples.
#' * dist_power: The parameter used when calculating the Minkowski distance. This corresponds to the Manhattan distance with dist_power = 1 and the Euclidean distance with dist_power = 2.
#'
#' @param response Character. The variable that is the response for analysis.
#' @param recipe A recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param train Data frame/tibble. The training data set.
#' @param test Data frame/tibble. The testing data set.
#' @param gridNumber Numeric. The size of the grid to tune on. Default is 15.
#' @param evalMetric Character. The classification metric you want to evaluate the model's accuracy on. Default is bal_accuracy. List of metrics available to choose from:
#' * bal_accuracy
#' * mn_log_loss
#' * roc_auc
#' * mcc
#' * kap
#' * sens
#' * spec
#' * precision
#' * recall
#'
#' @return A list with the following outputs:
#' * Training confusion matrix
#' * Training model metric score
#' * Testing confusion matrix
#' * Testing model metric score
#' * Final model chosen
#' * Tuned model
#' @export
#'
#' @examples
#' library(easytidymodels)
#' library(dplyr)
#' library(recipes)
#' utils::data(penguins, package = "modeldata")
#' #Define your response variable and formula object here
#' resp <- "sex"
#' formula <- stats::as.formula(paste(resp, ".", sep="~"))
#' #Split data into training and testing sets
#' split <- trainTestSplit(penguins, stratifyOnResponse = TRUE,
#' responseVar = resp)
#' #Create recipe for feature engineering for dataset, varies based on data working with
#' rec <- recipe(formula, data = split$train) %>% step_knnimpute(!!resp) %>%
#' step_dummy(all_nominal(), -all_outcomes()) %>%
#' step_medianimpute(all_predictors()) %>% step_normalize(all_predictors()) %>%
#' step_dummy(all_nominal(), -all_outcomes()) %>% step_nzv(all_predictors()) %>%
#' step_corr(all_numeric(), -all_outcomes(), threshold = .8) %>% prep()
#' train_df <- bake(rec, split$train)
#' test_df <- bake(rec, split$test)
#' folds <- cvFolds(train_df)
#'
#' #knn <- svmClassif(recipe = rec, response = resp, folds = folds,
#' #train = train_df, test = test_df)
#'
#' #Confusion Matrix
#' #knn$trainConfMat
#'
#' #Plot of confusion matrix
#' #knn$trainConfMatPlot
#'
#' #Test Confusion Matrix
#' #knn$testConfMat
#'
#' #Test Confusion Matrix Plot
#' #knn$testConfMatPlot
#' @importFrom magrittr "%>%"

knnClassif <- function(response = response,
                       recipe = rec,
                       folds = folds,
                       train = train_df,
                       test = test_df,
                       gridNumber = 15,
                       evalMetric = "bal_accuracy") {

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  mod <- parsnip::nearest_neighbor(
    mode = "classification",
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
                        type = "binary class")

  output <- trainTestEvalClassif(final = wflow$final,
                                 train = train,
                                 test = test,
                                 response = response)

  output$tune <- wflow$tune

  return(output)

}
