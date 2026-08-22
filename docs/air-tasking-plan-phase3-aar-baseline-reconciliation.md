---
document_id: OMW-AIR-TASKING-PLAN-PHASE3-AAR-BASELINE-RECONCILIATION
status: DRAFT
document_class: INTEGRATION_BASELINE_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 3 reconciliation of Air Tasking with the accepted AAR runtime baseline
  - branch-local reconciliation with the current-main MissionDemand contract
  - branch-local constraints for the AAR vertical integration
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - current-head DCS runtime acceptance
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

Phase 3 verwendet AAR als ersten vertikalen Integrationspfad. Die Air-Tasking-Schicht muss zwei bereits vorhandene Vertraege zusammenfuehren, ohne einen davon zu ersetzen:

```text
current-main canonical MissionDemand contract
+ accepted AAR runtime-demand contract
```

Die Uebersetzung liegt ausschliesslich in der Air-Tasking-Schicht.

## 2. Akzeptierte AAR-Baseline

Die bestehende AAR Acceptance-7 bleibt unveraendert massgeblich fuer den AAR-Produktionspfad:

```text
accepted source commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
DCS: 2.9.28.26385 MT
mission: OMW_Template_v10_AirOps_rdy(5).miz
mission SHA-256: 16d0a9b26a648c2dbcbd727b41afc93a28648620f8e2f8c357a770751e48cca5
bundle SHA-256: 3338d0baa67593be6bff9c22b3ed72b3a8e837cd00820d060eefe920faf91ee2
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
result: PASS
```

Air Tasking darf diese Baseline nicht nachbauen oder mutieren.

## 3. Bestehender AAR-Ausfuehrungspfad

Der akzeptierte Controller bleibt verantwortlich fuer:

```text
AAR area/profile policy
reserve/core track selection
SPAWN / FLIGHTGROUP / AUFTRAG tanker execution
FIR ingress / late approach / track / egress
handoff / loss lifecycle
```

Der bestehende CampaignState-Adapter bleibt allein verantwortlich fuer:

```text
KC-135 availability
reservation / consume
exact-once handoff recredit
loss audit
restore reconciliation
```

Keine dieser Verantwortlichkeiten wird in Air Tasking dupliziert.

## 4. Current-main MissionDemand contract

`main` enthaelt inzwischen `scripts/campaign/OMW_MissionDemand.lua` als kanonischen Campaign-Domain-Vertrag.

Relevante Identitaets-/Statusfelder sind insbesondere:

```text
id
missionType
priority
status
```

Die erste produktive Typmenge auf `main` umfasst `RESUPPLY` und `CAS_IMMEDIATE`. Air Tasking erweitert diese Registry in diesem Schritt nicht und mutiert keinen MissionDemand-Lifecycle.

Terminale MissionDemand-Zustaende sind:

```text
SUCCESS
FAILED
EXPIRED
```

Ein terminaler MissionDemand darf nicht neu fuer AAR-Unterstuetzung eingereicht werden.

## 5. Bestehender AAR-Runtime-Demand

Der akzeptierte AAR-Controller erwartet weiterhin seinen kleinen Laufzeitvertrag:

```text
missionDemandId
receiverProfile
operationsArea
supportMode
priority
```

Dieser Vertrag bleibt Controller-intern beziehungsweise Integrationsvertrag fuer die AAR-Ausfuehrung. Er wird nicht zum kanonischen Campaign-MissionDemand-Schema erhoben.

## 6. Reconciled translation boundary

Die Air-Tasking-Bridge konsumiert einen kanonischen MissionDemand read-only und erhaelt die AAR-spezifischen Planungswerte separat:

```text
canonical MissionDemand
  id
  missionType
  priority
  status

Air Tasking AAR planning
  receiverProfile
  operationsArea
  supportMode
```

Daraus erzeugt sie nur fuer den vorhandenen AAR-Controller:

```text
runtimeDemand = {
  missionDemandId = MissionDemand.id,
  receiverProfile = AirTasking.receiverProfile,
  operationsArea = AirTasking.operationsArea,
  supportMode = AirTasking.supportMode,
  priority = MissionDemand.priority,
}
```

Die Bridge:

```text
reads MissionDemand identity/state
creates ASR / ATM / EXE correlation
translates AAR runtime-demand fields
calls existing Controller.SelectArea / SubmitDemand / EndDemand
```

Sie darf nicht:

```text
mutate MissionDemand status
create a second MissionDemand registry
select tanker assets independently
recompute AAR area/profile policy
reserve/settle KC-135 resources
persist MOOSE/DCS runtime objects
```

## 7. Additive observer boundary

