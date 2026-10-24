# =============================================================================
# 04_tables.R — Regression tables -> LaTeX fragments.
#
# Reads results.rds from 03_analyze.R (coef_table = baseline, coef_table_ext =
# + controls; both stacked across two stratifying cuts via strat_by: "region"
# = continent, "soi_bloc_lag" = the 2026-09-14 alignment-based re-operational-
# ization). Writes FOUR stratum x measure grids: the coefficient on
# log(china_*_lag + 1), stars from p-value, SE in parens, country-clustered.
# ch04_quant_main.tex \input{}s all four under \input{tables/...} markers.
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(here) })

# Dissertation-level tables/ -- committed, \input{}'d by chapters/ch04_quant_main.tex.
# _outputs/ stays the gitignored pipeline-contract copy (audit-reproducibility,
# re-run diffing). Both are written; tables/ is the one the manuscript reads.
TABLES_DIR <- here("..", "..", "tables")
dir.create(TABLES_DIR, showWarnings = FALSE, recursive = TRUE)

results_path <- file.path(OUT_DIR, "results.rds")
if (!file.exists(results_path)) {
  stop("04_tables.R: ", results_path, " missing. Run 00_run_all.R first.")
}
results <- readRDS(results_path)

stars <- function(p) dplyr::case_when(p < 0.01 ~ "***", p < 0.05 ~ "**", p < 0.10 ~ "*", TRUE ~ "")

# Stratum x measure grid -> LaTeX tabular. One row per stratum level, one
# 2-col block (china_all, china_oda) per measure; each cell is
# estimate(stars) / (SE) / N. `strata` fixes row order (esp. for soi_bloc_lag,
# where "China-aligned -> Contested -> US-aligned" carries theoretical meaning
# and shouldn't be alphabetized).
grid_to_tex <- function(coef_table, strat_by_val, strata, row_label, caption, label) {
  ct <- dplyr::filter(coef_table, strat_by == strat_by_val)

  cell <- function(s, m) {
    row <- dplyr::filter(ct, stratum == s, measure == m)
    if (nrow(row) == 0 || is.na(row$estimate)) return(c("--", "", ""))
    c(
      sprintf("%.3f%s", row$estimate, stars(row$p.value)),
      sprintf("(%.3f)", row$std.error),
      sprintf("[N=%d, %d ctry]", row$n_obs, row$n_countries)
    )
  }

  body <- unlist(lapply(strata, function(s) {
    ca <- cell(s, "china_all"); co <- cell(s, "china_oda")
    c(
      sprintf("%s & %s & %s \\\\", s, ca[1], co[1]),
      sprintf(" & %s & %s \\\\", ca[2], co[2]),
      sprintf(" & %s & %s \\\\[2pt]", ca[3], co[3])
    )
  }))

  c(
    "\\begin{table}[htbp]",
    "\\centering",
    sprintf("\\caption{%s}", caption),
    sprintf("\\label{%s}", label),
    "\\begin{tabular}{lcc}",
    "\\toprule",
    sprintf("%s & China (all official finance) & China (ODA-like only) \\\\", row_label),
    "\\midrule",
    body,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{minipage}{0.9\\textwidth}",
    "\\vspace{4pt}",
    "\\footnotesize Coefficient on log(lagged China finance + 1) from",
    "log(US ODA + 1) $\\sim$ log(China finance$_{t-1}$ + 1) with year and",
    "country fixed effects; SEs clustered by country. * p<0.10, ** p<0.05, *** p<0.01.",
    "\\end{minipage}",
    "\\end{table}"
  )
}

REGIONS   <- c("Pooled", "Africa", "Americas", "Asia", "Europe", "Oceania")
# Duplicated in 03_analyze.R and 05_figures.R -- order is semantically
# meaningful (China-aligned -> Contested -> US-aligned); keep all three in sync.
SOI_BLOCS <- c("Pooled", "China-aligned", "Contested", "US-aligned")

write_table <- function(tex, filename) {
  writeLines(tex, con = file.path(OUT_DIR, filename))
  writeLines(tex, con = file.path(TABLES_DIR, filename))
  message("Wrote ", file.path(OUT_DIR, filename), " (+ Dissertation/tables/", filename, ")")
}

write_table(
  grid_to_tex(results$coef_table, "region", REGIONS, "Region",
              "Short-run US aid response to lagged Chinese finance, by region", "tab:main"),
  "table_main.tex"
)

write_table(
  grid_to_tex(results$coef_table, "soi_bloc_lag", SOI_BLOCS, "SOI bloc (t-1)",
              "Short-run US aid response to lagged Chinese finance, by alignment-based sphere-of-influence bloc",
              "tab:soi"),
  "table_soi.tex"
)

write_table(
  grid_to_tex(results$coef_table_trend, "soi_bloc_pre", SOI_BLOCS, "SOI bloc (1990s-frozen)",
              "Robustness: adding country-specific linear trends (pre-China baseline blocs)",
              "tab:soi-trends"),
  "table_soi_trends.tex"
)

if (nrow(results$coef_table_ext) > 0) {
  write_table(
    grid_to_tex(results$coef_table_ext, "region", REGIONS, "Region",
                "Robustness: adding GDP per capita, population, and US-alignment distance (by region)",
                "tab:controls"),
    "table_controls.tex"
  )
  write_table(
    grid_to_tex(results$coef_table_ext, "soi_bloc_lag", SOI_BLOCS, "SOI bloc (t-1)",
                "Robustness: adding GDP per capita, population, and US-alignment distance (by SOI bloc)",
                "tab:soi-controls"),
    "table_soi_controls.tex"
  )
}
