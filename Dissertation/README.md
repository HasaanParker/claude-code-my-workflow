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
│   ├── 03_iv_robustness/     # Dreher/Zeitz steel × exposure IV (stub)
│   ├── 04_var_dynamics/      # panel VAR / long-run co-evolution (stub)
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
cd Dissertation/analyses/01_quant_main && Rscript scripts/R/00_run_all.R
```

Only `01_quant_main` has a script skeleton so far. When starting `02`–`05`,
copy `01_quant_main/scripts/R/` as the starting point.

## Status

| Chapter | File | Stage |
|---|---|---|
| 1. Introduction | `chapters/ch01_intro.tex` | stub |
| 2. Related Literature | `chapters/ch02_lit.tex` | stub |
| 3. Theory | `chapters/ch03_theory.tex` | stub |
| 4. Quantitative core | `chapters/ch04_quant_main.tex` | stub (empirical burden) |
| 5. Conclusion | `chapters/ch05_conclusion.tex` | stub |

| Analysis | Dir | Stage |
|---|---|---|
| Short-run allocation (Ch 4) | `analyses/01_quant_main/` | script skeleton, no data |
| H2 private vs public goods | `analyses/02_h2_private_goods/` | not started |
| IV robustness (steel × exposure) | `analyses/03_iv_robustness/` | not started |
| Long-run dynamics (panel VAR) | `analyses/04_var_dynamics/` | not started |
| Advisor predict-and-compare reframe | `analyses/05_advisor_reframe/` | spec only (parked) |

## Single source of truth

`manuscript.tex` (via its chapters) is authoritative. Every numeric claim must
trace back to an R pipeline under `analyses/NN/` through `\input{tables/...}`
fragments or `%% source: analyses/NN/scripts/R/03_analyze.R` comments, so
`/audit-reproducibility` can verify the paper↔code graph. Data is not loaded
yet — `data/` is a placeholder for AidData GCDF + OECD-DAC CRS extracts.
