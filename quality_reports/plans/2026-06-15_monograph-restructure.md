# Plan: Restructure repo as a monograph + first-analysis spec

**Status:** COMPLETED (executed 2026-08-06)
**Date:** 2026-06-15 (drafted) · 2026-08-06 (executed)
**Canonical path:** `quality_reports/plans/2026-06-15_monograph-restructure.md` (renamed from working-draft `swirling-forging-robin.md`).
**Execution log:** `quality_reports/session_logs/2026-08-06_monograph-restructure.md`

---

## Context

The kickoff session (earlier today) built a 3-paper scaffold — `Papers/paper{1,2,3}_TODO/` — under the assumption the dissertation was a 3-paper hybrid. The `/interview-me` session that followed surfaced two decisions that override that scaffold:

- **The dissertation is a monograph**, not 3 papers. The user's Dec 2024 prospectus ("US-China Aid Competition in the 21st Century: Aid Races across Spheres of Influence") is a single-argument book. The 3-paper scaffold is a working-style scaffold that maps onto chapters, not separate manuscripts.
- **The qualitative case-study chapters (Ethiopia, Peru, Bangladesh) are dropped.** The dissertation becomes primarily quantitative. Empirical burden shifts entirely onto the quant chapter (Ch 4), which now needs to be airtight: better identification, better operationalization of "sphere of influence," IV, and a VAR/long-run dynamics extension.

Two other things surfaced that this plan needs to accommodate:

- **First analytical piece is Option A** — refresh the main quant chapter (country FE, IV via Dreher/Zeitz steel × exposure, better sphere-of-influence operationalization) — **plus** a long-run dynamics test (panel VAR / Granger-causality) as an additional analytical piece alongside the existing short-run OLS.
- **Advisor's predict-and-compare reframe** — a methodologically different framing where a pre-China baseline model of US aid allocation is used to generate counterfactual predictions, and China's contribution is inferred from the M0-vs-M1 predictive gap. Parked as a **side deliverable**, not restructured into. Space reserved for it under `Dissertation/analyses/05_advisor_reframe/` with a spec doc capturing what the user described.

**Africa sign clarified.** The user's off-hand "negative correlation only in Africa" statement was inverted; the actual prospectus finding is **+0.113 in Africa** (Aid Race, supporting the theory) and negative elsewhere (Aid Withdrawal, also supporting the theory). The theory survives the data. Work ahead = defend and extend, not replace.

---

## Target structure

Drop the `Papers/` wrapper. `Dissertation/` sits at repo root.

```
my-project/
├── Dissertation/                              # ← replaces Papers/paper{1,2,3}_TODO/
│   ├── manuscript.tex                         # top-level: \include{chapters/ch01_intro} etc.
│   ├── chapters/
│   │   ├── ch01_intro.tex                     # stubs; user fills over time
│   │   ├── ch02_lit.tex
│   │   ├── ch03_theory.tex
│   │   ├── ch04_quant_main.tex                # \input{tables/...} from analyses/01_quant_main
│   │   └── ch05_conclusion.tex                # (was Ch 7 in prospectus; renumbered after case-chapter cuts)
│   ├── analyses/                              # compartmentalized R work
│   │   ├── 01_quant_main/                     # Ch 4 core: short-run OLS by region
│   │   │   ├── .here                          # here::here() resolves to this dir
│   │   │   ├── scripts/R/                     # 00_run_all + 01_load → 05_figures (moved from paper1_TODO)
│   │   │   ├── _outputs/                      # .rds + sessionInfo.txt (gitignored except .gitkeep)
│   │   │   └── README.md                      # what's here, status, replication targets
│   │   ├── 02_h2_private_goods/               # H2 test: NGO vs government delivery (stub)
│   │   │   ├── .here
│   │   │   └── README.md
│   │   ├── 03_iv_robustness/                  # Dreher/Zeitz steel × exposure IV (stub)
│   │   │   ├── .here
│   │   │   └── README.md
│   │   ├── 04_var_dynamics/                   # Panel VAR / long-run co-evolution (stub)
│   │   │   ├── .here
│   │   │   └── README.md
│   │   └── 05_advisor_reframe/                # Predict-and-compare side deliverable (stub)
│   │       ├── .here
│   │       ├── SPEC.md                        # capture of the advisor's proposal
│   │       └── README.md
│   ├── figures/                               # PDFs \includegraphics'd into chapters
│   ├── tables/                                # .tex fragments \input into chapters
│   ├── data/                                  # raw + interim (gitignored except .gitkeep)
│   ├── .here                                  # here() at Dissertation level (for chapter-level R if any)
│   └── README.md                              # what's here + how to compile + current chapter/analysis status
├── Bibliography_base.bib                      # (unchanged, still at repo root)
├── Preambles/header.tex                       # (unchanged, still at repo root; manuscript uses ../Preambles/)
├── ...                                        # (rest of repo unchanged)
```

