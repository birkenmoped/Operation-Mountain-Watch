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
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR FuelLow, Dead/OnAfterDead, GetCoordinate und `AddWaypoint(...)` für FIR-Egress -> External Handoff praktisch bestätigt; Candidate-4-Late-Approach über public waypoint getters + `AddWaypoint(...)` ist `SOURCE_REVIEWED` und DCS-offen |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | dokumentierter COMMANDER-Lifecycle; nicht Quelle der externen OMW-AAR-Pools |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR `NewTANKER`, Mission-Ingress/-Egress und `Cancel()` praktisch bestätigt; Candidate 4 bewahrt `SetMissionIngressCoord(FIR fix)` und nutzt zusätzlich `GetGroupWaypointIndex(...)` sowie `SetMissionAltitude(...)` als `SOURCE_REVIEWED` |
| `SPAWN` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | area-spezifische AAR-Templates, stabile Sortie-Callsign-Familie und branch-lokal bestätigter 480-kt-In-Air-Spawnzustand; keine erzwungene `InitSTN()`, STN-Readback über `UNIT:GetSTN()` |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Source-Queue, Station-Monitoring und Acceptance-Koordination; einmaliges `BASE/FLIGHTGROUP:ScheduleOnce(...)` nach MOOSE-Routeaufbau ist für Candidate 4 `SOURCE_REVIEWED` und DCS-offen |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Readiness-Pfade |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-/Static-/Warehouse-/Zonenvalidierung; AAR `UNIT:GetSTN()` und test-only `UNIT:Explode()` praktisch bestätigt. `UNIT:GetFuel()`, `UNIT:GetCurrentFuelKgs()` und `UNIT:GetFuelMassMax()` wurden im dokumentierten AAR-Fuel-Telemetry-Lauf praktisch verwendet; die Fuel-Neuberechnung bleibt eine getrennte Designentscheidung. |
| `COORDINATE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` / teilweise `SOURCE_REVIEWED` | `Get2DDistance(...)` im AAR-Scope praktisch verwendet; `GetIntermediateCoordinate(..., distanceMeters)` für den 60-NM-LRC-Approach ist source-verifiziert und noch nicht als kombinierter Routingpfad DCS-validiert |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` / teilweise validiert | Bodenoperationsscope bleibt geplant; für AAR sind Despawn sowie Radio-/TACAN-Switch praktisch korreliert; `GetWaypointIndex(uid)`, `GetWaypointID(index)` und `GetWaypointCoordinate(index)` sind für Candidate 4 source-verifiziert |
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

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für den akzeptierten AAR-Produktionsstand sind im tatsächlich gepinnten `Moose.lua` geprüft und für den dokumentierten Einsatz praktisch bestätigt:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

SPAWN:InitCallSign(...)
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
```

Für die AAR-Fuel-Telemetrie wurden außerdem im realen DCS-Lauf verwendet:

```text
UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
```

Der gepinnte `Moose.lua` implementiert `UNIT:GetFuel()` als öffentlichen Wrapper über `DCS Unit:getFuel()` und liefert den relativen Fuelwert; bei externen Tanks kann der Wert größer als `1.0` sein. Der Telemetrie-Harness klemmt diesen Wert deshalb nicht. `UNIT:GetCurrentFuelKgs()` und `UNIT:GetFuelMassMax()` werden nur als ergänzende Massentelemetrie protokolliert.

`FLIGHTGROUP:AddWaypoint(...)` wird im akzeptierten Produktionspfad nach physischer Passage des FIR-Egress-Fixes verwendet, um den getrennten External-Handoff-Punkt anzufügen.

`OPSGROUP:SwitchCallsign(...)` ist im gepinnten MOOSE weiterhin verfügbar, wird im korrigierten AAR-Produktionspfad aber **nicht** für einen Wechsel zwischen Transit- und Track-Callsign verwendet. Der physische Tanker behält seine Callsign-Familie vom Spawn bis Despawn.

### 4.1 Branch-lokaler LRC-Kandidat

