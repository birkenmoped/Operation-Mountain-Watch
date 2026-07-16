# TM01C – automatische BLUE-Spielerrelevanz für Pack/Unpack

Datum: 17. Juli 2026  
Status: Implementierungs- und Teststand; DCS-Abnahme ausstehend

## 1. Ziel

Der bewährte manuelle Proxy-Pack-/Unpack-Kern wird um einen isolierten visuellen Nahbereichstest ergänzt:

```text
BLUE-Spieler nähert sich dem Proxy auf höchstens 500 m horizontal
→ automatisch entpacken

alle gültigen BLUE-Spieler sind weiter als 750 m entfernt
→ 30 Sekunden kontinuierliche Abwesenheit
→ automatisch einpacken
```

Dieser Test bewertet ausschließlich die automatische Repräsentationsumschaltung. Er ist noch keine operative Sicht-, Sensor-, Feind- oder Bedrohungslogik.

## 2. Konfiguration

Konfigurationskennung:

```text
TM01C-automatic-player-interest-5
```

Verbindliche Werte:

```text
Unpack-Radius:    500 m
Pack-Grenze:      750 m
Pack-Verzögerung: 30 s
Unpack-Retry:       5 s
Distanzmodell:     horizontal / 2D
Koalition:         BLUE
```

Höhe wird ignoriert. Der Relevanzraum entspricht einem vertikalen Zylinder um die aktuelle Lead-/Proxyposition.

Unverändert:

```text
Geschwindigkeit: 30 km/h
Spawnabstand:    15 m
Formation:       ON_ROAD
```

## 3. Spielerdefinition

Datenquelle:

```lua
coalition.getPlayers(coalition.side.BLUE)
```

Als gültig zählt nur eine Einheit mit:

- existierender Unit;
- `life > 0`;
- nichtleerem `getPlayerName()`;
- gültiger Weltposition.

Damit zählen keine Zuschauer, unbesetzten Client-Slots oder normalen AI-Einheiten. Bei mehreren Spielern ist die kleinste horizontale Distanz maßgeblich.

## 4. Hysterese

```text
Distanz <= 500 m
→ Band INSIDE_UNPACK

500 m < Distanz <= 750 m
→ Band HYSTERESIS

Distanz > 750 m oder kein gültiger BLUE-Spieler
→ Band OUTSIDE
```

Regeln:

- `COLLAPSED_PROXY + INSIDE_UNPACK` fordert genau ein Unpack an;
- fehlgeschlagene, nicht haltende Unpack-Versuche werden frühestens nach fünf Sekunden wiederholt;
- `EXPANDED + OUTSIDE` startet den 30-Sekunden-Timer;
- jeder Wiedereintritt auf höchstens 750 m bricht den Timer ab;
- in der Hysteresezone wird der bestehende Repräsentationszustand beibehalten.

## 5. Transition-Schutz

Die Spielerrelevanz löst keine neue Aktion aus während:

```text
PACKING
UNPACKING
ACTIVATING_ROUTE
```

Der Monitor umschließt den bereits vorhandenen `controller.tick()` und verwendet damit **keinen zusätzlichen Hochfrequenz-Scheduler**. Zuerst läuft die bestehende Konvoiüberwachung einschließlich Zielankunft und Transitionen; anschließend wird nur bei weiterhin gültigem, ruhendem Zustand die Spielerrelevanz ausgewertet.

## 6. Architektur

Neues Modul:

```text
mission/tests/tm01-blue-convoy/src/player_interest_monitor.lua
```

Das Modul wird nach erfolgreichem TM01C-Bootstrap an den Controller angehängt. Es:

- validiert Konfiguration und native Spieler-API;
- umschließt `controller.tick()`;
- umschließt `controller.showStatus()`;
- verwendet die bestehende `pack()`- und `unpack()`-Logik unverändert;
- speichert Band und Pack-Timer im CampaignState;
- hält den manuellen Kern bei einem reinen Monitor-Laufzeitfehler weiter verfügbar, deaktiviert aber die Automatik und protokolliert den Fehler.

## 7. Strukturierte Ereignisse

```text
player_interest_monitor_initialized
player_relevance_band_changed
player_relevance_entered
player_relevance_exited
automatic_pack_timer_started
automatic_pack_timer_cancelled
automatic_pack_requested
automatic_pack_request_failed
automatic_unpack_requested
automatic_unpack_request_failed
player_interest_status
player_interest_monitor_failed
```

Alle Ereignisse enthalten nach Möglichkeit:

- Repräsentations- und Transitionzustand;
- nächste Spielerdistanz;
- Spielername und Unitname;
- Zahl beobachteter und gültiger BLUE-Spieler;
- aktive Radien und Verzögerung;
- Runtime-Generation und Gruppenname.

## 8. F10-Verhalten

Die bisherigen Befehle bleiben erhalten:

```text
Start convoy
Pack convoy
Unpack convoy
Show status
Validate configuration
```

`Show status` gibt zusätzlich aus:

- aktuelles Relevanzband;
- nächsten BLUE-Spieler;
- horizontale Distanz;
- verbleibende Auto-Pack-Zeit;
- Monitorfehler, falls vorhanden.

Manuelle Befehle deaktivieren die Automatik nicht dauerhaft. Ein manuell erzeugter Zustand kann daher beim nächsten gültigen Relevanzentscheid wieder automatisch korrigiert werden.

## 9. Nicht Bestandteil

- Sichtlinie und Geländeabschattung;
- optische Erkennbarkeit;
- Sensor- oder Waffenreichweite;
- RED-Spieler und Feind-AI;
- Bedrohungsbewertung;
- Stadt-/Dorfprofile;
- dynamische Geschwindigkeit oder Formation Interval;
- Persistenz über Missionsneustart;
- Recovery, Unstuck oder Teleport.

## 10. Abnahmestatus

```text
Quellcode/Syntax:    vor Commit lokal geprüft
Bundle-Build:        durch Nutzer lokal auszuführen
DCS-Laufzeitabnahme: ausstehend
Merge-Freigabe:      nicht erteilt
```
