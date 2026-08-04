---
document_id: OMW-TEST-TKOT-MAIN-SYNC-G8-STATIC-PASS-2026-08-05
status: ACCEPTED_STATIC_BASELINE
document_class: STATIC_VALIDATION_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - current Tarinkot gate status after central lifecycle merge
  - Tarinkot synchronization with the merged central AirOps lifecycle baseline
  - post-merge G7 static revalidation
  - G8 UH-60 native vertical-dispatch static validation
  - remaining Mission Editor and artifact gates before DCS
not_authoritative_for:
  - G8 DCS runtime acceptance
  - actual vertical takeoff
  - owner visual acceptance
  - COMMANDER, landing, recovery or persistence
  - merge or Ready-for-Review authorization
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G8_STATIC_PASS_AWAITING_MIZ
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 713f008dab4b77f3fc3553269d89413981dbc5db
validated_in_dcs: false
supersedes:
  - Tarinkot README gate entries that classify PR 55 as Draft or not on main
  - Tarinkot manifest gate entries that block G8 on central consolidation
  - PR 53 text that classifies central lifecycle consolidation as incomplete
superseded_by: []
---

# Tarinkot – Main-Lifecycle-Synchronisierung und G8 Static PASS

## 1. Main-Baseline

Die zentrale AirOps-Lifecycle- und Testgovernance wurde mit PR #55 auf `main` übernommen:

```text
main merge commit:
cf1b5ff138c6cb5e59e0070f7ba8aef4cfb3823a
```

Sie enthält insbesondere:

```text
AIRWING/SQUADRON/WAREHOUSE-Lifecycle-Matrix
Pre-/Post-Start-Regeln
MIZ-Invalidierungsregel
Observer-Client-Policy
verifizierte Vertikaloption
verbindliche COMMANDER-Sequenz
kanonisches Dokument 22
mission/tests/GOVERNANCE.md
zentralen Lifecycle-Guard
Long-Test-Lock
```

## 2. Tarinkot-Synchronisierung

Der Tarinkot-Branch wurde konfliktaufgelöst mit `origin/main` synchronisiert:

```text
Tarinkot merge commit:
3c55cedcb2f1aa571a5bb715114199ab2b1c6a57
```

Auf diesem Stand bestanden:

```text
Documentation validation
Run 30955772772
SUCCESS

Tarinkot G7 static validation
Run 30955772776
SUCCESS
```

Damit ist die frühere Abhängigkeit `DRAFT_PR_55_NOT_ON_MAIN` aufgehoben. Dieses Dokument ersetzt für den aktuellen Gate-Status die entsprechenden älteren Statuszeilen in Manifest und Test-README; deren historische G5/G6/G7-Inhalte bleiben gültig.

## 3. G8-Implementierung

Implementiert wurde genau ein nativer UH-60-Dispatch:

```text
Source:
mission/tests/tarinkot-air-operations/src/08-tarinkot-g8-uh60-native-vertical-dispatch.lua

Builder:
tools/build-tarinkot-air-operations-g8-uh60-vertical-dispatch.ps1

BuilderVersion:
TKOT-G8-UH60-VERTICAL-DISPATCH-1

Bundle:
mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G8_UH60_VerticalDispatch.lua

Acceptance:
mission/tests/tarinkot-air-operations/expected/g8-uh60-native-vertical-departure-acceptance.md
```

Operativer Scope:

```text
1 AIRWING:AddMission
1 AUFTRAG:NewLANDATCOORDINATE
1 UH-60
1 erforderliche Mission-Editor-Zone
0 COMMANDER
0 OPSTRANSPORT
0 SPAWN
0 standalone FLIGHTGROUP
0 synthetische Zonen
```

## 4. Statischer Nachweis

Statisch validierter Implementierungs-Head:

```text
492716c1967a9afabb191f688e9a03e507242d95
```

Ergebnisse:

```text
Documentation validation
Run 30956553889
SUCCESS

Tarinkot G7 static validation
Run 30956553533
SUCCESS

Tarinkot G8 static validation
Run 30956553885
SUCCESS
```

Der G8-Workflow bestätigte:

```text
EmbeddedFoundation: TKOT-G7-AIRWING-FOUNDATION-4
LifecycleGuard: PASS via G7 builder
MissionType: AUFTRAG.Type.LANDATCOORDINATE
Squadron: SQ_US_TKOT_UH60_TF_ATTACK
RequiredAssets: 1
DestinationZone: ZONE_AIR_US_TKOT_ROTARY_STAGING
GroundDisplacementThresholdM: 75
OperationalMissions: 1
Commander: 0
OpsTransport: 0
RawSpawn: 0
StandaloneFlightGroup: 0
SyntheticZones: 0
OwnerVisualConfirmation: required
```

Der im PR-Merge-Ref erzeugte CI-Bundlehash lautete:

```text
dc757e468d7f708e19fe0c15b7f05d5a5076461d83acd0f1b95d97c1c0501565
```

Dieser Hash gilt ausschließlich für das CI-Artefakt. Der lokale Build erzeugt wegen eingebettetem Git-Commit und Erstellungszeitpunkt einen eigenen zu dokumentierenden Hash.

## 5. Verifizierter MOOSE-Pfad

```text
AIRWING:SetOptionPreferVerticalLanding()
AIRWING:Start()
AIRWING:AddMission(AUFTRAG)
AIRWING FlightOnMission
FLIGHTGROUP:SetOptionPreferVertical()
```

Der G8-Harness ruft `SetOptionPreferVertical()` nicht selbst auf. Er beobachtet lediglich, ob MOOSE das Flag auf der von AIRWING verwalteten FLIGHTGROUP gesetzt hat.

## 6. Noch erforderliche MIZ-Änderung

Vor dem DCS-Lauf muss im Mission Editor eine reale Zone angelegt werden:

```text
ZONE_AIR_US_TKOT_ROTARY_STAGING
```

Die Zone muss auf einer freien UH-60-geeigneten Lande-/Stagingfläche außerhalb von Startplatte, Client-, Static-, Taxiway- und Runwaybereichen liegen.

Es gibt keinen Lua-Fallback und keine erfundene Koordinate.

## 7. Artefaktregel

Nach Zonenanlage, Bundleeinbindung und Speichern müssen neu erfasst werden:

```text
Branch-Commit
BuilderVersion
lokaler Bundle-SHA-256
MIZ-SHA-256
interner mission-SHA-256
eingebetteter Bundle-SHA-256
eingebetteter Moose.lua-SHA-256
Trigger-/Ressourcenreferenz
```

Der kombinierte Lauf führt den G7-Objektvertragssmoke erneut aus, bevor G8 gestartet wird.

## 8. Gate-Status

```yaml
central_lifecycle_consolidation: PASS_MAIN
Tarinkot_main_sync: PASS
G7_post_merge_static_validation: PASS_CI
G8_implementation: PASS_STATIC_CI
G8_Mission_Editor_zone: REQUIRED
G8_artifact_identity: NOT_ESTABLISHED
G8_DCS_runtime: NOT_STARTED
G9_commander: BLOCKED_BY_G8
```

Kein weiterer DCS-Lauf ist zulässig, bevor die reale Zone angelegt, das aktuelle Bundle lokal gebaut, die MIZ gespeichert und die neue Hashkette festgehalten wurde.
