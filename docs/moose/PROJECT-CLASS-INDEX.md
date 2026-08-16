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
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE-Projektklassenindex

## 1. Zweck

Dieser Index führt den Projektstatus der für **Operation Mountain Watch** relevanten MOOSE-Klassen und Module. Der vollständige frühere Klassenindex bleibt als Source-Evidence erhalten:

- [`Legacy-MOOSE-Klassenindex`](../evidence/source-records/legacy-moose-project-class-index.md)

Technische Lifecycle-Details:

- [`OMW-MOOSE-AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE`](AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE.md)
- [`OMW-MOOSE-VERIFIED-METHODS`](VERIFIED-METHODS.md)
- [`OMW-MOOSE-STORAGE-WAREHOUSE-RESOURCE-FOUNDATION`](STORAGE-WAREHOUSE-RESOURCE-FOUNDATION.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](ISR-FAC-CAS-AAR.md)
- [`OMW-MOOSE-AAR-LRC-TRANSIT`](AAR-LRC-TRANSIT.md)

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
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR FuelLow, Dead/OnAfterDead, GetCoordinate und `AddWaypoint(...)` für FIR-Egress -> External Handoff praktisch bestätigt; Candidate-4-Late-Approach über public waypoint getters + `AddWaypoint(...)` ist fehlgeschlagen und nicht validiert |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | dokumentierter COMMANDER-Lifecycle; nicht Quelle der externen OMW-AAR-Pools |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR `NewTANKER`, Mission-Ingress/-Egress, `Cancel()` sowie `SetMissionAltitude(...)` für den Candidate-5-Exact-Track-Altitude-Scope praktisch bestätigt; Candidate-4-UID-Late-Approach bleibt nicht validiert |
| `SPAWN` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | area-spezifische AAR-Templates, stabile Sortie-Callsign-Familie und Candidate-5-480-kt-In-Air-Materialisierung praktisch bestätigt; keine erzwungene `InitSTN()`, keine nachgewiesene `InitFuel()`-API |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Source-Queue, Station-Monitoring und Acceptance-Koordination; Candidate-4-UID-Timing für Late-Approach nicht validiert |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Readiness-Pfade |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-/Static-/Warehouse-/Zonenvalidierung; AAR `UNIT:GetSTN()` und test-only `UNIT:Explode()` bestätigt. `UNIT:GetFuel()`, `UNIT:GetCurrentFuelKgs()` und `UNIT:GetFuelMassMax()` wurden in realen AAR-Fuel-Telemetry-Läufen verwendet. |
| `COORDINATE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` / teilweise `SOURCE_REVIEWED` | `Get2DDistance(...)` im AAR-Scope praktisch verwendet; Late-Approach-Kombination bleibt nicht validiert |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` / teilweise validiert | Bodenoperationsscope bleibt geplant; für AAR sind Despawn sowie Radio-/TACAN-Switch praktisch korreliert; Candidate-4-Waypoint-getter-Kombination nicht validiert |
| `OPSTRANSPORT` | `PLANNED` | taktischer Transport |
| `CTLD`, `CSAR`, `AICSAR` | `PLANNED` / teilweise verwendet | separate Acceptance erforderlich |
| `INTEL` | `PLANNED` | taktisches Lagebild; Laufzeitnachweis offen |
| `INTEL_DLINK` | `CANDIDATE` | Aggregation getrennter Netze; Performance offen |
| `PLAYERRECCE` | `CANDIDATE` | spielergeführte Aufklärung; Multiplayerprüfung offen |
| `TARS` | `CANDIDATE` | verzögerte Foto-/IMINT-Aufklärung; Verfügbarkeit offen |
| `DETECTION_*` | `PLANNED` | Spezialfälle; kein paralleles strategisches Lagebild neben `INTEL` |
| `Core.Astar`, `PATHLINE`, `MOVEMENT` | `PLANNED` | Routing und Bewegungsbegrenzung |
| `_DATABASE` | `INTERNAL_RESTRICTED` | nur Diagnose/Validierung; aktueller AAR-Produktionspfad verwendet `_DATABASE` nicht |
| `CHIEF` | `REJECTED_FOR_PROJECT_USE` | aktuelle Produktionsarchitektur `NOT_USED` |

## 4. AAR – gepinnter und akzeptierter MOOSE-Scope

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für den AAR-Scope sind im tatsächlich gepinnten `Moose.lua` geprüft und für den jeweils dokumentierten Einsatz praktisch bestätigt:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

SPAWN:InitCallSign(...)
SPAWN:InitSpeedKnots(...)
SPAWN template-STN collision handling
UNIT:GetSTN()
UNIT:Explode(...) [test-only]
GROUP:GetCallsign()

FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP FuelLow callback
FLIGHTGROUP Dead/onafterDead FSM event
OnAfterDead callback override
FLIGHTGROUP:GetCoordinate()
FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)

OPSGROUP:SwitchRadio(...)
OPSGROUP:TurnOffRadio()
OPSGROUP:SwitchTACAN(...)
OPSGROUP:TurnOffTACAN()
OPSGROUP:Despawn(...)

COORDINATE:Get2DDistance(...)
SCHEDULER:New(...)

UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
```

