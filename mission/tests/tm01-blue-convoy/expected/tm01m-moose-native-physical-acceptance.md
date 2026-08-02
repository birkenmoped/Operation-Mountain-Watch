# TM01M – Fünf gleichzeitige MOOSE-native MSR-Konvois: DCS-Abnahme

Status: `frühere 50-km/h-Fünf-Konvoi-Baseline PASS`; `gemeinsame Logistikknoten + STANDARD_07 + Zielbereichsbereinigung AUSSTEHEND`

## 1. Historisch bestätigte Baseline

Der DCS-Lauf vom 26. Juli 2026 bestätigte die frühere Konfiguration `TM01M-moose-native-five-convoys-1` mit fünf Gruppen, sechs Fahrzeugen je Gruppe und 30 Fahrzeugen insgesamt. Dieser Ergebnisbericht bleibt unverändert als Nachweis des exakt damaligen Stands:

```text
mission/tests/tm01-blue-convoy/results/2026-07-26-tm01m-five-convoy-50kph-pass.md
```

Die frühere HMMWV-basierte Vorlage ist keine aktuelle Missionsvorgabe mehr.

## 2. Aktuelles Folgeinkrement

```text
TM01M-moose-native-five-convoys-5
```

Das aktuelle Inkrement kombiniert:

1. sechs gemeinsame `OMW_LOG_NODE_*`-Standortknoten;
2. die neue sieben Fahrzeuge umfassende Standardvorlage `TPL_BLUE_CONVOY_STANDARD_07`;
3. fünf gleichzeitige Konvois mit insgesamt 35 Fahrzeugen;
4. 50 km/h und Formation `On Road`;
5. stille Entfernung vollständig angekommener Gruppen nach 60 Sekunden über MOOSE `GROUP:Destroy(false, 60)`.

Die zusätzliche Vorlage `TPL_BLUE_CONVOY_LIGHT_06` gehört bereits zur Vorlagenbibliothek, wird in Version 5 aber noch nicht zufällig ausgewählt. Die unterschiedliche Fahrzeugzahl beider Varianten erfordert ein separates Folgeinkrement und eine eigene DCS-Abnahme für MOOSE `SPAWN:InitRandomizeTemplate()`.

## 3. Verbindliche Mission-Editor-Vorlagen

### Aktive Vorlage

```text
TPL_BLUE_CONVOY_STANDARD_07
Late Activation: aktiv
7 Fahrzeuge
```

| Position | Fahrzeug | Funktion |
|---:|---|---|
| 1 | M-ATV | Lead Security |
| 2 | M1083 | Cargo 1 |
| 3 | MaxxPro | Convoy Commander / C2 |
| 4 | M1083 | Cargo 2 |
| 5 | MaxxPro | Mid-column Security / Support |
| 6 | M1083 | Cargo 3 |
| 7 | M-ATV | Rear Security |

### Vorbereitete Light-Variante

```text
TPL_BLUE_CONVOY_LIGHT_06
Late Activation: aktiv
6 Fahrzeuge
```

| Position | Fahrzeug | Funktion |
|---:|---|---|
| 1 | M-ATV | Lead Security |
| 2 | M1083 | Cargo 1 |
| 3 | MaxxPro | Convoy Commander / C2 |
| 4 | M1083 | Cargo 2 |
| 5 | MaxxPro | Support / Security |
| 6 | M-ATV | Rear Security |

### Zu entfernende Altvorlage

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
```

Sie darf in der aktuellen Mission nicht mehr als aktive oder versteckte Template-Gruppe verbleiben. Historische `.miz`-Dateien und Ergebnisberichte dürfen sie ausschließlich als alten Teststand enthalten.

## 4. Standortknoten und Routen

```text
OMW_LOG_NODE_BAGRAM
→ MSR_EAST_E03
→ OMW_LOG_NODE_KABUL

OMW_LOG_NODE_KABUL
→ MSR_EAST_E02
→ OMW_LOG_NODE_JALALABAD

OMW_LOG_NODE_TORKHAM
→ MSR_EAST_E01
→ OMW_LOG_NODE_JALALABAD

OMW_LOG_NODE_JALALABAD
→ MSR_KUNAR_K01
→ OMW_LOG_NODE_ASADABAD

OMW_LOG_NODE_ASADABAD
→ MSR_CAL_C01
→ MSR_CAL_C02
→ OMW_LOG_NODE_BOSTICK
```

Kabul, Jalalabad und Asadabad werden bewusst als gemeinsamer Start- und Zielknoten verwendet. Die sechs internen PATHLINE-Namen bleiben unverändert.

## 5. Vorbereitung und Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git fetch origin
git switch feature/tm01m-moose-native-baseline
git pull --ff-only origin feature/tm01m-moose-native-baseline

git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-tm01m-bundle.ps1"
```

