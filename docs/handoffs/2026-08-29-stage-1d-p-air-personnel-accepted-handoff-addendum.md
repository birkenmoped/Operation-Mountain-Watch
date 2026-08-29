---
document_id: OMW-HANDOFF-STAGE-1D-P-AIR-PERSONNEL-ACCEPTED-2026-08-29
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DEVELOPMENT_HANDOFF_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1D-P Air PERSONNEL closure
  - continuation order after accepted Stage 1D-P Air lifecycle
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Stage 1D-P STAGED status in OMW-HANDOFF-AUTOMATIC-RESPONSE-ORCHESTRATION-CONTINUATION-2026-08-29
superseded_by:
source_branch: agent/automatic-response-orchestration-continuation
source_commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
validated_in_dcs: true
acceptance_branch: agent/automatic-response-orchestration-continuation
acceptance_commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
acceptance_mission: OMW_Template_v20_GroundWorks.miz
acceptance_mission_sha256: 3B93F9817379BA6C66C8C02DD2142D1EDA3D88090CB8FC88973D4DAC45EE6B11
dcs_version: 2.9.29.27278 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# Stage 1D-P Air PERSONNEL – Accepted Handoff Addendum

## 1. Finaler Stage-Status

```text
Stage 1D-P strategic PERSONNEL contract: accepted for documented branch scope
Stage 1D-P Ground PERSONNEL carrier path: inherited accepted NOTHING/RTZ mechanics
Stage 1D-P Air PERSONNEL Jalalabad -> Fortress: ACCEPTED_TECHNICAL_BASELINE
```

Exact Air acceptance provenance:

```text
source/builder commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
builder: AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4-1
bundle SHA-256: C2BD325AF48BF6EA08936BCA666E4460293B60CC36FB8FE0181BC5140DF9ABD3
mission: OMW_Template_v20_GroundWorks.miz
mission SHA-256: 3B93F9817379BA6C66C8C02DD2142D1EDA3D88090CB8FC88973D4DAC45EE6B11
DCS: 2.9.29.27278 MT
MOOSE: 2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
runtime: PASS
```

## 2. Accepted Air PERSONNEL lifecycle

```text
PERSONNEL shortage strictly below 80%
-> MissionDemand RESUPPLY
-> CampaignState reserve/transfer Jalalabad -> Fortress
-> Jalalabad CH-47 AIRWING/SQUADRON asset
-> AUFTRAG LANDATCOORDINATE
-> OMW_FlightPath outbound
-> physical Fortress landing / 30 s dwell
-> matching MOOSE TaskDone near Fortress LZ
-> exact-once CampaignState MarkDelivered
-> MissionDemand SUCCESS
-> physical return corridor
-> Jalalabad OnAfterLanded
-> LegionAssetReturned
-> PASS
```

## 3. Decisions that must not be reopened without new evidence

```text
CampaignState is sole strategic PERSONNEL authority.
Ordinary PERSONNEL resupply is abstract headcount; no physical Infantry GROUP cargo required.
TROOPTRANSPORT remains separate tactical Infantry GROUP deployment scope.
Fortress intermediate landing uses a normal LZ trigger-zone/coordinate, not a foreign FARP/AIRBASE.
LegionAssetReturned alone is not physical RTB proof.
MissionDone is not LANDAT delivery instant when mission egress exists.
Second Takeoff is not mandatory PERSONNEL delivery authority.
TaskDone for the exact LANDAT task near the destination LZ is the accepted settlement signal.
OMW_FlightPath is the preferred valley centerline, not a hard geographic constraint.
Nominal lane is 500 m right of travel direction; this acceptance uses OMW runtime calibration heading +90 degrees.
No hard Air travel timeout.
No native DCS routing/event parallel implementation.
No MIST.
```

## 4. Mission artifact verification

The owner-supplied final `.miz` was inspected read-only. The embedded Acceptance-4 bundle hash exactly matches the locally built acceptance bundle. The embedded pinned Moose.lua and the current AirOps Warehouse/Ground base hashes also match the documented runtime artifacts.

No additional DCS repetition is required for this exact technical path.

## 5. Continuation order

The previous continuation handoff listed Stage 1D-P as the current gate. That gate is now closed for the documented scope.

Next planned development item remains:

```text
Stage 1D-V  VEHICLE source/design reconciliation
```

After that, retain the previously documented sequence for automatic-response orchestration unless a newer owner decision changes it.

Primary final evidence:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md
docs/moose/PROJECT-CLASS-INDEX-STAGE-1D-P-ACCEPTANCE-4.md
docs/moose/VERIFIED-METHODS-STAGE-1D-P-ACCEPTANCE-4.md
```
