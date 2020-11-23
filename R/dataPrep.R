dataPrep <- function(data = train,
                     allowNAInData = FALSE,
                     recipe = rec) {
  trainSet <- recipe %>%
    recipes::bake(data)

  if (allowNAInData == FALSE) {
    trainSet <- trainSet %>%
      dplyr::select_if(all(!is.na(x)))
  }

  return(trainSet)
}
