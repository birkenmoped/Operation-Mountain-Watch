---
document_id: OMW-MOOSE-GROUND-GENERIC-RESUPPLY-STAGE-1D-SOURCE-REVIEW
status: PLANNED
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local MOOSE-first source review for Stage 1D non-AMMO/non-FUEL Ground RESUPPLY
  - candidate mapping of SUPPLY, PERSONNEL and VEHICLE transfers to available MOOSE transport mechanisms
not_authoritative_for:
  - accepted production executor for Stage 1D-P PERSONNEL or Stage 1D-V VEHICLE
  - DCS runtime acceptance of TROOPTRANSPORT, OPSTRANSPORT storage transport or cohort relocation
  - permission to make DCS warehouses a second strategic resource authority
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration-continuation
source_commit: 4771420480a994ce7356abc618ae0a3189dc105e
validated_in_dcs: partial
---

# Ground Stage 1D – MOOSE-first Source Review für verbleibende RESUPPLY-Ressourcen

## 1. Ausgangslage

Stage 1A, 1C und 1B2 sind auf `main` integriert. Für den Ground-RESUPPLY-Pfad sind damit bereits folgende technische Baselines vorhanden:

```text
AMMO
-> AUFTRAG:NewAMMOSUPPLY(...)
-> ACCEPTED_TECHNICAL_BASELINE

FUEL
-> AUFTRAG:NewFUELSUPPLY(...)
-> BRIGADE:AddMission(...)
-> ACCEPTED_TECHNICAL_BASELINE

neutraler physischer Meta-Transport
-> AUFTRAG:NewNOTHING(...)
-> ACCEPTED_TECHNICAL_BASELINE
```

Stage 1D behandelt ausdrücklich **nicht** erneut AMMO oder FUEL. Zu prüfen sind die verbleibenden strategischen Ground-Ressourcen:

```text
SUPPLY
PERSONNEL
VEHICLE
```

Die aktuelle Ground-Ressourcenbaseline definiert:

```text
PERSONNEL = strategischer Headcount
VEHICLE   = eine strategische Fahrzeugeinheit
SUPPLY    = normalisierte allgemeine Sustainment-Einheit
```

`CampaignState` bleibt für diese Ressourcen die einzige strategische Autorität.

## 2. Geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Prüfreihenfolge:

```text
MOOSE Develop-Dokumentation
-> tatsächlich verwendete Moose.lua
-> vorhandene OMW Ground-Source-Reviews
-> offizielle MOOSE-Missionsrepositories, soweit auffindbar
```

## 3. Ergebnis: verfügbare Transportmechanismen

### 3.1 `AUFTRAG:NewTROOPTRANSPORT(...)`

Im gepinnten Source vorhanden und öffentlich:

```lua
AUFTRAG:NewTROOPTRANSPORT(
  TransportGroupSet,
  DropoffCoordinate,
  PickupCoordinate,
  PickupRadius
)
```

Source-Kategorie:

```text
AIR ROTARY, GROUND
```

Die Mission transportiert reale `GROUP`-/`SET_GROUP`-Objekte. Sie transportiert **keinen abstrakten CampaignState-Headcount**.

Folgerung:

```text
PERSONNEL
-> TROOPTRANSPORT ist nur passend,
   wenn tatsächlich eine physische Infanteriegruppe die strategische Verlegung repräsentiert.
```

Eine bloße `PERSONNEL +N`-Buchung darf nicht dadurch als TROOPTRANSPORT ausgegeben werden, dass keine physische Cargo-Gruppe existiert.

Status für OMW Stage 1D:

```text
SOURCE_REVIEWED_CANDIDATE
DCS_ACCEPTANCE_REQUIRED
```

### 3.2 `AUFTRAG:NewCARGOTRANSPORT(...)`

Im gepinnten Source vorhanden und öffentlich.

Grenzen:

```text
AIR ROTARY only
external sling-load cargo
StaticCargo required
DropZone must be a Mission-Editor zone with DCS zone ID
```

Damit ist `CARGOTRANSPORT` **kein generischer Ground-Convoy-Executor** für normalisierte `SUPPLY`-Einheiten.

Status:

```text
NOT_PRIMARY_FOR_STAGE_1D_GROUND_CONVOY
```

### 3.3 `AUFTRAG:NewFREIGHTTRANSPORT(...)`

Im gepinnten Source vorhanden und öffentlich.

Grenzen:

