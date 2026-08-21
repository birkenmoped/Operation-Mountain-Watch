---
document_id: OMW-GROUND-EXECUTION-LAYER-CONCEPT
status: PLANNED
document_class: IMPLEMENTATION_CONCEPT
owning_policy: OMW-GOV-001
authoritative_for:
  - planned production boundary between Ground CampaignState integration and physical MOOSE Ground execution
  - planned reuse classification of TM01M technical evidence
  - planned MOOSE-first execution sequence for patrol, convoy, return and later resupply
not_authoritative_for:
  - accepted production runtime implementation
  - DCS runtime acceptance
  - owner approval for a production MOOSE internal override
  - final MissionDemand or resupply orchestration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-execution-layer-concept
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground Execution Layer – Produktionskonzept

## 1. Zweck

Dieses Dokument schliesst die Architekturgrenze zwischen der bereits vorhandenen strategischen Ground-Foundation und der spaeteren physischen Ground-Ausfuehrung.

Bereits vorhanden:

```text
CampaignState
-> Ground Initial Stock
-> Ground CampaignState Adapter
-> Ground Runtime Integration
```

Diese Schicht entscheidet und verbucht strategische Ressourcen. Sie soll weder DCS-Gruppen bewegen noch eigene Ground-AI-Pathfinding-Logik besitzen.

Die fehlende Produktionsschicht ist:

```text
Ground Mission / MissionDemand
        ↓
Ground Execution Layer
        ↓
MOOSE BRIGADE / PLATOON / AUFTRAG / ARMYGROUP
        ↓
physical DCS GROUP
        ↓
MOOSE lifecycle result
        ↓
Ground CampaignState Adapter
        ↓
CampaignState settlement
```

## 2. Verbindliche Grenzen

Die Ground Execution Layer darf nicht:

```text
- strategische Ressourcen besitzen;
- CampaignState-Bestaende duplizieren;
- MOOSE BRIGADE/PLATOON/ARMYGROUP/AUFTRAG nachbauen;
- beliebige Ground-AI-Routen dynamisch erfinden;
- sichtbare Teleports als Recovery verwenden;
- DCS-Gruppennamen als stabile Campaign-IDs verwenden;
- einen eigenen hochfrequenten Watchdog neben MOOSE betreiben.
```

Sie darf:

```text
- einen bereits autorisierten strategischen Auftrag in eine MOOSE-Mission uebersetzen;
- stabile Entity-/Runtime-IDs mit MOOSE-Gruppen korrelieren;
- freigegebene Spawn-/Route-Geometrie an den MOOSE-Lifecycle uebergeben;
- MOOSE-FSM-Ergebnisse in genau einen Settlement-Aufruf uebersetzen;
- kleine, dokumentierte Adapter an einer nachgewiesenen MOOSE-Luecke verwenden.
```

CampaignState bleibt alleinige strategische Ressourcenautoritaet. MOOSE bleibt operative Auswahl-, Materialisierungs-, Routing- und Lifecycle-Schicht.

## 3. Was TM01M fuer Production bedeutet

TM01M wird nicht als Produktionsruntime uebernommen.

Klassifikation:

```text
TM01M = HISTORICAL_TEST_FIXTURE
```

Als technische Evidenz bleiben exakt folgende Erkenntnisse relevant:

```text
1. road-aligned unit placement
2. vehicle heading/orientation along the first route segment
3. PATHLINE-based predefined route geometry
4. road connector generation where a PATHLINE endpoint is not directly usable
5. MOOSE GROUP:Route execution
6. controlled delayed cleanup after arrival
```

Nicht zu uebernehmen sind:

```text
- TM01M F10 test menus
- fixed five-convoy scheduler
- test-only autonomous convoy generation
- TM01M resource ownership
- TM01M mission orchestration
- test-specific hard-coded route assignment as campaign policy
```

## 4. MOOSE-first Source Review fuer die Execution Layer

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-geprueft relevant:

```lua
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
COORDINATE:WaypointGround(...)

PATHLINE:GetNumberOfPoints()
PATHLINE:GetPoint2DFromIndex(...)
PATHLINE:GetCoordinates()

SPAWN:InitSetUnitAbsolutePositions(...)
SPAWN:InitValidateAndRepositionGroundUnits(...)
```

Die verwendete MOOSE-Version besitzt damit oeffentliche Mechanismen fuer Ground-Routen, PATHLINE-Lesen und absolute Unitpositionen. Die bereits validierte Ground-Foundation verwendet fuer den BRIGADE/WAREHOUSE-Lifecycle jedoch einen anderen Materialisierungspfad. Genau hier liegt die relevante Integrationsgrenze.

## 5. Bereits validierter Ground-Lifecycle

Die vorhandenen Ground-Acceptances haben bereits fuer ihren dokumentierten Scope bestaetigt:

```text
strategic debit
-> MOOSE materialization
-> ARMYGROUP mission
-> MissionDone
-> settlement
-> return to ACCESS / warehouse handoff
-> physical removal
-> return/loss reconciliation
```

Daraus folgt:

```text
Production muss diesen Lifecycle nicht ersetzen.
Production muss ihn mit einer Missions- und Geometrieschicht versorgen.
```

