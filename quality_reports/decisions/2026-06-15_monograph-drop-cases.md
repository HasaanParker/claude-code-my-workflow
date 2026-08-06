# ADR-0001: Monograph structure; drop the qualitative case chapters

**Status:** ACCEPTED
**Date:** 2026-06-15
**Context:** `/interview-me` session following the workflow kickoff; two structural decisions that override the initial 3-paper scaffold.

## Problem

The kickoff session built a 3-paper scaffold (`Papers/paper{1,2,3}_TODO/`) on the assumption the dissertation was a 3-paper hybrid. The interview surfaced that (a) the Dec 2024 prospectus — *"US–China Aid Competition in the 21st Century: Aid Races across Spheres of Influence"* — is a **single-argument book**, and (b) the planned qualitative case-study chapters (Ethiopia, Peru, Bangladesh) are being cut. We need to decide the dissertation's structure and where the empirical weight sits.

## Options considered

### Option A: Keep the 3-paper hybrid

Three self-contained manuscripts under `Papers/`, loosely themed.

**Pro:** Each paper is independently submittable; matches a common poli-sci job-market strategy.
**Con:** Misrepresents the actual project, which is one continuous argument; forces artificial separation and triplicated front matter; the prospectus is not written as three papers.

### Option B: Monograph, keep qualitative cases

Single book with quant chapter **and** the Ethiopia/Peru/Bangladesh case chapters.

**Pro:** Mixed-methods breadth; cases illustrate mechanisms the regressions can't.
**Con:** The cases were the weakest, highest-cost part of the plan; carrying them dilutes focus and delays the empirical core.

### Option C: Monograph, drop qualitative cases (chosen)

Single book, primarily quantitative; the empirical burden concentrates on the quant chapter (Ch 4).

**Pro:** Matches the prospectus; one tight argument; lets us make Ch 4 airtight (better identification, IV, VAR) rather than spreading effort.
**Con:** All empirical risk now sits on one chapter; loses the qualitative mechanism evidence.

## Decision

**Chose:** Option C — monograph, drop the qualitative case chapters.

**Rationale:** The prospectus already *is* a single-argument book; the 3-paper framing was a working-style scaffold, not the real structure. Dropping the cases is a focus decision — it concentrates effort on making the quantitative chapter defensible (country FE, a Dreher/Zeitz-style IV, a revised sphere-of-influence operationalization, and a long-run VAR/Granger test) rather than maintaining three thinner threads plus fragile case work. The `analyses/NN_*/` folders preserve the compartmentalized-working-piece benefit of the old scaffold without pretending each is a separate paper.

## Consequences

- `Papers/paper{1,2,3}_TODO/` retired; repo restructured to `Dissertation/` with `chapters/` (5: intro, lit, theory, quant, conclusion) + `analyses/NN_*/` (see the restructure plan `quality_reports/plans/2026-06-15_monograph-restructure.md`).
- The empirical burden concentrates on Ch 4 → the first analytical piece (spec: `quality_reports/specs/2026-06-15_first-analysis-quant-refresh.md`) must be airtight.
- Conclusion renumbered from prospectus Ch 7 → Ch 5 after the case-chapter cuts.
- Chapter numbering and the sphere-of-influence operationalization become load-bearing; future work defends and extends the theory rather than replacing it (the +0.113 Africa finding survives the data — see `MEMORY.md` `[LEARN:data]`).

## Rejected alternatives — why not

- **A (3-paper hybrid):** Misrepresents a single-argument project and triplicates overhead.
- **B (keep cases):** The cases were the highest-cost, lowest-confidence component; carrying them delays the empirical core the dissertation now rests on.
