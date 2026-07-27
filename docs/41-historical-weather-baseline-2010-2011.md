---
document_id: OMW-WX-HISTORICAL-BASELINE
status: BINDING
authoritative_for:
  - current Jalalabad METAR dataset
  - selected historical weather profiles
  - seasonal weather statistics for the dataset coverage
scenario_period: 2010-08-01/2011-12-31
data_coverage: 2010-08-01/2011-05-20
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/historical-weather-baseline-2010-2011
validated_in_dcs: false
---

# 41 – Historische Wetterbasis Jalalabad 2010–2011

## Dokumentstatus

Dieses Dokument definiert die derzeit verfügbare historische Wetter- und Planungsbasis für **Operation Mountain Watch**.

Zwei Zeiträume sind strikt zu unterscheiden:

```text
Verbindlicher Kampagnen- und Recherchezeitraum:
01.08.2010 bis 31.12.2011

Derzeit ausgewerteter QL5/KQL5-METAR-Datensatz:
01.08.2010 bis 20.05.2011 UTC
```

Der METAR-Datensatz deckt damit noch nicht den gesamten erweiterten Kampagnenzeitraum ab. Er bleibt für die enthaltenen Daten fachlich gültig, darf aber nicht als vollständige Wetterstatistik bis Dezember 2011 bezeichnet werden.

## Zweck und Abgrenzung

Die derzeit ausgewählten 16 METAR-Beobachtungen bilden vier reale Wetterlagen je Jahreszeit innerhalb der vorhandenen Datenabdeckung ab:

- eine normale beziehungsweise häufige Lage;
- eine typische Sichtminderungs- oder Bewölkungslage;
- eine reale Schlechtwetterlage;
- eine seltene adverse beziehungsweise extreme Missionslage.

Die Profile sind nicht gleich wahrscheinlich. Gewitter, schwere Staubstürme und sehr geringe Sichtweiten sind reale Sonderlagen, dürfen aber nicht mit derselben Häufigkeit wie saisonales Normalwetter ausgewählt werden.

Dieses Dokument enthält historische Bodenbeobachtungen, keine abschließend freigegebene DCS-Presetbibliothek. DCS-Editorwerte und praktisch beobachtete Wirkung werden in den Umsetzungsdokumenten getrennt geführt.

## Datenbasis

```text
Station: QL5 / KQL5
Stationsbezeichnung: JALALABAD
Archivabdeckung: 01.08.2010–20.05.2011 UTC
Beobachtungen: 4.886 METAR-Datensätze
Zeitbasis: UTC
Afghanistan-Ortszeit: UTC+4:30
Quelle: Iowa Environmental Mesonet, historisches ASOS/METAR-Archiv
Abrufparameter: report_type=2
```

Die vollständige Rohdatei wird über den dokumentierten IEM-Abruf reproduziert. Projektseitig gespeichert werden die ausgewählten Profile und die saisonale Statistik als kleine, diff-fähige CSV-Dateien.

## Begleitdateien

- [`data/weather/QL5-selected-historical-weather-profiles-2010-2011.csv`](data/weather/QL5-selected-historical-weather-profiles-2010-2011.csv)
- [`data/weather/QL5-seasonal-weather-statistics-2010-2011.csv`](data/weather/QL5-seasonal-weather-statistics-2010-2011.csv)
- [`data/weather/README.md`](data/weather/README.md)
- [`OMW-WX-DCS-IMPLEMENTATION – DCS-Wetterumsetzung und Editor-Validierung`](42-dcs-weather-editor-validation.md)
- [`OMW-WX-RAIN-PROFILE – DCS-Regenschauerprofil`](43-dcs-rain-shower-preset-validation.md)
- [`OMW-WX-MIST-PROFILE – Taldunst-/Tieflagenwolken-Testprofil`](44-dcs-valley-mist-low-cloud-test-profile.md)

## Saisonaler Überblick der vorhandenen Daten

Die Sichtweite wurde für den Mittelwert bei 10 km gedeckelt, weil METAR `9999` nur „10 km oder mehr“ bedeutet. Kategorien können sich überschneiden.

