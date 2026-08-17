---
document_id: OMW-MOOSE-CLASS-INDEX
status: BINDING
document_class: MOOSE_CLASS_REGISTER
owning_policy: OMW-GOV-001
authoritative_for:
  - project MOOSE class statuses
  - planned MOOSE integration candidates
  - scope boundaries of class-level evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - class index without consolidated AIRWING lifecycle evidence
superseded_by:
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
validated_in_dcs: partial
---

# MOOSE-Projektklassenindex

## 1. Zweck

Dieser Index führt den Projektstatus der für **Operation Mountain Watch** relevanten MOOSE-Klassen und Module. Der vollständige frühere Klassenindex bleibt als Source-Evidence erhalten:

- [`Legacy-MOOSE-Klassenindex`](../evidence/source-records/legacy-moose-project-class-index.md)

Technische Lifecycle-Details:

- [`OMW-MOOSE-AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE`](AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE.md)
- [`OMW-MOOSE-VERIFIED-METHODS`](VERIFIED-METHODS.md)
- [`OMW-MOOSE-VERIFIED-METHODS-AAR-ACCEPTANCE-7`](VERIFIED-METHODS-AAR-ACCEPTANCE-7.md)
- [`OMW-MOOSE-STORAGE-WAREHOUSE-RESOURCE-FOUNDATION`](STORAGE-WAREHOUSE-RESOURCE-FOUNDATION.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](ISR-FAC-CAS-AAR.md)
- [`OMW-MOOSE-AAR-LRC-TRANSIT`](AAR-LRC-TRANSIT.md)
- [`OMW-AIR-TASKING-PLAN-PHASE2-CHIEF-VERIFICATION`](../air-tasking-plan-phase2-chief-capability-verification.md)

## 2. Statusbedeutung

```text
CANDIDATE
PLANNED
IN_USE_PARTIAL
VALIDATED_FOR_DOCUMENTED_SCOPE
VALIDATED_CONFIGURATION_AND_SOURCE_PATH
SOURCE_REVIEWED
INTERNAL_RESTRICTED
REJECTED_FOR_PROJECT_USE
```

## 3. Aktuell besonders relevante Klassen

