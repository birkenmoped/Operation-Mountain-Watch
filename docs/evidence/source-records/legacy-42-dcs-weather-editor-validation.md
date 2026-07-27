---
document_id: OMW-WX-DCS-IMPLEMENTATION
status: BINDING
authoritative_for:
  - visually tested DCS weather editor behavior
  - validated working values for dust and cloud profiles
scenario_period: 2010-08-01/2011-12-31
data_coverage: 2010-08-01/2011-05-20
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/historical-weather-baseline-2010-2011
validated_in_dcs: partial
---

# 42 – DCS-Wetterumsetzung und Editor-Validierung

## Dokumentstatus

Dieses Dokument ergänzt `OMW-WX-HISTORICAL-BASELINE` in [`41-historical-weather-baseline-2010-2011.md`](41-historical-weather-baseline-2010-2011.md).

Historische METAR-Werte, modellierte Höhenwinde, DCS-Editorwerte und tatsächlich beobachtete Wirkung sind getrennte Datenklassen. Ein historisch korrekter Zahlenwert ist nicht automatisch ein brauchbarer DCS-Reglerwert.

## 1. Sandsturm-Testprofil WIN-04

### Historische Ausgangslage

```text
KQL5 220947Z 27012G25KT 0400 DS BKN000 22/M15 A2972
```

```text
Datum: 22.12.2010
Ortszeit: 14:17 AFT
Temperatur: 22 °C
Taupunkt: -15 °C
Wind: aus 270° mit 12 kt, Böen 25 kt
historische Sicht: 400 m / ca. 1.312 ft
Wetter: DS
QNH: 29.72 inHg
```

`BKN000` wird als durch Staub verdeckter Himmel interpretiert und nicht als reale Wolkendecke auf 0 ft umgesetzt.

### Testkonfiguration

```text
Wettermodus: statisch
Wolkenpreset: Nichts
Niederschlag: keine
Nebel: aus
Staubsturm: ein
```

DCS verwendet die Bewegungsrichtung des Luftstroms. Meteorologischer Wind **aus 270°** wird deshalb als **090°** im Editor eingetragen.

```text
33 ft:     090° / 12 kt
1.600 ft:  090° / 18 kt
6.600 ft:  095° / 25 kt
26.000 ft: 105° / 35 kt
Turbulenz: 8 kt
```

Nur der Bodenwind ist historisch belegt. Höhenwinde und Turbulenz sind modellierte Arbeitswerte.

### Geprüfte Staubreglerwerte in Jalalabad

| DCS-Wert | Beobachtete Wirkung | Bewertung |
|---:|---|---|
| 1.312 ft | keine erkennbare Staubwirkung | historisch numerisch korrekt, in DCS unbrauchbar |
| 5.000 ft | leichter trockener Dunst | zu schwach |
| 10.000 ft | deutlicher gelblich-brauner Schleier, reduzierte Kontraste | bester spielbarer Arbeitswert |
| 23.000 ft | deutlich stärkere Staublage | adversere Variante |

Verbindliche Erkenntnis:

> Der DCS-Staubsturmwert darf nicht direkt als meteorologische horizontale Sichtweite bezeichnet werden.

Die interne Skalierung oder Höhenreferenz ist durch diese Tests nicht abschließend bewiesen.

### WIN-04-DCS-PLAYABLE-V1

```text
Datum:              22.12.2010
Startzeit:          14:17 lokal
Temperatur:         22 °C
QNH:                 29.72 inHg
Wolkenpreset:       Nichts
Niederschlag:       keine
Nebel:               aus
Staubsturm:         ein
Staubsturmwert:     10.000 ft
33 ft:              090° / 12 kt
1.600 ft:           090° / 18 kt
6.600 ft:           095° / 25 kt
26.000 ft:          105° / 35 kt
Turbulenz:          8 kt
```

Status:

```text
visuell validierter DCS-Arbeitsstand
nicht quantitativ gleich der historischen 400-m-Sicht
Cockpit-, Sensor-, KI-, Höhenlagen- und Multiplayerprüfung offen
```

### WIN-04-DCS-STRONG-V1

Gleiche Grundlage mit:

```text
Staubsturmwert: 23.000 ft
```

