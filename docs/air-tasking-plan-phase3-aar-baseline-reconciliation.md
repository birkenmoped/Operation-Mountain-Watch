---
document_id: OMW-AIR-TASKING-PLAN-PHASE3-AAR-BASELINE-RECONCILIATION
status: DRAFT
document_class: INTEGRATION_BASELINE_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 3 reconciliation of Air Tasking with the accepted AAR runtime baseline
  - branch-local identification of the existing AAR integration seam to be reused
  - branch-local constraints for the first AAR vertical integration
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - new DCS runtime acceptance
  - owner approval to mutate mission files
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 3 AAR Baseline Reconciliation

## 1. Zweck

Phase 3 verwendet AAR als ersten vertikalen Integrationspfad. Vor neuem Runtime-Code wird deshalb die tatsächlich vorhandene AAR-Implementierung gegen die auf `main` verbindliche Acceptance-7-Baseline abgeglichen.

Der Integrationspfad darf den bestehenden AAR-Controller, dessen CampaignState-Adapter oder dessen MOOSE-Lifecycle nicht nachbauen.

## 2. Verbindliche AAR-Baseline auf `main`

Für den Acceptance-7-Scope ist `OMW-AAR-ACCEPTANCE-7-FINALIZATION` maßgeblich. Es superseded ältere Candidate-/Pending-Aussagen aus Dokument 29 für diesen Scope.

Exakte Acceptance-Provenienz:

```text
accepted source branch: agent/aar-fuel-telemetry-calibration
accepted source commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
builder/test ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-7
DCS: 2.9.28.26385 MT
mission: OMW_Template_v10_AirOps_rdy(5).miz
mission SHA-256: 16d0a9b26a648c2dbcbd727b41afc93a28648620f8e2f8c357a770751e48cca5
bundle SHA-256: 3338d0baa67593be6bff9c22b3ed72b3a8e837cd00820d060eefe920faf91ee2
controller SHA-256: 547f0336b954b116e43e8a09ca0f001d893ea81d2394025891be5ff078388438
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
result: PASS
```

Dieser Phase-3-Branch behauptet daraus keine neue DCS-Acceptance.

## 3. Abgleich des eingecheckten Controllers

Die Datei

```text
scripts/air-operations/OMW_AAR_Controller.lua
```

hat auf dem aktuellen Air-Tasking-Branch denselben Git-Blob wie am akzeptierten Source-Commit `7d55a1383cbf3f52ea776d7354b37dbe5a920466`:

```text
Git blob SHA: 9ca9de2da811d6350d09e172fd630f15e58f7472
```

Damit ist für den Quelltext des Controllers kein separater Port aus dem Acceptance-Branch erforderlich.

Die im Controller enthaltenen Acceptance-7-relevanten Kerndaten stimmen mit der verbindlichen Baseline überein:

```text
NELSON    STANDARD FAST  MANAS     EGPAN  initial 91.4067  FuelLow 24
PATTY     STANDARD SLOW  MANAS     EGPAN  initial 91.4067  FuelLow 26
MILHOUSE  STANDARD SLOW  AL_UDEID  DAVER  initial 79.4558  FuelLow 36
KRUSTY    STANDARD SLOW  AL_UDEID  DAVER  initial 79.4558  FuelLow 36
LISA      RESERVE  FAST  AL_UDEID  DAVER  initial 79.4558  FuelLow 38
MOE       RESERVE  FAST  MANAS     PINAX  initial 91.4067  FuelLow 31
```

Weitere bestätigte Controller-Verträge:

```text
same-source spawn spacing: 60 s
spawn initialization: 480 kt
transit route: 300 kt
late approach: 60 NM
station cycle: 10800 s
relief handover ETA: 300 s
per-track physical maximum: 2
STANDARD tracks: 4
RESERVE tracks: 2
```

## 4. Bestehender MOOSE-first AAR-Pfad

Der Controller verwendet bereits den akzeptierten MOOSE-first-Ausführungspfad:

```text
SPAWN
-> FLIGHTGROUP
-> FLIGHTGROUP:AddWaypoint(FIR)
-> FLIGHTGROUP:AddWaypoint(60 NM)
-> PassingWaypoint(FIR)
-> PassingWaypoint(60 NM)
-> FLIGHTGROUP:AddMission(AUFTRAG:NewTANKER(...))
-> exact track altitude
-> AUFTRAG egress
-> FIR egress
-> external handoff / Despawn
```

Für Phase 3 wird dieser Pfad nicht ersetzt und nicht erneut implementiert.

## 5. Strategische Ressourcenhoheit

`OMW_AAR_CampaignStateAdapter.lua` ist die vorhandene strategische Integrationsgrenze.

```text
OFFMAP_MANAS:    AIRCRAFT_KC135 = 16
OFFMAP_AL_UDEID: AIRCRAFT_KC135 = 40
```

Der Adapter verwendet den vorhandenen CampaignState-Transaktionsvertrag:

```text
CanMaterialize
-> ReserveResource
-> Consume
-> physical lifecycle
-> exact-once handoff recredit
or
-> exact-once loss audit without aircraft recredit
```

Air Tasking darf diese Bestände nicht spiegeln und keine zweite Reservation-/Settlement-Logik hinzufügen.

## 6. Vorhandene Runtime-Kompositionsgrenze

`scripts/air-operations/OMW_AAR_RuntimeIntegration.lua` bindet den bestehenden CampaignState-Store, den AAR-CampaignState-Adapter und den Controller zusammen.

Öffentliche Integrationsfunktion:

```text
Integration.Attach(spec)
```

Der Caller liefert:

```text
spec.store
spec.campaignState
spec.adapterModule
spec.controller
spec.restored
```

`Attach(...)`:

