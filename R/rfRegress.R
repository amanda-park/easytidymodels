#' Random Forest Regression
#'
#' Runs a random forest regression.
#'
#' @param gridNumber Numeric. Size of the grid you want XGBoost to explore. Default is 10.
#' @param recipe A recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param train The training data set.
#' @param test The testing data set.
#' @param response The variable that is the response for analysis.
#' @param treeNum The number of trees to evaluate your model with.
#' @param calcFeatImp Do you want to calculate feature importance for your model? If not, set = FALSE.
#' @param evalMetric The regression metric you want to evaluate the model's accuracy on.
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom magrittr "%>%"

rfRegress <- function(gridNumber = 10,
                      recipe = rec,
                      folds = cvFolds,
                      train = train_df,
                      test = test_df,
                      response = response,
                      treeNum = 100,
                      calcFeatImp = TRUE,
                      evalMetric = "rmse") {

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  #Create model
  mod <- parsnip::rand_forest(mode = "regression",
                     mtry = tune(),
                     min_n = tune(),
                     trees = treeNum) %>%
    parsnip::set_engine("ranger", importance = "permutation")

  subset <- dplyr::select(train, -matches(response))

  #Set RF parameters to tune
  params <- dials::parameters(
    dials::min_n(),
    dials::finalize(dials::mtry(), subset)
  )


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

  if(calcFeatImp == TRUE) {

    featImp <- featImpCalc(final = final,
                           train = train,
                           response = response,
                           evalMetric = evalMetric)

    #Add variables to output
    output$featImpPlot <- featImp$plot
    output$featImpVars <- featImp$vars
  }

  return(output)

}
