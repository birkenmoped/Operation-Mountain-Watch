---
document_id: OMW-MOOSE-GROUND-MATERIALIZATION-ROUTING-REVIEW
status: PLANNED
document_class: MOOSE_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE Ground warehouse materialization and predefined routing capabilities relevant to the Ground Execution Layer
  - documented public-API gap for reusable-template road-aligned per-unit Warehouse spawn geometry
not_authoritative_for:
  - DCS runtime acceptance
  - production approval of any internal MOOSE override
  - final route catalog data
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-execution-layer-concept
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Ground Materialization / Routing – Source Review

## 1. Gepruefter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die Pruefung betrifft nur die Frage, ob die Production Ground Execution Layer mit oeffentlichen MOOSE-Funktionen sowohl

```text
A) den BRIGADE/WAREHOUSE-Lifecycle erhalten
und
B) ein wiederverwendbares Fahrzeugtemplate exakt strassenorientiert materialisieren
```

kann.

## 2. Oeffentliche MOOSE-Funktionen – vorhanden

### 2.1 Warehouse Spawn Zone

```lua
WAREHOUSE:SetSpawnZone(zone, maxdist)
```

Damit kann der Mission Designer die Zone begrenzen, in der Ground Assets materialisiert werden.

Die Zone kann auch als Polygon ausgelegt werden. Diese Funktion bestimmt jedoch keine individuellen Positionen oder Headings der Units.

### 2.2 Warehouse Road Connection

Die WAREHOUSE-Dokumentation des gepinnten Source beschreibt eine Road Connection fuer self-propelled Assets und einen manuell setzbaren Road Connection Point.

Damit laesst sich die Anbindung eines Warehouses an das Strassennetz steuern. Das loest nicht die per-unit Materialisierungsgeometrie.

### 2.3 Warehouse Off-Road Path

```lua
WAREHOUSE:AddOffRoadPath(remotewarehouse, group, oneway)
```

Der gepinnte Source enthaelt dazu auch ein offizielles eingebettetes Beispiel. Die Waypoints eines late-activated Template-Groups definieren den Pfad zwischen zwei Warehouses.

Wichtig fuer OMW:

```text
- vordefinierte Wege sind damit MOOSE-nativ moeglich;
- die Rueckrichtung wird standardmaessig automatisch ergaenzt;
- mehrere Pfade koennen hinterlegt werden;
- Start und Ende werden jedoch aus zufaelligen Punkten der jeweiligen Spawn Zones erzeugt.
```

Der Source von `AddOffRoadPath` verwendet:

```lua
self.spawnzone:GetRandomCoordinate()
remotewarehouse.spawnzone:GetRandomCoordinate()
```

und baut daraus mit `_NewLane(...)` den Pfad.

Damit ist `AddOffRoadPath` fuer einen Warehouse-zu-Warehouse-Transportpfad relevant, aber nicht automatisch identisch mit dem OMW-Vertrag einer explizit gerichteten PATHLINE-Kette mit kontrollierten Handoff-Ankern.

### 2.4 Ground road task

```lua
CONTROLLABLE:TaskGroundOnRoad(...)
```

Der Source verwendet `COORDINATE:GetPathOnRoad(...)` und baut daraus Ground Waypoints.

OMW kann dies fuer kleine Connector-Segmente pruefen. Wegen der verbindlichen Ground-AI-Regel ersetzt es aber keine validierten MSR/PATHLINE-Routen.

### 2.5 PATHLINE

Source-geprueft:

```lua
PATHLINE:GetNumberOfPoints()
PATHLINE:GetPoint2DFromIndex(...)
PATHLINE:GetCoordinates()
```

Damit kann OMW eine im Mission Editor definierte, explizite Routengeometrie lesen, ohne eine eigene Pathfinding-Engine zu entwickeln.

### 2.6 SPAWN absolute positions

Source-geprueft:

```lua
SPAWN:InitSetUnitAbsolutePositions(Positions)
```

Die Methode akzeptiert pro Unit absolute Positionen und optional ein individuelles Heading.

Damit ist die benoetigte Geometriefunktion in MOOSE vorhanden.

Sie ist jedoch Teil des `SPAWN`-Pfades und wird von der normalen Ground-Asset-Materialisierung des WAREHOUSE nicht als oeffentlicher Konfigurationspunkt aufgerufen.

## 3. Tatsaechlicher WAREHOUSE Ground-Spawnpfad

Der gepinnte Source materialisiert Ground Assets ueber:

```lua
WAREHOUSE:_SpawnAssetGroundNaval(...)
```

Der Ablauf ist source-seitig:

```text
_SpawnAssetPrepareTemplate(...)
-> spawnzone:GetRandomCoordinate()
-> bestehende Template-Unitpositionen relativ zu diesem Zufallspunkt verschieben
-> optional ValidateAndRepositionGroundUnits
-> _DATABASE:Spawn(template)
-> __AssetSpawned(...)
```

Entscheidend:

