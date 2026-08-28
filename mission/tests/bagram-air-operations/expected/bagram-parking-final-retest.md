---
document_id: OMW-TEST-BAGRAM-PARKING-FINAL-RETEST
status: PLANNED
document_class: DCS_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - final repeat run after ALERT5 recruitment-capability harness failure
  - physical Bagram parking materialization acceptance for all seven SQUADRONs
not_authoritative_for:
  - tactical mission completion
  - taxi, takeoff, landing or recovery behavior
  - persistence or CampaignState settlement
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/bagram-parking-policy-integration
source_commit: GIT_HISTORY
acceptance_branch: agent/bagram-parking-policy-integration
acceptance_commit: PENDING_RETEST_DCS_RUN
acceptance_mission: OMW_Template_v20_BGRM_Parking_Correlation_1.miz
acceptance_mission_sha256: PENDING_RETEST_MIZ_GATE
dcs_version: PENDING_RETEST_DCS_RUN
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
---

# Bagram Final Parking Retest

## Anlass

Der erste finale Materialisierungslauf vom 28.08.2026 war `FAIL`, obwohl alle Parking- und Foundation-Gates bestanden. Der DCS-Log zeigte:

```text
PARKING_POLICY_POSTSTART status=PASS assetsChecked=69 expectedAssets=69 failed=0 lifecycle=WAREHOUSE_NEWASSET
PARKING_RUNTIME_BASELINE status=PASS candidates=187 runtimeParkingSpots=187 runtimeUniqueTerminalIDs=187 runtimeDuplicateIDs=0 missingCandidates=0 unexpectedRuntimeIDs=0
OBJECT_CONTRACT status=PASS warehouseUSAF=true warehouseArmy=true squadrons=7 policyIDs=44 foundationAssets=69 foundationParkingChecked=69 foundationParkingFailed=0 airwingsRunning=true templateFailures=0
DISPATCH_BATCH status=QUEUED requested=7 expected=7
BAGRAM_PARKING_FINAL_RESULT status=FAIL reason=TIMEOUT_120S foundationAssets=69 foundationParkingChecked=69 foundationParkingFailed=0 dispatchRequested=7 groupsMaterialized=0 unitsMaterialized=0 unitsParkingChecked=0 unitsInOwnPool=0 crossPoolViolations=0 blacklistViolations=0 unknownParking=0 unexpectedMissions=0 groupFailures=0
```

Der Lauf widerlegt damit weder TerminalID-Korrelation noch Parking-Pools noch die Propagation auf 69/69 Assets. Er scheiterte am Materialisierungs-Harness.

## Source-verifizierte Ursache

Im gepinnten `Moose.lua` ruft `LEGION:RecruitAssetsForMission()` auf:

```text
LEGION.RecruitCohortAssets(Cohorts, Mission.type, Mission.alert5MissionType, ...)
```

Für `AUFTRAG:NewALERT5(...)` ist `Mission.type == AUFTRAG.Type.ALERT5`. `LEGION.RecruitCohortAssets()` prüft zuerst `_CohortCan(cohort, MissionTypeRecruit, ...)`. Damit muss der SQUADRON/COHORT `AUFTRAG.Type.ALERT5` als Mission-Capability besitzen. Für Stock-Assets muss außerdem ein für ALERT5 geeigneter Payload vorhanden sein.

Der gepinnte MOOSE-Source zeigt dieselbe Paarung in offiziellen Framework-Beispielen:

```lua
Squadron:AddMissionCapability({ AUFTRAG.Type.ALERT5, ... })
Airwing:NewPayload(..., { AUFTRAG.Type.ALERT5, ... }, ...)
```

Der vorherige Harness erzeugte zwar `AUFTRAG:NewALERT5(...)`, ergänzte aber weder SQUADRON- noch Payload-Capability für ALERT5. Deshalb wurden sieben Missionen gequeued, aber kein Stock-Asset rekrutiert oder materialisiert.

## Korrektur

Die produktive Bagram-Foundation wird nicht verändert. Der Retest ergänzt ausschließlich testseitig über öffentliche MOOSE-APIs:

```lua
squadron:AddMissionCapability({ AUFTRAG.Type.ALERT5 })
airwing:NewPayload(seed, -1, { AUFTRAG.Type.ALERT5, operationalMissionType }, 100)
```

Das geschieht für alle sieben SQUADRONs vor dem vorhandenen finalen Dispatch-Harness.

Neue Quellen:

```text
mission/tests/bagram-air-operations/src/OMW_Bagram_Parking_Final_Retest_Alert5.lua
tools/build-bagram-parking-final-retest.ps1
```

Builder/Test:

```text
BuilderVersion: BGRAM-PARKING-FINAL-ACCEPTANCE-2
TestId: BAGRAM-PARKING-FINAL-ACCEPTANCE-1-RETEST-1
```

## Pflichtmarker

Vor Dispatch:

```text
ALERT5_TEST_PREP_ENTRY status=PASS ...
ALERT5_TEST_PREP status=PASS squadrons=7 payloads=7 mode=TEST_ONLY_PUBLIC_MOOSE_API
```

Danach bleiben alle bisherigen Gates verbindlich. Der finale PASS lautet weiterhin:

```text
BAGRAM_PARKING_FINAL_RESULT status=PASS reason=ALL_GATES_PASS foundationAssets=69 foundationParkingChecked=69 foundationParkingFailed=0 dispatchRequested=7 groupsMaterialized=7 unitsMaterialized=9 unitsParkingChecked=9 unitsInOwnPool=9 crossPoolViolations=0 blacklistViolations=0 unknownParking=0 unexpectedMissions=0 groupFailures=0
```

## Abschluss

Nur dieser positive Materialisierungsnachweis schließt den Parking-Branch technisch ab. Bei PASS werden Ergebnisbericht, README und zentrale MOOSE-Dokumentation synchronisiert und der Branch anschließend zur expliziten Merge-Entscheidung des Projektinhabers vorbereitet.
