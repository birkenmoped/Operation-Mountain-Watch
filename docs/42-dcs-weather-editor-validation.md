---
document_id: OMW-WX-DCS-IMPLEMENTATION
status: BINDING
document_class: DCS_EDITOR_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - visually tested DCS weather-editor behavior
  - documented working values for dust and cloud profiles
not_authoritative_for:
  - complete weather-preset acceptance
  - undocumented DCS internal scaling
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/historical-weather-baseline-2010-2011
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: partial
---

# 42 – DCS-Wetterumsetzung und Editor-Validierung

## 1. Einordnung

Dieses Dokument ist die verbindliche DCS-Editor-Arbeitsbaseline für bereits visuell geprüfte Wetterregler und deren beobachtete Wirkung.

Der vollständige frühere Test- und Wertebericht bleibt unverändert erhalten:

- [`Legacy-DCS-Wettereditor-Validierung`](evidence/source-records/legacy-42-dcs-weather-editor-validation.md)

Historische Datenbasis:

- [`OMW-WX-HISTORICAL-BASELINE`](41-historical-weather-baseline-2010-2011.md)

## 2. Verbindliche Datenklassentrennung

Jeder Wert wird als eine der folgenden Klassen geführt:

```text
HISTORICAL_OBSERVATION
DERIVED_WORKING_VALUE
DCS_EDITOR_VALUE
VISUALLY_OBSERVED_EFFECT
ACCEPTED_TECHNICAL_BASELINE
```

Ein historisch korrekter Zahlenwert ist nicht automatisch ein brauchbarer DCS-Reglerwert.

## 3. Sandsturmprofil WIN-04

Historische Ausgangslage:

```text
KQL5 220947Z 27012G25KT 0400 DS BKN000 22/M15 A2972
```

Geprüfte DCS-Staubreglerwirkung in Jalalabad:

| Editorwert | beobachtete Wirkung | Einordnung |
|---:|---|---|
| 1.312 ft | keine erkennbare Staubwirkung | historisch numerisch, technisch unbrauchbar |
| 5.000 ft | leichter trockener Dunst | zu schwach |
| 10.000 ft | deutlicher spielbarer Staubschleier | bevorzugter Arbeitswert |
| 23.000 ft | stärkere adverse Staublage | Extremvariante |

Der DCS-Staubwert darf nicht als direkte meteorologische horizontale Sichtweite bezeichnet werden.

## 4. Windrichtungsregel

Meteorologische Windrichtung beschreibt, **woher** der Wind kommt. Der DCS-Editor verwendet in den geprüften Profilen die Bewegungsrichtung. Daher wird die Richtung um 180 Grad umgesetzt.

Beispiel:

```text
METAR: Wind aus 270°
DCS:   Richtung 090°
```

Diese Regel bleibt versionsbezogen zu prüfen.

## 5. Validierungsgrenzen

`validated_in_dcs: partial` bedeutet:

- einzelne Reglerwerte und Profile wurden visuell geprüft;
- keine allgemeine DCS-Wetterphysik oder interne Skalierung ist bewiesen;
- nicht jedes Flugzeug-, KI-, Multiplayer- oder Sichtverhalten wurde getestet;
- jedes produktive Preset benötigt einen eigenen dokumentierten Testumfang.

## 6. Zugehörige Profile

- [`OMW-WX-RAIN-PROFILE`](43-dcs-rain-shower-preset-validation.md)
- [`OMW-WX-MIST-PROFILE`](44-dcs-valley-mist-low-cloud-test-profile.md)