`UNIT:GetFuel()` liefert den relativen Fuelwert; externe Tanks können Werte größer als `1.0` ergeben. Die Telemetrie klemmt diesen Wert nicht.

`FLIGHTGROUP:AddWaypoint(...)` wird im akzeptierten Produktionspfad nach physischer FIR-Egress-Passage verwendet, um den getrennten External-Handoff-Punkt anzufügen.

`OPSGROUP:SwitchCallsign(...)` ist verfügbar, wird im korrigierten AAR-Produktionspfad aber nicht zum Wechsel zwischen Transit- und Track-Callsign verwendet.

Im gepinnten `Moose.lua` wurde keine öffentliche `SPAWN:InitFuel(...)`-Methode nachgewiesen. Die physische Initial-Fuel-Menge bleibt deshalb Template-/Mission-Editor-Konfiguration und wird nicht durch eine erfundene MOOSE- oder Native-DCS-Parallellogik gesetzt.

### 4.1 LRC-/Fuel-Kalibrierung

Candidate 3 ersetzte den FIR-Ingress durch einen Late-Approach und wurde nach realer Routingregression verworfen.

Candidate 4 stellte `SetMissionIngressCoord(EGPAN/PINAX/DAVER, ...)` wieder her und bestätigte die sechs zugeordneten FIR-Passagen. Der zusätzliche UID-basierte Late-Approach scheiterte und ist nicht validiert.

Candidate 5 verwendete dagegen ohne Late-Approach:

```text
SPAWN:InitSpeedKnots(480)
route speed 300 kt
directional FL340/FL350
AUFTRAG:SetMissionAltitude(profile.altitudeFt)
accepted FIR ingress/egress
existing External Handoff lifecycle
```

Der dokumentierte DCS-Lauf vom 16.08.2026 erreichte für alle sechs Tracks `SPAWN, INGRESS, TRACK, TRACK_DEPARTURE, FIR_EGRESS, EXTERNAL_HANDOFF` und endete mit `RESULT PASS`. Damit sind `SPAWN:InitSpeedKnots(480)` und `AUFTRAG:SetMissionAltitude(...)` für diesen exakten Calibration-Scope praktisch bestätigt. Die anschließend promovierte Produktionsquelle benötigt weiterhin einen eigenen DCS-Acceptance-Lauf.

Details: [`OMW-MOOSE-AAR-LRC-TRANSIT`](AAR-LRC-TRANSIT.md).

## 5. Akzeptierter AAR-Produktionsscope

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

FIR-Fix-Routing:

```text
NELSON/PATTY    -> EGPAN
KRUSTY/MILHOUSE -> DAVER
LISA/MOE        -> PINAX

External Spawn != FIR Ingress
FIR Egress != External Handoff/Despawn
Airways-Routing = später / nicht Teil der akzeptierten Baseline
```

Praktisch bestätigt sind für den exakt dokumentierten Production-Final-Acceptance-Stand insbesondere Scheduled Relief, Radio/TACAN-Transfer, FuelLow Immediate Egress, CampaignState exact-once Settlement, Loss/Replacement und Restore-Reconciliation. Dessen genaue Provenienz steht in `VERIFIED-METHODS.md`.

Für die neu promovierte LRC-/Fuel-Konfiguration gelten zusätzlich als **Production Candidate, DCS acceptance pending**:

```text
spawn initial speed = 480 kt
route speed = 300 kt
MANAS inbound/outbound = FL340/FL350
AL_UDEID inbound/outbound = FL350/FL340
exact track mission altitude = enabled
initial fuel contract MANAS = 91.4067 %
initial fuel contract AL_UDEID = 79.4558 %
FuelLow NELSON/PATTY/LISA/MOE/MILHOUSE/KRUSTY = 24/26/35/31/36/36 %
```

## 6. Architekturgrenze

Die externen AAR-Pools MANAS und AL UDEID sind keine DCS-Airbase-/WAREHOUSE-/AIRWING-/SQUADRON-Bestände. CampaignState hält `AIRCRAFT_KC135` als count; SPAWN -> FLIGHTGROUP -> AUFTRAG materialisiert nur die physische Repräsentation.

## 7. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn MOOSE-Version/Commit, OMW-Source, Mission, Hashes, beobachtetes Verhalten und Einschränkungen dokumentiert sind. `VALIDATED` wird nicht aus Source-Review abgeleitet. Ein Calibration-PASS validiert nicht automatisch die anschließend geänderte Produktionsquelle.