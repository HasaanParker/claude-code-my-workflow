# =============================================================================
# 03_analyze.R — Panel VAR / long-run co-evolution (spec MUST: VAR extension).
#
# Bivariate panel VAR in (log US aid, log China aid) via system GMM
# (Blundell-Bond; Abrigo & Love 2016 "panelvar" implementation). One lag
# (annual data, T=22 max). Forward-orthogonal-deviations transformation,
# collapsed instruments (T=22 is long enough that uncollapsed GMM instrument
# counts would proliferate toward the >N-groups Roodman "too many instruments"
# problem). Two-step, Windmeijer-corrected SEs.
#
# china_all (baseline measure) only in this pass -- china_oda is a documented,
# not-yet-run extension (see README), matching the SHOULD/MAY scope split in
# the requirements spec rather than doubling GMM + bootstrap runtime here.
#
# Persists results.rds (fit, IRFs, stability) for 04/05.
# =============================================================================

suppressPackageStartupMessages({
  library(panelvar)
})

if (!exists("var_df", inherits = FALSE)) {
  stop("03_analyze.R: var_df not found. Run 00_run_all.R, not this script directly.")
}
if (!exists("OUT_DIR", inherits = FALSE)) {
  suppressPackageStartupMessages(library(here))
  OUT_DIR <- here::here("_outputs")
  dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)
}

message("03_analyze: fitting bivariate panel VAR (log_us_aid, log_china_all), system GMM...")

fit <- pvargmm(
  dependent_vars          = c("log_us_aid", "log_china_all"),
  lags                    = 1,
  transformation          = "fod",
  data                    = as.data.frame(var_df),
  panel_identifier        = c("iso3c", "Year"),
  steps                   = c("twostep"),
  system_instruments      = TRUE,
  max_instr_dependent_vars = 8,
  min_instr_dependent_vars = 2L,
  collapse                = TRUE,
  progressbar             = FALSE
)

message("\n--- Panel VAR summary ---")
print(summary(fit))

# ---- Stability ---------------------------------------------------------
stab <- tryCatch(stability(fit), error = function(e) {
  message("stability() failed: ", conditionMessage(e)); NULL
})
if (!is.null(stab)) {
  message("\n--- Stability (moduli of companion-matrix eigenvalues; all < 1 = stable) ---")
  print(stab)
}

# ---- Orthogonal IRFs + bootstrap CI -------------------------------------
N_AHEAD <- 8
irf_point <- oirf(fit, n.ahead = N_AHEAD)

N_BOOT <- 200  # kept modest for runtime; bump if the point estimates warrant tighter bands
irf_boot <- tryCatch(
  bootstrap_irf(
    fit, typeof_irf = "OIRF", n.ahead = N_AHEAD,
    nof_Nstar_draws = N_BOOT, confidence.band = 0.95, mc.cores = 1
  ),
  error = function(e) {
    message("bootstrap_irf failed: ", conditionMessage(e)); NULL
  }
)

results <- list(fit = fit, stability = stab, irf_point = irf_point, irf_boot = irf_boot,
                n_ahead = N_AHEAD, n_boot = N_BOOT)
saveRDS(results, file.path(OUT_DIR, "results_var.rds"))
message(sprintf("\n03_analyze: saved panel VAR fit + %d-step IRFs (%d bootstrap draws) to results_var.rds",
                N_AHEAD, N_BOOT))
