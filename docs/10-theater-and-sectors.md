---
document_id: OMW-THEATER-SECTORS
status: BINDING
document_class: THEATER_MODEL
owning_policy: OMW-GOV-001
authoritative_for:
  - campaign spatial hierarchy and sector model
  - required semantic location metadata
not_authoritative_for:
  - final Mission Editor polygon geometry
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - vertical-prototype-only spatial sequencing
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 10 – Operationsraum und Sektoren

## 1. Räumliche Ebenen

Die Kampagne verwendet vier Ebenen:

- strategischer Raum: Bagram, Kabul und weitere Theaterknoten;
- operativer Raum: Jalalabad/Fenty, Laghman, Kabul River Valley und regionale Zugänge;
- taktischer Hauptkampfraum: Kunar River Valley, Pech Valley, Seitentäler und Nuristan-Zugänge;
- Erweiterungsräume: weitere Regionen innerhalb der DCS-Karte und des Kampagnenzeitraums.

Der vollständige frühere Sektorentwurf bleibt unverändert erhalten:

- [`Legacy-Operationsraum und Sektoren`](evidence/source-records/legacy-10-theater-and-sectors.md)

Der frühere vertikale Prototyp begrenzt die aktuelle Foundation-Build-Reihenfolge nicht.

## 2. Sektormodell

Jeder Sektor benötigt mindestens:

```text
sectorId
displayName
missionEditorZone
terrainProfile
accessProfile
blueInfluence
redInfluence
locations
routes
passesAndChokepoints
supplyLinks
materializationPolicy
```

Vorläufige ID-Familien dürfen weiterverwendet werden, endgültige Grenzen werden jedoch im Mission Editor und anhand der DCS-Terrainrealität geprüft.

## 3. Ortsmodell

Erfasst werden nur Orte mit strategischer, taktischer oder spielerischer Funktion:

- Airbases, FOBs, COPs und Checkpoints;
- Städte und Dörfer an relevanten Routen;
- Pässe, Täler, Brücken und Flussquerungen;
- Camps, Hide Sites, Caches und Rückzugsräume;
- Landezonen, Drop Zones und Transferpunkte.

Jeder Ort erhält eine stabile ID und einen validierten DCS-Anker. F10-Kartenbezeichnungen oder externe Koordinaten werden nicht ungeprüft als DCS-Wahrheit übernommen.

## 4. RED-Geografie

Täler, Pässe, Seitentäler und grenznahe Wege bestimmen Bewegung, Versorgung und Rückzug. RED-Regeneration entsteht über nachvollziehbare Verbindungen und wird durch Aufklärung, Festnahmen, zerstörte Lager und gesperrte Routen beeinflusst.

## 5. Noch zu erfassen

- endgültige Sektorpolygone;
- relevante Siedlungs- und Infrastrukturanker;
- Straßen-, Tal- und Passachsen;
- Candidate Sites und Materialisierungsanker;
- Lande-, Abwurf- und Rückzugspunkte;
- DCS-Sicht-, Höhen- und Geländebeschränkungen.
