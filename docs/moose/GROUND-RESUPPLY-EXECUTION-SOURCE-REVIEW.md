---
document_id: OMW-MOOSE-GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local MOOSE source review for physical Ground RESUPPLY execution
  - accepted Stage 1A AMMOSUPPLY lifecycle
  - failed Stage 1B FUELSUPPLY OMW meta-resupply experiment
  - WAREHOUSE SELFPROPELLED replacement-candidate source review
  - AUFTRAG NOTHING generic movement-candidate source review
not_authoritative_for:
  - production generic Ground RESUPPLY executor
  - WAREHOUSE SELFPROPELLED runtime acceptance
  - AUFTRAG NOTHING runtime acceptance
  - CAS or CSAR execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
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

MOOSE-Dokumentation, tatsächlicher gepinnter Source und offizielle Beispielbestände werden getrennt betrachtet. Runtime-Aussagen gelten nur für dokumentierte DCS-Provenienz.

## 2. Strategische Grenze

```text
CampaignState = einzige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Zustand
MOOSE = physische operative Ausführung
DCS groups = temporäre physische Repräsentation
```

`GROUND_AMMO_PACKAGE`, `GROUND_FUEL_PACKAGE` und `GROUND_SUPPLY_PACKAGE` sind strategische CampaignState-Waren. Eine physische Truck-/Tanker-Anzahl definiert keine Package-Kapazität.

Insbesondere hat Stage 1B keine reale DCS-Fuel-Menge in Litern/Gallonen transportiert.

## 3. Stage 1A – AMMO akzeptiert

DCS-bestätigter MOOSE-first Pfad:

```text
BRIGADE / PLATOON / ARMYGROUP
AUFTRAG:NewAMMOSUPPLY(destinationZone)
SetMissionSpeed(27)
SetFormation(OnRoad)
SetReturnToLegion(false)
CampaignState delivery after exact destination-zone proof
MissionDone
30 s settlement
same ARMYGROUP RTZ Joyce ACCESS / OnRoad
Returned
LEGION/Warehouse AddAsset
physical cleanup
```

Provenienz:

```text
Acceptance source/build commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
Bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v18.miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
Result: PASS
```

Nur dieser AMMO-Scope ist praktisch validiert.

## 4. Stage 1B – FUELSUPPLY Versuch

Der gepinnte Source enthält:

```lua
AUFTRAG:NewFUELSUPPLY(Zone)
```

sowie `AUFTRAG.Type.FUELSUPPLY` und `AUFTRAG.SpecialTask.FUELSUPPLY`.

Die Source-Prüfung zeigt zugleich den vorgesehenen BRIGADE-Kontext:

```text
BRIGADE:AddRefuellingZone(zone)
-> BRIGADE status processing
-> AUFTRAG:NewFUELSUPPLY(supplyzone.zone)
```

Damit ist `FUELSUPPLY` nachweislich mit einer operativen Refuelling-Zone verknüpft. Eine offizielle aktuelle Demo für den von OMW versuchten abstrakten Warehouse-to-Warehouse-Fuel-Package-Roundtrip wurde nicht gefunden.

Der DCS-Lauf widerlegt die zuvor angenommene Gleichsetzung mit dem Stage-1A-AMMOSUPPLY-Lifecycle für diesen OMW-Scope:

```text
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=FUELSUPPLY
-> no OnAfterMissionExecute
-> no DELIVERY_CONFIRMED
-> no MissionDone
-> no RTZ
FAIL OUTBOUND_TIMEOUT
missionExecuteCount=0
missionDoneCount=0
```

Deshalb gilt:

```text
AUFTRAG:NewFUELSUPPLY(Zone)
= available MOOSE API
= valid Refuelling-Zone concept candidate
= REJECTED_FOR_CURRENT_OMW_META_RESUPPLY_EXECUTOR
```

Das ist keine generelle Aussage, dass `FUELSUPPLY` fehlerhaft sei.

