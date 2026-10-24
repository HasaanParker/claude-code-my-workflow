# =============================================================================
# 05_figures.R — Figures -> PDF (vector, for \includegraphics in manuscript.tex).
#
# Defines theme_dissertation(): the project's ggplot2 theme, matched to the
# palette in Preambles/header.tex (INV-1 palette-sync intent, applied to R
# figures rather than Beamer/Quarto). This is the FIRST figure built for the
# dissertation (per CLAUDE.md's deferred-customization list) — the theme lives
# here and any later analysis (02-05) should reuse it rather than reinventing one.
# =============================================================================

if (!exists("OUT_DIR", inherits = FALSE)) {
  stop("05_figures.R: OUT_DIR missing. Run 00_run_all.R (not this script directly).")
}
if (exists("PROJECT_SEED", inherits = FALSE)) set.seed(PROJECT_SEED)  # no RNG here, kept for contract parity

suppressPackageStartupMessages(library(here))
# Dissertation-level figures/ -- committed, \includegraphics'd by ch04. _outputs/
# stays the gitignored pipeline-contract copy (see 04_tables.R for the same split).
FIGURES_DIR <- here("..", "..", "figures")
dir.create(FIGURES_DIR, showWarnings = FALSE, recursive = TRUE)

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop(
    "05_figures.R: 'ggplot2' is required for figure generation and is not installed.\n",
    "Install with: install.packages('ggplot2')\n",
    "The pipeline will not silently fall back to base-R plots."
  )
}
library(ggplot2)

results_path <- file.path(OUT_DIR, "results.rds")
if (!file.exists(results_path)) {
  stop("05_figures.R: ", results_path, " missing. Run 00_run_all.R first.")
}
results <- readRDS(results_path)

# ---- Project theme (palette from Preambles/header.tex) --------------------
PAL <- list(
  primary_blue = "#012169", primary_gold = "#B9975B", highlight_yellow = "#F2A900",
  light_bg = "#E8EDF5", jet = "#1A1A1A",
  positive = "#15803D", negative = "#B91C1C", neutral = "#525252"
)

theme_dissertation <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      text             = element_text(color = PAL$jet),
      plot.title       = element_text(color = PAL$primary_blue, face = "bold"),
      axis.title       = element_text(color = PAL$jet),
      axis.text        = element_text(color = PAL$jet),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = PAL$light_bg),
      strip.text       = element_text(color = PAL$primary_blue, face = "bold"),
      strip.background = element_rect(fill = PAL$light_bg, color = NA),
      legend.position  = "bottom",
      legend.title     = element_blank(),
      plot.background  = element_rect(fill = "transparent", color = NA),
      panel.background = element_rect(fill = "transparent", color = NA)
    )
}

# ---- Fig: baseline short-run elasticity, by region and by SOI bloc --------
Z975 <- stats::qnorm(0.975)

# capabilities("cairo") can misreport TRUE after an R version upgrade whose
# X11/cairo shared libs (e.g. XQuartz) didn't come along — the flag is baked
# into the R build, not checked against the runtime linker. So probe by
# actually opening the device, not by trusting the capability flag.
cairo_pdf_works <- tryCatch({
  tmp <- tempfile(fileext = ".pdf")
  grDevices::cairo_pdf(tmp); grDevices::dev.off()
  file.exists(tmp) && file.info(tmp)$size > 0
}, error = function(e) FALSE, warning = function(w) FALSE)

# One coefficient-by-stratum plot, parameterized on strat_by/level order/title,
# so the region and soi_bloc_lag cuts render identically apart from those.
make_and_save_coef_plot <- function(strat_by_val, strat_levels, title, filename) {
  plot_data <- results$coef_table |>
    dplyr::filter(strat_by == strat_by_val) |>
    dplyr::mutate(
      stratum = factor(stratum, levels = strat_levels),
      measure = dplyr::recode(measure, china_all = "All official finance", china_oda = "ODA-like only"),
      conf.low  = estimate - Z975 * std.error,
      conf.high = estimate + Z975 * std.error
    )

  p <- ggplot(plot_data, aes(x = stratum, y = estimate, color = measure)) +
    geom_hline(yintercept = 0, color = PAL$neutral, linetype = "dashed") +
    geom_pointrange(aes(ymin = conf.low, ymax = conf.high),
                    position = position_dodge(width = 0.5), size = 0.5) +
    scale_color_manual(values = c("All official finance" = PAL$primary_blue,
                                  "ODA-like only" = PAL$primary_gold)) +
    labs(title = title, x = NULL, y = expression(hat(beta)~"on log(China finance"[t-1]*" + 1)")) +
    theme_dissertation()

  out_path <- file.path(OUT_DIR, filename)
  ggsave(out_path, p, width = 7, height = 4.5,
        device = if (cairo_pdf_works) grDevices::cairo_pdf else grDevices::pdf,
        bg = "transparent")
  file.copy(out_path, file.path(FIGURES_DIR, filename), overwrite = TRUE)
  message("Wrote ", out_path, " (+ Dissertation/figures/", filename, ")",
          if (!cairo_pdf_works) " [base pdf device, cairo unavailable]" else "")
}
if (!cairo_pdf_works) {
  warning("05_figures.R: cairo_pdf unavailable at runtime (X11/XQuartz libs missing) ",
          "-- figures written with the base pdf() device instead. ",
          "Fonts/anti-aliasing will be plainer; install XQuartz to restore cairo_pdf.",
          call. = FALSE)
}

make_and_save_coef_plot(
  "region", c("Pooled", "Africa", "Americas", "Asia", "Europe", "Oceania"),
  "Short-run elasticity of US ODA to lagged Chinese finance, by region",
  "fig_coef_by_region.pdf"
)
make_and_save_coef_plot(
  # Duplicated in 03_analyze.R and 04_tables.R -- order is semantically
  # meaningful (China-aligned -> Contested -> US-aligned); keep all three in sync.
  "soi_bloc_lag", c("Pooled", "China-aligned", "Contested", "US-aligned"),
  "Short-run elasticity of US ODA to lagged Chinese finance, by SOI bloc",
  "fig_coef_by_soi.pdf"
)
