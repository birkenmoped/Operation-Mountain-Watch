---
document_id: OMW-MOOSE-GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW
status: PLANNED
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local MOOSE source review for the first physical Ground RESUPPLY vertical slice
  - selection of AMMOSUPPLY as the first physical Ground resource-transfer mission form
  - delivery and return acceptance boundary for the Joyce-to-Honaker AMMO test
not_authoritative_for:
  - DCS runtime acceptance
  - generic SUPPLY execution
  - CAS or CSAR execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground RESUPPLY Execution – MOOSE Source Review

## 1. Zweck

Dieses Review schließt für den ersten Physical-RESUPPLY-Vertical-Slice die MOOSE-First-Prüfung vor dem DCS-Test. Maßgeblich bleiben `OMW-GOV-001`, `OMW-GOV-MOOSE-FIRST`, Dokument 90, die aktuelle Ground-Production-Baseline und der tatsächliche gepinnte MOOSE-Source.

Erster Testfall:

```text
GROUND_NODE_HONAKER / GROUND_AMMO_PACKAGE
40 -> 20
-> REORDER demand
-> supplyParent GROUND_NODE_JOYCE
-> transfer 20
-> physical M1083
-> Honaker 40
```

## 2. Geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Geprüft wurden die Projekt-MOOSE-Dokumentation, der tatsächliche gepinnte `Moose.lua`-Source und die im Source enthaltenen offiziellen WAREHOUSE-/LEGION-Beispiele. Ein DCS-PASS wird daraus nicht abgeleitet.

## 3. Vorhandene OMW-Verträge

### CampaignState

CampaignState besitzt bereits den vollständigen strategischen TRANSFER-Lifecycle:

```text
ReserveResource(TRANSFER)
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

Alternativ:

```text
IN_TRANSIT -> MarkLost -> LOST
RESERVED/LOADING -> Cancel -> CANCELLED
```

Der physische MOOSE-Konvoi darf deshalb weder Menge noch strategischen Bestand selbst besitzen.

### MissionDemand

`OMW_MissionDemand.lua` ist auf `main` integriert und stellt `RESUPPLY`, AI-/Player-Assignment, Dedupe und terminale Zustände bereit. Der physische Executor arbeitet auf genau einem bestehenden Demand und erzeugt keinen zweiten Demand-Ledger.

### Ground thresholds

Für Ground `SUPPLY`, `AMMO` und `FUEL` gilt auf `main`:

```text
reorder  = 50% of target
critical = 25% of target
```

Für Honaker-AMMO bedeutet dies bei `target=40`:

```text
reorder  = 20
critical = 10
```

## 4. MOOSE `AUFTRAG:NewAMMOSUPPLY`

Im tatsächlichen `Moose.lua` ist die öffentliche Methode vorhanden:

```lua
AUFTRAG:NewAMMOSUPPLY(Zone)
```

Source-seitig setzt sie unter anderem:

```text
mission type: AMMOSUPPLY
target: Zone
ROE: WeaponHold
alarm: Auto
missionFraction: 1.0
missionWaypointRadius: 0
category: GROUND
```

Damit ist sie für den ersten AMMO-Transport die fachlich passendste vorhandene MOOSE-Missionsform. Sie ersetzt nicht den CampaignState-Transfer.

Ebenso source-seitig vorhanden:

```lua
AUFTRAG:NewFUELSUPPLY(Zone)
```

FUEL wird erst nach erfolgreichem AMMO-Vertical-Slice separat integriert.

## 5. Fahrweise und physische Ground-Ausführung

Verwendet werden ausschließlich vorhandene MOOSE-/OMW-Verträge:

```text
BRIGADE
PLATOON
ARMYGROUP
AUFTRAG
AUFTRAG.Type.AMMOSUPPLY
AUFTRAG:SetMissionSpeed(...)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
ARMYGROUP:RTZ(..., ENUMS.Formation.Vehicle.OnRoad)
```

Für die Materialisierung wird ausschließlich der bereits owner-approved `OMW_GroundRoadSpawnAdapter.lua` wiederverwendet. Dieser verändert nur die vorbereitete WAREHOUSE-Spawngeometrie; Request-, Asset-, PLATOON-, ARMYGROUP- und AUFTRAG-Lifecycle bleiben MOOSE-owned.

Es wird kein eigener Router, kein eigener Pathfinding-Algorithmus und kein eigener Convoy-Dispatcher eingeführt.

## 6. Delivery-Grenze

Die Source-Prüfung zeigt für `AMMOSUPPLY`: die Mission ist eine Zonen-/Supply-Mission; sie darf für OMW nicht mit dem strategischen Lieferabschluss gleichgesetzt werden. Für den Acceptance-Slice gilt deshalb fail-closed:

```text
exact ARMYGROUP
+
exact AMMOSUPPLY mission
+
OnAfterMissionExecute
+
ARMYGROUP:IsInZone(destination ACCESS zone) == true

