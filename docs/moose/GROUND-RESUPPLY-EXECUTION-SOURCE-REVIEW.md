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
  - DCS runtime acceptance beyond the explicitly documented run evidence
  - generic SUPPLY execution
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

## 1. Zweck

Dieses Review dokumentiert für den ersten Physical-RESUPPLY-Vertical-Slice die MOOSE-First-Prüfung und die nach den ersten beiden DCS-Läufen bestätigten beziehungsweise noch offenen Grenzen. Maßgeblich bleiben `OMW-GOV-001`, `OMW-GOV-MOOSE-FIRST`, die aktuelle Ground-Production-Baseline und der tatsächlich gepinnte MOOSE-Source.

Erster Testfall:

```text
GROUND_NODE_HONAKER / GROUND_AMMO_PACKAGE
40 -> 20
-> REORDER demand
-> supplyParent GROUND_NODE_JOYCE
-> transfer 20
-> protected physical convoy
-> Honaker 40
-> empty convoy RTZ Joyce
```

Die strategische Menge `20` wird im aktuellen Slice bewusst **nicht** in eine physische `package-per-truck`-Kapazität übersetzt.

## 2. Geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Geprüft wurden die Projekt-MOOSE-Dokumentation, der tatsächliche gepinnte `Moose.lua`-Source und die im Source enthaltenen WAREHOUSE-/LEGION-Pfade. Ein DCS-PASS wird nur für tatsächlich beobachtete Teilpfade ausgewiesen.

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

`OMW_MissionDemand.lua` stellt `RESUPPLY`, AI-/Player-Assignment, Dedupe und terminale Zustände bereit. Der physische Executor arbeitet auf genau einem bestehenden Demand und erzeugt keinen zweiten Demand-Ledger.

### Ground thresholds

Für Ground `SUPPLY`, `AMMO` und `FUEL` gilt:

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

Der Adapter ist bereits für mehrgliedrige Ground-Templates ausgelegt: er ermittelt die Abstände aller `asset.template.units`, projiziert jede Einheit auf die Straßenachse und übergibt anschließend das vollständige vorbereitete Template an den gepinnten WAREHOUSE-Spawnpfad. Für den Wechsel vom Einzel-M1083 auf einen bestehenden Mehrfahrzeug-Konvoi wird daher kein neuer Spawn-/Routing-Mechanismus benötigt.

Es wird kein eigener Router, kein eigener Pathfinding-Algorithmus und kein eigener Convoy-Dispatcher eingeführt.

## 6. Physische Convoy-Baseline für Stage 1A

Der Projektinhaber hat nach DCS-Lauf 2 entschieden, für Resupply die bereits in der Mission vorhandenen Convoy-Templates zu verwenden:

```text
TPL_BLUE_CONVOY_LIGHT_06
TPL_BLUE_CONVOY_STANDARD_07
```

Für den nächsten Stage-1A-AMMO-Acceptance-Lauf gilt:

```text
physical template: TPL_BLUE_CONVOY_LIGHT_06
strategic transfer: 20 GROUND_AMMO_PACKAGE
```

Diese Zuordnung ist **nur eine Acceptance-Physical-Representation**. Sie definiert ausdrücklich noch nicht:

```text
1 M1083 = X GROUND_AMMO_PACKAGE
LIGHT_06 capacity = X
STANDARD_07 capacity = Y
automatic convoy-class selection
```

Ein späterer produktiver Kapazitätsvertrag muss diese Werte separat festlegen, bevor die angeforderte strategische Menge automatisch LIGHT/ STANDARD auswählen darf.

## 7. Delivery-Grenze

Für OMW gilt fail-closed:

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

## 8. Gepinnter `Returned -> AddAsset`-Vertrag

Der tatsächliche MOOSE-Source zeigt:

```lua
function ARMYGROUP:onafterReturned(From, Event, To)
  if self.legion then
    self.legion:__AddAsset(10, self.group, 1)
  end
end
```

Damit muss eine Acceptance, die den Warehouse-Handoff verifiziert, nach `Returned` mindestens dieses framework-eigene 10-Sekunden-Fenster berücksichtigen. Der bisherige Harness prüfte nach 3 Sekunden und war damit source-seitig zu früh. Der nächste Harness verwendet 12 Sekunden vor der finalen `AddAsset`-/Cleanup-Prüfung.

## 9. DCS-Lauf 2 – bestätigter Teilpfad

Exakte Provenienz steht im Ergebnisdokument `OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-FAIL-2`.

Beobachtet wurden:

