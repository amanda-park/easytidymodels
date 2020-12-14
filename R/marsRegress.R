#' Multi Adaptive Regressive Spline
#'
#' Fits a MARS regression model.
#'
#' Note - Tunes the following parameters:
#' * num_terms: The number of features that will be retained in the final model.
#' * prod_degree: The highest possible degree of interaction between features. A value of 1 indicates an additive model while a value of 2 allows, but does not guarantee, two-way interactions between features.
#' * prune_method: The type of pruning. Possible values are listed in ?earth.
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
#' #Fit a MARS regression object (commented out only due to long run time)
#' #marsReg <- marsRegress(recipe = rec, response = resp,
#' #folds = folds, train = train_df, test = test_df, evalMetric = "rmse")
#'
#' #Visualize training data and its predictions
#' #marsReg$trainPred %>% select(.pred, !!resp)
#'
#' #View how model metrics for RMSE, R-Squared, and MAE look for training data
#' #marsReg$trainScore
#'
#' #Visualize testing data and its predictions
#' #marsReg$testPred %>% select(.pred, !!resp)
#'
#' #View how model metrics for RMSE, R-Squared, and MAE look for testing data
#' #marsReg$testScore
#'
#' #See the final model chosen for MARS based on optimizing for your chosen evaluation metric
#' #marsReg$final
#'
#' #See how model fit looks based on another evaluation metric
#' #marsReg$tune %>% tune::show_best("mae")
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
