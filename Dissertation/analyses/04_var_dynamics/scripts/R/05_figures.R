# =============================================================================
# 05_figures.R — Orthogonal IRF plot -> PDF.
#
# Reuses the same palette as 01_quant_main/scripts/R/05_figures.R's
# theme_dissertation() (kept as a small local copy rather than a shared file,
# per the fixed 5-script-per-analysis convention -- see that script for the
# canonical definition if the two ever need to be reconciled).
# =============================================================================

if (!exists("OUT_DIR", inherits = FALSE)) {
  stop("05_figures.R: OUT_DIR missing. Run 00_run_all.R (not this script directly).")
}
if (exists("PROJECT_SEED", inherits = FALSE)) set.seed(PROJECT_SEED)

suppressPackageStartupMessages({ library(here); library(ggplot2); library(dplyr) })

FIGURES_DIR <- here("..", "..", "figures")
dir.create(FIGURES_DIR, showWarnings = FALSE, recursive = TRUE)

results_path <- file.path(OUT_DIR, "results_var.rds")
if (!file.exists(results_path)) {
  stop("05_figures.R: ", results_path, " missing. Run 00_run_all.R first.")
}
results <- readRDS(results_path)

PAL <- list(primary_blue = "#012169", primary_gold = "#B9975B", jet = "#1A1A1A",
           light_bg = "#E8EDF5", neutral = "#525252")
theme_dissertation <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(text = element_text(color = PAL$jet),
          plot.title = element_text(color = PAL$primary_blue, face = "bold"),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_line(color = PAL$light_bg),
          strip.text = element_text(color = PAL$primary_blue, face = "bold"),
          strip.background = element_rect(fill = PAL$light_bg, color = NA),
          legend.position = "none",
          plot.background = element_rect(fill = "transparent", color = NA),
          panel.background = element_rect(fill = "transparent", color = NA))
}

# Reshape point + bootstrap-band IRFs into one long frame:
# response x impulse x horizon, with lower/upper (NULL-safe if bootstrap failed).
responses <- names(results$irf_point)
long_rows <- list()
for (resp in responses) {
  mat <- results$irf_point[[resp]]
  for (imp in colnames(mat)) {
    lo <- if (!is.null(results$irf_boot)) results$irf_boot$Lower[[resp]][, imp] else NA_real_
    hi <- if (!is.null(results$irf_boot)) results$irf_boot$Upper[[resp]][, imp] else NA_real_
    long_rows[[paste(resp, imp)]] <- tibble::tibble(
      horizon = seq_len(nrow(mat)), response = resp, impulse = imp,
      estimate = mat[, imp], lower = lo, upper = hi
    )
  }
}
irf_long <- dplyr::bind_rows(long_rows) |>
  mutate(
    response = dplyr::recode(response, log_us_aid = "US aid response", log_china_all = "China aid response"),
    impulse  = dplyr::recode(impulse, log_us_aid = "to a US-aid shock", log_china_all = "to a China-aid shock")
  )

p_irf <- ggplot(irf_long, aes(horizon, estimate)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = PAL$light_bg, alpha = 0.8) +
  geom_hline(yintercept = 0, color = PAL$neutral, linetype = "dashed") +
  geom_line(color = PAL$primary_blue, linewidth = 0.8) +
  facet_grid(response ~ impulse, scales = "free_y") +
  labs(title = "Orthogonal impulse responses, bivariate panel VAR (95% bootstrap CI)",
      x = "Years ahead", y = "Response") +
  theme_dissertation()

fig_irf_pdf <- file.path(OUT_DIR, "fig_irf.pdf")
cairo_pdf_works <- tryCatch({
  tmp <- tempfile(fileext = ".pdf"); grDevices::cairo_pdf(tmp); grDevices::dev.off()
  file.exists(tmp) && file.info(tmp)$size > 0
}, error = function(e) FALSE, warning = function(w) FALSE)

ggsave(fig_irf_pdf, p_irf, width = 8, height = 6,
      device = if (cairo_pdf_works) grDevices::cairo_pdf else grDevices::pdf, bg = "transparent")
file.copy(fig_irf_pdf, file.path(FIGURES_DIR, "fig_irf.pdf"), overwrite = TRUE)
message("Wrote ", fig_irf_pdf, " (+ Dissertation/figures/fig_irf.pdf)",
        if (!cairo_pdf_works) " [base pdf device, cairo unavailable]" else "")
