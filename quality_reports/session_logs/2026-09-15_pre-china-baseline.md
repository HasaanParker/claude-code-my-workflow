# Session Log: 2026-09-15 — Pre-China baseline test (and what it exposed)

**Status:** COMPLETED — result is a **negative//fragility finding**, not a confirmation. Pending user decision on respecifying the primary model.

## Objective

Run the decisive endogeneity test on the 2026-09-14 SOI finding (significant
positive elasticity in the US-aligned bloc): freeze bloc assignment on a
pre-China baseline (1990–1999 mean `rel_align`, terciled once, time-invariant)
so China-era aid cannot drive the alignment that classifies it.

## What was built

`02_clean.R`: `soi_bloc_pre` — country-level mean `rel_align` over 1990–1999,
terciled once across the recipient sample, time-invariant, joined by `iso3c`
only (NOT lagged; already predetermined). Countries need ≥5 of 10 pre-years;
15 of 150 unassignable (Montenegro, Serbia, South Sudan, Timor-Leste,
Palestine, Somalia, and micro-states that joined the UN after 1999 — Tuvalu,
Tonga, Kiribati, Palau). `03_analyze.R`: added as a third stratification cut
alongside `region` and `soi_bloc_lag`, baseline and extended.

## The test result — and then the collapse

**Step 1 — pre-China bloc, full panel (1970–2022).** The finding did not just
survive, it more than doubled: US-aligned **0.251** (p<.001) vs 0.098 for the
t−1 bloc. Contested −0.018 (ns), China-aligned 0.033 (ns). Leave-one-country-out
across all 45 US-aligned countries is very stable (range 0.231–0.266, sd 0.008)
— **not** an outlier artifact. Bloc agreement between frozen-1990s and t−1 is
only 56%, so the likely reason the frozen version is larger is classifier noise
attenuating the t−1 estimate.

**Step 2 — the robustness checks killed it.** Two standard checks, both of
which the project's own `inference-robustness.md` calls for:

| Specification (US-aligned, pre-frozen, all-official) | Estimate | p |
|---|---|---|
| Full panel 1970–2022, no trends (the "headline") | **0.251** | <.001 |
| + country-specific linear trends | 0.056 | .061 |
| China era 2000–2021 only | 0.084 | .012 |
| **China era + country trends** | **0.029** | **.100** |

**Step 3 — this implicates the whole short-run analysis, not just this cut.**
In the most defensible specification (2000–2021, where the treatment actually
varies, + country trends), essentially nothing survives anywhere:

| Cut (China era + country trends) | Estimate | p |
|---|---|---|
| **Pooled** | **0.006** | **.660** |
| pre-frozen US-aligned | 0.029 | .100 |
| pre-frozen Contested | −0.034 | .044 |
| pre-frozen China-aligned | 0.003 | .921 |
| t−1 US-aligned | 0.032 | .073 |
| t−1 Contested | 0.004 | .786 |
| t−1 China-aligned | −0.022 | .183 |

(The lone p=.044 is Contested turning negative — one marginal result among many
specifications; not something to hang a claim on.)

## Root cause: a defect in the primary specification

The full 1970–2022 panel carries **30 years of structural-zero treatment**.
GCDF 3.0 only covers commitment years 2000–2021, so `china_all` is 0 for
1970–1999 *by construction* — that is "no data," not "China gave nothing."
Those observations contribute no treatment variation but do shape the fixed
effects, so a country whose US aid trended up over the same decades that
Chinese finance appeared reads as a positive China→US response. Country trends
(or dropping the pre-coverage years) absorbs it, and the effect goes to ~0.

**This is an internal inconsistency in my own work:** `04_var_dynamics/02_clean.R`
restricts to 2000–2021 for exactly this reason, with exactly this argument
written in its header — but `01_quant_main` does not. The VAR was specified
correctly; the FE analysis was not.

## The reconciliation this produces

The 2026-09-14 session flagged as a puzzle that the panel VAR found no
significant lagged cross-donor effect while the short-run FE model found
significant positive elasticities. **That puzzle is now resolved in the VAR's
favor**: the FE elasticities were the artifact. Two independent methods
(system-GMM panel VAR, and FE on the correctly-restricted sample) now agree
there is no detectable lagged US–China aid relationship.

## Genuine tension worth surfacing, not hiding

Country-specific trends can *over*-absorb: if Chinese finance grows smoothly
within a country and US aid responds progressively, a country trend eats the
real effect. So the honest range is:

- China era, **no** trends: pooled **0.060** (p=.003) — a modest real effect
- China era, **with** trends: pooled **0.006** (p=.660) — nothing

Which is right depends on whether within-country growth in Chinese finance *is*
the treatment or is a nuisance trend. That is a specification judgment for the
user/advisor, not something to settle unilaterally.

## Consequences

- The "reinforcement of already-secured allies" thread is **not currently
  supported**. Do not build theory on it until the specification question is settled.
- `ch04_quant_main.tex` currently reports the full-panel numbers (US-aligned
  0.098/p=.005, Europe 0.493, etc.) as findings. Those are now known to be
  specification-fragile and the chapter **overclaims as written**.
- No table/figure yet includes the 0.251 pre-frozen number — it was caught
  before being wired into any committed artifact.

## Next Steps

- [ ] **User decision:** make China-era (2000–2021) the primary sample? It departs from the original working recipe but fixes a real defect and matches how the VAR is already specified.
- [ ] **User decision:** country trends in the primary spec, or reported as robustness only (given the over-absorption tension)?
- [ ] Revise `ch04_quant_main.tex` down to what survives, once the above are settled.
- [ ] Dreher 2021 replication package is now in `Dissertation/data/dreher2021_replication/` — contains `Raw-Data/WSA_1990_2015.csv` (the actual World Steel Association series the paper used) and `test_instruments2.dta`, superseding the UN Comtrade stopgap for the IV thread.
