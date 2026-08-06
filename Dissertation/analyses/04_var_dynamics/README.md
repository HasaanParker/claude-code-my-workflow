# `analyses/04_var_dynamics/` — Long-run dynamics (panel VAR)

**Status:** not started.

Complements the short-run allocation models in `01_quant_main` with a test of
**long-run co-evolution**: a panel vector autoregression (and/or
Granger-causality tests) on US and Chinese aid flows, to distinguish a
contemporaneous race from a lead–lag dynamic (does one donor's entry predict the
other's response, and over what horizon?). Impulse-response functions feed
Chapter~4's "Long-run dynamics" section.

When starting: copy `../01_quant_main/scripts/R/` as the skeleton. The `.here`
sentinel makes `here::here()` resolve here; `here("_outputs")` stays local. Never
re-implement a VAR estimator by hand — drive the canonical panel-VAR package.
