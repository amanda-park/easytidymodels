#' @importFrom magrittr "%>%"

trainTestEvalRegress <- function(final = final,
                                 train = train,
                                 test = test,
                                 response = response) {

  trainPred <- final %>%
    parsnip::fit(
      data = train
    ) %>%
    stats::predict(new_data = train) %>%
    dplyr::bind_cols(train)

  trainScore <- trainPred %>%
    yardstick::metrics(!!response, .pred) %>%
    mutate(.estimate = format(round(.estimate, 2), big.mark = ","))

  testPred <- final %>%
    parsnip::fit(
      data = train
    ) %>%
    stats::predict(new_data = test) %>%
    dplyr::bind_cols(test)

  testScore <- testPred %>%
    yardstick::metrics(!!response, .pred) %>%
    mutate(.estimate = format(round(.estimate, 2), big.mark = ","))

  testPred$residPct <- (testPred[,response] - testPred$.pred) / testPred$.pred

  output <- list(
    "trainPred" = trainPred,
    "trainScore" = trainScore,
    "testPred" = testPred,
    "testScore" = testScore,
    "final" = final
  )

  return(output)

}
