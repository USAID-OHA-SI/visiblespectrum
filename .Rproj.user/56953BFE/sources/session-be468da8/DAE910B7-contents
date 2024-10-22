library(testthat)
library(visiblespectrum)

# Test: pull_naomi returns a data frame with default parameters
test_that("pull_naomi returns a data frame with default parameters", {
  result <- pull_naomi()  # Use default parameters
  expect_s3_class(result, "data.frame")  # Check if the result is a data frame
  expect_true(nrow(result) > 0)  # Ensure the data frame is not empty
})

# Test: pull_naomi handles specific country input
test_that("pull_naomi handles specific country input", {
  countries <- c("Kenya", "Tanzania")
  result <- pull_naomi(countries = countries)
  expect_s3_class(result, "data.frame")
  expect_true(all(result$country %in% countries))  # Check if countries match
})

# Test: pull_naomi handles indicators input
test_that("pull_naomi handles indicators input", {
  indicators <- c("HIV prevalence", "ART coverage")
  result <- pull_naomi(indicators = indicators)
  expect_s3_class(result, "data.frame")
  expect_true(all(result$indicator %in% indicators))  # Check if indicators match
})

# Test: pull_naomi returns appropriate data for age_groups
test_that("pull_naomi returns appropriate data for age_groups", {
  result <- pull_naomi(age_groups = c("0-14", "15-49"))
  expect_s3_class(result, "data.frame")
  expect_true(all(result$age_group %in% c("0-14", "15-49")))  # Check age groups
})

# Test: pull_naomi returns appropriate data for sex_options
test_that("pull_naomi returns appropriate data for sex_options", {
  result <- pull_naomi(sex_options = c("Male"))
  expect_s3_class(result, "data.frame")
  expect_true(all(result$sex %in% c("Male")))  # Check sex options
})

# Test: pull_naomi returns appropriate data for periods
test_that("pull_naomi returns appropriate data for periods", {
  result <- pull_naomi(periods = c("December 2022"))
  expect_s3_class(result, "data.frame")
  expect_true(all(result$period %in% c("December 2022")))  # Check periods
})

# Test: pull_naomi returns an appropriate structure for verbose mode
test_that("pull_naomi returns an appropriate structure for verbose mode", {
  result <- pull_naomi(verbose = TRUE)
  expect_type(result, "list")  # Expecting a list structure when verbose
  expect_true(length(result) > 0)  # Check if the list is not empty
})

# Test: pull_naomi returns a list when there are failed requests
test_that("pull_naomi returns a list when there are failed requests", {
  result <- pull_naomi(countries = "nonexistent_country")  # Example of a nonexistent country
  expect_type(result, "list")
  expect_true("fail_data" %in% names(result))  # Check if there is a failed request entry
})

# Test: pull_naomi respects max_level parameter
test_that("pull_naomi respects max_level parameter", {
  result <- pull_naomi(max_level = 2)  # Assume 2 corresponds to a specific level (e.g., district)
  expect_s3_class(result, "data.frame")  # Check that the result is a data frame
  # Assuming levels are coded numerically, check that all levels are less than or equal to max_level
  expect_true(all(result$level <= 2))  # Ensure all level entries are within the allowed max_level
})


# Test: pull_naomi handles age_groups input correctly
test_that("pull_naomi handles age_groups input correctly", {
  result <- pull_naomi(age_groups = "standard")  # Assuming 'standard' returns specific age groups
  expect_s3_class(result, "data.frame")
  expect_true(all(result$age_group %in% c("<1", "1-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50+")))  # Check standard age groups
})

# Test: pull_naomi handles dreams countries input correctly
test_that("pull_naomi handles dreams countries input", {
  dreams_countries <- c("Botswana", "Cote D'ivoire", "Haiti", "Kenya", "Lesotho",
                        "Malawi", "Mozambique", "Namibia", "Rwanda", "South Africa",
                        "South Sudan", "Tanzania", "Uganda", "Zambia", "Zimbabwe")

  result <- pull_naomi(countries = "dreams")  # Call with dreams parameter
  expect_s3_class(result, "data.frame")  # Check that the result is a data frame
  expect_true(all(result$country %in% dreams_countries))  # Ensure countries match
  expect_equal(unique(result$country), dreams_countries)  # Ensure all DREAMS countries are present
})
