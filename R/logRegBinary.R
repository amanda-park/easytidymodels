#' Logistic Regression.
#'
#' Runs a logistic regression model, evaluates it on training and testing set, and tunes hyperparameters.
#'
#' @param recipe A recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param train The training data set.
#' @param test The testing data set.
#' @param response The variable that is the response for analysis.
#' @param evalMetric The classification metric you want to evaluate the model's accuracy on.
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom magrittr "%>%"

logRegBinary <- function(recipe = rec,
                         folds = cvFolds,
                         train = datTrain,
                         test = datTest,
                         response = response,
                         evalMetric = "bal_accuracy"
) {

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  mod <- parsnip::logistic_reg(penalty = tune(), mixture = tune()) %>%
    parsnip::set_engine("glmnet") %>%
    parsnip::set_mode("classification")

  grid <- dials::grid_regular(dials::parameters(mod), levels = 15)

  final <- workflowFunc(mod = mod,
                        formula = formula,
                        folds = folds,
                        grid = grid,
                        evalMetric = evalMetric,
                        type = "binary class")

  output <- trainTestEvalClassif(final = final,
                                 train = train,
                                 test = test,
                                 response = response,
                                 isLogReg = TRUE)


  return(output)

}