Diese Variante ist als stärkere DCS-Interpretation und nicht als direkte METAR-Übersetzung zu kennzeichnen.

## 2. Wolkenprofil CLD-01

### Historische Ausgangslage

```text
KQL5 141055Z 07002KT 9999 SCT015 BKN055 BKN075 09/04 A2980
```

```text
Datum: 14.01.2011
Ortszeit: 15:25 AFT
Temperatur: 9 °C
Taupunkt: 4 °C
Wind: aus 070° mit 2 kt
Sicht: mindestens 10 km
Wolken: SCT 1.500 ft AGL, BKN 5.500 und 7.500 ft AGL
QNH: 29.80 inHg
```

Die reale Mehrschichtstruktur kann mit einem DCS-Preset nur angenähert werden.

### Presetabhängige Mindesthöhen

| Preset | niedrigster beobachteter Editorwert | Bewertung |
|---|---:|---|
| Aufgerissene Bewölkung 1 | 5.512 ft | für tiefe Jalalabad-Lage zu hoch |
| Aufgerissene Bewölkung 3 | 2.756 ft | geeigneter Arbeitsbereich |

Eine allgemeine minimale DCS-Wolkenbasis darf nicht ohne Angabe des Presets dokumentiert werden.

### CLD-01-DCS-PLAYABLE-V1

```text
Datum:              14.01.2011
Startzeit:          15:25 lokal
Temperatur:         9 °C
QNH:                 29.80 inHg
Wolkenpreset:       Aufgerissene Bewölkung 3
Editorbasis:        3.343 ft
Niederschlag:       keine
Nebel:               aus
Staubsturm:         aus
33 ft:              250° / 2 kt
1.600 ft:           250° / 4 kt
6.600 ft:           260° / 8 kt
26.000 ft:          270° / 15 kt
Turbulenz:          1 kt
```

Status:

- in Jalalabad visuell geprüft;
- glaubwürdige tiefe, aufgerissene Bewölkung;
- tatsächliche geometrische Wolkenbasis noch durch Flugmessung zu verifizieren;
- historische Mehrschichtstruktur nur visuell angenähert.

## 3. Regen- und Taldunstprofile

Das validierte Regenschauerprofil wird separat geführt:

- [`OMW-WX-RAIN-PROFILE`](43-dcs-rain-shower-preset-validation.md)

Der noch nicht validierte Taldunst-/Tieflagenwolken-Testkandidat wird separat geführt:

- [`OMW-WX-MIST-PROFILE`](44-dcs-valley-mist-low-cloud-test-profile.md)

## 4. Verbindliche Dokumentationsregel

Jedes DCS-Wetterprofil weist mindestens aus:

```yaml
profile_id:
historical_source:
historical_observation:
historical_visibility:
historical_surface_wind:
dcs_editor_values:
modelled_values:
validated_location:
validated_dcs_version:
visual_validation:
flight_validation:
ai_validation:
sensor_validation:
multiplayer_validation:
known_deviations:
```

Insbesondere werden getrennt:

1. historischer METAR-Wert;
2. modellierter Arbeitswert;
3. DCS-Editorwert;
4. beobachtete DCS-Wirkung;
5. vollständiger Acceptance-Status.

## 5. Offene gemeinsame Prüfungen

- Cockpitflüge mit OH-58D, AH-64D, UH-60 und CH-47;
- tatsächliche Sicht- und Identifikationsreichweite;
- Wolkenbasis durch Höhenmessung;
- EO/IR-, TADS- und Mastvisierwirkung;
- DCS-KI-Erkennung und Angriffsverhalten;
- Convoy-Aufklärung und Bodenzielerfassung;
- Wirkung außerhalb des Jalalabad-Tals;
- Tageszeit- und Sonnenstandabhängigkeit;
- Multiplayer-Synchronität und Leistung;
- mindestens 60 Minuten Laufzeit für dynamisch wirkende Niederschlagszonen.

## 6. Autoritätsregel

Die dokumentierten visuellen Ergebnisse gelten nur für den tatsächlich geprüften DCS-Stand, Ort und Reglerwert. Sie dürfen bei einer DCS-Versionänderung nicht automatisch als weiterhin validiert behandelt werden.
