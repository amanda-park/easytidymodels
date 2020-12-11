#' Linear Regression.
#'
#' Runs a linear regression model, and either:
#' 1) fits a basic lm() model and shows diagnostics and model fit
#' 2) Uses the tidymodels approach: evaluates it on training and testing set, and tunes hyperparameters.
#'
#' Note: Tidymodels version tunes the following parameters:
#' * penalty: The total amount of regularization in the model. Also known as lambda.
#' * mixture: The mixture amounts of different types of regularization (see below). If 1, amounts to LASSO regression. If 0, amounts to Ridge Regression. Also known as alpha.
#'
#' @param response Character. The variable that is the response for analysis.
#' @param computeMarginalEffects Logical. Compute marginal effects for lm model?
#' @param data The entire data frame. Used for tidyModelVersion = FALSE.
#' @param train Data frame/tibble. The training data set.
#' @param test Data frame/tibble. The testing data set.
#' @param tidyModelVersion Logical. Run a tidymodel version of linear regression? If yes, will tune hyperparameters and return a tidymodels regression model. If no, will fit an lm() object and return output based on that computation.
#' @param recipe A recipes::recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param evalMetric Character. The regression metric you want to evaluate the model's accuracy on (tidymodels only). Default is RMSE. Can choose from the following:
#'
#' * rmse
#' * mae
#' * rsq
#' * mase
#' * ccc
#' * icc
#' * huber_loss
#'
#' @return A list.
#'
#' If tidyModelVersion = TRUE:
#' * Training set predictions
#' * Training set evaluation on RMSE and MAE
#' * Testing set predictions
#' * Testing set evaluation on RMSE and MAE
#' * Tuned model object
#'
#' If tidyModelVersion = FALSE:
#' * lm() model object
#' * broom() cleaned object of summary of lm() model
#' * diagnostic plots
#'
#' @export
#'
#' @examples
#' library(easytidymodels)
#' library(dplyr)
#' library(recipes)
#' utils::data(penguins, package = "modeldata")
#'
#' #Define your response variable and formula object here
#' resp <- "bill_length_mm"
#' formula <- stats::as.formula(paste(resp, ".", sep="~"))
#'
#' #Split data into training and testing sets
#' split <- trainTestSplit(penguins, responseVar = resp)
#'
#' #Create recipe for feature engineering for dataset, varies based on data working with
#' rec <- recipe(formula, split$train) %>% prep()
#' train_df <- bake(rec, split$train)
#' test_df <- bake(rec, split$test)
#' folds <- cvFolds(train_df)
#'
#' #Fit a KNN regression object (commented out only due to long run time)
#' #linReg <- linearRegress(recipe = rec, response = resp, data = penguins, tidyModelVersion = FALSE,
#' #folds = folds, train = train_df, test = test_df, evalMetric = "rmse")
#'
#' #Visualize training data and its predictions
#' #linReg$trainPred %>% select(.pred, !!resp)
#'
#' #View how model metrics for RMSE, R-Squared, and MAE look for training data
#' #linReg$trainScore
#'
#' #Visualize testing data and its predictions
#' #linReg$testPred %>% select(.pred, !!resp)
#'
#' #View how model metrics for RMSE, R-Squared, and MAE look for testing data
#' #linReg$testScore
#'
#' #See the final model chosen by KNN based on optimizing for your chosen evaluation metric
#' #linReg$final
#'
#' #See how model fit looks based on another evaluation metric
#' #linReg$tune %>% tune::show_best("mae")
#' @importFrom magrittr "%>%"

linearRegress <- function(response = response,
                          computeMarginalEffects = FALSE,
                          data = df,
                          train = train_df,
                          test = test_df,
                          tidyModelVersion = FALSE,
                          recipe = rec,
                          folds = folds,
                          evalMetric = "rmse"
)

{

  formula <- stats::as.formula(paste(response, ".", sep="~"))

  if(tidyModelVersion == FALSE) {


    mod <- stats::lm(formula, data)

    #Need to fix this line for prettier diagnostic plots
    #diagnostics <- ggplot2::autoplot(mod, which = 1:6) + theme_minimal()
    diagnostics <- plot(mod)

    res <- broom::tidy(mod,
                       conf.int = TRUE,
                       conf.level = .95) %>%
      dplyr::filter(p.value <= .05)

    output <- list(
      "mod" = mod,
      "tidyData" = res,
      "diagnostics" = diagnostics
    )

    if(computeMarginalEffects == TRUE) {
      eff <- margins(mod)
      effPlot <- plot(eff)
      output$effectPlot <- effPlot
    }
  }

  else {
    mod <- parsnip::linear_reg(penalty = tune(), mixture = tune()) %>%
      parsnip::set_mode("regression") %>%
      parsnip::set_engine("glmnet")

    grid <- tidyr::crossing(
      penalty = 10^seq(-6, -1, length.out = 20),
      mixture = c(0.05, 0.2, 0.4, 0.6, 0.8, 1)
    )

    wflow <- workflowFunc(mod = mod,
                          formula = formula,
                          folds = folds,
                          grid = grid,
                          evalMetric = evalMetric,
                          type = "regress")

    output <- trainTestEvalRegress(final = wflow$final,
                                   train = train,
                                   test = test,
                                   response = response)

    output$tune <- wflow$tune
  }

  return(output)

}
