---
document_id: OMW-TEST-TKOT-G8-UH60-NATIVE-VERTICAL-DEPARTURE-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G8 native AIRWING/AUFTRAG UH-60 departure test
  - runtime verification of AIRWING vertical-policy propagation
  - telemetry and visual acceptance boundary for vertical takeoff
not_authoritative_for:
  - landing, return, recovery or inventory restoration
  - COMMANDER or OPSTRANSPORT acceptance
  - tactical transport, MEDEVAC or campaign behavior
  - merge or Ready-for-Review authorization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 585f3c46d4ff0a4b167c984d427bcdb356138e69
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot G8 – nativer UH-60-Vertikalabflug

## 1. Testziel

Der Test muss erstmals den vollständigen nativen MOOSE-Pfad ausführen:

```text
AIRWING mit vor Start gesetzter Vertikaloption
→ genau ein AUFTRAG
→ genau ein AIRWING:AddMission()
→ MOOSE-Auswahl des UH-60-SQUADRON
→ MOOSE-erzeugte FLIGHTGROUP
→ AIRWING FlightOnMission
→ FLIGHTGROUP:SetOptionPreferVertical()
→ tatsächliches Abheben ohne Taxi- oder Runway-Nutzung
```

G7 wird im selben Bundle als Struktur-, Lifecycle- und Objektvertragssmoke ausgeführt. G8 startet erst nach dessen PASS.

## 2. Provenienzvertrag

```yaml
branch: agent/tarinkot-object-contract-reconciliation
main_lifecycle_baseline: cf1b5ff138c6cb5e59e0070f7ba8aef4cfb3823a
mission: OMW_Template_v6_Tarinkot.miz
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
builder: tools/build-tarinkot-air-operations-g8-uh60-vertical-dispatch.ps1
builder_version: TKOT-G8-UH60-VERTICAL-DISPATCH-1
bundle: mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G8_UH60_VerticalDispatch.lua
```

Nach Einbindung und Speichern sind MIZ-, interne Mission-, eingebettete Bundle- und Moose-Hashes neu zu erfassen. Der G7-Hashstand ist historische Evidenz und nicht automatisch der G8-Artefaktstand.

## 3. Verbindliches Mission-Editor-Objekt

Vor Einbindung muss genau diese reale Mission-Editor-Zone vorhanden sein:

```text
ZONE_AIR_US_TKOT_ROTARY_STAGING
```

Anforderungen:

- freie, für einen einzelnen UH-60 geeignete Lande- und Abstellfläche;
- außerhalb der Startplatte und außerhalb aller Client-/Static-Sperrbereiche;
- kein Runway-, Taxiway- oder Gebäudeüberlapp;
- Position und Radius werden vom Missionsdesigner in der MIZ festgelegt und anschließend dokumentiert;
- kein Lua-Fallback und keine synthetische `ZONE_RADIUS`.

Fehlt die Zone, endet G8 kontrolliert mit:

```text
status=BLOCKED
reason=MISSING_MISSION_EDITOR_ZONE_ZONE_AIR_US_TKOT_ROTARY_STAGING
```

Dies ist kein DCS-Funktionsfehler, sondern ein unvollständiger MIZ-Vertrag.

## 4. Operativer Vertrag

```yaml
airwing: AW_US_TKOT_TF_ATTACK_3_101_AVN
squadron: SQ_US_TKOT_UH60_TF_ATTACK
payload_family: UH60
mission_name: OMW-TKOT-G8-UH60-VERTICAL-DISPATCH
mission_type: LANDATCOORDINATE
required_assets: 1
destination_zone: ZONE_AIR_US_TKOT_ROTARY_STAGING
start_delay_seconds: 35
takeoff_timeout_seconds: 240
max_ground_displacement_before_airborne_m: 75
```

Die Mission verwendet ausschließlich:

```lua
AUFTRAG:NewLANDATCOORDINATE(...)
mission:SetRequiredAssets(1, 1)
mission:AssignSquadrons({ squadron })
mission:AddRequiredPayload(payload)
airwing:AddMission(mission)
```

## 5. Verbotene Pfade

G8 darf nicht enthalten:

```text
COMMANDER:New
OPSTRANSPORT:New
SPAWN
FLIGHTGROUP:New
direktes SetOptionPreferVertical auf einer selbst erzeugten FLIGHTGROUP
ZONE_RADIUS:New
SetAIOn
StartUncontrolled
Despawn
Destroy
coalition.addGroup
CampaignState-Mutation
mehr als einen AUFTRAG-Konstruktor
mehr als einen AIRWING:AddMission-Pfad
```

## 6. Statische Freigabe vor DCS

Vor MIZ-Änderung müssen bestehen:

```text
Documentation validation
Tarinkot G7 lifecycle guard
Tarinkot G8 builder guards
```

Der G8-Builder muss ausgeben:

```text
BuilderVersion: TKOT-G8-UH60-VERTICAL-DISPATCH-1
EmbeddedFoundation: TKOT-G7-AIRWING-FOUNDATION-4
LifecycleGuard: PASS via G7 builder
OperationalMissions: 1
Commander: 0
OpsTransport: 0
RawSpawn: 0
StandaloneFlightGroup: 0
SyntheticZones: 0
OwnerVisualConfirmation: required
```

