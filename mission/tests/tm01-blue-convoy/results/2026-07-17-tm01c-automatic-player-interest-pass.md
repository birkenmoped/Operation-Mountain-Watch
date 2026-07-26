# TM01C – DCS-Ergebnis: automatische BLUE-Spielerrelevanz bestanden

Datum: 17. Juli 2026  
Status: **PASS für den visuellen Einzelspieler-Nahbereichstest**  
Konfiguration: `TM01C-automatic-player-interest-5`

## 1. Zweck

Dieser Lauf prüfte die automatische Umschaltung desselben strategischen BLUE-Konvois zwischen:

```text
EXPANDED
= alle überlebenden Fahrzeuge physisch

COLLAPSED_PROXY
= nur das aktuelle Führungs-/Proxyfahrzeug physisch
```

Relevanzmodell:

```text
BLUE-Spieler <= 500 m horizontal
→ automatisch entpacken

alle gültigen BLUE-Spieler > 750 m horizontal
→ 30 s kontinuierliche Abwesenheit
→ automatisch einpacken

500–750 m
→ Hysterese; Zustand beibehalten
```

Es wurde keine Sichtlinie, Sensorreichweite, Gegnerrelevanz oder Flughöhenabhängigkeit verwendet.

## 2. Testumgebung

```text
DCS:                 2.9.27.25340 Open Beta MT
Terrain:             Afghanistan
MOOSE:               2.9.18
MOOSE-Commit:        73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Entity:              TEST.TM01.CONVOY.001
Route:               ROUTE_TM01_BAGRAM_JALALABAD
Spielerunit:         OH-58D
Spielername im Log:  Neues Rufz.
```

Startup-Nachweis:

```text
event=startup
configurationVersion=TM01C-automatic-player-interest-5

event=configuration_valid
checkedObjectCount=10
expectedVehicleCount=6

event=bootstrap_outcome
outcome=READY

event=player_interest_monitor_initialized
coalition=BLUE
distanceModel=HORIZONTAL_2D
unpackRadiusMeters=500
packRadiusMeters=750
packDelaySeconds=30
schedulerModel=WRAPPED_EXISTING_CONVOY_TICK
```

## 3. Zusammenfassung der beobachteten Ereignisse

```text
automatic_pack_timer_started:       6
automatic_pack_timer_cancelled:     1
automatic_pack_requested:           5
convoy_pack_started:                5
convoy_packed:                      5

automatic_unpack_requested:         3
convoy_unpack_started:              4
convoy_unpacked:                    4

convoy_route_activation_confirmed:  5
player_relevance_entered:           4
player_relevance_exited:            4
player_relevance_band_changed:     17

convoy_losses_observed:              3
convoy_damage_restore_confirmed:     5
```

Die Differenz zwischen drei automatischen Unpack-Anforderungen und vier Unpack-Vorgängen entstand durch einen zusätzlichen manuellen Diagnose-Unpack. Die automatische Logik selbst erzeugte keine doppelte Anforderung.

## 4. Nachgewiesene Testfälle

### 4.1 Initialisierung und erste Bewegung – PASS

Der Konvoi startete mit sechs Fahrzeugen. Die initiale Routenaktivierung wurde nach realer Bewegung bestätigt:

```text
runtimeGeneration=1
liveRuntimeUnitCount=6
movementState=EN_ROUTE
transitionState=IDLE
halted=false
```

### 4.2 Auto-Pack nach 30 Sekunden außerhalb 750 m – PASS

Erster vollständiger Zyklus:

```text
13:07:37  distance=1383.61 m
            automatic_pack_timer_started

13:08:08  timerElapsedSeconds=30
            automatic_pack_requested
            convoy_pack_started

13:08:08  convoy_packed
            representationState=COLLAPSED_PROXY
```

Weitere vollständige Auto-Pack-Zyklen erfolgten ebenfalls nach exakt 30 Sekunden bei ungefähr:

```text
971.71 m
1003.66 m
1432.25 m
1008.25 m
```

Alle fünf Anforderungen führten zu genau fünf gestarteten und fünf bestätigten Pack-Vorgängen.

### 4.3 Auto-Unpack innerhalb 500 m – PASS

Drei automatische Annäherungen lösten bei folgenden Entfernungen genau einen Unpack-Vorgang aus:

```text
486.53 m
485.89 m
491.63 m
```

Jeder automatische Unpack durchlief:

```text
automatic_unpack_requested
convoy_unpack_started
convoy_unpacked
convoy_route_activation_task_issued
convoy_route_activation_confirmed
```

Alle neu erzeugten Gruppen kehrten nach bestätigter physischer Bewegung in folgenden Zustand zurück:

```text
representationState=EXPANDED
transitionState=IDLE
movementState=EN_ROUTE
pendingRouteActivation=false
halted=false
```

