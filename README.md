# Foreign Aid Competition: US–China

A PhD dissertation in political science by **Hasaan Parker**.

A ~3-paper hybrid dissertation (between traditional book and pure 3-paper format) on **foreign aid competition between the United States and China** — donor strategy, recipient response, and the political economy of aid in an era of great-power competition.

## Layout

| Path | What's there |
|---|---|
| [`Papers/`](Papers/) | The three dissertation papers, each self-contained (`manuscript.tex`, `scripts/R/`, `_outputs/`, `figures/`, `tables/`). See [`Papers/README.md`](Papers/README.md). |
| [`Bibliography_base.bib`](Bibliography_base.bib) | Shared bibliography (all three papers cite from this one file). |
| [`Preambles/header.tex`](Preambles/header.tex) | Shared LaTeX preamble. |
| `Slides/`, `Quarto/`, `docs/` | Slide infrastructure (dormant unless prepping a job talk / conference deck). |
| [`scripts/`](scripts/) | Repo-wide tooling (`quality_score.py`, `validate-setup.sh`, palette / surface-sync checks). |
| [`quality_reports/`](quality_reports/) | Plans, requirements specs, session logs, decision records, archive. |
| [`templates/`](templates/) | Session log, spec, quality-report, passport templates. |
| [`master_supporting_docs/`](master_supporting_docs/) | Reference papers and prior source materials. |

## Compiling a paper

From inside the paper directory:

```bash
cd Papers/paper1_TODO
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
BIBINPUTS=../..:$BIBINPUTS bibtex manuscript
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
```

Or via the workflow: `/compile-latex Papers/paper1_TODO/manuscript`.

## Running a paper's analysis

```bash
cd Papers/paper1_TODO && Rscript scripts/R/00_run_all.R
```

## Working with Claude Code

This repo uses an academic Claude Code workflow (plan-first → contractor mode, cross-artifact review, reproducibility audit, peer-review simulation). The AI-workflow context lives in:

- [`CLAUDE.md`](CLAUDE.md) — entry point for every session: project conventions, primary skills, paper progress.
- [`MEMORY.md`](MEMORY.md) — verified patterns + project `[LEARN]` entries.
- [`.claude/`](.claude/) — rules, skills, agents, hooks, references.

## Attribution

The Claude Code workflow infrastructure (`.claude/`, `CLAUDE.md`, `MEMORY.md` framing, `templates/`, `scripts/check-*.sh`, `.githooks/`) is forked from **[pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow)** by Pedro H. C. Sant'Anna. The upstream README (with its full feature tour, fork-and-go instructions, and contribution guide) is preserved at [`quality_reports/archive/UPSTREAM_README.md`](quality_reports/archive/UPSTREAM_README.md).

## License

[MIT](LICENSE), inherited from the upstream template.
