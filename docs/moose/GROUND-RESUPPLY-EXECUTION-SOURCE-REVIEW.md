---
document_id: OMW-MOOSE-GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local MOOSE source review for the first physical Ground RESUPPLY vertical slice
  - AMMOSUPPLY execution and return lifecycle for Joyce-to-Honaker Stage 1A
not_authoritative_for:
  - generic SUPPLY execution
  - FUEL execution beyond source review
  - CAS or CSAR execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Ground RESUPPLY Execution – MOOSE Source Review

## 1. Geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Geprüft wurden Projekt-MOOSE-Dokumentation, tatsächlicher gepinnter `Moose.lua`-Source, öffentliche Online-Dokumentation sowie offizielle MOOSE-Demo-/Testmissionen. Maßgeblich für API-Verfügbarkeit und Lifecycle bleibt die tatsächlich geladene `Moose.lua`.

## 2. Strategische Grenze

```text
CampaignState
= alleinige strategische Ressourcen-/Cargo-Autorität

MissionDemand
= Demand-/Assignment-Zustand

MOOSE BRIGADE / PLATOON / ARMYGROUP / AUFTRAG
= physische operative Ausführung
```

CampaignState TRANSFER:

```text
ReserveResource
-> RESERVED
-> MarkLoading
-> LOADING
-> MarkInTransit
-> origin debit exactly once
-> IN_TRANSIT
-> MarkDelivered
-> destination credit exactly once
-> DELIVERED
```

Der physische Convoy besitzt keine eigene strategische Menge.

## 3. MOOSE-first AMMO-Pfad

Im gepinnten Source ist vorhanden:

```lua
AUFTRAG:NewAMMOSUPPLY(Zone)
```

Stage 1A verwendet:

```text
BRIGADE
PLATOON
ARMYGROUP
AUFTRAG.Type.AMMOSUPPLY
AUFTRAG:NewAMMOSUPPLY(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die bereits owner-approved `OMW_GroundRoadSpawnAdapter.lua`-Ausnahme wird nur für road-aligned Materialisierung verwendet. Request-, Asset-, BRIGADE-, PLATOON-, ARMYGROUP- und AUFTRAG-Lifecycle bleiben MOOSE-owned.

Kein eigener Router, kein eigener Convoy-Dispatcher, kein Raw-SPAWN-Fallback und kein Despawn/Respawn-Return wurden eingeführt.

## 4. Physische Convoy-Baseline

Vorhandene Missions-Templates:

```text
TPL_BLUE_CONVOY_LIGHT_06
TPL_BLUE_CONVOY_STANDARD_07
```

Stage 1A verwendet fest:

```text
TPL_BLUE_CONVOY_LIGHT_06
strategic transfer = 20 GROUND_AMMO_PACKAGE
```

Nicht definiert:

```text
1 M1083 = X packages
LIGHT_06 capacity = X
STANDARD_07 capacity = Y
automatic LIGHT/STANDARD selection
```

## 5. Delivery-Grenze

Fail-closed Delivery:

```text
exact ARMYGROUP
+ exact AMMOSUPPLY mission
+ OnAfterMissionExecute
+ ARMYGROUP:IsInZone(destination ACCESS zone) == true
-> CampaignState MarkDelivered
-> MissionDemand DELIVERED / SUCCESS
```

`MissionDone` allein ist kein Liefernachweis.

## 6. AMMOSUPPLY-Abschluss und Return-Timing

Die Source-/Demo-Prüfung ergab keinen separaten automatischen Entlade-Timer, den OMW vor dem Return abwarten müsste. Der relevante Fehler aus DCS-Lauf 3 war eine Lifecycle-Überlappung:

```text
MissionDone
-> RTZ nach nur 2 s
-> AUFTRAG finalisiert danach noch die AMMOSUPPLY-Mission
-> Convoy bleibt am Ziel
-> RETURN_TIMEOUT
```

OMW Ground Acceptance 4-2 hatte bereits denselben öffentlichen mobilen RTZ-Pfad mit einem 30-s-Settlement-Fenster erfolgreich bestätigt. Stage 1A übernimmt deshalb:

```text
RETURN_ISSUE_DELAY_SEC = 30
MissionDone
-> wait 30 s
-> ARMYGROUP:RTZ(origin ACCESS zone, OnRoad)
```

DCS-Lauf 4 bestätigte diese Korrektur praktisch.

## 7. Returned -> AddAsset

Der gepinnte Source enthält:

```lua
function ARMYGROUP:onafterReturned(From, Event, To)
  if self.legion then
    self.legion:__AddAsset(10, self.group, 1)
  end
