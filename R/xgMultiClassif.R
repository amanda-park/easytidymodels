#' XGBoost Multiclass Classification
#'
#' Runs XGBoost for multiclass classification.
#'
#' @param gridNumber Numeric. Size of the grid you want XGBoost to explore. Default is 10.
#' @param levelNumber Numeric. The number of levels in your response variable. Default is 3.
#' @param recipe A recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param train The training data set.
#' @param test The testing data set.
#' @param response The variable that is the response for analysis.
#' @param treeNum The number of trees to evaluate your model with.
#' @param calcFeatImp Do you want to calculate feature importance for your model? If not, set = FALSE.
#' @param evalMetric The classification metric you want to evaluate the model's accuracy on.
#'
#' @return
#' @export
#'
#' @examples
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
               num_class=classNumber,
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

  final <- workflowFunc(mod = mod,
                        formula = formula,
                        folds = folds,
                        grid = grid,
                        evalMetric = evalMetric,
                        type = "multiclass")

  output <- trainTestEvalClassif(final = final,
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
    output$final <- final
  }

  return(output)
}
