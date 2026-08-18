---
document_id: OMW-AIR-TASKING-PLAN-FOUNDATION-CURRENT-STATUS
status: DRAFT
document_class: PROJECT_STATUS_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local current implementation status of agent/air-tasking-plan-foundation
  - branch-local mapping of completed and open items against the Air Tasking Plan foundation manifest
  - branch-local merge-readiness assessment
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS runtime acceptance
  - final owner decision to merge the branch
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Foundation – Aktueller Stand

## 1. Referenzstand

```text
branch: agent/air-tasking-plan-foundation
phase 0: PASS
phase 1: PASS
phase 2: PASS
phase 3: NOT STARTED
validated_in_dcs for Phase 2: false
```

Die frühere vermeintliche lokale/remote Divergenz ist geklärt: `e6e0bdeea991f51745c05ed214bf4176e5abbd11` gehörte zum separaten Branch `agent/army-ground-foundation-reconciliation`. Der lokale Air-Tasking-Branch wurde anschließend sauber per Fast-Forward auf den damaligen Remote-Handover-Head `bfcd3e13248f528a697cd01cca6acebc0e0c9e8e` synchronisiert. Die Divergenz-Sperre ist damit aufgehoben.

Vor einem Merge nach `main` bleibt dennoch eine erneute Reconciliation gegen den dann aktuellen `main`-Stand erforderlich.

## 2. Gesamtstatus

```text
PHASE 0  Governance / Reconciliation / Contracts          PASS
PHASE 1  Domain Data Model                               PASS
PHASE 2  MOOSE-First Capability Verification            PASS
PHASE 3  First Vertical Integration – AAR                NOT STARTED
PHASE 4  Player-Facing Mission Products                  NOT STARTED
PHASE 5  Ground Alert / CAS Request Lifecycle            NOT STARTED
PHASE 6  Dynamic Planning / Retasking / Persistence      NOT STARTED
```

Die PASS-Werte für Phase 0 bis 2 sind branch-lokal. Phase 2 ist Source-/Official-Example-/Architekturverifikation und **kein** neuer DCS-Runtime-Nachweis.

## 3. Tatsächlich geprüfte MOOSE-Baseline

Die aktuelle vom Projektinhaber bereitgestellte Mission wurde direkt geprüft:

```text
mission artifact: OMW_Template_v12_groundworks.miz
mission SHA-256: 3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078
embedded source: l10n/DEFAULT/Moose.lua
MOOSE context: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Damit entspricht die tatsächlich in der aktuellen `.miz` enthaltene `Moose.lua` exakt der Phase-2-Baseline.

## 4. Phase 0 / 1

Unverändert abgeschlossen:

```text
CampaignState
= strategische Zustands-/Ressourcenautorität

MissionDemand
= autoritative kampagnenweite Bedarfsidentität

Air Tasking Domain
= Request-/Mission-/Planungs-/Authority-/Persistenzmodell

MOOSE
= operative Capability-/Asset-/Missionsausführung innerhalb der OMW-Grenzen
```

Stabile Request-, Mission-, Relationship- und Execution-IDs bleiben von DCS-/MOOSE-Runtimeobjekten getrennt.

## 5. Phase 2 – abgeschlossene Prüfungen

```text
[x] pinned MOOSE branch/commit/hash
[x] CHIEF APIs / Verantwortungsgrenzen
[x] COMMANDER APIs
[x] AIRWING / BRIGADE APIs
[x] SQUADRON / PLATOON APIs
[x] AUFTRAG-Konstruktion und Missionstypen
[x] Mission Assignment / Lifecycle / FSM-Callbacks
[x] FLIGHTGROUP / ARMYGROUP / OPSGROUP Status-/Lifecycle-Anbindung
[x] offizielle Beispiele für tatsächlich benötigte Kombinationen
[x] Authority-/Allocation-Fälle gegen native MOOSE-Fähigkeiten
[x] finale OMW-Planungsdaten-vs.-MOOSE-Adaptergrenze
[x] PROJECT-CLASS-INDEX / thematische MOOSE-Dokumentation nachpflegen
[x] keine source-only Methode als neu DCS-VALIDATED markieren
```

### C2-/Execution-Pfad

```text
CampaignState / MissionDemand
        ↓
