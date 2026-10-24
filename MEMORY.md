# Project Memory — US–China Foreign Aid Competition Dissertation

Working memory for this dissertation: workflow patterns, verification architecture, and project-specific `[LEARN]` entries that should persist across sessions.

**Two-tier memory system:**
- **This file** (`MEMORY.md`, committed) — dissertation-wide patterns + project learnings.
- **Auto-memory** (`~/.claude/projects/-Users-hasaanparker-my-project/memory/`, not committed) — Claude's per-user memory of the user's profile, tools, collaboration style. Loaded automatically each session.

When you (the human) correct Claude, append a `[LEARN:category]` entry to the **Project Learnings** section at the bottom so the correction sticks across sessions.

---

## Workflow Patterns

[LEARN:workflow] Requirements specification phase catches ambiguity before planning → reduces rework 30–50%. Use spec-then-plan for complex/ambiguous tasks (>1 hour or >3 files).

[LEARN:workflow] Spec-then-plan protocol: AskUserQuestion (3-5 questions) → create `quality_reports/specs/YYYY-MM-DD_description.md` with MUST/SHOULD/MAY requirements → declare clarity status (CLEAR/ASSUMED/BLOCKED) → get approval → then draft plan.

[LEARN:workflow] Plans, specs, and session logs must live on disk (not just in conversation) to survive compression and session boundaries. Quality reports only at merge time.

[LEARN:workflow] (2026-09-14) A Pre-Flight package-availability check ("fixest OK") is a snapshot, not a guarantee — a tool-version upgrade between sessions can silently empty a package library, or make a `capabilities()`/feature-detection flag lie (baked into the build, not checked against the runtime linker). Prefer a real runtime probe (actually open the device / call the function in a `tryCatch`) over trusting a capability flag, especially for anything spanning a session gap. Machine-specific specifics of this incident are in `.claude/state/personal-memory.md`, not here — this entry is the portable lesson.

[LEARN:workflow] Context survival before compression: (1) Update MEMORY.md with [LEARN] entries, (2) Ensure session log current (last 10 min), (3) Active plan saved to disk, (4) Open questions documented. The pre-compact hook displays this checklist.

---

## Verification Architecture (three complementary patterns)

[LEARN:pattern] Verification operates at three architectural levels, each addressing a different failure mode. Do NOT collapse them — they are complementary, not redundant:

1. **Critic-fixer loop** (`/qa-quarto`, `/review-paper --adversarial`) — *two agents, serial* — one reads the artifact and flags issues, the other applies fixes; loop until APPROVED. Best for **presentation + structural** bugs. Agents see the full artifact; adversarial tension comes from role assignment.

2. **Cross-artifact review** (`/review-paper` + `/review-r` + `/audit-reproducibility`) — *horizontal dependency traversal* — a manuscript's claims depend on scripts' outputs, so the manuscript reviewer spawns script reviewers and reproducibility checkers alongside the paper review. Best for **paper ↔ code consistency** (ATTs, coefficients, N match the outputs that produced them). **This is the central pattern for the dissertation** — every paper has manuscript ↔ R-scripts ↔ outputs dependencies.

