---
document_id: OMW-WORLD-TOWNS-DISCOVERY
status: HISTORICAL_TEST_FIXTURE
document_class: DATASET_DOCUMENTATION
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Afghanistan TOWNS discovery fixture description
not_authoritative_for:
  - production settlement classification
  - production terrain or scenery architecture
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/towns-discovery
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# TOWNS-Discovery für Afghanistan

Dieses Dokument bewahrt den historischen Discovery-Stand des Branches `agent/towns-discovery`. Der Fixture dient ausschließlich der reproduzierbaren Erfassung von benannten Afghanistan-Ortsreferenzen und ist keine freigegebene Produktionsarchitektur.

## MOOSE-First-Abgleich 2026-08-29

Der tatsächlich im Projekt gepinnte MOOSE-Stand enthält die Klasse `TOWNS` (`Navigation.Towns`). Source-verifiziert sind insbesondere:

```text
TOWNS:NewFromFile(FileName)
TOWNS:NewFromTable(TownTable)
TOWNS:GetCoordinate(town)
TOWNS:GetCoordRoad(town)
TOWNS:GetCoordRail(town)
TOWNS:GetConnectionRoad(townA, townB, Railroad)
```

`TOWNS:NewFromFile()` prüft den Dateipfad über `UTILS.FileExists`, lädt `towns.lua` per `dofile()` und übergibt die globale Tabelle `towns` an `NewFromTable()`. `NewFromTable()` erzeugt MOOSE-`COORDINATE`-Objekte und leitet die nächsten Straßen- und Schienenpunkte über `COORDINATE:GetClosestPointToRoad()` ab.

Damit ist für die benannten Ortsreferenzen der MOOSE-native Pfad verbindlich. Der Discovery-Code darf diese Funktionalität nicht parallel neu implementieren.

Die MOOSE-Source verweist für `Navigation.Towns` auf offizielle Demo-Missionen unter `MOOSE_MISSIONS/Navigation - Towns`. Das aktuelle öffentliche `MOOSE_MISSIONS_UNPACKED`-Repository ist vorhanden; ein konkreter aktueller TOWNS-Demopfad konnte bei dieser Reconciliation jedoch nicht reproduzierbar aufgelöst werden. Deshalb wird kein Demo-Runtime-Nachweis behauptet.

## Historischer Discovery-Scope

Der erhaltene Development-Fixture liegt unter:

```text
src/dev/world-data/towns_discovery.lua
mission/tests/towns-discovery/
```

Er verwendet `TOWNS:NewFromFile()` als primären Datenzugang. Ergänzende Auswertung umfasst Statistik, Export und F10-Markierungen.

Der Code enthält zusätzlich native DCS-Lesezugriffe wie `land.getHeight` und `land.getSurfaceType` sowie Dateizugriffe über `io`/`lfs`. Diese Zugriffe sind ausschließlich für den historischen Development-/Evidence-Scope erhalten. Sie sind keine genehmigte Produktionsschnittstelle.

Die separate Scenery-Discovery unter

```text
mission/tests/towns-scenery-discovery/
```

bleibt ausdrücklich `HISTORICAL_TEST_FIXTURE`. Eine produktive Nutzung für Settlement-, Convoy-, Infantry- oder Terrain-Metadaten benötigt einen neuen MOOSE-first Gap Review und gegebenenfalls eine ausdrückliche Owner-Freigabe für den kleinsten notwendigen Native-DCS-Fallback.

## Voraussetzungen

- DCS World mit Afghanistan-Karte;
- gepinnte MOOSE-Version mit `Navigation.Towns`;
- dedizierte Development-Testmission;
- lesender Zugriff auf die terrain-spezifische `towns.lua`;
- für den historischen Export gegebenenfalls `io`/`lfs` in einer kontrollierten Entwicklungsumgebung.

`MissionScripting.lua` wird durch das Projekt nicht automatisch verändert.

## Abnahmegrenze

Die Integration dieses historischen Fixtures nach `main` bedeutet ausschließlich:

```text
SOURCE_REVIEWED / HISTORICAL_TEST_FIXTURE
```

Sie bedeutet ausdrücklich nicht:

```text
VALIDATED
ACCEPTED_TECHNICAL_BASELINE
production settlement classification
approved Native-DCS architecture
```

Ein erneuter DCS-Lauf ist für die Archivierung des Fixtures nicht erforderlich. Jede spätere produktive Übernahme benötigt einen aktuellen Acceptance-Nachweis mit vollständiger DCS-/MOOSE-Provenienz.
