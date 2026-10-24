# `analyses/04_var_dynamics/` — Long-run dynamics (panel VAR)

**Status:** first pass complete (2026-09-14). Bivariate panel VAR in
`(log us_aid, log china_all)`, system GMM (`panelvar::pvargmm`), 2000--2021,
150 countries balanced. Wired into `chapters/ch04_quant_main.tex`
("Long-run dynamics").

**Reuses `01_quant_main`'s cleaned panel** (`../01_quant_main/_outputs/panel.rds`)
rather than re-deriving the US/China harmonization — run `01_quant_main`'s
`00_run_all.R` at least once first.

**Headline finding:** neither lagged cross-donor term is significant (US-on-China
$-0.075$, $p=.56$; China-on-US $-0.013$, $p=.40$); each series is driven by its
own persistence. System is stable (eigenvalues $<1$). **Caveat:** the Hansen
overidentification test rejects ($\chi^2(28)=100.22$, $p<.001$) — read the point
estimates as suggestive, not confirmed, pending an instrument-count/validity check.

**Not yet run:** the `china_oda`-only measure (documented extension, matching
`01_quant_main`'s side-by-side-measures decision but not duplicated here to keep
GMM + bootstrap runtime bounded).
