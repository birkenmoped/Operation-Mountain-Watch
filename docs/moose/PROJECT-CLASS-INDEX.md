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
| `AIRBASE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Auflösung, ID, Parkingdump und airfield-spezifische Kalibrierung; aktuelle Kandahar-/Shindand-Nachweise siehe Fach- und Acceptance-Dokumente |
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, Stockregistrierung, SQUADRON-Bindung und direkter AUFTRAG-Dispatch; externe OMW-AAR-Pools verwenden bewusst kein AIRWING |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Foundation-Bestände und post-start Assetbindung für dokumentierte AirOps-Knoten |
| `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AirOps-Stock-/Asset-Lifecycle; kein WAREHOUSE für externe MANAS-/AL_UDEID-AAR-count-Pools |
| `STORAGE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | CampaignState->DCS-Warehouse Mirror/Telemetry; keine strategische Rückautorität |
| `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Asset-/Mission-Capability-Pfade für dokumentierte AirOps-Foundations |
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR source-reviewed für FuelLow, Dead/onafterDead, GetCoordinate und Mission-Lifecycle; Acceptance-6 bestätigte Boom-AAR und FuelLow/Cancel/Egress-Grundmechanik. Der aktuelle Continuous-Core-Controller nutzt `OnAfterDead` zur Loss-Klassifikation; dieser konkrete Einsatz bleibt bis Final-Acceptance-3 SOURCE_REVIEWED |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | dokumentierter COMMANDER-Lifecycle; nicht als Quelle der externen OMW-AAR-Pools verwendet |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR `NewTANKER`, Ingress/Egress, Cancel source-reviewed; Acceptance-6 bestätigte Tanker-/Cancel-/Egress-Grundpfad; Continuous-Core-/Relief-Einsatz noch DCS-offen |
| `SPAWN` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | area-spezifische AAR-Templates und Transit-Callsigns. OMW erzwingt keine `InitSTN()` mehr; die gepinnte SPAWN-Implementierung verwaltet Template-STN-Kollisionen, danach liest OMW die materialisierte STN über `UNIT:GetSTN()` |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | geordnete Konstruktion und verzögerte Diagnose bestätigt; aktueller AAR-Controller verwendet MOOSE `SCHEDULER` für Source-Queue und Station-Monitoring |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Readiness-Pfade |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-/Static-/Warehouse-/Zonenvalidierung. Für AAR ist `UNIT:GetSTN()` SOURCE_REVIEWED; `UNIT:Explode()` bleibt test-only SOURCE_REVIEWED bis zum Acceptance-Nachweis |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` | Bodenoperationsscope; für AAR sind Despawn, Callsign-/Radio-/TACAN-Switch source-reviewed und teilweise in früheren Acceptance-Läufen praktisch beobachtet |
| `OPSTRANSPORT` | `PLANNED` | taktischer Transport |
| `CTLD`, `CSAR`, `AICSAR` | `PLANNED` / teilweise verwendet | separate Acceptance erforderlich |
| `INTEL` | `PLANNED` | taktisches Lagebild; Laufzeitnachweis im gepinnten Stand offen |
| `INTEL_DLINK` | `CANDIDATE` | Aggregation getrennter Netze; Performance offen |
| `PLAYERRECCE` | `CANDIDATE` | spielergeführte Aufklärung; Multiplayerprüfung offen |
| `TARS` | `CANDIDATE` | verzögerte Foto-/IMINT-Aufklärung; Verfügbarkeit offen |
| `DETECTION_*` | `PLANNED` | Spezialfälle; kein paralleles strategisches Lagebild neben `INTEL` |
| `Core.Astar`, `PATHLINE`, `MOVEMENT` | `PLANNED` | Routing und Bewegungsbegrenzung |
| `_DATABASE` | `INTERNAL_RESTRICTED` | nur Diagnose/Validierung; aktueller AAR-Produktionspfad verwendet `_DATABASE` nicht |
| `CHIEF` | `REJECTED_FOR_PROJECT_USE` | aktuelle Produktionsarchitektur `NOT_USED` |

## 4. AIRWING-Lifecycle-Grenzen

```text
SQUADRON:New
-> Konfiguration vorhanden

