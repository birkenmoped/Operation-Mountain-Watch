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
source_branch: agent/aar-runtime-finalization
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
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | FuelLow, Dead/onafterDead, GetCoordinate und Mission-Lifecycle source-reviewed; `AddWaypoint(...)` ist für den neuen FIR-Egress->External-Handoff-Pfad SOURCE_REVIEWED und bis Acceptance-4 nicht praktisch bestätigt |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | dokumentierter COMMANDER-Lifecycle; nicht Quelle der externen OMW-AAR-Pools |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR `NewTANKER`, Ingress/Egress und Cancel source-reviewed; Acceptance-6 bestätigte Grundmechanik, neue FIR-Fix-Trennung noch offen |
| `SPAWN` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | area-spezifische AAR-Templates und stabile sortie Callsign-Familie; keine erzwungene `InitSTN()`, STN-Readback über `UNIT:GetSTN()` |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Source-Queue und Station-Monitoring |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Readiness-Pfade |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-/Static-/Warehouse-/Zonenvalidierung; `UNIT:GetSTN()` SOURCE_REVIEWED für AAR, `UNIT:Explode()` test-only SOURCE_REVIEWED bis Acceptance-Nachweis |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` | Bodenoperationsscope; für AAR sind Despawn sowie Radio-/TACAN-Switch source-reviewed und teilweise früher praktisch beobachtet |
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

## 4. AAR-Source-Review-Grenze

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für den aktuellen AAR-Produktionsstand sind im tatsächlich gepinnten `Moose.lua` geprüft:

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

`FLIGHTGROUP:AddWaypoint(...)` nimmt für Flightgroups Speed in Knoten und optionale Höhe in Fuß und aktualisiert standardmäßig die Route. Im aktuellen AAR-Branch wird diese öffentliche Methode erst nach physischer Passage des FIR-Egress-Fixes verwendet, um den External-Handoff-Punkt anzufügen. API-Verfügbarkeit ist source-reviewed; reales DCS-Verhalten dieses neuen Pfads bleibt bis Acceptance-4 offen.

`OPSGROUP:SwitchCallsign(...)` ist im gepinnten MOOSE weiterhin verfügbar, wird im korrigierten AAR-Produktionspfad aber **nicht mehr** für einen Wechsel zwischen Transit- und Track-Callsign verwendet. Der physische Tanker behält seine Callsign-Familie vom Spawn bis Despawn.

## 5. Aktueller AAR-Produktionsscope

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
Airways-Routing = später / nicht in Acceptance-4
```

Source-reviewed und noch nicht als praktisch bestätigt gelten insbesondere:

- automatischer Start ausschließlich der vier STANDARD-Tracks;
- demand-gesteuerter LISA-/MOE-Reserve-Lifecycle;
- stabile Callsign-Familie und eindeutige `n-1`-Gruppennummer bei Relief;
- FIR-Ingress über EGPAN/DAVER/PINAX;
- zweistufiger Egress `SetMissionEgressCoord(FIR fix)` -> `FLIGHTGROUP:AddWaypoint(external handoff)`;
- nominaler 3-h-Station-/Relief-Zyklus;
- FuelLow-Relief ohne Doppelmaterialisierung;
- CampaignState exact-once Settlement;
- Dead -> OnAfterDead -> OnLost ohne Aircraft-Recredit plus Ersatz bei weiter benötigtem Track;
- Restore-Reconciliation.

Diese Punkte dürfen erst nach dokumentiertem `AAR-PRODUCTION-FINAL-ACCEPTANCE-4` in `VERIFIED-METHODS.md` als praktisch bestätigt ergänzt werden.

## 6. Architekturgrenze

Die externen AAR-Pools MANAS und AL UDEID sind keine DCS-Airbase-/WAREHOUSE-/AIRWING-/SQUADRON-Bestände. CampaignState hält `AIRCRAFT_KC135` als count; SPAWN -> FLIGHTGROUP -> AUFTRAG materialisiert nur die physische Repräsentation.

## 7. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn MOOSE-Version/Commit, OMW-Source, Mission, Hashes, beobachtetes Verhalten und Einschränkungen dokumentiert sind. `VALIDATED` wird nicht aus Source-Review abgeleitet.
