# =============================================================================
# 03_analyze.R — 2SLS: instrument Chinese finance with steel x predetermined exposure.
#
#   2nd stage: log(us_aid+1) ~ log(china_all_lag+1) | Year + iso3c
#   1st stage: log(china_all_lag+1) ~ iv_steel   [= ln(steel_{t-1}) * cn_exposure_i]
#
# OLS on the SAME 2000-2015 window is refit alongside, so the OLS-vs-IV
# contrast isn't confounded by the shorter steel-bounded sample.
#
# KNOWN STRUCTURAL LIMITATION (state it, don't bury it). Chinese crude steel
# production rises near-monotonically over 2000-2014 (128,500 -> 822,698 kt),
# so ln(steel)_t is essentially a smooth trend. Year FE absorb its level, which
# means ALL identifying variation is cn_exposure_i x (a trend) -- i.e. the
# instrument is approximately a country-specific linear trend. Consequences:
#   (a) it cannot be combined with country-specific trends (collinear), and
#   (b) it therefore does NOT address the differential-trending fragility that
#       erased 01_quant_main's OLS result. It addresses a DIFFERENT threat:
#       selection in where China places finance. Both caveats belong in any
#       write-up of these estimates.
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(fixest)
  library(broom)
})

if (!exists("df_iv", inherits = FALSE)) {
  stop("03_analyze.R: df_iv not found. Run 00_run_all.R, not this script directly.")
}
if (!exists("OUT_DIR", inherits = FALSE)) {
  suppressPackageStartupMessages(library(here))
  OUT_DIR <- here::here("_outputs"); dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)
}

MEASURES <- c(china_all = "china_all_lag", china_oda = "china_oda_lag")

# Countries with zero pre-2000 exposure contribute a constant-zero instrument,
# so they carry no first-stage identifying variation. Report both samples: the
# full one (their FEs still help) and the positive-exposure one.
df_pos <- dplyr::filter(df_iv, cn_exposure > 0)

fit_ols <- function(d, lag_var) {
  suppressWarnings(fixest::feols(
    stats::as.formula(sprintf("log(us_aid + 1) ~ log(%s + 1) | Year + iso3c", lag_var)),
    data = d, vcov = ~iso3c))
}
# Clustered first-stage F. (Just-identified, single instrument, so this is the
# first-stage F on the excluded instrument -- not literally the Kleibergen-Paap
# rk statistic, which coincides only in special cases.) NA-safe across fixest versions.
first_stage_F <- function(fit) {
  tryCatch({
    fs <- fitstat(fit, "ivf", simplify = TRUE)
    as.numeric(fs$stat)
  }, error = function(e) NA_real_)
}

fit_iv_var <- function(d, lag_var, instr) {
  suppressWarnings(fixest::feols(
    stats::as.formula(sprintf("log(us_aid + 1) ~ 1 | Year + iso3c | log(%s + 1) ~ %s",
                              lag_var, instr)),
    data = d, vcov = ~iso3c))
}
fit_first <- function(d, lag_var, instr) {
  suppressWarnings(fixest::feols(
    stats::as.formula(sprintf("log(%s + 1) ~ %s | Year + iso3c", lag_var, instr)),
    data = d, vcov = ~iso3c))
}

INSTRUMENTS <- c(
  "predetermined (1970-99 Bartke share)" = "iv_steel",
  "contemporaneous (2000-15 share)"      = "iv_steel_contemp"
)

rows <- list()
fits <- list()
for (mname in names(MEASURES)) {
  lag_var <- MEASURES[[mname]]
  o <- fit_ols(df_iv, lag_var)
  fits[[paste(mname, "ols", sep = ":")]] <- o
  to <- broom::tidy(o)
  for (iname in names(INSTRUMENTS)) {
    instr <- INSTRUMENTS[[iname]]
    iv <- fit_iv_var(df_iv, lag_var, instr)
    fs <- fit_first(df_iv, lag_var, instr)
    fits[[paste(mname, instr, "iv", sep = ":")]] <- iv
    fits[[paste(mname, instr, "first", sep = ":")]] <- fs
    ti <- broom::tidy(iv); tf <- broom::tidy(fs)
    rows[[paste(mname, instr)]] <- tibble::tibble(
      measure = mname, instrument = iname,
      ols_est = to$estimate[1], ols_p = to$p.value[1],
      first_stage_coef = tf$estimate[1], first_stage_t = tf$statistic[1],
      first_stage_F = first_stage_F(iv),
      iv_est = ti$estimate[1], iv_se = ti$std.error[1], iv_p = ti$p.value[1],
      n_obs = iv$nobs
    )
  }
}
iv_table <- dplyr::bind_rows(rows)

message("\n--- OLS vs 2SLS by share definition, 2000-2015 (steel-bounded window) ---")
print(as.data.frame(iv_table |>
  mutate(across(where(is.numeric), ~ round(.x, 3)))), row.names = FALSE)
message("\nNOTE: the contemporaneous share is built from the same post-2000 Chinese-finance")
message("variation the instrument is meant to purge -- its first-stage power is circular,")
message("not evidence the design works. The predetermined share is the valid one, and it")
message("has no first stage. See this analysis's README.")

# ---- Why the predetermined share fails: it is absorbed by country FE ------
cross_sec <- df_iv |>
  summarise(mean_ln_china = mean(log(china_all + 1)),
            ever_china = as.integer(any(china_all > 0)),
            cn_exposure = dplyr::first(cn_exposure), .by = iso3c)
cs_lm <- stats::lm(mean_ln_china ~ cn_exposure, data = cross_sec)
message(sprintf(
  "\nCross-sectionally the share DOES predict Chinese finance (r=%.3f, p=%.2g) -- but it is\ntime-invariant, so country FE absorb it entirely. %0.f%% of countries with NO pre-2000\nChinese history still received finance post-2000, so the expansion was broad-based\nrather than proportional to historical ties: no differential growth, no first stage.",
  stats::cor(cross_sec$cn_exposure, cross_sec$mean_ln_china),
  summary(cs_lm)$coefficients[2, 4],
  100 * mean(cross_sec$ever_china[cross_sec$cn_exposure == 0])
))

results_iv <- list(iv_table = iv_table, fits = fits, cross_sec = cross_sec,
                   iv_years = range(df_iv$Year))
saveRDS(results_iv, file.path(OUT_DIR, "results_iv.rds"))
message(sprintf("\n03_analyze: saved %d fits to results_iv.rds", length(fits)))
