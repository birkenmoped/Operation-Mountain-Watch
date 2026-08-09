---
document_id: OMW-WORLD-DATA-ROUTING
status: BINDING
document_class: WORLD_DATA_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - semantic location registry and DCS/MOOSE terrain-data separation
  - approved location and route discovery workflow
not_authoritative_for:
  - automatically accepted external or discovered map data
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - ungoverned project-specific terrain-data extension wording
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# 16 – Kartendaten, Orte und Routenermittlung

## 1. Grundmodell

DCS und MOOSE liefern technische Geometrie-, Airbase-, Straßen-, Schienen- und Scenery-Daten. Sie liefern keine vollständige semantische Datenbank aller missionsrelevanten Orte und Infrastrukturen.

Der vollständige frühere Kartendaten- und Routingentwurf bleibt erhalten:

- [`Legacy-Kartendaten und Routenermittlung`](evidence/source-records/legacy-16-world-data-and-routing.md)

Das Projekt kombiniert deshalb:

- native MOOSE-/DCS-Terrainfunktionen;
- ein eigenes semantisches Ortsregister;
- validierte Mission-Editor-Zonen und Anker;
- vorberechnete und geprüfte Routen;
- optional Discovery-Testmissionen;
- manuelle Freigabe aller produktiv verwendeten Daten.

## 2. MOOSE-/DCS-Funktionen

Vorrangig zu prüfen:

- Airbase- und Karten-Konstanten;
- `COORDINATE:GetClosestPointToRoad()`;
- `COORDINATE:GetPathOnRoad()`;
- `SCENERY` und `SET_SCENERY` in begrenzten Zonen;
- `PATHLINE`;
- `Core.Astar`;
- Zone-, Coordinate-, Set- und Markerfunktionen.

Die exakte API wird gegen den gepinnten MOOSE-Stand geprüft.

## 3. Semantisches Ortsregister

Jeder spielrelevante Ort erhält mindestens:

```text
locationId
displayName
locationType
sectorId
coordinateSource
airbaseName | zoneName | coordinate
roadAccess
helicopterAccess
fixedWingAccess
terrainClass
validationState
sourceReference
```

Scenery-Dichte oder F10-Beschriftungen erzeugen keine automatische Ortswahrheit.

## 4. Erfassungswege

1. native Airbase-Daten;
2. Mission-Editor-Zonen und validierte Anker;
3. Straßen-/Schienenpfade zwischen bekannten Knoten;
4. begrenzte Discovery-Testmission;
5. historische und externe Referenzen mit DCS-Abgleich.

Automatisch erkannte Kandidaten bleiben `DRAFT` beziehungsweise `CANDIDATE`, bis der Missionsdesigner Lage, Typ und Verwendbarkeit bestätigt.

## 5. Daten- und Freigaberegel

- externe Koordinaten werden nicht ungeprüft übernommen;
- OpenStreetMap- oder Realdaten beweisen nicht, dass das Objekt in DCS vorhanden ist;
- DCS-Positionen können mit Realdaten klassifiziert werden, bleiben aber DCS-spezifisch;
- produktive Daten erhalten Provenienz, Validierungsdatum und Karten-/DCS-Version;
- neue eigene Discovery- oder Routinglogik benötigt Dokument 26 und Eigentümerfreigabe.
