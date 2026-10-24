# =============================================================================
# fetch_wdi.R — Standalone (NOT part of 00_run_all.R). Fetches World Bank WDI
# controls once and caches them to Dissertation/data/wdi_controls.rds so the
# deterministic pipeline (02_clean.R) reads a local file and never blocks on the
# network. Re-run only to refresh the controls.
#
#   Rscript scripts/R/fetch_wdi.R      # run from analyses/01_quant_main/
# =============================================================================

suppressPackageStartupMessages({ library(here); library(WDI); library(dplyr) })

DATA_DIR <- normalizePath(here::here("..", "..", "data"), mustWork = TRUE)
out <- file.path(DATA_DIR, "wdi_controls.rds")

message("Fetching WDI gdppc + pop (this needs internet; may take a minute)...")
wdi <- WDI(
  country   = "all",
  indicator = c(gdppc = "NY.GDP.PCAP.KD", pop = "SP.POP.TOTL"),
  start = 1970, end = 2022
) |>
  transmute(iso3c = iso3c, Year = year, gdppc, pop) |>
  filter(!is.na(iso3c))

saveRDS(wdi, out)
message(sprintf("fetch_wdi: cached %d rows to %s", nrow(wdi), out))