Der akzeptierte AAR-Controller besitzt keinen separaten Subscriber-Hook fuer Materialization/Handoff/Loss. Die Air-Tasking-Schicht beobachtet deshalb weiterhin den oeffentlich exponierten Stationszustand:

```text
Controller.GetStation(...)
+ MOOSE SCHEDULER every 5 seconds
```

Die beobachteten Runtime-Objekte werden nur fuer laufende Korrelation gehalten und nicht persistiert.

Der alte, nicht mehr verwendete `GetAdapterModule()`-/`baseAdapterModule`-Proxy-Pfad wurde entfernt. Damit existiert im aktuellen Air-Tasking-Code kein vorgesehener Weg mehr, den akzeptierten Strategic Adapter neu zu erzeugen oder dessen Callbacks zu dekorieren.

## 8. Stable identity boundary

Weiterhin gilt:

```text
MD-  canonical MissionDemand identity
ASR- Air Support Request
ATM- Air Tasking Mission
EXE- Execution Attempt
AAR- accepted AAR runtime identity
```

Insbesondere:

```text
ATM identity != AAR runtimeId
EXE identity != AAR runtimeId
```

`runtime_id` bleibt aus dem persistenten Air-Tasking-Snapshot ausgeschlossen.

## 9. Previous vertical acceptance

`AIR-TASKING-AAR-VERTICAL-2` erreichte am 22.08.2026 einen realen DCS-PASS fuer den damaligen exakten Stand:

```text
executable source commit: 1e52a9a685a58d54d0ebc6321d9b1aa81ab4427d
mission: OMW_Template_v16(6).miz
mission SHA-256: 5bc2382cf6ea30a77297b4ff3b36b65488dbcb34429d02c9618f1f449814dada
bundle SHA-256: 30701722eb739fb17b1f827fc681729a6ee781dedd223eab3b03fc72e78ab8a0
DCS: 2.9.28.26385 MT
result: PASS
```

Diese technische Acceptance bleibt fuer ihren exakten Stand gueltig. Sie wird nicht auf den aktuellen Source-Head uebertragen, bleibt aber Teil-Evidenz fuer den unveraenderten physischen AAR-/LISA-/Handoff-/Settlement-Pfad.

## 10. Current reconciliation evidence

Der reconciliierte Source-Stand wurde lokal gebaut und unabhaengig gehasht:

```text
GitCommit: 93cae7cee601f2af242cfcc963accf499ddea7d8
BuilderVersion: OMW-AIR-TASKING-AAR-ADDITIVE-TEST-3
TestId: AIR-TASKING-AAR-VERTICAL-3
MissionDemandContract: CANONICAL_MAIN_SHAPE_READ_ONLY
AARRuntimeDemandTranslation: true
LegacyAdapterProxyPath: false
BundleSHA256: dc840397ca311802cee99cf98f7448c0371ce40388f324b31dd01de7bf1c82f3
Independent Get-FileHash: dc840397ca311802cee99cf98f7448c0371ce40388f324b31dd01de7bf1c82f3
```

Der lokale Lua-Contract-Test wurde mangels lokalem Lua-Interpreter nicht ausgefuehrt und wird nicht als PASS behauptet.

## 11. Owner decision on LISA retest

Der Projektinhaber hat am 22.08.2026 entschieden, den LISA-spezifischen `AIR-TASKING-AAR-VERTICAL-3`-DCS-Retest nicht erneut durchzufuehren. Der bereits erfolgreiche `VERTICAL-2`-Lauf wird als bestehende Teil-Evidenz beibehalten. Der LISA-Test-Harness wurde vom Projektinhaber bereits aus der Arbeitsmission entfernt.

Diese Entscheidung bedeutet ausdruecklich nicht:

```text
current source head validated in DCS
VERTICAL-2 acceptance transferred to current source head
new runtime PASS inferred without test
```

Sie bedeutet:

```text
no additional LISA retest gate for branch reconciliation
historical VERTICAL-2 runtime evidence retained
current source head remains validated_in_dcs: false
```

## 12. Current Gate 3

```text
PHASE 3 RECONCILIATION: IMPLEMENTED
HISTORICAL VERTICAL-2: PASS FOR EXACT DOCUMENTED PROVENANCE
CURRENT RECONCILED HEAD: BUILD PASS / NOT REVALIDATED IN DCS
validated_in_dcs: false
```

Phase 3 ist damit fuer die weitere Branch-Reconciliation nicht durch einen erneuten LISA-Test blockiert. Eine spaetere Aenderung an AAR-Routing, AAR-Lifecycle, Strategic Adapter, Settlement, Runtime-Observer oder MissionDemand-to-AAR-Translation kann einen neuen DCS-Test erneut erforderlich machen.
