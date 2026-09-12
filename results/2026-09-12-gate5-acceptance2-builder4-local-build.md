---
document_id: OMW-RESULT-GATE5-ACCEPTANCE2-BUILDER4-LOCAL-BUILD-2026-09-12
status: BUILD_VERIFIED
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact owner-local Gate-5 Acceptance-2 Builder 4 build evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
validated_in_dcs: false
---

# Gate 5 Acceptance 2 - Builder 4 local build evidence

Der Projektinhaber hat nach der Korrektur der falschen Guard-ACCESS-Abhängigkeit den aktuellen Acceptance-2-Stand real lokal gebaut.

Owner-Korrektur, die für diesen Stand gilt:

```text
ZON_BLUE_GND_<SITE>_ACCESS gehört ausschließlich zum Convoy-/Zufahrtsvertrag.
Guard-Materialisierung und Guard-Routing verwenden diese Zonen nicht.
Guard spawn geometry = existing Guard PATHLINE.
Guard movement geometry = existing Guard PATHLINE.
```

Die zuvor kurzfristig erzeugte Zwischenfassung `ACCESS_CENTER_PATHLINE_HEADING` war fachlich falsch und ist nicht zu testen.

Reale lokale Evidenz:

```text
Owner worktree: P:/DCS-DEV/Operation-Mountain-Watch-fire-support-base-gate0
Git HEAD: a7944a995954a962d2a3b33b7a6d4c459d845f1e
BuilderVersion: FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-4
TestId: FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-2
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Formation: Off Road
FormationIntervalM: 2
SpawnAlignment: PATHLINE_FIRST_SEGMENT
GuardAccessZoneDependency: none
Encoding: UTF-8 without BOM
MIZ mutation: false

Bundle SHA-256:
E1CBF5341D608714C912380FA4806D73BFBF42BBE5F2D0E8513298C96555E9DC

Acceptance-2 source SHA-256:
DDADEA6531EA05A31E836EC0AC35319F83673B9AC4B16D2465A9E218E2C1AE36

Builder SHA-256:
BC6A28F1D167BB4DF768D8FB3F6FAAE60468B7111C77313BCE9715E1186D4D59
```

Der zuvor in einer Chat-Anweisung genannte Pfad `P:/DCS-DEV/Operation-Mountain-Watch` existiert auf der Owner-Workstation nicht. Der tatsächliche Worktree ist `P:/DCS-DEV/Operation-Mountain-Watch-fire-support-base-gate0`.

Status:

```text
Builder 4 owner-local build: PASS
Artifact provenance: verified by real owner output and hashes
DCS runtime for Builder 4: pending
```
