#' Linear Regression.
#'
#' Runs a linear regression model, and either:
#' 1) fits a basic lm() model and shows diagnostics and model fit
#' 2) evaluates it on training and testing set, and tunes hyperparameters.
#'

#' @param response The variable that is the response for analysis.
#' @param computeMarginalEffects Logical. Compute marginal effects for lm model?
#' @param data The entire data frame.
#' @param train The training data set.
#' @param test The testing data set.
#' @param tidyModelVersion Logical. Run a tidymodel version of linear regression?
#' @param recipe A recipe object.
#' @param folds A rsample::vfolds_cv object.
#' @param evalMetric The regression metric you want to evaluate the model's accuracy on.
#'
#' @return
#' @export
#'
#' @examples
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
