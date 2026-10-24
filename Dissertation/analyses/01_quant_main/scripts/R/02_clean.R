# =============================================================================
# 02_clean.R — Harmonize US + China aid into a recipient(ISO-3) x year panel.
#
# Faithful to the dissertation's working recipe (Scripts/us china aid.R):
#   - US: DAC3A ODA commitments; names -> ISO-3 via countryname() (drops
#         aggregates); OBS_VALUE (USD millions) x 1e6 -> USD.
#   - China: GCDF 3.0, Recommended For Aggregates == "Yes", summed
#            Amount (Constant USD 2021) by iso3c x year.
#   - Balanced panel 1970:2022 over the US-recipient ISO-3 universe; missing
#     aid -> 0; one-year lags.
#
# Extensions vs. the working recipe (documented so /audit-reproducibility can
# trace them):
#   - TWO China measures carried side by side (user decision 2026-08-06):
#       china_all = ALL recommended-for-aggregates flows  (baseline; matches recipe)
#       china_oda = ODA-like flows only
#   - region derived from ISO-3 via countrycode continent (stable per country),
#     rather than GCDF Recipient Region (which only exists for China-project rows).
#   - us_ideal_diff: |recipient UNGA ideal point - US ideal point| (Voeten Sep
#     2023 release), an alignment/SOI ingredient. Session->year uses the
#     corrected convention (session 1 = 1946, i.e. Year = session + 1945);
#     the working recipe used +1946 (off by one) — corrected here per the
#     2026-08-06 FYI to the user, flag if the original mapping is wanted instead.
#   - soi_bloc: re-operationalized sphere-of-influence (2026-09-14, replacing
#     continent as the H1 test cut). rel_align = china_ideal_diff - us_ideal_diff,
#     terciled WITHIN YEAR into China-aligned / Contested / US-aligned. See the
#     block below "Sphere-of-influence: alignment-based bloc" for the full
#     derivation and the theoretical mapping to H1.
#   - gdppc, pop: World Bank WDI controls, pre-fetched to a local cache by
#     fetch_wdi.R (kept out of 01_load.R's network path for determinism).
#     Optional: df carries NA gdppc/pop if the cache wasn't built.
#
# Produces: df  (the analysis-ready panel) for 03_analyze.R.
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(countrycode)
})

if (!exists("raw_us", inherits = FALSE) || !exists("raw_china", inherits = FALSE)) {
  stop("02_clean.R: raw_us / raw_china not found. Run 00_run_all.R, not this script directly.")
}
if (!exists("raw_ideal", inherits = FALSE)) {
  stop("02_clean.R: raw_ideal not found. Run 00_run_all.R, not this script directly.")
}

# Panel window is fixed here (not hardcoded downstream) so a reviewer can change
# the span in one place. 1970 is the US ODA start; GCDF begins 2000.
PANEL_YEARS <- 1970:2022

# ---- US ODA commitments ----------------------------------------------------
# countryname() maps recipient LABELS to ISO-3; aggregates ("Africa", "All
# recipients", multilateral funds) return NA and are dropped. Values are USD
# millions (constant 2022) -> convert to USD. Aggregate defensively to iso3c x
# year in case two labels map to one ISO-3 (no-op when they don't).
us_aid <- raw_us |>
  transmute(
    recipient = Recipient,
    Year      = TIME_PERIOD,
    us_aid    = OBS_VALUE * 1e6,
    iso3c     = suppressWarnings(countrycode::countryname(Recipient, "iso3c"))
  ) |>
  filter(!is.na(iso3c)) |>
  summarise(us_aid = sum(us_aid, na.rm = TRUE), .by = c(iso3c, Year))

# ---- China development finance (GCDF 3.0) ----------------------------------
# Recommended-for-aggregates rows only (AidData guidance, avoids double count).
china_proj <- raw_china |>
  filter(`Recommended For Aggregates` == "Yes") |>
  transmute(
    iso3c    = `Recipient ISO-3`,
    Year     = `Commitment Year`,
    flow     = `Flow Class`,
    proj_amt = `Amount (Constant USD 2021)`
  ) |>
  filter(!is.na(iso3c))

# Measure 1 (baseline): ALL flow classes. Measure 2: ODA-like only.
china_all <- china_proj |>
  summarise(china_all = sum(proj_amt, na.rm = TRUE), .by = c(iso3c, Year))
china_oda <- china_proj |>
  filter(flow == "ODA-like") |>
  summarise(china_oda = sum(proj_amt, na.rm = TRUE), .by = c(iso3c, Year))

