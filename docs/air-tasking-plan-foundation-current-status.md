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
recreate or mutate the AAR strategic adapter
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

Der Air-Tasking-Bootstrap verlangt eine bereits laufende `OMW.AirOps.AAR`-Facade. Er startet keinen zweiten AAR-Stack und mutiert keine Methoden der existierenden `StrategicAdapter`-Instanz.

Da der bestehende AAR-Controller keinen separaten Subscriber-Hook fuer Materialization/Handoff/Loss bereitstellt, beobachtet Air Tasking ausschliesslich den oeffentlich exponierten Runtime-Zustand ueber `Controller.GetStation(...)`. Dafuer wird ein MOOSE `SCHEDULER` mit festem 5-Sekunden-Intervall verwendet. Controller und Strategic Adapter bleiben fuer physischen Lifecycle und Settlement allein zustaendig.

Die frueheren nicht-additiven Air-Tasking-AAR-Builder wurden entfernt.

## 5. Lokal bestaetigter additiver Build

Der Projektinhaber hat am 22.08.2026 auf Commit

```text
1e52a9a685a58d54d0ebc6321d9b1aa81ab4427d
```

den additiven Builder erfolgreich ausgefuehrt.

```text
BuilderVersion: OMW-AIR-TASKING-AAR-ADDITIVE-TEST-2
TestId: AIR-TASKING-AAR-VERTICAL-2
MizMutation: false
ExistingAARBaseEmbedded: false
ExistingAARBaseRecreated: false
ExistingAARAdapterRecreated: false
ExistingAARAdapterMutated: false
RuntimeObservation: CONTROLLER_GETSTATION_PLUS_MOOSE_SCHEDULER
ObserverIntervalSec: 5
```

Reale SHA-256-Evidenz:

```text
AirTaskingBridge:
f582f8646f86dc1ccc0264abdb4dcd4271f225ca2bc6bd4ff8f3705ab1ec782a

AirTaskingBootstrap:
d2e0d4bd1b75b5fcf60d0186623eb5eed876533c79b9c9a40c6f50176ce3cdf1

Harness:
0bde695d8b4b09e21494e6065d34afada76cac41ca299cc7f372c530d8c32f28

Additive Test Bundle:
30701722eb739fb17b1f827fc681729a6ee781dedd223eab3b03fc72e78ab8a0
```

Der unabhaengige `Get-FileHash` bestaetigte den Bundle-Hash. Dies ist Build-/Source-Evidenz, kein DCS-Runtime-PASS.

## 6. DCS Vertical Acceptance

Die lokal gebaute Datei lautet:

```text
mission/tests/air-tasking-aar-vertical/dist/OMW_AirTasking_AAR_Vertical_Test.lua
```

Sie wird durch den Projektinhaber als **zusaetzliche** Mission-Editor-`DO SCRIPT FILE`-Aktion eingefuegt. `OMW_AAR_Base.lua` bleibt unangetastet.

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

## 7. Gate 3

```text
GATE 3: OPEN
validated_in_dcs: false
```

Vor einem PASS erforderlich:

```text
manual Mission Editor insertion by project owner
Mission SHA-256
tested DCS version
embedded MOOSE commit/hash
required runtime logs
RESULT PASS
```

## 8. Merge-Readiness

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
