# TM01M – Fünf gleichzeitige MOOSE-native MSR-Konvois: DCS-Abnahme

Status: `50-km/h-Fünf-Konvoi-Baseline PASS`; `gemeinsame OMW-Logistikknoten + 60-Sekunden-Zielbereichsbereinigung AUSSTEHEND`

## Bestätigte Baseline

Der DCS-Lauf vom 26. Juli 2026 hat die Konfiguration `TM01M-moose-native-five-convoys-1` vollständig bestanden:

```text
5 Konvois
6 Fahrzeuge je Konvoi
30 Fahrzeuge insgesamt
50 km/h
On Road
6 Mission-Editor-PATHLINEs
1618 PATHLINE-Quellpunkte
450405 m kompilierte Gesamtroutenlänge
```

Abschließender Nachweis:

```text
event=all_convoys_arrived
convoyCount=5
speedKph=50
survivingVehicles=30
```

Autoritativer Ergebnisbericht:

```text
mission/tests/tm01-blue-convoy/results/2026-07-26-tm01m-five-convoy-50kph-pass.md
```

## Aktuelles Folgeinkrement

```text
TM01M-moose-native-five-convoys-4
```

Dieses Inkrement kombiniert zwei nachgelagerte Anpassungen, ohne die bestätigte PATHLINE-Geometrie zu verändern:

1. die fünf Routen verwenden sechs gemeinsame `OMW_LOG_NODE_*`-Standortknoten; ein Knoten darf sowohl Start als auch Ziel sein;
2. vollständig angekommene Konvois werden nach 60 Sekunden über MOOSE `GROUP:Destroy(false, 60)` still entfernt.

## Verbindliche Standortknoten

```text
MSR HORSESHOE / Bagram → Kabul
OMW_LOG_NODE_BAGRAM
OMW_LOG_NODE_KABUL

MSR ILLINOIS-E2 / Kabul → Jalalabad
OMW_LOG_NODE_KABUL
OMW_LOG_NODE_JALALABAD

MSR ILLINOIS-E1 / Torkham → Jalalabad
OMW_LOG_NODE_TORKHAM
OMW_LOG_NODE_JALALABAD

MSR CALIFORNIA-C1 / Jalalabad → Asadabad
OMW_LOG_NODE_JALALABAD
OMW_LOG_NODE_ASADABAD

MSR CALIFORNIA-C2/C3 / Asadabad → FOB Bostick
OMW_LOG_NODE_ASADABAD
OMW_LOG_NODE_BOSTICK
```

Damit werden genau sechs eindeutige Knoten verwendet:

```text
OMW_LOG_NODE_BAGRAM
OMW_LOG_NODE_KABUL
OMW_LOG_NODE_TORKHAM
OMW_LOG_NODE_JALALABAD
OMW_LOG_NODE_ASADABAD
OMW_LOG_NODE_BOSTICK
```

Kabul, Jalalabad und Asadabad besitzen keine getrennten Start- und Zielzonen mehr.

## Unveränderte interne PATHLINE-Bindungen

```text
HORSESHOE Bagram → Kabul           MSR_EAST_E03
ILLINOIS-E2 Kabul → Jalalabad      MSR_EAST_E02
ILLINOIS-E1 Torkham → Jalalabad    MSR_EAST_E01
CALIFORNIA-C1 Jbad → Asadabad      MSR_KUNAR_K01
CALIFORNIA-C2/C3 Asad → Bostick    MSR_CAL_C01 + MSR_CAL_C02
```

Die stabilen internen Konvoi-IDs und Laufzeitaliasse bleiben unverändert. Die historische interne ID `CAL_ASAD_BOSTIK` wird zur Vergleichbarkeit der bisherigen Logs vorerst nicht umbenannt; der tatsächliche Standortknoten und Anzeigename verwenden `BOSTICK`.

## Veraltete Endpunktnamen

Sowohl die ursprünglichen Richtungsanker als auch die zwischenzeitlichen MSR-bezogenen Start-/Zielzonen dürfen nicht mehr verwendet werden. Dazu gehören insbesondere:

```text
MSR_EAST_E3_START_BAGRAM
MSR_EAST_E3_TARGET_KABUL
MSR_EAST_E2_START_KABUL
MSR_EAST_E2_TARGET_JALALABAD
MSR_EAST_E1_START_TORKHAM
MSR_EAST_E1_TARGET_JALALABAD
MSR_KUNAR K1_START_JALALABAD
MSR_KUNAR K1_TARGET_ASADABAD
MSR_CALIFORNIA_START_ASADABAD
MSR_CALIFORNIA_TARGET_FOB_BOSTIK

MSR_HORSESHOE_START_BAGRAM
MSR_HORSESHOE_E3_TARGET_KABUL
MSR_ILLINOIS_E2_START_KABUL
MSR_ILLINOIS_E2_TARGET_JALALABAD
MSR_ILLINOIS_E1_START_TORKHAM
MSR_ILLINOIS_E1_TARGET_JALALABAD
MSR_CALIFORNIA-C1_START_JALALABAD
MSR_CALIFORNIA-C1_TARGET_ASADABAD
MSR_CALIFORNIA-C2_START_ASADABAD
MSR_CALIFORNIA-C03_TARGET_FOB_BOSTIK
```