```text
DEMAND_RESERVED
PHYSICAL_EXECUTION_READY
BRIGADE_STARTED
MISSION_QUEUED type=AMMOSUPPLY
GROUP_MATERIALIZED
ARMY_ON_MISSION
DELIVERY_CONFIRMED ... quantity=20 ... demandStatus=SUCCESS
MISSION_DONE deliveryCommitted=true
RETURN_RTZ_ACTIVE
RETURN_RTZ_ISSUED ... zone=ZON_BLUE_GND_JOYCE_ACCESS formation=OnRoad
```

Danach endete der Harness mit dem bereits seit Teststart laufenden globalen `TIMEOUT seconds=1800`, bevor `Returned` und `AddAsset` erreicht werden konnten.

Daraus folgt:

```text
Joyce -> Honaker AMMOSUPPLY execution: PRACTICALLY CONFIRMED FOR RUN-2 SCOPE
destination-zone delivery proof: PRACTICALLY CONFIRMED
CampaignState delivery settlement: PRACTICALLY CONFIRMED
MissionDemand SUCCESS settlement: PRACTICALLY CONFIRMED
RTZ command accepted: PRACTICALLY CONFIRMED
full return to Joyce: NOT YET CONFIRMED
Returned -> AddAsset: NOT YET CONFIRMED IN THIS SLICE
```

## 10. Acceptance-Timeout-Grenze

Der nächste Harness trennt die Zeitfenster:

```text
OUTBOUND_TIMEOUT_SEC = 1800
- läuft ab Teststart
- wird wirkungslos, sobald Delivery bestätigt ist

RETURN_TIMEOUT_SEC = 1800
- startet erst nach akzeptiertem RTZ
- prüft den tatsächlichen Rückweg unabhängig vom Hinweg
```

Damit wird keine neue Runtime-Logik eingeführt; es handelt sich ausschließlich um One-shot-`SCHEDULER`-Gates der Acceptance.

## 11. `OPSTRANSPORT` – bewusst nicht im ersten Slice

Die öffentliche `OPSTRANSPORT`-Klasse ist im gepinnten MOOSE vorhanden. Der ebenfalls auffindbare Entwurf `AUFTRAG:NewOPSTRANSPORT(...)` ist im gepinnten Source jedoch auskommentiert und darf nicht als öffentliche API verwendet werden.

Für OMW-Ground-AMMO ist die strategische Fracht eine normalisierte CampaignState-Menge, keine notwendige physische CargoGroup. Ein zusätzliches physisches Cargo-/Carrier-Ledger würde den ersten Slice unnötig verkomplizieren und birgt Doppelautoritätsrisiko.

Daher:

```text
Stage 1A AMMO:
CampaignState abstract cargo
+ MOOSE BRIGADE/PLATOON/ARMYGROUP
+ AUFTRAG AMMOSUPPLY
+ existing OMW convoy template as physical representation

OPSTRANSPORT:
deferred for real physical cargo / troop transport cases
```

## 12. Generic SUPPLY

Im geprüften AUFTRAG-Scope wurde keine gleichwertige generische `SUPPLY`-Mission bestätigt. Für `GROUND_SUPPLY_PACKAGE` wird deshalb in diesem Schritt keine Ersatzmission erfunden.

Reihenfolge:

```text
1. AMMO -> AMMOSUPPLY
2. FUEL -> FUELSUPPLY
3. generic SUPPLY -> separate MOOSE gap review
4. falls erforderlich: owner decision before any custom fallback
```

## 13. Aktuelle Acceptance-Grenze

Der nächste Test darf nur folgende Aussage erzeugen:

```text
Joyce -> Honaker
GROUND_AMMO_PACKAGE = 20
one RESUPPLY MissionDemand
one CampaignState TRANSFER
one TPL_BLUE_CONVOY_LIGHT_06 physical AMMOSUPPLY execution
one destination credit
explicit full-convoy return to Joyce
Returned -> Warehouse AddAsset -> physical cleanup
```

Nicht Teil dieses Tests:

```text
generic SUPPLY
FUEL
automatic LIGHT_06 vs STANDARD_07 capacity selection
multiple simultaneous demands
convoy attack response
CAS
CSAR
external server/process persistence
```

## 14. Ergebnis der Source-Prüfung

```text
MOOSE-first path found: YES
custom physical dispatcher required: NO
custom routing/pathfinding required: NO
existing approved road-spawn adapter reused: YES
existing mission convoy template reused: YES
OPSTRANSPORT required for first AMMO slice: NO
new non-MOOSE exception requested: NO
DCS delivery path status: PARTIALLY CONFIRMED
DCS full roundtrip status: NOT YET CONFIRMED
```