```text
AIR transport
STATIC / SET_STATIC cargo
Destination = AIRBASE
internal cargo transport
```

Damit ist `FREIGHTTRANSPORT` ebenfalls kein Ground-Convoy-Executor für Stage 1D.

Status:

```text
NOT_PRIMARY_FOR_STAGE_1D_GROUND_CONVOY
```

### 3.4 `OPSTRANSPORT`

`OPSTRANSPORT` ist im gepinnten Source als eigenständige öffentliche Klasse vorhanden:

```lua
OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
```

Carrier können laut Source unter anderem Ground-Gruppen sein. Die Klasse besitzt außerdem einen Storage-Transportpfad:

```lua
OPSTRANSPORT:AddCargoStorage(
  StorageFrom,
  StorageTo,
  CargoType,
  CargoAmount,
  CargoWeight,
  TransportZoneCombo
)
```

Dieser Storage-Pfad ist ausdrücklich für `STORAGE`-Wrapper von **DCS-Warehouses** ausgelegt.

Für OMW gilt deshalb eine harte Authority-Grenze:

```text
CampaignState strategic SUPPLY/PERSONNEL/VEHICLE
!=
DCS warehouse storage ownership
```

`AddCargoStorage(...)` darf nicht einfach als strategischer CampaignState-Transfer übernommen werden. Das würde dieselbe Ressource parallel durch CampaignState und DCS/MOOSE-Storage führen.

Wichtiger Source-Befund:

```text
AUFTRAG.Type.OPSTRANSPORT existiert,
aber AUFTRAG:NewOPSTRANSPORT(...) ist im tatsächlich gepinnten Moose.lua auskommentiert.
```

Deshalb darf OMW **keine öffentliche `AUFTRAG:NewOPSTRANSPORT(...)`-API behaupten oder aufrufen**.

Direktes `OPSTRANSPORT` bleibt ein source-geprüfter Kandidat für echte Cargo-/Troop-Transporte, benötigt aber einen separaten DCS-Test und eine saubere CampaignState-Adaptergrenze.

Status:

```text
SOURCE_REVIEWED
NOT_ACCEPTED_FOR_GENERIC_CAMPAIGNSTATE_SUPPLY
```

### 3.5 Cohort relocation

Der gepinnte Source bietet öffentliche Relocation-Einstiege auf LEGION-/COMMANDER-Ebene:

```lua
LEGION:RelocateCohort(...)
COMMANDER:RelocateCohort(...)
```

Intern erzeugt MOOSE dazu einen `RELOCATECOHORT`-AUFTRAG. Die interne AUFTRAG-Fabrik heißt:

```lua
AUFTRAG:_NewRELOCATECOHORT(...)
```

und ist ausdrücklich `PRIVATE`.

Der öffentliche Relocation-Pfad bewegt einen **gesamten COHORT** und alle zugehörigen Assets von einer LEGION zu einer anderen. Er ist daher kein Ersatz für einen beliebigen partiellen Transfer von `VEHICLE = N`.

Geeignetes späteres Einsatzfeld:

```text
bewusste organisatorische Verlegung eines vollständigen MOOSE-COHORT
```

Nicht automatisch geeignet für:

```text
MissionDemand RESUPPLY payload VEHICLE +1 / +2 / +N
```

Status:

```text
SOURCE_REVIEWED_CANDIDATE_FOR_WHOLE_COHORT_RELOCATION
NOT_GENERIC_VEHICLE_RESUPPLY
```

## 4. Stage-1D-Ressourcenmatrix

| CampaignState-Ressource | Spezialisierter MOOSE-Pfad gefunden | Bewertung |
|---|---|---|
| `SUPPLY` | nein | Kein dedizierter Ground-SUPPLY-AUFTRAG gefunden. `OPSTRANSPORT:AddCargoStorage(...)` ist DCS-Warehouse-Storage und verletzt bei direkter strategischer Verwendung die OMW-Authority-Grenze. |
| `PERSONNEL` | bedingt `AUFTRAG:NewTROOPTRANSPORT(...)` | Nur wenn eine reale Cargo-Infanteriegruppe transportiert wird. Kein abstrakter Headcount-Transport. Eigener DCS-Test erforderlich. |
| `VEHICLE` | bedingt `LEGION/COMMANDER:RelocateCohort(...)` | Nur ganze Cohorts; kein beliebiger partieller Vehicle-Quantity-Transfer. |

