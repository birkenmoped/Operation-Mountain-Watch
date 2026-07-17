# TM01C – aktueller Status der Relevanztests

Datum: 17. Juli 2026  
Aktuelle Konfiguration: `TM01C-automatic-player-and-enemy-interest-8`

## Statusmatrix

```text
Manueller Proxy-Kern:                          PASS
Automatische BLUE-Spielerrelevanz Version 5:  PASS
Automatische RED-Gegnernähe Version 8:        PASS
Kombinierter Player-/Enemy-Monitor Version 8: PARTIAL PASS
```

## Was Version 8 im DCS-Lauf nachgewiesen hat

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

Der BLUE-Spieler lag während aller sieben Enemy-Unpacks ungefähr 3,08–15,79 km entfernt. Alle Anforderungen enthielten:

```text
triggeredByEnemy=true
triggeredByPlayer=false
```

Der Lauf beweist daher den isolierten Enemy-Proximity-Pfad, nicht den Player-Pfad der kombinierten Version 8.

## Offene Version-8-Regressionen

```text
Player-only unpack <= 500 m
Player-only pack nach > 750 m für 30 s
Player-Hysterese 500–750 m
Pack-Timer-Abbruch durch Rückkehr des Spielers
Player relevant, Enemy fällt weg
Enemy relevant, Player fällt weg
Player und Enemy gleichzeitig relevant
Höhenfall bei kleinem horizontalem Abstand
mehrere gleichzeitige BLUE-Spieler
```

## Autoritative Berichte

```text
results/2026-07-17-tm01c-automatic-player-interest-pass.md
results/2026-07-17-enemy-unpack-route-activation-timeout.md
results/2026-07-17-tm01c-enemy-proximity-regression-pass.md
expected/automatic-enemy-interest-acceptance.md
```

PR #8 bleibt Draft und ungemergt. Der aktuelle Stand erteilt keine Merge-Freigabe.
