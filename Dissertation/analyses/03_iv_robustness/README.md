# `analyses/03_iv_robustness/` — Instrumental-variables robustness

**Status:** not started.

Instruments Chinese aid exposure with a Dreher/Zeitz-style shift-share design:
Chinese steel (or broader heavy-industry) production interacted with each
recipient's baseline exposure to Chinese finance. Provides an exogenous-supply
robustness check on the short-run allocation estimates in `01_quant_main`, plus
first-stage strength diagnostics.

When starting: copy `../01_quant_main/scripts/R/` as the skeleton. The `.here`
sentinel makes `here::here()` resolve here; `here("_outputs")` stays local.
