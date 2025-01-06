#' @import dplyr
#' @import glue
#' @import purrr
#' @import readr
#' @import tidyr
#' @import httr
#' @import countrycode
#' @import progressr
#' @importFrom dplyr %>%
#' @importFrom dplyr mutate
#' @importFrom progressr progress

#' @title
#' Pull NAOMI Data
#'
#' @description
#' This function processes the country parameters, creates URLs, and fetches
#' data from the NAOMI API.
#'
#' @param countries A character vector of country names. Defaults to "all".
#' @param indicators A character vector of indicator names. Defaults to "all".
#' @param age_groups A character vector of age group strings. Defaults to "standard".
#' @param sex_options A character vector of sex options. Defaults to "all".
#' @param periods A character vector of period strings. Defaults to "recent".
#' @param max_level A character or integer representing area level. Defaults to "none".
#' @param verbose A logical value indicating whether to print progress messages. Defaults to FALSE.
#' @return A data frame containing the combined results from the API, or a list with
#'         separate entries for successful and failed requests.
#' @export
pull_naomi <- function(countries = "all", indicators = "all",
                       age_groups = "standard", sex_options = "all",
                       periods = "recent", max_level = 5,
                       verbose = FALSE, csv = FALSE, wait = 0) {

  load(system.file("data", "all_countries.RData", package = "visiblespectrum"))
  load(system.file("data", "all_indicators.RData", package = "visiblespectrum"))

  # Validate inputs before proceeding
  validate_inputs(countries, indicators, age_groups, sex_options, periods, verbose)

  countries <- handle_default_input(countries, "all", unlist(all_countries))
  if (length(countries) == 1 && countries == "dreams") {
    countries <- c("Botswana", "Cote D'ivoire", "Haiti", "Kenya", "Lesotho",
                   "Malawi", "Mozambique", "Namibia", "Rwanda", "South Africa",
                   "Tanzania", "Uganda", "Zambia", "Zimbabwe")
  }

  indicators <- handle_default_input(indicators, "all", all_indicators[[1]][[1]])
  indicators <- handle_default_input(indicators, "no anc", c("Population", "HIV prevalence", "PLHIV",
                                                             "ART coverage", "ART number (residents)",
                                                             "ART number (attending)", "PLHIV not on ART",
                                                             "Proportion PLHIV aware", "Number PLHIV unaware",
                                                             "Number PLHIV aware", "PLHIV (ART catchment)",
                                                             "Untreated PLHIV (ART catchment)", "Number aware PLHIV (ART catchment)",
                                                             "Number unaware PLHIV (ART catchment)", "HIV incidence per 1000",
                                                             "New infections"))
  age_groups <- handle_default_input(age_groups, "standard",
                                     c("<1", "1-4", "5-9", "10-14", "15-19", "20-24", "25-29",
                                       "30-34", "35-39", "40-44", "45-49", "50+"))
  sex_options <- handle_default_input(sex_options, "all", c("Male", "Female", "Both"))
  periods <- handle_default_input(periods, "recent", "December 2023")  # Adjust this when needed!

  if (verbose) {
    log_message("Processing country parameters...")
  }

  # Process country parameters
  processed_country_param_dt <- process_country_parameters(
    countries = countries,
    indicators = indicators,
    age_groups = age_groups,
    sex_options = sex_options,
    periods = periods
  )

  if (verbose) {
    log_message("Country parameters processed.")
  }

  if (verbose) {
    log_message("Creating URLs...")
  }

  # Create URLs
  param_combinations_with_code <- create_urls(processed_country_param_dt, max_level)

  if (verbose) {
    log_message("URLs created.")
    print(param_combinations_with_code)
  }

  results_list <- list()
  success_count <- 0
  fail_count <- 0
  fail_list <- list()
  expected_requests <- length(indicators) * length(age_groups) * length(sex_options) * length(periods)

  for (i in seq_len(nrow(param_combinations_with_code))) {
    url <- param_combinations_with_code$url[i]

    if (verbose) {
      log_message(paste0("Processing: ", url))
    }

    response <- httr::GET(url)

    if (httr::status_code(response) == 200) {
      response_content <- httr::content(response, "text")

      # Read the CSV data from the response
      df_final <- read_csv(response_content, show_col_types = FALSE) %>%
        mutate(
          period = param_combinations_with_code$periods[i],
          period_year_quarter = param_combinations_with_code$code_period[i],
          age_group = param_combinations_with_code$age_groups[i],
          sex = param_combinations_with_code$sex_options[i],
          indicator = param_combinations_with_code$code_indicator[i],
          iso = param_combinations_with_code$code_iso[i],
          level = as.numeric(level),
          mean = as.numeric(mean),
          lower = as.numeric(lower),
          upper = as.numeric(upper)
        )

      # Handle the fill down of country names
      df_final <- df_final %>%
        mutate(country = NA) %>%
        mutate(country = ifelse(level == 0, area, NA)) %>%
        fill(country, .direction = "down") %>%
        mutate(country = ifelse(level == 0, area, country)) %>%
        select(-iso)

      if (nrow(df_final) != 0) {
        results_list[[i]] <- df_final
        success_count <- success_count + 1

        if (verbose) {
          log_message(paste0("Processed ",
                             param_combinations_with_code$periods[i],
                             " ", param_combinations_with_code$age_groups[i],
                             " ", param_combinations_with_code$sex_options[i],
                             " ", param_combinations_with_code$code_indicator[i],
                             "."))
        }
      } else {
        log_message(paste0("Failed ",
                           param_combinations_with_code$periods[i],
                           " ", param_combinations_with_code$age_groups[i],
                           " ", param_combinations_with_code$sex_options[i],
                           " ", param_combinations_with_code$code_indicator[i],
                           "."))
        fail_count <- fail_count + 1
        fail_record <- param_combinations_with_code[i, ] %>%
          select(periods, age_groups, sex_options, code_indicator, url)
        fail_list[[i]] <- fail_record
        next
      }
    } else {
      log_message(paste("Failed to fetch data for URL:", url,
                        "with status code:", httr::status_code(response)))
      fail_count <- fail_count + 1
      fail_record <- param_combinations_with_code[i, ] %>%
        select(periods, age_groups, sex_options, code_indicator, url)
      fail_list[[i]] <- fail_record
      next
    }

    # Sleep if wait is specified
    if (wait > 0) {
      Sys.sleep(wait)
    }
  }

  if (verbose) {
    log_message("Combining all queries' results...")
  }

  if (length(results_list) == 0) {
    log_message("No data fetched from the API.")
    return(NULL)
  }

  combined_results <- bind_rows(results_list)

  if (verbose) {
    num_rows <- nrow(combined_results)
    num_cols <- ncol(combined_results)
    log_message(paste("Combined results shape: ", num_rows, " rows and ",
                      num_cols, " columns."))
  }

  if (verbose) {
    log_message("Data fetching completed.")
  }

  log_message(paste("Expected requests:", expected_requests))
  log_message(paste("Successful requests:", success_count))
  log_message(paste("Failed requests:", fail_count))

  if (fail_count == 0) {
    if (csv) {
      write_csv(combined_results, "naomi_results.csv")
      log_message("Results downloaded to current directory as naomi_results.csv")
    }
    return(combined_results)
  } else {
    failed_requests_df <- bind_rows(fail_list)
    cat("Failures in query. To see successful results: $success_data. To see failures, view $fail_data")

    if (csv) {
      write_csv(combined_results, "naomi_results.csv")
      log_message("Successful results downloaded to current directory as naomi_results.csv")
    }

    return(list(success_data = combined_results, fail_data = failed_requests_df))
  }
}
