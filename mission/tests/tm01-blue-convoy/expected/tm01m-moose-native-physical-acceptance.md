# TM01M – Fünf gleichzeitige MOOSE-native MSR-Konvois: DCS-Abnahme

Status: `30-km/h-Einzelkonvoi-Baseline PASS`; `50-km/h-Fünf-Konvoi-Stresstest AUSSTEHEND`

## Zweck

TM01M prüft nun fünf gleichzeitig aktive physische Konvois auf fünf getrennten MSR-Verbindungen. Alle Verbände verwenden dasselbe Mission-Editor-Template und dieselben gemeinsamen Marschparameter.

Die Teststufe enthält weiterhin keine Virtualisierung, keinen CampaignState, kein Pack/Unpack und keine Recovery-, Teleport- oder Unstuck-Logik.

Der nicht ausgeführte 40-km/h-Einzelkonvoi-Zwischenschritt wird durch diesen größeren 50-km/h-Stresstest ersetzt. Daraus folgt ausdrücklich noch kein Nachweis, dass 50 km/h für jeden gemischten Verband dauerhaft fahrbar sind.

## Konfiguration

```text
Konfigurationsversion: TM01M-moose-native-five-convoys-1
Konvoi-Anzahl:         5
Fahrzeuge je Konvoi:   6
Gesamtfahrzeuge:       30
Sollgeschwindigkeit:   50 km/h
Formation:             On Road
Template:              TPL_TEST_BLUE_CONVOY_STANDARD_01
```

Jeder Verband besteht aus dem unveränderten gemeinsamen Template:

```text
3 × M1043 HMMWV Armament
3 × CHAP_M1083
```

## Verbindliche Routen

### EAST-E3: Bagram → Kabul

```text
MSR_EAST_E3_START_BAGRAM
→ MSR_EAST_E03
→ MSR_EAST_E3_TARGET_KABUL
```

### EAST-E2: Kabul → Jalalabad

```text
MSR_EAST_E2_START_KABUL
→ MSR_EAST_E02
→ MSR_EAST_E2_TARGET_JALALABAD
```

### EAST-E1: Torkham → Jalalabad

```text
MSR_EAST_E1_START_TORKHAM
→ MSR_EAST_E01
→ MSR_EAST_E1_TARGET_JALALABAD
```

### KUNAR-K1: Jalalabad → Asadabad

```text
MSR_KUNAR K1_START_JALALABAD
→ MSR_KUNAR_K01
→ MSR_KUNAR K1_TARGET_ASADABAD
```

### CALIFORNIA: Asadabad → FOB Bostik

```text
MSR_CALIFORNIA_START_ASADABAD
→ MSR_CAL_C01
→ MSR_CAL_C02
→ MSR_CALIFORNIA_TARGET_FOB_BOSTIK
```

Die im Mission Editor sichtbaren Beschriftungen mit Leerzeichen und Bindestrichen sind nicht die MOOSE-Objektnamen. Für `PATHLINE:FindByName()` gelten ausschließlich die oben genannten internen Namen mit Unterstrichen.

## MOOSE-First-Aufbau

TM01M verwendet weiterhin ausschließlich die bereits geprüften MOOSE-Bausteine:

```text
PATHLINE:FindByName()
PATHLINE:GetNumberOfPoints()
PATHLINE:GetPoint2DFromIndex()
COORDINATE:GetClosestPointToRoad()
COORDINATE:GetPathOnRoad()
COORDINATE:WaypointGround()
SPAWN:NewWithAlias()
SPAWN:InitSetUnitAbsolutePositions()
SPAWN:Spawn()
GROUP:Route()
SCHEDULER:New()
MESSAGE:New()
MENU_MISSION / MENU_MISSION_COMMAND
```

Aus demselben Template werden fünf voneinander unabhängige MOOSE-`SPAWN`-Instanzen mit eindeutigen Laufzeitaliasen erzeugt. Ein einziger MOOSE-`SCHEDULER` überwacht alle fünf Verbände.

## Laufzeitalias und Konvoi-IDs