Detailergebnis:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-fuel-resupply-acceptance-1-fail-1.md
```

## 5. MOOSE-native Ersatzkandidat A: WAREHOUSE SELFPROPELLED

Der gepinnte MOOSE-Source dokumentiert einen direkten Warehouse-zu-Warehouse-Assettransfer:

```text
WAREHOUSE:AddRequest(...)
WAREHOUSE.TransportType.SELFPROPELLED
```

`SELFPROPELLED` ist definiert als:

```text
Assets go to their destination by themselves. No transport carrier needed.
```

Für Ground-Assets führt WAREHOUSE den Request selbst aus und routet den Ground-Asset-Group über `_RouteGround(...)`. Definierte `AddOffRoadPath(...)`-Verbindungen haben Vorrang; andernfalls wird die Straßenverbindung zwischen den Warehouses verwendet.

Besonders relevant ist die im gepinnten Source eingebettete Warehouse-Dokumentation, Example 15:

```lua
warehouse.Kobuleti:AddAsset("M978", 20)
warehouse.London:AddAsset("M818", 20)
warehouse.Kobuleti:AddOffRoadPath(warehouse.London, ...)
warehouse.Kobuleti:AddRequest(
  warehouse.London,
  WAREHOUSE.Descriptor.ATTRIBUTE,
  WAREHOUSE.Attribute.GROUND_TRUCK,
  WAREHOUSE.Quantity.ALL
)
```

Die Dokumentation beschreibt ausdrücklich, dass Trucks an den Warehouses gespawnt und zum jeweils anderen Warehouse geführt werden. Damit ist generischer selbstfahrender Ground-Asset-Transfer ein belegter MOOSE-Anwendungsfall.

### 5.1 Harte Handoff-Grenze

`WAREHOUSE:onafterArrived(...)` ist für mobile Ground-Groups nicht optional:

```text
Arrived
-> receiving warehouse selected
-> RouteGroundTo(receiving warehouse coordinate, 30% max speed, Off Road)
-> receivingWarehouse:__AddAsset(60, group)
```

`WAREHOUSE:onafterAddAsset(...)` nimmt das bekannte Asset in den Ziel-Stock auf und entfernt die lebende physische Gruppe über OPSGROUP-Despawn beziehungsweise Group-Destroy.

Damit ist für einen Roundtrip zwingend:

```text
outbound materialization
-> physical drive
-> destination absorption/despawn
-> destination warehouse stock
-> later return request
-> new materialization
-> physical return drive
```

Der gepinnte Source enthält keinen öffentlichen Schalter, der dieses 60-s-Arrival-Absorbieren deaktiviert und denselben physischen Group-Lifecycle für eine sofortige Rückfahrt erhält.

`WAREHOUSE:SetSpawnZone(zone, maxdist)` erlaubt zwar eine separate Ground-Spawnzone bis standardmäßig 5000 m vom Warehouse, löst aber nur die Materialisierungsposition. Es ändert nicht den Arrival-`__AddAsset(60, group)`-Pfad.

Folge für OMW:

```text
WAREHOUSE SELFPROPELLED = framework-native Warehouse transfer
same physical convoy roundtrip = NOT PROVIDED BY THIS PUBLIC LIFECYCLE
no observable spawn/despawn = only potentially satisfiable via intentionally hidden base handoff areas
```

Ob ein bewusst verdeckter Warehouse-Handoff als zulässig gilt, ist eine Owner-/Designentscheidung und wird nicht stillschweigend angenommen.

## 6. MOOSE-native Ersatzkandidat B: AUFTRAG NOTHING als neutraler Move-and-Wait-Pfad

Der gepinnte Source enthält:

```lua
AUFTRAG:NewNOTHING(RelaxZone)
```

Dokumentierter Zweck:

```text
[GROUND, NAVAL] Create a mission to do NOTHING.
RelaxZone = zone where the assets are supposed to do nothing.
```

Source-seitig bestätigt:

```text
AUFTRAG.Type.NOTHING
AUFTRAG.SpecialTask.NOTHING
categories = GROUND, NAVAL
mission target = RelaxZone
WeaponHold
AlarmState.Auto
missionFraction = 1.0
```

Für `OPSGROUP:RouteToMission(...)` wird bei `NOTHING` eine zufällige Coordinate innerhalb der Zielzone gewählt. Für `ARMYGROUP` wird anschließend über den normalen MOOSE-Waypoint-/Routingpfad zur Mission gefahren. `AUFTRAG:SetMissionSpeed(...)` und `AUFTRAG:SetFormation(...)` sind öffentliche Setter; `mission.optionFormation` wird beim Ground-Mission-Waypoint verwendet.

Beim Task-Start führt `AUFTRAG.SpecialTask.NOTHING` für ARMYGROUP/NAVYGROUP einen FullStop aus. `TaskCancel` behandelt `NOTHING` ausdrücklich als `done=true`; damit existiert source-seitig ein sauberer MOOSE-Pfad:

```text
move to destination zone
-> NOTHING executes / group stops
-> OMW may evaluate exact physical arrival
-> cancel mission
-> MissionDone lifecycle
-> same ARMYGROUP remains available for subsequent RTZ
```

Das ist semantisch kein Fuel-, Ammo- oder Cargo-Transportmodell. Genau deshalb ist es für CampaignState-Meta-Waren als **neutraler physischer Move-and-Wait-Kandidat** interessanter als das zweckgebundene `FUELSUPPLY`.

Wichtig: In `MOOSE_MISSIONS` und `MOOSE_MISSIONS_UNPACKED` wurde bei der aktuellen Suche kein dediziertes `NewNOTHING`-Beispiel gefunden. Deshalb bleibt dieser Pfad `SOURCE_REVIEWED / DCS_PENDING`.

## 7. Vergleich der Kandidaten

```text
WAREHOUSE SELFPROPELLED
+ offizieller Warehouse-Ground-Transfer-Anwendungsfall
+ Example 15 mit M978/M818
+ MOOSE-eigener Request-/Arrival-/Stock-Lifecycle
- Ziel-Absorption/Despawn nach 60 s fest im Lifecycle
- same physical convoy roundtrip nicht vorgesehen
- strategische OMW-Ware darf trotzdem nicht zum MOOSE-Assetbestand werden

