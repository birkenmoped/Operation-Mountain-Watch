---
document_id: OMW-TEST-AAR-FUEL-TELEMETRY
status: DRAFT
document_class: TEST_MANIFEST
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local AAR fuel telemetry test scope
  - build and Mission Editor insertion procedure for AAR fuel calibration
  - interpretation boundaries of SPAWN, INGRESS and TRACK fuel measurements
not_authoritative_for:
  - revised production initial fuel values
  - revised FuelLow thresholds
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

Dieser Test erfasst für die erste natürliche Sortie aller sechs produktiven AAR-Tracks drei voneinander unabhängige Fuel-Messpunkte:

```text
1. SPAWN
2. FIR INGRESS
3. TRACK ENTRY
```

`FuelLow` wird bewusst **nicht** als Messpunkt verwendet. Die aktuellen FuelLow-Schwellen sind selbst Teil der späteren Neukalibrierung und dürfen daher nicht als Eingangsdaten für diese Messung dienen.

Der Test verändert keine produktiven Fuel-Werte. Er misst nur den von DCS/MOOSE tatsächlich gemeldeten Zustand der existierenden Tanker-Sorties.

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

Für die Telemetrie werden ausschließlich vorhandene öffentliche MOOSE-Funktionen verwendet:

```text
UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
FLIGHTGROUP:GetCoordinate()
COORDINATE:Get2DDistance(...)
SCHEDULER:New(...)
```

`UNIT:GetFuel()` liefert laut gepinntem `Moose.lua` den relativen DCS-Fuelwert und kann bei externen Tanks größer als `1.0` sein. Der Rohwert wird daher nicht geklemmt. Zusätzlich werden, soweit von MOOSE verfügbar, Fuelmasse in kg und maximale Fuelmasse protokolliert.

Eine spezielle offizielle Demo ist für diese reine Wrapper-Telemetrie nicht erforderlich; die verwendeten Methoden sind direkte öffentliche Wrapper-/Coordinate-/Scheduler-Funktionen. Die tatsächliche DCS-Messbarkeit in diesem OMW-Test bleibt bis zum Lauf `validated_in_dcs: false`.

## Messgeometrie

Die produktive AAR-Logik verwendet aktuell:

```text
FIR fix radius:   5 NM
Track entry radius: 5 NM
```

Der Telemetrie-Harness misst INGRESS und TRACK mit denselben Radien. Zusätzlich protokolliert er die reale Distanz zum jeweiligen Referenzpunkt im Messmoment.

Für jede Sortie werden außerdem zwei Entfernungsarten ausgegeben:

```text
plannedFirToTrackNm
= geometrische produktive Referenzdistanz zwischen FIR-Fix und Track-Zentrum

pathIngressToTrackNm
= aus 1-s-MOOSE-Positionssamples aufsummierter tatsächlich beobachteter DCS-Flugweg
```

Damit kann die spätere Fuel-Kalibrierung sowohl die feste Missionsgeometrie als auch den tatsächlich geflogenen Weg berücksichtigen.

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
pathSpawnIngressNm
pathIngressTrackNm
plannedFirTrackNm
timeSpawnIngressSec
timeIngressTrackSec
```

Der SPAWN-Wert wird beim ersten Poll nach Materialisierung gelesen. `sampleDelaySec` dokumentiert die Verzögerung zwischen `materializedAt` und tatsächlichem Fuel-Sample. Bei `POLL_SEC = 1` ist damit die Unsicherheit des Spawn-Samples explizit sichtbar.

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

## Mission Editor

Ausgangspunkt ist eine Kopie der zuletzt funktionierenden AAR-Testmission mit allen sechs KC-135-Templates und dem korrekten gepinnten `Moose.lua`.

Im Mission Editor:

1. den vorhandenen `DO SCRIPT FILE`-Eintrag des alten AAR-Acceptance-Bundles entfernen oder auf den neuen Telemetrie-Bundle umstellen;
2. sicherstellen, dass **nur ein** AAR-Testbundle geladen wird;
3. `Moose.lua` unverändert vor dem Telemetrie-Bundle laden;
4. als `DO SCRIPT FILE` auswählen:

```text
P:\DCS-DEV\Operation-Mountain-Watch\mission\tests\aar-fuel-telemetry\dist\OMW_AAR_Fuel_Telemetry.lua
```

5. Mission unter einem neuen Testnamen speichern;
6. keine Templates, Fuel-Werte, Routen, Tracks, Callsigns oder Tanker-Parameter im Mission Editor verändern.

ChatGPT verändert keine `.miz`-Datei.

## Testende

Der Lauf ist beendet, sobald im `dcs.log` steht:

```text
[OMW][AAR-FUEL-TELEMETRY-1] RESULT PASS allTracks=6 samplesPerTrack=3 points=SPAWN,INGRESS,TRACK fuelLowExcluded=true
```

Danach werden für die Auswertung benötigt:

```text
dcs.log
debrief.log
exakte getestete .miz
Builder-Ausgabe einschließlich GitCommit und BundleSHA256
```

Erst nach Auswertung dieser realen Messdaten werden neue Initial-Fuel- und FuelLow-Werte berechnet. Der Test selbst ändert diese produktiven Werte nicht.
