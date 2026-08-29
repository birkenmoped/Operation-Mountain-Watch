---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-2-ACCEPTANCE-1
status: PLANNED
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 2 MOOSE class evidence pending DCS Acceptance 1
not_authoritative_for:
  - master PROJECT-CLASS-INDEX status on main
  - DCS runtime validation before Acceptance 1 is executed
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 Acceptance 1 – MOOSE class evidence

## 1. Pinned framework

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 2. Branch-local class status

| Klasse/Pfad | Status vor DCS-Lauf | Stage-2-Verwendung |
|---|---|---|
| `BASE` | `SOURCE_REVIEWED` / acceptance staged | `BASE:New()`, `HandleEvent(EVENTS.Hit, ...)`, `UnHandleEvent(EVENTS.Hit)` für den MOOSE-first Hit-Listener |
| `EVENTS.Hit` | `SOURCE_REVIEWED` / acceptance staged | realer RED-on-BLUE Treffer am explizit registrierten Fortress-Testziel |
| `SCHEDULER` | bereits anderweitig `VALIDATED_FOR_DOCUMENTED_SCOPE`; neuer Stage-2-Scope noch nicht validiert | langsame 2-s Acceptance-Auswertung nach beobachteten Hit-Ereignissen; kein World-/Frame-Scan |

Keine Statusanhebung auf `VALIDATED_FOR_DOCUMENTED_SCOPE` erfolgt durch Source oder CI allein.

## 3. Negative Grenze

Nicht verwendet:

```text
world.addEventHandler
MIST
native timer.scheduleFunction
AUFTRAG:NewCAS
COMMANDER:AddMission
AIRWING/SQUADRON dispatch
```

## 4. Reconciliation

Nach realem Acceptance-1-Lauf mit vollständiger Provenienz wird dieser Addendum-Stand entweder:

```text
PASS -> in docs/moose/PROJECT-CLASS-INDEX.md und VERIFIED-METHODS.md für den exakt getesteten Scope reconciled
FAIL -> keine Statusanhebung; Fehler und erforderliche Korrektur werden dokumentiert
```