end
```

Der Acceptance-Harness wartet deshalb 12 Sekunden nach `Returned`, bevor `AddAsset` und physische Entfernung final geprüft werden.

DCS-Lauf 4 bestätigte:

```text
RETURNED_HANDOFF
-> 10 s MOOSE handoff window
-> WAREHOUSE_ADD_ASSET
-> physical group no longer alive
-> PASS
```

## 8. DCS Acceptance – bestätigte Provenienz

```text
Branch: agent/automatic-response-orchestration
Acceptance source/build commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
Acceptance bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Executed mission: OMW_Template_v18.miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
internal mission SHA-256: 38B207278365CD977E74FF3C9000C6A7C5B13EEE3E5B1BB154F1775055D02AF6
Result: PASS
```

Runtime sequence:

```text
DELIVERY_CONFIRMED
MISSION_DONE returnIssueDelaySec=30
AUFTRAG Ammo Supply success
RETURN_RTZ_ACTIVE
RETURN_RTZ_ISSUED
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS originFinal=24 destinationFinal=40 returnedCount=1 warehouseAddAssetCount=1
```

Detailergebnis:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-ammo-resupply-acceptance-1-pass-1.md
```

## 9. Methodenstatus für Stage 1A

```text
AUFTRAG:NewAMMOSUPPLY(Zone)                         VALIDATED_FOR_DOCUMENTED_SCOPE
AUFTRAG:SetMissionSpeed(...)                        VALIDATED_FOR_DOCUMENTED_SCOPE
AUFTRAG:SetFormation(OnRoad)                        VALIDATED_FOR_DOCUMENTED_SCOPE
AUFTRAG:SetReturnToLegion(false)                    VALIDATED_FOR_DOCUMENTED_SCOPE
BRIGADE:AddMission(...)                             VALIDATED_FOR_DOCUMENTED_SCOPE
PLATOON:AddMissionCapability(AMMOSUPPLY, ...)       VALIDATED_FOR_DOCUMENTED_SCOPE
ARMYGROUP:RTZ(existing ACCESS zone, OnRoad)         VALIDATED_FOR_DOCUMENTED_SCOPE
ARMYGROUP:OnAfterReturned(...)                      VALIDATED_FOR_DOCUMENTED_SCOPE
ARMYGROUP:onafterReturned -> LEGION:__AddAsset(...) VALIDATED_FOR_DOCUMENTED_SCOPE
```

Nur der exakt dokumentierte Joyce-Honaker-LIGHT_06-Scope ist dadurch validiert.

## 10. FUEL und Generic SUPPLY

Source-seitig vorhanden:

```lua
AUFTRAG:NewFUELSUPPLY(Zone)
```

Status:

```text
FUEL = SOURCE_REVIEWED / DCS_PENDING
```

Für `GROUND_SUPPLY_PACKAGE` wurde keine gleichwertige generische öffentliche `AUFTRAG:NewSUPPLY(...)`-Mission bestätigt.

Reihenfolge:

```text
1. AMMO -> AMMOSUPPLY: ACCEPTED_TECHNICAL_BASELINE
2. FUEL -> FUELSUPPLY: next dedicated acceptance candidate
3. generic SUPPLY -> separate MOOSE gap review
4. custom fallback only after documented gap + owner approval
```

## 11. Ergebnis

```text
MOOSE-first path found: YES
custom physical dispatcher required: NO
custom routing/pathfinding required: NO
existing approved road-spawn adapter reused: YES
existing mission convoy template reused: YES
OPSTRANSPORT required for first AMMO slice: NO
new non-MOOSE exception requested: NO
DCS full Joyce-Honaker-Joyce roundtrip: PASS
Returned -> Warehouse AddAsset: PASS
Stage 1A classification: ACCEPTED_TECHNICAL_BASELINE
```