`AAR-FUEL-TELEMETRY-3` hat den FIR-Ingress-Vertrag verletzt, indem `SetMissionIngressCoord(...)` auf den Late-Approach verschoben und der FIR-Fix anschließend per delayed `AddWaypoint` nachgerüstet wurde. Der reale DCS-Lauf zeigte keine zuverlässige PINAX-/DAVER-Passage. Dieser Ansatz ist verworfen.

Für `AAR-FUEL-TELEMETRY-4` sind zusätzlich im gepinnten `Moose.lua` source-verifiziert, aber als Kombination noch **nicht** DCS-validiert:

```text
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:GetGroupWaypointIndex(opsgroup)
FLIGHTGROUP:AddMission(...)
OPSGROUP:GetWaypointIndex(uid)
OPSGROUP:GetWaypointID(index)
OPSGROUP:GetWaypointCoordinate(index)
FLIGHTGROUP:AddWaypoint(...)
BASE/FLIGHTGROUP:ScheduleOnce(...)
COORDINATE:GetIntermediateCoordinate(...)
```

Candidate 4 lässt `AUFTRAG:SetMissionIngressCoord(EGPAN/PINAX/DAVER, ...)` unverändert. Nach dem MOOSE-Routeaufbau wird die Mission-Waypoint-UID über `GetGroupWaypointIndex(...)` aufgelöst, der unmittelbar vorhergehende Wegpunkt geometrisch gegen den konfigurierten FIR-Fix geprüft und erst danach der 60-NM-Late-Approach eingefügt. Bei einer Abweichung > 0,5 NM bricht der Test ab, statt den Routingvertrag stillschweigend zu verändern.

Details und DCS-Akzeptanzgrenze stehen in [`OMW-MOOSE-AAR-LRC-TRANSIT`](AAR-LRC-TRANSIT.md).

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

Praktisch bestätigt sind für den exakt dokumentierten AAR-Acceptance-Stand insbesondere:

- automatischer Start ausschließlich der vier STANDARD-Tracks;
- demand-gesteuerter LISA-/MOE-Reserve-Lifecycle;
- stabile Callsign-Familie und eindeutige `n-1`-Gruppennummer bei Relief;
- natürliche FIR-Ingress-/Egress-Passage über EGPAN/DAVER/PINAX;
- zweistufiger Egress `SetMissionEgressCoord(FIR fix)` -> `FLIGHTGROUP:AddWaypoint(external handoff)`;
- Scheduled Relief: `ETA <= 5 min` nur Handover-Arming, outgoing bleibt ACTIVE bis realer Relief-Ankunft;
- Radio/TACAN-Transfer erst bei realem Station-Owner-Wechsel;
- FuelLow Immediate Egress mit natürlichem Replacement;
- CampaignState exact-once Settlement;
- Dead -> OnAfterDead -> OnLost ohne Aircraft-Recredit plus Ersatz bei weiter benötigtem Track;
- Restore-Reconciliation.

Acceptance-Provenienz:

```text
Acceptance commit: 5e7dbec37f53155f39c63c25590cf6b4e35814ca
Mission: OMW_Template_v9_AirOps_rdy.miz
Mission SHA-256: c9e3978a4bbb35ebbfe5ae362021b5f8870129d6c8b06b58147424dde71a94e3
Bundle SHA-256: f33b0a5a6212d9a1103dfa2e0ab677777142ca771a2f5007a3ab1c7fee594cbf
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

## 6. Architekturgrenze

Die externen AAR-Pools MANAS und AL UDEID sind keine DCS-Airbase-/WAREHOUSE-/AIRWING-/SQUADRON-Bestände. CampaignState hält `AIRCRAFT_KC135` als count; SPAWN -> FLIGHTGROUP -> AUFTRAG materialisiert nur die physische Repräsentation.

## 7. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn MOOSE-Version/Commit, OMW-Source, Mission, Hashes, beobachtetes Verhalten und Einschränkungen dokumentiert sind. `VALIDATED` wird nicht aus Source-Review abgeleitet.