Insbesondere soll kein neuer ConvoyController entstehen, der BRIGADE, AUFTRAG oder ARMYGROUP parallel verwaltet.

## 6. Zielmodule

Die kleinste sinnvolle Production-Aufteilung ist:

```text
OMW_GroundExecution.lua
OMW_GroundRouteCatalog.lua
OMW_GroundMaterializationAdapter.lua   [nur falls genehmigte Luecke bestehen bleibt]
```

### 6.1 `OMW_GroundExecution.lua`

Aufgabe:

```text
- validierten Ground-Auftrag annehmen;
- Entity-ID / Runtime-ID pruefen;
- passende BRIGADE und PLATOON referenzieren;
- passende AUFTRAG-Mission erzeugen oder uebernehmen;
- freigegebene Route/Zone zuordnen;
- MOOSE-Mission starten;
- MOOSE-Lifecycle beobachten;
- genau einen Ground-Settlement-Pfad ausloesen.
```

Nicht enthalten:

```text
- Bestandsberechnung;
- Resupply-Thresholds;
- MissionDemand-Erzeugung;
- DCS-native Wegfindung;
- eigene Asset-Auswahl an MOOSE vorbei.
```

### 6.2 `OMW_GroundRouteCatalog.lua`

Reine Projektdaten-/Mapping-Schicht:

```text
routeId
originNodeId
destinationNodeId / objectiveId
pathlineNames
accessZoneName
returnZoneName
speedKph
formation
allowedMissionTypes
```

Der Katalog erfindet keine Route zur Laufzeit. Er referenziert im Mission Editor validierte PATHLINEs, ACCESS-Zonen und Handoff-Punkte.

Eine Route darf erst produktiv verwendet werden, wenn ihre Geometrie und Richtung dokumentiert sind.

### 6.3 `OMW_GroundMaterializationAdapter.lua`

Dieser Adapter ist nur zulaessig, wenn der oeffentliche BRIGADE/WAREHOUSE-Pfad die benoetigte road-aligned Einzelaufstellung weiterhin nicht anbietet.

Aufgabe waere dann ausschliesslich:

```text
prepared MOOSE Warehouse asset
-> validated start PATHLINE / road anchor
-> absolute per-unit road positions
-> per-unit heading along route direction
-> exactly one normal Warehouse materialization continuation
```

Er darf nicht:

```text
- eigene Assetreservation erzeugen;
- MOOSE Request Queue umgehen;
- ARMYGROUP selbst ersetzen;
- MissionDone selbst simulieren;
- Ressourcen abbuchen;
- physische Gruppen ausserhalb des MOOSE-Lifecycles loeschen.
```

WICHTIG: Die vorhandene Acceptance-3-2-Ausnahme war testgebunden. Sie darf nicht stillschweigend in Production uebernommen werden. Fuer Production ist eine neue ausdrueckliche Owner-Freigabe erforderlich, falls dieser interne Hook tatsaechlich benoetigt wird.

## 7. Produktionsablauf – Patrol / Ground Mission

```text
1. Campaign-domain Auftrag ist autorisiert.
2. Ground CampaignState Adapter bestaetigt Materialisierbarkeit.
3. Ground Execution waehlt die bereits konfigurierte BRIGADE/PLATOON-Faehigkeit.
4. Ground Route Catalog liefert freigegebene Objective-/Route-Daten.
5. MOOSE BRIGADE reserviert/materialisiert das Asset.
6. Falls erforderlich und genehmigt: Materialization Adapter setzt nur Spawn-Geometrie/Heading.
7. MOOSE ARMYGROUP erhaelt den AUFTRAG.
8. MOOSE fuehrt Bewegung und Mission-Lifecycle aus.
9. MissionDone / Return / Loss wird ueber MOOSE-FSM beobachtet.
10. Ground CampaignState Adapter fuehrt genau einmal Settlement aus.
```

## 8. Produktionsablauf – ROAD_CONVOY

ROAD_CONVOY ist keine eigene Ressourcenautoritaet, sondern eine Ground-Ausfuehrungsform.

Vorgesehener Ablauf:

```text
MissionDemand / Ground order
-> strategic resources reserved by CampaignState
-> Ground Execution receives physical convoy requirement
-> BRIGADE / PLATOON provides convoy asset
-> validated routeId resolves PATHLINE chain
-> road-aligned materialization at ACCESS boundary
-> MOOSE GROUP/ARMYGROUP follows predefined route
-> arrival at destination Handoff/ACCESS boundary
-> delivery/return settlement
```

Die genaue strategische Cargo-Transferbuchung gehoert nicht in die Execution Layer und wird separat im Resupply-Scope behandelt.

## 9. Route- und Heading-Regel

Fuer jede routeId gilt:

```text
startAnchor
firstForwardAnchor
...
finalAnchor
```

Heading fuer die initiale Marschaufstellung wird aus der Richtung

```text
startAnchor -> firstForwardAnchor
```

abgeleitet.

Die Fahrzeuge werden in Marschreihenfolge entlang der validierten Strassenachse aufgestellt. Der Abstand ist template-/missionstypabhaengig und darf nicht aus dem DCS-Gruppennamen abgeleitet werden.

