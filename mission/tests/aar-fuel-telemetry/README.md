---
document_id: OMW-TEST-AAR-FUEL-TELEMETRY
status: DRAFT
document_class: TEST_MANIFEST
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local AAR fuel telemetry test scope
  - build and Mission Editor insertion procedure for AAR fuel calibration
  - interpretation boundaries of SPAWN, INGRESS and TRACK fuel measurements
  - branch-local KC-135 spawn-speed candidate evaluation
not_authoritative_for:
  - revised production initial fuel values
  - revised FuelLow thresholds
  - revised production transit speed before owner acceptance
  - historical KC-135 fuel burn
  - repository-wide acceptance before a documented DCS run
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# AAR Fuel Telemetry Calibration

## Ziel

Der Test erfasst für die erste natürliche Sortie aller sechs produktiven AAR-Tracks drei voneinander unabhängige Fuel-Messpunkte:

```text
1. SPAWN
2. FIR INGRESS
3. TRACK ENTRY
```

`FuelLow` wird bewusst **nicht** als Messpunkt verwendet. Die aktuellen FuelLow-Schwellen sind selbst Teil der späteren Neukalibrierung und dürfen daher nicht als Eingangsdaten für diese Messung dienen.

Der zweite Lauf `AAR-FUEL-TELEMETRY-2` prüft zusätzlich einen eng abgegrenzten Kandidaten für den In-Air-Spawnzustand. Im ersten DCS-Lauf wurde direkt nach dem Spawn bei ungefähr FL330 ein deutlich energiearmer Zustand beobachtet und per Screenshot dokumentiert: etwa `172 KIAS`, hoher Anstellwinkel und anschließende längere Beschleunigung. Nach Stabilisierung wurden ungefähr `274 KIAS` in FL340 beobachtet.

## Test-2-Kandidat

Für die Vergleichbarkeit wird **nur die initiale physische Spawn-Geschwindigkeit** geändert:

```text
production SPAWN initial speed:   300 kt
candidate SPAWN initial speed:    480 kt
production ingress/egress speed:  300 kt, unverändert
track speed FAST/SLOW:            unverändert
transit altitude:                 unverändert
initial fuel:                     unverändert
FuelLow:                          unverändert
```

Der Builder verändert dafür ausschließlich die im generierten Testbundle verwendete `SPAWN:InitSpeedKnots(...)`-Zeile. Die produktive Datei `scripts/air-operations/OMW_AAR_Controller.lua` wird **nicht** verändert.

Diese Ein-Variablen-Änderung ist beabsichtigt: Der zweite Lauf soll zeigen, ob die künstliche Beschleunigungsphase nach der Materialisierung verschwindet und wie sich dies auf `SPAWN -> INGRESS` sowie `SPAWN -> TRACK` auswirkt. Der bereits stabil wirkende produktive Ingress-/Egress-Route-Speed bleibt zunächst unangetastet.

## Testumfang

STANDARD:

```text
NELSON   FAST   MANAS     EGPAN
PATTY    SLOW   MANAS     EGPAN
MILHOUSE SLOW   AL_UDEID  DAVER
KRUSTY   SLOW   AL_UDEID  DAVER
```

RESERVE, für diesen Test explizit geöffnet:

```text
LISA     FAST   MANAS     PINAX
MOE      FAST   MANAS     PINAX
```

Damit werden Nord- und Südquellgruppe in einem Lauf erfasst.

## MOOSE-First-Prüfung

Gepinnter Projektstand:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für Spawn und Routing werden weiterhin ausschließlich vorhandene MOOSE-Funktionen verwendet:

```text
SPAWN:InitSpeedKnots(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
FLIGHTGROUP:AddWaypoint(...)
```

Der tatsächlich verwendete `Moose.lua`-Stand dokumentiert `SPAWN:InitSpeedKnots(Knots)` als Initialgeschwindigkeit für In-Air-Spawns und wandelt den Wert über `UTILS.KnotsToMps(...)` in die Spawn-Geschwindigkeit um. `SetMissionIngressCoord(..., Speed)` und `SetMissionEgressCoord(..., Speed)` erwarten Speed in knots. `FLIGHTGROUP:AddWaypoint(...)` erwartet ebenfalls knots und erzeugt daraus einen DCS-Air-Waypoint über `COORDINATE:WaypointAir(...)`.

Für die Fuel-Telemetrie werden verwendet:

```text
UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
FLIGHTGROUP:GetCoordinate()
COORDINATE:Get2DDistance(...)
SCHEDULER:New(...)
```

`UNIT:GetFuel()` liefert laut gepinntem `Moose.lua` den relativen DCS-Fuelwert und kann bei externen Tanks größer als `1.0` sein. Der Rohwert wird daher nicht geklemmt. Zusätzlich werden, soweit von MOOSE verfügbar, Fuelmasse in kg und maximale Fuelmasse protokolliert.

## Messgeometrie

Die produktive AAR-Logik verwendet aktuell:

