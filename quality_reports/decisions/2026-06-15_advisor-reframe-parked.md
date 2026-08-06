# ADR-0002: Park the advisor's predict-and-compare reframe as a side deliverable

**Status:** ACCEPTED
**Date:** 2026-06-15
**Context:** `/interview-me` session; the advisor proposed a methodologically different framing of the Ch 4 empirical question.

## Problem

The advisor suggested reframing the core empirical question as a **prediction problem**: fit a pre-China baseline model of US aid allocation (M0), predict where US aid "should" flow absent Chinese competition, and infer China's contribution from the M0-vs-observed (M1) predictive gap — rather than estimating a US↔China aid correlation directly. This is attractive (it sidesteps simultaneity and frames the contribution as an interpretable magnitude) but it is not yet a pinned-down design, and it arrived without a full writeup. We need to decide how much of the dissertation to commit to it now.

## Options considered

### Option A: Restructure Ch 4 around the reframe

Make predict-and-compare the primary empirical strategy.

**Pro:** Directly satisfies the advisor; a clean single narrative.
**Con:** The design has real open questions (definition of "pre-China," what M0 is, inference on the gap, whether the gap is causal or descriptive). Committing now means restructuring around an unspecified method.

### Option B: Ignore it for now

Proceed with the short-run OLS + IV + VAR plan; revisit later if the advisor insists.

**Pro:** Keeps momentum on the committed empirical plan.
**Con:** Loses the advisor's input and the framing's genuine strengths; risks re-litigating later with nothing captured.

### Option C: Park it as a side deliverable (chosen)

Reserve space at `Dissertation/analyses/05_advisor_reframe/` with a `SPEC.md` capturing the proposal; do not restructure around it until the user brings a fuller description.

**Pro:** Preserves the idea and its open questions without derailing the committed plan; makes it cheap to pick up later.
**Con:** Requires a later decision to graduate or drop it; the parked spec may go stale if not revisited.

## Decision

**Chose:** Option C — park as a side deliverable.

**Rationale:** The reframe is promising but under-specified, and the interview surfaced it as an idea, not a worked design. Capturing it in a `SPEC.md` (with the open questions explicitly listed) keeps it recoverable at near-zero cost while the committed short-run + IV + VAR plan carries the dissertation forward. Restructuring around an unspecified method (Option A) would be premature; ignoring it (Option B) would waste the advisor's input.

## Consequences

- `Dissertation/analyses/05_advisor_reframe/` created with `.here`, `README.md`, and `SPEC.md` (the proposal capture + open questions + resume steps).
- Explicit non-goal: **do not** restructure the dissertation around the reframe until the user brings a fuller writeup / advisor conversation notes.
- A future decision is deferred: whether the reframe graduates into a dedicated chapter, becomes a robustness appendix, or is set aside.

## Rejected alternatives — why not

- **A (restructure now):** The design is under-specified (pre-China cutoff, choice of M0, inference on the gap, causal vs. descriptive) — committing the dissertation to it now is premature.
- **B (ignore):** Discards the advisor's input and the framing's real strengths, and captures nothing for later.