AUFTRAG NOTHING
+ direkte öffentliche MOOSE-Mission
+ GROUND ausdrücklich unterstützt
+ neutral gegenüber Cargo-/Fuel-Semantik
+ normaler ARMYGROUP-Waypoint-/Mission-/Cancel-Lifecycle
+ same physical group kann source-seitig nach MissionDone weiterverwendet werden
+ kompatibel mit CampaignState als alleiniger Warenautorität
- kein dediziertes offizielles Demo gefunden
- OMW-Verwendung als Meta-Resupply-Bewegungsauftrag noch nicht in DCS validiert
```

Damit ist `AUFTRAG:NewNOTHING(destinationZone)` derzeit der kleinere Kandidat für einen **sichtbar kontinuierlichen** Meta-Resupply-Convoy, während `WAREHOUSE SELFPROPELLED` der stärker dokumentierte Kandidat für einen **Warehouse-owned Assettransfer mit Absorption/Rematerialisierung** bleibt.

## 8. Nicht geeignete Alternativen

`STORAGE`-/OPSTRANSPORT-Fuel-Cargo darf nicht zur zweiten strategischen Fuel-Autorität werden. CampaignState bleibt autoritativ.

`AUFTRAG:NewCARGOTRANSPORT(...)` ist laut gepinntem Source ein AIR-ROTARY Slingload-Pfad. `AUFTRAG:NewFREIGHTTRANSPORT(...)` ist ein AIR-Transportpfad für interne Cargo-Items. Der `AUFTRAG:NewOPSTRANSPORT(...)`-Konstruktor ist im gepinnten Source auskommentiert und damit kein nutzbarer öffentlicher Pfad.

Ein eigener Native-DCS- oder Parallel-Dispatcher bleibt ohne dokumentierten MOOSE-Gap und Owner-Freigabe ausgeschlossen.

## 9. Aktueller Status und Entscheidungsgrenze

```text
Stage 1A AMMO / AMMOSUPPLY: ACCEPTED_TECHNICAL_BASELINE
Stage 1B FUEL / FUELSUPPLY meta-resupply: FAILED / CLOSED
GROUND_FUEL_PACKAGE strategic model: RETAIN AS CAMPAIGNSTATE META RESOURCE
Fuel convoy templates: RETAIN AS PHYSICAL REPRESENTATIONS
WAREHOUSE SELFPROPELLED: SOURCE_REVIEWED CANDIDATE / ABSORB-REMATERIALIZE LIFECYCLE
AUFTRAG NOTHING: SOURCE_REVIEWED CANDIDATE / SAME-GROUP MOVE-AND-WAIT
replacement DCS acceptance: NOT YET STAGED
production executor: NOT YET CREATED
```

Vor einem neuen DCS-Lauf ist nur noch die Designentscheidung erforderlich, welcher physische Vertrag gewollt ist:

```text
A) Warehouse-owned transfer mit verdecktem Despawn/Respawn-Handoff
oder
B) same physical convoy Hin-/Rückweg mit AUFTRAG NOTHING als neutralem MOOSE-Move-and-Wait-Auftrag
```

Keine der beiden Varianten verändert die strategische Ressourcenhoheit von CampaignState.