# ---- Sphere-of-influence ingredient: UNGA ideal-point alignment -----------
# Session -> year: session 1 convened in 1946, so Year = session + 1945.
# One ideal point per country-year; US row supplies the reference point that
# every recipient-year is compared against.
#
# raw_ideal has 23 duplicate iso3c x Year rows (2026-09-14, caught by the
# stopifnot below): pre-unification North Yemen ("Yemen Arab Republic") and
# South Yemen ("Yemen People's Republic") both carry iso3c "YAR", 1967-1989.
# Averaging collapses this cleanly -- "YAR" never appears in our recipient
# panel anyway (countryname() maps modern and pre-unification Yemen alike to
# "YEM"), so this is a robustness fix for the general-purpose `ideal`
# construction, not something that changes any number in this analysis.
ideal <- raw_ideal |>
  transmute(iso3c, Year = session + 1945L, ideal = IdealPointAll) |>
  summarise(ideal = mean(ideal), .by = c(iso3c, Year))

us_ideal    <- ideal |> filter(iso3c == "USA") |> select(Year, us_ideal = ideal)
china_ideal <- ideal |> filter(iso3c == "CHN") |> select(Year, china_ideal = ideal)

soi <- ideal |>
  left_join(us_ideal, by = "Year") |>
  left_join(china_ideal, by = "Year") |>
  transmute(
    iso3c, Year,
    us_ideal_diff    = abs(ideal - us_ideal),
    china_ideal_diff = abs(ideal - china_ideal)
  )

# One row per iso3c x Year, or the left_join into df below fans out silently.
# Cheap to assert now; expensive to debug later if a future Voeten vintage
# ever ships a duplicate country-session row (r-reviewer, 2026-09-14).
stopifnot("soi must be unique per iso3c x Year" =
  !anyDuplicated(soi[c("iso3c", "Year")]))

# ---- Sphere-of-influence: alignment-based bloc (2026-09-14) ---------------
# H1 (Ch3) predicts a race (positive elasticity) in CONTESTED spheres and
# withdrawal (negative) where the US has effectively already lost the
# recipient to China -- a sharper, asymmetric prediction than a flat
# "positive here / negative there" split, and one continent can't express.
#
# rel_align = china_ideal_diff - us_ideal_diff:
#   large POSITIVE -> far from China, close to US   -> "US-aligned"
#   large NEGATIVE -> far from US, close to China    -> "China-aligned"
#   near ZERO      -> equidistant, genuinely contested -> "Contested"
#
# `rel_align` itself is computed here (needs raw_ideal's full UN membership,
# since a recipient's distance to the US/China ideal point doesn't depend on
# who else is in the regression sample). The TERCILE split, however, is
# deferred to the panel-assembly block below and computed ONLY among the
# ~150 US-aid-recipient countries actually in `df` -- not the full ~190-
# country UN membership -- so "US-aligned"/"Contested"/"China-aligned" mean
# "relative to other aid recipients," not "relative to Canada and the UK."
# (r-reviewer, 2026-09-14: flagged terciling against the full UN population as
# a plausible non-bug driver of the SOI-bloc finding; checked directly --
# recipient-only terciles reproduce the same pattern and if anything sharpen
# it, so this is a parsimony choice, not a finding-driven one. See session log.)
soi <- soi |>
  mutate(rel_align = china_ideal_diff - us_ideal_diff)

# ---- WDI controls -----------------------------------------------------------
# NULL-safe: if fetch_wdi.R hasn't been run, wdi_ctrl is an empty 0-row frame
# with the right columns, so the left_join below is a no-op (all NA) rather
# than an error.
wdi_ctrl <- if (exists("raw_wdi", inherits = FALSE) && !is.null(raw_wdi)) {
  raw_wdi
} else {
  tibble::tibble(iso3c = character(), Year = integer(),
                 gdppc = double(), pop = double())
}

# ---- Assemble panel --------------------------------------------------------
# ISO-3 universe = US-recipient countries (matches the recipe's US-anchored
# left join). China-only recipients with no US ODA ever are out of frame.
all_aid <- us_aid |>
  left_join(china_all, by = c("iso3c", "Year")) |>
  left_join(china_oda, by = c("iso3c", "Year"))

panel <- tidyr::expand_grid(Year = PANEL_YEARS, iso3c = unique(all_aid$iso3c))

# ---- Pre-China baseline bloc (2026-09-15) ---------------------------------
# The endogeneity problem with `soi_bloc`/`soi_bloc_lag`: UN-voting alignment
# is itself partly CAUSED by US aid, so a country is "US-aligned at t-1" partly
# because of US aid at t-2, t-3, ... and that aid relationship persists into t.
# A one-year lag does not sever that loop -- it just shifts it by a year.
#
# This variant freezes bloc assignment on the pre-China era (1990-1999: after
# the Cold War alignment space collapses, before GCDF coverage starts in 2000),
# averaged per country and terciled ONCE across countries, so the bloc is
# time-invariant and fully predetermined relative to every China-era aid flow
# being tested. If the US-aligned result survives this, it isn't an artifact of
# aid-driven alignment; if it collapses, the t-1 version was picking up
# persistence in the aid relationship rather than a response to China.
#
# Countries need >= MIN_PRE_YEARS of 1990s ideal-point coverage to be assigned;
# states that didn't exist pre-2000 (Timor-Leste, Montenegro, South Sudan, ...)
# get NA by construction -- there is no pre-China baseline to freeze for them.
PRE_CHINA_YEARS <- 1990:1999
MIN_PRE_YEARS   <- 5L