**Path implications (worked once, used across every chapter and analysis):**

- Chapter code: `Dissertation/manuscript.tex` → `\input{../Preambles/header.tex}`, `\bibliography{../Bibliography_base}`. One `../` less than the old `Papers/paper1_TODO/` layout.
- R code in `analyses/NN/scripts/R/`: `.here` sits in `analyses/NN/`, so `here()` resolves to the analysis root. `OUT_DIR = here("_outputs")` stays clean (same idiom as the old `paper1_TODO` layout).
- Cross-cutting data: `analyses/NN/scripts/R/01_load.R` reads from `../../../data/` (or uses an absolute-via-`here()` pattern once a `Dissertation/`-level path helper is added). Deferred until data actually lands.

---

## Deliverables from this session (concrete file operations)

### A. Repo restructure (mostly `git mv`, one directory rename)

1. **Move** `Papers/paper1_TODO/scripts/R/*` → `Dissertation/analyses/01_quant_main/scripts/R/*`. Preserves git history via rename detection. All 7 files (6 `.R` + `README.md`).
2. **Move** `Papers/paper1_TODO/.here` → `Dissertation/analyses/01_quant_main/.here`.
3. **Move** `Papers/paper1_TODO/_outputs/.gitkeep` → `Dissertation/analyses/01_quant_main/_outputs/.gitkeep`.
4. **Delete** `Papers/paper1_TODO/{manuscript.tex,README.md,figures/,tables/}` — content superseded by new Dissertation/ files (below). Note: `manuscript.tex` content pattern gets rewritten at the `Dissertation/manuscript.tex` level.
5. **Delete** `Papers/paper2_TODO/` and `Papers/paper3_TODO/` entirely — speculative placeholders that never had unique content.
6. **Delete** `Papers/README.md` and `Papers/` wrapper.

### B. New Dissertation/ scaffolding (fresh files)

7. `Dissertation/manuscript.tex` — top-level LaTeX assembling chapters via `\include{}`. Adapted from the current `Papers/paper1_TODO/manuscript.tex` but restructured for `\include{chapters/ch01_intro}` etc. Uses `\input{../Preambles/header.tex}` and `\bibliography{../Bibliography_base}` (paths adjusted).
8. `Dissertation/chapters/ch{01_intro,02_lit,03_theory,04_quant_main,05_conclusion}.tex` — 5 stub chapters, each with a placeholder heading + `\textit{Placeholder.}` sections following the prospectus outline (minus Ch 5–6 cases). `ch04_quant_main.tex` includes commented `\input{tables/...}` markers pointing at where `analyses/01_quant_main/_outputs/*.tex` output will land.
9. `Dissertation/README.md` — 1-page overview: what's here, compile command, current chapter/analysis status, pointer to `CLAUDE.md`.
10. `Dissertation/.here` — sentinel so `here()` at Dissertation level resolves correctly.
11. `Dissertation/{figures,tables,data}/.gitkeep` — placeholder directories.
12. `Dissertation/analyses/{02_h2_private_goods,03_iv_robustness,04_var_dynamics,05_advisor_reframe}/` — each with `.here`, `README.md` (1 paragraph on scope + "not started"), no scripts skeleton yet (user copies from `01_quant_main/scripts/R/` when they start each piece).
13. `Dissertation/analyses/05_advisor_reframe/SPEC.md` — capture of the advisor's predict-and-compare framing based on what the user described this session. Enough detail that a future session can pick it up without re-deriving; frames it as an open exploration, not a committed design.

### C. Update the R skeleton for the new layout

14. Edit `Dissertation/analyses/01_quant_main/scripts/R/00_run_all.R` and `README.md` to reflect the analysis-level context (path references, section names). The scripts are already paper-root-relative via `.here`, so the actual R code needs minimal change; the surrounding docstrings + README reference paths that need updating.

### D. Config file updates

15. **`CLAUDE.md`** — replace the "Folder Structure" section, the "Commands" section (compile paths change), the "Paper Progress" table (replaced by a "Chapter Progress" or "Chapter + Analyses Status" table), and the "Deferred customizations" section (rename `Papers/paper{1,2,3}_TODO/` → drop that line, since the reorg happens in this plan). Keep everything else.
16. **`MEMORY.md`** — append 3 `[LEARN]` entries under "Project Learnings":
    - `[LEARN:framing]` monograph (not 3-paper) decision + reason; scaffolding-as-working-strategy note.
    - `[LEARN:data]` Africa is the ONLY region with positive US↔China aid correlation (+0.113); non-Africa negative. Confirmed against Dec 2024 prospectus Appendix Table 1. Correct any future off-hand claim to the contrary before proceeding.
    - `[LEARN:project]` Advisor pushing predict-and-compare reframe; parked as side deliverable pending user's fuller description. See `Dissertation/analyses/05_advisor_reframe/SPEC.md`.

