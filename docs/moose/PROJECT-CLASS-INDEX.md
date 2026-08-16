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
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` / neuer AAR-Scope `SOURCE_REVIEWED` | AAR FuelLow, Dead/OnAfterDead, GetCoordinate und `AddWaypoint(...)` für FIR-Egress -> External Handoff praktisch bestätigt; `AddWaypoint(...)` plus `OnAfterPassingWaypoint(...)` für die strikt gestufte Folge FIR -> 60-NM-Late-Approach -> AUFTRAG sind source-reviewed und Acceptance-7-pending |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | dokumentierter COMMANDER-Lifecycle; nicht Quelle der externen OMW-AAR-Pools |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` / neuer AAR-Scope `SOURCE_REVIEWED` | AAR `NewTANKER`, Mission-Egress, `Cancel()` sowie `SetMissionAltitude(...)` praktisch bestätigt; im korrigierten Candidate wird AUFTRAG erst nach bestätigter Passage des 60-NM-Wegpunkts hinzugefügt, damit es den FIR-Wegpunkt nicht überschreiben kann |
| `SPAWN` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | area-spezifische AAR-Templates, stabile Sortie-Callsign-Familie und 480-kt-In-Air-Materialisierung praktisch bestätigt; keine erzwungene `InitSTN()`, keine nachgewiesene `InitFuel()`-API |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Source-Queue, Station-Monitoring und Acceptance-Koordination; kein Timer-basierter Late-Approach |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Readiness-Pfade |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-/Static-/Warehouse-/Zonenvalidierung; AAR `UNIT:GetSTN()` und test-only `UNIT:Explode()` bestätigt. `UNIT:GetFuel()`, `UNIT:GetCurrentFuelKgs()` und `UNIT:GetFuelMassMax()` wurden in realen AAR-Fuel-Telemetry-Läufen verwendet. |
| `COORDINATE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` / neuer AAR-Scope `SOURCE_REVIEWED` | `Get2DDistance(...)` praktisch verwendet; `GetIntermediateCoordinate(...)` für den 60-NM-Late-Approach ist im gepinnten Source geprüft und Acceptance-7-pending |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` / teilweise validiert | Bodenoperationsscope bleibt geplant; für AAR sind Despawn sowie Radio-/TACAN-Switch praktisch korreliert; OPSGROUP-`PassingWaypoint`-FSM bildet die source-reviewte Basis des neuen FLIGHTGROUP-Callbacks |
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

## 4. AAR – gepinnter MOOSE-Scope

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für den AAR-Scope sind im tatsächlich gepinnten `Moose.lua` geprüft:

```text
AUFTRAG:NewTANKER(...)
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
FLIGHTGROUP/OPSGROUP PassingWaypoint FSM event
FLIGHTGROUP OnAfterPassingWaypoint callback override
FLIGHTGROUP:AddMission(...)

OPSGROUP:SwitchRadio(...)
OPSGROUP:TurnOffRadio()
OPSGROUP:SwitchTACAN(...)
OPSGROUP:TurnOffTACAN()
OPSGROUP:Despawn(...)

COORDINATE:GetIntermediateCoordinate(ToCoordinate, Fraction)
COORDINATE:Get2DDistance(...)
SCHEDULER:New(...)

UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
```

`FLIGHTGROUP:AddWaypoint(...)` ist für den bestehenden FIR-Egress -> External-Handoff-Pfad praktisch bestätigt. Der korrigierte Acceptance-7-Candidate verwendet die öffentliche Methode zusätzlich für zwei explizite Inbound-Wegpunkte: zuerst den realen FIR-Fix, danach den Punkt 60 NM vor Track-Eintritt. Die Methode liefert unmittelbar eine Waypoint-Tabelle mit `uid` zurück. Der gepinnte MOOSE-Source zeigt außerdem den `PassingWaypoint`-FSM-Pfad und offizielle frameworkinterne Callback-Verwendung mit `OnAfterPassingWaypoint(..., Waypoint)`. Der konkrete OMW-AAR-Einsatz bleibt bis zum DCS-Test `SOURCE_REVIEWED`.

`COORDINATE:GetIntermediateCoordinate(...)` berechnet den Punkt 60 NM vom Track in Richtung FIR-Fix. Die Methode ist im gepinnten Source verifiziert; der konkrete AAR-Einsatz ist noch nicht DCS-validiert.

Im gepinnten `Moose.lua` wurde keine öffentliche `SPAWN:InitFuel(...)`-Methode nachgewiesen. Die physische Initial-Fuel-Menge bleibt Template-/Mission-Editor-Konfiguration.

### 4.1 LRC-/Fuel-Kalibrierung und Acceptance-7-Korrektur

Candidate 3 ersetzte den FIR-Ingress durch einen Late-Approach und wurde verworfen. Candidate 4 stellte den FIR-Fix wieder her, scheiterte aber mit einem UID-/Timing-basierten Late-Approach-Adapter. Candidate 5 bestätigte Spawn-/LRC-/Track-Höhen- und Fuel-Telemetrie.

Der erste Acceptance-7-Ansatz auf Commit `00ed8e33e05d1c88295a44ae4bda34f18e90f4ca` verwendete:

```text
FLIGHTGROUP:AddWaypoint(FIR fix)
-> AUFTRAG:SetMissionIngressCoord(60-NM point)
-> FLIGHTGROUP:AddMission(AUFTRAG)
```

Der reale DCS-Lauf vom 16.08.2026 wurde vom Projektinhaber abgebrochen: Der 60-NM-Höhenübergang funktionierte, die physischen Tanker ignorierten jedoch erneut die vorgeschalteten FIR-Ingress-Punkte. Dieser Stand ist damit **nicht akzeptiert**.

Der korrigierte MOOSE-first Candidate verwendet stattdessen:

```text
SPAWN
-> FLIGHTGROUP:AddWaypoint(FIR fix, inbound LRC altitude)
-> FLIGHTGROUP:AddWaypoint(60-NM late approach, inbound LRC altitude)
-> OnAfterPassingWaypoint confirms FIR
-> OnAfterPassingWaypoint confirms late approach
-> only then FLIGHTGROUP:AddMission(AUFTRAG tanker)
-> exact track altitude
```

Damit kann die AUFTRAG-Routenerzeugung den FIR-Wegpunkt nicht mehr vor dessen physischer Passage ersetzen. `SetMissionIngressCoord(...)` wird in diesem Candidate bewusst **nicht** für den Late-Approach verwendet. Der bestehende Egress-Vertrag über `SetMissionEgressCoord(...)` bleibt unverändert.

LISA bleibt:

```text
AL_UDEID / DAVER
initialFuelPct = 79.4558
FuelLow = 38
```

Dieser kombinierte Scope ist `SOURCE_REVIEWED`; der korrigierte Acceptance-7-DCS-Lauf steht aus.

Details: [`OMW-MOOSE-AAR-LRC-TRANSIT`](AAR-LRC-TRANSIT.md).

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

FIR-/Source-Routing des finalen Candidates:

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

Praktisch bestätigt sind für den vorherigen Production-Final-Acceptance-Stand Scheduled Relief, Radio/TACAN-Transfer, FuelLow Immediate Egress, CampaignState exact-once Settlement, Loss/Replacement und Restore-Reconciliation.

Für den korrigierten kombinierten Candidate gelten als **DCS acceptance pending**:

```text
spawn initial speed = 480 kt
route speed = 300 kt
MANAS inbound/outbound = FL340/FL350
AL_UDEID inbound/outbound = FL350/FL340
inbound order = SPAWN -> FIR -> 60-NM late approach -> AUFTRAG/track
60-NM late approach = enabled
exact track mission altitude = enabled
initial fuel MANAS = 91.4067 %
initial fuel AL_UDEID = 79.4558 %
FuelLow NELSON/PATTY/LISA/MOE/MILHOUSE/KRUSTY = 24/26/38/31/36/36 %
LISA = AL_UDEID / DAVER
```

## 6. Architekturgrenze

Die externen AAR-Pools MANAS und AL UDEID sind keine DCS-Airbase-/WAREHOUSE-/AIRWING-/SQUADRON-Bestände. CampaignState hält `AIRCRAFT_KC135` als count; SPAWN -> FLIGHTGROUP -> AUFTRAG materialisiert nur die physische Repräsentation.

## 7. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn MOOSE-Version/Commit, OMW-Source, Mission, Hashes, beobachtetes Verhalten und Einschränkungen dokumentiert sind. `VALIDATED` wird nicht aus Source-Review abgeleitet. Nach realem korrigiertem Acceptance-7-PASS sind die neuen Methodenverwendungen in `VERIFIED-METHODS.md` mit exakter Provenienz nachzutragen.
