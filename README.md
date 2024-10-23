# 🌈 visiblespectrum 🌈




**A package to scrape the UNAIDS NAOMI Spectrum HIV sub-national estimates viewer.**

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
## Usage
The main function to retrieve data is `pull_naomi`. Users can customize the data retrieval by providing parameters as follows:

```R
pull_naomi(
  countries = "all",   # Options: a list, "all", or "dreams"
  indicators = "all",  # Options: a list or "all"
  age_groups = "standard", # Options: a list or "standard"
  sex_options = "all", # Options: a list or "all"
  periods = "recent",  # Options: a list or "recent"
  max_level = "none",  # Integer indicating the maximum area level depth or "none"
  verbose = FALSE      # Logical indicating whether to print progress messages
)
```
#### Example Queries

```R
# Pull defaults
pull_naomi()

# Pull one query for Angola's 15-19 female population in December 2023
pull_naomi(
  countries = c("Angola"),
  indicators = c("Population"),
  age_groups = c("15-19"),
  sex_options = c("Female"),
  periods = c("December 2023")

# Pull ART coverage for DREAMS countries for females aged 15-24 in the most recent period (default) at area levels 0 and 1
pull_naomi(
  countries = "dreams", 
  indicators = c("ART coverage"), 
  age_groups = c("15-24"), 
  sex_options = c("Female"), 
  max_level = 1
)

# Pull HIV prevalence for all ages (together) for all genders (together) in all countries at the country (area level 0) level
pull_naomi(
  indicators = c("HIV prevalence"),
  age_groups = c("all ages"),
  sex_options = c("Both"),
  max_level = 0
)
```

## Parameters

- **`countries`**: A character vector specifying the countries to include. Options are `"all"`, `"standard"`, or `"dreams"`.
- **`indicators`**: A character vector for the indicators of interest. Options include `"all"` or a specific list.
- **`age_groups`**: A character vector for the desired age groups. Can be set to `"standard"` or a specific list.
- **`sex_options`**: A character vector specifying the sex options. Defaults to `"all"`.
- **`periods`**: A character vector for the periods of interest. Defaults to `"recent"`.
- **`max_level`**: An integer representing the maximum area level to retrieve data for.
- **`verbose`**: A logical value that controls whether progress messages are printed during data retrieval.


---

### In Development
- Improve error handling for expected data gaps, such as:
  - **Namibia**: Missing PEDS (0-14) data.
  - Some countries missing data for **`ANC tested negative`** and **`ANC tested positive`**.
- Automatically select and use the most recent available period for all countries.
- Introduce more robust testing procedures.
- Draft more detailed vignettes.
- Fix issues with the **progress bar** not showing up when using package (but functioning when running in RStudio as a script).
- Resolve Shiny-related issues in the `Input Tables` vignette (Shiny not functioning as a vignette).
- Address the warning message regarding **`httr`** and **`progressr`** upon loading.
- Create a standard set of input indicators that would be most useful (there are 27 indicators at present and under the default, they are all being run)
- Add download as a CSV functionality to `pull_naomi`
- Add all periods functionality to `pull_naomi`
- Explain what the all/standard input params are
- Add rerun functionality for fails
- Dig into periods issue and handle Mozambique (see notes)

### Notes
- **Eswatini** is listed as **`ESW`** in the dataset. The ISO code expected by `countrycode` is **`SWZ`**.
- **Namibia** does not have data for the `0-14` age group, which will result in failures when attempting to retrieve it.
- Several countries do not have data for `ANC Positive`/`ANC Negative` even though in the NAOMI UI they are dropdown options.
- Area levels are 0-based, meaning level 0 represents the country level. When specifying a max level depth, the data will include levels from 0 up to the selected max. For example, setting `max_level = 2` will return data for levels 0 (country), 1, and 2.
- Every country has data for period December 2023, which is why it was used for development. All countries have a dropdown option (may not include all data) for September 2024 (Q3) except for Mozambique, which has the option for December 2024 (Q4). It appears in future years as well Mozambique is one quarter later than all other countries.
- `pull_naomi` and `validate_parameters` are the external methods



---
*Disclaimer: The findings, interpretation, and conclusions expressed herein are those of the authors and do not necessarily reflect the views of United States Agency for International Development. All errors remain our own.*
