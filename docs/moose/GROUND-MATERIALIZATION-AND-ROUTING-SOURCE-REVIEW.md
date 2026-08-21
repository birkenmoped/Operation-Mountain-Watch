---
document_id: OMW-MOOSE-GROUND-MATERIALIZATION-ROUTING-REVIEW
status: PLANNED
document_class: MOOSE_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE Ground warehouse materialization and routing capabilities relevant to road-aligned Ground spawning
  - documented public-API gap for per-unit WAREHOUSE spawn geometry
  - owner-approved production scope of the minimal road-spawn materialization adapter
not_authoritative_for:
  - DCS runtime acceptance of the generalized production adapter
  - final Ground tasking or route architecture
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-execution-layer-concept
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Ground Materialization / Routing – Source Review

## 1. Gepruefter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Ziel der Pruefung ist ausschliesslich die Materialisierungsfrage:

```text
Kann MOOSE den bestehenden BRIGADE/WAREHOUSE-Lifecycle beibehalten
und gleichzeitig beliebige Ground Assets reproduzierbar auf einer Strasse
mit per-unit Position und Heading materialisieren?
```

## 2. Oeffentliche MOOSE-Funktionalitaet

Source-geprueft vorhanden:

```lua
WAREHOUSE:SetSpawnZone(...)
WAREHOUSE:AddOffRoadPath(...)

CONTROLLABLE:TaskGroundOnRoad(...)
COORDINATE:GetPathOnRoad(...)

PATHLINE:GetNumberOfPoints()
PATHLINE:GetPoint2DFromIndex(...)
PATHLINE:GetCoordinates()

SPAWN:InitSetUnitAbsolutePositions(...)
```

Damit sind Road-Geometrie, vordefinierte Wege, PATHLINE-Lesen und absolute SPAWN-Unitpositionen in MOOSE vorhanden.

## 3. Nachgewiesene oeffentliche API-Luecke

Der gepinnte WAREHOUSE-Ground-Spawnpfad materialisiert ueber:

```lua
WAREHOUSE:_SpawnAssetGroundNaval(...)
```

Source-seitig:

```text
_SpawnAssetPrepareTemplate(...)
-> spawnzone:GetRandomCoordinate()
-> Templatepositionen relativ verschieben
-> optional ValidateAndRepositionGroundUnits
-> _DATABASE:Spawn(template)
```

Die oeffentliche WAREHOUSE-API stellt im gepinnten Stand keinen Hook bereit, der vor diesem Spawn individuelle absolute Positionen und Headings der Ground-Units uebernimmt.

Damit ist die Luecke eng begrenzt:

```text
MOOSE kann die Geometrie grundsaetzlich.
WAREHOUSE kann sie im normalen Ground-Asset-Lifecycle nicht oeffentlich injizieren.
```

Es besteht keine nachgewiesene Luecke fuer einen eigenen Warehouse-, Asset-, Mission-, FSM- oder Pathfinding-Ersatz.

## 4. Acceptance-3-2 Evidenz

Acceptance 3-2 verwendete fuer sechs Ground Sites eine owner-genehmigte, versionsgebundene Ausnahme.

Der Adapter:

```text
- fing nur _SpawnAssetGroundNaval(...) der jeweiligen BRIGADE ab;
- verwendete _SpawnAssetPrepareTemplate(...);
- ersetzte nur absolute Unitpositionen und Heading;
- spawnte die vorbereitete Kopie genau einmal ueber _DATABASE:Spawn(template);
- liess Assetreservation, Request Queue, BRIGADE, PLATOON, ARMYGROUP und AUFTRAG bestehen.
```

Der damalige DCS-Nachweis bestaetigte diese Materialisierung fuer den dokumentierten sechs-Site-/M-ATV-Testscope.

Dieser Nachweis bleibt begrenzt auf seine dokumentierte Provenienz und beweist nicht automatisch die jetzt allgemeinere Production-Verwendung.

## 5. Owner-Freigabe 2026-08-21

Der Projektinhaber hat die Ausnahme ausdruecklich erweitert:

> Fuer alle Bodeneinheiten gilt: Wenn auf einer Strasse gespawnt/materialisiert wird, soll die Ausrichtung immer nach dem Acceptance-3-2-Grundverfahren erfolgen.

Genehmigter Production-Scope:

```text
Ground asset is intentionally a ROAD SPAWN
-> MOOSE WAREHOUSE prepares asset
-> OMW road-spawn adapter computes road-axis positions and headings
-> prepared template receives only geometry changes
-> normal MOOSE asset/request/BRIGADE/PLATOON/ARMYGROUP/AUFTRAG lifecycle continues
```

Nicht genehmigt:

```text
- eigener Warehouse-Ersatz
- eigener Asset-Pool
- eigener Ground Mission Controller
- eigener Route Catalog
- eigener Pathfinding-Algorithmus
- parallele Mission-/Return-/Settlement-FSM
```

