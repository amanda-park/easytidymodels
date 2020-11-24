#' MARS
#'
#' Fits a MARS regression model.
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

marsRegress <- function(response = response,
                        recipe = rec,
                        folds = folds,
                        train = train_df,
                        test = test_df,
                        gridNumber = 10,
                        evalMetric = "rmse")
{

  mod <- parsnip::mars(num_terms = tune(),
              prod_degree = tune()) %>%
    parsnip::set_engine("earth") %>%
    parsnip::set_mode("regression")

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  params <- dials::parameters(
    dials::finalize(dials::num_terms(), dplyr::select(train, -matches(response))),
    dials::prod_degree()
  )

  #Set grid
  grid <- dials::grid_max_entropy(params, size = gridNumber)

  final <- workflowFunc(mod = mod,
                        formula = formula,
                        folds = folds,
                        grid = grid,
                        evalMetric = evalMetric,
                        type = "regress")

  output <- trainTestEvalRegress(final = final,
                                 train = train,
                                 test = test,
                                 response = response)

  return(output)

}
