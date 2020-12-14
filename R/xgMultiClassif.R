#' XGBoost Multiclass Classification
#'
#' Runs XGBoost for multiclass classification.
#'
#' What the model tunes:
#' * mtry: The number of predictors that will be randomly sampled at each split when creating the tree models.
#' * min_n: The minimum number of data points in a node that are required for the node to be split further.
#' * tree_depth: The maximum depth of the tree (i.e. number of splits).
#' * learn_rate: The rate at which the boosting algorithm adapts from iteration-to-iteration.
#' * loss_reduction: The reduction in the loss function required to split further.
#' * sample_size: The amount of data exposed to the fitting routine.
#'
#' What you set specifically:
#' * trees: Default is 100. Sets the number of trees contained in the ensemble. A larger values increases runtime but (ideally) leads to more robust outcomes.
#'
#' @param gridNumber Numeric. Size of the grid you want XGBoost to explore. Default is 10.
#' @param recipe A recipe object.
#' @param levelNumber Numeric. How many levels are in your response? Default is 3.
#' @param folds A rsample::vfolds_cv object.
#' @param train Data frame/tibble. The training data set.
#' @param test Data frame/tibble. The testing data set.
#' @param response Character. The variable that is the response for analysis.
#' @param treeNum Numeric. The number of trees to evaluate your model with.
#' @param calcFeatImp Logical. Do you want to calculate feature importance for your model? If not, set = FALSE.
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
#' * Final model chosen by XGBoost
#' * Tuned model
#' * Feature importance plot
#' * Feature importance variable
#' @export
#'
#' @examples
#' library(easytidymodels)
#' library(dplyr)
#' library(recipes)
#' utils::data(penguins, package = "modeldata")
#' #Define your response variable and formula object here
#' resp <- "species"
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
#' #xgClass <- xgMultiClassif(recipe = rec, response = resp, folds = folds,
#' #train = train_df, test = test_df, evalMetric = "roc_auc")
#'
#' #Visualize training data and its predictions
#' #xgClass$trainConfMat
#'
#' #View how model metrics look
#' #xgClass$trainScore
#'
#' #Visualize testing data and its predictions
#' #xgClass$testConfMat
#'
#' #View how model metrics look
#' #xgClass$testScore
#'
#' #See the final model chosen by XGBoost based on optimizing for your chosen evaluation metric
#' #xgClass$final
#'
#' #See how model fit looks based on another evaluation metric
#' #xgClass$tune %>% tune::show_best("bal_accuracy")
#'
#' #Feature importance plot
#' #xgClass$featImpPlot
#'
#' #Feature importance variables
#' #xgClass$featImpVars
#'
#' @importFrom magrittr "%>%"

xgMultiClassif <- function(gridNumber = 10,
                           levelNumber = 3,
                           recipe = rec,
                           folds = folds,
                           train = train_df,
                           test = test_df,
                           response = response,
                           treeNum = 100,
                           calcFeatImp = TRUE,
                           evalMetric = "roc_auc") {

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  #Create model
  mod <- parsnip::boost_tree(
    trees = treeNum, #nrounds
    learn_rate = tune(), #eta
    sample_size = tune(), #subsample
    mtry = tune(), #colsample_bytree
    min_n = tune(), #min_child_weight
    tree_depth = tune(), #max_depth
    loss_reduction = tune() #gamma
  ) %>%
    parsnip::set_engine("xgboost",
               objective = "multi:softprob",
               lambda=1,
               alpha=0,
               num_class=levelNumber,
               verbose=1
    ) %>%
    parsnip::set_mode("classification")

  #Set XGBoost parameters to tune
  params <- dials::parameters(
    dials::min_n(),
    dials::tree_depth(),
    dials::learn_rate(),
    dials::finalize(dials::mtry(),dplyr::select(train,-matches(response)), force = TRUE),
    sample_size = dials::sample_prop(c(0.4, 0.9)),
    dials::loss_reduction()
  )

  #Set XGBoost grid
  grid <- dials::grid_max_entropy(params, size = gridNumber)

  wflow <- workflowFunc(mod = mod,
                        formula = formula,
                        folds = folds,
                        grid = grid,
                        evalMetric = evalMetric,
                        type = "multiclass")

  output <- trainTestEvalClassif(final = wflow$final,
                                 train = train,
                                 test = test,
                                 response = response)

  output$tune <- wflow$tune

  if(calcFeatImp == TRUE) {

    featImp <- featImpCalc(final = wflow$final,
                           train = train,
                           response = response,
                           evalMetric = evalMetric)

    output$featImpPlot <- featImp$plot
    output$featImpVars <- featImp$vars
  }

  return(output)
}