Ohne statischen PASS wird kein DCS-Lauf autorisiert.

## 7. Testbedingungen

```text
Moose.lua zuerst laden
anschließend ausschließlich das aktuelle G8-Bundle laden
ältere Tarinkot-G6/G7-Bundles entfernen
Mission mindestens bis zum Abschlussmarker laufen lassen
Beobachter ausschließlich auf einem hart ausgeschlossenen Tarinkot-Clientplatz
keine F10-Mission und keinen zweiten Auftrag auslösen
```

Zulässiger Beobachter:

```text
TerminalID 20, 8 oder 3
```

Er muss als `detected`, `allowed` und `blocking` korrekt protokolliert werden. Für diesen Test ist insbesondere ein AH-64-Beobachter auf TerminalID 20 zulässig, da die UH-60-Pools ausschließlich `30,27,23` verwenden.

## 8. Erwarteter G7-Vorlauf

Der kombinierte Bundlelauf muss zunächst enthalten:

```text
RESULT G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION status=PASS
```

mit:

```text
airwingRunning=true
squadrons=3
stock=5
rolePayloads=3
totalPayloads=6
opsGroups=0
observerClientsBlocking=0
verticalPolicy=true
```

G8 ist blockiert, wenn G7 nicht PASS meldet.

## 9. Erwartete G8-Marker

Auftragseinbindung:

```text
MISSION_ADDED
name=OMW-TKOT-G8-UH60-VERTICAL-DISPATCH
type=LANDATCOORDINATE
destinationZone=ZONE_AIR_US_TKOT_ROTARY_STAGING
requiredAssets=1
verticalPolicy=true
```

Erwartete AUFTRAG-Progression:

```text
REQUESTED
SCHEDULED
STARTED
```

MOOSE-Übergabemarker:

```text
FLIGHT_ON_MISSION
mission=OMW-TKOT-G8-UH60-VERTICAL-DISPATCH
optionPreferVertical=true
```

Der Marker ist der technische Nachweis, dass die vor `AIRWING:Start()` gesetzte AIRWING-Policy im nativen `FlightOnMission`-Pfad an die von MOOSE verwaltete FLIGHTGROUP übertragen wurde.

## 10. Telemetrie-Acceptance

Bis zum ersten `inAir=true` wird die horizontale Verschiebung gegenüber der initialen Runtimeposition gemessen.

PASS-Telemetrie:

```text
flightOnMission=true
optionPreferVertical=true
inAir=true
maxGroundDisplacementM <= 75
airborneDistanceM <= 75
```

Erwarteter vorläufiger Abschlussmarker:

```text
RESULT G8_UH60_NATIVE_VERTICAL_DEPARTURE
status=PASS_RUNTIME_TELEMETRY_PENDING_OWNER_VISUAL
reason=none
missionAdded=true
flightOnMission=true
optionPreferVertical=true
maxGroundDisplacementM<=75
airborneDistanceM<=75
ownerVisualRequired=true
```

Die 75-Meter-Grenze ist ein Fehlerdetektor gegen eindeutiges Taxi-/Runway-Verhalten. Sie ersetzt nicht die visuelle Prüfung.

## 11. Visuelle Acceptance

Der Projektinhaber muss bestätigen:

```text
UH-60 erscheint auf einer akzeptierten UH-60-Parkingposition
Rotorstart erfolgt dort
kein Rollen über Taxiway oder Runway
Abheben erfolgt unmittelbar von der Parking-/Startfläche
kein Teleport oder Positionssprung
keine Kollision mit Client, Static oder anderem Objekt
```

Erst Telemetrie-PASS plus visuelle Bestätigung ergeben:

```text
PASS_DCS_OWNER_VISUAL_ACCEPTED
```

## 12. FAIL-Kriterien

```text
G7-Vorlauf nicht PASS
AIRWING nicht Running
UH-60-SQUADRON oder Rollen-Payload fehlt
AIRWING-Vertikaloption fehlt
AUFTRAG-Konstruktion oder AddMission scheitert
FlightOnMission wird nicht beobachtet
OptionPreferVertical bleibt false
Mission cancelled/failed vor Abheben
Takeoff-Timeout
Ground displacement > 75 m
sichtbares Taxi- oder Runway-Verhalten
falscher Aircrafttyp
Spawn außerhalb des akzeptierten UH-60-Pools
Lua-/Scheduler-/MOOSE-Fehler im relevanten Laufzeitfenster
```

## 13. Nachweisgrenze

G8 beweist nicht:

```text
sichere Landung am Ziel
Rückkehr nach Tarinkot
Recovery in Warehouse-Stock
Verlustbuchung
Persistenz
MEDEVAC- oder Transportfunktion
COMMANDER-Auswahl
OPSTRANSPORT
Mehrspieler- oder Langzeitstabilität
```

## 14. Gate-Wirkung

```yaml
static_pass_only:
  G8: IMPLEMENTED_AWAITING_MIZ_AND_DCS
runtime_telemetry_pass_only:
  G8: PASS_RUNTIME_PENDING_OWNER_VISUAL
runtime_plus_visual_pass:
  G8: PASS_DCS_OWNER_VISUAL_ACCEPTED
  G9_commander: AUTHORIZED
failure:
  G8: FAIL
  G9_commander: BLOCKED
```
