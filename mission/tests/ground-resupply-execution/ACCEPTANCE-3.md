---
document_id: OMW-GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local acceptance plan for generic MissionDemand-driven Ground meta-resource RESUPPLY via AUFTRAG NOTHING
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground Meta RESUPPLY Acceptance 1 – AUFTRAG NOTHING

## 1. Owner-Entscheidung

Am 22.08.2026 hat der Projektinhaber den physischen Vertrag für `AUFTRAG:NewNOTHING(...)` als Ersatzkandidaten für abstrakte Ground-Meta-Waren bestätigt.

Der fehlgeschlagene `AUFTRAG:NewFUELSUPPLY(...)`-Pfad bleibt historische Negativ-Evidenz und wird nicht überschrieben.

## 2. Ziel

Erster Fixture bleibt bewusst `GROUND_FUEL_PACKAGE`, um den bisherigen Stage-1B-Versuch mit minimal veränderter strategischer Semantik zu ersetzen:

```text
HONAKER FUEL 36
-> test-only consumption 18
-> HONAKER FUEL 18 / REORDER
-> one MissionDemand RESUPPLY
-> CampaignState TRANSFER 18 Joyce -> Honaker
-> TPL_BLUE_CONVOY_FUEL_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(Honaker ACCESS)
-> OnRoad 27 kt
-> exact destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> mission cancel / MissionDone
-> 30 s settlement
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Erwarteter strategischer Endzustand:

```text
JOYCE FUEL   40 -> 22
HONAKER FUEL 36 -> 18 -> 36
```

## 3. Architekturgrenze

```text
CampaignState = alleinige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Zustand
AUFTRAG NOTHING = nur neutrale physische Bewegung / Aufenthalt
DCS group = temporäre physische Repräsentation
```

Nicht definiert:

```text
DCS fuel quantity
1 M978 = X GROUND_FUEL_PACKAGE
FUEL_LIGHT_06 capacity
physical cargo authority
```

Der M978 ist für diesen Test lediglich eine plausible sichtbare Repräsentation von Fuel-Nachschub.

## 4. MOOSE-First Nachweis

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im tatsächlich verwendeten Source bestätigt:

```lua
AUFTRAG:NewNOTHING(RelaxZone)
```

Weitere bestätigte Semantik:

```text
AUFTRAG.Type.NOTHING
AUFTRAG.SpecialTask.NOTHING
GROUND/NAVAL categories
zone objective
WeaponHold
AlarmState.Auto
missionFraction = 1.0
OPSGROUP NOTHING task -> FullStop at execution
TaskCancel NOTHING -> TaskDone -> MissionDone path
```

Eine dedizierte offizielle MOOSE-Demo für den OMW-Meta-RESUPPLY-Roundtrip ist nicht belegt. Runtime bleibt daher DCS-pending.

## 5. Physischer Vertrag

```text
PLATOON:AddMissionCapability(AUFTRAG.Type.NOTHING, 100)
AUFTRAG:NewNOTHING(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:AddMission(...)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die bereits owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird unverändert wiederverwendet.

## 6. Fail-fast Gate

Der frühere Fuel-Test wartete bis zum 1800-s-Outbound-Timeout. Dieser Harness begrenzt die Wartezeit:

```text
OutboundTimeoutSec = 600
DestinationCheckIntervalSec = 15
DestinationExecutionGraceSec = 90
```

Nach tatsächlichem Eintritt des ARMYGROUP in die Honaker-ACCESS-Zone muss `MissionExecute` innerhalb von 90 Sekunden folgen. Andernfalls:

```text
FAIL reason=DESTINATION_EXECUTION_TIMEOUT
```

Damit wird ein erneuter physischer Zielstillstand ohne MOOSE-Lifecycle-Fortschritt früh erkannt.

## 7. Delivery / Return

Delivery bleibt fail-closed:

```text
exact Mission
AND OnAfterMissionExecute
AND ARMYGROUP:IsInZone(Honaker ACCESS) == true
-> CampaignState MarkDelivered
-> MissionDemand SUCCESS
```

Danach:

```text
mission:__Cancel(1)
-> MissionDone
-> 30 s settlement
-> same ARMYGROUP RTZ Joyce
-> Returned
-> MOOSE Legion/Warehouse AddAsset
-> 12 s final verification
```

Der 30-s-Delay wird als bereits bei Stage 1A bestätigte AUFTRAG-/RTZ-Lifecycle-Koordination beibehalten; er ist keine Entladezeit.

## 8. Source / Builder

```text
mission/tests/ground-resupply-execution/src/03-ground-meta-resupply-nothing-acceptance.lua
tools/build-ground-meta-resupply-nothing-acceptance-1.ps1
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-1
Output: mission/tests/ground-resupply-execution/dist/OMW_Ground_Meta_Resupply_NOTHING_Acceptance_1.lua
```

## 9. Aktueller Status

```text
Owner physical contract approval: YES
MOOSE docs/source review: COMPLETE FOR STAGED SCOPE
Acceptance source: STAGED ON BRANCH
Builder: STAGED ON BRANCH
Owner-local build: NOT RUN
Mission Editor integration: NOT STARTED
DCS runtime: NOT RUN
Acceptance result: DCS_PENDING
```
