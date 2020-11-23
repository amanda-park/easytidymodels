#' Creates cross-validation folds
#'
#' Create folds based on training data fed in.
#'
#' @param data The training data set
#' @param foldNumber the number of folds for cross-validation. Default is 5.
#' @param stratifyOnVar Logical. Should the folds be stratified based on the response? If so, set TRUE.
#' @param whatVarToStratifyOn Character. What is the name of the variable to stratify on?
#'
#' @return
#' @export
#'
#' @examples


cvFolds <- function(data = train,
                    foldNumber = 5,
                    stratifyOnVar = FALSE,
                    whatVarToStratifyOn = "var") {

  if(stratifyOnVar == FALSE) {
    output <- rsample::vfold_cv(data = data,
                                v = foldNumber)
  }

  else {
    output <- rsample::vfold_cv(data = data,
                                v = foldNumber,
                                strata = !!whatVarToStratifyOn)
  }

  return(output)
}
