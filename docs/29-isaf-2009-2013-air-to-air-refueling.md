---
document_id: OMW-AAR-ISAF-ACO
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW AAR-area and ACO mission-design reference for Afghanistan 2009-2013
  - source-derived tanker-area geometry and planning constraints
not_authoritative_for:
  - historical operational ACO authenticity
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - REFERENCE used as governance document status
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 29 – ISAF 2009–2013: Air-to-Air Refuelling und ACO-Referenz

## 1. Einordnung

Dieses Dokument ist die verbindliche quellenbasierte Planungsreferenz für AAR Areas, Tanker-Orbits und ACO-bezogene Missionsgestaltung in **Operation Mountain Watch**.

Der vollständige Quellen-, Tabellen-, KMZ- und CombatFlite-Auswertungstext bleibt unverändert erhalten:

- [`Legacy-AAR-/ACO-Quellenfassung`](evidence/source-records/legacy-29-isaf-aar-aco-source-capture.md)

## 2. Quellenstatus

```yaml
source_author: Graveyard of Empires
patreon_parts_available: 3/3
pdf_table: evaluated
kmz_geometry: extracted
combatflite_cf: present_but_full_analysis_pending
source_status: SOURCE_CAPTURE_COMPLETE
```

Die Aussagen sind als Wiedergabe und Projektableitung der bereitgestellten Quellen zu behandeln. Eine vollständige unabhängige historische Verifikation jeder AAR Area ist nicht behauptet.

## 3. Verbindliche Missionsdesign-Grundsätze

- AAR Areas werden als klar benannte, räumlich definierte Gebiete mit Racetrack, Kontrollpunkten und Höhenblock geführt.
- Tankertyp, Receiver-Domain, optimale Höhe, Geschwindigkeit, TACAN, Frequenz und Callsign werden getrennt dokumentiert.
- Mehrere Tanker benötigen definierte vertikale Staffelung und Konfliktfreiheit.
- DCS-Turnradien und Orbitverhalten müssen praktisch gegen die geplante Geometrie geprüft werden.
- AAR-Gebiete sind keine automatisch freigegebenen historischen Originalräume; ihre Nutzung ist eine quellenbasierte OMW-Planungsentscheidung.

## 4. Technische Zielartefakte

- maschinenlesbares AAR-Area-Register;
- Mission-Editor-Zonen und Orbitpunkte;
- Tanker-Templates und `AUFTRAG`-/RAT-Konfiguration;
- Kneeboard- und Briefingtabellen;
- Konfliktprüfung gegen Flugplätze, Trainingsräume, ROZ und Missionsziele.

## 5. Noch erforderliche Validierung

- vollständige technische Auswertung der `.cf`-Datei;
- Geometrieabgleich KMZ, DCS und Mission Editor;
- Tankerturns und Trackhaltung;
- Boom-/Drogue-Eignung je Receiver;
- Multiplayer-, TACAN- und Funkverhalten;
- Performance bei mehreren gleichzeitig aktiven Tankern.
