# `analyses/02_h2_private_goods/` — H2: private vs. public goods delivery

**Status:** not started.

Tests hypothesis **H2** (Chapter~3): the US–China aid race is sharper where aid
is delivered as private/excludable goods (government-to-government projects)
than where it flows through NGOs toward broad public goods. The dependent
structure splits US and Chinese aid by delivery channel and re-estimates the
short-run allocation model from `01_quant_main` interacted with channel type.

When starting: copy `../01_quant_main/scripts/R/` as the skeleton. The `.here`
sentinel in this directory makes `here::here()` resolve here, so `here("_outputs")`
writes locally.
