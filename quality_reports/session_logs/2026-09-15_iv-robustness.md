# Session Log: 2026-09-15 (cont'd) — IV robustness (negative result)

**Status:** COMPLETED — pipeline built and run; **the instrument does not work**, and that is the finding. r-reviewer findings incorporated (two real fidelity bugs fixed; conclusion survives).

## Objective

Build `03_iv_robustness/` using the Dreher, Fuchs, Parks, Strange & Tierney
(AEJ:EP 2021) shift-share instrument, now that the user supplied their
replication package. Goal: identify the US-aid response to Chinese finance,
which the OLS/FE design of `01_quant_main` cannot.

## What the published instrument actually is

Extracted from `Analysis do file.do` (~lines 6082–6086) rather than guessed:

```stata
gen steel_1_ln          = ln(chinese_steel)                   // SHIFT (national, year-varying)
gen probaid_PRC_OFn_all = sum2 / 15                           // SHARE (country, time-invariant)
gen steel_OFn_all_1_ln  = steel_1_ln * probaid_PRC_OFn_all    // INSTRUMENT
```

Two corrections to earlier assumptions in this project:
- The main instrument **is** steel production (the "first factor of six
  construction materials" I found earlier in their appendix is an *alternative*).
  The project spec's original description was accurate.
- Their **headline share is computed over the study window (2000–2014)**, not a
  pre-period. They also build a historical alternative (`prob_PRCaid_2000`,
  share of 1970–1999 years, from Bartke) used in robustness.

## What we built

Inputs: `Raw-Data/WSA_1990_2015.csv` (`Chinese_steel`, kt) and
`Raw-Data/Bartke.dta` (`nbproject_womed`), both from their package; plus
`01_quant_main`'s panel. Instrument = `ln(steel_{t-1}) × exposure_i`, timed to
match the `china_*_lag` endogenous regressor. Sample **2000–2015** (bounded by
the steel series, six years shorter than the chapter's 2000–2021 primary).

**Deliberate departure:** we take the **predetermined** 1970–99 share as
primary, because a share computed over the outcome window is not predetermined
and cannot do what a shift-share design requires. Both are built and compared.

## Result

| Exposure share | 1st-stage coef | $t$ | 1st-stage $F$ | 2SLS |
|---|---|---|---|---|
| Predetermined (1970–99) | −0.040 | −0.02 | **0.001** | −40.7 (SE 2061) |
| Contemporaneous (2000–15) | 3.089 | 4.97 | 27.3 | 0.321 (p=.196) |

(For ODA-like flows the predetermined share reaches only F=8.2 — still below
the conventional threshold.)

**The valid share produces no first stage. The share that produces a first
stage is circular** — it is constructed from the same post-2000 Chinese-finance
variation the instrument exists to purge. Even taking it at face value, its
2SLS estimate is insignificant.

## Why it fails (diagnosed, not assumed)

Pre-2000 exposure *does* predict post-2000 Chinese finance across recipients
(r = 0.437, p = 2.3e-08; 95% of recipients with pre-2000 history received
finance after 2000). **But that content is purely cross-sectional, and the
country fixed effects this design requires absorb all of it.** Identification
then needs historically-exposed recipients to have seen *differentially
steeper* growth. They did not: **73% of recipients with no recorded pre-2000
Chinese project received Chinese finance anyway.** China's expansion was
broad-based rather than a deepening of existing ties — substantively
interesting in its own right, and fatal to the instrument.

This also rules out the obvious "my join is broken" explanation: a failed
`recipientcode`→`iso3c` join would give every country a zero share and no
correlation at all; instead 80 of 150 have positive history and the share
predicts finance strongly.

## Second structural limitation

Chinese steel production rose near-monotonically 2000–2014 (128,500 → 822,698
kt), so `ln(steel)_t` is essentially a trend. With year FE absorbing its level,
the instrument reduces to `share_i × trend_t` — approximately a
country-specific linear trend. Therefore it **cannot be combined with the
country-trend robustness spec**, and is vulnerable to the very
differential-trending confound that erased the OLS result rather than being a
remedy for it. Both limitations point the same way: this IV cannot rescue the
identification.

## Wired in

- `ch04_quant_main.tex` §IV rewritten from placeholder to a full negative-result
  section, with `table_iv.tex` and `fig_iv_first_stage.pdf`.
- Table is explicitly framed as a diagnosis, not an estimate ("neither 2SLS
  column supports inference").
- READMEs (`03_iv_robustness`, `Dissertation`) and `CLAUDE.md` status updated;
  stale claims in `Dissertation/README.md` swept per summary-parity rule.
- Manuscript compiles clean (24 pp, no overfull); manuscript + ch04 both 100/100.

## r-reviewer round — two real fidelity bugs, conclusion unchanged

The reviewer verified the null is genuine rather than a coding artifact (the
join key is sound — Bartke's `recipientcode` is already ISO3, and the live
cross-sectional correlation proves the join works), but found two fidelity
bugs against the published construction. Both were confirmed directly against
the do-file before acting, and both were real:

1. **Wrong exposure indicator.** We used `nbproject_womed` alone; Dreher et al.
   use a fallback cascade `bartke_amount_con → cia_amount_con → fais_total →
   oecd_con → nbproject_womed` (`Analysis do file.do:5031-5036`). The single
   variable under-counted exposure by 36% (508 vs 796 flagged country-years).
2. **Missing legacy ISO3 recodes.** `ZAR→COD`, `YUG/SCG→SRB`, `ROM→ROU`,
   `ADO→AND`, `WBG→PSE`, `TMP→TLS` (`:4999-5005`). Without them DR Congo,
   Serbia, Palestine and Timor-Leste silently failed to join and were
   indistinguishable from genuine zero-history countries. *Nuance:* Dreher's own
   do-file applies these in a different Bartke extract and NOT in the
   `prob_PRCaid_2000` block — we apply them regardless, since they are correct.

**After both fixes the exposure measure is materially better** — mean share
0.111 → 0.177, zero-history countries 70 → 53, 146 of 150 now matching Bartke,
cross-sectional $r$ 0.437 → 0.477 — **and the first stage is still dead**
($F$ 0.001 → 0.27 for china_all; 8.2 → 6.3 for china_oda, still sub-threshold).
The negative result therefore now rests on a correctly-built instrument rather
than a buggy one, which strengthens rather than weakens it. All downstream
numbers (chapter, table, README) were updated to the corrected figures.

Minor findings also applied: removed dead `fit_iv()`, corrected an imprecise
"Kleibergen-Paap" label (just-identified single-instrument design, so it is the
clustered first-stage F).

## Next Steps

- [ ] Open question unchanged and now sharper: the trends-vs-no-trends
      specification call is the thing that decides whether there is a finding.
- [ ] Remaining avenues: H2 delivery-channel test (`02_h2_private_goods`,
      independent of all this), and the advisor's predict-and-compare reframe
      (whose pre-China-baseline logic is already built).


---
**Context compaction (manual) at 08:26**
Check git log and quality_reports/plans/ for current state.
