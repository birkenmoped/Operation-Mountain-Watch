---
document_id: OMW-WX-MIST-PROFILE
status: PLANNED
authoritative_for:
  - planned Jalalabad valley-mist and low-cloud DCS test
scenario_period: 2010-08-01/2011-12-31
historical_observation_date: 2011-04-10
source_branch: docs/historical-weather-baseline-2010-2011
validated_in_dcs: false
---

# 44 – DCS-Taldunst- und Tieflagenwolken-Testprofil

## Dokumentstatus

**Geplanter DCS-Testkandidat – noch nicht visuell oder flugbetrieblich validiert.**

Verweis auf die Datenbasis:

- [`OMW-WX-HISTORICAL-BASELINE`](41-historical-weather-baseline-2010-2011.md)
- [`OMW-WX-DCS-IMPLEMENTATION`](42-dcs-weather-editor-validation.md)

Historischer METAR-Wert, abgeleiteter Arbeitswert und beobachtete DCS-Wirkung müssen getrennt dokumentiert werden.

## 1. Historische Ausgangslage

Grundlage ist Profil `SPR-01`:

```text
KQL5 100955Z 29005KT 3200 SHRA BR FEW005 OVC020 14/13 A3003
```

```text
Datum: 10.04.2011
Ortszeit: 14:25 AFT
Temperatur: 14 °C
Taupunkt: 13 °C
relative Feuchte: etwa 94 %
Wind: aus 290° mit 5 kt
Sicht: 3.200 m / ca. 10.500 ft
Wetter: SHRA BR
Wolken: FEW 500 ft AGL, OVC 2.000 ft AGL
QNH: 30.03 inHg
```

`BR` bezeichnet feuchten Dunst beziehungsweise Mist, nicht echten Nebel. Echter Nebel würde mit `FG`, flacher Bodennebel etwa mit `MIFG`, gemeldet.

Die DCS-Nebelfunktion ist daher nur eine technische Annäherung an die historische Sichtminderung. Das Profil wird fachlich als **Taldunst mit tiefen Wolken** geführt.

## 2. Zielbild

- feuchte, kontrastarme Luft im Jalalabad-Tal;
- flache Dunst- beziehungsweise Nebelschicht am Talboden;
- teilweise verdeckte untere Berghänge und Taleingänge;
- tiefere Wolken an umliegenden Höhenzügen;
- oberhalb der flachen Schicht bessere Sicht;
- weiterhin möglicher Hubschrauberbetrieb;
- erschwerte Navigation und Zielidentifikation in Seitentälern.

Ob DCS mit globalen Reglern tatsächlich eine glaubwürdige talgebundene Darstellung erzeugt, ist offen.

## 3. Vorgeschlagene DCS-Grundkonfiguration

```text
Profilname:           MST-01-DCS-TEST-V1
Datum:                10.04.2011
Startzeit:            14:25 lokal
Temperatur:           14 °C
QNH:                   30.03 inHg
33 ft:                110° / 5 kt
1.600 ft:             110° / 7 kt
6.600 ft:             120° / 12 kt
26.000 ft:            140° / 20 kt
Turbulenz:            2 kt
Staubsturm:           aus
```

Der historische Bodenwind kommt aus 290°. Für den DCS-Editor wird die Gegenrichtung 110° eingetragen. Höhenwinde und Turbulenz sind modellierte Arbeitswerte.

## 4. Dunst-/Nebelschicht

### Erster Arbeitswert

```text
Nebelmodus:           Manuell
Sichtweite:           10.500 ft
Dicke:                2.360 ft
```

Die Sichtweite entspricht näherungsweise den historischen 3.200 m.

Jalalabad liegt in der bisherigen DCS-Beobachtung bei ungefähr 1.843 ft MSL. Unter der unbestätigten Arbeitshypothese, dass der Editorwert der Nebeldicke von MSL aus wirkt, würde 2.360 ft etwa 517 ft über den Flugplatz reichen. Diese Interpretation muss praktisch geprüft werden.

### Vergleichsreihe

| Test | DCS-Nebeldicke | Beabsichtigte Wirkung |
|---|---:|---|
| MST-01-A | 1.970 ft | Schicht knapp über Flugplatzniveau |
| MST-01-B | 2.360 ft | nominell etwa 500 ft über Jalalabad |
| MST-01-C | 2.950 ft | deutlich höhere Einbettung von Tal und Hängen |

Die Sichtweite bleibt zunächst in allen Durchläufen bei 10.500 ft.

## 5. Wolken

Historisch:

```text
FEW 500 ft AGL
OVC 2.000 ft AGL
```

Erster Editor-Arbeitswert für die Hauptschicht:

```text
Wolkenbasis: etwa 3.850 ft im DCS-Editor
```

Presetauswahl:

1. zunächst ein `Bedeckt`-Preset testen, das etwa 3.850 ft zulässt;
2. falls technisch oder flugbetrieblich ungeeignet, `Aufgerissene Bewölkung 3` als ausdrücklich gekennzeichnete Ersatzlösung prüfen;
3. die Abweichung von `OVC020` sichtbar dokumentieren.

Die getrennte historische `FEW005`-Schicht lässt sich mit einem einzelnen DCS-Preset voraussichtlich nicht separat reproduzieren.

## 6. Testreihenfolge

Der erste Test erfolgt ohne Niederschlag, damit Dunst- und Wolkenwirkung getrennt beurteilt werden können:

1. identische Beobachtungspositionen und Kamerablickrichtungen verwenden;
2. Nebeldicken 1.970, 2.360 und 2.950 ft vergleichen;
3. Sichtweite bei 10.500 ft konstant halten;
4. Wolkenpreset und -basis konstant halten;
5. Flugplatz, Talboden und Berghänge getrennt bewerten;
6. danach historische Schauerkomponente ergänzen;
7. Cockpit-, Höhen-, Sensor-, KI- und Multiplayerprüfung durchführen.

## 7. Abnahmekriterien

| Kriterium | Status vor Test |
|---|---|
| feuchte Dunstwirkung sichtbar | offen |
| Flugplatz für Hubschrauber nutzbar | offen |
| Berghänge/Taleingänge teilweise verdeckt | offen |
| oberhalb der Schicht bessere Sicht | offen |
| keine unplausible globale Weißfärbung | offen |
| Wolkenbasis praktisch bestätigt | offen |
| Cockpitperspektive geprüft | offen |
| KI-, Sensor- und Multiplayerwirkung geprüft | offen |

## 8. Verbindliche Kennzeichnung

```text
Profil:                    MST-01-DCS-TEST-V1
Status:                    geplanter Testkandidat
Historische Sicht:         ca. 10.500 ft
DCS-Nebeldicke:            zunächst 2.360 ft
Wolkenbasis:               zunächst ca. 3.850 ft
Visuell validiert:         nein
Flugbetrieblich geprüft:   nein
```

Das Profil darf vor der praktischen Prüfung nicht als freigegebenes Kampagnenpreset bezeichnet werden.
