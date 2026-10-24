# =============================================================================
# 01_load.R — Load the analysis panel plus the two Dreher et al. IV ingredients.
#
#   raw_panel — 01_quant_main's harmonized panel (must be run first)
#   raw_steel — Chinese crude steel production, WSA 1990-2015 (the SHIFT)
#   raw_bartke— Bartke historical Chinese aid, 1951-1999 (the SHARE's source)
#
# Both IV ingredients come from the Dreher, Fuchs, Parks, Strange & Tierney
# (AEJ:EP 2021) replication package, openICPSR-118648, unzipped under
# Dissertation/data/dreher2021_replication/. We use their raw inputs and
# rebuild the instrument ourselves (see 02_clean.R) rather than lifting their
# constructed variables, because our share is the PREDETERMINED 1970-1999 one
# and our estimation window differs from theirs.
# =============================================================================

suppressPackageStartupMessages({
  library(here)
  library(readr)
  library(haven)
})

panel_path <- normalizePath(here::here("..", "01_quant_main", "_outputs", "panel.rds"),
                            mustWork = FALSE)
if (!file.exists(panel_path)) {
  stop("01_load.R: ", panel_path, " not found.\n",
       "Run Dissertation/analyses/01_quant_main/scripts/R/00_run_all.R first ",
       "-- 03_iv_robustness reuses its harmonized panel.")
}
raw_panel <- readRDS(panel_path)

DREHER_DIR <- normalizePath(
  here::here("..", "..", "data", "dreher2021_replication", "Raw-Data"),
  mustWork = FALSE
)
steel_path  <- file.path(DREHER_DIR, "WSA_1990_2015.csv")
bartke_path <- file.path(DREHER_DIR, "Bartke.dta")
if (!file.exists(steel_path) || !file.exists(bartke_path)) {
  stop("01_load.R: Dreher replication inputs not found under\n  ", DREHER_DIR,
       "\nExpected WSA_1990_2015.csv and Bartke.dta. See this analysis's README.")
}

# Chinese crude steel production, thousand metric tons. Two columns: the
# original series and the WSA-2015-report revision (which differs for
# 2005-2010). We use `Chinese_steel`, the column Dreher et al. use.
raw_steel <- readr::read_csv(steel_path, show_col_types = FALSE)

# Bartke: China -> recipient historical aid, project counts and amounts.
raw_bartke <- haven::read_dta(bartke_path)

message(sprintf("01_load: raw_panel %d x %d, raw_steel %d x %d, raw_bartke %d x %d",
                nrow(raw_panel), ncol(raw_panel), nrow(raw_steel), ncol(raw_steel),
                nrow(raw_bartke), ncol(raw_bartke)))
