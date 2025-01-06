#' Helper Functions for the visiblespectrum Package
#'
#' This file contains various helper functions used in the visiblespectrum package
#' for processing country parameters and creating API URLs.

#' @import dplyr
#' @import glue
#' @import purrr
#' @import readr
#' @import tidyr
#' @import countrycode
#' @import stringdist
#' @importFrom dplyr %>%
#' @importFrom dplyr mutate


#------------------- Helper Functions -------------------

#' @title
#' Log messages with timestamp
#'
#' @description
#' This function logs messages to the console with a timestamp.
#'
#' @param message A character string to log.
log_message <- function(message) {
  cat("[LOG]", Sys.time(), message, "\n")
}

#' Convert age group codes to human-readable format
#'
#' @param age_range A character string representing the age group (e.g., "Y015_049").
#' @return A character string representing the age range, or NA if the input
#' format is invalid.
age_range_to_code <- function(age_range) {
  if (is.na(age_range)) {
    return(NA)
  }

  if (age_range == "all ages") {
    return("Y000_999")
  }
  if (age_range == "<1") {
    return("Y000_000")
  }

  if (grepl("\\+", age_range)) {
    start_age <- as.numeric(gsub("\\+", "", age_range))
    return(paste0("Y", sprintf("%03d", start_age), "_999"))
  }

  age_parts <- unlist(strsplit(age_range, "-"))
  start_age <- as.numeric(age_parts[1])
  end_age <- as.numeric(age_parts[2])

  start_code <- sprintf("%03d", start_age)
  end_code <- sprintf("%03d", end_age)

  return(paste0("Y", start_code, "_", end_code))
}

#' Convert country names to ISO country codes
#'
#' @param country_name A character string representing the country name (e.g.,
#' "United States").
#' @return A character string representing the ISO country code, or NA if the
#' country name is not found.
country_name_to_iso <- function(country_name) {
  iso_codes <- ifelse(
    country_name == "Eswatini", "ESW", # Eswatini is ESW in database, not SWZ as in ISO3C
    countrycode(country_name, origin = "country.name",
                destination = "iso3c")
  )

  # Handle cases where countrycode might return NA
  if (any(is.na(iso_codes))) {
    warning(paste(
      "Unrecognized country names:",
      paste(country_name[is.na(iso_codes)], collapse = ", ")
    ))
  }

  return(iso_codes)
}

#' Convert date string to "YYYY-Q" format
#'
#' @param date_string A character string representing the date (e.g., "January
#' 2024").
#' @return A character string formatted as "YYYY-Q".
convert_date_to_quarter_YYYY_Q <- function(date_string) {
  date_parsed <-
    as.Date(paste("01", date_string), format = "%d %B %Y")
  year <- format(date_parsed, "%Y")
  month <- as.numeric(format(date_parsed, "%m"))

  quarter <- case_when(month %in% 1:3 ~ 1, # January, February, March -> Q1
                       month %in% 4:6 ~ 2, # April, May, June -> Q2
                       month %in% 7:9 ~ 3, # July, August, September -> Q3
                       month %in% 10:12 ~ 4, # October, November, December -> Q4
                       TRUE ~ NA_real_)    # In case of an invalid month

  return(paste(year, quarter, sep = "-"))
}

#------------------- Main Processing Function -------------------

#' Process Country Parameters for API Calls
#'
#' Loads country parameter data and indicator data, processes them, and returns
#' a data frame containing processed parameters with corresponding codes.
#'
#' @param countries A character vector of country names.
#' @param indicators A character vector of indicator names.
#' @param age_groups A character vector of age group strings.
#' @param sex_options A character vector of sex options.
#' @param periods A character vector of period strings.
#' @return A data frame containing processed country parameters with ISO codes,
#' age codes, sex options, and date periods.
process_country_parameters <- function(countries,
                                       indicators,
                                       age_groups,
                                       sex_options,
                                       periods) {
  # Load indicators_df to convert indicators to indicator codes
  load(system.file("data", "indicators_df.RData", package = "visiblespectrum"))

  country_param_dt <- expand.grid(
    age_groups = age_groups,
    sex_options = sex_options,
    indicators = indicators,
    periods = periods,
    stringsAsFactors = FALSE
  )

  processed_country_param_dt <- country_param_dt %>%
    left_join(indicators_df, by = c("indicators" = "indicator_name")) %>%
    mutate(
      code_iso = list(sapply(countries, country_name_to_iso)),
      code_indicator = indicator_code,
      code_age = map(age_groups, age_range_to_code) %>% map(~ .x[!is.na(.x)]),
      code_sex = tolower(sex_options),
      code_period = map(periods, convert_date_to_quarter_YYYY_Q) %>% map(~ .x[!is.na(.x)])
    ) %>%
    select(-indicator_code)

  return(processed_country_param_dt)
}

