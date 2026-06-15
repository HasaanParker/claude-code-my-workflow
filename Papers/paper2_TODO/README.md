# Paper 2: *[Working title TBD]*

**Slug:** `paper2_TODO` (rename when title firms up)
**Stage:** scaffold
**Target journal:** TBD

## Question

*One-sentence research question — TBD.*

## Layout

Same shape as `paper1_TODO/` — see `../paper1_TODO/README.md` for details.

## Reproducing

```bash
cd Papers/paper2_TODO && Rscript scripts/R/00_run_all.R
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
BIBINPUTS=../..:$BIBINPUTS bibtex manuscript
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
```

## Replication targets

*Fill once a replication baseline is established.*
