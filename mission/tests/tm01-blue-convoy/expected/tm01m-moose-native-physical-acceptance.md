# TM01M – Fünf gleichzeitige MOOSE-native MSR-Konvois: DCS-Abnahme

Status: `50-km/h-Fünf-Konvoi-Baseline PASS`; `60-Sekunden-Zielbereichsbereinigung AUSSTEHEND`

## Bestätigte Baseline

Der DCS-Lauf vom 26. Juli 2026 hat die Konfiguration

```text
TM01M-moose-native-five-convoys-1
```

vollständig bestanden:

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

## Neues Folgeinkrement

```text
TM01M-moose-native-five-convoys-2
```

Die Routen-, Spawn- und Geschwindigkeitsparameter bleiben unverändert. Ergänzt wird ausschließlich der Lebenszyklus nach vollständiger Ankunft:

```text
vollständige Gruppe in Zielzone
→ convoy_arrived
→ 60 Sekunden Abklingzeit
→ MOOSE GROUP:Destroy(false, 60)
→ Gruppe wird ohne Dead-/Crash-Ereignisse entfernt
→ Zielstraße wird freigegeben
```

## MOOSE-First-Nachweis

Verwendet wird die Funktion der gepinnten MOOSE-Version 2.9.18:

```lua
GROUP:Destroy(GenerateEvent, delay)
```

Aufruf in TM01M:

```lua
runtimeGroup:Destroy(false, 60)
```

Damit übernimmt MOOSE sowohl die Verzögerung als auch das Entfernen der Gruppe. Es wird kein eigener Lua-Timer und kein nativer DCS-Despawn implementiert.

`GenerateEvent=false` ist verbindlich, damit das administrative Entfernen nach erfolgreicher Lieferung nicht als Fahrzeugverlust, Dead- oder Crash-Ereignis ausgewertet wird.

## Vorbereitungen

Branch aktualisieren:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git fetch origin
git switch feature/tm01m-moose-native-baseline
git pull --ff-only
git rev-parse HEAD
```

Bundle bauen:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-tm01m-bundle.ps1"
```

Danach im Mission Editor die neu erzeugte Datei erneut auswählen:

```text
mission/tests/tm01-blue-convoy/dist/TM01M.lua
```

`Moose.lua` muss weiterhin zuerst geladen werden. Mission anschließend speichern.

## Erwarteter Bootstrap

```text
event=bootstrap_outcome
outcome=READY

event=startup
configurationVersion=TM01M-moose-native-five-convoys-2
convoyCount=5
msrPathlineCount=6
speedKph=50
formation=On Road
arrivalDespawnDelaySeconds=60
arrivalDestroyEvents=false
```

## Routen- und Spawn-Regression

Die bestätigte Baseline darf durch die Zielbereichsbereinigung nicht verändert werden.

Erwartet werden weiterhin:

```text
5 × event=convoy_route_plan_compiled
5 × event=convoy_spawned
5 × event=convoy_route_started
```

Spawn-Abnahme:

- genau fünf Gruppen;
- genau 30 Fahrzeuge;
- sechs Fahrzeuge je Gruppe;
- alle Fahrzeuge korrekt auf der jeweiligen Straße;
- korrekte lokale Marschrichtung;
- keine Gebäude-, Mauer- oder Dachspawns.

Routen-Abnahme:

- alle fünf Verbände fahren ihre konfigurierte MSR;
- jeder Wegpunkt verwendet 50 km/h und `On Road`;
- keine dauerhafte Trennung oder Blockade;
- CAL-C1/CAL-C2 wird vollständig durchfahren.

## Ankunft und Abklingzeit

Bei jeder vollständigen Ankunft müssen unmittelbar erscheinen:

```text
event=convoy_arrived
convoyId=...
survivingVehicles=6
targetZoneName=...
```

und danach:

```text
event=convoy_despawn_scheduled
convoyId=...
delaySeconds=60
generateDestroyEvents=false
method=MOOSE_GROUP_Destroy
```

Die Gruppe muss anschließend ungefähr 60 Sekunden physisch im Zielbereich verbleiben.

Während dieser Abklingzeit gilt:

