---
document_id: OMW-GROUND-EXECUTION-LAYER-CONCEPT
status: PLANNED
document_class: IMPLEMENTATION_CONCEPT
owning_policy: OMW-GOV-001
authoritative_for:
  - planned production boundary between Ground CampaignState integration and physical MOOSE Ground execution
  - owner-approved production scope of the road-aligned Ground WAREHOUSE materialization adapter
  - rejection of premature custom Ground routing and mission-contract abstractions
not_authoritative_for:
  - DCS runtime acceptance of the production adapter
  - final Ground tasking architecture
  - final MissionDemand or resupply orchestration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-execution-layer-concept
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground Execution Layer – MOOSE-first Produktionskonzept

## 1. Zweck

Die bestehende Ground-Foundation bleibt erhalten:

```text
CampaignState
-> Ground Initial Stock
-> Ground CampaignState Adapter
-> Ground Runtime Integration
```

Die physische Ausfuehrung bleibt MOOSE-first:

```text
Ground tasking
-> MOOSE COMMANDER / BRIGADE / PLATOON / AUFTRAG / ARMYGROUP
-> physical DCS GROUP
-> MOOSE lifecycle result
-> Ground CampaignState Adapter
-> CampaignState settlement
```

Es wird keine eigene Ground-Missionsengine, kein eigener Asset-Pool und kein eigenes Pathfinding-System eingefuehrt.

## 2. Korrektur des vorherigen Branch-Ansatzes

Die zuvor auf diesem Branch angelegten Module

```text
OMW_GroundRouteCatalog.lua
OMW_GroundExecutionContract.lua
tests/ground/test_ground_execution_contract.lua
```

wurden als vorzeitige Eigenabstraktion verworfen und wieder entfernt.

Begruendung:

```text
- MOOSE besitzt bereits PATHLINE-, Ground-Routing-, AUFTRAG-, BRIGADE-, PLATOON- und ARMYGROUP-Mechanismen.
- Ein eigener Route Catalog war vor Nachweis einer konkreten MOOSE-Luecke nicht gerechtfertigt.
- Der eigene Execution Contract fuehrte vorzeitig eigene Missionstypen und Routing-Felder ein.
- Die weitere Arbeit muss vom konkreten MOOSE-Auftrag ausgehen und nicht von einer vorab erfundenen Parallelabstraktion.
```

Damit gilt fuer die weitere Entwicklung:

```text
konkrete Ground-Aufgabe
-> passende MOOSE-Klasse / Methode / FSM
-> vorhandene Mission-Editor-Geometrie
-> nur nachgewiesene kleine Adapterluecke
```

## 3. TM01M-Status

TM01M bleibt:

```text
HISTORICAL_TEST_FIXTURE
```

Nicht uebernommen werden dessen Testmenues, Scheduler, autonome Convoy-Erzeugung, Ressourcenlogik oder Missionsorchestrierung.

Als technische Evidenz duerfen nur die bereits bestaetigten Verfahren weiterverwendet werden, insbesondere:

```text
- road-aligned Unitpositionen
- Heading entlang der Fahrtrichtung
- MOOSE-basierte Road-/Route-Geometrie
- kontrollierte Materialisierung am vorgesehenen Handoff-/ACCESS-Bereich
```

## 4. MOOSE-first Source Review

Gepinnter MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Fuer Ground-Materialisierung und Routing sind unter anderem source-geprueft:

```lua
WAREHOUSE:SetSpawnZone(...)
WAREHOUSE:AddOffRoadPath(...)

BRIGADE:AddPlatoon(...)
COMMANDER:AddBrigade(...)
COMMANDER:AddMission(...)

PLATOON:New(...)
COHORT:AddMissionCapability(...)
COHORT:CanMission(...)

AUFTRAG:NewPATROLZONE(...)
AUFTRAG:SetReturnToLegion(...)

GROUP:Route(...)
CONTROLLABLE:TaskGroundOnRoad(...)
COORDINATE:GetPathOnRoad(...)

PATHLINE:GetNumberOfPoints()
PATHLINE:GetPoint2DFromIndex(...)
PATHLINE:GetCoordinates()

SPAWN:InitSetUnitAbsolutePositions(...)
```

Die einzige fuer den aktuellen Scope nachgewiesene Luecke ist:

```text
WAREHOUSE bietet im gepinnten oeffentlichen API keinen Hook,
um vor dem Ground-Spawn individuelle absolute Unitpositionen und Headings einzuspeisen.
```

Der WAREHOUSE-/BRIGADE-/PLATOON-/ARMYGROUP-/AUFTRAG-Lifecycle selbst bleibt MOOSE.

## 5. Owner-Entscheidung 2026-08-21

Der Projektinhaber hat die bisher auf Acceptance 3-2 begrenzte Ausnahme fuer die Produktion erweitert.

Verbindliche Entscheidung fuer diesen Scope:

> Fuer alle Bodeneinheiten gilt: Wenn eine Einheit auf einer Strasse materialisiert/spawned werden soll, muss die Aufstellung immer road-aligned erfolgen. Die einzelnen Units werden auf der Strassenachse positioniert und entlang der vorgesehenen Fahrtrichtung ausgerichtet.

Genehmigt ist ausschliesslich die kleinstmoegliche Erweiterung des bestehenden MOOSE-WAREHOUSE-Materialisierungspfads:

