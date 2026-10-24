# =============================================================================
# 03_analyze.R — EDA diagnostics + short-run allocation models (spec MUST #1).
#
# Core model (matches the working recipe):
#   feols(log(us_aid + 1) ~ log(china_*_lag + 1) | Year + iso3c)
# fit POOLED and stratified by region (continent), for BOTH China measures
# (china_all = all official finance = baseline; china_oda = ODA-like only).
# An EXTENDED spec adds controls (log gdppc, log pop, US-alignment distance,
# all lagged like the treatment to avoid mixing predetermined and contemporaneous
# regressors) for the same cells. SEs are EXPLICITLY clustered by country via
# vcov = ~iso3c -- fixest's true no-argument default with two FEs is plain IID,
# not first-FE clustering (verified empirically 2026-09-14; an earlier version
# of this comment asserted "fixest default: first FE", which was wrong on this
# fixest version and meant the actual SEs used didn't match this file's own claim).
#
# The coefficient on log(china_*_lag + 1) is a short-run elasticity of US ODA
# w.r.t. lagged Chinese finance. H1: positive in Africa (aid race), negative
# elsewhere (aid withdrawal). Prospectus target: +0.113 in Africa — see the
# 2026-08-06 reproduction finding in the session log (direction reproduces,
# exact magnitude does not; vintage/input discrepancy, not tuned to force a match).
#
# Persists results.rds (fits + tidy coefficient tables) for 04/05.
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
  library(broom)
  library(ggplot2)
})

if (!exists("df", inherits = FALSE)) {
  stop("03_analyze.R: df not found. Run 00_run_all.R, not this script directly.")
}
if (!exists("OUT_DIR", inherits = FALSE)) {
  suppressPackageStartupMessages(library(here))
  OUT_DIR <- here::here("_outputs")
  dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)
}
DIAG_DIR <- file.path(OUT_DIR, "diagnostics")
dir.create(DIAG_DIR, showWarnings = FALSE, recursive = TRUE)

# ---- EDA: coverage + distributions -----------------------------------------
# Exploratory only (not committed figures, hence theme_bw() not the project
# theme — see 05_figures.R for the publication-ready theme, INV-12).
coverage_by_year <- df |>
  summarise(
    pct_china_all_positive = mean(china_all > 0),
    pct_china_oda_positive = mean(china_oda > 0),
    .by = Year
  )

p_coverage <- coverage_by_year |>
  tidyr::pivot_longer(-Year, names_to = "measure", values_to = "pct") |>
  ggplot(aes(Year, pct, color = measure)) +
  geom_line() +
  labs(title = "China aid coverage by year", y = "Share of countries with china aid > 0") +
  theme_bw()
ggsave(file.path(DIAG_DIR, "coverage_by_year.pdf"), p_coverage, width = 7, height = 4)

p_dist <- df |>
  filter(china_all > 0) |>
  transmute(log_us_aid = log(us_aid + 1), log_china_all = log(china_all + 1)) |>
  tidyr::pivot_longer(everything(), names_to = "var", values_to = "val") |>
  ggplot(aes(val)) +
  geom_histogram(bins = 40) +
  facet_wrap(~var, scales = "free") +
  labs(title = "Distributions (China-recipient-years only)") +
  theme_bw()
ggsave(file.path(DIAG_DIR, "distributions.pdf"), p_dist, width = 8, height = 4)

message(sprintf("03_analyze EDA: %d rows, china_all coverage %.1f%%, china_oda coverage %.1f%%",
                nrow(df), 100 * mean(df$china_all > 0), 100 * mean(df$china_oda > 0)))

MEASURES <- c(china_all = "china_all_lag", china_oda = "china_oda_lag")
REGIONS  <- c("Pooled", sort(unique(stats::na.omit(df$region))))
# SOI re-operationalization (2026-09-14): alignment-based bloc instead of
# continent -- see 02_clean.R "Sphere-of-influence: alignment-based bloc" and
# ch03_theory.tex. Order carries meaning: China-aligned (withdrawal predicted)
# -> Contested (race predicted) -> US-aligned (already secured, no sharp
# prediction) -- kept explicit rather than sorted, unlike REGIONS.
SOI_BLOCS <- c("Pooled", "China-aligned", "Contested", "US-aligned")
# This literal is duplicated in 04_tables.R and 05_figures.R (each numbered
# script stays self-contained; see the theme_dissertation() duplication note
# in 05_figures.R for the same tradeoff). Order is semantically meaningful
# (China-aligned -> Contested -> US-aligned) -- keep all three in sync.

