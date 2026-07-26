# TM01C – Abnahme automatische BLUE-Spielerrelevanz

Status: **visueller Einzelspieler-Nahbereichstest bestanden; erweiterte Abnahmen teilweise offen**

Ergebnisnachweis:

```text
mission/tests/tm01-blue-convoy/results/
2026-07-17-tm01c-automatic-player-interest-pass.md
```

Konfiguration:

```text
TM01C-automatic-player-interest-5
```

## Abnahmematrix

| Test | Status | Nachweis |
|---|---|---|
| A – Auto-Pack nach 30 s Abwesenheit | PASS | 5/5 automatische Pack-Anforderungen vollständig bestätigt |
| B – Auto-Unpack bei Annäherung | PASS | 3/3 automatische Unpack-Anforderungen vollständig bestätigt |
| C – Timerabbruch | PASS | Timer nach 27 s bei 743,67 m abgebrochen |
| D – Hysterese | PASS | kein Pack-/Unpack-Flattern im Bereich 500–750 m |
| E – allgemeiner Transition-Schutz | PASS im beobachteten Lauf | keine Doppelanforderung oder parallele Transition; gezielte Grenzüberquerung in jeder einzelnen Transition bleibt offen |
| F – mehrere Spieler | OFFEN | zweiter BLUE-Spieler nicht Teil dieses Laufs |
| G – expliziter Höhentest | OFFEN | horizontales Distanzmodell aktiv; gezielter großer Höhenunterschied noch nicht separat abgenommen |

## Voraussetzungen des bestandenen Laufs

- Bundle aus aktuellem Branch neu gebaut;
- Konfigurationskennung `TM01C-automatic-player-interest-5` im Startup-Log;
- ein besetzter BLUE-OH-58D;
- Konvoi vollständig gestartet und Routenaktivierung bestätigt;
- keine RED-/Feindrelevanzlogik aktiv;
- MOOSE 2.9.18 mit erwartetem Commit und Build-Hash.

## Test A – Auto-Pack nach Abwesenheit – PASS

Verfahren:

1. Konvoi starten.
2. Spieler auf mehr als 750 m horizontalen Abstand bringen.
3. `automatic_pack_timer_started` abwarten.
4. mindestens 30 Sekunden dauerhaft außerhalb bleiben.
5. sichtbares und protokolliertes Packen prüfen.

Bestätigte Ereigniskette:

```text
playerInterestBand=OUTSIDE
automatic_pack_timer_started
automatic_pack_requested
convoy_pack_started
convoy_packed
representationState=COLLAPSED_PROXY
halted=false
```

Der Log enthält fünf vollständige automatische Pack-Zyklen. Jeder Timer lief exakt 30 Sekunden bis zur Anforderung. Es gab keine fehlgeschlagene oder doppelte Pack-Anforderung.

## Test B – Auto-Unpack bei Annäherung – PASS

Verfahren:

1. Mit eingepacktem Konvoi auf höchstens 500 m horizontal annähern.
2. sichtbares Entpacken beobachten.
3. Ausrichtung und Routenaktivierung prüfen.

Bestätigte Ereigniskette:

```text
player_relevance_entered
automatic_unpack_requested
convoy_unpack_started
convoy_unpacked
convoy_route_activation_confirmed
representationState=EXPANDED
halted=false
```

Automatische Unpack-Anforderungen wurden bei 486,53 m, 485,89 m und 491,63 m ausgelöst. Alle drei führten zu genau einem bestätigten Unpack und anschließend bestätigter Bewegung.

Die visuelle Beobachtung bestätigte korrekt entlang der Straße ausgerichtete Fahrzeuge und störungsfreies Weiterfahren.

## Test C – Timerabbruch – PASS

Verfahren:

1. Expandierten Konvoi verlassen und `automatic_pack_timer_started` abwarten.
2. vor Ablauf von 30 Sekunden wieder auf höchstens 750 m annähern.
3. prüfen, dass kein Packen erfolgt.

Bestätigt:

```text
automatic_pack_timer_started
...
automatic_pack_timer_cancelled
timerElapsedSeconds=27
nearestPlayerDistanceMeters=743.665...
```

Aus dem abgebrochenen Timer folgte kein `automatic_pack_requested`.

## Test D – Hysterese – PASS

Bestätigte Bänder:

```text
Distanz <= 500 m
→ INSIDE_UNPACK

500 m < Distanz <= 750 m
→ HYSTERESIS

Distanz > 750 m
→ OUTSIDE
```

Der Log enthält wiederholte Wechsel durch `HYSTERESIS` in beiden Repräsentationszuständen. Es trat kein Flattern auf:

```text
EXPANDED bleibt EXPANDED
COLLAPSED_PROXY bleibt COLLAPSED_PROXY
```

Ein Wiedereintritt in die Hysteresezone brach einen laufenden Pack-Timer korrekt ab.

## Test E – Transition-Schutz – PASS im beobachteten Lauf / gezielte Teiltests offen

Im gesamten Lauf trat nicht auf:

```text
parallele zweite Transition
doppelte automatische Pack-Anforderung
doppelte automatische Unpack-Anforderung
Pack und Unpack gleichzeitig
```

Die Automatik wertete nach abgeschlossener Routenaktivierung erneut aus. Ein gezieltes Überqueren der Distanzgrenzen genau während jeder einzelnen Phase bleibt als optionaler Stresstest offen:

```text
PACKING
UNPACKING
ACTIVATING_ROUTE
```

## Test F – mehrere Spieler – OFFEN

Noch zu prüfen:

- ein BLUE-Spieler außerhalb 750 m;
- ein BLUE-Spieler innerhalb 500 m;
- der nähere Spieler bestimmt die Relevanz;
- Auto-Pack startet erst, wenn alle gültigen BLUE-Spieler außerhalb 750 m sind.

Dieser Test ist für Multiplayer-Skalierung relevant, blockiert aber nicht das PASS des vereinbarten Einzelspieler-Proof-of-Concepts.

## Test G – Spielerhöhe – OFFEN

Noch separat zu prüfen:

- Spieler direkt über dem Konvoi;
- großer Höhenunterschied;
- horizontal innerhalb 500 m;
- kein Auto-Pack allein aufgrund der Höhe.

Die Implementierung protokollierte `distanceModel=HORIZONTAL_2D`; der separate DCS-Nachweis mit bewusst großer Höhe bleibt offen.

## Zusätzliche positive Regressionen

Der Abnahmelauf bewies zusätzlich:

```text
- drei beobachtete Fahrzeugverluste;
- Survivor-Liste reduzierte sich auf 5,2,1;
- zerstörte Slots blieben nach Pack/Unpack zerstört;
- partielle Schäden wurden pro Stable Slot erhalten;
- zwei beschädigte Fahrzeuge wurden nach Unpack wiederhergestellt und verifiziert;
- alle Routenaktivierungen wurden bestätigt;
- kein Controller-Halt;
- keine TM01C-ERROR-Ereignisse.
```

## Fehlerkriterien

Im bestandenen Lauf trat keines dieser Kriterien auf:

```text
player_interest_monitor_initialization_failed
player_interest_monitor_failed
proxy_controller_initialization_failed
convoy_route_activation_timeout
convoy_route_activation_failed
convoy_pack_failed
convoy_unpack_failed_proxy_restored
halted=true
movementState=FAILED
```

Ein erneuter manueller `Start convoy`-Aufruf wurde erwartungsgemäß mit `convoy has already been started` abgewiesen. Das ist kein Fehler der Automatik.

## Abnahmeentscheidung

```text
Visueller Einzelspieler-Proof-of-Concept: PASS
Mehrspieler-Nähe:                      OFFEN
Expliziter Höhentest:                  OFFEN
Operative Produktionsradien:           NICHT FESTGELEGT
Sichtlinie/Sensorik/Feindrelevanz:      NICHT BESTANDTEIL
```

Die automatische Pack-/Unpack-Grundfunktion ist damit in DCS nachgewiesen.