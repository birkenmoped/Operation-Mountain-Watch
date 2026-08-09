---
document_id: OMW-TEST-TKOT-G8-UH60-PASS-WITH-HARNESS-LIMITATION-2026-08-09
status: DRAFT
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G8-2 DCS runtime result on 2026-08-09
  - validated revised Tarinkot parking object contract for the recorded artifact chain
  - G8 takeoff-timeout root cause and G8-3 harness correction requirement
not_authoritative_for:
  - accepted vertical departure
  - owner visual acceptance
  - landing, recovery or persistent inventory
  - merge or Ready-for-Review authorization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-revised-parking-layout
source_commit: 8af4c00b78e845b4803e18cc591e7ac382edccd0
validated_in_dcs: true
supersedes: []
superseded_by: []
---

# Tarinkot G8-2 – UH-60 PASS mit Harness-Einschränkung

## 1. Ergebnis

```yaml
classification: PASS_WITH_LIMITATION
gate: G8_UH60_NATIVE_VERTICAL_DEPARTURE
reason: TAKEOFF_TIMEOUT
G7_object_contract: PASS
native_airwing_auftrag_dispatch: PASS
flight_on_mission: PASS
vertical_option_propagated: PASS
takeoff_inside_telemetry_window: FALSE_NEGATIVE_TIMEOUT
takeoff_after_telemetry_finalization: CONFIRMED_BY_DEBRIEF
vertical_departure_geometry: OWNER_VISUALLY_CONFIRMED
destination_landing: OWNER_VISUALLY_CONFIRMED_AND_DEBRIEF_CONFIRMED
owner_visual_acceptance: CONFIRMED
```

Der automatische G8-Endmarker ist ein False Negative: Der Test finalisierte bei
240 Sekunden ab `AIRWING:AddMission()` mit `inAir=false`, bevor der normale
Kaltstart beendet war. Der Debrief belegt den anschließenden Takeoff und die
Landung. Der Projektinhaber bestätigte visuell genau eine UH-60, vertikalen
Abflug ohne Taxiweg, Flug zum vorgesehenen Ort und Außenlandung. Damit ist der
fachliche G8-Pfad bestanden; die Einschränkung betrifft die unvollständige
numerische Abflugtelemetrie des zu früh beendeten Harnesses.

## 2. Provenienz

```text
Testdatum:                2026-08-09
DCS:                      2.9.28.26385 MT
Branch:                   agent/tarinkot-revised-parking-layout
Remote Source-Commit:     8af4c00b78e845b4803e18cc591e7ac382edccd0
Builder-Version G7:       TKOT-G7-AIRWING-FOUNDATION-5
Builder-Version G8:       TKOT-G8-UH60-VERTICAL-DISPATCH-2
Mission:                  OMW_Template_v6_Tarinkot.miz
MIZ SHA-256:              c750d84ebe659b9ceaec3a7a7f794db3154f3d5b70524f2df8704eb727673cfc
interner mission SHA-256: 14d2d9adc99aed88f1fc5037d5c5cb29b41018e12b249e7934cfb805f1d0b710
Bundle SHA-256:           3e182ef2550e58466cfce4adbdedab4501a0820b22808b7973f11df9a03104d0
MOOSE Release:            2.9.18
MOOSE Commit:             73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:        e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS-Log SHA-256:          2d003b974d6cd394d929b1954f297379b45549fdf79d5df8a54a000d1d420f3e
Debrief SHA-256:          8a1c3d86c5718b6898e662a832dd2ff67c307f274f9748450865cc1b444b7f5a
Observer-Client:          CLIENT_US_TKOT_AH64D_01_UNIT_01 / Neues Rufz.
```

Die hochgeladene MIZ lädt `Moose.lua` als erste Startaktion. Das aktuelle G8-Bundle
ist genau einmal als Startaktion 10 eingebunden. Es ist kein älteres Tarinkot-G6-,
G7- oder G8-Bundle parallel eingebettet. Andere Flugplatz- und Projektskripte
bleiben Bestandteil der Arbeitsmission.

## 3. Objektvertragssmoke

Der eingebettete G7-5-Vorlauf meldete:

```text
Tarinkot Airbase: name=Tarinkot id=9
Warehouse: WH_AIR_US_TARINKOT found
Parkingcount: 33
AH-64 pool: 20,19 free=true accepted=true
UH-60 pool: 23,27,30 free=true accepted=true
CH-47 pool: 32,29,10 free=true accepted=true
Static contract: 12/12
Templates: AH-64 2 units; UH-60 1 unit; CH-47 1 unit
Observer clients: detected=1 allowed=1 blocking=0
```

Abschluss:

```text
RESULT G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION status=PASS
violations=0
airwingRunning=true
stock=5
parkingIDs=8
verticalPolicy=true
```

Damit ist der revidierte Parkplatz- und Lifecycle-Vertrag für genau diese
Artefaktkette im DCS bestätigt.

