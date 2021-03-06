#' Random Forest Regression
#'
#' Runs a random forest regression.
#'
#' What the model tunes:
#' * mtry: The number of predictors that will be randomly sampled at each split when creating the tree models.
#' * min_n: The minimum number of data points in a node that are required for the node to be split further.
#'
#' What you set specifically:
#' * trees: Default is 100. Sets the number of trees contained in the ensemble. A larger values increases runtime but (ideally) leads to more robust outcomes.
#'
#' @param gridNumber Numeric. Size of the grid you want XGBoost to explore. Default is 10.
#' @param recipe A recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param train Data frame/tibble. The training data set.
#' @param test Data frame/tibble. The testing data set.
#' @param response Character. The variable that is the response for analysis.
#' @param treeNum Numeric. The number of trees to evaluate your model with. Default is 100.
#' @param calcFeatImp Logical. Do you want to calculate feature importance for your model? If not, set = FALSE.
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
#' @return A list with the following features:
#'
#' * Training set predictions
#' * Training set evaluation on RMSE and MAE
#' * Testing set predictions
#' * Testing set evaluation on RMSE and MAE
#' * Feature importance plot
#' * Feature importance table (with exact values)
#' * Tuned model object
#' @export
#'
#' @examples
#' #' library(easytidymodels)
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
#' #rfReg <- rfRegress(recipe = rec, response = resp, folds = folds,
#' #train = train_df, test = test_df, calcFeatImp = TRUE)
#'
#' #Visualize training data and its predictions
#' #rfReg$trainPred %>% select(.pred, !!resp)
#'
#' #View how model metrics for RMSE, R-Squared, and MAE look for training data
#' #rfReg$trainScore
#'
#' #Visualize testing data and its predictions
#' #rfReg$testPred %>% select(.pred, !!resp)
#'
#' #View how model metrics for RMSE, R-Squared, and MAE look for testing data
#' #rfReg$testScore
#'
#' #See the final model chosen by RF based on optimizing for your chosen evaluation metric
#' #rfReg$final
#'
#' #See how model fit looks based on another evaluation metric
#' #rfReg$tune %>% tune::select_best("rmse")
#'
#' #See feature importance of model
#' #rfReg$featImpPlot
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

  if(calcFeatImp == TRUE) {

    featImp <- featImpCalc(final = wflow$final,
                           train = train,
                           response = response,
                           evalMetric = evalMetric)

    #Add variables to output
    output$featImpPlot <- featImp$plot
    output$featImpVars <- featImp$vars
  }

  return(output)

}
