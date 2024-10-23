## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = FALSE)
library(knitr)
library(dplyr)
library(kableExtra)
library(gt)
library(flextable)
library(officer)
library(glitr)
library(htmltools)
invisible(library(here))
knitr::opts_chunk$set(warning = FALSE)

## ----load, echo=FALSE---------------------------------------------------------
load(system.file("extdata", "output.RData", package = "visiblespectrum"))
load(system.file("extdata", "ui_scrape.RData", package = "visiblespectrum"))

## ----results='asis'-----------------------------------------------------------
options_summary_df <- output$options_summary_df 

options_summary_df <- options_summary_df %>%
  mutate(
    parameter = recode(
      parameter,
      "ui_country" = "Countries",
      "ui_indicators" = "Indicators",
      "ui_ages" = "Age Categories",
      "ui_sexes" = "Sex Options",
      "ui_periods" = "Periods"
    )
  )

ui_scrape <- ui_scrape %>%
  mutate(
    ui_num_levels = ui_num_levels - 1 #area levels are 0 based, so go back 1
  )

parameters_by_country <- ui_scrape %>%
  rename(
    Country = ui_country,
    Indicators = ui_indicators,
    Ages = ui_ages,
    Sex_Options = ui_sexes,
    Periods = ui_periods,
    Max_Level = ui_num_levels
  ) %>%
  group_by(Country) %>%
  summarize(
    Indicators = as.character(paste(unique(unlist(Indicators)), collapse = ", ")),
    Ages = as.character(paste(unique(unlist(Ages)), collapse = ", ")),
    Sex_Options = as.character(paste(unique(unlist(Sex_Options)), collapse = ", ")),
    Periods = as.character(paste(unique(unlist(Periods)), collapse = ", ")),
    Max_Level = max(Max_Level)
  )

## ----echo=FALSE---------------------------------------------------------------
write.csv(options_summary_df, here("inst/extdata", "all_parameters_summary.csv"), row.names = FALSE)
write.csv(parameters_by_country, here("inst/extdata", "parameters_by_country.csv"), row.names = FALSE)

## ----echo=FALSE---------------------------------------------------------------
# Display the modified DataFrame
kable(options_summary_df)%>%
  kable_styling() %>%
  column_spec(1, bold = TRUE)


## ----echo=FALSE---------------------------------------------------------------
defaults_df <- output$defaults_df
defaults_df <- defaults_df %>%
    mutate(
    parameter = recode(
      parameter,
      "ui_country" = "Countries",
      "ui_indicators" = "Indicators",
      "ui_ages" = "Age Categories",
      "ui_sexes" = "Sex Options",
      "ui_periods" = "Periods"
    )
  )

kable(defaults_df)%>%
  kable_styling() %>%
  column_spec(1, bold = TRUE)


## -----------------------------------------------------------------------------
deviations_df <- output$deviations_df
deviations_df <- deviations_df %>%
    mutate(
    parameter = recode(
      parameter,
      "ui_country" = "Countries",
      "ui_indicators" = "Indicators",
      "ui_ages" = "Age Categories",
      "ui_sexes" = "Sex Options",
      "ui_periods" = "Periods"
    )
  )

## -----------------------------------------------------------------------------
kable(deviations_df)  %>%
  kable_styling() %>%
  column_spec(1, bold = TRUE)

## -----------------------------------------------------------------------------
country_period_df <- output$country_period_df
column_names <- colnames(country_period_df)
columns_with_x <- sapply(country_period_df, function(col) all(col == 'x'))

## -----------------------------------------------------------------------------
border_style <- fp_border(color = light_grey, width = 1, style = "solid")
colormatrix <- ifelse(country_period_df[, -1] == "x", midnight_blue, "white")


country_period_ft <- flextable(country_period_df) %>%
  theme_vanilla() %>%
  font(part = "all", fontname = "Source Sans Pro") %>%
  border(border = border_style, part = "all") %>%
  vline(j = 2:ncol(country_period_df), border = border_style) %>% 

  bg(i = 1:nrow(country_period_df), j = 2:ncol(country_period_df), bg = colormatrix) %>%  
  bg(i = 1:nrow(country_period_df), j = 1, bg = light_grey, part = "body") %>%

  add_footer_lines("Countries marked with 'x' indicate participation in the respective periods.") %>%
  bg(part = "header", bg = suva_grey) %>%
  color(part = "header", color = nero) %>%
  color(part = "body", color = nero) %>%
  font(part = "header", fontname = "Source Sans Pro") %>%
  bold(part = "header") %>%
  bold(j = 1, part = "body") %>%
  align(align = "left", part = "all") %>%
  align(align = "left", part = "header") %>%
  align(align = "left", j = 1, part = "body") %>%
  align(align = "center", j = 2:ncol(country_period_df), part = "body") %>%
  set_table_properties(
    x = .,
    opts_html = list(
      scroll = list(
        height = "900px",
        freeze_first_column = TRUE
      )
    )
  )
country_period_ft


## -----------------------------------------------------------------------------
# Create a gt table
kable(parameters_by_country)%>%
  kable_styling() %>%
  column_spec(1, bold = TRUE)


