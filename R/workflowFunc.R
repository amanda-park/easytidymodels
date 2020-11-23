#' @importFrom magrittr "%>%"

workflowFunc <- function(mod = mod,
                         formula = formula,
                         folds = folds,
                         grid = grid,
                         evalMetric = evalMetric,
                         type = "regress") {

  wflow <- workflows::workflow() %>%
    workflows::add_model(mod) %>%
    workflows::add_formula(formula)

  if(type == "regress") {

    tune <- tune::tune_grid(
        wflow,
        resamples = folds,
        grid = grid,
        metrics = yardstick::metric_set(
          yardstick::rmse,
          yardstick::rsq,
          yardstick::mae)
      )
  }

  else if(type == "binary class") {
    tune <- tune::tune_grid(
      wflow,
      resamples = folds,
      grid      = grid,
      metrics   = yardstick::metric_set(
        yardstick::bal_accuracy,
        yardstick::kap,
        yardstick::roc_auc,
        yardstick::mcc),
      #https://yardstick.tidymodels.org/articles/metric-types.html
      control   = tune::control_grid(verbose = TRUE)
    )


  }

  else if(type == "multiclass") {
    tune <- tune::tune_grid(
      wflow,
      resamples = folds,
      grid      = grid,
      metrics   = yardstick::metric_set(
        yardstick::mn_log_loss,
        yardstick::kap,
        yardstick::roc_auc,
        yardstick::bal_accuracy),
      control   = tune::control_grid(verbose = TRUE)
    )
  }

  best <- tune::select_best(tune, evalMetric)

  final <- tune::finalize_workflow(
    wflow,
    best
  )

  output <- list("tune" = tune,
                 "final" = final)

  return(final)
}
