---
document_id: OMW-MOOSE-GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local MOOSE source review for physical Ground RESUPPLY vertical slices
  - AMMOSUPPLY execution and return lifecycle for Joyce-to-Honaker Stage 1A
  - FUELSUPPLY source-reviewed staging boundary for Joyce-to-Honaker Stage 1B
not_authoritative_for:
  - generic SUPPLY execution
  - FUELSUPPLY runtime acceptance before the dedicated DCS test
  - CAS or CSAR execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Ground RESUPPLY Execution – MOOSE Source Review

## 1. Geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Geprüft wurden Projekt-MOOSE-Dokumentation, tatsächlicher gepinnter `Moose.lua`-Source, aktuelle Online-Dokumentation sowie offizielle MOOSE-Demo-/Testrepositories. Maßgeblich für API-Verfügbarkeit und Lifecycle bleibt die tatsächlich geladene `Moose.lua`.

## 2. Strategische Grenze

```text
CampaignState = alleinige strategische Ressourcen-/Cargo-Autorität
MissionDemand = Demand-/Assignment-Zustand
MOOSE BRIGADE / PLATOON / ARMYGROUP / AUFTRAG = physische operative Ausführung
DCS group = temporäre physische Repräsentation
```

CampaignState TRANSFER bleibt:

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

## 3. Stage 1A – AMMO / akzeptierter MOOSE-first Pfad

Im gepinnten Source vorhanden und im dokumentierten Stage-1A-DCS-Lauf praktisch bestätigt:

```lua
AUFTRAG:NewAMMOSUPPLY(Zone)
```

Verwendeter Pfad:

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

Die owner-approved `OMW_GroundRoadSpawnAdapter.lua`-Ausnahme dient ausschließlich der road-aligned Materialisierung. Request-, Asset-, BRIGADE-, PLATOON-, ARMYGROUP- und AUFTRAG-Lifecycle bleiben MOOSE-owned.

Kein eigener Router, kein eigener Convoy-Dispatcher, kein Raw-SPAWN-Fallback und kein Despawn/Respawn-Return wurden eingeführt.

### Stage-1A Provenienz

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

Runtime bestätigte:

```text
CampaignState AMMO shortage / REORDER demand
MissionDemand RESUPPLY
CampaignState TRANSFER Joyce -> Honaker
TPL_BLUE_CONVOY_LIGHT_06
AMMOSUPPLY / OnRoad 27 kt
destination-zone proof
MarkDelivered / MissionDemand SUCCESS
MissionDone
30 s settlement window
same ARMYGROUP RTZ Joyce
Returned
LEGION/Warehouse AddAsset
physical cleanup
```

## 4. Delivery-/Return-Grenze

Für AMMO und den Stage-1B-FUEL-Harness gilt fail-closed:

```text
exact ARMYGROUP
+ exact acceptance AUFTRAG mission
+ OnAfterMissionExecute
+ ARMYGROUP:IsInZone(destination ACCESS zone) == true
-> CampaignState MarkDelivered
-> MissionDemand DELIVERED / SUCCESS
```

`MissionDone` allein ist kein Liefernachweis.

Der gepinnte MOOSE-Source enthält für ARMYGROUP:

```lua
function ARMYGROUP:onafterReturned(From, Event, To)
  if self.legion then
    self.legion:__AddAsset(10, self.group, 1)
  end
end
```

Der Acceptance-Harness wartet deshalb 12 Sekunden nach `Returned`, bevor Warehouse-AddAsset und physische Entfernung final geprüft werden.

## 5. Return-Timing / Race-Condition

Stage 1A reproduzierte mit nur zwei Sekunden Abstand:

```text
MissionDone
-> early RTZ accepted
-> AUFTRAG completion still running
-> Convoy remains at destination
-> RETURN_TIMEOUT
```

Mit dem aus Ground Acceptance 4 übernommenen 30-s-Fenster wurde der komplette Return praktisch bestätigt:

```text
MissionDone
-> wait 30 s
-> ARMYGROUP:RTZ(origin ACCESS, OnRoad)
-> Returned
-> Warehouse AddAsset
-> PASS
```

Dieses Fenster ist eine Lifecycle-Koordination und weder AMMO- noch FUEL-Entladezeit.

## 6. Stage 1B – FUEL / Source Review

Die aktuelle Online-MOOSE-Dokumentation führt ausdrücklich:

```lua
AUFTRAG:NewFUELSUPPLY(Zone)
```

als Ground FUEL SUPPLY mission.

Die tatsächlich gepinnte `Moose.lua` bestätigt:

```text
AUFTRAG.Type.FUELSUPPLY
AUFTRAG.SpecialTask.FUELSUPPLY
AUFTRAG:NewFUELSUPPLY(Zone)
```

