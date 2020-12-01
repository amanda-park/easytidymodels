#' Multinomial Regression.
#'
#' Runs a multinomial regression model, evaluates it on training and testing set, and tunes hyperparameters.
#'
#' @param recipe A recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param train The training data set.
#' @param test The testing data set.
#' @param response The variable that is the response for analysis.
#' @param levelNum Numeric. The number of levels you want the grid to search on. Default is 15.
#' @param evalMetric The classification metric you want to evaluate the model's accuracy on.
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom magrittr "%>%"

logRegMulti <- function(recipe = rec,
                        folds = cvFolds,
                        train = train_df,
                        test = test_df,
                        response = response,
                        levelNum = 15,
                        evalMetric = "bal_accuracy"
) {

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  mod <- parsnip::multinom_reg(penalty = tune(), mixture = tune()) %>%
    parsnip::set_engine("glmnet") %>%
    parsnip::set_mode("classification")

  grid <- dials::grid_regular(dials::parameters(mod), levels = levelNum)

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
