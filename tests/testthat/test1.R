library(testthat)
library(visiblespectrum)

# Test: pull_naomi returns a data frame using one country and one indicator
test_that("pull_naomi returns a data frame using one country and one indicator", {
  result <- pull_naomi(countries = c("Angola"), indicators = c("Population"), verbose = FALSE)
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)  # Ensure the data frame is not empty
})