## 4. G8-Laufzeitfolge

```text
MISSION_ADDED
AUFTRAG REQUESTED
AUFTRAG SCHEDULED
FLIGHT_ON_MISSION
AUFTRAG STARTED
```

Die Runtimegruppe lautete:

```text
SQ_US_TKOT_UH60_TF_ATTACK_AID-95
SQ_US_TKOT_UH60_TF_ATTACK_AID-95-01
```

Beim `FlightOnMission`-Callback waren bestätigt:

```text
mission=OMW-TKOT-G8-UH60-VERTICAL-DISPATCH
missionType=Land at Coordinate
optionPreferVertical=true
initialX=-149059.82825936
initialY=1356.9160400049
initialZ=-30985.550638905
```

Bis zum Harnessabschluss blieb die Einheit unverändert:

```text
elapsed=240.0
inAir=false
displacementM=0.0
maxGroundDisplacementM=0.0
speedMps=0.0
missionState=started
```

Finaler G8-Marker:

```text
RESULT G8_UH60_NATIVE_VERTICAL_DEPARTURE
status=FAIL
reason=TAKEOFF_TIMEOUT
missionAdded=true
flightOnMission=true
optionPreferVertical=true
maxGroundDisplacementM=0.0
airborneDistanceM=-1.0
```

## 5. Spätere Debrief-Ereignisse

Der Testlauf wurde nach dem G8-Finalmarker nicht sofort beendet. Der Debrief enthält
für dasselbe dynamische UH-60-Objekt:

```text
engine startup: t=147.504
takeoff Tarinkot: t=311.504
land: t=473.954
mission end: t=758.573
```

Der G8-Log meldete nach dem FAIL zusätzlich:

```text
AUFTRAG EXECUTING
AUFTRAG DONE
AUFTRAG SUCCESS
```

Der Takeoff erfolgte ungefähr 242,5 Sekunden nach der Runtimezuweisung und etwa
36,5 Sekunden nach dem bisherigen Harnessabschluss. Zusammen mit der visuellen
Bestätigung belegen diese Ereignisse den vertikalen Abflug ohne Taxiweg, den Flug
zum Ziel und die Außenlandung. Nicht verfügbar bleibt nur ein nach dem Takeoff
automatisch ausgegebener numerischer `airborneDistanceM`-Wert.

## 6. Root Cause

Der bisherige Harness verwendete ein gemeinsames 240-Sekunden-Fenster ab
`AIRWING:AddMission()`. Darin lagen sowohl die MOOSE-Zuweisung der Runtimegruppe
als auch Engine startup und Takeoff. Der beobachtete UH-60 benötigte länger als
dieses Gesamtfenster.

Die Korrektur trennt künftig:

```yaml
flight_assignment_timeout_seconds: 180
takeoff_timeout_after_flight_on_mission_seconds: 360
takeoff_primary_event: FLIGHTGROUP.OnAfterTakeoff
ground_displacement_poll_seconds: 2
```

Der Takeoff-Timeout beginnt erst mit `FlightOnMission`. Der im gepinnten MOOSE-
Stand vorhandene native `FLIGHTGROUP:OnAfterTakeoff`-FSM-Callback wird zum
primären Abschlussimpuls. Das DCS-`inAir()`-Polling bleibt zur Positionsmessung
und als enger Fallback erhalten.

## 7. Nebenbefunde

- Im relevanten Missionslauf wurde kein Lua-/Schedulerfehler des Tarinkot-Bundles
  protokolliert.
- MOOSE meldete wiederholt unbekannte DCS-Event-Metadaten für Event-ID 61. Dieser
  Befund verursachte im vorliegenden Log keinen Abbruch des G8-Pfads, bleibt aber
  ein separater Kompatibilitätshinweis für DCS 2.9.28 und MOOSE 2.9.18.
- Der `bhHook.lua`-Fehler zu einem nil-`tcp` trat erst beim Stoppen der Mission auf
  und ist nicht Teil der G8-Root-Cause.

## 8. Nächster Schritt

Ein erneuter isolierter UH-60-Lauf ist nicht erforderlich. Der korrigierte
Timeout-/Callbackpfad wird in den gebündelten Folgetest übernommen. Dieser muss
alle fünf registrierten Tarinkot-KI-Gruppen in einem DCS-Lauf prüfen:

```text
2 AH-64-Zweiergruppen
2 UH-60-Einzelgruppen
1 CH-47-Einzelgruppe
native AIRWING-/AUFTRAG-Zuweisung
FLIGHTGROUP OnAfterTakeoff oder eng korrelierter inAir-Fallback je Gruppe
kein Taxi-/Runway-Abflug
keine Parking-, Static- oder Clientkollision
eindeutige gruppenbezogene Telemetrie
```

G9 bleibt bis zum gebündelten Folgetest blockiert.