#' Create API URLs from parameter combinations
#'
#' This function constructs URLs for API calls based on country parameter
#' combinations.
#'
#' @param processed_country_param_dt A data frame containing parameter
#' combinations with code columns.
#' @param max_level A character or integer representing the user-specified area
#' level.
#' @return A data frame with constructed URLs.
create_urls <- function(processed_country_param_dt, max_level) {
  # Load the max levels data
  load(system.file("data", "country_max_levels.RData", package = "visiblespectrum"))

  # Base URL for API calls
  BASE_URL <- "https://naomiviewerserver.azurewebsites.net/api/v1/data?"

  # Add country codes and area level, then group and summarize
  processed_country_param_dt <- processed_country_param_dt %>%
    mutate(country_codes = sapply(code_iso, paste, collapse = "&country=")) %>%
    mutate(level = max_level) %>%
    mutate(
      url = glue(
        "{BASE_URL}country={URLencode(country_codes)}&indicator={URLencode(code_indicator)}&ageGroup={URLencode(code_age)}&period={URLencode(code_period)}&sex={URLencode(code_sex)}&areaLevel={level}"
      )
    )

  return(processed_country_param_dt)
}

#' Validate Input Parameters for Data Scraping
#'
#' This function checks the validity of the input parameters used for scraping data.
#' It ensures that the provided countries, indicators, age groups, sex options, periods,
#' and maximum level meet the predefined criteria.
#'
#' @param countries A character vector of countries. Accepts "all" or "dreams"
#'        as valid options, or a specific country from the predefined list.
#' @param indicators A character vector of indicators. Accepts "all" or a specific
#'        indicator from the predefined list.
#' @param age_groups A character vector of age groups. Accepts "standard" or a
#'        specific age group from the predefined list.
#' @param sex_options A character vector of sex options. Accepts "all" or a specific
#'        option from the predefined list (i.e., "Both", "Male", "Female").
#' @param periods A character vector of periods in the format "Month YYYY". Each
#'        period must match the specified format.
#' @param max_level A numeric value representing the maximum level. Must be a
#'        whole number greater than 0.
#' @param verbose A logical value indicating whether to print messages about input
#'        validation. Defaults to FALSE.
#' @return NULL If all inputs are valid. Stops execution and throws an error
#'         message if any input is invalid, including suggestions for valid inputs.
#' @export
validate_inputs <-
  function(countries,
           indicators,
           age_groups,
           sex_options,
           periods,
           verbose) {
    load(system.file("data", "all_countries.RData", package = "visiblespectrum"))
    valid_countries <- unlist(all_countries)
    load(system.file("data", "all_indicators.RData", package = "visiblespectrum"))
    valid_indicators <- unlist(all_indicators)
    valid_age_groups <- c("15-49", "15-64", "15+", "50+", "all ages", "0-64", "0-14",
                          "15-24", "25-34", "35-49", "50-64", "65+", "10-19", "25-49",
                          "0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34",
                          "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69",
                          "70-74", "75-79", "80+", "<1", "1-4")
    valid_sex_options <- c("Both", "Male", "Female")

    suggest_closest <- function(input, valid_options) {
      dist <- stringdist::stringdist(input, valid_options, method = "lv")
      closest <- valid_options[which.min(dist)]

      if (min(dist) <= 2) {
        return(closest)
      } else {
        return(NULL)
      }
    }

    validate_param <- function(input, valid_options, param_name) {
      if (all(input %in% valid_options)) {
        return(TRUE)
      }

      for (value in input) {
        if (!(value %in% valid_options)) {
          suggested <- suggest_closest(value, valid_options)
          stop(
            glue(
              "Invalid parameter: {value}. Did you mean {suggested}? Rerun with valid input value."
            )
          )
        }
      }
    }

    # Validate all inputs
    if (!(length(countries) == 1 &&
          (countries %in% c("all", "dreams")))) {
      validate_param(countries, valid_countries, "country")
    }

    if (!(length(indicators) == 1 && indicators %in% c("all", "no anc"))) {
      validate_param(indicators, valid_indicators, "indicator")
    }

    if (!(length(age_groups) == 1 && age_groups == "standard")) {
      validate_param(age_groups, valid_age_groups, "age group")
    }

    if (!(length(sex_options) == 1 && sex_options == "all")) {
      validate_param(sex_options, valid_sex_options, "sex option")
    }

    # Validate periods
    if (periods != "recent" &&
        !all(
          grepl(
            "\\b(?:January|February|March|April|May|June|July|August|September|October|November|December)\\s\\d{4}\\b",
            periods
          )
        )) {
      stop(
        "Invalid periods format. Please provide periods in the format 'Month YYYY', e.g., 'December 2023'."
      )
    }

    if (verbose) {
      message("All inputs are valid.")
    }
  }

#' Handle Default Input Values
#'
#' This helper function manages default input handling by returning a set of valid values
#' when the input matches a specified default value. If the input does not match the default,
#' the original input is returned.
#'
#' @param input A vector of input values to be validated.
#' @param default_value A value that represents the default input option.
#' @param valid_values A vector of valid values to return if the input matches the default.
#'
#' @return A vector of input values or the predefined valid values if the input matches the default.
handle_default_input <-
  function(input, default_value, valid_values) {
    if (length(input) == 1 && input == default_value) {
      return(valid_values)
    }
    return(input)
  }
