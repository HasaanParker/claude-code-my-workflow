# =============================================================================
# 00_run_all.R — Orchestrator. Run this, not the individual scripts.
#
# Same reproducibility contract as the sibling analyses (fixed seed, here()-
# relative paths, sessionInfo capture, outputs listed).
#
# CROSS-ANALYSIS DEPENDENCY: 01_quant_main must have been run at least once
# (this reuses its harmonized panel.rds rather than re-deriving the panel).
# =============================================================================

suppressPackageStartupMessages({
  if (!requireNamespace("here", quietly = TRUE)) {
    stop("Install 'here' first: install.packages('here')")
  }
  library(here)
})

PROJECT_SEED <- 20260615L   # dissertation-wide seed (INV-9)
set.seed(PROJECT_SEED)

OUT_DIR <- here("_outputs")
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

pipeline_env <- new.env(parent = globalenv())
pipeline_env$PROJECT_SEED <- PROJECT_SEED
pipeline_env$OUT_DIR      <- OUT_DIR

pipeline <- c("01_load.R", "02_clean.R", "03_analyze.R", "04_tables.R", "05_figures.R")

message("Running reproducibility pipeline with seed ", PROJECT_SEED, "...")

timings <- vapply(pipeline, function(script) {
  path <- here("scripts", "R", script)
  if (!file.exists(path)) stop("Missing pipeline script: ", path)
  start <- Sys.time()
  source(path, local = pipeline_env)
  elapsed <- as.numeric(Sys.time() - start, units = "secs")
  message(sprintf("  %s -> %.2fs", script, elapsed))
  elapsed
}, numeric(1))

writeLines(capture.output(sessionInfo()), con = file.path(OUT_DIR, "sessionInfo.txt"))

outputs <- list.files(OUT_DIR, full.names = FALSE)
message("")
message("Pipeline complete. Total time: ", sprintf("%.2fs", sum(timings)))
message("Outputs in ", OUT_DIR, ":")
for (f in outputs) message("  - ", f)

invisible(list(timings = timings, outputs = outputs))
