---
document_id: OMW-TARGETING-AFGHANISTAN-NSL
status: BINDING
document_class: TARGETING_ARCHITECTURE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - Afghanistan No-Strike List target-exclusion architecture
  - mandatory NSL checks before project-generated target nomination
  - fail-closed behavior for unresolved protected-object conflicts
not_authoritative_for:
  - real-world legal advice or military target approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - source-status values used as document status
  - pre-policy publication and license blocker wording
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# 48 – Afghanistan No-Strike List

## 1. Zweck und Autorität

Dieses Dokument legt die verbindliche Zielschutz- und NSL-Architektur für **Operation Mountain Watch** fest.

Die NSL ist vor jeder projektseitigen Zielnominierung, Angriffserzeugung, KI-Auftragsanlage oder Spieler-Task-Erstellung zwingend zu prüfen.

Maßgebliche Regeln:

- [`OMW-GOV-001`](00-project-governance.md)
- [`OMW-GOV-SOURCE-USE`](sources/graveyard-of-empires.md)
- [`OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE`](targeting/afghanistan-nsl-data-use-policy.md)
- [`OMW-C2-AIR-C2-CAS-AFGHANISTAN`](45-air-c2-cas-afghanistan.md)

Der vollständige frühere Quellen-, Datensatz- und Architekturtext bleibt unverändert erhalten:

- [`Legacy-Quellen- und Architekturfassung`](evidence/source-records/legacy-48-afghanistan-no-strike-list-source-and-architecture.md)

## 2. Datensatz und Quellenstatus

```yaml
source_author: Graveyard of Empires
source_dataset: Afghanistan NSL v1.0
records: 2954
source_status: SOURCE_CAPTURE_COMPLETE
runtime_validation: false
```

Die ursprüngliche Recherche und Zusammenstellung werden vollständig **Graveyard of Empires** zugerechnet.

## 3. Projektverwendung und Veröffentlichung

Projektweit gilt:

- die Verwendung der Afghanistan-NSL v1.0 ist genehmigt;
- die Normalisierung aller 2.954 Einträge ist genehmigt und vorgesehen;
- Konvertierung in Lua, JSON, CSV, GeoJSON und weitere Laufzeitformate ist zulässig;
- normalisierte und abgeleitete Daten dürfen in Missionen, Testpakete und veröffentlichte Projektartefakte eingebunden werden;
- Originaldateien dürfen nach dokumentierter Projektmanagerentscheidung als `PUBLIC`, `INTERNAL` oder `MISSION_PACKAGE_ONLY` abgelegt werden;
- eine fehlende allgemeine Lizenzbezeichnung ist kein Implementierungs- oder Veröffentlichungsblocker;
- Attribution, Provenienz, Hashes und konkrete entgegenstehende materialspezifische Bedingungen bleiben verbindlich;
- es wird keine allgemeine Gemeinfreiheit oder Lizenzfreiheit behauptet.

## 4. Verbindliche Zielprüfung

Jedes Zielobjekt durchläuft vor Freigabe mindestens:

1. Koordinaten- und Geometrievalidierung;
2. Suche nach NSL-Punkten und Schutzflächen im definierten Prüfbereich;
3. Prüfung von Zieltyp, gewünschtem Effekt und Waffenwirkung;
4. Prüfung des zivilen Umfelds und weiterer ROE-/C2-Bedingungen;
5. dokumentierte Entscheidung `CLEAR`, `BLOCKED`, `REVIEW_REQUIRED` oder `DATA_ERROR`.

```text
CLEAR            Ziel darf die weiteren Freigabestufen durchlaufen.
BLOCKED          Zielnominierung oder Angriffserzeugung wird verhindert.
REVIEW_REQUIRED  Keine automatische Freigabe; ausdrückliche Projekt-/Missionsentscheidung erforderlich.
DATA_ERROR       Fail closed; keine Zielnominierung bis zur Datenkorrektur.
```

## 5. Fail-closed-Regel

Bei fehlendem Datensatz, Parse-Fehlern, unklarer Koordinate, unbekannter Kategorie oder widersprüchlicher Geometrie darf keine automatische Zielnominierung erfolgen.

Unzulässig:

- NSL-Prüfung nachträglich erst beim Waffenabwurf;
- stilles Ignorieren fehlerhafter Einträge;
- Entfernung geschützter Punkte aus Laufzeitdaten ohne dokumentierte Entscheidung;
- Verwendung eines Zielnamens als alleiniger Schutzmechanismus;
- unterschiedliche NSL-Wahrheiten für Spieler und KI.

## 6. Datenmodell

Jeder normalisierte Eintrag benötigt mindestens:

```text
stableId
sourceId
name
category
latitude
longitude
geometryType
protectionRadiusOrPolygon
sourceReference
sourceHash
normalizationVersion
validationState
notes
```

Geometrie, Kategorien und Schutzradien werden nicht aus fehlenden Angaben geraten. Unklare Einträge erhalten `REVIEW_REQUIRED` oder `DATA_ERROR`.

## 7. Technische Architektur

Vorgesehene Komponenten:

```text
NSLDataLoader
NSLNormalizer
NSLSpatialIndex
NSLTargetValidator
NSLAuditLogger
```

Ablauf:

```text
source files
→ normalized dataset
→ schema/hash validation
→ spatial index
→ target candidate
→ NSLTargetValidator
→ CLEAR | BLOCKED | REVIEW_REQUIRED | DATA_ERROR
→ MissionDemand / PLAYERTASK / AUFTRAG only when allowed
```

Die technische Umsetzung ist MOOSE-first. Eigene Geometrie- oder Indexlogik benötigt die Prüfung vorhandener MOOSE-Zonen-, Koordinaten-, Sets- und Suchfunktionen sowie das Ausnahmeverfahren aus Dokument 26.

## 8. Spieler- und KI-Gleichbehandlung

- Spieleraufträge und KI-Aufträge verwenden dieselbe NSL-Datenbasis.
- Ein blockiertes Ziel darf nicht als alternatives KI-Ziel wieder erscheinen.
- Missionseditor-Ziele, dynamische Ziele, erkannte Gruppen und statische Objekte werden vor Task-Erzeugung geprüft.
- Zielverschiebungen und neue Koordinaten lösen eine erneute Prüfung aus.

## 9. Logging und Nachvollziehbarkeit

Jede Prüfung protokolliert mindestens:

```text
targetId
targetCoordinate
requestingSystem
matchedNSLIds
minimumDistance
geometryResult
decision
decisionReason
datasetVersion
datasetHash
timestamp
```

## 10. Acceptance-Kriterien

Die NSL-Funktion ist erst technisch akzeptiert, wenn:

- alle 2.954 Einträge reproduzierbar normalisiert werden;
- Schema, Hash und Datensatzversion protokolliert werden;
- Punkt-, Radius- und gegebenenfalls Polygonprüfungen getestet sind;
- Fehlerfälle nachweislich fail closed reagieren;
- Spieler- und KI-Tasking dieselbe Entscheidung verwenden;
- Zielverschiebungen erneut geprüft werden;
- Blockierungen und Review-Fälle in Logs nachvollziehbar sind;
- Multiplayer- und Missionsneustarttests durchgeführt wurden.
