# TM01C – automatische RED-Gegnerrelevanz

Datum: 17. Juli 2026  
Status: Implementiert; DCS-Laufzeitabnahme ausstehend

## 1. Ziel

Der bereits bestandene automatische BLUE-Spielerrelevanztest wird um eine zweite, deterministische Relevanzquelle ergänzt:

```text
lebende Einheit einer ausdrücklich konfigurierten RED-Testgruppe <= 750 m horizontal
→ Konvoi muss EXPANDED sein
→ bei COLLAPSED_PROXY automatisch entpacken

nächste lebende Einheit aller konfigurierten RED-Testgruppen > 1000 m
UND alle gültigen BLUE-Spieler > 750 m
→ 30 Sekunden kontinuierliche gemeinsame Abwesenheit
→ automatisch einpacken
```

Die neue Logik verwendet einen gemeinsamen Repräsentationsentscheid. Der Konvoi darf nur gepackt werden, wenn **jede aktivierte Relevanzquelle** außerhalb ihrer Pack-Grenze liegt.

## 2. Konfiguration

Konfigurationskennung:

```text
TM01C-automatic-player-and-enemy-interest-6
```

Gemeinsame Transitionseinstellungen:

```text
Pack-Verzögerung: 30 s
Unpack-Retry:       5 s
Distanzmodell:     horizontal / 2D
```

BLUE-Spielerrelevanz:

```text
Unpack: <= 500 m
Pack-freigebend: > 750 m
```

RED-Gegnerrelevanz:

```text
Unpack: <= 750 m
Pack-freigebend: > 1000 m
```

Konfigurierte RED-Testgruppe:

```text
TEST_TM01E_RED_INFANTRY_01
```

Nur lebende Units dieser ausdrücklich benannten Gruppe werden berücksichtigt. Weitere Gruppen können später über `enemyInterest.groupNames` ergänzt werden.

## 3. Semantik

Dieser Test bildet **noch keinen tatsächlichen DCS-Sensor- oder Sichtkontakt** ab.

Er verwendet ausschließlich:

```text
lebende RED-Testunit
+ bekannte Weltposition
+ horizontale Entfernung zum aktuellen Lead-/Proxyfahrzeug
```

Nicht enthalten:

- Sichtlinie;
- Geländeabschattung;
- DCS-Erkennungszustand;
- Waffenreichweite;
- Schuss-/Trefferereignisse;
- `hostile act` oder `hostile intent`;
- Einheitentyp- oder Bedrohungsgewichtung;
- Erinnerung an kürzlich beendeten Feuerkontakt.

Die korrekte Bezeichnung dieses Schritts lautet daher **Gegnernähe-/Enemy-Proximity-Proof-of-Concept**, nicht vollständige Feindkontakterkennung.

## 4. Kombinierte Entscheidungslogik

### Automatisches Unpack

Ein eingepackter Konvoi wird entpackt, wenn mindestens eine aktivierte Quelle `INSIDE_UNPACK` meldet:

```text
PLAYER <= 500 m
ODER
ENEMY <= 750 m
```

Das Ereignis `automatic_unpack_requested` enthält:

```text
triggeredByPlayer=true|false
triggeredByEnemy=true|false
```

### Automatisches Pack

Ein expandierter Konvoi darf den Pack-Timer nur starten, wenn gleichzeitig gilt:

```text
PLAYER > 750 m oder kein gültiger BLUE-Spieler
UND
ENEMY > 1000 m oder keine lebende Unit in den konfigurierten RED-Gruppen
```

Kein einzelner Relevanzkanal darf den anderen überstimmen.

### Hysterese

```text
PLAYER 500–750 m
→ bestehende Repräsentation halten

ENEMY 750–1000 m
→ bestehende Repräsentation halten
```

Liegt irgendeine Quelle in ihrer Hysterese oder innerhalb ihres Unpack-Radius, wird kein Pack-Timer gestartet beziehungsweise ein laufender Timer abgebrochen.

## 5. Architektur

Neues Modul:

```text
mission/tests/tm01-blue-convoy/src/representation_interest_monitor.lua
```

Es ersetzt im Bundle den bisherigen ausschließlich auf BLUE-Spieler fokussierten Monitor. Der alte Quelltext bleibt vorerst als historischer, nicht mehr eingebundener Implementierungsstand erhalten.

Der kombinierte Monitor:

- umschließt weiterhin den vorhandenen `controller.tick()`;
- erzeugt keinen zusätzlichen Hochfrequenz-Scheduler;
- verwendet die existierenden `pack()`- und `unpack()`-Transitionen;
- wertet zuerst BLUE-Spieler und dann konfigurierte RED-Gruppen aus;
- speichert Player- und Enemy-Band im CampaignState;
- trifft genau einen gemeinsamen Repräsentationsentscheid;
- löst nichts während `PACKING`, `UNPACKING` oder `ACTIVATING_ROUTE` aus;
- deaktiviert die Automatik bei einem internen Monitorfehler, ohne den manuellen Controllerkern zu entfernen.

## 6. Datenquelle und Kosten

BLUE:

```lua
coalition.getPlayers(coalition.side.BLUE)
```

RED:

```lua
Group.getByName(configuredGroupName)
group:getUnits()
```

Damit werden nicht alle RED-Gruppen der Mission jede Sekunde durchsucht. Der erste Test prüft genau eine kleine, benannte Gruppe. Die wiederkehrenden Kosten sind entsprechend gering.

## 7. Strukturierte Ereignisse

Neu:

```text
representation_interest_monitor_initialized
enemy_interest_monitor_initialized
enemy_relevance_band_changed
enemy_relevance_entered
enemy_relevance_exited
representation_interest_status
representation_interest_monitor_failed
representation_interest_monitor_initialization_failed
```

Weiterhin verwendet:

```text
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
```

## 8. Testisolation

Unverändert bleiben:

```text
Geschwindigkeit: 30 km/h
Spawnabstand:    15 m
Formation:       ON_ROAD
```

Noch nicht Bestandteil dieses Schritts:

```text
ALARM_STATE = RED
ROE = RETURN_FIRE
DISPERSE_ON_ATTACK = false
```

Diese taktischen Controlleroptionen bleiben ein separater Regressionstest. Dadurch kann ein Fehler eindeutig der neuen Relevanzlogik oder dem späteren Gefechtsverhalten zugeordnet werden.

## 9. Vorabprüfung

Vor dem Commit wurden durchgeführt:

- Syntaxprüfung des neuen Lua-Moduls mit `loadfile()`;
- Mocktest für:
  - kein Unpack bei beiden Quellen außerhalb;
  - Enemy-Unpack innerhalb 750 m;
  - kein Pack solange Enemy nicht außerhalb 1000 m ist;
  - Pack nach 30 s gemeinsamer Abwesenheit;
  - bestehendes Player-Unpack innerhalb 500 m;
  - Hysterese verhindert Pack-Timer;
  - Gegnerwiedereintritt bricht Pack-Timer ab.

Diese Prüfungen ersetzen keine DCS-Laufzeitabnahme.