Falls mehrere PATHLINEs eine Route bilden, muss die Richtung jeder Teilstrecke explizit im Route Catalog festgelegt sein. Automatisches Umdrehen aufgrund der aktuellen Fahrzeugposition ist fuer Production nicht vorgesehen.

## 10. Warum `TaskGroundOnRoad()` nicht allein die OMW-Route ersetzt

`CONTROLLABLE:TaskGroundOnRoad(...)` ist im gepinnten MOOSE-Source vorhanden und verwendet `COORDINATE:GetPathOnRoad(...)`.

Das ist fuer lokale Connectoren und klar begrenzte Road-Segmente nuetzlich. OMW behandelt Ground-AI-Pathfinding aber als unzuverlaessig und besitzt bereits bewusst definierte MSR-/PATHLINE-Geometrie.

Daher gilt:

```text
validated PATHLINE route = primaere Route
TaskGroundOnRoad         = moeglicher MOOSE-first Connector zwischen validierten Anchors
```

Nicht:

```text
start node + destination node
-> DCS/MOOSE soll irgendeinen Weg finden
```

## 11. Spawn-/Materialisierungsentscheidung

Aktueller technischer Stand:

```text
A) Public SPAWN supports InitSetUnitAbsolutePositions().
B) Public WAREHOUSE SetSpawnZone() does not expose per-unit heading/position control.
C) Acceptance 3-2 used an owner-approved, version-bound internal Warehouse spawn adapter.
D) This exception was explicitly limited to Acceptance 3-2 and later validated there.
```

Folge fuer Production:

```text
Noch KEINE automatische Production-Freigabe des internen Hooks.
```

Vor Runtime-Implementierung ist genau eine der beiden Richtungen festzulegen:

```text
P1: ein oeffentlicher MOOSE-Pfad erfuellt die notwendige road-aligned Materialisierung ausreichend;
oder
P2: die kleinste versionsgebundene Materialization-Adapter-Ausnahme wird fuer Production ausdruecklich freigegeben.
```

## 12. Lifecycle- und Settlement-Regeln

Die Execution Layer fuehrt keine eigene zweite Zustandsmaschine fuer Ressourcen.

Physischer Status kann intern beispielsweise korreliert werden als:

```text
REQUESTED
MATERIALIZED
ON_MISSION
RETURNING
HANDED_OFF
LOST
```

Diese Werte sind Telemetrie/Correlation und keine neue strategische Wahrheit.

Settlement bleibt beim bestehenden Ground CampaignState Adapter:

```text
confirmed return including damaged survivor
-> immediate one-time availability credit

confirmed loss
-> permanent loss

open nonterminal commitment at server stop/crash
-> one-time strategic recredit at next startup
-> no blind physical continuation
```

## 13. Beobachtbarkeit

Materialisierung und Entfernung duerfen nur an dafuer vorgesehenen ACCESS-/Handoff-Grenzen stattfinden.

Production darf nicht:

```text
- vor Spielern sichtbar mitten auf der MSR spawnen;
- einen festgefahrenen Convoy wegteleportieren;
- Gruppen unsichtbar ersetzen, waehrend Spieler sie beobachten;
- bei Serverrestart die alte physische Position blind rekonstruieren.
```

## 14. Acceptance-Reihenfolge

Neue Runtime-Aenderungen sollen gemaess Owner-Entscheidung nicht als Serie kleiner Einzelmissionen getestet werden. Der spaetere Ground-Integrationstest soll mehrere offene Verhaltensweisen gemeinsam pruefen.

Vorgesehene Gates:

```text
G1 Source/API review complete
G2 route catalog contract complete
G3 public materialization path or owner-approved minimal exception selected
G4 production Ground Execution source complete
G5 syntax + contract tests
G6 integration build with current production foundations
G7 bundled DCS Ground integration acceptance
```

DCS G7 muss mindestens pruefen:

```text
- road-aligned materialization
- correct heading / march order
- predefined PATHLINE movement
- no duplicate materialization
- mission completion
- return handoff
- partial vehicle loss settlement
- damaged survivor return settlement
- multiple nodes concurrently
- no visible teleport/reconstitution
```

## 15. Naechste konkrete Arbeit

Ohne weitere Architekturentscheidung koennen als naechstes erledigt werden:

```text
1. Route Catalog Datenvertrag implementieren, noch ohne produktive Routenwerte.
2. Ground Execution Interface als MOOSE/DCS-freien Contract definieren.
3. bestehenden MOOSE-Source fuer die genaue BRIGADE/WAREHOUSE-Materialisierungsgrenze erneut gegen Production-Anforderung pruefen.
4. TM01M-Funktionen nur als Evidenzmatrix dokumentieren.
5. erst danach entscheiden, ob eine Production-Ausnahme fuer den Materialization Adapter erforderlich ist.
```

Damit bleibt die Arbeit MOOSE-first und verschiebt die einzige moegliche Ausnahmeentscheidung bis zu dem Punkt, an dem die oeffentliche API-Luecke erneut konkret nachgewiesen ist.