# ---- ESTIMATION SAMPLE: the China era only (user decision, 2026-09-15) ----
# GCDF 3.0 covers commitment years 2000-2021 ONLY, so china_* is 0 for
# 1970-1999 *by construction* -- that is "no coverage," not "China gave
# nothing." Those rows carry no treatment variation but still shape the fixed
# effects, so a country whose US aid trended up over the same decades Chinese
# finance first appeared reads as a positive China->US response. Estimating on
# the full panel inflated every elasticity here (e.g. pre-frozen US-aligned
# 0.251 -> 0.084 on restriction; Europe 0.493 -> 0.214) -- see
# quality_reports/session_logs/2026-09-15_pre-china-baseline.md.
#
# `df` keeps the full 1970-2022 span (other analyses and the pre-1990s
# baseline construction need it); only the ESTIMATION sample is restricted.
# This matches how 04_var_dynamics/02_clean.R was already specified.
ANALYSIS_YEARS <- 2000:2021
df_est <- dplyr::filter(df, Year %in% ANALYSIS_YEARS)
message(sprintf("03_analyze: estimation sample = %d..%d (%d rows of %d in the full panel)",
                min(ANALYSIS_YEARS), max(ANALYSIS_YEARS), nrow(df_est), nrow(df)))

# A few recipient-years carry negative US ODA (net repayments/adjustments);
# log(us_aid + 1) is NaN for us_aid < -1 and feols drops them, as in the
# working recipe. Surface the count once rather than warn per fit.
n_neg_us <- sum(df_est$us_aid < -1, na.rm = TRUE)
message(sprintf("03_analyze: %d recipient-years with us_aid < -1 (dropped by log)", n_neg_us))

# Number of country FEs kept in a fit (estimation sample), robust to API.
n_fe_iso3c <- function(fit) {
  tryCatch(as.integer(fit$fixef_sizes[["iso3c"]]), error = function(e) NA_integer_)
}

# Fit one FE model for a (measure, stratum) cell, stratified on ANY column
# (region or soi_bloc_lag). vcov = ~iso3c is explicit (see header note) --
# do not rely on feols()'s no-argument default.
fit_cell <- function(lag_var, strat_col, strat_val) {
  d <- if (strat_val == "Pooled") df_est else dplyr::filter(df_est, .data[[strat_col]] == !!strat_val)
  fml <- stats::as.formula(
    sprintf("log(us_aid + 1) ~ log(%s + 1) | Year + iso3c", lag_var)
  )
  suppressWarnings(fixest::feols(fml, data = d, vcov = ~iso3c))
}

# Runs the (measure x stratum) grid for one stratifying column; returns a
# tidy coefficient table with `stratum` (level) and `strat_by` (column name)
# columns so baseline results from different cuts (region, soi_bloc_lag) can
# be stacked and compared directly.
run_grid <- function(strat_col, strat_levels, fit_fn = fit_cell) {
  fits_out <- list()
  rows_out <- list()
  for (mname in names(MEASURES)) {
    lag_var <- MEASURES[[mname]]
    for (s in strat_levels) {
      key <- paste(strat_col, mname, s, sep = ":")
      fit <- fit_fn(lag_var, strat_col, s)
      fits_out[[key]] <- fit
      td <- broom::tidy(fit)
      china_term <- paste0("log(", lag_var, " + 1)")
      china_row <- td[td$term == china_term, ]
      if (nrow(china_row) == 0) china_row <- td[1, ]  # baseline spec: single term, positional fallback
      rows_out[[key]] <- tibble::tibble(
        strat_by = strat_col, measure = mname, stratum = s,
        estimate = china_row$estimate[1], std.error = china_row$std.error[1],
        p.value = china_row$p.value[1], n_obs = fit$nobs, n_countries = n_fe_iso3c(fit)
      )
    }
  }
  list(fits = fits_out, coef_table = dplyr::bind_rows(rows_out))
}

