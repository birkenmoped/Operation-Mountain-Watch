---
document_id: OMW-WX-HISTORICAL-BASELINE
status: BINDING
document_class: HISTORICAL_DATA_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - current Jalalabad METAR dataset coverage
  - selected historical weather profiles
  - seasonal statistics within the documented coverage
not_authoritative_for:
  - complete weather statistics through December 2011
  - directly usable DCS editor presets
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/historical-weather-baseline-2010-2011
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# 41 – Historische Wetterbasis Jalalabad 2010–2011

## 1. Geltungsbereich

Dieses Dokument ist die verbindliche historische Wetter- und Planungsbasis für die derzeit ausgewerteten Jalalabad-METAR-Daten.

Der vollständige statistische und profilbezogene Text bleibt unverändert erhalten:

- [`Legacy-Wetterbaseline mit Tabellen und Profilen`](evidence/source-records/legacy-41-historical-weather-baseline-2010-2011.md)

## 2. Datenabdeckung

```text
Kampagnen- und Recherchezeitraum: 01.08.2010–31.12.2011
Ausgewerteter QL5/KQL5-Datensatz: 01.08.2010–20.05.2011 UTC
Beobachtungen:                    4.886 METAR-Datensätze
Station:                          QL5 / KQL5 JALALABAD
Quelle:                           Iowa Environmental Mesonet
```

Der Datensatz ist für seine tatsächliche Abdeckung fachlich verbindlich, aber keine vollständige Statistik bis Dezember 2011.

## 3. Profilmodell

Für jede Jahreszeit werden innerhalb der vorhandenen Abdeckung vier reale Lageklassen ausgewählt:

- normale beziehungsweise häufige Lage;
- typische Sichtminderungs- oder Bewölkungslage;
- reale Schlechtwetterlage;
- seltene adverse beziehungsweise extreme Missionslage.

Diese Profile sind nicht gleich wahrscheinlich. Extremwetter darf nicht mit derselben Häufigkeit wie Normalwetter ausgewählt werden.

## 4. Trennung der Datenklassen

- historische METAR-Beobachtung;
- statistische Auswertung;
- modellierter Höhenwind;
- DCS-Editor-Arbeitswert;
- praktisch beobachtete DCS-Wirkung;
- technisch akzeptiertes Preset.

Ein historischer Wert wird nicht automatisch unverändert als DCS-Reglerwert verwendet.

## 5. Begleitdokumente

- [`OMW-WX-DCS-IMPLEMENTATION`](42-dcs-weather-editor-validation.md)
- [`OMW-WX-RAIN-PROFILE`](43-dcs-rain-shower-preset-validation.md)
- [`OMW-WX-MIST-PROFILE`](44-dcs-valley-mist-low-cloud-test-profile.md)
- `data/weather/QL5-selected-historical-weather-profiles-2010-2011.csv`
- `data/weather/QL5-seasonal-weather-statistics-2010-2011.csv`

## 6. Erweiterungsbedarf

- METAR-Abdeckung 21.05.2011–31.12.2011 ergänzen;
- weitere relevante Basen beziehungsweise Klimaräume erfassen;
- Höhenwind- und Sichtmodelle getrennt kennzeichnen;
- DCS-Presets ausschließlich in den Umsetzungs- und Acceptance-Dokumenten freigeben.
