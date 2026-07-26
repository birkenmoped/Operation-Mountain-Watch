# TM01C – automatische RED-Gegnerrelevanz

Datum: 17. Juli 2026  
Status: **Implementiert; isolierter Enemy-Proximity-Pfad mit Version 8 in DCS bestanden; kombinierter Player-/Enemy-Pfad teilweise abgenommen**

## 1. Ziel

Der bereits bestandene automatische BLUE-Spielerrelevanztest wurde um eine zweite, deterministische Relevanzquelle ergänzt:

```text
lebende Einheit einer ausdrücklich konfigurierten RED-Testgruppe <= 750 m horizontal
→ Konvoi muss EXPANDED sein
→ bei COLLAPSED_PROXY automatisch entpacken

nächste lebende Einheit aller konfigurierten RED-Testgruppen > 1000 m
UND alle gültigen BLUE-Spieler > 750 m
→ 30 Sekunden kontinuierliche gemeinsame Abwesenheit
→ automatisch einpacken
```

Die Logik verwendet einen gemeinsamen Repräsentationsentscheid. Der Konvoi darf nur gepackt werden, wenn **jede aktivierte Relevanzquelle** außerhalb ihrer Pack-Grenze liegt.

## 2. Aktuelle Konfiguration

Konfigurationskennung:

```text
TM01C-automatic-player-and-enemy-interest-8
```

Gemeinsame Transitionseinstellungen:

```text
Pack-Verzögerung: 30 s
Unpack-Retry:       5 s
Distanzmodell:      horizontal / 2D
```

BLUE-Spielerrelevanz:

```text
Unpack:             <= 500 m
Hysterese:          500–750 m
Pack-freigebend:    > 750 m
```

RED-Gegnerrelevanz:

```text
Unpack:             <= 750 m
Hysterese:          750–1000 m
Pack-freigebend:    > 1000 m
```

Konfigurierte RED-Testgruppen:

```text
TEST_TM01E_RED_INFANTRY_01
TEST_TM01E_RED_INFANTRY_02
TEST_TM01E_RED_INFANTRY_03
TEST_TM01E_RED_INFANTRY_04
TEST_TM01E_RED_INFANTRY_05
TEST_TM01E_RED_INFANTRY_06
TEST_TM01E_RED_INFANTRY_07
TEST_TM01E_RED_INFANTRY_08
TEST_TM01E_RED_INFANTRY_09
TEST_TM01E_RED_INFANTRY_10
```

Jede Gruppe enthält im Testaufbau genau eine RED-Infanterieeinheit. Nur lebende Units dieser ausdrücklich benannten Gruppen werden berücksichtigt.

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
- Schuss-/Trefferereignisse als Relevanzquelle;
- `hostile act` oder `hostile intent`;
- Einheitentyp- oder Bedrohungsgewichtung;
- Erinnerung an kürzlich beendeten Feuerkontakt.

Die korrekte Bezeichnung dieses Schritts lautet **Gegnernähe-/Enemy-Proximity-Proof-of-Concept**, nicht vollständige Feindkontakterkennung.

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

Gemeinsamer Monitor:

```text
mission/tests/tm01-blue-convoy/src/representation_interest_monitor.lua
```

Der Monitor:

- umschließt den vorhandenen `controller.tick()`;
- erzeugt keinen zusätzlichen Hochfrequenz-Scheduler;
- verwendet die existierenden `pack()`- und `unpack()`-Transitionen;
- wertet BLUE-Spieler und konfigurierte RED-Gruppen aus;
- speichert Player- und Enemy-Band im CampaignState;
- trifft genau einen gemeinsamen Repräsentationsentscheid;
- löst nichts während `PACKING`, `UNPACKING` oder `ACTIVATING_ROUTE` aus;
- deaktiviert die Automatik bei einem internen Monitorfehler, ohne den manuellen Controllerkern zu entfernen.

## 6. Enemy-spezifische Routenaktivierung

Version 7 zeigte im Live-Fire-Test einen Konstruktionsfehler:

```text
Enemy-Unpack erfolgreich
+ Konvoi bewegt sich im Feuerkampf nur 1,838 m
+ allgemeiner Aktivierungs-Guard verlangt 2 m
→ convoy_route_activation_timeout
→ halted=true
→ Relevanzmonitor stoppt
```

