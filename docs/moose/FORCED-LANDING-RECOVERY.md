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
-> bis dahin keine Resource-Gutschrift
-> danach verbleibender Fuel/Stores strategisch gutschreiben
-> Aircraft RECOVERED_AWAITING_REPAIR
-> 6 h Repair-Lock
-> AVAILABLE

unexpected landing außerhalb recovery-capable envelope
-> OFF_FIELD_UNRECOVERABLE
-> Aircraft/Fuel/Stores strategisch verloren
```

`<= 5 %` Fuel bleibt ein starkes Zusatzsignal, ist aber ausdrücklich kein alleiniger Forced-Landing-Trigger.

## 3. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 4. Source-reviewed Lifecycle

Im tatsächlich verwendeten `Moose.lua` ist für `FLIGHTGROUP` belegt:

```text
EVENTS.Land
-> FLIGHTGROUP:OnEventLanding(...)
-> ElementLanded(...)

EVENTS.EngineShutdown
-> FLIGHTGROUP:OnEventEngineShutdown(...)
-> nur bei lebender Unit, on-ground und erkanntem Parking:
   ElementArrived(...)

FLIGHTGROUP:onafterArrived(...)
-> AI + AIRWING asset + kein pickup/transport
-> ReturnToLegion(1)
```

Wichtig ist die vorhandene MOOSE-Grenze: Ein normales AIRWING-Return wird erst über `Arrived`/Parking zurück in die Legion gegeben. Ein Off-field-Landing ohne erkanntes Parking wird durch `EngineShutdown` nicht automatisch zu `Arrived`.

Ebenfalls source-reviewed:

```text
FLIGHTGROUP:IsLandingAt()
FLIGHTGROUP:IsLandedAt()
FLIGHTGROUP:IsPickingup()
FLIGHTGROUP:IsTransporting()
FLIGHTGROUP:GetMissionCurrent()
AUFTRAG.Type.LANDATCOORDINATE
EVENTHANDLER:New()
BASE:HandleEvent(EVENTS.Land)
BASE:HandleEvent(EVENTS.EngineShutdown)
UNIT:IsAlive()
UNIT:InAir()
UNIT:GetFuel()
UNIT:GetCoordinate()
AIRBASE:FindByName()
AIRBASE:GetCoordinate()
COORDINATE:Get2DDistance()
```

Damit ist keine Native-DCS-Event-Parallelimplementierung notwendig.

## 5. Neue OMW-Komponenten

```text
scripts/logistics/OMW_ForcedLandingRecoveryPolicy.lua
scripts/logistics/OMW_ForcedLandingObserver.lua
```

### Policy

Pure Campaign-Domain-Logik ohne MOOSE/DCS-Abhängigkeit. Sie kodiert ausschließlich die beschlossenen Klassifikationen, 5-km-Grenze, 30-min-Recovery und 6-h-Repair-Lock.

### Observer

Der Observer verwendet `EVENTHANDLER` und öffentliche MOOSE-Wrapper. Er beobachtet ausschließlich explizit mit `TrackFlight()` registrierte `FLIGHTGROUP`s.

```text
Land
-> candidate telemetry

EngineShutdown after Land
-> planned LANDATCOORDINATE / LandingAt / pickup / transport erkennen
-> vorhandenes FLIGHTGROUP Arrived als expected normal return erkennen
-> nearest configured recovery-capable aviation node bestimmen
-> Policy klassifizieren
```

Der Observer verändert weder CampaignState noch STORAGE noch AIRWING/WAREHOUSE noch physische DCS-Objekte.

## 6. Wichtige Grenze

Die Source-Prüfung reicht aus, um die verwendbaren MOOSE-Signale und die geplante Klassifikationslogik festzulegen. Sie beweist noch nicht, dass jeder reale DCS-Forced-Landing-Fall zuverlässig eine für diesen Pfad ausreichende `Land -> EngineShutdown`-Sequenz erzeugt.

Deshalb ist genau **ein** gebündelter Runtime-Gate erforderlich, bevor die automatische CampaignState-Recovery-Buchung aktiviert werden darf. Der Gate muss insbesondere prüfen:

```text
normal AIRWING return -> NORMAL_EXPECTED_RETURN
planned LANDATCOORDINATE -> NORMAL_PLANNED_LANDING
unexpected off-field landing with engine shutdown -> forced-landing classification
5-km recovery envelope
no premature CampaignState/STORAGE mutation
```

Bereits bestätigte Materialization-, Rearm-, Refuel-, normal-return- und total-loss-Warehouse-Semantik wird dabei nicht erneut getestet.

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
