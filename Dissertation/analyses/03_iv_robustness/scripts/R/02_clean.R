# =============================================================================
# 02_clean.R — Build the Dreher et al. shift-share instrument.
#
# Their construction (Analysis do file.do, lines ~6082-6086):
#   gen steel_1_ln          = ln(chinese_steel)                  // the SHIFT
#   gen probaid_PRC_OFn_all = (yrs recipient got a CN project)/15 // the SHARE
#   gen steel_OFn_all_1_ln  = steel_1_ln * probaid_PRC_OFn_all    // the INSTRUMENT
#
# ONE DELIBERATE DEPARTURE. Their headline share is computed over 2000-2014 --
# the same window as the outcome, so it is NOT predetermined, which is the
# standard shift-share critique. They also build a historical alternative
# (`prob_PRCaid_2000`, share of years 1970-1999, from Bartke) and use it in
# their "historic probabilities" robustness. We take the HISTORICAL one as
# primary: our estimation window is 2000-2015, so a 1970-1999 share is fully
# predetermined relative to every flow we test. This is the same reasoning
# that motivated 01_quant_main's pre-China baseline bloc.
#
# WINDOW. The WSA steel series ends in 2015, so the IV sample is 2000-2015 --
# six years shorter than 01_quant_main's 2000-2021 primary window. Estimates
# here are therefore NOT directly comparable to that chapter's OLS on sample
# size alone; 03_analyze.R refits OLS on this same window for a fair contrast.
#
# Produces: df_iv for 03_analyze.R.
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
})

for (obj in c("raw_panel", "raw_steel", "raw_bartke")) {
  if (!exists(obj, inherits = FALSE)) {
    stop("02_clean.R: ", obj, " not found. Run 00_run_all.R, not this script directly.")
  }
}

IV_YEARS       <- 2000:2015   # bounded by the WSA steel series
PRE_YEARS      <- 1970:1999   # predetermined share window (Bartke coverage)
N_PRE_YEARS    <- length(PRE_YEARS)

# ---- The SHIFT: log Chinese crude steel production -------------------------
steel <- raw_steel |>
  transmute(Year = as.integer(Year), chinese_steel = as.numeric(Chinese_steel)) |>
  filter(!is.na(chinese_steel)) |>
  mutate(ln_steel = log(chinese_steel))
stopifnot("steel series must be unique by Year" = !anyDuplicated(steel$Year))

# ---- The SHARE: predetermined 1970-1999 Chinese-aid exposure --------------
# "Did recipient i receive Chinese aid in year t?" summed over 1970-1999 and
# divided by the 30-year window, reproducing Dreher et al.'s prob_PRCaid_2000
# (Analysis do file.do:5030-5047).
#
# THE CASCADE. Their indicator is not a single variable: it falls through
# four sources in order, taking the next whenever the current one is missing
# OR zero --
#   test = bartke_amount_con -> cia_amount_con -> fais_total -> oecd_con
#          -> nbproject_womed
# then flags test > 0. Using nbproject_womed alone (an earlier version of this
# script) under-counts badly: 508 flagged country-years vs 796 under the full
# cascade. Aid delivered but not recorded as discrete "projects" was being
# dropped.
#
# LEGACY ISO3 CODES. Bartke uses pre-dissolution codes that do not match the
# modern panel. Dreher's do-file applies these recodes (lines 4999-5005) in
# its *other* Bartke extract but NOT in the prob_PRCaid_2000 block -- we apply
# them here regardless, because without them DR Congo (ZAR), Serbia (SCG),
# Palestine (WBG) and Timor-Leste (TMP) silently fail to join and are
# indistinguishable from genuine zero-history countries.
#
# Recipients absent from Bartke get share = 0, matching their explicit
# `replace prob_PRCaid_2000 = 0 if ==.`. `in_bartke` is carried alongside so a
# true zero can be told apart from a failed match in diagnostics.
ISO3_RECODE <- c(ZAR = "COD", YUG = "SRB", SCG = "SRB", ROM = "ROU",
                 ADO = "AND", WBG = "PSE", TMP = "TLS")

bartke_share <- raw_bartke |>
  filter(donorcode == "CHN", year %in% PRE_YEARS) |>
  mutate(
    iso3c = as.character(recipientcode),
    iso3c = dplyr::coalesce(ISO3_RECODE[iso3c], iso3c),
    aid_measure = bartke_amount_con,
    aid_measure = dplyr::if_else(is.na(aid_measure) | aid_measure == 0, cia_amount_con, aid_measure),
    aid_measure = dplyr::if_else(is.na(aid_measure) | aid_measure == 0, fais_total, aid_measure),
    aid_measure = dplyr::if_else(is.na(aid_measure) | aid_measure == 0, oecd_con, aid_measure),
    aid_measure = dplyr::if_else(is.na(aid_measure) | aid_measure == 0, nbproject_womed, aid_measure),
    aid_measure = tidyr::replace_na(aid_measure, 0),
    got_aid = as.integer(aid_measure > 0)
  ) |>
  summarise(n_years_with_aid = sum(got_aid), .by = iso3c) |>
  mutate(cn_exposure = n_years_with_aid / N_PRE_YEARS, in_bartke = TRUE)

# ---- Assemble ---------------------------------------------------------------
df_iv <- raw_panel |>
  filter(Year %in% IV_YEARS) |>
  left_join(bartke_share, by = "iso3c") |>
  mutate(cn_exposure = tidyr::replace_na(cn_exposure, 0),
         in_bartke   = tidyr::replace_na(in_bartke, FALSE)) |>
  left_join(steel, by = "Year") |>
  arrange(iso3c, Year) |>
  group_by(iso3c) |>
  mutate(
    ln_steel_lag = dplyr::lag(ln_steel, order_by = Year),
    # Dreher et al.'s HEADLINE share: proportion of STUDY-WINDOW years the
    # recipient had a Chinese project. Built here only as a diagnostic
    # contrast -- it is computed from the same post-2000 Chinese-finance
    # variation the instrument is supposed to purge, so it is circular for
    # our purposes. 03_analyze.R runs both and reports the difference.
    cn_exposure_contemp = sum(china_all > 0) / dplyr::n()
  ) |>
  ungroup() |>
  # Instruments, timed to match the endogenous regressor: the treatment in
  # 01_quant_main is china_*_lag (t-1), so the shift is also taken at t-1.
  mutate(
    iv_steel         = ln_steel_lag * cn_exposure,          # predetermined share (primary)
    iv_steel_contemp = ln_steel_lag * cn_exposure_contemp   # contemporaneous share (diagnostic)
  )

message(sprintf(
  "02_clean: df_iv %d rows, %d countries, %d..%d",
  nrow(df_iv), dplyr::n_distinct(df_iv$iso3c), min(df_iv$Year), max(df_iv$Year)
))
message(sprintf(
  "02_clean: exposure share -- mean %.3f, median %.3f, %d of %d countries with zero pre-2000 history",
  mean(df_iv$cn_exposure), median(df_iv$cn_exposure),
  dplyr::n_distinct(df_iv$iso3c[df_iv$cn_exposure == 0]), dplyr::n_distinct(df_iv$iso3c)
))
# Distinguish a genuine zero from a failed Bartke join (the failure mode the
# ISO3 recodes above exist to prevent).
message(sprintf(
  "02_clean: %d countries matched Bartke; %d unmatched (treated as zero exposure)",
  dplyr::n_distinct(df_iv$iso3c[df_iv$in_bartke]),
  dplyr::n_distinct(df_iv$iso3c[!df_iv$in_bartke])
))
