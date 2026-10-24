# `analyses/03_iv_robustness/` — Instrumental-variables robustness

**Status:** built and run (2026-09-15). **Result is negative: the instrument
has no first stage under the only share definition that would make it valid.**

## Headline

| Exposure share | 1st-stage $F$ (china_all) | Verdict |
|---|---|---|
| Predetermined (1970–99, Bartke) | **0.27** | No identifying variation |
| Contemporaneous (2000–15 window) | 27.3 | Strong but **circular** |

The predetermined share is the methodologically valid one — being predetermined
is the property a shift-share design requires — and it produces nothing. The
contemporaneous share, which is what Dreher et al. use in their headline, is
constructed from the same post-2000 Chinese-finance variation the instrument
exists to purge, so its power is mechanical rather than evidence of
identification. Even taking it at face value, its 2SLS estimate is
insignificant ($0.321$, $p=.196$).

**Why it fails.** Pre-2000 exposure genuinely predicts post-2000 Chinese finance
across recipients ($r=0.48$, $p<10^{-9}$) — but that content is purely
cross-sectional and the country fixed effects this design requires absorb all of
it. Identification then needs historically-exposed recipients to have seen
*differentially steeper* growth tracking the steel trend. They did not: **68% of
recipients with no recorded pre-2000 Chinese aid received Chinese finance
anyway after 2000.** China's expansion was broad-based rather than a deepening
of existing ties — substantively interesting, and fatal to the instrument.

**Second structural limitation.** Chinese steel production rose
near-monotonically over 2000–2014, so $\ln(\text{steel})_t$ is essentially a
trend; with year FE absorbing its level, the instrument reduces to
$\text{share}_i \times \text{trend}_t$ — approximately a country-specific linear
trend. It therefore cannot be combined with the country-trend robustness
specification in `01_quant_main`, and is vulnerable to the same
differential-trending confound rather than a remedy for it.

## What the published instrument actually is

Read off `Analysis do file.do` (~lines 6082–6086) in the replication package,
not inferred:

```stata
gen steel_1_ln          = ln(chinese_steel)                   // SHIFT
gen probaid_PRC_OFn_all = sum2 / 15                           // SHARE
gen steel_OFn_all_1_ln  = steel_1_ln * probaid_PRC_OFn_all    // INSTRUMENT
```

Two corrections to earlier assumptions recorded in this project:

- The main instrument **is** Chinese crude steel production. The "first factor
  of six construction-material series" is an *alternative* in their appendix,
  not the headline. The original project spec's description was accurate.
- The paper is Dreher, Fuchs, Parks, Strange & Tierney, *AEJ: Economic Policy*
  (2021). Earlier notes in this repo called it "Dreher/Zeitz" — Zeitz is not an
  author of it.

The exposure share is built from Bartke historical Chinese aid via a **fallback
cascade** (`Analysis do file.do:5030–5047`), not a single variable:
`bartke_amount_con → cia_amount_con → fais_total → oecd_con → nbproject_womed`,
taking the next whenever the current is missing or zero, then flagging `> 0`.
Using `nbproject_womed` alone under-counts badly (508 flagged country-years vs
796 under the full cascade).

Bartke also uses legacy ISO3 codes that must be recoded before joining
(`ZAR→COD`, `YUG/SCG→SRB`, `ROM→ROU`, `ADO→AND`, `WBG→PSE`, `TMP→TLS`).
Dreher's do-file applies these in a *different* Bartke extract but not in the
`prob_PRCaid_2000` block; we apply them regardless, because without them DR
Congo, Serbia, Palestine and Timor-Leste silently fail to join and are
indistinguishable from genuine zero-history countries. After the fix, 146 of
150 recipients match Bartke.

## Inputs

From the replication package at `Dissertation/data/dreher2021_replication/`:

- `Raw-Data/WSA_1990_2015.csv` — Chinese crude steel production (`Chinese_steel`,
  thousand metric tons). **This bounds the sample to 2000–2015**, six years
  shorter than `01_quant_main`'s 2000–2021 primary window, so `03_analyze.R`
  refits OLS on the same window for a fair contrast.
- `Raw-Data/Bartke.dta` — historical Chinese aid, source of the predetermined share.

Plus `01_quant_main/_outputs/panel.rds`, so **run `01_quant_main` first.**

> `Dissertation/data/china_steel_exports_hs72.csv` (UN Comtrade HS72 exports,
> fetched 2026-09-14) is superseded for this analysis — it was a stopgap before
> the replication package arrived. It measures *exports*, not *production*, and
> is no longer read by this pipeline.

## Running

```bash
cd Dissertation/analyses/01_quant_main  && Rscript scripts/R/00_run_all.R
cd Dissertation/analyses/03_iv_robustness && Rscript scripts/R/00_run_all.R
```