=> CampaignState MarkDelivered(transactionId)
=> MissionDemand reservationState = DELIVERED
=> MissionDemand SUCCESS
```

Ohne positiven Zonenbeweis erfolgt keine Zielgutschrift.

Nach bestätigter Lieferung wird die Acceptance-Mission beendet und der physische Carrier ausdrücklich zurückgeführt:

```text
MissionDone
-> ARMYGROUP:RTZ(origin ACCESS zone, OnRoad)
-> OnAfterReturned
-> BRIGADE / Warehouse AddAsset
-> physical group removed
```

Dieser Return-Pfad entspricht dem bereits in Ground Acceptance 6 getesteten MOOSE-Lifecycle; der neue Joyce-Honaker-Transport selbst ist noch nicht in DCS validiert.

## 7. `OPSTRANSPORT` – bewusst nicht im ersten Slice

Die öffentliche `OPSTRANSPORT`-Klasse ist im gepinnten MOOSE vorhanden. Der ebenfalls auffindbare Entwurf `AUFTRAG:NewOPSTRANSPORT(...)` ist im gepinnten Source jedoch auskommentiert und darf nicht als öffentliche API verwendet werden.

Für OMW-Ground-AMMO ist die strategische Fracht eine normalisierte CampaignState-Menge, keine notwendige physische CargoGroup. Ein zusätzliches physisches Cargo-/Carrier-Ledger würde den ersten Slice unnötig verkomplizieren und birgt Doppelautoritätsrisiko.

Daher:

```text
Stage 1A AMMO:
CampaignState abstract cargo
+ MOOSE BRIGADE/PLATOON/ARMYGROUP
+ AUFTRAG AMMOSUPPLY

OPSTRANSPORT:
deferred for real physical cargo / troop transport cases
```

## 8. Generic SUPPLY

Im geprüften AUFTRAG-Scope wurde keine gleichwertige generische `SUPPLY`-Mission bestätigt. Für `GROUND_SUPPLY_PACKAGE` wird deshalb in diesem Schritt keine Ersatzmission erfunden.

Reihenfolge:

```text
1. AMMO -> AMMOSUPPLY
2. FUEL -> FUELSUPPLY
3. generic SUPPLY -> separate MOOSE gap review
4. falls erforderlich: owner decision before any custom fallback
```

## 9. Acceptance-Grenzen

Der erste Test darf nur folgende Aussage erzeugen:

```text
Joyce -> Honaker
GROUND_AMMO_PACKAGE = 20
one RESUPPLY MissionDemand
one CampaignState TRANSFER
one M1083 physical AMMOSUPPLY execution
one destination credit
explicit return to Joyce
```

Nicht Teil dieses Tests:

```text
generic SUPPLY
FUEL
multiple simultaneous demands
convoy attack response
CAS
CSAR
external server/process persistence
```

## 10. Ergebnis der Source-Prüfung

```text
MOOSE-first path found: YES
custom physical dispatcher required: NO
custom routing/pathfinding required: NO
existing approved road-spawn adapter reused: YES
OPSTRANSPORT required for first AMMO slice: NO
new non-MOOSE exception requested: NO
DCS runtime status: NOT RUN
```
