---
document_id: OMW-WX-RAIN-PROFILE
status: BINDING
document_class: DCS_WORKING_PROFILE
owning_policy: OMW-GOV-001
authoritative_for:
  - current visually confirmed Jalalabad rain-shower working profile
  - separation of historical observations from DCS editor approximations
not_authoritative_for:
  - formal technical acceptance
  - all aircraft, AI or multiplayer conditions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unsupported ACCEPTED_TECHNICAL_BASELINE classification
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: PENDING_MERGE
validated_in_dcs: partial
validation_status: VISUALLY_CONFIRMED_WORKING_PROFILE
---

# 43 – DCS-Regenschauerprofil und Editor-Validierung

## 1. Status

`SHR-01-DCS-PLAYABLE-V1` ist ein **verbindlich dokumentiertes, visuell bestätigtes Arbeitsprofil**. Es ist keine formale technische Acceptance-Baseline.

Der vollständige bisherige Testbericht bleibt erhalten:

- [`Legacy-Regenschauer-Testbericht`](evidence/source-records/legacy-43-dcs-rain-shower-preset-validation.md)

Grundlagen:

- [`OMW-WX-HISTORICAL-BASELINE`](41-historical-weather-baseline-2010-2011.md);
- [`OMW-WX-DCS-IMPLEMENTATION`](42-dcs-weather-editor-validation.md);
- [`OMW-GOV-DOCUMENT-METADATA`](DOCUMENT-METADATA-POLICY.md).

## 2. Historische Referenz

```text
KQL5 011255Z 35008G15KT 9999 -SHRA FEW070 BKN090 20/05 A2985
Datum:      01.04.2011
Ortszeit:   17:25 AFT
Temperatur: 20 °C
QNH:        29.85 inHg
```

## 3. DCS-Arbeitsprofil

```text
Profilname:           SHR-01-DCS-PLAYABLE-V1
Wettermodus:          statisch
Temperatur:           20 °C
QNH:                  29.85 inHg
Wolkenpreset:         Bedeckt und Regen 2
Wolkenbasis Editor:   8.850 ft
Nebel:                aus
Staubsturm:           aus
33 ft:                170° / 8 kt
1.600 ft:             170° / 10 kt
6.600 ft:             180° / 15 kt
26.000 ft:            200° / 25 kt
Turbulenz:            4 kt
```

Datum, Uhrzeit, Temperatur, QNH und Bodenwind stammen aus der historischen Beobachtung. Höhenwinde, Turbulenz, Wolkenpreset und Editorbasis sind DCS-Arbeitswerte beziehungsweise Näherungen.

## 4. Beobachtete Wirkung

Visuell bestätigt wurden räumlich unterschiedliche Schauerbereiche, trockene Zwischenräume, brauchbare Bodensicht außerhalb stärkerer Niederschläge und grundsätzlich möglicher Flugbetrieb.

## 5. Fehlende Acceptance-Provenienz

Für `ACCEPTED_TECHNICAL_BASELINE` fehlen weiterhin mindestens:

- reproduzierbare Missionsdatei und SHA-256;
- exakter Branch- und Commitnachweis des Wettertests;
- formales Acceptance-Paket;
- vollständige DCS- und MOOSE-Provenienz;
- Flugmessung der geometrischen Wolkenbasis;
- OH-58D-, AH_64D-, UH-60- und CH-47-Tests;
- KI-, Sensor- und Multiplayerprüfung;
- Langzeitbeobachtung der Schauerzonen.

Erst nach vollständiger Provenienz darf der Status erneut auf `ACCEPTED_TECHNICAL_BASELINE` angehoben werden.
