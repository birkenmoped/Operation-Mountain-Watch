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
not_authoritative_for:
  - production generic Ground RESUPPLY executor
  - WAREHOUSE SELFPROPELLED runtime acceptance
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

## 5. MOOSE-native Ersatzkandidat: WAREHOUSE SELFPROPELLED

Der gepinnte MOOSE-Source dokumentiert einen direkten Warehouse-zu-Warehouse-Assettransfer:

```text
WAREHOUSE:AddRequest(...)
WAREHOUSE.TransportType.SELFPROPELLED
```

`SELFPROPELLED` ist definiert als:

```text
Assets go to their destination by themselves. No transport carrier needed.
```

Für Ground-Assets führt `WAREHOUSE:onafterRequestSpawned()` direkt `_RouteGround(group, Request)` aus. `_RouteGround` verwendet eine definierte Off-Road-Verbindung, falls vorhanden; andernfalls wird die Straßenverbindung zwischen den Warehouses verwendet.

Besonders relevant ist MOOSE Warehouse Example 15:

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

Die Dokumentation beschreibt dazu ausdrücklich, dass Trucks an beiden Warehouses gespawnt und zum jeweils anderen Warehouse geführt werden.

Damit ist der generische physische Truck-Transfer ein wesentlich besser belegter MOOSE-first Kandidat als `FUELSUPPLY` für Meta-Waren.

## 6. Wichtige Handoff-Grenze des WAREHOUSE-Pfads

Der Source zeigt bei `WAREHOUSE:onafterArrived(...)`:

```text
self-propelled asset
-> receiving warehouse selected
-> mobile ground group routed toward warehouse coordinate
-> warehouse:__AddAsset(60, group)
```

Das bedeutet: MOOSE übernimmt das physische Asset nach der Ankunft wieder in den Warehouse-Stock. Ein späterer Rücktransport wird aus diesem Stock erneut materialisiert.

Für OMW ist daher vor Adoption zwingend zu klären:

```text
Framework-owned destination handoff/despawn
+ later warehouse materialization for return
versus
OMW rule: no observable spawn/despawn/teleport
```

Dieser Punkt ist derzeit der entscheidende Architektur-/Acceptance-Gate. Er wird nicht durch eine eigene Route oder einen eigenen Dispatcher umgangen.

## 7. Nicht geeignete Alternativen

`STORAGE`-/OPSTRANSPORT-Fuel-Cargo darf nicht zur zweiten strategischen Fuel-Autorität werden. CampaignState bleibt autoritativ.

`AUFTRAG:NewCARGOTRANSPORT(...)` ist kein generischer Ground-Meta-Warenpfad. `AUFTRAG:NewOPSTRANSPORT(...)` ist im gepinnten Stand nicht als nutzbarer öffentlicher Konstruktor bestätigt.

Ein eigener Native-DCS- oder Parallel-Dispatcher bleibt ohne dokumentierten MOOSE-Gap und Owner-Freigabe ausgeschlossen.

## 8. Aktueller Status

```text
Stage 1A AMMO / AMMOSUPPLY: ACCEPTED_TECHNICAL_BASELINE
Stage 1B FUEL / FUELSUPPLY meta-resupply: FAILED / CLOSED
GROUND_FUEL_PACKAGE strategic model: RETAIN AS CAMPAIGNSTATE META RESOURCE
Fuel convoy templates: RETAIN AS PHYSICAL REPRESENTATIONS
WAREHOUSE SELFPROPELLED: SOURCE_REVIEWED CANDIDATE
WAREHOUSE visual handoff/despawn boundary: OPEN
replacement DCS acceptance: NOT YET STAGED
production executor: NOT YET CREATED
```

Kein weiterer DCS-Lauf wird angesetzt, bevor die Warehouse-Handoff-Grenze geklärt und der kleinste MOOSE-first Ersatzpfad festgelegt ist.
