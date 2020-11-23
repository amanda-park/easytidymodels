#' @importFrom magrittr "%>%"

trainTestEvalClassif <- function(final = final,
                                 train = train,
                                 test = test,
                                 response = response,
                                 isLogReg = FALSE) {
  trainPred <- final %>%
    parsnip::fit(
      data = train
    ) %>%
    stats::predict(new_data = train) %>%
    dplyr::bind_cols(train)

  trainScore <- trainPred %>%
    yardstick::metrics(!!response, .pred_class) %>%
    mutate(.estimate = format(round(.estimate, 2), big.mark = ","))

  trainConfMat <- trainPred %>%
    yardstick::conf_mat(truth = !!response, estimate = .pred_class)

  trainConfMatPlot <- autoplot(trainConfMat, type = "heatmap")

  testPred <- final %>%
    parsnip::fit(
      data = train
    ) %>%
    stats::predict(new_data = test) %>%
    dplyr::bind_cols(test)

  testScore <- testPred %>%
    yardstick::metrics(!!response, .pred_class) %>%
    dplyr::mutate(.estimate = format(round(.estimate, 2), big.mark = ","))

  testConfMat <- testPred %>%
    yardstick::conf_mat(truth = !!response, estimate = .pred_class)

  testConfMatPlot <- autoplot(testConfMat, type = "heatmap")

  output <- list(
    "trainPred" = trainPred,
    "trainScore" = trainScore,
    "trainConfMat" = trainConfMat,
    "trainConfMatPlot" = trainConfMatPlot,
    "testPred" = testPred,
    "testScore" = testScore,
    "testConfMat" = testConfMat,
    "testConfMatPlot" = testConfMatPlot,
    "final" = final
  )

  return(output)

}
