# TM01C – Layout für zehn einzelne RED-Infanterieposten

Datum: 17. Juli 2026  
Status: Mission-Editor-Aufbau für DCS-Laufzeittest

## Ziel

Entlang der Konvoiroute werden zehn einzelne RED-Infanteristen verteilt, damit der Konvoi wiederholt zwischen `COLLAPSED_PROXY` und `EXPANDED` wechseln kann.

Jeder Infanterist muss als **eigene DCS-Ground-Group mit genau einer Unit** angelegt werden. Eine einzelne Gruppe mit zehn weit auseinandergezogenen Units ist für diesen Test ungeeignet, weil DCS die Formation beziehungsweise Gruppenbewegung zusammenhängend behandeln kann.

## Erforderliche Gruppennamen

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

Die Unit-Namen innerhalb dieser Gruppen sind frei wählbar. Maßgeblich ist ausschließlich der Gruppenname.

## Aktive Relevanzwerte

```text
Enemy-Unpack-Radius:   <= 750 m horizontal
Enemy-Pack-Grenze:     > 1000 m horizontal
Gemeinsame Pack-Zeit:  30 s
Konvoigeschwindigkeit: 30 km/h
```

Bei 30 km/h fährt der Konvoi in 30 Sekunden ungefähr 250 m.

## Mindestabstand für einen vollständigen Pack-/Unpack-Zyklus

Damit der Konvoi nach einem Posten vollständig packen kann, bevor der nächste Posten den Unpack-Radius erreicht, muss ungefähr gelten:

```text
1000 m  Abstand hinter dem vorherigen Gegner bis zur Pack-Freigabe
+ 250 m Fahrstrecke während der 30-s-Pack-Verzögerung
+ 750 m Abstand bis zum Unpack-Radius des nächsten Gegners
= 2000 m theoretischer Mindestabstand
```

Wegen Kurven, seitlichem Versatz, AI-Geschwindigkeitsschwankungen, Scheduler-Takt und Übergangszeit wird für den Test empfohlen:

```text
empfohlen: 2200–3000 m zwischen aufeinanderfolgenden Infanterieposten
```

Unter ungefähr 2000 m kann der Konvoi durchgehend expandiert bleiben oder erst unmittelbar vor dem nächsten Gegner packen. Das wäre kein Fehler des Monitors, sondern eine Folge überlappender Relevanzbereiche.

## Seitlicher Abstand zur Route

Empfohlen:

```text
30–100 m seitlich der Fahrbahn
```

Die Units sollten nicht direkt auf der Straße stehen, da sie sonst den Konvoi blockieren oder das Fahrverhalten verfälschen können. Der horizontale Seitenabstand zählt zur gemessenen Entfernung; bei 50–100 m seitlichem Abstand bleibt der Einfluss auf die 750-/1000-m-Schwellen gering.

## Erster Testlauf

Für die reine Repräsentationsprüfung:

```text
jede RED-Gruppe: eine Unit
ROE: WEAPON HOLD
keine späte Aktivierung
keine Route oder Bewegung
keine Gruppenzusammenführung
```

Der BLUE-Beobachter muss horizontal mehr als 750 m vom Konvoi entfernt bleiben, damit nicht die Spielerrelevanz das Packen verhindert.

Erwartete wiederholte Sequenz:

```text
Enemy <= 750 m
→ automatic_unpack_requested
→ convoy_unpacked

Enemy > 1000 m und BLUE > 750 m
→ automatic_pack_timer_started
→ nach 30 s convoy_packed

nächster Enemy <= 750 m
→ erneutes automatic_unpack_requested
```

## Diagnose

`Show status` muss bei korrekt aufgelösten Gruppen unter anderem zeigen beziehungsweise loggen:

```text
configuredEnemyGroupCount=10
resolvedEnemyGroupCount=10
aliveEnemyUnitCount=10
```

Nach Verlust einzelner Infanteristen sinkt `aliveEnemyUnitCount`. Tote Units oder Wracks dürfen die Repräsentation nicht relevant halten.

## Aktuelle Konfiguration

```text
TM01C-automatic-player-and-enemy-interest-7
```

Die zehn Gruppennamen sind in `config-tm01c.lua` explizit hinterlegt. Der Monitor durchsucht nicht pauschal die gesamte RED-Koalition, sondern nur diese zehn kleinen Testgruppen.
