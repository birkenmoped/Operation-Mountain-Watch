---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-2-ACCEPTANCE-2-ACTIVE-GROUND-ADDENDUM
status: BINDING
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - accepted Stage 2B Fortress active Guard MOOSE API evidence
  - accepted Stage 2B deterministic multi-QRF MOOSE API evidence
not_authoritative_for:
  - production-wide QRF force-size doctrine
  - perfect DCS infantry pathfinding through arbitrary installation statics
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
validated_in_dcs: true
---

# Stage 2B active Ground response – MOOSE class-index addendum

Pinned framework:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Accepted APIs

| Klasse/API | Accepted use |
|---|---|
| `PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)` | seven available QRF asset groups from the existing 9-person template for the acceptance pool |
| `AUFTRAG:NewONGUARD(...)` | Fortress Guard readiness/security mission |
| `AUFTRAG:SetEngageDetected(...)` | native MOOSE detected-Ground-target response configured for the Guard |
| `ARMYGROUP:EngageTarget(...)` | native active engagement path underlying detected-target response |
| `AUFTRAG:NewGROUNDATTACK(...)` | one concrete QRF mission per assigned RED group |
| `COHORT/PLATOON:CountAssets(true, AUFTRAG.Type.GROUNDATTACK)` | physical QRF availability bound |

MOOSE itself uses `ONGUARD + SetEngageDetected` in its strategic path, so this is not an OMW parallel attack implementation.

## Multi-QRF contract

```text
min(
  alive RED groups in OPSZONE,
  available GROUNDATTACK-capable assets,
  CampaignState 9-person slots above reserve floor 80,
  cap 7
)
```

Target ordering:

```text
nearest to Fortress
-> stable group-name tie-break
```

Final DCS run:

```text
redGroups=3
availableAssets=7
strategicSlots=7
dispatchGroups=3
QRF-1 -> Ground-3 -> 751 m
QRF-2 -> Ground-1 -> 778 m
QRF-3 -> Ground-2 -> 878 m
```

All three QRFs materialized and all three later reached origin return. Two Ground-Attack missions ended `success`, one `failed`; Stage 2B acceptance does not redefine MOOSE mission-result semantics.

## Guard boundary

The final run confirmed Guard materialization and `SENTRY_ONGUARD_EXECUTING ... activeResponse=MOOSE_SET_ENGAGE_DETECTED`. A final Guard `Returned` callback was not observed before mission shutdown. The owner explicitly accepted the residual Guard/HESCO pathfinding observation as non-blocking for this Stage 2B PASS.

Exact provenance: `../../mission/tests/fob-attack-support-demand/RESULT-2.md`.