| Datensegment | Beobachtungen | Ø Temperatur | Temperaturbereich | Ø Wind | Ø Sicht, max. 10 km | HZ | FU | Regen/Schauer | Gewitter | Staub |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| August 2010 | 765 | 30,3 °C | 20–39 °C | 4,0 kt | 9,5 km | 20,0 % | 0,0 % | 6,7 % | 1,7 % | 0,4 % |
| Herbst 2010 | 2.218 | 22,1 °C | 4–38 °C | 2,9 kt | 8,8 km | 48,8 % | 8,5 % | 1,1 % | 0,6 % | 2,5 % |
| Winter 2010/2011 | 1.385 | 9,6 °C | 0–22 °C | 2,5 kt | 8,2 km | 45,2 % | 21,0 % | 2,8 % | 0,1 % | 1,6 % |
| Frühling bis 20.05.2011 | 518 | 23,4 °C | 6–43 °C | 4,2 kt | 9,2 km | 20,1 % | 0,0 % | 5,6 % | 2,3 % | 5,4 % |

### Belastbarkeit

- August 2010 bildet nur einen Sommermonat ab.
- Herbst und Winter sind innerhalb des vorhandenen Datensatzes weitgehend abgedeckt.
- Frühling endet am 20.05.2011.
- Die Berichtsdichte fällt ab Januar 2011 deutlich ab.
- Saisonale Prozentwerte für Winter und Frühling sind weniger robust als für August bis Dezember 2010.
- Für 21.05.2011 bis 31.12.2011 liegt in dieser Auswertung noch keine gleichwertige Statistik vor.

## Profilklassen

Die 16 konkreten METARs und Originalmeldungen werden autoritativ in der CSV geführt. Für Dokumentation und Missionsauswahl gelten die Klassen:

```text
SUM-01 ... SUM-04
AUT-01 ... AUT-04
WIN-01 ... WIN-04
SPR-01 ... SPR-04
```

Die IDs bleiben stabil, auch wenn später zusätzliche Profile für Juni bis Dezember 2011 ergänzt werden. Neue Profile erhalten eigene IDs und überschreiben die bisherigen Beobachtungen nicht.

## Verbindliche Interpretationsregeln

1. METAR beschreibt eine Bodenbeobachtung zu einem konkreten Zeitpunkt.
2. `9999` bedeutet mindestens 10 km Sicht, nicht exakt 10 km.
3. Höhenwinde sind aus dieser Quelle nicht belegt.
4. Modellierte Höhenwinde müssen ausdrücklich als Arbeitswerte gekennzeichnet werden.
5. DCS-Wolken-, Nebel- und Staubregler sind keine direkte physikalische Übersetzung der METAR-Werte.
6. Historischer Wert, DCS-Editorwert und beobachtete DCS-Wirkung werden getrennt dokumentiert.
7. Eine einzelne Extremmeldung bestimmt nicht die normale saisonale Auswahlhäufigkeit.
8. Der vorhandene Datensatz darf nicht als vollständige Statistik des gesamten Kampagnenzeitraums ausgegeben werden.

## Erweiterungsauftrag für den Zeitraum bis Dezember 2011

Für die vollständige Kampagnenabdeckung ist nach Möglichkeit nachzuliefern:

- weitere QL5/KQL5-Beobachtungen vom 21.05.2011 bis 31.12.2011;
- falls QL5 lückenhaft bleibt, geeignete regionale Vergleichsstationen;
- dokumentierte Stationsentfernung und Übertragbarkeitsgrenzen;
- zusätzliche Sommer-, Herbst- und Frühwinterprofile 2011;
- Abgleich mit Satellitenbildzeitpunkten und ausgewählten Missionsbaselines;
- getrennte Statistik für den ergänzten Zeitraum.

Bis dahin sind die vorhandenen 16 Profile gültige historische Wetterkandidaten, aber keine vollständige klimatologische Repräsentation der erweiterten Kampagne.

## Häufigkeitsmodell für die spätere Presetbibliothek

Eine spätere Auswahl soll mindestens unterscheiden:

```text
NORMAL
COMMON_REDUCED_VISIBILITY
ADVERSE
RARE_EXTREME
```

Extremprofile erhalten deutlich geringere Auswahlgewichte. Die genauen Gewichte werden erst nach Erweiterung der Datenbasis und DCS-Flugtests verbindlich festgelegt.

## Autoritätsregel

- Dieses Dokument: historische Datenbasis, Abdeckung, Statistik und Profil-IDs.
- `OMW-WX-DCS-IMPLEMENTATION`: praktisch getestete DCS-Umsetzungen.
- `OMW-WX-RAIN-PROFILE`: validierter Regenschauer-Arbeitsstand.
- `OMW-WX-MIST-PROFILE`: noch nicht validierter Taldunst-/Tieflagenwolken-Testkandidat.

Eine DCS-Umsetzung darf die historischen Werte nicht rückwirkend verändern; umgekehrt darf ein METAR-Wert nicht ohne DCS-Test als direkt funktionsfähiger Editorwert gelten.