Ein Lookup auf einen dieser Namen ist ein Konfigurationsfehler.

## MOOSE-First-Nachweis der Zielbereichsbereinigung

Verwendet wird die Funktion der gepinnten MOOSE-Version 2.9.18:

```lua
GROUP:Destroy(GenerateEvent, delay)
```

Aufruf in TM01M:

```lua
runtimeGroup:Destroy(false, 60)
```

MOOSE übernimmt sowohl die Verzögerung als auch das Entfernen. Es gibt keinen eigenen Lua-Timer und keinen nativen DCS-Despawn.

## Vorbereitung

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git fetch origin
git switch feature/tm01m-moose-native-baseline
git pull --ff-only

git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-tm01m-bundle.ps1"
```

Danach im Mission Editor die neu erzeugte Datei erneut auswählen:

```text
mission/tests/tm01-blue-convoy/dist/TM01M.lua
```

`Moose.lua` muss zuerst geladen werden. Die Mission muss anschließend gespeichert werden. Eine bereits in der `.miz` eingebettete ältere TM01M-Datei wird nicht automatisch durch den Repository-Build ersetzt.

## Erwarteter Bootstrap

```text
event=bootstrap_outcome
outcome=READY

event=startup
configurationVersion=TM01M-moose-native-five-convoys-4
convoyCount=5
msrPathlineCount=6
speedKph=50
formation=On Road
arrivalDespawnDelaySeconds=60
arrivalDestroyEvents=false
```

Alle fünf `convoy_route_plan_compiled`-Ereignisse müssen die gemeinsamen `OMW_LOG_NODE_*`-Namen ausgeben. Es darf kein `mission_configuration_missing`, `mission_object_lookup_failed` oder `convoy_route_plan_failed` auftreten.

## Routen- und Spawn-Regression

Erwartet werden:

```text
5 × event=convoy_route_plan_compiled
5 × event=convoy_spawned
5 × event=convoy_route_started
```

Abnahme:

- genau fünf Gruppen und 30 Fahrzeuge;
- sechs Fahrzeuge je Gruppe;
- alle Fahrzeuge korrekt auf der jeweiligen Straße und in lokaler Marschrichtung;
- keine Gebäude-, Mauer- oder Dachspawns;
- alle fünf Verbände folgen ihrer unveränderten internen PATHLINE-Geometrie;
- jeder Wegpunkt verwendet 50 km/h und `On Road`;
- CALIFORNIA-C2/C3 wird vollständig über `MSR_CAL_C01` und `MSR_CAL_C02` durchfahren.

## Ankunft und Abklingzeit

Bei jeder vollständigen Ankunft:

```text
event=convoy_arrived
convoyId=...
survivingVehicles=6
targetZoneName=<OMW_LOG_NODE_*>

event=convoy_despawn_scheduled
convoyId=...
delaySeconds=60
generateDestroyEvents=false
method=MOOSE_GROUP_Destroy
```

Nach ungefähr 60 Sekunden:

```text
event=convoy_despawned
convoyId=...
delaySeconds=60
method=MOOSE_GROUP_Destroy
```

Gesamt-PASS:

```text
event=all_convoys_arrived
convoyCount=5
survivingVehicles=30
speedKph=50
despawnDelaySeconds=60

event=all_convoys_despawned
convoyCount=5
delaySeconds=60
generateDestroyEvents=false
method=MOOSE_GROUP_Destroy
```

## Besondere Beobachtungspunkte

### Jalalabad

- beide ILLINOIS-Konvois erreichen dieselbe `OMW_LOG_NODE_JALALABAD`-Zone;
- CALIFORNIA-C1 kann denselben Knoten als Start verwenden;
- der zuerst angekommene Verband verschwindet nach 60 Sekunden;
- keine Bereinigung entfernt die falsche Laufzeitgruppe.

### Asadabad

- CALIFORNIA-C1 endet in `OMW_LOG_NODE_ASADABAD`;
- CALIFORNIA-C2/C3 verwendet denselben Knoten als Start;
- das spätere Entfernen des C1-Konvois beeinflusst den bereits abgefahrenen C2/C3-Konvoi nicht.

## PASS-Kriterien

- Bootstrap endet mit `READY`.
- Alle sechs gemeinsamen Standortknoten werden gefunden.
- Kein veralteter Start-/Zielanker wird benötigt.
- Die sechs internen PATHLINE-Namen bleiben unverändert funktionsfähig.
- Alle fünf Verbände erreichen ihr Ziel mit jeweils sechs Fahrzeugen.
- Genau fünf stille 60-Sekunden-Despawnvorgänge werden geplant und abgeschlossen.
- Planmäßiges Entfernen erzeugt kein `convoy_destroyed`.
- `all_convoys_arrived` meldet 30 Fahrzeuge.
- `all_convoys_despawned` erscheint genau einmal.
- Kein TM01M-Lua-Fehler tritt auf.

## Nachweis

```text
dcs.log
debrief.log
Screenshot der fünf korrekten Spawns
Screenshot einer angekommenen Gruppe während der Abklingzeit
Screenshot desselben Zielbereichs nach dem Despawn
Nachweis all_convoys_arrived
Nachweis all_convoys_despawned
```
