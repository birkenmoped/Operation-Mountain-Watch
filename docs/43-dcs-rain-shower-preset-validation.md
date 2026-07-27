---
document_id: OMW-WX-RAIN-PROFILE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_TEST_PROFILE
owning_policy: OMW-GOV-001
authoritative_for:
  - visually validated Jalalabad rain-shower working profile
not_authoritative_for:
  - universal cloud-base geometry
  - all aircraft, AI or multiplayer conditions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/historical-weather-baseline-2010-2011
source_commit:
validated_in_dcs: partial
---

# 43 – DCS-Regenschauerprofil und Editor-Validierung

## 1. Acceptance-Umfang

Dieses Dokument führt das visuell geprüfte Arbeitsprofil `SHR-01-DCS-PLAYABLE-V1` als begrenzte technische Baseline für wechselnde Regenschauer bei weiterhin möglichem Flugbetrieb.

Der vollständige Testbericht mit METAR-Verlauf, Editorwerten und Beobachtungen bleibt unverändert erhalten:

- [`Legacy-Regenschauer-Testbericht`](evidence/source-records/legacy-43-dcs-rain-shower-preset-validation.md)

Grundlagen:

- [`OMW-WX-HISTORICAL-BASELINE`](41-historical-weather-baseline-2010-2011.md)
- [`OMW-WX-DCS-IMPLEMENTATION`](42-dcs-weather-editor-validation.md)

## 2. Historische Referenz

```text
KQL5 011255Z 35008G15KT 9999 -SHRA FEW070 BKN090 20/05 A2985
Datum:      01.04.2011
Ortszeit:   17:25 AFT
Temperatur: 20 °C
QNH:        29.85 inHg
```

## 3. Akzeptiertes Arbeitsprofil

```text
Profilname:           SHR-01-DCS-PLAYABLE-V1
Wettermodus:          statisch
Temperatur:           20 °C
QNH:                   29.85 inHg
Wolkenpreset:         Bedeckt und Regen 2
Wolkenbasis Editor:   8.850 ft
Nebel:                 aus
Staubsturm:            aus
33 ft:                 170° / 8 kt
1.600 ft:              170° / 10 kt
6.600 ft:              180° / 15 kt
26.000 ft:             200° / 25 kt
Turbulenz:             4 kt
```

## 4. Herkunft der Werte

- Datum, Uhrzeit, Temperatur, QNH und Bodenwind: historische Beobachtung;
- DCS-Windrichtung: um 180 Grad umgesetzter Arbeitswert;
- Höhenwinde und Turbulenz: modellierte DCS-Arbeitswerte;
- Wolkenpreset und Editorbasis: DCS-Näherung an die beobachtete Lage.

## 5. Acceptance-Grenzen

Die Baseline bestätigt ausschließlich die dokumentierte visuelle Nutzbarkeit des Profils. Noch offen sind:

- genaue geometrische Wolkenuntergrenze per Flugmessung;
- Verhalten verschiedener Luftfahrzeugtypen;
- KI-Start, Landung und Navigation;
- Multiplayer-Synchronisation;
- reproduzierbarer Missions- und Hashnachweis in einem formalen Acceptance-Paket.

Bis dieser Nachweis ergänzt ist, darf die Baseline nicht als universell technisch freigegebenes Wetterpreset bezeichnet werden.