# Both REGIONS and SOI_BLOCS include "Pooled", so this fits the pooled model
# twice per measure (identical formula, identical data) rather than once and
# reusing it across both grids. Accepted duplication (r-reviewer, 2026-09-14):
# a feols() fit here is milliseconds, and de-duping would mean threading a
# "Pooled belongs to region" special case through 04_tables.R/05_figures.R's
# per-stratum filtering for a cosmetic saving, not a correctness one.
region_res <- run_grid("region", REGIONS)
soi_res    <- run_grid("soi_bloc_lag", SOI_BLOCS)
# Pre-China baseline cut (2026-09-15): same grid, but the stratifier is the
# time-invariant 1990s-frozen bloc, so it cannot be contaminated by China-era
# aid driving alignment. This is the decisive test of the soi_bloc_lag result.
soi_pre_res <- run_grid("soi_bloc_pre", SOI_BLOCS)
fits <- c(region_res$fits, soi_res$fits, soi_pre_res$fits)
coef_table <- dplyr::bind_rows(region_res$coef_table, soi_res$coef_table, soi_pre_res$coef_table)

# ---- Extended spec: + controls (SHOULD: sensitivity to controls) -----------
# Adds log(gdppc_lag), log(pop_lag), and lagged US-alignment distance (SOI
# ingredient) to the same FE structure -- ALL lagged like the treatment, so
# predetermined-at-t-1 regressors aren't mixed with contemporaneous-at-t ones
# (recipient GDP/pop in year t is plausibly simultaneous with US aid decided
# in year t; lagging avoids that ambiguity without arguing it away in prose).
# NA controls (gdppc/pop/ideal-point gaps) shrink the estimation sample per
# cell -- n_obs in the table reflects that, not a separate flag.
#
# WDI availability guard: 01_load.R proceeds with raw_wdi = NULL if
# wdi_controls.rds is missing (fetch_wdi.R not yet run), and 02_clean.R's
# left_join then leaves gdppc/pop all-NA rather than erroring -- but an
# all-NA control would make every extended fit fail on zero complete cases.
# Skip the extended spec loudly rather than let feols() fail deep in a loop.
has_wdi_controls <- !all(is.na(df$gdppc))
if (!has_wdi_controls) {
  warning("03_analyze.R: gdppc is all-NA (wdi_controls.rds missing/empty) -- ",
          "skipping the extended (+controls) specification entirely. ",
          "Run scripts/R/fetch_wdi.R to enable it.", call. = FALSE)
}

fit_cell_ext <- function(lag_var, strat_col, strat_val) {
  d <- if (strat_val == "Pooled") df_est else dplyr::filter(df_est, .data[[strat_col]] == !!strat_val)
  fml <- stats::as.formula(sprintf(
    "log(us_aid + 1) ~ log(%s + 1) + log(gdppc_lag) + log(pop_lag) + us_ideal_diff_lag | Year + iso3c",
    lag_var
  ))
  suppressWarnings(fixest::feols(fml, data = d, vcov = ~iso3c))
}

# ---- Robustness spec: + country-specific linear trends --------------------
# Demoted to robustness by user decision (2026-09-15), NOT primary, because
# country trends can over-absorb: if Chinese finance grows smoothly within a
# country and US aid responds progressively, the trend eats the real effect.
# Reported alongside the primary spec so the reader sees the full range --
# on the restricted sample the pooled estimate moves 0.060 (p=.003) without
# trends to ~0.006 (p=.66) with them, which is the honest uncertainty here.
fit_cell_trend <- function(lag_var, strat_col, strat_val) {
  d <- if (strat_val == "Pooled") df_est else dplyr::filter(df_est, .data[[strat_col]] == !!strat_val)
  fml <- stats::as.formula(sprintf(
    "log(us_aid + 1) ~ log(%s + 1) | Year + iso3c + iso3c[Year]", lag_var
  ))
  suppressWarnings(fixest::feols(fml, data = d, vcov = ~iso3c))
}