```text
FIR fix radius:     5 NM
Track entry radius: 5 NM
```

Der Telemetrie-Harness misst INGRESS und TRACK mit denselben Radien. Zusätzlich protokolliert er die reale Distanz zum jeweiligen Referenzpunkt im Messmoment.

Für die Fuel-Neuberechnung gelten die bekannten produktiven Referenzdistanzen zwischen FIR-Fix und Track. Die im ersten Test nicht funktionierende aufsummierte `path...Nm`-Diagnose ist für diesen zweiten Lauf **kein Acceptance-Kriterium** und wird nicht als Grund für einen weiteren Test verwendet.

## Erfasste Daten

Pro Track werden mindestens ausgegeben:

```text
runtime
area
profile
source
point
fuelRel
fuelPct
fuelKg
maxFuelKg
time
distanceToReferenceNm
```

Zusammenfassung pro Track:

```text
spawnFuelPct
ingressFuelPct
trackFuelPct
burnSpawnIngressPct
burnIngressTrackPct
burnSpawnTrackPct
plannedFirTrackNm
timeSpawnIngressSec
timeIngressTrackSec
```

Der SPAWN-Wert wird beim ersten Poll nach Materialisierung gelesen. `sampleDelaySec` dokumentiert die Verzögerung zwischen `materializedAt` und tatsächlichem Fuel-Sample.

## Optische DCS-Prüfung

Für mindestens einen nördlichen und einen südlichen Tanker sollen Screenshots dokumentieren:

```text
A. unmittelbar nach Spawn / sobald auswählbar
B. nach Stabilisierung im Transit
```

Soweit die DCS-Oberfläche sie anzeigt, sollen erkennbar sein:

```text
IAS in der Außenansicht
Höhe
Pitch / AoA
Geschwindigkeitsanzeige auf F10
```

Ziel ist nicht die formale Ableitung von IAS/TAS/GS aus der UI, sondern der direkte A/B-Nachweis, ob der neue Spawnzustand die zuvor beobachtete hohe AoA und lange Beschleunigungsphase reduziert.

## Build

Auf dem Testbranch:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git switch agent/aar-fuel-telemetry-calibration
git pull --ff-only origin agent/aar-fuel-telemetry-calibration

.\tools\build-aar-fuel-telemetry.ps1
```

Der Builder erzeugt:

```text
mission\tests\aar-fuel-telemetry\dist\OMW_AAR_Fuel_Telemetry.lua
```

Der Builder mutiert keine `.miz`.

Die Buildausgabe muss für Test 2 enthalten:

```text
BuilderVersion: AAR-FUEL-TELEMETRY-2
TestId: AAR-FUEL-TELEMETRY-2
CandidateSpawnSpeedKt: 480
ProductionTransitRouteSpeedKt: 300
CandidateScope: SPAWN_INITIAL_SPEED_ONLY
MizMutation: false
```

## Mission Editor

Ausgangspunkt ist die bereits für Test 1 verwendete AAR-Fuel-Telemetry-Mission mit allen sechs KC-135-Templates und dem korrekten gepinnten `Moose.lua`.

Im Mission Editor:

1. den vorhandenen AAR-Fuel-Telemetry-`DO SCRIPT FILE`-Eintrag auf den neu gebauten Bundle verweisen beziehungsweise die Datei neu auswählen;
2. sicherstellen, dass **nur ein** AAR-Testbundle geladen wird;
3. `Moose.lua` unverändert vor dem Telemetrie-Bundle laden;
4. als `DO SCRIPT FILE` auswählen:

```text
P:\DCS-DEV\Operation-Mountain-Watch\mission\tests\aar-fuel-telemetry\dist\OMW_AAR_Fuel_Telemetry.lua
```

5. Mission unter einem neuen Testnamen speichern;
6. keine Templates, Fuel-Werte, Routen, Tracks, Callsigns oder Tanker-Parameter im Mission Editor verändern.

Der separate CREE-Diagnostic kann entfernt werden; er ist für den Fuel-Test 2 nicht erforderlich.

ChatGPT verändert keine `.miz`-Datei.

## Testende

Der Lauf ist beendet, sobald im `dcs.log` steht:

```text
[OMW][AAR-FUEL-TELEMETRY-2] RESULT PASS allTracks=6 samplesPerTrack=3 points=SPAWN,INGRESS,TRACK fuelLowExcluded=true
```

Danach werden für die Auswertung benötigt:

```text
dcs.log
debrief.log
exakte getestete .miz
Screenshots des Spawn- und stabilisierten Transitzustands
Builder-Ausgabe einschließlich GitCommit und BundleSHA256
```

Erst nach Auswertung dieser realen Messdaten wird entschieden, ob `480 kt` als produktiver Initial-Spawn-Speed übernommen wird und wie die Initial-Fuel- sowie FuelLow-Werte neu festgelegt werden. Der Test selbst ändert keine produktive Baseline.