soi_pre <- soi |>
  filter(iso3c %in% unique(all_aid$iso3c),
         Year %in% PRE_CHINA_YEARS,
         !is.na(rel_align)) |>
  summarise(rel_align_pre = mean(rel_align), n_pre_years = dplyr::n(), .by = iso3c) |>
  filter(n_pre_years >= MIN_PRE_YEARS) |>
  mutate(
    soi_bloc_pre = c("China-aligned", "Contested", "US-aligned")[dplyr::ntile(rel_align_pre, 3)]
  ) |>
  select(iso3c, rel_align_pre, soi_bloc_pre)

df <- panel |>
  left_join(all_aid, by = c("Year", "iso3c")) |>
  mutate(across(c(us_aid, china_all, china_oda), ~ tidyr::replace_na(.x, 0))) |>
  left_join(soi, by = c("iso3c", "Year")) |>
  # Tercile computed WITHIN this recipient panel (not the full UN membership
  # in `soi`/`ideal` above) and WITHIN YEAR (NOMINATE-scale drift across
  # sessions). `idx` restricts ntile() to non-NA rel_align rows so missing
  # alignment data doesn't consume a bin slot or need a separate NA guard.
  mutate(
    soi_bloc = {
      out <- rep(NA_character_, dplyr::n())
      idx <- which(!is.na(rel_align))
      if (length(idx) > 0) {
        out[idx] <- c("China-aligned", "Contested", "US-aligned")[dplyr::ntile(rel_align[idx], 3)]
      }
      out
    },
    .by = Year
  ) |>
  left_join(wdi_ctrl, by = c("iso3c", "Year")) |>
  # Time-invariant, so joined by iso3c only and NOT lagged below -- it is
  # already predetermined relative to the entire China era.
  left_join(soi_pre, by = "iso3c") |>
  # Region from ISO-3 (stable per country). Africa here == continent Africa.
  # Kept alongside soi_bloc for comparison with the pre-2026-09-14 region cut.
  mutate(region = countrycode::countrycode(iso3c, "iso3c", "continent")) |>
  arrange(iso3c, Year) |>
  group_by(iso3c) |>
  mutate(
    china_all_lag     = dplyr::lag(china_all, order_by = Year),
    china_oda_lag     = dplyr::lag(china_oda, order_by = Year),
    us_aid_lag        = dplyr::lag(us_aid,    order_by = Year),
    us_ideal_diff_lag = dplyr::lag(us_ideal_diff, order_by = Year),
    gdppc_lag         = dplyr::lag(gdppc, order_by = Year),
    pop_lag           = dplyr::lag(pop,   order_by = Year),
    # Lagged like the treatment (china_*_lag): the bloc a country was in at
    # t-1, not t, so this session's aid decision isn't used to classify the
    # very bloc it's being tested against (avoids a simultaneity loop).
    rel_align_lag     = dplyr::lag(rel_align, order_by = Year),
    soi_bloc_lag      = dplyr::lag(soi_bloc,  order_by = Year)
  ) |>
  ungroup()

message(sprintf(
  "02_clean: df %d rows, %d countries, %d..%d; region NA=%d, gdppc NA=%d, us_ideal_diff NA=%d, soi_bloc_lag NA=%d",
  nrow(df), dplyr::n_distinct(df$iso3c), min(df$Year), max(df$Year),
  sum(is.na(df$region)), sum(is.na(df$gdppc)), sum(is.na(df$us_ideal_diff)),
  sum(is.na(df$soi_bloc_lag))
))
message(sprintf(
  "02_clean: pre-China baseline bloc assigned to %d of %d countries (>= %d yrs of %d-%d coverage); %d countries unassignable",
  dplyr::n_distinct(df$iso3c[!is.na(df$soi_bloc_pre)]), dplyr::n_distinct(df$iso3c),
  MIN_PRE_YEARS, min(PRE_CHINA_YEARS), max(PRE_CHINA_YEARS),
  dplyr::n_distinct(df$iso3c[is.na(df$soi_bloc_pre)])
))

# Persist the harmonized panel so sibling analyses (e.g. 04_var_dynamics) reuse
# this exact panel rather than re-deriving it and risking drift. Gitignored
# (_outputs/), so 04_var_dynamics documents that 01_quant_main must run first.
if (exists("OUT_DIR", inherits = FALSE)) {
  saveRDS(df, file.path(OUT_DIR, "panel.rds"))
}
