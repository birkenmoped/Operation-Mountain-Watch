---
document_id: OMW-TEST-BAGRAM-AIR-OPERATIONS-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram dual-AIRWING foundation test layout
  - Bagram foundation build and Mission Editor prerequisites
  - Bagram AIRWING/SQUADRON parking-policy acceptance state
  - final combined Bagram parking acceptance run
not_authoritative_for:
  - tactical tasking beyond controlled ALERT5 materialization
  - taxi, takeoff, landing, recovery or persistence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - historical single-AIRWING Bagram test index
superseded_by: []
source_branch: agent/bagram-parking-policy-integration
source_commit: GIT_HISTORY
validated_in_dcs: partial
---

# Bagram Air Operations / Parking Acceptance

## Aktueller Stand

Die Bagram-Foundation selbst ist historisch akzeptiert. Die Parking-Policy wurde inzwischen im DCS-Lifecycle bis zur vollständigen `asset.parkingIDs`-Propagation bestätigt:

```text
PARKING_POLICY_POSTSTART status=PASS assetsChecked=69 expectedAssets=69 failed=0 lifecycle=WAREHOUSE_NEWASSET
parkingPolicy=PASS parkingAssetsChecked=69
```

Der erste Parking-Lauf mit Foundation-5 scheiterte ausschließlich an einer zu frühen synchronen Post-Start-Prüfung. Dieser Acceptance-Harness-Fehler wurde gegen den gepinnten MOOSE-Lifecycle analysiert und mit dem öffentlichen `OnAfterNewAsset`-Callback korrigiert.

Der noch offene Nachweis ist die **tatsächliche physische Materialisierung** auf den vorgesehenen SQUADRON-Parking-Pools. Dafür gibt es genau noch einen kombinierten DCS-Lauf.

## Finaler Test

```text
TestID: BAGRAM-PARKING-FINAL-ACCEPTANCE-1
BuilderVersion: BGRAM-PARKING-FINAL-ACCEPTANCE-1
Builder: tools/build-bagram-parking-final-acceptance.ps1
Generated bundle: mission/tests/bagram-air-operations/dist/OMW_AirOps_Bagram.lua
Acceptance contract: mission/tests/bagram-air-operations/expected/bagram-parking-final-acceptance.md
```

Der Builder erzeugt **ein** Testbundle aus:

```text
scripts/air-operations/OMW_AirOps_Bagram_Bootstrap.lua
+
mission/tests/bagram-air-operations/src/OMW_Bagram_Parking_Final_Acceptance.lua
+
docs/data/bagram-me-parking-to-moose-terminalid-validated.csv
```

Damit enthält der letzte Lauf in einem Artefakt:

```text
187/187 TerminalID-Runtimebaseline
2 AIRWINGs
7 SQUADRONs
69 registrierte Assets
69/69 parkingIDs-Propagation
44 AI-Pool-TerminalIDs
10 hard-excluded TerminalIDs
7 kontrollierte MOOSE ALERT5-Materialisierungen
9 physische Luftfahrzeuge
Unit-Koordinate -> nächster realer Bagram-TerminalID
Own-Pool-/Cross-Pool-/Blacklist-Prüfung
finales Aggregatergebnis
```

## MOOSE-First

Der finale Materialisierungstest verwendet ausschließlich nachgewiesene MOOSE-Pfade:

```text
AIRBASE:GetParkingSpotsTable()
COORDINATE:Get2DDistance()
AUFTRAG:NewALERT5(MissionType)
AUFTRAG:SetRequiredAssets(1, 1)
AUFTRAG:AssignSquadrons({ squadron })
AIRWING:AddMission(mission)
OnAfterOpsOnMission
SCHEDULER:New(...)
GROUP:FindByName()
GROUP:GetUnits()
UNIT:GetCoordinate()
```

`AUFTRAG:NewALERT5()` ist für diesen Test geeignet, weil der gepinnte MOOSE-Source ALERT5 als uncontrolled materialisierte Luftfahrzeuge beschreibt, die auf eine weitere Zuweisung warten. `LEGION` erzwingt für ALERT5 den Takeoff-Typ `TakeOffParking`.

Nicht verwendet werden:

```text
SPAWN
FLIGHTGROUP:New
Native-DCS-Spawn
COMMANDER
OPSTRANSPORT
MIST
MOOSE-Override
```

## Required Mission Editor objects

Airbase:

```text
Bagram
```

Warehouse anchors:

