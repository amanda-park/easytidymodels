#' Resample Time Series
#'
#' Wrapper for modeltime.resample. Resamples time series to see how they compare over different time chunks.
#'
#' @param df The time series formatted data frame. Columns must be named "Date" and "Value" respectively.
#' @param table A modeltime table object.
#' @param sliceLimit The number of slices to have in resample. Default is 5.
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom magrittr "%>%"

resampleTimeSeries <- function(df = dts,
                               table = output$forecastTable,
                               sliceLimit = 5) {
  resamples <- modeltime.resample::time_series_cv(
    data        = df,
    assess      = floor(nrow(data) / 10),
    initial     = floor(nrow(data) / 4),
    skip        = floor(nrow(data) / 10),
    slice_limit = sliceLimit
  )

  # Begin with a Cross Validation Strategy
  resampleSplits <- resamples %>%
    modeltime.resample::tk_time_series_cv_plan() %>%
    modeltime.resample::plot_time_series_cv_plan(Date, Value, .facet_ncol = 2, .interactive = FALSE)

  resamplesFitted <- table %>%
    modeltime.resample::modeltime_fit_resamples(
      resamples = resamples,
      control   = tune::control_resamples(verbose = FALSE)
    )

  resamplesPlot <- resamplesFitted %>%
    modeltime.resample::plot_modeltime_resamples(
      .point_size  = 3,
      .point_alpha = 0.8,
      .interactive = FALSE
    )

  resamplesTable <- resamplesFitted %>%
    modeltime.resample::modeltime_resample_accuracy(summary_fns = mean) %>%
    modeltime::table_modeltime_accuracy(.interactive = FALSE)

  output <- list(
    "table" = resamplesTable,
    "plot" = resamplesPlot,
    "fit" = resamplesFitted,
    "splits" = resampleSplits
  )

  return(output)

}
