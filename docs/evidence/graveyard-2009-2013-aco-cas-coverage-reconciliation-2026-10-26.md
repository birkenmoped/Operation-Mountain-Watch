---
document_id: OMW-EVIDENCE-GRAVEYARD-ACO-CAS-COVERAGE-20261026
status: SOURCE_REVIEWED
document_class: RESEARCH_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-review findings and schedule implications for fixed-wing CAS
not_authoritative_for:
  - replacement of binding AAR geometries, historical ACO authenticity, operational CAS orbits, approved sortie limits, DCS validation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
validated_in_dcs: false
---

# Graveyard ISAF 2009–2013 – ACO/CASTrack-Recherche und CAS-Schedule-Abgleich

## 1. Quellenstand und Reichweite

Recherche am 26.10.2026, Webzugriff nur auf frei erreichbare Textabschnitte. Die aktuell publizierten, nicht vollstaendig ausgelesenen Patreon-Anhaenge bzw. die nicht eingesehenen `.cf`/`.kmz` koennen **nicht** als kontrolliert gepruefte Koordinatenevidenz gelten.

**Bindende OMW-main-Basis, unveraendert:**
- `docs/00-project-governance.md`, `docs/26-moose-first-development-policy.md`.
- `docs/29-isaf-2009-2013-air-to-air-refueling.md`: BINDING_PROJECT_DECISION; produktive Geometrien ausschliesslich `data/air-operations/aar/omw-2011-aar-areas.csv` und `.geojson` (19 Areas), operative Rollen in `omw-2011-aar-operational-core.csv`. Vier STANDARD-Tracks aktuell kontinuierlich, zwei RESERVE bei Demand.
- `docs/89-aar-acceptance-7-finalization.md`: BINDING_PROJECT_DECISION, source-domain/Threshold-/Lifecycle-Acceptance; nicht durch fremde Beispiel-ROZ ersetzen.
- `docs/54-air-tasking-airspace-control-cas-requests-and-mission-data.md` T06 (synthetische CAS-Mission), T07 (synthetischer Ground Alert CAS), T08 (synthetische AAR-Mission), Abschnitt 8.3 `EXAMPLE_ONLY`.
- `docs/88-air-tasking-plan-foundation.md`: On-station-Zeit und Takeoff/Transit/Alert-Fenster getrennt.
- Branchlokal `docs/air-operations-fixed-wing-cas-coverage-and-ground-alert-decision.md`: 24h CAS *anforderbar*, Ground Alert Bagram 2-ship als Ziel, CAS-On-station-Luecken zulaessig; keine genehmigten fixen Uhrzeiten oder Sortielaengen.

**Graveyard, direkt aus oeffentlich zugaenglichem Quellentext:**
- `Airspace Management` (2024): ACO als tagesbezogene Aktivierungs-/Hoehen-/Geometrieliste; SACO/ACO-Trennung, dynamische ACM-Anpassung bei kurzfristigem CAS. https://www.patreon.com/graveyard4DCS/posts/airspace-114852766
- `ISAF 2009-2013 - ACO Building - Air-to-Air Refueling Areas (2/x)` (Oktober 2025): Aufbau von AAR Areas auf Basis ziviler Luftrauminformation/AIP. Mindestvertikalraum je einzelnem Tanker im *Quellenbeispiel* 4000 ft; weitere Operationsregeln beduerfen eigener Pruefung. https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-2-141257957
- `ISAF 2009-2013 - ACO Building - Air-to-Air Refueling Areas - CombatFlite Template and Kneeboard (3/x)` (26.10.2025): AAR-Kneeboard, veroeffentlichte `AAR ROZ - 2009-2013.cf`, `.kmz` und `AAR Areas - Afghanistan.pdf` **als Attachment-Existenz belegt; Inhalte/Koordinaten hier nicht gelesen**. https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-3-141708508
- `ISAF 2009-2013 - ACO Building - IFR & VFR Transit Trough Pakistan (7/x)` (Dezember 2025): Kontrolle und Planung grosser Transitkorridore, nicht automatisch lokaler RC-East-CAS-Track. https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-7-145969527
- Graveyard-Index publiziert zusaetzlich `Bullseye List (9/x)`, `Civilian Flight Rules (10/x)`, `Upper and Lower ATS Routes (11/x)` und `ISR ROZ (12/x)` bis Maerz 2026 sowie `AEW and Tactical C2` (4–6/x). Index belegt **Existenz/Titel, nicht frei verfuegbare Trackdetails**. https://www.patreon.com/cw/graveyard4DCS/sitemap

## 2. Wichtige AAR-Details aus Teil 3, ihre Grenzen und die Relevanz fuer A5-3