```text
- oeffentliche SetSpawnZone API: ja
- kontrollierter Gruppenmittelpunkt: nur ueber Zone, intern zufaellig
- individuelle absolute Unitpositionen ueber WAREHOUSE public API: nein gefunden
- individuelles per-unit Heading ueber WAREHOUSE public API: nein gefunden
- normaler WAREHOUSE Asset/Request/Callback-Lifecycle: ja
```

## 4. Warum ein sehr schmales Spawn-Polygon die Luecke nicht vollstaendig schliesst

Ein schmales Polygon kann die zufaellige Gruppenposition geometrisch einschraenken. Es garantiert aber nicht den vollstaendigen OMW-Vertrag:

```text
- reproduzierbare Marschreihenfolge entlang der Strassenachse;
- definierter Fahrzeugabstand;
- Heading jeder Unit in Fahrtrichtung;
- wiederverwendbares Template an Strassen mit unterschiedlichem Heading;
- garantiertes Forward-Alignment zur gewaehlten Route.
```

Ein site-spezifisch bereits passend ausgerichtetes Template koennte Teile davon umgehen, wuerde aber die beabsichtigte wiederverwendbare Template-Architektur aufgeben und die bereits vorhandene TM01M-/Acceptance-Erkenntnis nicht sauber verallgemeinern.

## 5. Acceptance-3-2 Evidenz

Die Ground Foundation hat diese konkrete Luecke bereits einmal fuer einen Testscope behandelt.

Die owner-genehmigte Acceptance-3-2-Ausnahme setzte vor dem finalen Warehouse-Spawn absolute per-unit Strassenpositionen und Headings in die vorbereitete Template-Kopie und liess danach den bestehenden Warehouse-/Asset-/Callback-Lifecycle weiterlaufen.

Der zugehoerige dokumentierte DCS-Lauf bestaetigte fuer den damaligen Scope sechs Sites und road-aligned Materialisierung.

Diese Evidenz beweist:

```text
- der kleine Integrationspunkt funktioniert im dokumentierten Acceptance-Scope;
- BRIGADE/WAREHOUSE/ARMYGROUP koennen dabei erhalten bleiben.
```

Sie beweist NICHT:

```text
- automatische Production-Freigabe;
- Versionsstabilitaet ausserhalb des gepinnten Moose.lua;
- beliebige Route-/Templatekombinationen;
- dass kein kuenftiger oeffentlicher MOOSE-Pfad existiert.
```

## 6. MOOSE-first Bewertung

Anforderungszerlegung:

```text
Mission/Asset lifecycle                 -> MOOSE direkt
Route execution                         -> MOOSE direkt
PATHLINE reading                        -> MOOSE direkt
road connector                          -> MOOSE direkt, soweit geeignet
absolute per-unit spawn geometry        -> MOOSE SPAWN kann es
WAREHOUSE public injection of geometry  -> im gepinnten Source nicht gefunden
```

Damit liegt keine Begruendung fuer eine eigene Spawn-/Mission-Engine vor.

Die einzige verbleibende Production-Luecke ist eng:

```text
Wie werden MOOSE-faehige absolute per-unit Positionen/Headings
in den bestehenden WAREHOUSE Ground materialization lifecycle eingespeist,
ohne Assetreservation, Request Queue, __AssetSpawned oder ARMYGROUP zu ersetzen?
```

## 7. Kleinster moeglicher Fallback

Falls der Projektinhaber spaeter eine Production-Ausnahme genehmigt, darf sie nur diesen Umfang haben:

```text
1. prepared Warehouse Ground template erhalten;
2. Route Catalog / PATHLINE start geometry lesen;
3. absolute Unitpositionen + Headings berechnen;
4. nur diese Geometriefelder in der vorbereiteten Kopie ersetzen;
5. genau einmal den normalen Spawn fortsetzen;
6. bestehenden __AssetSpawned / BRIGADE / PLATOON / ARMYGROUP / AUFTRAG Lifecycle unveraendert lassen.
```

Ausgeschlossen:

```text
- eigener Asset-Pool;
- eigener Warehouse-Ersatz;
- Raw-SPAWN als parallele Ground-Ressourcenhoheit;
- eigener MissionDone-Lifecycle;
- eigener DCS Event Handler, wenn MOOSE Events ausreichen;
- eigener Pathfinding-Algorithmus.
```

## 8. Produktionsentscheidung

Status nach Source Review:

```text
PUBLIC MOOSE ROUTING CAPABILITY: SUFFICIENT FOR PLANNED ROUTE EXECUTION
PUBLIC MOOSE PATHLINE CAPABILITY: SUFFICIENT
PUBLIC MOOSE SPAWN GEOMETRY CAPABILITY: SUFFICIENT IN SPAWN CLASS
PUBLIC WAREHOUSE PER-UNIT GEOMETRY INJECTION: NOT FOUND
PRODUCTION INTERNAL ADAPTER APPROVAL: NOT YET GRANTED
```

Damit ist die offene Entscheidung jetzt sauber auf genau einen kleinen Integrationspunkt reduziert. Bis zu einer Owner-Freigabe bleibt `OMW_GroundMaterializationAdapter.lua` geplant und wird nicht als Production Runtime implementiert.
