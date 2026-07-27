---
document_id: OMW-WX-RAIN-PROFILE
status: ACCEPTED_TECHNICAL_BASELINE
authoritative_for:
  - visually validated Jalalabad rain shower working profile
scenario_period: 2010-08-01/2011-12-31
historical_observation_date: 2011-04-01
source_branch: docs/historical-weather-baseline-2010-2011
validated_in_dcs: partial
---

# 43 – DCS-Regenschauerprofil und Editor-Validierung

## Dokumentstatus

**Visuell geprüftes Arbeitsprofil für wechselnde Regenschauer bei weiterhin möglichem Flugbetrieb.**

Verweise:

- [`OMW-WX-HISTORICAL-BASELINE`](41-historical-weather-baseline-2010-2011.md)
- [`OMW-WX-DCS-IMPLEMENTATION`](42-dcs-weather-editor-validation.md)

Historische METAR-Werte, modellierte Höhenwinde, DCS-Editorwerte und beobachtete Darstellung werden getrennt behandelt.

## 1. Historische Ausgangslage

### Wetterverlauf am 1. April 2011

| Ortszeit Afghanistan | Relevante METAR-Angabe | Einordnung |
|---|---|---|
| 07:25 | `8000 VCSH HZ FEW060 SCT100` | Schauer in Platznähe, Dunst |
| 08:25 | `9999 FEW060 SCT100`, `VC SHRA DSPTD` | Schauer in der Umgebung abgeklungen |
| 09:25 | `9999 FEW060 SCT100`, `SHRA DSNT N OVR MTN` | Schauer nördlich über den Bergen |
| 11:25 | Gewitter südwestlich und nordwestlich | konvektive Aktivität im Umfeld |
| 12:25 | `9999 SCT050 BKN200`, Schauer nördlich | trockener Platz, Schauer im Umfeld |
| 17:25 | `9999 -SHRA FEW070 BKN090` | leichter Regenschauer am Platz |
| 19:25 | `9999 FEW120 FEW150` | Schauer beendet |

Der Verlauf belegt Schauerstaffeln, trockene Zwischenräume und gute Sicht außerhalb der Niederschlagszonen.

### Referenz-METAR

```text
KQL5 011255Z 35008G15KT 9999 -SHRA FEW070 BKN090 20/05 A2985 RMK AO2A LTG DSNT NE SLP098 WND DATA ESTMD ALSTG/SLP ESTMD
```

```text
Datum: 01.04.2011
UTC: 12:55
Ortszeit: 17:25 AFT
Temperatur: 20 °C
Taupunkt: 5 °C
Wind: aus 350° mit 8 kt, Böen 15 kt
Sicht: mindestens 10 km
Wetter: -SHRA
Wolken: FEW 7.000 ft AGL, BKN 9.000 ft AGL
QNH: 29.85 inHg
```

Die historische Lage beschreibt keinen tiefen, flugbetrieblich weitgehend sperrenden Zustand.

## 2. Praktisch getestete DCS-Konfiguration

```text
Profilname:           SHR-01-DCS-PLAYABLE-V1
Datum:                01.04.2011
Startzeit:            17:25 lokal
Wettermodus:          statisch
Temperatur:           20 °C
QNH:                   29.85 inHg
Wolkenpreset:         Bedeckt und Regen 2
Wolkenbasis:          8.850 ft im Editor
Niederschlag:         durch Preset
Nebel:                 aus
Staubsturm:           aus
33 ft:                170° / 8 kt
1.600 ft:             170° / 10 kt
6.600 ft:             180° / 15 kt
26.000 ft:            200° / 25 kt
Turbulenz:            4 kt
```

### Herkunft der Werte

| Wert | Status |
|---|---|
| Datum, Uhrzeit, Temperatur, QNH | historisch |
| Bodenwind aus 350° mit 8 kt, Böen 15 kt | historisch |
| DCS-Bodenwind 170° / 8 kt | Richtung um 180° umgesetzt |
| Höhenwinde | modellierte Arbeitswerte |
| Turbulenz 4 kt | DCS-Arbeitswert |
| Wolkenpreset | DCS-Näherung |
| Editorbasis 8.850 ft | Arbeitswert zur Annäherung an `FEW070` |

Bei einer Platzhöhe von ungefähr 1.843 ft MSL entspricht der Editorwert rechnerisch etwa 7.000 ft über dem Flugplatz. Die tatsächliche geometrische Wolkenuntergrenze ist noch durch Flugmessung zu bestätigen.

## 3. Beobachtete Wirkung

- räumlich unterschiedliche helle und dunkle Wetterbereiche;
- sichtbare Niederschlags- beziehungsweise Schauerbereiche;
- gleichzeitig trocken wirkende Abschnitte;
- gute Bodensicht außerhalb stärkerer Schauer;
- keine durchgehend tiefe, den ganzen Flugplatz einschließende Wolkendecke;
- plausible Betriebsbedingungen für Hubschrauber und niedrig fliegende Starrflügler.

Das Preset wirkt wie örtlich wechselnde Schauer. Die historische Struktur `FEW070 BKN090` wird nicht exakt reproduziert; das DCS-Preset ist dichter und komplexer, liefert aber die benötigte räumlich variierende Niederschlagswirkung.

## 4. Bewertung

`SHR-01-DCS-PLAYABLE-V1` ist ein **visuell validierter Arbeitsstand**.

| Kriterium | Ergebnis |
|---|---|
| wechselnde statt überall gleichmäßige Niederschlagswirkung | visuell erfüllt |
| Wolken ausreichend hoch für Talflugbetrieb | visuell plausibel |
| Flugplatz am Boden nutzbar | erfüllt |
| gute Sicht außerhalb der Schauer | visuell erfüllt |
| historische Wolkenstruktur exakt | nicht möglich, angenähert |
| tatsächliche AGL-Wolkenbasis | offen |
| zeitliche Entwicklung über längere Mission | offen |
| Spieler-, KI-, Sensor- und Multiplayerprüfung | offen |

## 5. Verbindliche Erkenntnisse

1. Für „wechselnde Regenschauer“ ist der Verlauf benachbarter METARs zu betrachten.
2. DCS-Regenpresets können dichter wirken als historische `FEW`-/`BKN`-Schichten.
3. Eine hohe Editorbasis kann Flugbetrieb erhalten, während Niederschlag örtlich missionswirksam bleibt.
4. DCS-Editorbasis, historische AGL-Untergrenze und gemessene DCS-Wolkenbasis sind getrennt auszuweisen.
5. Räumlich verschiedene Schauerzonen in Standbildern beweisen noch keine zeitliche Bewegung.
6. Höhenwinde und Turbulenz sind ohne separate Quelle keine historischen Messwerte.

## 6. Offene Prüfungen

- Wolkenbasis per Flug verifizieren;
- Regenzonen mindestens 60 Minuten beobachten;
- Cockpitübergänge zwischen trockenen Bereichen und Schauern prüfen;
- Sicht innerhalb und außerhalb des Niederschlags vergleichen;
- OH-58D, AH-64D, UH-60 und CH-47 testen;
- Start-, Lande- und Platzrundenbetrieb bewerten;
- EO/IR-, TADS- und Mastvisierwirkung prüfen;
- DCS-KI-Verhalten untersuchen;
- Gebirgsrouten nach Kunar, Laghman und Kabul erproben;
- Multiplayer-Synchronität vergleichen.

Bis dahin ist das Profil nicht vollständig als Kampagnenpreset abgenommen.