```text
creates the existing AAR CampaignState adapter
-> optionally ReconcileRestore()
-> controller.SetStrategicAdapter(adapter)
-> controller.StartContinuousCoreCoverage()
```

Diese Kompositionsgrenze startet die vier STANDARD-Tracks, wenn der reale Controller dies unterstützt. RESERVE bleibt durch `Controller.SubmitDemand(...)` bedarfsgesteuert.

## 7. Bestehender MissionDemand-Eingang

Der vorhandene Controller akzeptiert bereits einen AAR-spezifischen MissionDemand-Vertrag:

```text
missionDemandId
receiverProfile
operationsArea
supportMode
priority
```

`Controller.SelectArea(demand)` bleibt die autoritative AAR-Policy für die konkrete Area-/Track-Auswahl innerhalb dieses Runtime-Moduls.

Aktuelle Policy:

```text
EAST + SUPPORT + SLOW             -> PATTY
SOUTH_CENTRAL + RECOVERY + SLOW   -> MILHOUSE
SOUTHEAST + RECOVERY + SLOW       -> KRUSTY
NORTHEAST + SUPPORT + FAST        -> NELSON
CENTRAL                            -> MOE
WEST                               -> LISA
```

Air Tasking darf diese Zuordnung nicht duplizieren. Insbesondere ist für Phase 3 kein zweiter Area-/Profile-Dispatcher zulässig.

## 8. Reserve-Lifecycle als Phase-3-Testpfad

`Controller.SubmitDemand(demand)`:

```text
validates/selects existing AAR policy
-> attaches to an already active compatible station when possible
or
-> queues the required track materialization
```

Für `LISA` und `MOE` bedeutet dies den bereits akzeptierten RESERVE-/MissionDemand-Pfad.

`Controller.EndDemand(demand, terminalStatus)` akzeptiert:

```text
COMPLETE
CANCELLED
ABORTED
```

Bei einem RESERVE-Track ohne weitere offene Demands wird die Station geschlossen und vorhandene ACTIVE-/RELIEF-Runtime kontrolliert in den bestehenden Egress-/Handoff-Pfad geschickt. Bei STANDARD bleibt die kontinuierliche Coverage erhalten.

Damit ist LISA oder MOE der geeignete erste vertikale Phase-3-Testfall. Die vier STANDARD-Tracks werden durch Air Tasking nicht geplant, gestartet oder beendet.

## 9. Air-Tasking-Domain-Grenze

Die Phase-1-Verträge bleiben unverändert:

```text
MissionDemand identity: MD-...
AIR_SUPPORT_REQUEST identity: ASR-...
AIR_TASKING_MISSION identity: ATM-...
EXECUTION_ATTEMPT identity: EXE-...
```

Dabei gilt:

```text
ATM identity != AAR runtimeId
EXE identity != AAR runtimeId
```

Der vorhandene AAR-`runtimeId` (`AAR-....`) ist eine Runtime-Korrelation und darf nicht zur persistenten Air-Tasking-Primär-ID werden.

Für den ersten Vertical Slice muss die kleine Air-Tasking-Korrelationsschicht deshalb mindestens folgende Beziehung halten:

```text
MD-...
-> ASR-...
-> ATM-...
-> EXE-...
-> existing AAR runtimeId
```

Keine MOOSE-, FLIGHTGROUP-, AUFTRAG- oder DCS-Objektreferenz darf Teil des persistenten Domainrecords werden.

## 10. Statusgrenze

Phase 1 definiert für eine Air-Tasking-Mission:

```text
DRAFT -> PLANNED -> ALLOCATED -> TASKED -> EXECUTING
                                      |         |
                                      |         +-> COMPLETED | FAILED | ABORTED
                                      +-> CANCELLED | ABORTED
```

Ein `EXECUTION_ATTEMPT` besitzt:

```text
PENDING -> STARTED -> ENDED | FAILED | CANCELLED
```

Für den AAR-Vertical-Slice darf insbesondere nicht angenommen werden:

```text
AAR runtime handoff == MissionDemand SUCCESS
AAR runtime loss == MissionDemand FAILED
ATM COMPLETED == CampaignState settlement
```

Mission-level Ergebnis, Request-Erfüllung, MissionDemand-Ergebnis und CampaignState-Settlement bleiben getrennte Entscheidungen.

## 11. Erforderliche minimale Ergänzung

Die vorhandene AAR-Laufzeit besitzt bereits MOOSE-/AAR-Ereignisse für Materialisierung, FuelLow, PassingWaypoint, On-Station, Egress, Handoff und Verlust. Was noch fehlt, ist eine öffentliche, kleine Korrelationsgrenze, über die Air Tasking diese Ereignisse mit `ATM-`/`EXE-`-Records verbinden kann.

Diese Ergänzung darf:

```text
observe existing AAR lifecycle events
map stable Air Tasking IDs to existing runtime IDs
log the correlation
update Air Tasking domain status
```

Sie darf nicht:

```text
select tanker assets independently
select AAR areas independently
create a second scheduler for tanker lifecycle
reserve/settle KC-135 resources independently
replace AUFTRAG/FLIGHTGROUP execution
persist MOOSE/DCS objects
```

Das ist eine projektspezifische Domain-/Integrationskorrelation im ausdrücklich vorgesehenen kleinen Adapter-Scope und keine MOOSE-Parallelimplementierung.

## 12. Ergebnis des Baseline-Gates

```text
PHASE 3 AAR BASELINE RECONCILIATION: PASS
scope: source/baseline reconciliation only
new DCS validation: false
```

Der nächste Implementierungsschritt darf daher die kleine Air-Tasking-to-AAR-Korrelationsschicht erstellen. Gate 3 bleibt bis zum realen reproduzierbaren DCS-End-to-End-Test offen.