if (has_wdi_controls) {
  region_res_ext  <- run_grid("region", REGIONS, fit_fn = fit_cell_ext)
  soi_res_ext     <- run_grid("soi_bloc_lag", SOI_BLOCS, fit_fn = fit_cell_ext)
  soi_pre_res_ext <- run_grid("soi_bloc_pre", SOI_BLOCS, fit_fn = fit_cell_ext)
  fits_ext <- c(region_res_ext$fits, soi_res_ext$fits, soi_pre_res_ext$fits)
  coef_table_ext <- dplyr::bind_rows(region_res_ext$coef_table, soi_res_ext$coef_table,
                                     soi_pre_res_ext$coef_table)
} else {
  fits_ext <- list()
  coef_table_ext <- tibble::tibble()
}

# Trends robustness runs regardless of WDI availability (no controls in it).
region_res_tr  <- run_grid("region", REGIONS, fit_fn = fit_cell_trend)
soi_res_tr     <- run_grid("soi_bloc_lag", SOI_BLOCS, fit_fn = fit_cell_trend)
soi_pre_res_tr <- run_grid("soi_bloc_pre", SOI_BLOCS, fit_fn = fit_cell_trend)
fits_trend <- c(region_res_tr$fits, soi_res_tr$fits, soi_pre_res_tr$fits)
coef_table_trend <- dplyr::bind_rows(region_res_tr$coef_table, soi_res_tr$coef_table,
                                     soi_pre_res_tr$coef_table)

# ---- Report the reproduction (Africa is the target cell) -------------------
message("\n--- Baseline elasticity, by region: coef on log(china_lag + 1) ---")
print(as.data.frame(coef_table |> filter(strat_by == "region") |>
  mutate(across(c(estimate, std.error, p.value), ~ round(.x, 3))) |> select(-strat_by)), row.names = FALSE)
africa_all <- coef_table |> filter(strat_by == "region", measure == "china_all", stratum == "Africa")
message(sprintf("\nAfrica (all official finance): %.3f (SE %.3f, p %.3f)  [prospectus target +0.113]",
                africa_all$estimate, africa_all$std.error, africa_all$p.value))

message("\n--- Baseline elasticity, by SOI bloc (alignment-based, t-1): coef on log(china_lag + 1) ---")
print(as.data.frame(coef_table |> filter(strat_by == "soi_bloc_lag") |>
  mutate(across(c(estimate, std.error, p.value), ~ round(.x, 3))) |> select(-strat_by)), row.names = FALSE)

message("\n--- Baseline elasticity, by PRE-CHINA BASELINE bloc (1990s-frozen, time-invariant) ---")
message("    (decisive test: if US-aligned survives here, it isn't aid-driven alignment)")
print(as.data.frame(coef_table |> filter(strat_by == "soi_bloc_pre") |>
  mutate(across(c(estimate, std.error, p.value), ~ round(.x, 3))) |> select(-strat_by)), row.names = FALSE)

message("\n--- Extended elasticity (+ gdppc, pop, US-alignment distance) ---")
if (nrow(coef_table_ext) > 0) {
  print(as.data.frame(coef_table_ext |>
    mutate(across(c(estimate, std.error, p.value), ~ round(.x, 3)))), row.names = FALSE)
} else {
  message("(skipped -- WDI controls unavailable)")
}

message("\n--- ROBUSTNESS: + country-specific linear trends (can over-absorb; not primary) ---")
print(as.data.frame(coef_table_trend |> filter(measure == "china_all") |>
  mutate(across(c(estimate, std.error, p.value), ~ round(.x, 3)))), row.names = FALSE)

results <- list(
  fits = fits, coef_table = coef_table,
  fits_ext = fits_ext, coef_table_ext = coef_table_ext,
  fits_trend = fits_trend, coef_table_trend = coef_table_trend,
  analysis_years = ANALYSIS_YEARS,
  measures = MEASURES
)
saveRDS(results, file.path(OUT_DIR, "results.rds"))
message(sprintf("03_analyze: saved %d baseline + %d extended fits to results.rds",
                length(fits), length(fits_ext)))
