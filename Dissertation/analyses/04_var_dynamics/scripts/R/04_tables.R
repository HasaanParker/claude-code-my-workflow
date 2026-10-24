# =============================================================================
# 04_tables.R — Panel VAR coefficient table -> LaTeX.
#
# fit$second_step / se(fit) / pvalue(fit) share one [2 equations x 3 regressor]
# shape (lag1_log_us_aid, lag1_log_china_all, const). Reports the Hansen J
# overidentification test and the stability check alongside the coefficients --
# both are load-bearing caveats on this estimate, not footnote trivia.
# =============================================================================

suppressPackageStartupMessages(library(panelvar))
suppressPackageStartupMessages(library(here))

TABLES_DIR <- here("..", "..", "tables")
dir.create(TABLES_DIR, showWarnings = FALSE, recursive = TRUE)

results_path <- file.path(OUT_DIR, "results_var.rds")
if (!file.exists(results_path)) {
  stop("04_tables.R: ", results_path, " missing. Run 00_run_all.R first.")
}
results <- readRDS(results_path)
fit <- results$fit

coefs <- fit$second_step
ses   <- panelvar::se(fit)
dimnames(ses) <- dimnames(coefs)  # se() drops dimnames; same [equation, regressor] shape/order as second_step
pvals <- panelvar::pvalue(fit)
stars <- function(p) dplyr::case_when(p < 0.01 ~ "***", p < 0.05 ~ "**", p < 0.10 ~ "*", TRUE ~ "")

eq_label <- c(fod_log_us_aid = "US aid (log, $t$)", fod_log_china_all = "China aid (log, $t$)")
col_label <- c(fod_lag1_log_us_aid = "US aid (log, $t-1$)",
              fod_lag1_log_china_all = "China aid (log, $t-1$)",
              const = "Constant")

body <- unlist(lapply(rownames(coefs), function(eq) {
  vals <- sprintf("%.3f%s", coefs[eq, ], stars(pvals[eq, ]))
  ses_row <- sprintf("(%.3f)", ses[eq, ])
  c(
    sprintf("%s & %s \\\\", eq_label[[eq]], paste(vals, collapse = " & ")),
    sprintf(" & %s \\\\[2pt]", paste(ses_row, collapse = " & "))
  )
}))

hansen <- panelvar::hansen_j_test(fit)
stab_ok <- isTRUE(tryCatch(all(results$stability$Modulus < 1), error = function(e) NA))

tex_var <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Bivariate panel VAR: US and Chinese aid, 2000--2021 (system GMM)}",
  "\\label{tab:var}",
  sprintf("\\begin{tabular}{l%s}", paste(rep("c", ncol(coefs)), collapse = "")),
  "\\toprule",
  sprintf(" & %s \\\\", paste(col_label[colnames(coefs)], collapse = " & ")),
  "\\midrule",
  body,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.9\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize Two-step system GMM, forward-orthogonal-deviations, collapsed",
  "instruments; Windmeijer-corrected SEs in parens. * p<0.10, ** p<0.05, *** p<0.01.",
  sprintf(
    "Hansen J test of overidentifying restrictions: $\\chi^2(%d) = %.2f$, $p %s$ --",
    hansen$parameter, hansen$statistic, if (hansen$p.value < 0.001) "< 0.001" else sprintf("= %.3f", hansen$p.value)
  ),
  sprintf(
    "\\textbf{rejects} at conventional levels (%d instruments over %d groups); interpret with caution.",
    hansen$nof_instruments, fit$nof_groups
  ),
  sprintf("Stability: companion-matrix eigenvalues %s inside the unit circle.",
          if (isTRUE(stab_ok)) "all lie" else "NOT confirmed to all lie"),
  "\\end{minipage}",
  "\\end{table}"
)

var_path <- file.path(OUT_DIR, "table_var.tex")
writeLines(tex_var, con = var_path)
writeLines(tex_var, con = file.path(TABLES_DIR, "table_var.tex"))
message("Wrote ", var_path, " (+ Dissertation/tables/table_var.tex)")
