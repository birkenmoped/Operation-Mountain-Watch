---
document_id: OMW-MOOSE-FORCED-LANDING-RECOVERY
status: ACCEPTED_TECHNICAL_BASELINE
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
source_commit: 76998ae9c802c915d099a30207ec902dd54f1edc
validated_in_dcs: true
---

# Forced Landing / Recovery V1 – MOOSE-Grenze

## 1. Zweck

Diese Notiz setzt die beschlossenen Forced-Landing-/Recovery-Regeln in eine MOOSE-First-Implementierungsgrenze um. Sie gehört zum Aircraft-/Resource-Lifecycle, nicht zum CSAR-Scope.

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

`FLIGHTGROUP:GetParkingSpot(element, maxdist, airbase)` dokumentiert 5 m als Default-Distanzschwelle. Für Client-Gruppen ohne FLIGHTGROUP-`Arrived` enthält der aktuelle Branch deshalb zusätzlich eine read-only Parking-Prüfung über `AIRBASE:GetParkingSpotsTable()`.

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
-> nearest recovery node / 5-km Policy
```

Für den später korrigierten Branch-Stand gilt zusätzlich:

```text
<= 5 m zu Parking-Spot eines recovery-capable Nodes
-> NORMAL_EXPECTED_RETURN evidence
```

Diese Parking-Korrektur ist source-reviewed, wurde aber nicht separat mit dem final akzeptierten Gate-1-Runtime-Artefakt validiert.

## 6. Runtime-Evidenz und Acceptance

### 6.1 PlaceName-Grenze

Der erste DCS-Lauf lieferte:

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

Land und EngineShutdown wurden korrekt beobachtet. Die fehlerhafte PlaceName-Annahme wurde anschließend aus der Branch-Implementierung entfernt und durch die source-reviewed Parking-Distanzprüfung ersetzt.

### 6.2 Recovery-Grenze

Weitere reale DCS-Läufe mit dem vom Projektinhaber verwendeten Gate-1-Artefakt belegten beide Seiten der 5-km-Grenze:

```text
4782.4415407502 m
-> expectedReturn=false
-> recoveryCapable=true
-> RECOVERABLE_FORCED_LANDING
-> RECOVERABLE_RUNTIME_PASS
-> RESULT status=PASS

5432.5138283616 m
-> expectedReturn=false
-> recoveryCapable=true
-> OFF_FIELD_UNRECOVERABLE
```

Der positive Lauf verwendete:

```text
DCS: 2.9.28.26385 MT
Mission: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: dbe72aa0627b01e25491d89418a24bfb4a07a6228a2613d4332fee41bfe1eb1a
internal mission SHA-256: b5fcab7d428811f97c06beea2355a213608fdbc8788073ae618556edd94305e3
embedded Gate SHA-256: 0b99504ca01c6e543d82c022fa41fa3940e65413da9dfa43d10a94048ef9eabc
embedded BuilderVersion: FORCED-LANDING-RECOVERY-V1-GATE-1
embedded GitCommit: 76998ae9c802c915d099a30207ec902dd54f1edc
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: 5598b58bc22ecc6cdb30d2a59dfeea2027cc290e0b0b0b5d24850dcc6cb58c11
debrief.log SHA-256: 7ba77812600f3b7737ba0d4e5fe10ffa7785f1519d369b0d6fb7a887fd8afe3c
```

Der Projektinhaber hat am 13.08.2026 ausdrücklich entschieden, diese Testreihe als erfolgreich abgenommen zu werten.

Damit ist für den dokumentierten Scope technisch akzeptiert:

```text
Land/EngineShutdown observation
5-km recovery classification
RECOVERABLE_FORCED_LANDING inside envelope
OFF_FIELD_UNRECOVERABLE outside envelope
deterministic 1800-s recovery / 21600-s repair-lock policy logic
```

Nicht separat runtime-validiert ist die nach Versuch 1 implementierte Parking-Korrektur des späteren Gate-2-Standes. Diese Einschränkung bleibt Teil der Acceptance.

## 7. Nicht Teil dieses Scopes

```text
CSAR/AICSAR
crew lifecycle
contested recovery V2
recovery convoy simulation
artificial DCS damage/repair percentages
native DCS event fallback
custom AIRWING return controller
productive CampaignState settlement
productive STORAGE settlement
productive repair-lock scheduler/persistence
```
