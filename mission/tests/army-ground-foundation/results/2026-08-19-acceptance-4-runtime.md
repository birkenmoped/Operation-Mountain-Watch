---
document_id: OMW-RESULT-ARMY-GROUND-ACCEPTANCE-4-RUNTIME-20260819
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact Acceptance 4-2 Fenty MOOSE return-handoff runtime evidence
not_authoritative_for:
  - CampaignState settlement or strategic resource credit
  - production return policy or cross-session reconstitution
  - other MOOSE, DCS or MIZ versions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: ec66a29ddbd234d07f28d174a7725e4331cc31a6
validated_in_dcs: true
acceptance_branch: agent/army-ground-foundation-reconciliation
acceptance_commit: ec66a29ddbd234d07f28d174a7725e4331cc31a6
acceptance_mission: OMW_Template_v13_ground_test(20260819-200418).miz
acceptance_mission_sha256: 1564001e9aa524217a9142c35977d5cf9c0d4e8b2765c1de351ecb31a7edf3e2
internal_mission_sha256: c0b26f5af717d9db0c60551b06544348eb58d7597bf8917cdb3989f97c3cc4b7
embedded_bundle_sha256: 643637683e7e161584d5b1dbcc16b87a6691b2f32a6ae4e101229da1d35af5bd
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
supersedes:
superseded_by:
---

# ARMY Ground Acceptance 4 – Runtime-Ergebnis 19.08.2026

## Ergebnis

~~~text
PASS for documented Fenty mobile return-handoff scope
OWNER VISUAL ACCEPTANCE: PASS
CAMPAIGNSTATE SETTLEMENT: NOT TESTED / NOT CHANGED
~~~

Acceptance 4-2 bestätigt für die exakte Provenienz:

~~~text
road-aligned WAREHOUSE/BRIGADE materialization
-> ARMOREDGUARD On Road outbound
-> MissionDone with physical group retained
-> 30-second AUFTRAG settlement delay
-> public ARMYGROUP:RTZ(ZON_BLUE_GND_FENTY_ACCESS, OnRoad)
-> Returning
-> Returned
-> LEGION:__AddAsset(10, group, 1)
-> WAREHOUSE AddAsset
-> controlled temporary DCS-group removal
~~~

## Provenienz

~~~text
Branch: agent/army-ground-foundation-reconciliation
Embedded bundle source commit: ec66a29ddbd234d07f28d174a7725e4331cc31a6
BuilderVersion / Test-ID: ARMY-GROUND-ACCEPTANCE-4-2
Embedded Acceptance-4 bundle SHA-256: 643637683e7e161584d5b1dbcc16b87a6691b2f32a6ae4e101229da1d35af5bd
Mission artifact: OMW_Template_v13_ground_test(20260819-200418).miz
MIZ SHA-256: 1564001e9aa524217a9142c35977d5cf9c0d4e8b2765c1de351ecb31a7edf3e2
Internal mission SHA-256: c0b26f5af717d9db0c60551b06544348eb58d7597bf8917cdb3989f97c3cc4b7
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
~~~

Die MIZ, das interne mission-Mitglied und das eingebettete Bundle wurden am hochgeladenen Owner-Artefakt read-only gehasht. Der eingebettete Bundle-Hash stimmt mit dem lokalen Builder-Output überein.

## Reale Runtime-Sequenz

Im DCS-Lauf wurden folgende Acceptance-Marker protokolliert:

~~~text
18:42:50  START testId=ARMY-GROUND-ACCEPTANCE-4-2
18:48:42  MISSION1_DONE physicalGroupRetained=true returnSettlementDelaySec=30
18:48:59  AUFTRAG Mission success
18:49:12  RETURN_RTZ_ACTIVE zone=ZON_BLUE_GND_FENTY_ACCESS formation=OnRoad
18:49:12  RETURN_RTZ_ISSUED state=Returning
18:49:17  RETURN_IN_PROGRESS state=Returning
18:55:57  RETURNED_HANDOFF
18:55:58  WAREHOUSE_ADD_ASSET
18:55:58  SITE_RUNTIME_PASS spawnCount=1 returnedCount=1 warehouseAddAssetCount=1 physicalGroupRemoved=true
18:55:58  RUNTIME_PASS_VISUAL_PENDING sites=1 passed=1
~~~

Der Test lief bis mission_time = 1094.362 s; der 900-s-Return-Timeout wurde nicht ausgelöst. Im ausgewerteten Acceptance-Pfad liegt kein OMW_GND_A4 FAIL vor.

## Visuelle Abnahme

Der Projektinhaber hat beobachtet und akzeptiert:

- vier M-ATV materialisieren road-aligned und fahren normal aus dem Fenty-Bereich;
- die Gruppe kehrt road-aligned zur bestehenden Fenty-ACCESS-Zone zurück;
- kein Teleport während Materialisierung, Anfahrt oder Rückfahrt;
- nach Ankunft und Returned -> AddAsset verschwinden die Einheiten sichtbar und erwartungsgemäß als temporäre DCS-Repräsentation.

Diese sichtbare, erst nach Ankunft ausgelöste Entfernung ist der erwartete MOOSE-Warehouse-Handoff, kein Fehler und keine strategische Gutschrift.

## Acceptance-Grenze

Dieser technische Baseline-Nachweis gilt nur für den dokumentierten mobilen Fenty-Rückgabepfad. Nicht bestätigt und bewusst offen bleiben:

~~~text
CampaignState exactly-once settlement or strategic credit
production return policy
cross-session reconstitution
loss handling
multi-site return
OPSTRANSPORT
Fortress/Honaker quantity decisions
merge to main or Ready-for-Review
~~~
