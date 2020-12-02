#' KNN Regression
#'
#' Fits a K-Nearest Neighbors Regression Model.
#'
#' @param response The variable that is the response for analysis.
#' @param recipe A recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param train The training data set.
#' @param test The testing data set.
#' @param gridNumber The size of the grid to tune on.
#' @param evalMetric The regression metric you want to evaluate the model's accuracy on.
#'
#' @return
#' @export
#'
#' @examples
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
