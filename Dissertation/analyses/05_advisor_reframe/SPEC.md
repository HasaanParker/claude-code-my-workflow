# SPEC — Predict-and-Compare Reframe (advisor's proposal)

**Status:** OPEN EXPLORATION · parked side deliverable · not a committed design
**Captured:** 2026-06-15 (interview session) · **Owner:** Hasaan Parker
**Relation to main design:** an *alternative* framing of the Chapter-4 empirical
question, not a replacement for the short-run allocation + VAR strategy in
`analyses/01_quant_main` / `04_var_dynamics`.

---

## The idea in one sentence

Rather than estimating a US↔China aid correlation directly, build a **pre-China
baseline model of US aid allocation**, use it to predict where US aid *would*
have gone absent Chinese competition, and read China's effect off the **gap
between predicted and observed US aid** (a predictive-counterfactual, not a
coefficient).

## Why the advisor likes it

- Sidesteps the reflection/simultaneity problem in a direct US–China regression
  (both flows respond to the same recipient characteristics and to each other).
- Frames the contribution as *"how much of the change in US aid allocation is
  attributable to China's entry?"* — a magnitude a policy audience understands.
- Turns the question into a prediction problem, where out-of-sample fit and the
  structure of prediction errors carry the argument.

## Sketch of the design (to be pinned down)

1. **M0 — baseline.** Train a model of US aid allocation on the **pre-China era**
   (or on recipients/periods with negligible Chinese finance), using the standard
   allocation covariates (need, strategic value, governance, historical ties).
   The estimand is a *predictive* function \(\hat{f}_0(\text{recipient covariates})\),
   not a causal coefficient.
2. **Counterfactual prediction.** Apply M0 to the China era to get
   \(\widehat{\text{US aid}}^{\,M0}\): where US aid should flow if the pre-China
   logic still held.
3. **M1 — observed / augmented.** Either observed US aid, or a model that adds
   Chinese-aid exposure as a predictor.
4. **The gap.** China's imputed contribution = systematic component of
   \((\text{observed US aid}) - \widehat{\text{US aid}}^{\,M0}\), or the
   improvement in fit from M0 → M1. Decompose the gap by region and by
   sphere-of-influence status to connect back to H1 (race vs. withdrawal).

## Open questions (blockers before this is a real design)

- **Definition of "pre-China."** Calendar cutoff vs. exposure threshold? GCDF
  coverage starts ~2000; a clean pre-treatment US-only window may be thin.
- **What M0 is.** OLS allocation model for interpretability, or a flexible
  learner (which predicts better but muddies the "US allocation logic" story)?
- **Inference on the gap.** How to put a standard error / uniform band on a
  predicted-vs-observed decomposition (bootstrap over the M0 estimation?).
- **Identification claim.** Is the gap *causal* (needs the pre-China logic to be
  the right counterfactual — a strong parallel-logic assumption) or explicitly
  *descriptive*? The advisor's framing needs this stated.
- **Overlap between M0 and the sphere-of-influence operationalization** so this
  isn't just re-deriving H1 by another route.

## Next step when resumed

Get the advisor's fuller writeup / conversation notes, then convert this sketch
into a MUST/SHOULD/MAY requirements spec under `quality_reports/specs/` and
decide whether it graduates to a chapter or stays a robustness appendix. Until
then, do **not** restructure the dissertation around it.
