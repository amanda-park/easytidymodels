#' Model Time Series
#'
#' Runs many time series models as well as combinations of the time series.
#'
#' @param train Training data set.
#' @param test The testing data set.
#' @param df The time series formatted data frame. Columns must be named "Date" and "Value" respectively.
#' @param response The variable that is the response for analysis.
#' @param predictor The variable that is the predictor.
#' @param folds A rsample::vfolds_cv object.
#' @param days The numbers of days desired to forecast for. Default is 7.
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom magrittr "%>%"
#'
modelTimeSeries <- function(train = tr,
                            test = ts,
                            df = dts,
                            response = resp,
                            predictor = pred,
                            folds = cvFolds,
                            days = 7) {

  #Automate formula
  formulaBase <- stats::as.formula(paste(response, ".", sep="~"))

  #Recipe-free models

  arima_model <- modeltime::arima_reg() %>%
    parsnip::set_engine("auto_arima") %>%
    parsnip::fit(formulaBase, data = train)

  prophet_model <- modeltime::prophet_reg() %>%
    parsnip::set_engine("prophet") %>%
    parsnip::fit(formulaBase, data = train)

  ets_model <- modeltime::exp_smoothing() %>%
    parsnip::set_engine("ets") %>%
    parsnip::fit(formulaBase, data = train)

  tbats_model <- modeltime::seasonal_reg() %>%
    parsnip::set_engine("tbats") %>%
    parsnip::fit(formulaBase, data = train)

  nn_model <- modeltime::nnetar_reg() %>%
    parsnip::set_engine("nnetar") %>%
    parsnip::fit(formulaBase, data = train)

  stlm_ets_model <- modeltime::seasonal_reg() %>%
    parsnip::set_engine("stlm_ets") %>%
    parsnip::fit(formulaBase, data = train)

  stlm_arima_model <- modeltime::seasonal_reg() %>%
    parsnip::set_engine("stlm_arima") %>%
    parsnip::fit(formulaBase, data = train)

  forecast_table <- modeltime::modeltime_table(
    arima_model,
    prophet_model,
    ets_model,
    tbats_model,
    nn_model,
    stlm_ets_model,
    stlm_arima_model
  )

  acc <- forecast_table %>%
    modeltime::modeltime_calibrate(test) %>%
    modeltime::modeltime_accuracy() %>%
    dplyr::arrange(mase)

  order <- acc$.model_id

  forecast_table <- forecast_table[order,]

  crossValPlot <- forecast_table %>%
    modeltime::modeltime_calibrate(test) %>%
    modeltime::modeltime_forecast(actual_data = test) %>%
    modeltime::plot_modeltime_forecast()

  fcastVals <- forecast_table %>%
    modeltime::modeltime_refit(df) %>%
    modeltime::modeltime_calibrate(df) %>%
    modeltime::modeltime_forecast(h = days, actual_data = df)

  fcast <- fcastVals %>%
    modeltime::plot_modeltime_forecast()

  #Model ensembling
  ensembleAvg <- forecast_table %>%
    modeltime.ensemble::ensemble_average(type = "mean")

  ensembleMed <- forecast_table %>%
    modeltime.ensemble::ensemble_average(type = "median")

  ensembleWeighted <- forecast_table[1:5,] %>%
    modeltime.ensemble::ensemble_weighted(loadings = c(5, 4, 3, 2, 1),
                      scale_loadings = TRUE)

  ensembleTable <- modeltime::modeltime_table(
    ensembleAvg,
    ensembleMed,
    ensembleWeighted
  )

  accEnsemble <- ensembleTable %>%
    modeltime::modeltime_calibrate(test) %>%
    modeltime::modeltime_accuracy()

  fcastEnsembleVals <- ensembleTable %>%
    modeltime_calibrate(df) %>%
    modeltime_forecast(
      new_data    = test,
      actual_data = df
    )

  fcastEnsembleCVPlot <- fcastEnsembleVals %>%
    modeltime::plot_modeltime_forecast()

  fcastEnsembleFcast <- ensembleTable %>%
    modeltime::modeltime_refit(df) %>%
    modeltime::modeltime_calibrate(df) %>%
    modeltime::modeltime_forecast(h = days, actual_data = df)

  fcastEnsembleFcastPlot <- fcastEnsembleFcast %>%
    modeltime::plot_modeltime_forecast()

  output <- list(
    "accuracyTable" = acc,
    "crossValPlot" = crossValPlot,
    "forecastTable" = forecast_table,
    "forecastPlot" = fcast,
    "forecastValues" = fcastVals,
    "accuracyEnsembleTable" = accEnsemble,
    "ensembleCrossValPlot" = fcastEnsembleCVPlot,
    "ensembleForecastValues" = fcastEnsembleFcast,
    "ensembleForecastPlot" = fcastEnsembleFcastPlot
  )

  return(output)

}