- die Gruppe bleibt sichtbar;
- sie wird nicht als zerstört gewertet;
- es darf kein zweiter Despawn geplant werden;
- die übrigen Konvois laufen unabhängig weiter.

Nach Ablauf der Verzögerung muss erscheinen:

```text
event=convoy_despawned
convoyId=...
delaySeconds=60
method=MOOSE_GROUP_Destroy
```

Die Gruppe muss danach vollständig aus der Mission entfernt sein.

## Gesamtankunft trotz früher Despawns

Da die ersten Konvois deutlich früher als der letzte Verband eintreffen können, darf die Gesamtauswertung nicht die zu diesem Zeitpunkt noch physisch vorhandenen Fahrzeuge zählen. Sie muss die bei jeder Einzelankunft gespeicherte Fahrzeugzahl summieren.

Deshalb bleibt der erwartete Gesamt-PASS:

```text
event=all_convoys_arrived
convoyCount=5
survivingVehicles=30
speedKph=50
despawnDelaySeconds=60
```

Dieser Eintrag muss auch dann `survivingVehicles=30` melden, wenn frühere Konvois bereits planmäßig entfernt wurden.

Nach der letzten Zielbereichsbereinigung:

```text
event=all_convoys_despawned
convoyCount=5
delaySeconds=60
generateDestroyEvents=false
method=MOOSE_GROUP_Destroy
```

## Besondere Beobachtungspunkte

### Jalalabad

Zwei Konvois enden im stark überlappenden Zielbereich. Hier ist zu prüfen:

- erste Ankunft wird korrekt erkannt;
- erste Gruppe wird nach 60 Sekunden entfernt;
- die Zielstraße wird dadurch vor beziehungsweise während der späteren Ankunft wieder freigegeben;
- keine Gruppe wird durch die Bereinigung einer anderen Gruppe beeinflusst.

### Asadabad

Der KUNAR-Konvoi endet nahe dem Startbereich des CALIFORNIA-Konvois. Auch dort muss die spätere Bereinigung ausschließlich die angekommene Laufzeitgruppe entfernen.

## PASS-Kriterien

- Bootstrap endet mit `READY`.
- Alle fünf Routen- und Spawn-Baselinekriterien bleiben bestanden.
- Alle fünf Verbände erreichen ihr Ziel mit jeweils sechs Fahrzeugen.
- Genau fünf `convoy_despawn_scheduled`-Ereignisse erscheinen.
- Jeder Despawn verwendet 60 Sekunden und `generateDestroyEvents=false`.
- Keine Gruppe verschwindet vor Ablauf der Abklingzeit.
- Genau fünf `convoy_despawned`-Ereignisse erscheinen.
- Planmäßiges Entfernen erzeugt kein `convoy_destroyed`.
- `all_convoys_arrived` meldet weiterhin 30 Fahrzeuge.
- `all_convoys_despawned` erscheint genau einmal.
- Jalalabad wird nach den Ankünften wieder freigegeben.
- Kein TM01M-Lua-Fehler tritt auf.

## FAIL-Kriterien

- eine Gruppe wird unmittelbar statt nach ungefähr 60 Sekunden entfernt;
- ein planmäßiger Despawn erzeugt Dead-/Crash- oder Verlustereignisse;
- die Gruppe bleibt dauerhaft in der Zielzone stehen;
- ein Despawn entfernt die falsche Gruppe;
- eine Gruppe wird mehrfach entfernt;
- `all_convoys_arrived` meldet wegen früherer Despawns weniger als 30 Fahrzeuge;
- planmäßige Bereinigung wird als `convoy_destroyed` protokolliert;
- die erfolgreiche 50-km/h-Routen- oder Spawn-Baseline regressiert;
- ein TM01M-Lua-Fehler tritt auf.

## Nachweis

Nach dem Lauf sichern:

```text
dcs.log
debrief.log
Screenshot einer angekommenen Gruppe während der Abklingzeit
Screenshot desselben Zielbereichs nach dem Despawn
Nachweis der zwei Jalalabad-Ankünfte
Nachweis all_convoys_arrived
Nachweis all_convoys_despawned
```
