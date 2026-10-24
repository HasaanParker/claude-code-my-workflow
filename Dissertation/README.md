# Dissertation — *US–China Aid Competition in the 21st Century*

**Aid Races across Spheres of Influence** · Hasaan Parker · Political Science, University of Wisconsin–Madison

This is a **monograph** (single-argument book), not a 3-paper collection. The `analyses/NN_*/` folders are a working-style scaffold that maps onto the empirical chapters — they are compartmentalized R pipelines, not separate manuscripts. See [`CLAUDE.md`](../CLAUDE.md) for project conventions and the decision record in [`quality_reports/decisions/2026-06-15_monograph-drop-cases.md`](../quality_reports/decisions/2026-06-15_monograph-drop-cases.md) for why.

## Layout

```
Dissertation/
├── manuscript.tex            # top-level assembly; \include{chapters/chNN_*}
├── chapters/                 # ch01_intro → ch05_conclusion (stubs; fill over time)
├── analyses/                 # compartmentalized R work, one dir per empirical piece
│   ├── 01_quant_main/        # Ch 4 core: short-run allocation models by region
│   ├── 02_h2_private_goods/  # H2: NGO vs government delivery (stub)
│   ├── 03_iv_robustness/     # steel × exposure shift-share IV (run; negative result)
│   ├── 04_var_dynamics/      # panel VAR / long-run co-evolution (run)
│   └── 05_advisor_reframe/   # predict-and-compare side deliverable (SPEC.md)
├── figures/                  # finished PDFs \includegraphics'd into chapters
├── tables/                   # .tex fragments \input into chapters
└── data/                     # raw + interim (gitignored except .gitkeep)
```

Each `analyses/NN_*/` has a `.here` sentinel, so `here::here()` inside its
`scripts/R/` resolves to that analysis root and `here("_outputs")` stays local.

## Compiling the manuscript

From inside `Dissertation/` (3-pass XeLaTeX + bibtex):

```bash
cd Dissertation
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
BIBINPUTS=..:$BIBINPUTS bibtex manuscript
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
```

During drafting, uncomment `\includeonly{chapters/ch04_quant_main}` in
`manuscript.tex` to compile a single chapter fast.

## Running an analysis

```bash
cd Dissertation/analyses/01_quant_main  && Rscript scripts/R/00_run_all.R
cd Dissertation/analyses/03_iv_robustness && Rscript scripts/R/00_run_all.R  # after 01_quant_main
cd Dissertation/analyses/04_var_dynamics  && Rscript scripts/R/00_run_all.R  # after 01_quant_main
```

`01_quant_main`, `03_iv_robustness`, and `04_var_dynamics` have full pipelines
and real data. Both `03` and `04` reuse `01_quant_main`'s cleaned panel, so run
`01_quant_main` first. `03_iv_robustness` additionally needs the Dreher et al.
(2021) replication package unzipped at `data/dreher2021_replication/`. When
starting `02` or `05`, copy `01_quant_main/scripts/R/` as the starting point.

## Status

| Chapter | File | Stage |
|---|---|---|
| 1. Introduction | `chapters/ch01_intro.tex` | stub |
| 2. Related Literature | `chapters/ch02_lit.tex` | stub |
| 3. Theory | `chapters/ch03_theory.tex` | SOI operationalization + H1 drafted with real content; H2 still placeholder |
| 4. Quantitative core | `chapters/ch04_quant_main.tex` | drafted with real results (region + SOI-bloc cuts, IV, VAR); final robustness section still placeholder |
| 5. Conclusion | `chapters/ch05_conclusion.tex` | stub |

| Analysis | Dir | Stage |
|---|---|---|
| Short-run allocation (Ch 4) | `analyses/01_quant_main/` | **run** (2026-09-14) — FE model, region- AND alignment-based-SOI-stratified, +controls; see caveats below |
| H2 private vs public goods | `analyses/02_h2_private_goods/` | not started |
| IV robustness (steel × exposure) | `analyses/03_iv_robustness/` | **run** (2026-09-15) — negative: instrument has no first stage under a predetermined share |
| Long-run dynamics (panel VAR) | `analyses/04_var_dynamics/` | **run** (2026-09-14) — system GMM, see Hansen-J caveat in its README |
| Advisor predict-and-compare reframe | `analyses/05_advisor_reframe/` | spec only (parked) |

**Open empirical questions (not yet resolved):**

- **H1's sign flip does not appear under any operationalization.** Neither
  continent nor UN-voting alignment (in either a $t-1$ or a predetermined
  pre-China form) produces a significant race in the contested middle or the
  negative coefficient "withdrawal" requires. The prospectus's Africa-only
  $+0.113$ does not reproduce; Africa is not distinguishable from zero.
- **What positive association exists is fragile.** On the primary 2000–2021
  sample the pooled elasticity is $0.053$ ($p=.007$) and concentrates among
  already-US-aligned recipients, but country-specific linear trends reduce the
  pooled estimate to $-0.002$ ($p=.900$). Whether trends over-absorb a real
  effect or correctly remove a spurious one is the central open specification
  question — it decides whether there is a finding at all.
- **The IV cannot settle it.** The Dreher et al. steel shift-share instrument
  has no first stage under a predetermined exposure share, and is itself
  approximately a country-specific trend, so it is vulnerable to the same
  confound rather than a remedy. Identification remains open.
- **The panel VAR independently finds no lagged cross-donor effect**, which is
  consistent with the low end of the range above.

Nothing was tuned to force a match (replication-protocol discipline). See the
2026-09-14 and 2026-09-15 session logs for the full record.

## Single source of truth

`manuscript.tex` (via its chapters) is authoritative. Every numeric claim must
trace back to an R pipeline under `analyses/NN/` through `\input{tables/...}`
fragments or `%% source: analyses/NN/scripts/R/03_analyze.R` comments, so
`/audit-reproducibility` can verify the paper↔code graph. `data/` holds the
raw inputs (AidData GCDF 3.0, OECD-DAC ODA commitments, Voeten ideal points,
WDI controls, and the Dreher et al. 2021 replication package) and is gitignored.