Die visuelle Nutzerbeobachtung bestätigte zusätzlich korrekt ausgerichtete Fahrzeuge und ein störungsfreies Weiterfahren.

### 4.4 Pack-Timer-Abbruch – PASS

Ein gestarteter Timer wurde nach 27 Sekunden beim Wiedereintritt auf 743.67 m korrekt abgebrochen:

```text
automatic_pack_timer_started
...
automatic_pack_timer_cancelled
timerElapsedSeconds=27
reason=player returned inside pack boundary
```

Danach erfolgte kein Pack-Vorgang aus diesem Timer.

### 4.5 Hysterese – PASS

Der Log zeigt wiederholte Übergänge durch das Band `HYSTERESIS` bei Entfernungen zwischen 500 und 750 m. Beispiele:

```text
728.56 m  COLLAPSED_PROXY bleibt bestehen
511.33 m  EXPANDED bleibt bestehen
743.67 m  EXPANDED bleibt bestehen und Timer wird abgebrochen
700.83 m  EXPANDED bleibt bestehen
592.65 m  EXPANDED bleibt bestehen
```

Es trat kein Pack-/Unpack-Flattern auf.

### 4.6 Verlust- und Survivor-Persistenz während Automatik – PASS

Während Runtime-Generation 3 wurden drei Verluste erkannt:

```text
6,5,4,3,2,1
→ 6,5,4,2,1
→ 6,5,2,1
→ 5,2,1
```

Die reduzierte Gruppe `5,2,1` blieb anschließend über weitere Pack-/Unpack-Zyklen erhalten. Zerstörte Stable Slots wurden nicht wiederhergestellt.

### 4.7 Teilschaden durch Repräsentationswechsel – PASS im Log

Für die überlebenden Slots wurde gespeichert:

```text
5:98.93
2:98.73
1:100.00
```

Nach dem späteren Unpack wurden zwei beschädigte Fahrzeuge wiederhergestellt und verifiziert:

```text
convoy_damage_restore_applied
restoredVehicleCount=2

convoy_damage_restore_confirmed
verifiedDamagedVehicleCount=2
```

Damit blieb der Domain-Schadenszustand auch zusammen mit der Spielerrelevanzautomatik erhalten.

## 5. Fehlerprüfung

Im gesamten TM01C-Ereignisstrom trat nicht auf:

```text
level=ERROR
player_interest_monitor_failed
player_interest_monitor_initialization_failed
proxy_controller_initialization_failed
convoy_route_activation_timeout
convoy_route_activation_failed
convoy_pack_failed
convoy_unpack_failed_proxy_restored
movementState=FAILED
halted=true
```

Ein einzelnes Ereignis war erwartbar und harmlos:

```text
convoy_proxy_command_rejected
action=Start convoy
reason=convoy has already been started
```

Dies war ein erneuter manueller Startversuch und kein Laufzeitfehler.

## 6. Abnahmeentscheidung

```text
Automatisches Packen nach 30 s:       PASS
Automatisches Unpack bei <= 500 m:    PASS
Hysterese 500–750 m:                  PASS
Timerabbruch bei Rückkehr:            PASS
Transitionen ohne Doppelanforderung:  PASS im beobachteten Lauf
Wiederanlauf nach Unpack:              PASS
Survivor-Persistenz:                   PASS
Schadenspersistenz:                    PASS im strukturierten Log
Controller stabil / nicht halted:      PASS
```

Der **visuelle Einzelspieler-Nahbereichstest ist bestanden**.

## 7. Noch offene erweiterte Abnahmen

Diese Punkte wurden durch diesen Lauf nicht vollständig bewiesen und bleiben getrennt offen:

```text
- zwei oder mehr gleichzeitige BLUE-Spieler;
- expliziter Höhentest direkt über dem Konvoi;
- absichtliches Grenzüberqueren während PACKING;
- absichtliches Grenzüberqueren während UNPACKING;
- absichtliches Grenzüberqueren während ACTIVATING_ROUTE;
- operative Produktionsradien;
- Sichtlinie, Sensorik und Gegnerrelevanz.
```

Diese offenen Punkte ändern nicht das PASS-Ergebnis des vereinbarten visuellen Einzelspieler-Proof-of-Concepts.

## 8. Designfolgerung

Das gewählte Kostenmodell hat sich bewährt:

```text
- kein zusätzlicher Hochfrequenz-Scheduler;
- Spielerrelevanz im bestehenden Konvoi-Tick;
- reine horizontale Distanzprüfung;
- Hysterese statt einer einzelnen Schaltschwelle;
- CampaignState bleibt Autorität;
- vorhandene Pack-/Unpack-Transitionen unverändert wiederverwendet;
- keine Recovery-, Teleport-, Unstuck- oder Dauer-Re-Routing-Logik.
```

Der nächste Entwicklungsschritt kann auf dieser stabilen Automatikgrundlage aufbauen.