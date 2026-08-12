---
document_id: OMW-MOOSE-FORCED-LANDING-RECOVERY
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-MOOSE-FIRST
authoritative_for:
  - source-reviewed MOOSE boundary for forced-landing observation
  - OMW forced-landing classification and recovery V1 timing
  - distinction between normal return, planned off-field landing and forced-landing candidates
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-forced-landing-recovery-v1
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Forced Landing / Recovery V1 – MOOSE-Grenze

## 1. Zweck

Diese Notiz setzt die bereits beschlossenen Forced-Landing-/Recovery-Regeln in die kleinste MOOSE-First-Implementierungsgrenze um. Sie gehört zum Aircraft-/Resource-Lifecycle, nicht zum CSAR-Scope.

## 2. Verbindliche Domain-Regeln

```text
planned off-field landing / transport landing
-> NORMAL_PLANNED_LANDING
-> kein Loss-/Recovery-Handling

normal expected AIRWING return
-> NORMAL_EXPECTED_RETURN
-> vorhandenen FLIGHTGROUP/AIRWING Return-Lifecycle verwenden

unexpected landing <= 5 km zu recovery-capable friendly aviation node
-> RECOVERABLE_FORCED_LANDING
-> RECOVERY_IN_PROGRESS 30 min
-> danach verbleibender Fuel/Stores strategisch gutschreiben
-> Aircraft RECOVERED_AWAITING_REPAIR
-> 6 h Repair-Lock
-> AVAILABLE

unexpected landing außerhalb recovery-capable envelope
-> OFF_FIELD_UNRECOVERABLE
-> Aircraft/Fuel/Stores strategisch verloren
```

`<= 5 %` Fuel bleibt ein Zusatzsignal und ist kein alleiniger Trigger.

## 3. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 4. Source-reviewed Lifecycle

Im tatsächlich verwendeten `Moose.lua` ist für `FLIGHTGROUP` belegt:

```text
EVENTS.Land -> ElementLanded(...)
EVENTS.EngineShutdown -> nur bei lebender Unit, on-ground und erkanntem Parking ElementArrived(...)
FLIGHTGROUP:onafterArrived(...) -> AI + AIRWING asset + kein pickup/transport -> ReturnToLegion(1)
```

Ein normales AIRWING-Return wird damit über `Arrived`/Parking erkannt. Ein Off-field-Landing ohne Parking wird durch `EngineShutdown` nicht automatisch zu `Arrived`.

Source-reviewed sind außerdem:

```text
FLIGHTGROUP:IsLandingAt()
FLIGHTGROUP:IsLandedAt()
FLIGHTGROUP:IsPickingup()
FLIGHTGROUP:IsTransporting()
FLIGHTGROUP:GetMissionCurrent()
FLIGHTGROUP:GetParkingSpot(element, maxdist, airbase)
AUFTRAG.Type.LANDATCOORDINATE
EVENTHANDLER:New()
EVENTS.Land
EVENTS.EngineShutdown
UNIT:IsAlive()
UNIT:InAir()
UNIT:GetFuel()
UNIT:GetCoordinate()
AIRBASE:FindByName()
AIRBASE:GetCoordinate()
AIRBASE:GetParkingSpotsTable()
COORDINATE:Get2DDistance()
```

`FLIGHTGROUP:GetParkingSpot(element, maxdist, airbase)` dokumentiert 5 m als Default-Distanzschwelle. Für Client-Gruppen ohne FLIGHTGROUP-`Arrived` wird diese vorhandene MOOSE-Grenze read-only über `AIRBASE:GetParkingSpotsTable()` verwendet.

## 5. OMW-Komponenten

```text
scripts/logistics/OMW_ForcedLandingRecoveryPolicy.lua
scripts/logistics/OMW_ForcedLandingObserver.lua
```

Der Observer mutiert weder CampaignState noch STORAGE noch AIRWING/WAREHOUSE noch physische DCS-Objekte.

AIRWING-AI:

```text
planned LANDATCOORDINATE / LandingAt / pickup / transport -> NORMAL_PLANNED_LANDING
FLIGHTGROUP Arrived -> NORMAL_EXPECTED_RETURN
sonst -> nearest recovery node / 5-km Policy
```

Client:

```text
Land + EngineShutdown
-> recovery-capable AIRBASE resolve
-> <= 5 m zu Parking-Spot => NORMAL_EXPECTED_RETURN evidence
-> sonst kein expected-return evidence
-> nearest recovery node / 5-km Policy
```

## 6. Runtime-Befund 12.08.2026

Der erste DCS-Gate lieferte einen verwertbaren FAIL:

```text
CLIENT_US_SHND_AH64D_01
place=Shindand Heliport
distanceM=2223.6182540257
classification=NORMAL_EXPECTED_RETURN
RESULT status=FAIL reason=CLASSIFICATION
```

Damit ist für den getesteten Stand belegt:

```text
PlaceName == recovery-node airbase name
!= physical return to that airbase/parking
```

Die absichtlich off-field ausgeführte Landung lag 2223,6 m vom Node-Zentrum entfernt. `Land` und `EngineShutdown` wurden korrekt beobachtet; falsch war ausschließlich die bisherige OMW-Annahme, `PlaceName` könne für Clients als Return-Beweis dienen.

Korrektur:

```text
PlaceName wird nur noch Telemetrie.
Client expected return wird über die source-reviewed 5-m-Parking-Grenze bestimmt.
```

Der Gate bleibt `PLANNED` / `validated_in_dcs: false`, bis der korrigierte Lauf `RECOVERABLE_FORCED_LANDING` bestätigt.

## 7. Nicht Teil dieses Scopes

```text
CSAR/AICSAR
crew lifecycle
contested recovery V2
recovery convoy simulation
artificial DCS damage/repair percentages
native DCS event fallback
custom AIRWING return controller
```