```text
EAST_E3_BGR_KBL      → TM01M_E3_BGR_KBL
EAST_E2_KBL_JBAD     → TM01M_E2_KBL_JBAD
EAST_E1_TRK_JBAD     → TM01M_E1_TRK_JBAD
KUNAR_K1_JBAD_ASAD   → TM01M_K1_JBAD_ASAD
CAL_ASAD_BOSTIK      → TM01M_CAL_ASAD_BOS
```

Jeder relevante Logeintrag enthält `convoyId=...`, damit Route, Spawn, Routenstart, Zerstörung und Ankunft eindeutig zugeordnet werden können.

## Vorbereitungen

1. Branch aktualisieren und den erwarteten HEAD prüfen.
2. Bundle neu bauen:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-tm01m-bundle.ps1"
```

3. Die Mission `OMW_TEST_TM01M_MooseFirst(3).miz` im DCS Mission Editor öffnen.
4. Im vorhandenen `DO SCRIPT FILE`-Trigger die neu erzeugte Datei `mission/tests/tm01-blue-convoy/dist/TM01M.lua` erneut auswählen.
5. `Moose.lua` weiterhin vor `TM01M.lua` laden.
6. Mission speichern.
7. DCS-Log vor dem Lauf leeren oder den Laufbeginn eindeutig markieren.

Die hochgeladene Missionsdatei enthält noch die alte eingebettete Konfiguration `TM01M-moose-native-msr-pathline-1` mit einem Einzelkonvoi und 30 km/h. Ohne erneutes Auswählen und Speichern würde deshalb nicht der Fünf-Konvoi-Test laufen.

## Erwarteter Bootstrap

Für jeden Konvoi muss genau ein Ereignis erscheinen:

```text
event=convoy_route_plan_compiled
convoyId=...
runtimeAlias=...
routeMode=MOOSE_PATHLINE_MSR
startZoneName=...
targetZoneName=...
msrPathlines=...
pathlineDirections=...
msrPathlineCount=...
sourcePointCount=...
compiledPointCount=...
routeLengthMeters=...
```

Danach muss die Gesamtsumme erscheinen:

```text
event=multi_convoy_route_plans_compiled
convoyCount=5
msrPathlineCount=6
sourcePointCount=1618
compiledPointCount=...
totalRouteLengthMeters=...
```

Zusätzlich:

```text
event=bootstrap_outcome
outcome=READY

