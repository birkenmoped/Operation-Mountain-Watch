---
document_id: OMW-BASES-FOBS
status: PLANNED
document_class: BASE_AND_FOB_MODEL
owning_policy: OMW-GOV-001
authoritative_for:
  - planned campaign functions and common metadata of bases, FOBs, COPs and checkpoints
not_authoritative_for:
  - active air ORBAT
  - final Mission Editor object state
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - vertical-prototype-only base sequence
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 11 – Basen, FOBs und Luftstützpunkte

## 1. Einordnung

Dieses Dokument beschreibt die geplanten Kampagnenfunktionen und gemeinsamen Datenfelder von Hauptbasen, Luftoperationsknoten, FOBs, COPs und Checkpoints.

Der vollständige frühere Basenentwurf bleibt unverändert erhalten:

- [`Legacy-Basen- und FOB-Planung`](evidence/source-records/legacy-11-bases-and-fobs.md)

Aktive Luftfahrzeugbestände und Staffeln stehen ausschließlich in:

- [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md)

Konkrete Missionseditorzustände stehen in den basisbezogenen Manifesten und Acceptance-Berichten.

## 2. Gemeinsames Basenmodell

Jeder Standort erhält mindestens:

```text
locationId
displayName
baseClass
sectorId
missionEditorAnchors
campaignFunction
resourceCapacity
personnelAndGarrison
warehouse
roadAccess
airAccess
landingAndDropZones
repairAndMedicalCapabilities
defenseCapabilities
damageState
rebuildState
```

## 3. Strategische Rollen

### Bagram

Strategisches Hauptquartier, Theaterreserven, schwere Wartung, Fighter-/Transportknoten und übergeordnete Luftoperationsbasis.

### Kabul

Politischer und logistischer Rückraum, Personal- und Materialbewegung sowie alternative strategische Drehscheibe.

### Jalalabad / FOB Fenty

Regionaler operativer und logistischer Knoten für Nangarhar, Laghman, Kunar und Nuristan mit Straße, Hubschrauber, QRF, CSAR und taktischem Lufttransport.

### Vorgeschobene Standorte

FOBs, COPs und Checkpoints besitzen begrenzte Ressourcen, Fähigkeiten und Zufahrtsarten. Nicht jeder Standort unterstützt Fixed-Wing-Betrieb, Slingload, Luftabwurf oder ein eigenes AIRWING.

## 4. Zulässige Lieferverfahren

Pro Standort ausdrücklich konfigurieren:

```text
ROAD_CONVOY
HELICOPTER_INTERNAL
HELICOPTER_SLING
FIXED_WING_LANDED
FIXED_WING_AIRDROP
```

## 5. Foundation-Build-Anforderungen

- Standort und DCS-Anker validieren;
- Warehouse- und Ressourcenmodell festlegen;
- Zufahrten, Parkplätze und Landezonen prüfen;
- Garnison, Verteidigung und Bereitschaft definieren;
- Schadens- und Wiederaufbaustufen modellieren;
- basisbezogene Manifeste und Testfälle anlegen;
- keine ORBAT-Zahlen aus dieser allgemeinen Planung ableiten.
