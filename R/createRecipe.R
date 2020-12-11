#' Creates recipes to preprocess data set
#'
#' Creates and returns a recipe object.
#'
#' The following data transformations are automatically applied to the data:
#'
#' * Normalizes numeric variables
#' * Puts infrequent levels of categorical variables into "other" category
#' * Puts NA values into "unknown" category
#' * Removes variables with near-zero variance
#' * Removes highly correlated variables
#' * One-hot encodes your categorical variables
#'
#' If a different recipe is needed, I recommend calling the recipes library and building one appropriate for your dataset (this function is hard to automate given the variety of data transformations that can happen for a specific data set).
#'
#' @param data The training data set
#' @param responseVar the variable that is the response for analysis.
#' @param corrValue The value to remove variables that are highly correlated from dataset. The step will try to remove the minimum number of columns so that all the resulting absolute correlations are less than this value. Default value is .9.
#' @param otherValue The minimum frequency of a level in a factor variable needed to avoid converting its outcome to "other". Default is .01.
#'
#' @return A recipes::recipe object that has been prepped.
#' @export
#'
#' @examples
#' library(easytidymodels)
#' library(dplyr)
#' utils::data(penguins, package = "modeldata")
#' resp <- "sex"
#' split <- trainTestSplit(penguins, stratifyOnResponse = TRUE, responseVar = resp)
#' formula <- stats::as.formula(paste(resp, ".", sep="~"))
#' rec <- createRecipe(split$train, responseVar = resp)
#' rec
#' @importFrom magrittr "%>%"

createRecipe <- function(data = data,
                         responseVar = "response",
                         corrValue = .9,
                         otherValue = .01) {

  formula <- stats::as.formula(paste(responseVar, ".", sep="~"))

  rec <- recipes::recipe(formula, data) %>%
    recipes::step_unknown(recipes::all_nominal()) %>%
    recipes::step_normalize(recipes::all_numeric(), -recipes::all_outcomes()) %>%
    recipes::step_other(recipes::all_nominal(), threshold = otherValue) %>%
    recipes::step_nzv(recipes::all_predictors()) %>%
    recipes::step_corr(recipes::all_numeric(), -recipes::all_outcomes(), threshold = corrValue) %>%
    recipes::step_dummy(recipes::all_nominal(), -dplyr::matches(responseVar), one_hot = T, preserve = F) %>%
    recipes::prep()

  return(rec)
}
