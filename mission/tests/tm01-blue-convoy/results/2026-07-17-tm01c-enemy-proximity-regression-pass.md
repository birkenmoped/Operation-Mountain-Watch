# TM01C – Enemy-Proximity-Regression Version 8

Datum: 17. Juli 2026  
DCS: 2.9.27.25340 Open Beta MT  
Konfiguration: `TM01C-automatic-player-and-enemy-interest-8`  
Ergebnis: **PASS für den isolierten RED-Enemy-Proximity-Pfad; PARTIAL PASS für den kombinierten Player-/Enemy-Monitor**

## 1. Testumfang

Dieser Lauf prüfte ausschließlich die deterministische RED-Gegnernähe entlang der Konvoiroute.

Der BLUE-Spieler blieb während aller gegnerausgelösten Entpackvorgänge außerhalb der Player-Pack-Grenze. Die gemessenen Spielerentfernungen lagen ungefähr zwischen 3,08 km und 15,79 km.

Damit gilt für diesen Lauf:

```text
triggeredByEnemy=true
triggeredByPlayer=false
```

Nicht Gegenstand dieses Laufs waren Player-only-Unpack, Player-only-Pack, Player-Hysterese, Spieler-Timerabbruch und kombinierte Prioritätsfälle mit gleichzeitig relevantem Spieler und Gegner.

## 2. Ergebnisübersicht

```text
Enemy-triggered automatic unpack requests:      7
Enemy-specific activation-policy adjustments:   7
Route activations confirmed:                    8
Successful pack transitions:                    8
Enemy-triggered pack-timer cancellations:       1
TM01C ERROR events in Version-8 segment:         0
convoy_route_activation_timeout:                 0
halted=true:                                     0
movementState=FAILED:                            0
```

Die acht bestätigten Routenaktivierungen umfassen den Initialspawn und sieben gegnerausgelöste Unpack-Spawns.

Die acht Packvorgänge umfassen das anfängliche Packen sowie die Repacks nach den isolierten Gegnerrelevanzfenstern.

## 3. Bestätigte Enemy-Unpack-Zyklen

Automatische Enemy-Unpacks wurden für folgende Posten protokolliert:

```text
TEST_TM01E_RED_INFANTRY_01
TEST_TM01E_RED_INFANTRY_02
TEST_TM01E_RED_INFANTRY_03
TEST_TM01E_RED_INFANTRY_04
TEST_TM01E_RED_INFANTRY_08
TEST_TM01E_RED_INFANTRY_09
TEST_TM01E_RED_INFANTRY_10
```

Jeder dieser Vorgänge enthielt:

```text
automatic_unpack_requested
triggeredByEnemy=true
triggeredByPlayer=false

convoy_route_activation_policy_adjusted
confirmationPolicy=ROUTE_ASSIGNED_DAMAGE_VERIFIED_ENEMY_RELEVANCE
movementRequired=false

convoy_route_activation_confirmed
movementRequired=false
movementState=EN_ROUTE
```

Damit ist die Korrektur des Version-7-Fehlers bestätigt: Ein im unmittelbaren Feuerkontakt stehender Konvoi wird nach einem gegnerausgelösten Unpack nicht mehr wegen fehlender physischer Bewegung angehalten.

## 4. Enemy-Hysterese und Timerabbruch

Ein laufender Pack-Timer wurde korrekt abgebrochen, als `TEST_TM01E_RED_INFANTRY_06` wieder in die Enemy-Hysterese eintrat:

```text
nearestEnemyDistanceMeters=995.212
newBand=HYSTERESIS
automatic_pack_timer_cancelled
timerElapsedSeconds=24
reason=player or enemy remains inside pack boundary
```

Der BLUE-Spieler war zu diesem Zeitpunkt ungefähr 10,47 km entfernt und `playerInterestBand=OUTSIDE`. Der Timerabbruch wurde damit eindeutig durch die Enemy-Relevanz ausgelöst.

## 5. Auto-Pack nach Enemy-Abwesenheit

Nach dem Verlassen beziehungsweise Ausschalten eines relevanten Postens wechselte die Enemy-Relevanz auf `OUTSIDE`. Bei ebenfalls außerhalb liegendem BLUE-Spieler startete der gemeinsame 30-Sekunden-Timer.

Bestätigte Sequenz:

```text
enemy_relevance_exited
enemyInterestBand=OUTSIDE
playerInterestBand=OUTSIDE
automatic_pack_timer_started
...
automatic_pack_requested
timerElapsedSeconds=30
convoy_pack_started
convoy_packed
representationState=COLLAPSED_PROXY
```

Der letzte dokumentierte Packvorgang erfolgte nach dem Kontakt mit Posten 10 und endete ohne Controllerfehler.

## 6. Schadenszustand

Während der wiederholten Enemy-Zyklen wurden Teilschäden erfasst, nach Unpack wieder angewendet und bestätigt.

Im letzten dokumentierten Zyklus wurden zwei beschädigte Fahrzeuge wiederhergestellt und verifiziert. Der abschließende Packvorgang speicherte unter anderem:

```text
slot 3: 99.74 %
slot 1: 84.50 %
```

Es wurden keine zerstörten Stable Slots wiederhergestellt.

## 7. Abnahmestatus

```text
Enemy forced unpack <= 750 m:                         PASS
Enemy hold / no pack while <= 1000 m:                 PASS
Stationary enemy-unpack activation policy:            PASS
Enemy hysteresis 750–1000 m:                          PASS
Enemy-triggered pack-timer cancellation:              PASS
Auto-pack after 30 s common absence:                  PASS
Repeated enemy pack/unpack cycles:                     PASS
Controller remains serviceable after combat unpack:   PASS
Damage capture/restore through enemy cycles:           PASS
```

## 8. Nicht durch diesen Lauf nachgewiesen

```text
Player-only unpack <= 500 m with version 8
Player-only pack after > 750 m for 30 s
Player hysteresis 500–750 m
Pack-timer cancellation by player return
Simultaneously relevant player and enemy
Enemy leaves while player remains relevant
Player leaves while enemy remains relevant
Altitude-only player relevance
Multiple simultaneous BLUE players
Production relevance radii
LOS, sensor detection or hostile-intent semantics
```

Der frühere automatische BLUE-Einzelspielertest bleibt als eigener Version-5-Nachweis gültig. Er ersetzt jedoch keinen Regressionstest des BLUE-Pfads innerhalb der kombinierten Version-8-Konfiguration.

## 9. Gesamtbewertung

```text
Automatic RED enemy-proximity regression: PASS
Combined player-and-enemy relevance monitor: PARTIAL PASS
Automatic BLUE player path under version 8: NOT YET RETESTED
```

PR #8 bleibt Draft und ungemergt. Dieser Lauf erteilt keine Merge-Freigabe.
