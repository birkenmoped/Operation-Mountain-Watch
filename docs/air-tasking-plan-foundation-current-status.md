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

## 1. Gesamtstatus

```text
PHASE 0  Governance / Reconciliation / Contracts          PASS
PHASE 1  Domain Data Model                               PASS
PHASE 2  MOOSE-First Capability Verification            PASS
PHASE 3  First Vertical Integration – AAR                IN PROGRESS
PHASE 4  Player-Facing Mission Products                  NOT STARTED
PHASE 5  Ground Alert / CAS Request Lifecycle            NOT STARTED
PHASE 6  Dynamic Planning / Retasking / Persistence      NOT STARTED
```

Phase 0 bis 2 sind branch-lokale PASS-Staende. Phase 3 ist noch nicht in DCS validiert.

## 2. Gepruefte Missions-/MOOSE-Baseline

Die aktuelle vom Projektinhaber bereitgestellte Mission wurde ausschliesslich lesend geprueft:

```text
mission artifact: OMW_Template_v12_groundworks(2).miz
mission SHA-256: 3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078
embedded source: l10n/DEFAULT/Moose.lua
MOOSE context: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
existing AAR resource: l10n/DEFAULT/OMW_AAR_Base.lua
```

Die bestehende AAR-Base bleibt unveraendert.

## 3. Phase-3-Architektur

Verbindliche branch-lokale Integrationsrichtung:

```text
existing OMW_AAR_Base.lua
-> existing OMW.AirOps.AAR facade RUNNING
-> additive OMW_AirTasking_AARBootstrap
-> OMW_AirTasking_AARBridge
-> existing AAR Controller / CampaignState adapter
-> existing MOOSE execution
```

Nicht zulaessig fuer diesen Pfad:

```text
replace OMW_AAR_Base.lua
rebuild the accepted AAR base inside Air Tasking
recreate the AAR strategic adapter
recompute AAR area/profile policy
create a second tanker inventory
bypass CampaignState settlement
```

## 4. Implementierter Stand

```text
scripts/air-operations/OMW_AirTasking_AARBridge.lua
scripts/air-operations/OMW_AirTasking_AARBootstrap.lua
mission/tests/air-tasking-aar-vertical/src/01-air-tasking-aar-vertical-acceptance.lua
tools/build-air-tasking-aar-additive-test.ps1
```

Der Air-Tasking-Bootstrap verlangt eine bereits laufende `OMW.AirOps.AAR`-Facade. Er startet keinen zweiten AAR-Stack. Die existierende `StrategicAdapter`-Instanz wird nicht ersetzt; Air Tasking beobachtet ihre oeffentlichen Settlement-Callbacks additiv und delegiert immer zuerst an die bestehende Implementierung.

Die frueheren nicht-additiven Air-Tasking-AAR-Builder wurden entfernt.

## 5. DCS Vertical Acceptance

Test-ID:

```text
AIR-TASKING-AAR-VERTICAL-2
```

Der lokale Builder erzeugt nur die zusaetzliche Test-Lua:

```text
mission/tests/air-tasking-aar-vertical/dist/OMW_AirTasking_AAR_Vertical_Test.lua
```

Diese Datei wird durch den Projektinhaber als zusaetzliche Mission-Editor-`DO SCRIPT FILE`-Aktion eingefuegt. `OMW_AAR_Base.lua` bleibt unangetastet.

Der Test wartet auf die bereits laufende AAR-Base und prueft anschliessend:

```text
EXISTING_AAR_ATTACH_PASS
-> four STANDARD tracks
-> WEST/FAST MissionDemand
-> LISA reserve materialization
-> stable MD/ASR/ATM/EXE correlation
-> natural track arrival
-> EndAAR(COMPLETE)
-> external handoff
-> exact-once AL_UDEID recredit
-> RESULT PASS
```

## 6. Gate 3

```text
GATE 3: OPEN
validated_in_dcs: false
```

Vor einem PASS erforderlich:

```text
local additive Lua build + hash
manual Mission Editor insertion by project owner
Mission SHA-256
DCS version
embedded MOOSE commit/hash
required runtime logs
RESULT PASS
```

## 7. Merge-Readiness

```text
MERGE TO MAIN NOW: NOT YET RECOMMENDED
```

Vor Integration noch erforderlich:

```text
Gate-3 DCS vertical acceptance
current-main reconciliation
full branch diff review
document metadata / registry / provenance review
documentation validator
owner merge decision
```

`source_commit: PENDING_MERGE` ist auf diesem ungemergten Branch zulaessig, darf aber nicht unveraendert auf `main` verbleiben.