| Klasse | Projektstatus | Geltungsgrenze |
|---|---|---|
| `AIRBASE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Auflösung, ID, Parkingdump und airfield-spezifische Kalibrierung |
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, Stockregistrierung, SQUADRON-Bindung und direkter AUFTRAG-Dispatch; externe OMW-AAR-Pools verwenden bewusst kein AIRWING |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Foundation-Bestände und post-start Assetbindung |
| `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AirOps-Stock-/Asset-Lifecycle; kein WAREHOUSE für externe MANAS-/AL_UDEID-AAR-count-Pools |
| `STORAGE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | CampaignState->DCS-Warehouse Mirror/Telemetry; keine strategische Rückautorität |
| `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Asset-/Mission-Capability-Pfade für dokumentierte AirOps-Foundations |
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR FuelLow, Dead/OnAfterDead, GetCoordinate, `AddWaypoint(...)`, `AddMission(...)` und `OnAfterPassingWaypoint(...)`; Acceptance 7 bestätigte FIR -> 60-NM -> AUFTRAG sowie Egress -> External Handoff |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | dokumentierter COMMANDER-Lifecycle; nicht Quelle der externen OMW-AAR-Pools |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR `NewTANKER`, `SetMissionAltitude`, Mission-Egress und `Cancel()` praktisch bestätigt; finaler Inbound fügt AUFTRAG erst nach Passage des 60-NM-Wegpunkts hinzu |
| `SPAWN` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | area-spezifische AAR-Templates, stabile Sortie-Callsign-Familie und 480-kt-In-Air-Materialisierung praktisch bestätigt; keine erzwungene `InitSTN()`, keine nachgewiesene `InitFuel()`-API |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Source-Queue, Station-Monitoring und Acceptance-Koordination; kein Timer-basierter Late-Approach |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Readiness-Pfade |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-/Static-/Warehouse-/Zonenvalidierung; AAR `UNIT:GetSTN()` und test-only `UNIT:Explode()` bestätigt. `UNIT:GetFuel()`, `UNIT:GetCurrentFuelKgs()` und `UNIT:GetFuelMassMax()` wurden in realen AAR-Fuel-Telemetry-Läufen verwendet. |
| `COORDINATE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `Get2DDistance(...)` praktisch verwendet; `GetIntermediateCoordinate(...)` und `HeadingTo(...)` im Acceptance-7-AAR-Pfad praktisch bestätigt |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` / teilweise validiert | Bodenoperationsscope bleibt geplant; für AAR sind Despawn, Radio-/TACAN-Switch und PassingWaypoint-FSM im dokumentierten Scope praktisch bestätigt |
| `OPSTRANSPORT` | `PLANNED` | taktischer Transport |
| `CTLD`, `CSAR`, `AICSAR` | `PLANNED` / teilweise verwendet | separate Acceptance erforderlich |
| `INTEL` | `PLANNED` | taktisches Lagebild; Laufzeitnachweis offen |
| `INTEL_DLINK` | `CANDIDATE` | Aggregation getrennter Netze; Performance offen |
| `PLAYERRECCE` | `CANDIDATE` | spielergeführte Aufklärung; Multiplayerprüfung offen |
| `TARS` | `CANDIDATE` | verzögerte Foto-/IMINT-Aufklärung; Verfügbarkeit offen |
| `DETECTION_*` | `PLANNED` | Spezialfälle; kein paralleles strategisches Lagebild neben `INTEL` |
| `Core.Astar`, `PATHLINE`, `MOVEMENT` | `PLANNED` | Routing und Bewegungsbegrenzung |
| `_DATABASE` | `INTERNAL_RESTRICTED` | nur Diagnose/Validierung; aktueller AAR-Produktionspfad verwendet `_DATABASE` nicht |
| `CHIEF` | `REJECTED_FOR_PROJECT_USE` | Air-Tasking-Phase-2 am Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54` source-geprüft: erzeugt eigenen `COMMANDER`, erweitert `INTEL` und trägt Strategy/DEFCON/Target-/Strategic-Zone-/ResponseOnTarget-Semantik; für OMW wegen Überschneidung mit CampaignState/MissionDemand/Air-Tasking-Autorität `NOT_USED`, ohne eigene CHIEF-Nachbildung |

## 4. AAR – gepinnter und Acceptance-7-validierter MOOSE-Scope

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Acceptance-7-Provenienz:

```text
Accepted source commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
Builder/Test-ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-7
Mission artifact: OMW_Template_v10_AirOps_rdy(5).miz
Mission SHA-256: 16d0a9b26a648c2dbcbd727b41afc93a28648620f8e2f8c357a770751e48cca5
Bundle SHA-256: 3338d0baa67593be6bff9c22b3ed72b3a8e837cd00820d060eefe920faf91ee2
DCS: 2.9.28.26385 MT
Result: PASS
```

Für den dokumentierten AAR-Scope sind source-geprüft und, soweit unten genannt, praktisch bestätigt:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

SPAWN:InitCallSign(...)
SPAWN:InitHeading(...)
SPAWN:InitSpeedKnots(...)
SPAWN:SpawnFromCoordinate(...)
UNIT:GetSTN()
UNIT:Explode(...) [test-only]
GROUP:GetCallsign()

FLIGHTGROUP:New(...)
FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP FuelLow callback
FLIGHTGROUP Dead/OnAfterDead FSM event
FLIGHTGROUP:GetCoordinate()
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:AddMission(...)
FLIGHTGROUP/OPSGROUP PassingWaypoint FSM event
FLIGHTGROUP OnAfterPassingWaypoint callback override

OPSGROUP:SwitchRadio(...)
OPSGROUP:TurnOffRadio()
OPSGROUP:SwitchTACAN(...)
OPSGROUP:TurnOffTACAN()
OPSGROUP:Despawn(...)

COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:Get2DDistance(...)
COORDINATE:HeadingTo(...)
SCHEDULER:New(...)

UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
```

`FLIGHTGROUP:AddWaypoint(...)` plus `OnAfterPassingWaypoint(...)` ist jetzt für die strikt gestufte Inbound-Folge praktisch bestätigt:

```text
SPAWN
-> FIR waypoint at inbound LRC altitude
-> 60-NM late-approach waypoint at inbound LRC altitude
-> PassingWaypoint FIR
-> PassingWaypoint 60 NM
-> FLIGHTGROUP:AddMission(AUFTRAG)
-> exact track altitude
```

`COORDINATE:GetIntermediateCoordinate(...)` berechnet den 60-NM-Punkt; Acceptance 7 bestätigte die 60.0-NM-Geometrie. `AUFTRAG:SetMissionIngressCoord(lateApproachCoord, ...)` ist für diesen finalen Inbound-Pfad verworfen, weil der erste Acceptance-7-Lauf zeigte, dass ein früh hinzugefügter AUFTRAG den FIR-Wegpunkt umgehen konnte.

