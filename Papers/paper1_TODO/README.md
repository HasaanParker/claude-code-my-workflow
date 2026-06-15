# Paper 1: *[Working title TBD]*

**Slug:** `paper1_TODO` (rename when title firms up)
**Stage:** scaffold
**Target journal:** TBD (calibrates `/review-paper --peer`)

## Question

*One-sentence research question — TBD.*

## Layout

```
paper1_TODO/
├── manuscript.tex      # the paper
├── scripts/R/          # 00_run_all.R + 01_load → 05_figures
├── _outputs/           # R intermediate .rds + sessionInfo.txt
├── figures/            # PDF figures included in manuscript
├── tables/             # LaTeX table fragments \input{} into manuscript
└── .here               # here::here() resolves to this directory
```

## Reproducing

```bash
# Analysis
cd Papers/paper1_TODO && Rscript scripts/R/00_run_all.R

# Manuscript (3-pass XeLaTeX with bibtex)
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
BIBINPUTS=../..:$BIBINPUTS bibtex manuscript
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
```

## Replication targets

*Fill once a replication baseline is established — see `.claude/rules/replication-protocol.md`.*

| Target | Table / Figure | Value | SE/CI | Notes |
|---|---|---|---|---|

## Provenance

Numeric claims are tracked in a passport (see `templates/passport-template.yaml`). Create `quality_reports/passports/paper1.yaml` when the first numeric claim lands in `manuscript.tex`.
