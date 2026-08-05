---
document_id: OMW-WX-MIST-PROFILE
status: PLANNED
document_class: DCS_TEST_PROFILE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned Jalalabad valley-mist and low-cloud DCS test
not_authoritative_for:
  - validated DCS fog behavior
  - operational weather preset acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/historical-weather-baseline-2010-2011
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# 44 – DCS-Taldunst- und Tieflagenwolken-Testprofil

## 1. Status

```text
PLANNED – noch nicht visuell oder flugbetrieblich validiert
```

Der vollständige historische Ausgangswert, die Arbeitshypothesen und die vorgeschlagene Vergleichsreihe bleiben unverändert erhalten:

- [`Legacy-Taldunst-Testprofil`](evidence/source-records/legacy-44-dcs-valley-mist-low-cloud-test-profile.md)

Grundlagen:

- [`OMW-WX-HISTORICAL-BASELINE`](41-historical-weather-baseline-2010-2011.md)
- [`OMW-WX-DCS-IMPLEMENTATION`](42-dcs-weather-editor-validation.md)

## 2. Historische Referenz

```text
KQL5 100955Z 29005KT 3200 SHRA BR FEW005 OVC020 14/13 A3003
Datum:      10.04.2011
Ortszeit:   14:25 AFT
Temperatur: 14 °C
QNH:        30.03 inHg
Sicht:      3.200 m
Wetter:     SHRA BR
Wolken:     FEW 500 ft AGL, OVC 2.000 ft AGL
```

`BR` wird als feuchter Dunst beziehungsweise Mist behandelt, nicht als echter Nebel `FG`. Die DCS-Nebelfunktion ist daher nur eine technische Annäherung.

## 3. Geplanter Testkandidat

```text
Profilname:           MST-01-DCS-TEST-V1
Temperatur:           14 °C
QNH:                   30.03 inHg
33 ft:                 110° / 5 kt
1.600 ft:              110° / 7 kt
6.600 ft:              120° / 12 kt
26.000 ft:             140° / 20 kt
Turbulenz:             2 kt
Staubsturm:            aus
Nebelmodus:            Manuell
Sichtweite:            10.500 ft
Dicke Arbeitswert:     2.360 ft
```

Höhenwinde, Turbulenz und Nebeldicke sind modellierte Arbeitswerte. Die Bedeutung der DCS-Nebeldicke und ihre Höhenreferenz sind nicht bestätigt.

## 4. Testziele

- Glaubwürdigkeit der talgebundenen Sichtminderung;
- tatsächliche Oberkante und horizontale Sicht;
- Sicht auf Berghänge und Taleingänge;
- Hubschrauberbetrieb und Navigation;
- KI-Start, Landung und Routenverhalten;
- Verhalten oberhalb der Dunstschicht;
- Multiplayer-Synchronisation;
- Abgrenzung zwischen Nebelregler und tiefem Wolkenpreset.

## 5. Acceptance-Regel

Erst ein dokumentierter DCS-Test mit Mission, Hash, DCS-Version, Screenshots beziehungsweise Messpunkten und beobachtetem Flugverhalten darf den Status auf `ACCEPTED_TECHNICAL_BASELINE` anheben.