Im gepinnten `Moose.lua` wurde keine öffentliche `SPAWN:InitFuel(...)`-Methode nachgewiesen. Physische Initial-Fuel-Mengen bleiben Template-/Mission-Editor-Konfiguration.

### 4.1 LRC-/Fuel-Kalibrierung und Fehlerhistorie

```text
Candidate 3:
REJECTED — FIR-Ingress durch Late-Approach ersetzt.

Candidate 4:
FIR restoration observed PASS; UID late-approach adapter FAILED.

Candidate 5:
Outbound six-point fuel telemetry PASS.

Acceptance 6:
Lifecycle/calibration PASS for documented scope; early inbound descent remained open.

Acceptance 7 commit 00ed8e3:
ABORTED — 60-NM altitude behavior worked but FIR waypoint was bypassed.

Corrected Acceptance 7 commit 7d55a13:
PASS — exact FIR-before-60NM-before-AUFTRAG order, high-hold, track altitude, LISA south-domain and lifecycle.
```

LISA accepted contract:

```text
AL_UDEID / DAVER
initialFuelPct = 79.4558
FuelLow = 38
```

Details und Rechnungen:

- [`OMW-MOOSE-AAR-LRC-TRANSIT`](AAR-LRC-TRANSIT.md)
- [`OMW-MOOSE-VERIFIED-METHODS-AAR-ACCEPTANCE-7`](VERIFIED-METHODS-AAR-ACCEPTANCE-7.md)
- [`AAR Production Final Acceptance 7`](../../mission/tests/aar-production-integration/ACCEPTANCE-7.md)

## 5. AAR-Produktionsscope

```text
STANDARD / kontinuierlich:
NELSON FAST
PATTY SLOW
MILHOUSE SLOW
KRUSTY SLOW

RESERVE / MissionDemand:
LISA FAST
MOE FAST

kein globales 2/2/4-AAR-Limit
pro Track max. 1 ACTIVE + 1 RELIEF
Callsign-Familie bleibt pro Sortie stabil
```

FIR-/Source-Routing:

```text
NELSON/PATTY    -> MANAS / EGPAN
MOE             -> MANAS / PINAX
LISA            -> AL_UDEID / DAVER
KRUSTY/MILHOUSE -> AL_UDEID / DAVER

External Spawn != FIR Ingress
FIR Ingress != 60-NM Late Approach
FIR Egress != External Handoff/Despawn
Airways-Routing = später / nicht Teil der Baseline
```

Acceptance 7 bestätigte für die exakte Provenienz:

```text
spawn initial speed = 480 kt
route speed = 300 kt
MANAS inbound/outbound = FL340/FL350
AL_UDEID inbound/outbound = FL350/FL340
inbound order = SPAWN -> FIR -> 60-NM late approach -> AUFTRAG/track
exact track mission altitude
initial fuel MANAS = 91.4067 %
initial fuel AL_UDEID = 79.4558 %
FuelLow NELSON/PATTY/LISA/MOE/MILHOUSE/KRUSTY = 24/26/38/31/36/36 %
LISA = AL_UDEID / DAVER
Scheduled Relief
FuelLow Immediate Egress + Relief
Reserve MissionDemand lifecycle
Loss/Replacement
CampaignState exact-once settlement
final steady state = 4 STANDARD / 0 RESERVE
```

## 6. Architekturgrenze

Die externen AAR-Pools MANAS und AL UDEID sind keine DCS-Airbase-/WAREHOUSE-/AIRWING-/SQUADRON-Bestände. CampaignState hält `AIRCRAFT_KC135` als count; SPAWN -> FLIGHTGROUP -> AUFTRAG materialisiert nur die physische Repräsentation.

Test-only Artificial FuelLow, `UNIT:Explode()`-Loss-Injection, Acceptance-Zeitbeschleunigung und in-process Restore gehören nicht in das endgültige Missionsgrundgerüst.

## 7. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn MOOSE-Version/Commit, OMW-Source, Mission, Hashes, beobachtetes Verhalten und Einschränkungen dokumentiert sind. `VALIDATED_FOR_DOCUMENTED_SCOPE` für den neuen AAR-Routingpfad gilt ausschließlich für die oben dokumentierte Acceptance-7-Provenienz und darf nicht pauschal auf andere MOOSE-/DCS-/Missionsstände übertragen werden.