event=startup
configurationVersion=TM01M-moose-native-five-convoys-1
convoyCount=5
msrPathlineCount=6
speedKph=50
formation=On Road
```

## Start über F10

Empfohlener Teststart:

```text
F10
→ Other
→ OMW Tests
→ TM01M Five MSR Convoys
→ Launch all five convoys
```

Dieser Befehl erzeugt alle fünf Verbände und weist anschließend allen fünf Gruppen die Route mit identischer Verzögerung zu.

Alternativ stehen getrennte Befehle zur Verfügung:

```text
Spawn all convoys
Start all MSR routes
Show fleet status
```

Für Diagnosezwecke existiert außerdem je Konvoi ein eigenes Untermenü.

## Spawn-Abnahme

Nach `Launch all five convoys` oder `Spawn all convoys` müssen genau fünf Laufzeitgruppen mit insgesamt 30 Fahrzeugen existieren.

Für jeden Verband ist zu prüfen:

- sechs Fahrzeuge vorhanden;
- alle Fahrzeuge innerhalb der zugehörigen Startzone;
- alle Fahrzeuge auf einer befahrbaren Straße;
- korrekte lokale Marschrichtung;
- ausreichender Abstand zwischen den Fahrzeugen;
- kein Fahrzeug in einem Gebäude, auf einem Dach, in einer Mauer oder quer zur Straße;
- keine Überschneidung mit einem anderen gleichzeitig gestarteten Verband.

Erwartet werden genau fünf Ereignisse:

```text
event=convoy_spawned
convoyId=...
runtimeAlias=...
aliveUnits=6
spawnPositionMode=MOOSE_InitSetUnitAbsolutePositions
spawnZoneName=...
msrFirstPathline=...
```

Danach:

```text
event=multi_convoy_spawn_completed
requestedConvoys=5
spawnedConvoys=5
totalExpectedVehicles=30
```

## Routenabnahme bei 50 km/h

Erwartet werden genau fünf Ereignisse:

```text
event=convoy_route_started
convoyId=...
runtimeAlias=...
routeMode=MOOSE_PATHLINE_MSR
speedKph=50
formation=On Road
waypointCount=...
routeLengthMeters=...
maximumWaypointRoadSnapMeters=...
```

Danach:

```text
event=multi_convoy_routes_started
requestedConvoys=5
startedConvoys=5
speedKph=50
formation=On Road
```

Besonders zu beobachten sind:

- Fahrzeugabstände bei 50 km/h;
- dauerhaft zurückfallende M1043 oder CHAP M1083;
- Brücken, enge Kurven und Steigungen;
- gleichzeitige KI-Wegfindung von 30 Fahrzeugen;
- die stark überlappenden Jalalabad-Zonen von EAST-E1, EAST-E2 und KUNAR-K1;
- die überlappenden Asadabad-Zonen von KUNAR-K1 und CALIFORNIA;
- mögliche gegenseitige Blockaden an Ziel- und Startbereichen;
- der Übergang `MSR_CAL_C01 → MSR_CAL_C02`.

## Ankunft

Für jeden Verband muss genau einmal erscheinen:

```text
event=convoy_arrived
convoyId=...
runtimeAlias=...
survivingVehicles=6
targetZoneName=...
routeMode=MOOSE_PATHLINE_MSR
```

Wenn alle fünf Konvois angekommen sind:

```text
event=all_convoys_arrived
convoyCount=5
survivingVehicles=30
speedKph=50
```

## PASS-Kriterien

- Bootstrap endet mit `READY`.
- Alle fünf Routenpläne werden aus insgesamt sechs MOOSE-`PATHLINE`-Objekten kompiliert.
- Fünf Gruppen werden aus demselben Template über unabhängige MOOSE-`SPAWN`-Instanzen erzeugt.
- Genau 30 Fahrzeuge stehen korrekt auf ihren Straßen.
- Alle fünf Gruppen erhalten genau einmal eine Route über `GROUP:Route()`.
- Jedes Routenereignis meldet `speedKph=50` und `formation=On Road`.
- Kein Fahrzeug fällt dauerhaft zurück oder verlässt seine Route.
- Kein Verband blockiert einen anderen dauerhaft.
- Alle fünf vollständigen Verbände erreichen ihre jeweilige Zielzone.
- Es werden fünf Einzelankünfte und genau eine Gesamtankunft erkannt.
- `all_convoys_arrived` meldet `survivingVehicles=30`.
- Es tritt kein TM01M-Lua-Fehler auf.
- Es greift keine Virtualisierungs-, Recovery-, Teleport- oder Unstuck-Logik ein.

## FAIL-Kriterien

- die eingebettete Konfiguration meldet weiterhin eine ältere TM01M-Version;
- Bootstrap findet eine der zehn Zonen oder eine der sechs PATHLINEs nicht;
- weniger als fünf Konvois oder weniger als 30 Fahrzeuge werden erzeugt;
- ein Fahrzeug erscheint abseits der Straße oder in einem Objekt;
- ein Verband erhält keine Route oder eine falsche MSR-Zuordnung;
- ein M1043 oder CHAP M1083 kann 50 km/h im Verband dauerhaft nicht halten;
- ein Konvoi reißt dauerhaft auseinander;
- zwei Verbände blockieren sich dauerhaft in Jalalabad oder Asadabad;
- der CALIFORNIA-Konvoi scheitert am Übergang C01 → C02;
- ein Verband bleibt vor seiner Zielzone dauerhaft stehen;
- Spawn oder Routenzuweisung wird doppelt ausgeführt;
- ein benutzerdefinierter Teleport, Respawn oder Unstuck-Vorgang greift ein;
- ein TM01M-Lua-Fehler tritt auf.

## Nachweis

Nach dem Lauf sind mindestens zu sichern:

```text
dcs.log
debrief.log
Screenshot der fünf Spawnaufstellungen
Nachweis aller fünf gleichzeitig fahrenden Verbände
Screenshot oder Track kritischer Knoten in Jalalabad und Asadabad
Screenshot der vollständigen Zielankunft jedes Verbands
beobachtete Simulationszeiten je Konvoi
```

Der 50-km/h-Fünf-Konvoi-Test gilt erst nach einem dokumentierten DCS-Lauf als bestanden.
