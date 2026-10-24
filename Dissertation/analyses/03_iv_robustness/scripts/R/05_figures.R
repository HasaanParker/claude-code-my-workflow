# =============================================================================
# 05_figures.R — The diagnostic figure: why the predetermined share fails.
#
# Panel-free single plot: pre-2000 Chinese-aid exposure (x) against mean
# post-2000 Chinese finance (y), one point per recipient. The fitted slope is
# clearly positive -- the share genuinely predicts Chinese finance across
# countries -- which is exactly the point: that predictive content is
# CROSS-SECTIONAL, and country fixed effects absorb all of it, leaving the
# instrument with nothing to identify from.
# =============================================================================

if (!exists("OUT_DIR", inherits = FALSE)) {
  stop("05_figures.R: OUT_DIR missing. Run 00_run_all.R (not this script directly).")
}
if (exists("PROJECT_SEED", inherits = FALSE)) set.seed(PROJECT_SEED)

suppressPackageStartupMessages({ library(here); library(ggplot2); library(dplyr) })

FIGURES_DIR <- here("..", "..", "figures")
dir.create(FIGURES_DIR, showWarnings = FALSE, recursive = TRUE)

results_path <- file.path(OUT_DIR, "results_iv.rds")
if (!file.exists(results_path)) stop("05_figures.R: ", results_path, " missing.")
results <- readRDS(results_path)

# Palette/theme kept in sync with 01_quant_main/scripts/R/05_figures.R
PAL <- list(primary_blue = "#012169", primary_gold = "#B9975B", jet = "#1A1A1A",
           light_bg = "#E8EDF5", neutral = "#525252")
theme_dissertation <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(text = element_text(color = PAL$jet),
          plot.title = element_text(color = PAL$primary_blue, face = "bold"),
          plot.subtitle = element_text(color = PAL$neutral),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_line(color = PAL$light_bg),
          legend.position = "none",
          plot.background = element_rect(fill = "transparent", color = NA),
          panel.background = element_rect(fill = "transparent", color = NA))
}

p <- ggplot(results$cross_sec, aes(cn_exposure, mean_ln_china)) +
  geom_point(color = PAL$primary_blue, alpha = 0.6, size = 1.8) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE,
              color = PAL$primary_gold, fill = PAL$light_bg, linewidth = 0.8) +
  labs(
    # Plain ASCII punctuation: the base pdf() device (cairo unavailable on this
    # machine) substitutes a '-' for U+2014 and warns on every save.
    title = "The exposure share predicts Chinese finance, but only across countries",
    subtitle = "Country fixed effects absorb this entirely, leaving the instrument without identifying variation",
    x = "Pre-2000 exposure: share of 1970-99 years with a Chinese project",
    y = expression("Mean log(Chinese finance + 1), 2000-2015")
  ) +
  theme_dissertation()

cairo_ok <- tryCatch({
  tmp <- tempfile(fileext = ".pdf"); grDevices::cairo_pdf(tmp); grDevices::dev.off()
  file.exists(tmp) && file.info(tmp)$size > 0
}, error = function(e) FALSE, warning = function(w) FALSE)

out <- file.path(OUT_DIR, "fig_iv_first_stage.pdf")
ggsave(out, p, width = 7, height = 4.5,
      device = if (cairo_ok) grDevices::cairo_pdf else grDevices::pdf, bg = "transparent")
file.copy(out, file.path(FIGURES_DIR, "fig_iv_first_stage.pdf"), overwrite = TRUE)
message("Wrote ", out, " (+ Dissertation/figures/fig_iv_first_stage.pdf)",
        if (!cairo_ok) " [base pdf device, cairo unavailable]" else "")
