# Papers/

The three dissertation papers, each self-contained.

## Layout

```
Papers/
├── paper1_TODO/      # rename slug when working title firms up
├── paper2_TODO/
└── paper3_TODO/
```

Each paper directory has the same shape:

```
paperN_<slug>/
├── manuscript.tex          # the paper; \input{../../Preambles/header.tex}; \bibliography{../../Bibliography_base}
├── scripts/R/              # 00_run_all.R orchestrator + 01_load → 05_figures
├── _outputs/               # R intermediate .rds + sessionInfo (gitignored except .gitkeep)
├── figures/                # PDF figures sourced into manuscript via \includegraphics
├── tables/                 # LaTeX table fragments (\input{tables/<name>.tex})
├── .here                   # makes here::here() resolve to the paper root, not the repo root
└── README.md               # paper-level overview, target journal, replication status
```

## Why self-contained

- A paper can be submitted (or shared with a coauthor) without dragging the other two.
- Cross-artifact review (`/review-paper` + `/review-r` + `/audit-reproducibility`) runs entirely within one paper directory — manuscript ↔ scripts ↔ outputs dependency graph stays local.
- `here::here()` inside any script resolves to the paper root (`.here` sentinel), so paths are short and the paper directory is portable.

## Shared across all papers

- `Bibliography_base.bib` (repo root) — one canonical bibliography.
- `Preambles/header.tex` — shared LaTeX preamble (palette, packages). Reused for any job-talk slides.
- `quality_reports/` — plans, specs, session logs, decision records.

## Compiling a paper

From inside the paper directory:

```bash
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
BIBINPUTS=../..:$BIBINPUTS bibtex manuscript
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
```

Or via skill: `/compile-latex Papers/paper1_TODO/manuscript`.

## Running a paper's analysis

```bash
cd Papers/paper1_TODO && Rscript scripts/R/00_run_all.R
```
