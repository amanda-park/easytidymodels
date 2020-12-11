#' Split your data into a training and testing set
#'
#' Create a training and testing data set. Also returns a bootstrapped version of the training data set.
#'
#' @param data The data set of interest.
#' @param splitAmt The amount of data you want in the training set. Default is .8
#' @param timeDependent Logical. Is your data time-dependent? If so, set TRUE.
#' @param responseVar Name of response variable in analysis.
#' @param stratifyOnResponse Logical. Should the training and testing splits be stratified based on the response? If so, set TRUE.
#' @param numberOfBootstrapSamples Numeric. How many bootstrap samples do you want? Default is 25.
#'
#' @return A list with four components: train is the training set, test is the testing set, boot is a bootstrapped data set, and split is an rsample object that helps split your original data set.
#' @export
#'
#' @examples
#' library(easytidymodels)
#' library(dplyr)
#' utils::data(penguins, package = "modeldata")
#' resp <- "sex"
#' split <- trainTestSplit(penguins, stratifyOnResponse = TRUE, responseVar = resp)
#' #Training data
#' split$train
#'
#' #Testing data
#' split$test
#'
#' #Bootstrapped data
#' split$boot
#'
#' #Split object (helpful to call if you want to do model stacking)
#' split$split
trainTestSplit <- function(data = df,
                           splitAmt = .8,
                           timeDependent = FALSE,
                           responseVar = "nameOfResponseVar",
                           stratifyOnResponse = FALSE,
                           numberOfBootstrapSamples = 25) {

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
  datBoot <- rsample::bootstraps(datTrain, times = numberOfBootstrapSamples)

  output <- list("train" = datTrain,
              "test" = datTest,
              "boot" = datBoot,
              "split" = split)

  return(output)
}
