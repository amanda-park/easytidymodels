#' Multinomial Regression
#'
#' Runs a multinomial regression model, evaluates it on training and testing set, and tunes hyperparameters.
#'
#' What the model tunes:
#' * penalty: The total amount of regularization in the model. Also known as lambda.
#' * mixture: The mixture amounts of different types of regularization (see below). If 1, amounts to LASSO regression. If 0, amounts to Ridge Regression. Also known as alpha.
#'
#' @param recipe A recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param train Data frame/tibble. The training data set.
#' @param test Data frame/tibble. The testing data set.
#' @param response Character. The variable that is the response for analysis.
#' @param gridNum Numeric. The number of levels you want the grid to search on. Default is 15.
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
#' #mr <- logRegMulti(recipe = rec, response = resp, folds = folds,
#' #train = train_df, test = test_df)
#'
#' #Confusion Matrix
#' #mr$trainConfMat
#'
#' #Plot of confusion matrix
#' #mr$trainConfMatPlot
#'
#' #Test Confusion Matrix
#' #mr$testConfMat
#'
#' #Test Confusion Matrix Plot
#' #mr$testConfMatPlot
#' @importFrom magrittr "%>%"

logRegMulti <- function(recipe = rec,
                        folds = cvFolds,
                        train = train_df,
                        test = test_df,
                        response = response,
                        gridNum = 15,
                        evalMetric = "bal_accuracy"
) {

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  mod <- parsnip::multinom_reg(penalty = tune(), mixture = tune()) %>%
    parsnip::set_engine("glmnet") %>%
    parsnip::set_mode("classification")

  grid <- dials::grid_regular(dials::parameters(mod), levels = gridNum)

  wflow <- workflowFunc(mod = mod,
                        formula = formula,
                        folds = folds,
                        grid = grid,
                        evalMetric = evalMetric,
                        type = "multiclass")

  output <- trainTestEvalClassif(final = wflow$final,
                                 train = train,
                                 test = test,
                                 response = response,
                                 isLogReg = TRUE)

  output$tune <- wflow$tune


  return(output)

}
