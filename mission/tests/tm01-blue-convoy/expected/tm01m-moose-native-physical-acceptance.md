# TM01M – Fünf gleichzeitige MOOSE-native MSR-Konvois: DCS-Abnahme

Status: `50-km/h-Fünf-Konvoi-Baseline PASS`; `umbenannte MSR-Endpunkte + 60-Sekunden-Zielbereichsbereinigung AUSSTEHEND`

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
TM01M-moose-native-five-convoys-3
```

Dieses Inkrement kombiniert zwei nachgelagerte Anpassungen, ohne die bestätigte Routengeometrie zu verändern:

1. die Mission-Editor-Start- und Zielzonen verwenden die neuen fachlichen MSR-Namen;
2. vollständig angekommene Konvois werden nach 60 Sekunden über MOOSE `GROUP:Destroy(false, 60)` still entfernt.

## Verbindliche Mission-Editor-Endpunkte

```text
MSR HORSESHOE / Bagram → Kabul
MSR_HORSESHOE_START_BAGRAM
MSR_HORSESHOE_E3_TARGET_KABUL

MSR ILLINOIS-E2 / Kabul → Jalalabad
MSR_ILLINOIS_E2_START_KABUL
MSR_ILLINOIS_E2_TARGET_JALALABAD

MSR ILLINOIS-E1 / Torkham → Jalalabad
MSR_ILLINOIS_E1_START_TORKHAM
MSR_ILLINOIS_E1_TARGET_JALALABAD

MSR CALIFORNIA-C1 / Jalalabad → Asadabad
MSR_CALIFORNIA-C1_START_JALALABAD
MSR_CALIFORNIA-C1_TARGET_ASADABAD

MSR CALIFORNIA-C2/C3 / Asadabad → FOB Bostik
MSR_CALIFORNIA-C2_START_ASADABAD
MSR_CALIFORNIA-C03_TARGET_FOB_BOSTIK
```

Die Schreibweise ist exakt einzuhalten. Insbesondere gehören die Bindestriche in `MSR_CALIFORNIA-C1_*`, `MSR_CALIFORNIA-C2_*` und `MSR_CALIFORNIA-C03_*` zum Objektnamen. Der Zielname verwendet weiterhin die in der Mission gespeicherte Schreibweise `BOSTIK`.

## Unveränderte interne PATHLINE-Bindungen

Die sichtbare und fachliche MSR-Benennung wurde angepasst. Die internen Mission-Editor-PATHLINE-Namen wurden nicht umbenannt und bleiben verbindlich:

```text
HORSESHOE Bagram → Kabul           MSR_EAST_E03
ILLINOIS-E2 Kabul → Jalalabad      MSR_EAST_E02
ILLINOIS-E1 Torkham → Jalalabad    MSR_EAST_E01
CALIFORNIA-C1 Jbad → Asadabad      MSR_KUNAR_K01
CALIFORNIA-C2/C3 Asad → Bostik     MSR_CAL_C01 + MSR_CAL_C02
```

Die stabilen internen Konvoi-IDs und Laufzeitaliasse bleiben ebenfalls unverändert. Dadurch wird die bereits bestandene Routen-, Spawn- und Diagnoselogik nicht unnötig neu identifiziert.

## Veraltete Endpunktnamen

Die folgenden Namen dürfen in der aktuellen TM01M-Konfiguration nicht mehr verwendet werden:

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

MOOSE übernimmt sowohl die Verzögerung als auch das Entfernen. Es gibt keinen eigenen Lua-Timer und keinen nativen DCS-Despawn. `GenerateEvent=false` verhindert künstliche Dead-/Crash-Ereignisse für eine erfolgreich angekommene Lieferung.

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
configurationVersion=TM01M-moose-native-five-convoys-3
convoyCount=5
msrPathlineCount=6
speedKph=50
formation=On Road
arrivalDespawnDelaySeconds=60
arrivalDestroyEvents=false
```

Alle fünf `convoy_route_plan_compiled`-Ereignisse müssen die neuen Start- und Zielzonennamen ausgeben. Es darf kein `mission_configuration_missing`, `mission_object_lookup_failed` oder `convoy_route_plan_failed` auftreten.

## Routen- und Spawn-Regression

Erwartet werden weiterhin:

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
targetZoneName=<neuer Endpunktname>

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

- beide ILLINOIS-Konvois erreichen ihre jeweils korrekt umbenannte Zielzone;
- der zuerst angekommene Verband verschwindet nach 60 Sekunden;
- die Zielstraße wird für den später ankommenden Verband freigegeben;
- keine Bereinigung entfernt die falsche Laufzeitgruppe.

### Asadabad

- CALIFORNIA-C1 endet in `MSR_CALIFORNIA-C1_TARGET_ASADABAD`;
- CALIFORNIA-C2/C3 startet unabhängig in `MSR_CALIFORNIA-C2_START_ASADABAD`;
- das spätere Entfernen des C1-Konvois beeinflusst den bereits abgefahrenen C2/C3-Konvoi nicht.

## PASS-Kriterien

- Bootstrap endet mit `READY`.
- Alle zehn neuen Endpunktnamen werden gefunden.
- Kein veralteter Endpunktname wird benötigt.
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