Version 8 ergänzt deshalb eine eng begrenzte Policy:

```text
Enemy-triggered unpack
+ Routenzuweisung erfolgreich
+ Runtime-Gruppe lebt
+ Schadenszustand bestätigt
→ Aktivierung darf ohne physischen Bewegungsnachweis bestätigt werden
```

Konfiguration:

```lua
allowStationaryEnemyTriggeredUnpack = true
```

Implementierung:

```text
mission/tests/tm01-blue-convoy/src/convoy_proxy_controller/
03e-enemy-contact-activation-policy.lua
```

Diagnoseereignis:

```text
convoy_route_activation_policy_adjusted
confirmationPolicy=ROUTE_ASSIGNED_DAMAGE_VERIFIED_ENEMY_RELEVANCE
movementRequired=false
automaticEnemyInterest=true
```

Die Ausnahme gilt nur bei `automaticEnemyInterest=true`. Initialspawn, manuelles Unpack und ausschließlich spielerausgelöstes Unpack behalten den normalen 2-m-Bewegungsnachweis.

## 7. Datenquellen und Kosten

BLUE:

```lua
coalition.getPlayers(coalition.side.BLUE)
```

RED:

```lua
Group.getByName(configuredGroupName)
group:getUnits()
```

Es werden nicht alle RED-Gruppen der Mission durchsucht. Pro Monitor-Tick werden ausschließlich die zehn explizit konfigurierten kleinen Testgruppen geprüft. Die wiederkehrenden Kosten sind entsprechend begrenzt und deterministisch.

## 8. Strukturierte Ereignisse

```text
representation_interest_monitor_initialized
player_interest_monitor_initialized
enemy_interest_monitor_initialized
player_relevance_band_changed
player_relevance_entered
player_relevance_exited
enemy_relevance_band_changed
enemy_relevance_entered
enemy_relevance_exited
automatic_pack_timer_started
automatic_pack_timer_cancelled
automatic_pack_requested
automatic_unpack_requested
convoy_pack_started
convoy_packed
convoy_unpack_started
convoy_unpacked
convoy_route_activation_policy_adjusted
convoy_route_activation_confirmed
representation_interest_status
representation_interest_monitor_failed
representation_interest_monitor_initialization_failed
```

## 9. DCS-Laufzeitstatus

Ergebnisbericht:

```text
mission/tests/tm01-blue-convoy/results/
2026-07-17-tm01c-enemy-proximity-regression-pass.md
```

Version-8-Lauf:

```text
7 gegnerausgelöste automatische Unpacks
7 enemy-spezifische Aktivierungspolicy-Anpassungen
8 bestätigte Routenaktivierungen einschließlich Initialspawn
8 erfolgreiche Packvorgänge
1 Enemy-Hysterese-Timerabbruch
0 TM01C-ERROR-Ereignisse im Version-8-Segment
0 convoy_route_activation_timeout
0 halted=true
0 movementState=FAILED
```

Der BLUE-Spieler blieb während der sieben Enemy-Unpacks ungefähr 3,08–15,79 km entfernt. Alle sieben Unpack-Anforderungen enthielten:

```text
triggeredByEnemy=true
triggeredByPlayer=false
```

Damit gilt:

```text
Automatic RED enemy-proximity regression: PASS
Combined player-and-enemy relevance monitor: PARTIAL PASS
Automatic BLUE player path under version 8: NOT YET RETESTED
```

## 10. Testisolation

Unverändert:

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

Diese taktischen Controlleroptionen bleiben ein separater Regressionstest.

## 11. Noch offene kombinierte Regressionen

```text
Player-only unpack <= 500 m unter Version 8
Player-only pack nach > 750 m für 30 s
Player-Hysterese 500–750 m
Pack-Timer-Abbruch durch Rückkehr des Spielers
Player bleibt relevant, Enemy fällt weg
Enemy bleibt relevant, Player fällt weg
Player und Enemy gleichzeitig relevant
expliziter Höhentest
mehrere gleichzeitige BLUE-Spieler
Produktionsradien
```

Der frühere BLUE-Einzelspielerlauf mit Version 5 bleibt ein gültiger separater Nachweis, ersetzt aber nicht die Regression des BLUE-Pfads in Version 8.
