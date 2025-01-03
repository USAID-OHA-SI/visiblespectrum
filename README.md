# 🌈 visiblespectrum 🌈




**A package to scrape the UNAIDS NAOMI Spectrum HIV sub-national estimates viewer.**

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Usage and Parameters](#usage-and-parameters)
4. [In Development](#in-development)
5. [Notes](#notes)
6. [License](#license)

## Overview

The `visiblespectrum` package is currently in development and aims to provide users with easy access to HIV sub-national estimates from the [UNAIDS NAOMI Spectrum tool](https://naomi-spectrum.unaids.org/). The primary function for pulling data is `pull_naomi`, which allows users to specify various parameters to customize their queries.

## Installation

To install the development version of `visiblespectrum`, you can use the `devtools` package. Make sure you have `devtools` installed, then run:

```R
# Install devtools if you haven't already
install.packages("devtools")

# Install visiblespectrum from GitHub
devtools::install_github("USAID-OHA-SI/visiblespectrum")
```
## Usage and Parameters
The main function to retrieve data is `pull_naomi`. Users can customize the data retrieval by providing parameters as follows:

```R
pull_naomi(
  countries = "all",   # Character vector, "all", or "dreams"
  indicators = "all",  # Character vector, "all" or "no anc"
  age_groups = "standard", # Character vector or "standard"
  sex_options = "all", # Character vector or "all"
  periods = "recent",  # Character vector or "recent"
  max_level = 5,       # Integer
  verbose = FALSE,     # Logical
  csv = FALSE,         # Logical
  wait = 0             # Numeric
)
```

### Parameters

- **`countries`**: A character vector specifying the countries to include. Options are `"all"` or `"dreams"`.
- **`indicators`**: A character vector for the indicators of interest. Options include `"all"`, `"no anc"`, or a specific list.
- **`age_groups`**: A character vector for the desired age groups. Can be set to `"standard"` or a specific list.
- **`sex_options`**: A character vector specifying the sex options. Defaults to `"all"`.
- **`periods`**: A character vector for the periods of interest. Defaults to `"recent"`.
- **`max_level`**: An integer representing the maximum area level to retrieve data for.
- **`verbose`**: A logical value that controls whether progress messages are printed during data retrieval.
- **`csv`**: A logical value that controls whether the results will be saved as a CSV or not. CSVs save in the current working directory.
- **`wait`**: An optional float parameter that introduces a delay (in seconds) between API requests. This can help reduce errors if too many requests are sent in a short period. Set to `0` for no delay, or to a positive value to wait before each request.

#### Parameter Input Options

Input any of the possible values into a character vector (ensure each value is enclosed in quotes). View the full list of parameters here: [https://github.com/USAID-OHA-SI/visiblespectrum/blob/main/inst/extdata/all_parameters_summary.csv][all_parameters_summary.csv].

You can also use the predefined input options below:

| Parameter    | Option        | Description                                                                                                               |
|--------------|---------------|---------------------------------------------------------------------------------------------------------------------------|
| `countries`  | `"all"`      | `c("Angola", "Benin", "Botswana", "Burkina Faso", "Burundi", "Chad", "Congo", "Cote D'ivoire", "Democratic Republic of the Congo", "Eritrea", "Eswatini", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea", "Guinea Bissau", "Haiti", "Kenya", "Lesotho", "Liberia", "Malawi", "Mali", "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda", "Sierra Leone", "South Africa", "Togo", "Uganda", "United Republic of Tanzania", "Zambia", "Zimbabwe")` |
| `countries`  | `"dreams"`   | `c("Botswana", "Cote D'ivoire", "Haiti", "Kenya", "Lesotho", "Malawi", "Mozambique", "Namibia", "Rwanda", "South Africa", "South Sudan", "Tanzania", "Uganda", "Zambia", "Zimbabwe")` |
| `indicators` | `"all"`        | `c("Population", "HIV prevalence", "PLHIV", "ART coverage", "ART number (residents)", "ART number (attending)", "PLHIV not on ART", "Proportion PLHIV aware", "Number PLHIV unaware", "Number PLHIV aware", "PLHIV (ART catchment)", "Untreated PLHIV (ART catchment)", "Number aware PLHIV (ART catchment)", "Number unaware PLHIV (ART catchment)", "HIV incidence per 1000", "New infections", "ANC HIV prevalence", "ANC prior ART coverage", "ANC clients", "HIV positive ANC attendees", "ANC attendees already on ART", "ART initiations at ANC", "ANC known positive", "ANC tested positive", "ANC tested negative")` |
| `indicators` | `"no anc"`        | `c("Population", "HIV prevalence", "PLHIV", "ART coverage", "ART number (residents)", "ART number (attending)", "PLHIV not on ART", "Proportion PLHIV aware", "Number PLHIV unaware", "Number PLHIV aware", "PLHIV (ART catchment)", "Untreated PLHIV (ART catchment)", "Number aware PLHIV (ART catchment)", "Number unaware PLHIV (ART catchment)", "HIV incidence per 1000", "New infections"` |
| `age_groups` | `"standard"`   | `c("<1", "1-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50+")`                      |
| `sex_options`| `"all"`      | `c("Male", "Female", "Both")`                                                                                          |
| `periods`    | `"recent"`   | Most recent period. Currently set to `December 2023`.                                                                     |
| `max_level`  | `5`     | No max level is set. Highest area level depth will be used.                                                              |

### Example Queries

```R
library(visiblespectrum)

# Pull defaults
defaults_query <- pull_naomi()
View(defaults_query)

# Pull one query for Angola's 15-19 female population in December 2023 and save to CSV
single_inputs_query <- pull_naomi(
  countries = c("Angola"),
  indicators = c("Population"),
  age_groups = c("15-19"),
  sex_options = c("Female"),
  periods = c("December 2023"),
  csv = TRUE
)
View(single_inputs_query)

# Pull ART coverage for DREAMS countries for females aged 15-24 at area levels 0 and 1 with a wait
dreams_art_query <- pull_naomi(
  countries = "dreams", 
  indicators = c("ART coverage"), 
  age_groups = c("15-24"), 
  sex_options = c("Female"), 
  max_level = 1,
  wait = 0.5
)
View(dreams_art_query)

# Pull HIV prevalence for all ages (together) for all genders (together) in all countries at the country (area level 0) level
hiv_prev_country_level_query <- pull_naomi(
  indicators = c("HIV prevalence"),
  age_groups = c("all ages"),
  sex_options = c("Both"),
  max_level = 0
)
View(hiv_prev_country_level_query)

```

---

### In Development

#### Higher Priority
- Improve graceful error handling for expected data gaps, such as:
  - **Namibia**: Missing PEDS (0-14) data.
  - Some countries missing data for ANC indicators including **`ANC tested negative`** and **`ANC tested positive`**.
- Automatically select and use the most recent available period for all countries.
  - Dig into periods issue and handle Mozambique (see notes)
- Introduce more robust testing procedures.
- Add rerun functionality for fails.

#### Lower Priority
- Add all periods functionality to `pull_naomi`.
- Fix issues with the **progress bar** not showing up when using package (but functioning when running in RStudio as a script).
- Address the warning message regarding **`httr`** and **`progressr`** upon loading.

#### Need More Information
- Create a standard set of input indicators that would be most useful (there are 27 indicators at present and under the default, they are all being run)
  - What should this standard set be?
- Draft more detailed vignettes.
  - What should it/they look like?
- Fix `README` to be more standardized (only necessary if `visiblespectrum` will be separate from `mindthegap`)


### Notes
- **Eswatini** is listed as **`ESW`** in the dataset. The ISO code expected by `countrycode` is **`SWZ`**.
- **Namibia** does not have data for the `0-14` age group, which will result in failures when attempting to retrieve it.
- Several countries do not have data for `ANC Positive`/`ANC Negative` even though in the NAOMI UI they are dropdown options.
- Area levels are 0-based, meaning level 0 represents the country level. When specifying a max level depth, the data will include levels from 0 up to the selected max. For example, setting `max_level = 2` will return data for levels 0 (country), 1, and 2.
- Every country has data for period `December 2023`, which is why it was used for development. All countries have a dropdown option (may not include all data) for `September 2024` (Q3) except for Mozambique, which has the option for `December 2024` (Q4). It appears in future years as well Mozambique is one quarter later than all other countries.
- `pull_naomi` and `validate_parameters` are external methods.



---
*Disclaimer: The findings, interpretation, and conclusions expressed herein are those of the authors and do not necessarily reflect the views of United States Agency for International Development. All errors remain our own.*
