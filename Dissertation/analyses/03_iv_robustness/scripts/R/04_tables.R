# =============================================================================
# 04_tables.R — IV diagnostic table -> LaTeX.
#
# The deliverable here is a NEGATIVE result, so the table is built to show the
# diagnosis rather than a headline estimate: OLS alongside 2SLS under both
# share definitions, with the first-stage coefficient and F for each, so the
# reader can see that power appears only under the circular share.
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(here) })

TABLES_DIR <- here("..", "..", "tables")
dir.create(TABLES_DIR, showWarnings = FALSE, recursive = TRUE)

results_path <- file.path(OUT_DIR, "results_iv.rds")
if (!file.exists(results_path)) {
  stop("04_tables.R: ", results_path, " missing. Run 00_run_all.R first.")
}
results <- readRDS(results_path)

stars <- function(p) dplyr::case_when(is.na(p) ~ "", p < 0.01 ~ "***", p < 0.05 ~ "**",
                                      p < 0.10 ~ "*", TRUE ~ "")
fmt <- function(x, d = 3) ifelse(is.na(x), "--", sprintf(paste0("%.", d, "f"), x))

tb <- results$iv_table |> filter(measure == "china_all")

# Short row labels keep the tabular inside \textwidth; the full definitions
# live in the footnote below rather than in the stub column.
short_label <- c(
  "predetermined (1970-99 Bartke share)" = "Predetermined (1970--99)",
  "contemporaneous (2000-15 share)"      = "Contemporaneous (2000--15)"
)

body <- unlist(lapply(seq_len(nrow(tb)), function(i) {
  r <- tb[i, ]
  lbl <- short_label[[r$instrument]]
  c(
    sprintf("%s & %s & %s & %s & %s%s \\\\",
            lbl, fmt(r$first_stage_coef), fmt(r$first_stage_t, 2),
            fmt(r$first_stage_F, 2), fmt(r$iv_est), stars(r$iv_p)),
    sprintf(" & & & & (%s) \\\\[2pt]", fmt(r$iv_se))
  )
}))

ols_note <- sprintf("OLS on the same sample: $%s$%s.",
                    fmt(tb$ols_est[1]), stars(tb$ols_p[1]))

tex <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Shift-share IV for Chinese finance: first-stage diagnostics by share definition}",
  "\\label{tab:iv}",
  "\\small",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  "Exposure share & 1st-stage coef. & 1st-stage $t$ & 1st-stage $F$ & 2SLS estimate \\\\",
  "\\midrule",
  body,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.92\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize Instrument $=\\ln(\\text{Chinese crude steel production}_{t-1})\\times\\text{exposure share}_i$,",
  "following Dreher, Fuchs, Parks, Strange and Tierney (2021). Outcome is $\\log(\\text{US ODA}+1)$,",
  "endogenous regressor $\\log(\\text{Chinese official finance}_{t-1}+1)$; year and country fixed",
  "effects, SEs clustered by country. Sample 2000--2015 (bounded by the WSA steel series).",
  sprintf("%s * p<0.10, ** p<0.05, *** p<0.01.", ols_note),
  "\\textbf{Read this table as a diagnosis, not an estimate.} The predetermined share is the",
  "methodologically valid one and produces no first stage. The contemporaneous share is",
  "constructed from the same post-2000 Chinese-finance variation the instrument is meant to",
  "purge, so its first-stage power is mechanical rather than evidence the design identifies",
  "anything. Neither 2SLS column supports inference.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tex, con = file.path(OUT_DIR, "table_iv.tex"))
writeLines(tex, con = file.path(TABLES_DIR, "table_iv.tex"))
message("Wrote ", file.path(OUT_DIR, "table_iv.tex"), " (+ Dissertation/tables/table_iv.tex)")