AIRWING:AddSquadron
-> Cohort registriert
-> Warehouse-Stock synchron erhöht

AIRWING:Start plus Initialisierung
-> Warehouse-Assets werden COHORT/SQUADRON zugeordnet
```

Ein Pre-Start-PASS über nichtleere `squadron.assets` ist unzulässig. Die externen AAR-Pools MANAS und AL UDEID sind eine andere Architekturklasse: keine DCS-Airbase, kein WAREHOUSE/AIRWING und keine SQUADRON. CampaignState hält dort nur `AIRCRAFT_KC135` als `count`; die physische Mission wird direkt über SPAWN -> FLIGHTGROUP -> AUFTRAG materialisiert.

## 5. AAR-Source-Review-Grenze

Für den aktuellen AAR-Produktionsstand sind im tatsächlich gepinnten `Moose.lua` insbesondere folgende Pfade geprüft:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetRadio(...)
AUFTRAG:SetTACAN(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:IsExecuting()
AUFTRAG:Cancel()

SPAWN:InitCallSign(...)
SPAWN template-STN collision handling
UNIT:GetSTN()

FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FuelLow callback
FLIGHTGROUP Dead/onafterDead FSM event
OnAfterDead callback override
FLIGHTGROUP:GetCoordinate()
FLIGHTGROUP:IsAirborne()
FLIGHTGROUP:Refuel(...)

OPSGROUP:SwitchCallsign(...)
OPSGROUP:SwitchRadio(...)
OPSGROUP:TurnOffRadio()
OPSGROUP:SwitchTACAN(...)
OPSGROUP:TurnOffTACAN()
OPSGROUP:Despawn(...)

COORDINATE:Get2DDistance(...)
COORDINATE:Get3DDistance(...)
SCHEDULER:New(...)
```

Der Source-Review bestätigt API-Verfügbarkeit und Signaturen, nicht automatisch das reale DCS-Verhalten.

## 6. Aktueller AAR-Produktionsscope

```text
6 kontinuierliche Core-Tracks:
LISA FAST
MOE FAST
MILHOUSE SLOW
KRUSTY SLOW
PATTY SLOW
NELSON FAST

kein globales 2/2/4-AAR-Limit
pro Track max. 1 ACTIVE + 1 RELIEF
bei gleichzeitigem Relief aller Tracks max. 12 physische KC-135
MissionDemand attach/end beeinflusst nicht die kontinuierliche Track-Verfügbarkeit
```

Source-reviewed und noch nicht als praktisch bestätigt gelten insbesondere:

- automatischer Continuous-Core-Start nach RuntimeIntegration-Attach;
- nominaler 3-h-Station-/Relief-Zyklus;
- FuelLow-Relief ohne Doppelmaterialisierung;
- Transit-/Station-Callsign-/Radio-/TACAN-Handover im aktuellen Produktionscontroller;
- CampaignState Consume/Exact-once-Recredit-Kopplung für den Continuous-Core-Betrieb;
- MissionDemand-Ende ohne Core-Track-Shutdown;
- FLIGHTGROUP-Dead -> OnAfterDead -> strategischer OnLost ohne Aircraft-Recredit;
- Ersatzmaterialisierung nach Loss bei weiter erforderlicher Core-Abdeckung;
- Restore-Reconciliation für nicht aufgelöste AAR-Commitments;
- MOOSE-gemanagte Spawn-STN plus `UNIT:GetSTN()`-Readback bei bis zu 12 gleichzeitigen Tankern.

Diese Punkte dürfen erst nach dem dokumentierten `AAR-PRODUCTION-FINAL-ACCEPTANCE-3`-Lauf in `VERIFIED-METHODS.md` als praktisch bestätigt ergänzt werden.

## 7. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn MOOSE-Version/Commit, OMW-Source, Mission, Hashes, beobachtetes Verhalten und Einschränkungen dokumentiert sind. `VALIDATED` wird nicht aus Source-Review abgeleitet.