### E. Decision records + specs for the interview outputs

17. `quality_reports/decisions/2026-06-15_monograph-drop-cases.md` — ADR-style record of the two structural decisions made this session (monograph over 3-paper; drop qualitative case chapters). Options considered, choice, consequences, rejected alternatives.
18. `quality_reports/decisions/2026-06-15_advisor-reframe-parked.md` — ADR for parking the advisor's reframe as a side deliverable rather than restructuring around it.
19. `quality_reports/specs/2026-06-15_dissertation-plan-monograph.md` — the interview-me research spec. Full spec per the interview-me skill template: research question, motivation, hypotheses (H1, H2), empirical strategy (short-run OLS + panel VAR + IV + revised SOI operationalization), data, expected results, contribution, open questions. Supersedes the Dec 2024 prospectus as the current statement of the dissertation.
20. `quality_reports/specs/2026-06-15_first-analysis-quant-refresh.md` — MUST/SHOULD/MAY requirements spec for the first analytical piece (Option A refresh + VAR extension). Concrete enough to hand to `/data-analysis` in a future session.

### F. Session log

21. `quality_reports/session_logs/2026-06-15_interview-monograph-restructure.md` — end-of-session log capturing the interview conclusions + repo restructure + decisions taken + open items (advisor reframe details, PR #1 merge, etc.).

**Total file operations:** ~15 new files, ~10 file moves (git mv), ~5 file deletions, 2 config edits, 1 session log.

**Not touched:** `.claude/skills/`, `.claude/agents/`, `.claude/rules/`, `.claude/hooks/`, `.claude/scripts/`, `.claude/settings.json`, `templates/`, `Preambles/header.tex`, `.githooks/`, `Bibliography_base.bib`, everything under `explorations/`, `master_supporting_docs/`, `Slides/`, `Quarto/`, `docs/`, `scripts/`. Upstream template infrastructure stays clean for future merges.

---

## Verification

1. **`git status`** after all operations: expect ~20 modified/new/deleted files, no `.claude/skills|agents|rules|hooks` touched.
2. **`grep -rn "Papers/paper" .`** (excluding `.git`, `quality_reports/archive/`, and this plan file itself): should return zero non-historical hits after the reorg. If any skill or rule references the old `Papers/paperN_TODO/` paths (`CLAUDE.md`, `MEMORY.md` learnings, session logs from last session), those references either get updated or explicitly left as historical mentions of the old layout.
3. **Compile the new Dissertation/manuscript.tex** end-to-end from `Dissertation/`:
   ```bash
   cd Dissertation && \
     TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode manuscript.tex
   ```
   Expected: multi-chapter PDF (~5 pages of placeholder content), no unresolved `\include{}` errors.
4. **Sanity-check the R skeleton path resolution**: `cd Dissertation/analyses/01_quant_main && Rscript -e 'library(here); print(here::here())'` should print `.../Dissertation/analyses/01_quant_main` (not the repo root).
5. **Quality gate**: `python scripts/quality_score.py Dissertation/manuscript.tex Dissertation/chapters/*.tex Dissertation/analyses/01_quant_main/scripts/R/*.R`. Expect the same 04_tables.R false positive we saw last commit; everything else 100/100.

---

## Explicitly deferred

- **Merge PR #1** from the last session (still open). Will do at the end of this plan's implementation via a `/commit` for this restructure + `gh pr merge` for both (unless the user wants them merged separately).
- **Fleshing out the advisor's reframe.** SPEC.md captures the current understanding; when the user has a fuller writeup / advisor conversation notes, we revise.
- **Real content for chapter stubs.** Placeholder text only; the user writes.
- **Actually running the quant refresh (country FE, IV, VAR)** — the first analytical piece. Spec captured in `quality_reports/specs/2026-06-15_first-analysis-quant-refresh.md`; execution is a *separate* future session via `/data-analysis`.
- **Loading real data.** `Dissertation/data/` is a placeholder; user brings AidData GCDF + OECD-DAC CRS extracts in when actually running the analysis.
- **Renaming `Papers/paperN_TODO/` deferred item in CLAUDE.md** — this plan actually closes that item; remove it from CLAUDE.md's "Deferred customizations" list.
- **A dedicated Ch 4b or Ch 5 for the advisor reframe** — not created; the reframe lives under `analyses/05_advisor_reframe/` until it graduates.
