---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-1-RUNTIME-20260818
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - ARMY Ground Acceptance 1 result for the exact documented provenance
not_authoritative_for:
  - general production vehicle patrol behavior
  - other missions, MOOSE builds or DCS versions
  - restart/reconstitution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
validated_in_dcs: true
acceptance_branch: agent/army-ground-foundation-reconciliation
acceptance_commit: 1e5218cb38dd1db05a0bcf335cf9d00cf2693384
acceptance_mission: OMW_Template_v13_ground_test.miz
acceptance_mission_sha256: fde9e4d7e0e1eb6a9c32c0de5efa02c26ca3afd498c8948ee11bdb4ca0e49b13
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
supersedes:
superseded_by:
---

# ARMY Ground Acceptance 1 – Runtime-Ergebnis 18.08.2026

## Ergebnis

```text
PASS for documented lifecycle scope
PATHFINDING / ACCESS QUALITY NOTE OPEN
PATROLZONE NOT APPROVED AS PRODUCTION VEHICLE PATROL BEHAVIOR
```

Acceptance 1 bestätigt für die exakte Provenienz den kleinsten MOOSE-first Ground-Lifecycle:

```text
BRIGADE startup
-> one PLATOON asset available
-> exactly one physical ARMYGROUP materialized
-> PATROLZONE mission executed
-> AUFTRAG cancellation
-> MissionDone
-> SetReturnToLegion(false) preserved physical group
-> same physical ARMYGROUP reused for follow-up mission
-> no duplicate materialization
```

## Provenienz

```text
Branch:
agent/army-ground-foundation-reconciliation

Acceptance source commit embedded in runtime bundle:
1e5218cb38dd1db05a0bcf335cf9d00cf2693384

Mission filename in DCS/debrief:
OMW_Template_v13_ground_test.miz

Uploaded artifact alias:
OMW_Template_v13_ground_test(1).miz

Final MIZ SHA-256:
fde9e4d7e0e1eb6a9c32c0de5efa02c26ca3afd498c8948ee11bdb4ca0e49b13

Internal mission SHA-256:
c24d4a71c69faa64cfa8b750c24312431c84325abc9c08d294ea6af7130df7aa

Embedded Acceptance-1 bundle SHA-256:
e227ac0d8e9647d1ca56d0e8c14919d0be8ba6e6ca38cbc291a077643170c8b4

DCS log SHA-256:
29489621f24e55257187e663c42fa3b7b8b0a94817058e532fcee2f978520a06

Debrief log SHA-256:
3290c48ec590644dfa08062e24828e48afcd0b17fc70640e410dfa324bd1faa6

DCS:
2.9.28.26385 MT

MOOSE:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der frühere lokale Pre-Embed-Build mit Commit `72d8cc5...` erzeugte SHA-256 `e49c02e5...`. Dieser Hash ist **nicht** der finale embedded Runtime-Bundle-Hash, weil nach dem anschließenden Pull/Build der generierte Header Commit/Zeitstempel enthielt. Für die DCS-Acceptance ist die oben dokumentierte finale embedded Hashkette maßgeblich.

## Runtime-Marker

Der reale `dcs.log` enthielt die erwartete Reihenfolge:

```text
OMW_GND_A1 START testId=ARMY-GROUND-ACCEPTANCE-1-1
OMW_GND_A1 WAREHOUSE_RESOLVED WH_BLUE_GND_JOYCE
OMW_GND_A1 TEMPLATE_RESOLVED TPL_BLUE_GND_PATROL_MATV_4
OMW_GND_A1 ACCESS_ZONE_RESOLVED ZON_BLUE_GND_JOYCE_ACCESS
OMW_GND_A1 PATROL_ZONE_RESOLVED ZON_BLUE_GND_JOYCE_PATROL_TEST_01
OMW_GND_A1 BRIGADE_STARTED BDE_BLUE_GND_JOYCE
OMW_GND_A1 PLATOON_READY assets=1
OMW_GND_A1 MISSION1_QUEUED reservation=COMMITTED
OMW_GND_A1 GROUP_MATERIALIZED PLT_BLUE_GND_JOYCE_PATROL_AID-211
OMW_GND_A1 MISSION1_CANCEL_SCHEDULED delaySec=120
OMW_GND_A1 MISSION1_DONE reservation=FIELD_DEPLOYED
OMW_GND_A1 GROUP_STILL_ALIVE PLT_BLUE_GND_JOYCE_PATROL_AID-211
OMW_GND_A1 MISSION2_QUEUED reservation=FIELD_DEPLOYED
OMW_GND_A1 SAME_GROUP_REUSED PLT_BLUE_GND_JOYCE_PATROL_AID-211
OMW_GND_A1 PASS reservation=FIELD_DEPLOYED spawnCount=1
```

Damit ist insbesondere bestätigt:

```text
one asset selected
one materialization
same ARMYGROUP survives MissionDone
same ARMYGROUP receives follow-up mission
spawnCount remains 1
```

## Visuelle Beobachtung des Projektinhabers

Der Projektinhaber berichtete:

```text
- vor dem eigentlichen Abmarsch fuhr die Gruppe einige kleinere Runden im Spawn-/ACCESS-Bereich;
- anschließend sah die Fahrt im Convoy normal aus;
- im PATROLZONE-Zielgebiet fuhr die Gruppe erwartungsgemäß weiter umher;
- nach einiger Zeit parkte/stand die Gruppe;
- kein sichtbarer Teleport, Despawn oder zweites Fahrzeugset wurde berichtet.
```

Die initialen kleinen Runden waren **kein** geplanter Guard-Auftrag. Sie werden als offene Ground-AI-/ACCESS-/Routing-Quality-Note geführt.

Das Umherfahren im Zielgebiet war dagegen eine direkte Folge des bewusst für Acceptance 1 verwendeten `PATROLZONE`-Verhaltens. Dieses Verhalten ist technisch für den Lifecycle-Test akzeptiert, aber für eine vier Fahrzeuge starke OMW-Mounted-Patrol optisch/taktisch nicht als Production-Standard akzeptiert.

## Acceptance-Grenze

`ACCEPTED_TECHNICAL_BASELINE` gilt hier ausschließlich für:

```text
BRIGADE / PLATOON startup and asset selection
single materialization
AUFTRAG lifecycle through cancellation and MissionDone
SetReturnToLegion(false) live-session field persistence
same physical ARMYGROUP follow-up reuse
no duplicate materialization in the tested sequence
```

Nicht validiert:

```text
PATROLZONE as production mounted-patrol behavior
clean ACCESS departure without circling
ARMOREDGUARD / tactical halt formation
per-vehicle sectors
return to Warehouse
restart/reconstitution
OPSTRANSPORT
QRF
CampaignState production adapter
multiplayer behavior
```

Diese offenen Punkte werden ab Acceptance 2 getrennt geprüft.
