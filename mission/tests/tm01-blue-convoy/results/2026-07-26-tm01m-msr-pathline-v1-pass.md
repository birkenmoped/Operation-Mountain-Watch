# TM01M – MSR-PATHLINE-Baseline Version 1: DCS PASS

Datum: 26. Juli 2026  
Status: PASS

## Validierter Stand

```text
Branch:                feature/tm01m-moose-native-baseline
Validierter Commit:    0db10501f81c160cd5818088e760af181b33d86d
Konfigurationsversion: TM01M-moose-native-msr-pathline-1
DCS-Version:           2.9.28.26283
```

## Nachweise

```text
dcs(86).log
SHA-256 afe3dcae67494d53756f55e24a776949254ce90df67ac9846278ed30e4a15969

debrief(39).log
SHA-256 a4e3f820d676308311ed397a0ead21de2a707131161d13c1bd4a0b36909f43a1
```

## Kompilierter MSR-Plan

```text
event=msr_route_plan_compiled
routeMode=MOOSE_PATHLINE_MSR
msrPathlines=MSR_EAST_E03,MSR_EAST_E02
pathlineDirections=MSR_EAST_E03:reversed,MSR_EAST_E02:reversed
sourcePointCount=641
compiledPointCount=709
routeLengthMeters=213299
startConnectorMeters=1919
startRoadSnapMeters=6
targetConnectorMeters=287
targetRoadSnapMeters=1
```

Der Bootstrap endete mit `READY`.

## Spawn

```text
event=convoy_spawned
runtimeGroupName=TM01M_BLUE_CONVOY#001
aliveUnits=6
spawnPositionMode=MOOSE_InitSetUnitAbsolutePositions
spawnZoneName=ZONE_TM01_START_BAGRAM
spawnX=124664
spawnY=271218
spawnHeadingDeg=206
spawnLeadRouteDistanceMeters=110
spawnRearRouteDistanceMeters=20
maximumSpawnRoadSnapMeters=2
```

Alle sechs Fahrzeuge wurden straßengerecht innerhalb der Startzone aufgestellt. Es trat kein Spawn in einem Gebäude, auf einem Dach oder quer zur Straße auf.

## Routenzuweisung

```text
event=convoy_route_started
routeMode=MOOSE_PATHLINE_MSR
msrPathlineCount=2
msrPathlines=MSR_EAST_E03,MSR_EAST_E02
formation=On Road
speedKph=30
waypointCount=89
routeLengthMeters=213189
maximumWaypointRoadSnapMeters=19
```

Der Konvoi folgte der vollständigen Route von Bagram über `MSR_EAST_E03` und `MSR_EAST_E02` bis Jalalabad. Die historischen Route-Anchor-Zonen wurden nicht benötigt.

## Ankunft

```text
event=convoy_arrived
routeMode=MOOSE_PATHLINE_MSR
runtimeGroupName=TM01M_BLUE_CONVOY#001
survivingVehicles=6
targetZoneName=ZONE_TM01_TARGET_JALALABAD
```

Die Ankunft wurde genau einmal erkannt. Alle sechs Fahrzeuge überlebten und befanden sich vollständig in der Zielzone.

## Fahrzeugzusammensetzung

```text
3 × M1043 HMMWV Armament
3 × CHAP_M1083
```

Im abschließenden Debrief waren alle sechs Laufzeitfahrzeuge mit `dead=false` enthalten.

## Fahrzeit und Geschwindigkeit

Beobachtete Simulationszeit:

```text
Abfahrt:  ca. 08:00
Ankunft:  ca. 15:11
Dauer:    ca. 7 h 11 min
```

Aus der zugewiesenen Strecke von `213.189 km` ergibt sich:

```text
Durchschnitt: ca. 29,7 km/h
             ca. 16,0 kn
```

Das entspricht praktisch exakt der konfigurierten Sollgeschwindigkeit von `30 km/h`. Die beobachteten ungefähr `16 kn` waren daher keine erkennbare fahrzeugbedingte Begrenzung, sondern die vorgegebene Routengeschwindigkeit.

Aufgrund der verwendeten Zeitbeschleunigung betrug die reale Logzeit zwischen Routenzuweisung und Ankunft ungefähr `33 min 31 s`.

## Ergebnis

**PASS**

Nachgewiesen wurden:

- erfolgreiche MOOSE-`PATHLINE`-Auflösung und automatische Fahrtrichtung;
- straßengerechter absoluter Spawn aller sechs Fahrzeuge;
- durchgehende MSR-gebundene Route mit 89 Wegpunkten;
- korrekter Übergang von `MSR_EAST_E03` auf `MSR_EAST_E02`;
- vollständige Fahrt bis Jalalabad;
- genau einmalige Ankunftserkennung;
- sechs überlebende Fahrzeuge;
- keine relevante TM01M-Lua-Fehlermeldung;
- keine Virtualisierung, Recovery-, Teleport- oder alte TM01B-/TM01C-Runtime.

Der bekannte `bhHook.lua:168`-Fehler trat erst nach `Dispatcher Stop` auf und gehört nicht zum TM01M-Missionsskript.

## Folgeinkrement

Die angenommene Sollgeschwindigkeit wird in `TM01M-moose-native-msr-pathline-2` kontrolliert von `30 km/h` auf `40 km/h` erhöht.

Der nächste DCS-Lauf muss prüfen:

- ob alle drei M1043 und alle drei CHAP M1083 die Marschgruppe dauerhaft halten;
- ob kein Fahrzeug dauerhaft zurückfällt oder die Wegfindung verliert;
- ob der Verband weiterhin vollständig in Jalalabad ankommt;
- ob die höhere Geschwindigkeit keine neuen Stau-, Kurven- oder Brückenprobleme erzeugt.

Die theoretische Fahrzeit für `213.189 km` bei konstant `40 km/h` beträgt ungefähr `5 h 20 min`. Dieser Wert ist nur eine Orientierung; DCS-Ground-AI, Kurven, Steigungen und kurzfristige Verzögerungen dürfen die tatsächliche Fahrzeit erhöhen.
