---
document_id: OMW-WX-DATASET-DOCUMENTATION
status: BINDING
document_class: DATASET_DOCUMENTATION
owning_policy: OMW-WX-HISTORICAL-BASELINE
authoritative_for:
  - file inventory and coverage of the versioned Jalalabad weather datasets
  - reproducible source retrieval and dataset-quality caveats
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified weather data README
superseded_by:
source_branch: docs/historical-weather-baseline-2010-2011
source_commit: beb72bc0ccadc3b12c7e0c84f1a4d5fe3659bca4
validated_in_dcs: false
source_status: PARTIAL_PERIOD_COVERAGE
---

# Wetterdaten Jalalabad 2010–2011

## Gültigkeit und Abdeckung

```text
Verbindlicher Kampagnenzeitraum: 01.08.2010–31.12.2011
Vorhandene QL5/KQL5-Daten:       01.08.2010–20.05.2011 UTC
Beobachtungen:                   4.886
```

Die vorhandenen Daten sind für ihre tatsächliche Abdeckung verbindlich dokumentiert, bilden aber nicht das gesamte Kalenderjahr 2011 ab.

Der vollständige bisherige Datenbericht bleibt erhalten:

- [`legacy-weather-data-readme.md`](../../evidence/source-records/legacy-weather-data-readme.md)

## Versionierte Dateien

- `QL5-selected-historical-weather-profiles-2010-2011.csv` – 16 ausgewählte reale Beobachtungen;
- `QL5-seasonal-weather-statistics-2010-2011.csv` – saisonale Kennzahlen aus 4.886 Beobachtungen.

Die Dateinamen sind stabile Referenzen und keine Behauptung vollständiger Jahresabdeckung.

## Datenqualität

Viele Meldungen kennzeichnen Wind- und Druckdaten als geschätzt. Die IEM-Koordinate für QL5 besitzt gegenüber OAJL eine dokumentierte Metadatenunsicherheit. Die Daten sind historische Stationsbeobachtungen, keine vollständigen Klimanormalwerte.

## Zugehörige Baseline

- [`OMW-WX-HISTORICAL-BASELINE`](../../41-historical-weather-baseline-2010-2011.md)
- [`OMW-WX-DCS-IMPLEMENTATION`](../../42-dcs-weather-editor-validation.md)