Die Methode konstruiert den Ground-FUELSUPPLY-Pfad mit Zielzone, WeaponHold, AlarmState.Auto und `missionFraction = 1.0`. Im OPSGROUP-SpecialTask-/TaskCancel-Pfad wird `FUELSUPPLY` zusammen mit `AMMOSUPPLY` behandelt. Damit existiert ein direkter MOOSE-first-Pfad; ein projektspezifischer FUEL-Dispatcher ist nicht erforderlich.

Die offiziellen Repositories `MOOSE_MISSIONS` und `MOOSE_MISSIONS_UNPACKED` wurden nach einem dedizierten aktuellen `NewFUELSUPPLY`-/`FUELSUPPLY`-Demo-Slice durchsucht. Kein entsprechender direkter Demo-Beleg wurde gefunden. Diese fehlende Demo-Evidenz wird nicht durch Annahmen ersetzt.

Status vor DCS:

```text
AUFTRAG:NewFUELSUPPLY(Zone) = SOURCE_REVIEWED / DCS_PENDING
AUFTRAG.Type.FUELSUPPLY = SOURCE_REVIEWED / DCS_PENDING
FUELSUPPLY OPSGROUP execution = SOURCE_REVIEWED / DCS_PENDING
```

## 7. Stage 1B – v19 Physical Fixture

Owner-created Mission `OMW_Template_v19.miz`, durch ChatGPT ausschließlich read-only geprüft:

```text
MIZ SHA-256: B89DBE7B755D25B43384B158F3D25921C70847820F71B837F12F86C5D863A8A6
internal mission SHA-256: 6B15369398C3B5989B676DB473127489C236F5948737AA3242FDB182FD515B95
```

Ausgewähltes Acceptance-Fixture:

```text
TPL_BLUE_CONVOY_FUEL_LIGHT_06
lateActivation = true
1 CHAP_MATV
2 M978 HEMTT Tanker
3 MaxxPro_MRAP
4 M978 HEMTT Tanker
5 MaxxPro_MRAP
6 CHAP_MATV
```

Weitere neue Templates in v19:

```text
TPL_BLUE_CONVOY_FUEL_STD_07
TPL_BLUE_CONVOY_MIXED_LIGHT_06
TPL_BLUE_CONVOY_MIXED_STD_07
```

Sie werden durch Stage 1B nicht automatisch ausgewählt und definieren keine strategische Capacity-Regel.

## 8. Stage 1B – geplanter Acceptance-Vertrag

Ground-Baseline:

```text
JOYCE FUEL target/initial 40, reorder 20, critical 10
HONAKER FUEL target/initial 36, reorder 18, critical 9, supplyParent Joyce
```

Acceptance-Slice:

```text
HONAKER 36
-> test-only consumption 18
-> HONAKER 18 / REORDER
-> one RESUPPLY MissionDemand
-> CampaignState TRANSFER 18 Joyce -> Honaker
-> TPL_BLUE_CONVOY_FUEL_LIGHT_06
-> AUFTRAG:NewFUELSUPPLY(Honaker ACCESS)
-> OnRoad 27 kt
-> exact destination-zone delivery proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> 30 s settlement window
-> same ARMYGROUP RTZ Joyce
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Strategischer Endzustand:

```text
JOYCE FUEL   40 -> 22
HONAKER FUEL 36 -> 18 -> 36
```

Keine Ableitung:

```text
1 M978 = X GROUND_FUEL_PACKAGE
FUEL_LIGHT_06 capacity = X
FUEL_STD_07 capacity = Y
automatic FUEL_LIGHT/FUEL_STD selection
```

## 9. Generic SUPPLY

Für `GROUND_SUPPLY_PACKAGE` wurde weiterhin keine gleichwertige generische öffentliche `AUFTRAG:NewSUPPLY(...)`-Mission bestätigt.

```text
AMMO -> AMMOSUPPLY: ACCEPTED_TECHNICAL_BASELINE
FUEL -> FUELSUPPLY: SOURCE_REVIEWED / DCS_PENDING
generic SUPPLY -> separate MOOSE gap review
custom fallback -> only after documented gap + owner approval
```

## 10. Ergebnis

```text
MOOSE-first FUEL path found: YES
custom physical dispatcher required: NO
custom routing/pathfinding required: NO
existing approved road-spawn adapter reused: YES
owner-created dedicated fuel convoy template available: YES
OPSTRANSPORT required: NO
new non-MOOSE exception requested: NO
Stage 1A AMMO: ACCEPTED_TECHNICAL_BASELINE
Stage 1B FUEL: SOURCE_REVIEWED / STAGED / DCS_PENDING
```