3. **Post-Flight Verification / CoVe** (`/verify-claims` + `claim-verifier` agent) — *single agent, fresh-context fork* — the verifier has never seen the draft; it answers verification questions from the source material alone, using `context: fork` to architecturally enforce independence. Best for **factual hallucination** (fabricated citations, wrong dataset fields, misattributed findings). Adapted from [Dhuliawala et al. 2023, arXiv:2309.11495](https://arxiv.org/abs/2309.11495).

Each pattern enforces independence differently: critic-fixer uses role tension; cross-artifact uses dependency-graph traversal; CoVe uses context isolation. A skill that needs all three (e.g., `/review-paper --peer`) invokes them at different phases.

[LEARN:pattern] **HIGH-WARN gate-refuse for fabricated citations.** `/verify-claims` ranks three severity tiers: HIGH-WARN (fabricated reference / numerical contradiction / directional contradiction) → MED-WARN (transient retrieval failure) → LOW-WARN (source genuinely inaccessible). HIGH-WARN **blocks `/commit`** for affected files unless explicit `--no-fail-closed` override. False positives erode the gate's authority — be conservative on HIGH-WARN assignment.

[LEARN:pattern] **Variance reporting > point estimate for peer review.** `/review-paper --peer` originally returned one editorial verdict from one editor + 2 referees. AgentReview (ACL 2024, [arXiv:2406.12708](https://arxiv.org/abs/2406.12708)) found ~37% of paper decisions vary purely from reviewer-disposition sampling. `--variance N` runs N referees with sampled dispositions and returns a *distribution* of verdicts plus a K-of-N concern-frequency table. Bimodal "love-it-or-hate-it" papers reveal themselves; tight modal majorities reveal robust concerns. Cost: N×referee tokens. Hard cap N=5.

[LEARN:pattern] **Five-critic isolated voting beats single-critic composite judgment.** `/promote-memory` decides which `[LEARN]` entries graduate from personal-memory.md to MEMORY.md by spawning 5 critics in forked contexts (generality / staleness / redundancy / evidence / format). Each votes YES/NO on one dimension; majority promotes. Critics cannot see each other's votes — isolation prevents groupthink. User is final gate even on 5-of-5 unanimous votes.

[LEARN:pattern] **Provenance as a YAML artifact, not a folder.** `templates/passport-template.yaml` is a per-paper file listing every numeric claim with `source_file:line` + `output_file:field` + tolerance + status (PASS/FAIL/STALE/UNVERIFIED). `/audit-reproducibility` reads + rewrites in place. Stronger than folder-based reports because it's queryable and grep-able.

[LEARN:pattern] **70/20/10 architect/editor split for cost discipline.** `model-routing.md` codifies tier-per-agent: Haiku 4.5 for mechanical work (TikZ extraction, citation formatting, bib validation); Sonnet 4.6 for review/critique (r-reviewer, slide-auditor, proofreader); Opus 4.8 for high-judgment work (editor, methods-referee, claim-verifier, domain-reviewer). Typical 50–80% cost reduction with no quality loss on the mechanical tier. Anti-pattern: pushing claim-verifier / methods-referee / editor down a tier — these protect the paper from hallucination + weak identification + desk-reject mistakes; one false-positive PASS dominates the routing savings.

---

## Plan→Bypass Framing

[LEARN:safety] Do NOT frame Plan→Bypass as a "safety boundary" or "safety guarantee." Plan approval gives you a chance to review the APPROACH before execution, but exiting plan mode returns the session to `defaultMode` (bypassPermissions), at which point any tool call runs under the full allowlist. Frame as "review-before-execute convenience." If a real enforcement boundary is needed, keep `defaultMode: "default"` and approve each high-risk tool individually.

---

## Privacy in Diagnostic Skills

[LEARN:privacy] Diagnostic skills that read host-global config (e.g., `~/.claude/`, VSCode user settings) must require **explicit user confirmation** before crossing the repo boundary. Phase the skill: repo-local auto, host-global opt-in with key redaction.

---

## Claim-vs-Reality Framing

[LEARN:framing] The "orchestrator" is a **pattern** implemented by specific skills (`/commit`, `/qa-quarto`, `/review-paper --adversarial`, `/slide-excellence`, `/create-lecture`, `/data-analysis`, `/review-paper --peer`), not a runtime daemon. Plan approval does NOT auto-trigger the 6-step loop. User invokes a skill; skill runs the loop internally.

[LEARN:framing] Cross-artifact review is **pattern-based detection**, not universal auto-invocation. If the manuscript has no `\input{scripts/...}` signals or sibling `scripts/*/` directory, no cross-artifact work happens. Document detection signals explicitly.

[LEARN:framing] "Quality gates" is overselling when the only enforcement is inside `/commit` (halt-and-ask, not block). A direct `git commit` bypasses the review unless the user has installed `.githooks/pre-commit` via `./scripts/install-hooks.sh`. Use "quality review" or add an "(advisory)" qualifier in docs that promise more.

---

## Project Learnings — Foreign Aid Competition Dissertation

*New `[LEARN]` entries from this dissertation work go here. Most recent at bottom.*

[LEARN:workflow] (2026-06-15, kickoff) Plan-first → contractor mode after approval. Throttle check-ins down once the user calibrates to the workflow (~5 sessions in). Until then, prefer one extra check-in over guessing on substantive decisions.

[LEARN:visuals] (2026-06-15, kickoff) Figures + tables for this dissertation must be **publication-ready by default** — no draft-quality intermediates. Vector PDF for manuscript inclusion; a single consistent ggplot2 theme across the whole monograph (theme TBD on first figure).

[LEARN:framing] (2026-06-15, interview) The dissertation is a **monograph** (single-argument book), NOT a 3-paper hybrid. The old `Papers/paper{1,2,3}_TODO/` scaffold was retired; the repo is now `Dissertation/` with `chapters/` + `analyses/NN_*/`. The `analyses/NN_*/` folders are a working-style scaffold that maps onto empirical chapters — they are compartmentalized R pipelines, not separate manuscripts. Qualitative case chapters (Ethiopia, Peru, Bangladesh) were dropped, shifting the full empirical burden onto Ch 4 (quant). See `quality_reports/decisions/2026-06-15_monograph-drop-cases.md`.

[LEARN:data] (2026-06-15, interview) The Dec 2024 prospectus reports **+0.113 in Africa** for the US↔China aid relationship (a **regression coefficient**, not a Pearson correlation), positive there vs. negative elsewhere — read as aid race in Africa, aid withdrawal elsewhere. If any off-hand statement claims the effect is negative in Africa (an easy inversion to make), correct it against this before proceeding.

[LEARN:data] (2026-08-06, /data-analysis) **The +0.113 does NOT reproduce on GCDF 3.0 + `us_oda_commits_70_22.csv`.** Faithful reimplementation of the user's own script — `feols(log(us_aid+1) ~ log(china_lag+1) | Year + iso3c)` — gives Africa **+0.048** (all official finance, p≈.004) / **+0.005** (ODA-like, ns), and the sign is positive in *most* regions, not negative-except-Africa. The **direction** (positive Africa = aid race) reproduces; the **magnitude/pattern** does not. Likely because the prospectus used **GCDF 2.0** (2000–2017) and/or the original `usa oda commits.csv` (the script shows it was "switched" for the `_70_22` file; not in repo). Per the user (2026-08-06): **proceed on the current vintage**, treat the FE elasticity as the statistic of record, and document +0.113 as a prior-vintage number. Working baseline = GCDF 3.0 + `_70_22`. See `quality_reports/session_logs/2026-08-06_data-analysis-quant-main.md`.

[LEARN:project] (2026-06-15, interview) The advisor is pushing a **predict-and-compare reframe** (fit a pre-China baseline model of US aid, infer China's effect from the M0-vs-M1 predictive gap). Parked as a **side deliverable**, not restructured into — space reserved at `Dissertation/analyses/05_advisor_reframe/` with a `SPEC.md` capture. Do NOT restructure the dissertation around it until the user brings a fuller writeup. See `quality_reports/decisions/2026-06-15_advisor-reframe-parked.md`.

[LEARN:data] (2026-09-14, /data-analysis) **First full run of `01_quant_main` + `04_var_dynamics` against real data — CORRECTED after r-reviewer caught a clustering bug.** An initial pass mis-claimed "SEs clustered by country (fixest default)"; `feols()`'s true no-argument default with two FEs is plain IID, not clustering. Fixed same-session (`vcov = ~iso3c` explicit). **With correct clustering, the region-stratified picture is much noisier**: only Pooled ($0.087$, $p=.004$) and Europe ($0.493$, $p=.011$) are significant for the all-official-finance measure; Americas is marginal ($p=.084$); **Africa is NOT significant** ($0.048$, $p=.328$) — a materially different conclusion from the pre-fix IID-SE run, which had shown Africa/Oceania as significant. Point estimates unchanged by the fix (clustering only affects SEs); only significance calls changed. Africa's positive point estimate still doesn't match the prospectus's $+0.113$ magnitude, and now isn't even distinguishable from zero — so the vintage discrepancy is *larger* than the 2026-08-06 entry suggested, not smaller. Europe/Oceania cluster on only 11 countries each — below the conventional 20–50 minimum for cluster-robust asymptotics, so read those significance calls cautiously too. **Also this session:** the bivariate panel VAR (system GMM, 2000–2021, 150 countries) finds NO significant lagged cross-donor effect in either direction (US→China lag $-0.075$, $p=.56$; China→US lag $-0.013$, $p=.40$) — each series driven by its own persistence, model stable, but the **Hansen overidentification test rejects** ($\chi^2(28)=100.22$, $p<.001$), so read as suggestive not confirmed. Full writeup in `Dissertation/chapters/ch04_quant_main.tex` §4.3–4.4 and `quality_reports/session_logs/2026-09-14_data-analysis-run.md`.

[LEARN:data] (2026-09-14, same day, follow-up — CORRECTED after r-reviewer's second pass) **Re-operationalized "sphere of influence" via UN-alignment data instead of continent — the result contradicts H1's predicted pattern, not just weakens it, and survives a real bug fix + a robustness switch.** New `soi_bloc` measure: UNGA ideal-point distance from China minus distance from US, terciled **within the ~150-country aid-recipient sample** (not the full ~190-country UN membership — switched after r-reviewer flagged the global-population tercile as a plausible non-bug driver of the finding; checked directly, the pattern survives and *sharpens* under recipient-only terciles, so this became the primary spec) and within year, lagged. **Final numbers** (baseline, all-official-finance): China-aligned $0.013$ ($p=.760$), Contested $0.009$ ($p=.783$), **US-aligned $0.098$ ($p=.005$)** — the ONE clearly significant effect is in the bloc H1 gives no sharp prediction for, not the theoretically-predicted Contested bloc (null) or the predicted-negative China-aligned bloc (also null, drifts negative but not significant in the extended spec). **Two independent, non-overlapping SOI operationalizations (continent, alignment) both fail to recover H1's sign-flip.** Candidate reading (not adjudicated, needs user/advisor judgment): this looks more like *reinforcement of already-secured allies* (led by Turkey, Ukraine, and NATO/EU-accession-track post-Soviet states — not an Israel/Egypt-type idiosyncratic handful; 97 distinct countries pass through the bloc) than *a contest for the uncommitted middle* — a different mechanism than H1 as stated, not a weaker version of it. **A genuine bug was caught and fixed along the way**: the Voeten ideal-point data has 23 duplicate iso3c×Year rows (pre-unification North/South Yemen both coded "YAR", 1967–1989) that could have silently fanned out via `left_join` — verified inert for every number here ("YAR" never matches the recipient panel, which uses "YEM"), fixed at the source anyway (average the duplicate rows) rather than left as a landmine for a future data-vintage swap. Also delivered: `Dissertation/data/china_steel_exports_hs72.csv`, a UN-Comtrade-sourced (not PDF-scraped) China steel-export series for the future IV analysis — the real Dreher/Fuchs/Parks/Strange/Tierney (AEJ:EP 2021) instrument is a 6-material export factor × exposure share, not literally "steel production"; this is a disclosed single-series simplification. Full record: `quality_reports/session_logs/2026-09-14_soi-reoperationalization.md`.

[LEARN:data] (2026-09-15) **Two specification findings that reshape the empirical chapter.** (1) **The full 1970–2022 panel was inflating every elasticity**: GCDF covers only 2000–2021, so Chinese finance is zero for 1970–99 *by construction* (no coverage, not no finance), and those 30 zero-treatment years shape the FEs such that any country whose US aid trended up reads as a China response. Primary sample is now **2000–2021** (user decision) — pooled elasticity 0.087→0.053, pre-frozen US-aligned 0.251→0.082, Europe 0.493→0.229. Country trends kept as **robustness** (they may over-absorb): with trends the pooled estimate is −0.002 (p=.900), so the honest range runs from a modest effect to nothing, and that specification call is the open question that decides whether there is a finding. `04_var_dynamics` was already correctly specified on 2000–2021 — its null now *corroborates* rather than contradicts. (2) **The Dreher et al. steel shift-share IV does not transfer to this design.** With a predetermined 1970–99 exposure share (Bartke) the first stage is dead (F=0.001); power appears only with their *contemporaneous* (study-window) share, which is circular. Reason: the share's predictive content is purely cross-sectional (r=0.44) and country FE absorb it, while China's post-2000 expansion was broad-based — 73% of recipients with no pre-2000 Chinese project got finance anyway — so there is no differential growth to identify from. Separately, ln(steel) is near-monotonic, making the instrument ≈ a country-specific trend, so it cannot even be combined with the trends spec. **Identification remains open.** Full record: `quality_reports/session_logs/2026-09-15_pre-china-baseline.md` and `2026-09-15_iv-robustness.md`.
