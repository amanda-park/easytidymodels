#' Support Vector Machine
#'
#' Fits a radial basis Support Vector Machine Regression.
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

svmRegress <- function(response = response,
                       recipe = rec,
                       folds = folds,
                       train = train_df,
                       test = test_df,
                       gridNumber = 10,
                       evalMetric = "rmse") {

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  mod <- parsnip::svm_rbf(
    cost = tune::tune(),
    rbf_sigma = tune::tune()
  ) %>%
    set_engine("kernlab") %>%
    set_mode("regression")

  params <- dials::parameters(
    dials::cost(),
    dials::rbf_sigma()
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