```text
WH_AIR_US_BAGRAM
WH_AIR_US_BAGRAM_ARMY
```

Required Late Activation templates:

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
TPL_AIR_US_BGRM_MQ1A_RECON_1SHIP
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP
```

## Parking policy

```text
F-15E: M01-M12
F-16C: M13-M24
MQ-1A: B01-B08
C-130: A10,S01-S05
HH-60G: R15-R16
UH-60: R17-R18
CH-47: R19-R20
```

Hard exclusions:

```text
A08 A09
M27 M28 M29 M30
R21 R22
HAZ01 HAZ02
```

Die sieben Pools umfassen 44 eindeutige AI-TerminalIDs. Die zehn Blacklist-IDs dürfen in keinem Pool vorkommen.

## Finaler Materialisierungsumfang

```text
F-15E   1 x 2-ship = 2 Units
F-16C   1 x 2-ship = 2 Units
MQ-1A   1 x 1-ship = 1 Unit
C-130   1 x 1-ship = 1 Unit
HH-60G  1 x 1-ship = 1 Unit
UH-60   1 x 1-ship = 1 Unit
CH-47   1 x 1-ship = 1 Unit

Total: 7 groups / 9 units
```

Jede Unit wird anhand ihrer MOOSE-`UNIT:GetCoordinate()`-Position dem nächstgelegenen Eintrag aus `AIRBASE:GetParkingSpotsTable()` zugeordnet. Ein Abstand über 50 m gilt als nicht belastbar zuordenbar und damit als FAIL.

## Erwarteter finaler Marker

```text
BAGRAM_PARKING_FINAL_RESULT status=PASS reason=ALL_GATES_PASS foundationAssets=69 foundationParkingChecked=69 foundationParkingFailed=0 dispatchRequested=7 groupsMaterialized=7 unitsMaterialized=9 unitsParkingChecked=9 unitsInOwnPool=9 crossPoolViolations=0 blacklistViolations=0 unknownParking=0 unexpectedMissions=0 groupFailures=0
```

Nur diese vollständige Kombination ist PASS.

## Build

Finaler Acceptance-Build:

```powershell
.\tools\build-bagram-parking-final-acceptance.ps1
```

Der bisherige reine Foundation-Builder bleibt weiterhin verfügbar:

```powershell
.\tools\build-bagram-air-operations-foundation.ps1
```

Er ist jedoch **nicht** der Builder für den letzten physischen Parking-Test.

## MOOSE pin

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Foundation accounting

```text
2 AIRWINGs
7 SQUADRONs
69 MOOSE asset groups
81 represented airframes
83 logical airframes
2 logical fighter reserve airframes
8 role-payload registrations
```

## Bisherige Runtime-Evidenz 28.08.2026

Der korrigierte Foundation-6-Lauf bestätigte die ParkingID-Propagation auf alle 69 Assets.

```text
Source commit: 2a0e8044543d42bf4ac9ff087bf3e6ff69d7d45f
BuilderVersion: BGRAM-AIR-OPS-DUAL-FOUNDATION-6
Generated bundle SHA-256: 705B2EE891A990A686721B411BC0835A0F3FC500D7F3F82B9F9D0D1496186D0A
DCS: 2.9.29.27278
DCS log artifact SHA-256: 41874509E8959A52B766091443F0F14E677BBC388D40BC97931DD86AB34B8E46
Debrief artifact SHA-256: F6A3A24A0623CE12B21DF4B0D25067B5F9D341D6932614475D83B1BB017C14E4
```

Diese Evidenz bleibt gültig für den dokumentierten Lifecycle-Scope, ersetzt aber nicht den finalen physischen Materialisierungsnachweis.

## Statisches Gate vor dem letzten DCS-Lauf

Nach der letzten MIZ-Änderung werden neu geprüft und dokumentiert:

```text
Branch / Commit
BuilderVersion
Source-/Builder-/Bundle-SHA-256
MIZ-SHA-256
interner mission-SHA-256
eingebetteter Bundle-SHA-256
eingebetteter Moose.lua-SHA-256
Objektvertragssmoke
Trigger-/Ressourcenpfad
keine alte parallele Parking-Correlation-Aktion
```

Erst nach diesem Gate wird der **eine letzte DCS-Lauf** gestartet.

Bei PASS werden Ergebnisbericht, README, Manifest und MOOSE-Projektdokumentation synchronisiert. Danach folgen Diff-/CI-Prüfung und die ausdrückliche Ready-for-Review-/Merge-Entscheidung des Projektinhabers.
