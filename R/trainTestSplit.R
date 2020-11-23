#' Split data into training and testing
#'
#' Create a training and testing data set. Also returns a bootstrapped version of the training data set.
#'
#' @param data The data set of interest.
#' @param splitAmt The amount of data you want in the training set. Default is .8
#' @param timeDependent Logical. Is your data time-dependent? If so, set TRUE.
#' @param responseVar Name of response variable in analysis.
#' @param stratifyOnResponse Logical. Should the training and testing splits be stratified based on the response? If so, set TRUE.
#'
#' @return
#' @export
#'
#' @examples
trainTestSplit <- function(data = df,
                           splitAmt = .8,
                           timeDependent = FALSE,
                           responseVar = "nameOfResponseVar",
                           stratifyOnResponse = FALSE) {

  if(timeDependent == FALSE) {
    if(stratifyOnResponse == FALSE) {
      split <- rsample::initial_split(data,
                                      prop = splitAmt)
    }
    else {
      split <- rsample::initial_split(data,
                                      prop = splitAmt,
                                      strata = !!responseVar)
    }

  }
  else {
    split <- rsample::initial_time_split(data,
                                         prop = splitAmt)
  }

  datTrain <- rsample::training(split)
  datTest <- rsample::testing(split)

  datBoot <- rsample::bootstraps(datTrain)

  output <- list("train" = datTrain,
              "test" = datTest,
              "boot" = datBoot)

  return(output)
}