Der Autor unterscheidet IP/ARIP (Einstellung von Betankungshoehe/-geschwindigkeit) und CP/ARCP (Rendezvous zur Control Time). Afghanistan-AAR-Zeitslots seien nach dieser retrospektiven Darstellung relativ flexibel gewesen; DCS-Tanker unterstuetzen die reale Anpassung ihres Tracks fuer Receiver-Interception **nicht gleichwertig**. Der Autor nennt ein kuerzeres Tanker-Holding als effizienter: **35 NM Leg** verursacht beim Receiver typischerweise weniger Nachflug als **70 NM Leg**. Das ist ein *Beispielvergleich fuer AAR*, keine 35-NM-Norm und keine Aussage zur CAS-Racetrack-Laenge.

Ebenfalls in Teil 3: exemplarische 5000-ft bzw. 10000-ft Vertical Blocks, true headings und fuer die eigene AAR-Grafik 1500 ft Obstacle Margin. **Keine** dieser Groessen darf projektweit als bindende OMW-AAR-Hoehe, allgemeine CAS-Mindesthoehe oder akzeptierte Koordinatensetzung uebernommen werden. Der vorhandene OMW-2011-AAR-Geometrievertrag und die Acceptance-7-Baseline haben Vorrang.

Planerische Konsequenz: Der `AAR_SELECTED`-Event allein beweist noch keine guenstige Receiver-Interception. Fuer Fixed-Wing-CAS-Schedule messen: Weg von/zu CAS-Bereitschaftsraum, Zeit bis `AAR_REFUELED`, AAR-Abwesenheit, zusaetzlichen Fuel-Burn des ganzen Two-Ship, moeglichen Deckungsausfall. Reale A5-3-Beobachtung: Kandahar-A-10 erreichte den ersten CAS-AO-Eintritt rund 2h02m nach Takeoff *inklusive* erstem AAR; vierte AAR rund 8h40m nach Start; Test abgebrochen ohne vollstaendigen RTB. Das **belegt weder vier Stunden dauernde ON-STATION-Einsatzbereitschaft noch sichere zehnstuendige Sortie**.

## 3. CAS-Racetrack-Evidenz und Planungsentscheidung

Graveyard-T06 aus OMW-main dokumentiert eine **zweiflugzeugstarke Kandahar-CAS-Mission mit Arbeitsgebiet, Zeitfenster, Hoehe, FAC, Control Agency und Report-In Point**. Der bestehende Source Review liefert **keine nachgewiesenen exakten CAS-Racetrack-Endpunkte, Schenkellaengen und Heading-Werte fuer RC East 2010/2011**. In den hier geprueften 2009-2013-ACO-Beitraegen ist ein solcher CAS-Track ebenfalls nicht nachgewiesen. AAR-ROZ, ISR-ROZ, zivilen ATS-Korridor, Departure-Marshalling und CAS-Standby-Racetrack **nicht** gleichsetzen.

ATO-Konsequenz (Empfehlung, keine eigenstaendige Owner-Freigabe): CAS-Coverage-Schedule nach *tatsaechlich gewuenschtem* On-Station-Fenster planen; Startzeit rueckwaerts aus gemessener Taxi/Join/Transit/AAR-Zeit errechnen; Ablosung zeitgerecht fuer gepruefte CAS-Verfuegbarkeit disponieren; sicheren RTB inklusive Recovery vor dem Ende der maximalen Sortie ausloesen. Bagram-Ground-Alert bleibt hiervon getrennt und darf nicht durch routinemaessige AAR vor einem Immediate-CAS-Start verzogert werden. Fuer Kandahar muss die laengere Transit-/Tankzeit sichtbar sein; 8h regulaer bzw. 10h als Ausnahme sind derzeit **Diskussionswerte, keine freigegebene Binding Policy oder implementierte Grenze**. Physische 24h-CAS-Praesenz bleibt nicht verpflichtend.

**Offene Evidenz:** echter A5-3-RTB nach mehreren Betankungen, kontrollierte Standby-Track-Positionen/ACO-Blocks, Betankungszeit/Interception pro AAR-Provider, Abdeckung waehrend AAR, verfuegbare Ablosungs-Assets, historische Geodaten. Keine Geometrie-, Laufzeit- oder MIZ-Mutation aus dieser Recherche.

## 4. Folge-Gates

1. Bereits vorhandene `omw-2011-aar-areas.csv`/`.geojson` sowie AAR-Rollen und Track-Konfigurationen mit dem (nicht als gesichtet auszugebenden) Graveyard-2025-Attachment abgleichen, **falls ein legitim lesbares Attachment verfuegbar ist**; andernfalls keinen erfundenen Koordinaten-Diff.
2. Das geplante CAS-Standby als eigenes, mit ACO zeitlich/vertikal abgestimmtes Airspace-Control-Objekt definieren; kein AAR-/ISR-Area-Rebranding.
3. Echte CAS-Verfuegbarkeitszeit und Tankunterbrechung messen statt gleichzeitiger On-Station- und AAR-Verfuegbarkeit.
4. Sortie-/Relief-Policy mit Owner-Entscheidung dokumentieren, erst danach MOOSE-First-Lifecycle-, ATO- und DCS-Acceptance-Implementierung.
