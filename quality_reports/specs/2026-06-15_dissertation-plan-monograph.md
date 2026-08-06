# Research Spec: US–China Aid Competition (monograph)

**Date:** 2026-06-15
**Status:** APPROVED
**Source:** `/interview-me` session (2026-06-15). **Supersedes** the Dec 2024 prospectus as the current statement of the dissertation.
**Format:** Monograph — see `quality_reports/decisions/2026-06-15_monograph-drop-cases.md`.

---

## Research question

How does great-power donor competition between the United States and China
reshape the allocation of foreign aid across contested spheres of influence?
Specifically: when China enters a recipient the US values, does the US **race**
(match Chinese finance to hold the sphere) or **withdraw** (cede the recipient)?

## Motivation

China's scale-up of development finance (AidData GCDF documents hundreds of
billions in official finance since 2000) has turned aid back into an instrument
of great-power competition. Whether the US treats Chinese entry as a threat to
contest or a loss to accept — and where — is both theoretically unsettled and
policy-relevant. The prospectus finding that US and Chinese aid **co-move
positively in Africa (+0.113) but negatively elsewhere** is the empirical puzzle
the dissertation explains.

## Theory (Chapter 3)

Donors facing a strategic rival's entry choose between escalation (an **aid
race**) and disengagement (**aid withdrawal**). Which dominates depends on:

1. whether the recipient sits inside a **contested sphere of influence**
   (operationalized via geographic proximity, historical ties, and
   voting-alignment components — a construct this dissertation refines and
   tests, not takes as given); and
2. the **type of good** the aid delivers (private/excludable government-to-
   government projects vs. NGO-delivered public goods).

## Hypotheses

- **H1 (race vs. withdrawal).** In contested spheres, US and Chinese aid co-move
  positively; outside them, US aid falls as Chinese aid rises. The +0.113 Africa
  vs. negative-elsewhere pattern is the motivating instance.
- **H2 (private vs. public goods).** The race is sharper where aid is delivered
  as private/excludable goods than where it flows through NGOs to broad public
  goods. (Tested in `analyses/02_h2_private_goods/`.)

## Empirical strategy

Concentrated in Chapter 4 (the qualitative case chapters were dropped, so this
chapter carries the empirical burden). Four compartmentalized pieces:

| Piece | Dir | Role |
|---|---|---|
| Short-run allocation model | `analyses/01_quant_main/` | Country + year FE regressions of US aid on Chinese aid × sphere status, by region. The dissertation's core estimate. |
| IV robustness | `analyses/03_iv_robustness/` | Dreher/Zeitz-style shift-share instrument (Chinese steel/heavy-industry production × recipient exposure) for Chinese aid. |
| Long-run dynamics | `analyses/04_var_dynamics/` | Panel VAR / Granger-causality to separate a contemporaneous race from a lead–lag dynamic; IRFs for Ch 4. |
| SOI operationalization | (feeds all of the above) | A revised, defensible measure of "sphere of influence." |

The **first analytical piece** (Option A refresh + VAR extension) has its own
requirements spec: `quality_reports/specs/2026-06-15_first-analysis-quant-refresh.md`.

## Data

- **Chinese official finance:** AidData Global Chinese Development Finance (GCDF).
- **US / DAC aid:** OECD-DAC Creditor Reporting System (CRS).
- **Unit of analysis:** recipient-country × year.
- **Covariates:** need (GDP p.c., population), strategic value, governance, UNGA
  voting alignment, historical-ties and geographic components of SOI.
- Not yet loaded — `Dissertation/data/` is a placeholder for the extracts.

## Expected results

- Positive US↔China aid association in Africa, negative outside — robust to
  country FE and to the IV.
- A sharper race for private/excludable delivery (H2).
- Long-run dynamics consistent with response rather than coincidence (one
  donor's entry Granger-predicts the other's move within a few years).

## Contribution

- Reconciles the mixed sign of donor-competition estimates by conditioning on
  sphere-of-influence status and good type, rather than reporting an average.
- A defensible, testable operationalization of "sphere of influence" in aid data.
- Short-run allocation **and** long-run co-evolution evidence in one framework.

## Open questions

- Final SOI operationalization and its sensitivity.
- IV validity: exclusion restriction for steel × exposure; first-stage strength.
- Panel-VAR lag selection and stationarity handling for aid flows.
- The advisor's predict-and-compare reframe (parked — see
  `analyses/05_advisor_reframe/SPEC.md`) as a possible alternative or robustness.

## Non-goals (this dissertation)

- Qualitative case studies (dropped).
- Restructuring around the predict-and-compare reframe before a fuller writeup.
