---
document_id: OMW-STAGE-2B-FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - exact-provenance Stage 2B Fortress automatic-response acceptance
  - Fortress CAS valley-route execution and completion
  - Fortress active Guard configuration and deterministic multi-QRF response
  - native MOOSE QRF return-to-origin and CampaignState settlement evidence
not_authoritative_for:
  - installations other than Fortress
  - production-wide QRF sizing doctrine
  - perfect DCS infantry pathfinding through arbitrary HESCO layouts
  - proof of GUARD_RETURNED_ORIGIN in the final run
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local passive-Guard and exactly-one-QRF Stage 2B plan
  - branch-local explicit ACCESS RTZ default-return plan
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
acceptance_branch: agent/fob-attack-support-demand
acceptance_commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
acceptance_mission: OMW_Template_v20_GroundWorks(20260830-132050).miz
acceptance_mission_sha256: 28fe4ab40f54ceb48fa5428c0e5e2daf2874f6f61213c964a317434087f413cc
dcs_version: 2.9.29.27278
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
validated_in_dcs: true
---

# Stage 2B – Fortress full automatic-response Acceptance 2

## Ergebnis

```text
PASS
```

Der Projektinhaber schloss den realen DCS-Lauf vom 30.08.2026 ausdrücklich als PASS. Die technische Acceptance gilt ausschließlich für die dokumentierte Fortress-Komposition und Provenienz.

## Finaler Build

```text
Tested source commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
BuilderVersion: FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-6
Acceptance Lua: OMW_FOB_Attack_CAS_Dispatch_Acceptance_2.lua
Bundle SHA-256: AB696D8E9CEBACD3A402E34DA016773046181E998318214C2198A9915E396C7B
Mission: OMW_Template_v20_GroundWorks(20260830-132050).miz
Mission SHA-256: 28FE4AB40F54CEB48FA5428C0E5E2DAF2874F6F61213C964A317434087F413CC
Embedded bundle SHA-256: AB696D8E9CEBACD3A402E34DA016773046181E998318214C2198A9915E396C7B
DCS: 2.9.29.27278
MOOSE: 2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 062B83B61C02E7F7A93CF260540588F6849819E74CF1DC20F406EDF17C170EE2
debrief.log SHA-256: 4863E4B945E3B8F4719E081A18A56737E74989A414CBEB05B62793C53CE605F8
```

## Accepted chain

```text
Fortress BLUE local security
-> runtime MOOSE OPSZONE threat
-> CAS_IMMEDIATE
-> Jalalabad AH-64D CAS
-> OMW_FlightPath outbound
-> Fortress CAS
-> local Guard/QRF response
-> OPSZONE Defeated(RED)
-> CAS closure
-> reverse OMW_FlightPath
-> Jalalabad RTB / Landed / Arrived
```

## Guard

```text
AUFTRAG:NewONGUARD(...)
+ AUFTRAG:SetEngageDetected(..., {"Ground Units"})
```

This uses the native MOOSE ARMYGROUP engagement lifecycle. The final log confirms Guard materialization, ONGUARD execution with `MOOSE_SET_ENGAGE_DETECTED`, and mission-close request after Threat Clear. A final `GUARD_RETURNED_ORIGIN` was not logged before mission end; the owner accepted the residual Guard/HESCO observation as non-blocking for this Stage 2B acceptance.

## QRF

The artificial one-QRF limit was removed. Dispatch is bounded by:

```text
alive RED groups
available GROUNDATTACK-capable assets
CampaignState slots above PERSONNEL reserve floor 80
acceptance cap 7
```

Targets are sorted nearest-first with stable group-name tie-break, and each dispatched QRF receives its own `AUFTRAG:NewGROUNDATTACK(...)` mission.

Final runtime:

```text
redGroups=3
availableAssets=7
strategicSlots=7
dispatchGroups=3

QRF-1 -> Ground-3 -> 751 m
QRF-2 -> Ground-1 -> 778 m
QRF-3 -> Ground-2 -> 878 m
```

All three QRFs materialized. Two Ground-Attack missions ended `success`, one ended `failed`; all three QRF groups nevertheless completed native return to the Fortress origin Warehouse and were settled individually.

## CAS valley route

The final run confirms:

```text
CAS_CORRIDOR_INSTALLED
corridorPoints=14
outboundWaypoints=14
returnWaypoints=13
altitudeFtAGL=500
```

The owner visually confirmed both outbound and return valley transit. The lifecycle then reached `CAS_RTB`, `CAS_LANDED`, and `CAS_ARRIVED` at Jalalabad.

## Ground return

The accepted QRF return uses normal MOOSE origin semantics:

```text
ReturnToLegion default true
-> origin Legion spawnzone
-> Warehouse WH_BLUE_GND_FORTRESS spawn zone
-> Returned
-> origin Warehouse AddAsset
```

No `SetReturnToLegion(false)`, explicit `ARMYGROUP:RTZ(...)`, `WAREHOUSE:SetSpawnZone(...)` override or teleport is used in the accepted Fortress QRF path.

## CampaignState

Deployment is reservation, not consumption. Confirmed casualties alone permanently reduce strategic quantity. Each QRF has a separate settlement identity and releases its reservation exactly once on return/loss settlement.

## Accepted limitation

The final screenshots showed some BLUE soldiers still navigating around Fortress HESCOs after combat. Because all three QRFs had already reached `QRF_RETURNED_ORIGIN` while the Guard had not produced `GUARD_RETURNED_ORIGIN`, the Guard is the most likely dynamic source. The owner explicitly accepted this residual observation as a non-blocking DCS Ground-AI/pathfinding limitation for Stage 2B.

Detailed result: `RESULT-2.md`.
