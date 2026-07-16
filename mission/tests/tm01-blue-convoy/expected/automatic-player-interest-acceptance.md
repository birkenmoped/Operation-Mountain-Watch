# TM01C – Abnahme automatische BLUE-Spielerrelevanz

Status: DCS-Laufzeitnachweis erforderlich

## Voraussetzungen

- Bundle aus aktuellem Branch neu gebaut;
- Konfigurationskennung `TM01C-automatic-player-interest-5` im Startup-Log;
- ein besetzter BLUE-Hubschrauber oder ein anderes gültiges BLUE-Spielerfahrzeug;
- Konvoi vollständig gestartet und Routenaktivierung bestätigt;
- keine RED-/Feindrelevanzlogik aktiv.

## Test A – Auto-Pack nach Abwesenheit

1. Konvoi starten.
2. Spieler auf mehr als 750 m horizontalen Abstand bringen.
3. `automatic_pack_timer_started` abwarten.
4. mindestens 30 Sekunden dauerhaft außerhalb bleiben.
5. sichtbares und protokolliertes Packen prüfen.

Erwartet:

```text
playerInterestBand=OUTSIDE
automatic_pack_timer_started
automatic_pack_requested
convoy_pack_started
convoy_packed
representationState=COLLAPSED_PROXY
halted=false
```

## Test B – Auto-Unpack bei Annäherung

1. Mit eingepacktem Konvoi auf höchstens 500 m horizontal annähern.
2. sichtbares Entpacken beobachten.
3. Ausrichtung und Routenaktivierung prüfen.

Erwartet:

```text
player_relevance_entered
automatic_unpack_requested
convoy_unpack_started
convoy_unpacked
convoy_route_activation_confirmed
representationState=EXPANDED
halted=false
```

## Test C – Timerabbruch

1. Expandierten Konvoi verlassen und `automatic_pack_timer_started` abwarten.
2. nach ungefähr 15–25 Sekunden wieder auf höchstens 750 m annähern.
3. prüfen, dass kein Packen erfolgt.

Erwartet:

```text
automatic_pack_timer_cancelled
```

Nicht erwartet:

```text
automatic_pack_requested
convoy_packed
```

## Test D – Hysterese

1. Konvoi expandiert halten.
2. zwischen 500 und 750 m bleiben oder mehrfach innerhalb dieses Bandes pendeln.
3. prüfen, dass kein Pack-/Unpack-Flattern entsteht.

Erwartet:

```text
playerInterestBand=HYSTERESIS
representationState bleibt EXPANDED
```

Danach mit eingepacktem Proxy denselben Bereich prüfen:

```text
representationState bleibt COLLAPSED_PROXY
```

## Test E – Transition-Schutz

Während `PACKING`, `UNPACKING` oder `ACTIVATING_ROUTE` die Distanzgrenzen überqueren.

Erwartet:

- keine parallele zweite Transition;
- keine doppelten Pack-/Unpack-Anforderungen;
- neue Auswertung erst nach Rückkehr zu `IDLE`.

## Test F – mehrere Spieler

Mit zwei BLUE-Spielern testen:

- ein Spieler außerhalb 750 m;
- ein Spieler innerhalb 500 m.

Erwartet:

- der nähere Spieler bestimmt die Relevanz;
- der Konvoi bleibt beziehungsweise wird expandiert;
- Auto-Pack startet erst, wenn **alle** gültigen BLUE-Spieler außerhalb 750 m sind.

## Test G – Spielerhöhe

Direkt über dem Konvoi in größerer Höhe fliegen, aber horizontal innerhalb 500 m bleiben.

Erwartet:

- Spieler gilt als relevant;
- Distanz ist horizontal;
- kein Auto-Pack aufgrund reiner Flughöhe.

## Fehlerkriterien

Der Lauf ist nicht bestanden bei:

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

## Zu sammelnde Logereignisse

```text
startup
configuration_valid
player_interest_monitor_initialized
player_relevance_band_changed
player_relevance_entered
player_relevance_exited
automatic_pack_timer_started
automatic_pack_timer_cancelled
automatic_pack_requested
automatic_unpack_requested
convoy_pack_started
convoy_packed
convoy_unpack_started
convoy_unpacked
convoy_route_activation_confirmed
player_interest_status
convoy_proxy_status
```
