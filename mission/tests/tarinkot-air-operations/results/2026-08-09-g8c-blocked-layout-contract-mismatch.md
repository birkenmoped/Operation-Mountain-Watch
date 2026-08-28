---
document_id: OMW-TEST-TKOT-G8C-BLOCKED-LAYOUT-CONTRACT-MISMATCH-2026-08-09
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact blocked G8C runtime observation on 2026-08-09
  - evidence that the tested embedded G7 parking data did not match the current layout contract
not_authoritative_for:
  - vertical takeoff behavior
  - AI spawn behavior after the parking-layout contract is implemented
  - acceptance of a Tarinkot AIRWING, SQUADRON or G8C runtime configuration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: a9eb30802a907399ede3d00d9ff2afbecea98b1e
validated_in_dcs: true
supersedes: []
superseded_by: []
---

# Tarinkot G8C – blockierter Lauf wegen Parkplatzvertrags-Mismatch

## 1. Ergebnis

Der am 9. August 2026 ausgeführte G8C-Bundlelauf erzeugte keine KI-Gruppen. Das Ergebnis ist kein Befund zu `AUFTRAG:NewHOVER()`, AIRWING-Recruitment oder vertikalem Abheben: Der eingebettete G7-Preflight brach vorher ab.

```text
RESULT G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION
status=FAIL
reason=PREFLIGHT_CONTRACT_VIOLATION
violations=2

RESULT G8C_UNIFORM_ROTARY_HOVER_DISPATCH
status=BLOCKED
reason=G7_FOUNDATION_NOT_PASS
assigned=0/5
takeoffGroups=0/5
runtimeUnits=0/7
hoverMissionsAdded=0/5
```

## 2. Unmittelbare Ursache

Der eingebettete G7-Teil protokollierte für AH-64:

```text
PARKING_POOL family=AH64 ids=21,4
PARKING_ID_READY family=AH64 id=21 type=40 free=false toac=true accepted=false
VIOLATION reason=PARKING_ID_NOT_READY family=AH64 id=21
```

Nach dem aktuellen [`OMW-AIR-TKOT-PARKING-LAYOUT`](../../../../docs/tarinkot-air-operations-parking-layout.md) ist TerminalID `21` jedoch der AH-64-Client-Slot `C04-H`. Der Testbundle enthielt damit eine veraltete beziehungsweise abweichende Zuordnung; sein Preflight war nicht kompatibel mit dem aktuellen Vertrag.

## 3. Konsequenz

Der nächste G8C-Build darf erst nach separater Quellangleichung erfolgen. Der Bundle- und Runtime-Preflight müssen dann mindestens ausgeben:

```text
clientTerminalIDs=21,8,3
AH64 parkingIDs=20,19
UH60 parkingIDs=23,27,30
CH47 parkingIDs=32,29,10
```

Ein anschließender G7-PASS ist nur die Voraussetzung für den eigentlichen G8C-Dispatch. Vertikales Abheben sowie die Nichtbenutzung von Taxiway oder Runway bleiben danach eigene DCS-Sichtabnahmekriterien.