```text
prepared MOOSE WAREHOUSE Ground template
-> road geometry from MOOSE COORDINATE / road path
-> absolute per-unit positions
-> per-unit heading
-> _DATABASE:Spawn(template)
-> normaler MOOSE WAREHOUSE / BRIGADE / PLATOON / ARMYGROUP / AUFTRAG lifecycle
```

Die Genehmigung gilt projektweit fuer Ground Assets, wenn der konkrete Materialisierungsvorgang als Road Spawn gekennzeichnet ist.

Nicht genehmigt sind dadurch:

```text
- eigener Warehouse-Ersatz
- eigener Asset-Pool
- eigener Ground Mission Controller
- eigener Route Catalog
- eigener Pathfinding-Algorithmus
- eigene Mission-FSM als Ersatz fuer MOOSE
- Raw-SPAWN als paralleler Ressourcen-/Assetpfad
```

## 6. Production-Modul

Der genehmigte Adapter liegt in:

```text
scripts/ground/OMW_GroundRoadSpawnAdapter.lua
```

Seine Aufgabe ist bewusst eng.

Ein Aufrufer installiert den Adapter an einer MOOSE-`BRIGADE`/`WAREHOUSE`-Instanz und liefert ueber `resolveRoadSpawn(...)` nur dann Road-Geometrie, wenn der konkrete Spawn auf einer Strasse erfolgen soll.

```text
resolveRoadSpawn(...) == nil
-> originaler MOOSE _SpawnAssetGroundNaval(...) Pfad

resolveRoadSpawn(...) -> { accessZone, forwardCoordinate, entityId }
-> road-aligned Materialisierung
```

Damit kann dieselbe BRIGADE weiterhin auch nicht-strassengebundene Ground-Spawns ueber den unveraenderten MOOSE-Pfad ausfuehren.

## 7. Geometrievertrag

Der Adapter verwendet die in Acceptance 3-2 bestaetigte MOOSE-Grundlage:

```lua
accessZone:GetCoordinate():GetClosestPointToRoad(false)
startRoad:GetPathOnRoad(forwardCoordinate, true, false, false, false)
COORDINATE:NewFromVec2(...)
coordinate:GetClosestPointToRoad(false)
```

Die Aufstellung wird nicht mehr pauschal auf den damaligen M-ATV-Abstand von 18 m festgelegt. Stattdessen werden Reihenfolge und Abstaende aus dem vorhandenen Asset-Template uebernommen und entlang der Strassenachse abgetragen. Damit wird keine neue allgemeine Fahrzeug-/Infanterie-Abstandspolicy erfunden.

Default-Sicherheitswerte des Adapters:

```text
rearClearanceM             20
headingSampleM             10
maxSnapM                   30
minimumTemplateSpacingM     0.5
```

Die ersten drei Werte stammen aus dem Acceptance-3-2-Verfahren; der minimale Template-Abstand ist nur ein Guard gegen kollabierte/ungueltige Template-Geometrie und keine taktische Formation.

## 8. MOOSE-Lifecycle-Grenze

Der Adapter veraendert nicht:

```text
Assetreservation
WAREHOUSE request queue
PLATOON capability
ARMYGROUP ownership
AUFTRAG mission lifecycle
MissionDone
Return/Returned
CampaignState settlement
```

Bei einem Road Spawn wird nur die vorbereitete Template-Geometrie ersetzt. Danach wird der gleiche interne Spawnpunkt verwendet, der in Acceptance 3-2 mit dem gepinnten MOOSE-Stand bereits praktisch bestaetigt wurde.

## 9. Routing bleibt MOOSE-first

Es existiert kein OMW Route Catalog mehr auf diesem Branch.

Routen werden erst im Kontext der konkreten MOOSE-Mission behandelt. Vorrang haben vorhandene MOOSE-Mechanismen und Mission-Editor-Geometrie, darunter je nach Aufgabe:

```text
PATHLINE
GROUP / ARMYGROUP routing
TaskGroundOnRoad
WAREHOUSE AddOffRoadPath
OPSTRANSPORT, wenn dessen Cargo-/Carrier-Modell zur Aufgabe passt
```

Erst wenn bei einer konkreten Mission eine weitere OMW-Mappingluecke nachgewiesen wird, darf die kleinste notwendige Mapping-Schicht entworfen werden.

## 10. Acceptance-Grenze

Der neue Production-Adapter ist noch nicht in DCS validiert.

Acceptance 3-2 belegt nur den frueheren sechs-Site-Testscope. Die jetzige projektweite Freigabe und Verallgemeinerung auf beliebige Ground-Templates muss in einem spaeteren gebuendelten Ground-Integrationstest abgedeckt werden.

Mindestens zu pruefen:

```text
- road-aligned materialization an mehreren Ground Nodes
- unterschiedliche Ground-Templates und Unit-Anzahlen
- korrekte Template-Reihenfolge und Abstaende
- korrektes Heading in Outbound-Richtung
- kein doppelter Spawn
- unveraenderte WAREHOUSE-/BRIGADE-/ARMYGROUP-Callbacks
- normaler Mission-/Return-/Loss-Lifecycle
- kein sichtbarer Teleport/Reconstitution-Pfad
```

## 11. Naechster Schritt

Nach diesem Commit ist die Materialisierungsgrenze geklaert. Der naechste Arbeitsblock darf wieder nur von einer konkreten Ground-Mission ausgehen und muss dafuer die passende MOOSE-Ausfuehrung pruefen. Es wird kein generischer Ground-Manager vorab erfunden.