Danach im Mission Editor:

1. beide neuen `TPL_BLUE_CONVOY_*`-Gruppen auf `Late Activation` prüfen;
2. `TPL_TEST_BLUE_CONVOY_STANDARD_01` löschen;
3. das neu gebaute `mission/tests/tm01-blue-convoy/dist/TM01M.lua` erneut im `DO SCRIPT FILE` auswählen;
4. sicherstellen, dass `Moose.lua` zuerst geladen wird;
5. Mission unter neuem Testnamen speichern.

## 6. Erwarteter Bootstrap

```text
event=bootstrap_outcome
outcome=READY

event=startup
configurationVersion=TM01M-moose-native-five-convoys-5
convoyCount=5
msrPathlineCount=6
speedKph=50
formation=On Road
arrivalDespawnDelaySeconds=60
arrivalDestroyEvents=false
```

Nicht zulässig:

```text
event=mission_configuration_missing
event=mission_object_lookup_failed
event=convoy_route_plan_failed
event=spawn_count_mismatch
```

## 7. Routen- und Spawn-Regression

Erwartet werden:

```text
5 × event=convoy_route_plan_compiled
5 × event=convoy_spawned
5 × event=convoy_route_started
```

Abnahme:

- genau fünf Gruppen;
- genau sieben Fahrzeuge je Gruppe;
- insgesamt 35 Fahrzeuge;
- jede Gruppe entspricht `TPL_BLUE_CONVOY_STANDARD_07` in Position und Fahrzeugfolge;
- alle Fahrzeuge stehen auf der jeweiligen Straße und in lokaler Marschrichtung;
- keine Gebäude-, Mauer- oder Dachspawns;
- alle fünf Verbände folgen der unveränderten PATHLINE-Geometrie;
- jeder Wegpunkt verwendet 50 km/h und `On Road`;
- CALIFORNIA-C2/C3 nutzt vollständig `MSR_CAL_C01` und `MSR_CAL_C02`.

## 8. Ankunft und Bereinigung

Bei vollständiger Ankunft jeder Gruppe:

```text
event=convoy_arrived
survivingVehicles=7

event=convoy_despawn_scheduled
delaySeconds=60
generateDestroyEvents=false
method=MOOSE_GROUP_Destroy
```

Nach ungefähr 60 Sekunden:

```text
event=convoy_despawned
method=MOOSE_GROUP_Destroy
```

Gesamt-PASS:

```text
event=all_convoys_arrived
convoyCount=5
survivingVehicles=35
speedKph=50

event=all_convoys_despawned
convoyCount=5
```

## 9. Besondere Beobachtungspunkte

### Jalalabad

- beide ILLINOIS-Konvois erreichen `OMW_LOG_NODE_JALALABAD`;
- CALIFORNIA-C1 kann denselben Knoten als Start verwenden;
- die erste angekommene Gruppe wird nach 60 Sekunden entfernt;
- die Bereinigung erfasst keine falsche Laufzeitgruppe.

### Asadabad

- CALIFORNIA-C1 endet in `OMW_LOG_NODE_ASADABAD`;
- CALIFORNIA-C2/C3 startet am selben Knoten;
- die spätere Entfernung der ersten Gruppe beeinflusst den abgefahrenen Folgekonvoi nicht.

## 10. PASS-Kriterien

- Bootstrap endet mit `READY`.
- `TPL_BLUE_CONVOY_STANDARD_07` wird gefunden.
- `TPL_TEST_BLUE_CONVOY_STANDARD_01` wird nicht benötigt und ist im aktuellen Missionsstand gelöscht.
- Alle sechs gemeinsamen Standortknoten werden gefunden.
- Alle fünf Gruppen spawnen mit je sieben Fahrzeugen.
- Alle 35 Fahrzeuge erreichen bei unbeschädigtem Lauf ihre Zielknoten.
- Genau fünf stille 60-Sekunden-Despawnvorgänge werden abgeschlossen.
- Planmäßiges Entfernen erzeugt kein `convoy_destroyed`.
- `all_convoys_arrived` meldet 35 Fahrzeuge.
- `all_convoys_despawned` erscheint genau einmal.
- Kein TM01M-Lua-Fehler tritt auf.

## 11. Nachweis

```text
dcs.log
debrief.log
Screenshot beider neuen Late-Activation-Templates
Screenshot ohne TPL_TEST_BLUE_CONVOY_STANDARD_01
Screenshot der fünf korrekten Siebener-Spawns
Screenshot einer angekommenen Gruppe während der Abklingzeit
Screenshot desselben Zielbereichs nach dem Despawn
Nachweis all_convoys_arrived
Nachweis all_convoys_despawned
```