## 5. Konsequenz für den neutralen `NOTHING`-Pfad

Stage 1C hat bereits bewiesen, dass ein MOOSE-`AUFTRAG:NewNOTHING(...)` als neutraler physischer Ground-Transportträger in der dokumentierten Acceptance-Provenienz funktionieren kann.

Die Stage-1D-Prüfung ergibt **keine** spezialisierte MOOSE-Ground-Mission für normalisierte allgemeine `SUPPLY`-Einheiten.

Damit ist für `SUPPLY` der kleinste MOOSE-first-konforme Kandidat:

```text
CampaignState SUPPLY transfer reservation
-> existing Ground logistics PLATOON / convoy asset
-> AUFTRAG:NewNOTHING(destinationZone)
-> BRIGADE:AddMission(...)
-> physical arrival evidence
-> exactly-once CampaignState settlement
-> explicit MOOSE ARMYGROUP RTZ return / Returned / Warehouse handoff
```

Das ist keine Native-DCS- oder Nicht-MOOSE-Ausnahme. Es verwendet ausschließlich den bereits akzeptierten MOOSE-Lifecycle, behauptet aber auch keine nicht vorhandene MOOSE-`SUPPLYSUPPLY`-Mission.

Für `PERSONNEL` und `VEHICLE` wird dieser neutrale Pfad **nicht automatisch** übernommen. Beide Ressourcen repräsentieren strategische Assets/Headcount und benötigen einen eigenen physischen Repräsentationsvertrag.

## 6. Stage-1D-S Runtime-Akzeptanz

Stage 1D-S wurde am 29.08.2026 im DCS-Lauf praktisch bestätigt.

```text
status: ACCEPTED_TECHNICAL_BASELINE
runtime_result: PASS
branch: agent/automatic-response-orchestration-continuation
build_commit: 4771420480a994ce7356abc618ae0a3189dc105e
builder_version: GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-2
bundle_sha256: C805C996A2028629251F833F0E0D0ED06F462C15271A1166E0DB8DF0BA105CE3
mission_sha256: BA556641A9ECAD629FDBE62AEA5CC30E22E081B81B4188C136855026F70D0907
dcs: 2.9.29.27278 MT
```

Beobachteter Lifecycle:

```text
START
-> DEMAND_RESERVED
-> MISSION_QUEUED
-> ROAD_ALIGNED_WAREHOUSE_SPAWN
-> GROUP_MATERIALIZED
-> ARMY_ON_MISSION
-> DESTINATION_ZONE_ENTERED
-> MISSION_EXECUTE_OBSERVED
-> DELIVERY_CONFIRMED
-> MISSION_DONE
-> delayed explicit ARMYGROUP:RTZ(Joyce ACCESS, OnRoad)
-> RETURNED_HANDOFF
-> WAREHOUSE_ADD_ASSET
-> PASS
```

Der erfolgreiche Build stellt bewusst den bereits in Stage 1C bestandenen NOTHING-Vertrag wieder her. Eine zuvor eingeführte Abweichung auf einen FUELSUPPLY-artigen automatischen Return-Pfad war eine unnötige Regression und wurde entfernt. Es wurde keine neue interne Zielzone und keine eigene Ground-Routinglogik eingeführt.

Vollständige Evidenz:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-5.md
mission/tests/ground-resupply-execution/results/2026-08-29-ground-supply-resupply-nothing-acceptance-1-pass-1.md
```

## 7. Verbleibender Stage-1D-Schnitt

```text
Stage 1D-P
PERSONNEL
-> TROOPTRANSPORT nur mit realer Cargo-Gruppe
-> Source-/Design-Reconciliation

Stage 1D-V
VEHICLE
-> whole-cohort relocation separat von quantity resupply unterscheiden
-> Source-/Design-Reconciliation
```

Damit wird vermieden, dass `PERSONNEL`, `VEHICLE` und `SUPPLY` trotz unterschiedlicher Semantik künstlich durch denselben Executor gepresst werden.

## 8. DCS-Testpflicht für verbleibende Ressourcen

Stage 1D-S ist technisch akzeptiert. Für Stage 1D-P und Stage 1D-V bleiben eigene Acceptance-Nachweise erforderlich. Insbesondere sind vor produktiver Freigabe zu klären:

```text
physical representation contract
CampaignState stable resource identity
MOOSE executor semantics
exactly-once settlement
loss / damage / partial return behavior
restart / reconciliation behavior
no second resource authority
```
