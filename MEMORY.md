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

[LEARN:data] (2026-06-15, interview) **Africa is the ONLY region with a positive US↔China aid correlation (+0.113)**; correlations are negative outside Africa. Both signs support the theory (aid race in Africa, aid withdrawal elsewhere). Confirmed against the Dec 2024 prospectus (Appendix Table 1). If any off-hand statement claims the correlation is negative in Africa (an easy inversion to make), correct it against this number before proceeding.

[LEARN:project] (2026-06-15, interview) The advisor is pushing a **predict-and-compare reframe** (fit a pre-China baseline model of US aid, infer China's effect from the M0-vs-M1 predictive gap). Parked as a **side deliverable**, not restructured into — space reserved at `Dissertation/analyses/05_advisor_reframe/` with a `SPEC.md` capture. Do NOT restructure the dissertation around it until the user brings a fuller writeup. See `quality_reports/decisions/2026-06-15_advisor-reframe-parked.md`.