## 6. Production-Implementierung

Source:

```text
scripts/ground/OMW_GroundRoadSpawnAdapter.lua
```

Der Adapter wird an einer konkreten MOOSE-`BRIGADE`/`WAREHOUSE`-Instanz installiert.

Ein vom konkreten MOOSE-Auftrag bereitgestellter Resolver entscheidet ausschliesslich, ob der aktuelle Spawn ein Road Spawn ist:

```text
resolveRoadSpawn(...) == nil
-> unveraenderter originaler MOOSE Ground-Spawnpfad

resolveRoadSpawn(...) -> table
-> road-aligned Ausnahme wird angewendet
```

Der Resolver muss fuer einen Road Spawn mindestens liefern:

```text
accessZone
forwardCoordinate
```

Optional:

```text
entityId
```

Damit trifft der Adapter selbst keine Mission-, Route-, Asset- oder Campaign-Entscheidung.

## 7. Road-Geometrie

Der Production-Adapter verwendet ausschliesslich bereits in Acceptance 3-2 eingesetzte MOOSE-/DCS-Geometriepfade:

```lua
accessZone:GetCoordinate():GetClosestPointToRoad(false)
startRoad:GetPathOnRoad(forwardCoordinate, true, false, false, false)
COORDINATE:NewFromVec2(...)
coordinate:GetClosestPointToRoad(false)
coordinate:Get2DDistance(...)
```

Die Ausrichtung jeder Unit wird entlang des lokalen Road-Path-Tangentenverlaufs berechnet.

Anders als der M-ATV-Test erzwingt die Production-Fassung keinen festen 18-m-Abstand fuer alle Ground-Typen. Reihenfolge und Abstaende werden aus dem bereits vorhandenen Asset-Template uebernommen und entlang der Strassenachse abgetragen. Dadurch wird keine neue allgemeine OMW-Formationspolicy eingefuehrt.

## 8. Private MOOSE-Abhaengigkeit

Der Adapter ist bewusst versionsgebunden, weil er diese internen Punkte nutzt:

```lua
brigade._SpawnAssetGroundNaval
brigade:_SpawnAssetPrepareTemplate(...)
_DATABASE:Spawn(template)
```

Diese Nutzung ist nur fuer die genehmigte Road-Spawn-Geometrieausnahme zulaessig.

Bei einem MOOSE-Update muss vor weiterer Verwendung erneut geprueft werden:

```text
- Signatur _SpawnAssetGroundNaval
- Semantik _SpawnAssetPrepareTemplate
- Rueckgabe-/Callback-Pfad nach _DATABASE:Spawn
- Assetreservation und Request Queue
- __AssetSpawned / OnAfterAssetSpawned
- ARMYGROUP construction
```

## 9. Guard Rails

Der Adapter verweigert einen Road Spawn, wenn unter anderem:

```text
- kein Road-Punkt innerhalb der ACCESS-Zone gefunden wird;
- kein Road-Path in Outbound-Richtung ermittelt werden kann;
- die vorhandene Template-Geometrie kollabiert ist;
- die Gruppe nicht in die verfuegbare Road-Strecke passt;
- ein Unit-Snap mehr als 30 m betraegt;
- eine berechnete Position ausserhalb der ACCESS-Zone liegt;
- WAREHOUSE ValidateAndRepositionGroundUnits gleichzeitig aktiv ist.
```

Ein angeforderter Road Spawn faellt nicht stillschweigend auf den zufaelligen Standard-WAREHOUSE-Spawn zurueck.

## 10. MOOSE-first Bewertung

```text
MOOSE asset lifecycle                    DIRECT MOOSE
MOOSE mission lifecycle                  DIRECT MOOSE
MOOSE road/path geometry                 DIRECT MOOSE
MOOSE PATHLINE                           DIRECT MOOSE
MOOSE public SPAWN absolute positions    AVAILABLE
WAREHOUSE public per-unit injection      NOT FOUND
minimal WAREHOUSE geometry adapter       OWNER APPROVED
custom route engine                      REJECTED / NOT NEEDED
custom Ground mission engine             REJECTED / NOT NEEDED
```

Damit ist die Ausnahme auf genau die nachgewiesene API-Luecke begrenzt und entspricht der MOOSE-First-Policy.

## 11. Validierungsgrenze

Status des Production-Adapters:

```text
SOURCE IMPLEMENTED
OWNER APPROVED FOR PRODUCTION SCOPE
DCS VALIDATION PENDING
```

Acceptance 3-2 bleibt historische Runtime-Evidenz fuer den damaligen Scope. Die generalisierte Fassung muss in der naechsten gebuendelten Ground-Integration-Acceptance mit mehreren Templates und normalen MOOSE-Lifecycles erneut geprueft werden.
