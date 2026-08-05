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
source_commit: a0fe0ea887d05fa293160b92a6ad48bd00be9d38
validated_in_dcs: false
---

# 29 – ISAF 2009–2013: Air-to-Air Refuelling und ACO-Referenz

## 1. Einordnung

Dieses Dokument ist die verbindliche quellenbasierte Planungsreferenz für AAR Areas, Tanker-Orbits und ACO-bezogene Missionsgestaltung in **Operation Mountain Watch**.

Der vollständige Quellen-, Tabellen-, KMZ- und CombatFlite-Auswertungstext bleibt unverändert erhalten:

- [`Legacy-AAR-/ACO-Quellenfassung`](evidence/source-records/legacy-29-isaf-aar-aco-source-capture.md)

Das allgemeine Datenmodell für ATO-/ACO-/SPINS-Produkte, Tanker-Receiver-Zuordnung, ARCT, Offload, Control Agency und Evidenzstufen steht ergänzend in:

- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md).

Dokument 29 bleibt für die bereits erfasste ISAF-2009–2013-AAR-Geometrie autoritativ. Dokument 54 qualifiziert zusätzliche Callsign-, Höhen- und ROZ-Hypothesen und definiert die technische Datenstruktur.

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

Zusätzliche Quellenklassifizierung aus Dokument 54:

| Quelle | Einstufung | Verwendung |
|---|---|---|
| ATO Example 3 – AAR | `EXAMPLE_ONLY` | Datenmodell für Tanker, Receiver, ARCT und Offload |
| Tankers Callsigns List | `LEAD_ONLY` | Kandidaten, keine automatische historische Zuweisung |
| Tankers Refueling Altitudes | `SOURCE_DERIVED_HYPOTHESIS` | Planungsannahmen, keine bestätigten historischen Höhen |
| Tankers ROZ Locations | `BACKGROUND_ONLY` für 2010/2011 | frühe OEF-2001/2002-Ableitung |
| NATO/Combined-Ops-Verfahrensquellen | `POST_PERIOD_REFERENCE` | moderne Struktur- und Deconfliction-Referenz |

## 3. Verbindliche Missionsdesign-Grundsätze

- AAR Areas werden als klar benannte, räumlich definierte Gebiete mit Racetrack, Kontrollpunkten und Höhenblock geführt.
- Tankertyp, Receiver-Domain, optimale Höhe, Geschwindigkeit, TACAN, Frequenz und Callsign werden getrennt dokumentiert.
- Callsign, Track, Höhe, Tankertyp und Datum erhalten jeweils eine eigene Evidenzbewertung; ein bestätigtes Merkmal bestätigt nicht automatisch die übrigen.
- Mehrere Tanker benötigen definierte vertikale Staffelung und Konfliktfreiheit.
- DCS-Turnradien und Orbitverhalten müssen praktisch gegen die geplante Geometrie geprüft werden.
- AAR-Gebiete sind keine automatisch freigegebenen historischen Originalräume; ihre Nutzung ist eine quellenbasierte OMW-Planungsentscheidung.
- Airways, Terrain/MFE, Threat Envelope, Receiver Performance, CAS-/ISR-Arbeitsräume, Rejoin/Exit, Diverts und CSAR-Abdeckung werden gemeinsam betrachtet.
- pauschale Webannahmen wie FL200–FL290, mindestens 10.000 ft AGL oder 15 Minuten Entfernung zum Arbeitsgebiet werden nicht ohne Primärquelle und Test als Standard festgelegt.
- frühe OEF-Trackvorschläge 2001/2002 werden nicht auf 2010/2011 rückprojiziert.

## 4. Datenfelder

Jede AAR-Zuordnung führt mindestens:

```yaml
aarAssignment:
  tanker_mission_id: string
  area_or_track_id: string
  tanker_type_id: string
  callsign: string
  callsign_confidence: VERIFIED_HISTORICAL | CORROBORATED | LEAD_ONLY | PROJECT_ASSIGNED
  altitude_block: string
  altitude_confidence: VERIFIED_HISTORICAL | SOURCE_DERIVED | PROJECT_ASSIGNED
  refueling_system: BOOM | DROGUE | BDA | OTHER
  fuel_type: string
  planned_total_offload_lb: number | null
  receiver_mission_ids: [string]
  arct_slots: [object]
  control_agency_id: string | null
  effective_from: datetime
  effective_to: datetime
  source_ids: [string]
```

Synthetische Beispiele tragen:

```yaml
example_only: true
historical_claim: false
```

## 5. Technische Zielartefakte

- maschinenlesbares AAR-Area-Register;
- Mission-Editor-Zonen und Orbitpunkte;
- Tanker-Templates und `AUFTRAG`-/RAT-Konfiguration;
- Kneeboard- und Briefingtabellen;
- Request-/Mission-/Receiver-Verknüpfung;
- ARCT- und Offload-Planung;
- Konfliktprüfung gegen Flugplätze, zivile Routen, Trainingsräume, ROZ und Missionsziele;
- separate Divert- und Personnel-Recovery-Angaben.

## 6. Noch erforderliche Validierung

- vollständige technische Auswertung der `.cf`-Datei;
- Geometrieabgleich KMZ, DCS und Mission Editor;
- historische Bestätigung von Callsigns, Tracks und Höhen je Datum;
- Prüfung der einschlägigen ATP-56-Ausgabe für 2010/2011;
- Tankerturns und Trackhaltung;
- Boom-/Drogue-/BDA-Eignung je Receiver;
- geplante Offload- und ARCT-Logik;
- Konfliktprüfung mit Airspace Control Measures;
- Multiplayer-, TACAN- und Funkverhalten;
- Performance bei mehreren gleichzeitig aktiven Tankern;
- dokumentierte DCS-, MOOSE-, Mission- und Bundle-Version.
