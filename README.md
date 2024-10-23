# 🌈 visiblespectrum 🌈




**A package to scrape the UNAIDS NAOMI Spectrum HIV sub-national estimates viewer.**

## Overview

The `visiblespectrum` package is currently in development and aims to provide users with easy access to HIV sub-national estimates from the UNAIDS NAOMI Spectrum tool. The primary function for pulling data is `pull_naomi`, which allows users to specify various parameters to customize their queries.

## Installation

To install the development version of `visiblespectrum`, you can use the `devtools` package. Make sure you have `devtools` installed, then run:

```R
# Install devtools if you haven't already
install.packages("devtools")

# Install visiblespectrum from GitHub
devtools::install_github("USAID-OHA-SI/visiblespectrum")
```
## Usage
The main function to retrieve data is pull_naomi. Users can customize the data retrieval by providing parameters as follows:

```R
pull_naomi(
  countries = "all",   # Options: a list, "standard", or "dreams"
  indicators = "all",  # Options: a list or "standard"
  age_groups = "standard", # Options: a list or "standard"
  sex_options = "all", # Options: a list or "recent"
  periods = "recent",  # Options: a list or "recent"
  max_level = "none",  # Integer indicating the maximum area level depth
  verbose = FALSE      # Logical indicating whether to print progress messages
)
```
## Parameters

- **countries**: A character vector specifying the countries to include. Options are "all", "standard", or "dreams".
- **indicators**: A character vector for the indicators of interest. Options include "all" or a specific list.
- **age_groups**: A character vector for the desired age groups. Can be set to "standard" or a specific list.
- **sex_options**: A character vector specifying the sex options. Defaults to "all".
- **periods**: A character vector for the periods of interest. Defaults to "recent".
- **max_level**: An integer representing the maximum area level to retrieve data for.
- **verbose**: A logical value that controls whether progress messages are printed during data retrieval.


---

### In Development:
- Improve error handling for expected data gaps, such as:
  - **Namibia**: Missing pediatric (PEDS) data.
  - Some countries missing data for **ANC tested negative** and **ANC tested positive**.
- Implement checks to ensure the user's input parameters are valid, and provide suggestions if not.
- Automatically select and use the most recent available period for all countries.
- Introduce more robust testing procedures.
- Draft more detailed vignettes.
- Fix issues with the **progress bar** not showing up when using package (but functioning when running in RStudio as a script).
- Resolve Shiny-related issues in the Input Tables vignette (Shiny not functioning as a vignette).
- Address the warning message regarding **httr** and **progressr** upon loading.
- Create a standard set of input indicators that would be most useful (there are 27 indicators at present and under the default, they are all being run)

### Notes:
- **Eswatini** is listed as **ESW** in the dataset. The ISO code expected by `countrycode` is **SWZ**.
- **Namibia** does not have data for the 0-14 age group, which will result in failures when attempting to retrieve it.
- Several countries do not have data for ANC Positive/ANC Negative even though in the NAOMI UI they are dropdown options.



---
*Disclaimer: The findings, interpretation, and conclusions expressed herein are those of the authors and do not necessarily reflect the views of United States Agency for International Development. All errors remain our own.*
