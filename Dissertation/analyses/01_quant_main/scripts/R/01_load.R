# =============================================================================
# 01_load.R — Load raw data. No transformations, no derivations.
#
# Reads the raw inputs into R objects for 02_clean.R to pick up:
#   raw_us    — OECD DAC3A US ODA commitments (recipient x year, long)
#   raw_china — AidData GCDF 3.0 project-level Chinese development finance
#   raw_ideal — Voeten UNGA ideal points (sphere-of-influence ingredient)
#   raw_wdi   — World Bank WDI gdppc + pop controls (OPTIONAL; NULL if absent)
#
# Data live in Dissertation/data/ (shared across analyses). here() resolves to
# this analysis root via the .here sentinel, so ../../data is the data dir.
# =============================================================================

suppressPackageStartupMessages({
  library(here)
  library(readr)
  library(readxl)
})

# Data dir: analysis-root-relative, normalized so a wrong depth fails loudly.
DATA_DIR <- normalizePath(here::here("..", "..", "data"), mustWork = TRUE)

us_path    <- file.path(DATA_DIR, "us_oda_commits_70_22.csv")
china_path <- file.path(DATA_DIR, "chinadevefinance_3_0.xlsx")
ideal_path <- file.path(DATA_DIR, "IdealpointestimatesAll_Sep2023.csv")  # Voeten UNGA
wdi_path   <- file.path(DATA_DIR, "wdi_controls.rds")                    # optional
stopifnot(file.exists(us_path), file.exists(china_path), file.exists(ideal_path))

# US ODA commitments (OECD DAC3A export). guess_max high so the mixed
# coded/labelled columns type correctly.
raw_us <- readr::read_csv(us_path, show_col_types = FALSE, guess_max = 50000)

# China GCDF 3.0 — project-level records live on the "GCDF_3.0" sheet.
raw_china <- readxl::read_excel(china_path, sheet = "GCDF_3.0", guess_max = 100000)

# Voeten UN General Assembly ideal points (Sep 2023 release) — the sphere-of-
# influence / alignment source. One row per country-session.
raw_ideal <- readr::read_csv(ideal_path, show_col_types = FALSE, guess_max = 50000)

# WDI controls (gdppc, pop) — pre-fetched by fetch_wdi.R since WDI() hits the
# network and would break reproducibility/determinism if called here. Optional:
# proceed without controls (with a warning) if the cache hasn't been built yet.
raw_wdi <- if (file.exists(wdi_path)) {
  readRDS(wdi_path)
} else {
  warning("01_load: wdi_controls.rds not found — run scripts/R/fetch_wdi.R. ",
          "Proceeding without gdppc/pop controls.")
  NULL
}

message(sprintf(
  "01_load: raw_us %d x %d, raw_china %d x %d, raw_ideal %d x %d, raw_wdi %s",
  nrow(raw_us), ncol(raw_us), nrow(raw_china), ncol(raw_china),
  nrow(raw_ideal), ncol(raw_ideal),
  if (is.null(raw_wdi)) "NULL" else sprintf("%d x %d", nrow(raw_wdi), ncol(raw_wdi))
))
