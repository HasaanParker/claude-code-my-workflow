# =============================================================================
# 02_clean.R — Restrict to the double-donor era and build the panelvar-ready frame.
#
# GCDF only covers 2000-2021; pre-2000 china_aid is a structural 0 (no data),
# not a genuine absence of Chinese finance, so including 1970-1999 would treat
# a coverage artifact as a real dynamic. The VAR panel is restricted to
# 2000-2021, the window both flows can genuinely co-move in.
#
# Produces: var_df (balanced iso3c x Year panel, 2000-2021) for 03_analyze.R.
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
})

if (!exists("raw_panel", inherits = FALSE)) {
  stop("02_clean.R: raw_panel not found. Run 00_run_all.R, not this script directly.")
}

VAR_YEARS <- 2000:2021

var_df <- raw_panel |>
  filter(Year %in% VAR_YEARS) |>
  transmute(
    iso3c, Year, region,
    log_us_aid    = log(us_aid + 1),
    log_china_all = log(china_all + 1),
    log_china_oda = log(china_oda + 1)
  ) |>
  arrange(iso3c, Year)

# Panel balance check -- panelvar's GMM tolerates gaps, but a fully balanced
# panel (guaranteed by 01_quant_main's expand_grid construction) is the clean
# case and worth confirming rather than assuming.
years_per_country <- var_df |> summarise(n_years = dplyr::n(), .by = iso3c)
n_balanced <- sum(years_per_country$n_years == length(VAR_YEARS))

message(sprintf(
  "02_clean: var_df %d rows, %d countries (%d fully balanced over %d..%d), NA=%d",
  nrow(var_df), dplyr::n_distinct(var_df$iso3c), n_balanced,
  min(VAR_YEARS), max(VAR_YEARS), sum(!complete.cases(var_df))
))
