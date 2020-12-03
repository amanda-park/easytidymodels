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
          yardstick::mae,
          yardstick::mase,
          yardstick::ccc,
          yardstick::iic,
          yardstick::huber_loss),
        control = tune::control_grid(verbose = TRUE,
                           save_pred = TRUE,
                           save_workflow = TRUE,
                           allow_par = TRUE, parallel_over = "everything")
      )
  }

  else if(type == "binary class") {
    tune <- tune::tune_grid(
      wflow,
      resamples = folds,
      grid      = grid,
      metrics   = yardstick::metric_set(
        yardstick::bal_accuracy,
        yardstick::mn_log_loss,
        yardstick::kap,
        yardstick::roc_auc,
        yardstick::mcc,
        yardstick::precision,
        yardstick::recall,
        yardstick::sens,
        yardstick::spec),
      control   = tune::control_grid(verbose = TRUE,
                                     save_pred = TRUE,
                                     save_workflow = TRUE,
                                     allow_par = TRUE, parallel_over = "everything")
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
        yardstick::mcc,
        yardstick::bal_accuracy,
        yardstick::precision,
        yardstick::recall,
        yardstick::sens,
        yardstick::spec),
      control   = tune::control_grid(verbose = TRUE,
                                     save_pred = TRUE,
                                     save_workflow = TRUE,
                                     allow_par = TRUE, parallel_over = "everything")
    )
  }

  best <- tune::select_best(tune, evalMetric)

  final <- tune::finalize_workflow(
    wflow,
    best
  )

  output <- list("tune" = tune,
                 "final" = final)

  return(output)
}
