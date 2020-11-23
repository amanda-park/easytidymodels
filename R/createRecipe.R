#' Creates recipes
#'
#' Create recipes
#'
#' @param data The training data set
#' @param responseVar the variable that is the response for analysis.
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom magrittr "%>%"

createRecipe <- function(data = data,
                         responseVar = "response") {

  formula <- stats::as.formula(paste(responseVar, ".", sep="~"))

  rec <- recipes::recipe(formula, data) %>%
    #step_unknown(all_nominal()) %>%
    #step_other(all_nominal(), threshold = .01) %>%
    recipes::step_nzv(recipes::all_predictors()) %>%
    #step_corr(all_predictors(), threshold = tune()) %>%
    recipes::step_dummy(recipes::all_nominal(), -dplyr::matches(responseVar), one_hot = T, preserve = F) %>%
    recipes::prep()

  return(rec)
}