Air Tasking Domain
        ↓
small OMW adapter
        ↓
COMMANDER
        ↓
AIRWING / BRIGADE
        ↓
SQUADRON / PLATOON
        ↓
AUFTRAG
        ↓
FLIGHTGROUP / ARMYGROUP
        ↓
DCS
```

`CHIEF` bleibt für diesen Pfad `REJECTED_FOR_PROJECT_USE`.

## 6. Wesentliche Phase-2-Ergebnisse

### AUFTRAG-Mapping

```text
AAR     -> NewTANKER
CAS     -> NewCAS / NewCASENHANCED
ISR     -> NewRECON for physical recon execution
CSAR    -> dedicated MOOSE CSAR/AICSAR path; NewRESCUEHELO is carrier-specific
AIRLIFT -> NewTROOPTRANSPORT / NewCARGOTRANSPORT / NewFREIGHTTRANSPORT by cargo semantics
ESCORT  -> NewESCORT
```

Am tatsächlich eingebetteten MOOSE-Stand gilt ausdrücklich:

```text
AUFTRAG:NewOPSTRANSPORT(...)
= implementation commented out
= not callable
= MUST NOT USE
```

### Lifecycle

MOOSE stellt native Assignment-, Queue-, `OpsOnMission`-, `FlightOnMission`-, `ArmyOnMission`-, AUFTRAG- und OPSGROUP-Lifecycle-Hooks bereit.

Wichtige Semantik:

```text
MOOSE DONE != OMW mission success
MOOSE cancellation != CampaignState settlement
MOOSE runtime UID != OMW mission_id
```

### Authority / Allocation

```text
OMW / CampaignState
= strategic authority / availability / reservation / settlement / persistence

MOOSE
= operational capability / recruitment / assignment / physical execution
```

Eine parallele OMW-Command-/Capability-/Asset-Dispatcher-Engine ist weder erforderlich noch zulässig.

## 7. Offizielle MOOSE-Beispiele

Auf `FlightControl-Master/MOOSE_MISSIONS_UNPACKED`, Branch `develop`, wurden die benötigten Kombinationen bestätigt:

```text
OPS - Airwing/Airwing - 010 - Fighter Wing
SQUADRON -> AIRWING -> AUFTRAG -> FLIGHTGROUP

OPS - Brigade/Brigade - 010 - Patrol Mission
PLATOON -> BRIGADE -> AUFTRAG -> ARMYGROUP

OPS - Commander/Commander - 020 - Bombing with Airwings
COMMANDER -> multiple AIRWINGs -> AUFTRAG -> OPSGROUP
```

## 8. Gate 2

```text
GATE 2: PASS
scope: MOOSE-first source / official-example / architecture verification
validated_in_dcs: false
```

Es wurde keine Framework-Lücke gefunden, die für diesen Foundation-Scope eine produktive Nicht-MOOSE- oder Native-DCS-Parallelimplementierung rechtfertigt.

## 9. Merge-Readiness

```text
MERGE TO MAIN NOW: NOT YET RECOMMENDED
```

Nicht mehr wegen eines offenen Gate 2, sondern weil vor Integration noch erforderlich sind:

```text
current-main reconciliation
full branch diff review
document metadata / registry / provenance review
documentation validator
owner merge decision
```

`source_commit: PENDING_MERGE` ist auf diesem ungemergten Branch zulässig, darf aber nicht unverändert auf `main` verbleiben.

## 10. Nächster fachlicher Schritt

```text
PHASE 3 – First Vertical Integration: AAR
```

Vor produktivem Adaptercode ist zunächst die aktuelle AAR-Schnittstelle gegen die verbindliche `main`-Baseline zu prüfen. Danach ist nur die kleinste notwendige Air-Tasking-Korrelationsschicht um den bestehenden AAR-Adapter zu implementieren.

Unverändert verboten:

```text
replace existing AAR strategic adapter
recompute AAR MissionDemand / Area / Profile logic in Air Tasking
create a second tanker inventory
bypass CampaignState exact-once settlement
persist MOOSE/DCS runtime objects as campaign truth
claim new DCS validation without a documented DCS test
```
