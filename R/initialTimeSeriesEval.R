#' Initial Time Series Evaluation
#'
#' Gives overview of time series object. Plots time series, seasonality, and acf.
#'
#' @param df The time series formatted data frame. Columns must be named "Date" and "Value" respectively.
#' @param response The variable that is the response for analysis.
#' @param predictor The variable that is the predictor.
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom magrittr "%>%"

initialTimeSeriesEval <- function(df = dts,
                                  response = resp,
                                  predictor = pred) {

  initPlot <- df %>%
    timetk::plot_time_series(Date, Value, .interactive = FALSE)

  seasonality <- df %>%
    timetk::plot_seasonal_diagnostics(
      Date, Value,
      .feature_set = c("week", "month.lbl"),
      .interactive = FALSE
    )

  acf <- df %>%
    timetk::plot_acf_diagnostics(
      Date, Value,
      .interactive = FALSE,
      .show_white_noise_bars = TRUE)  +
    labs(title = "Lag Diagnostics")


  output <- list(
    "seasonality" = seasonality,
    "acf" = acf,
    "plot" = initPlot
  )

  return(output)
}
