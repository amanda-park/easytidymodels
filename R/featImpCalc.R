#' @importFrom magrittr "%>%"

featImpCalc <- function(final = final,
                        train = train,
                        response = response,
                        evalMetric = evalMetric) {
  fitMod <- final %>%
    parsnip::fit(data = train) %>%
    workflows::pull_workflow_fit()

  featImpPlot <- fitMod %>%
    vip::vip(geom = "col")

  vars <- fitMod %>%
    vip::vi()

  output <- list(
    "plot" = featImpPlot,
    "vars" = vars
  )

  return(output)
}
