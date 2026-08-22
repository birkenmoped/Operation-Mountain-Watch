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
PHASE 0  Governance / Reconciliation / Contracts          PASS, MAIN RECONCILIATION APPLIED
PHASE 1  Domain Data Model                               PASS, MAIN RECONCILIATION APPLIED
PHASE 2  MOOSE-First Capability Verification            PASS
PHASE 3  First Vertical Integration – AAR                RETEST REQUIRED
PHASE 4  Player-Facing Mission Products                  NOT STARTED
PHASE 5  Ground Alert / CAS Request Lifecycle            NOT STARTED
PHASE 6  Dynamic Planning / Retasking / Persistence      NOT STARTED
```

`AIR-TASKING-AAR-VERTICAL-2` bleibt eine reale technische Acceptance fuer seinen exakt dokumentierten Stand. Der aktuelle Branch-Head wurde danach mit dem inzwischen auf `main` integrierten MissionDemand-Vertrag reconciliert und benoetigt deshalb einen neuen Gate-3-Retest.

## 2. Current-main reconciliation

Der Branch ist gegen den aktuellen `main`-Stand fachlich abgeglichen worden. `main` enthaelt inzwischen insbesondere:

```text
scripts/campaign/OMW_MissionDemand.lua
scripts/campaign/OMW_ResourceDemandPolicy.lua
```

sowie die ueber PR #114 und PR #115 integrierte MissionDemand-/RESUPPLY-Baseline.

Verbindliche Grenze fuer Air Tasking:

```text
Campaign MissionDemand
= canonical demand identity and campaign assignment state

Air Tasking
= ASR / ATM / ATP / REL / EXE planning and correlation

MOOSE / accepted AAR runtime
= physical execution

CampaignState
= strategic resource authority and settlement
```

Air Tasking darf weder einen parallelen MissionDemand-Store noch einen zweiten Ressourcenledger einfuehren.

## 3. MissionDemand-Vertragsanpassung

Der bisherige AAR-Vertical-Slice verwendete direkt den bestehenden AAR-Runtime-Demand-Vertrag:

```text
missionDemandId
receiverProfile
operationsArea
supportMode
priority
```

Der kanonische MissionDemand auf aktuellem `main` verwendet dagegen insbesondere:

```text
id
missionType
priority
status
```

Die Air-Tasking-Bridge konsumiert deshalb jetzt den kanonischen MissionDemand read-only und erzeugt ausschliesslich fuer den akzeptierten AAR-Controller einen kleinen AAR-Runtime-Demand:

```text
MissionDemand.id -> runtimeDemand.missionDemandId
Air Tasking AAR planning -> receiverProfile / operationsArea / supportMode
MissionDemand.priority -> runtimeDemand.priority
```

Der MissionDemand-Status wird durch die Bridge nicht veraendert. Terminale MissionDemands (`SUCCESS`, `FAILED`, `EXPIRED`) werden fuer neue AAR-Unterstuetzung abgewiesen.

## 4. Additive AAR-Grenze

Unveraendert bleiben:

```text
OMW_AAR_Base.lua
OMW_AAR_Controller.lua
OMW_AAR_CampaignStateAdapter.lua
OMW_AAR_RuntimeIntegration.lua
main OMW_MissionDemand.lua
CampaignState settlement
```

Der fruehere tote `GetAdapterModule()`-/`baseAdapterModule`-Pfad wurde aus der Air-Tasking-Schicht entfernt. Damit verbleibt kein vorgesehener Air-Tasking-Pfad zur Neuerzeugung oder Dekoration des akzeptierten AAR Strategic Adapters.

Runtime-Beobachtung bleibt:

```text
Controller.GetStation(...)
+ MOOSE SCHEDULER at 5 s
+ Air Tasking internal MD/ASR/ATM/EXE correlation
```

## 5. Vorherige Gate-3-Acceptance

Der erfolgreiche `AIR-TASKING-AAR-VERTICAL-2`-Lauf bleibt dokumentierte historische technische Evidenz:

```text
acceptance branch: agent/air-tasking-plan-foundation
executable source commit: 1e52a9a685a58d54d0ebc6321d9b1aa81ab4427d
mission artifact: OMW_Template_v16(6).miz
mission SHA-256: 5bc2382cf6ea30a77297b4ff3b36b65488dbcb34429d02c9618f1f449814dada
bundle SHA-256: 30701722eb739fb17b1f827fc681729a6ee781dedd223eab3b03fc72e78ab8a0
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
result: PASS
```

Dieser PASS wird gemaess Governance nicht auf den geaenderten aktuellen Source-Head uebertragen.

## 6. Aktueller Retest-Stand

Neue Test-/Builder-Baseline:

```text
TestId: AIR-TASKING-AAR-VERTICAL-3
BuilderVersion: OMW-AIR-TASKING-AAR-ADDITIVE-TEST-3
MissionDemandContract: CANONICAL_MAIN_SHAPE_READ_ONLY
AARRuntimeDemandTranslation: true
LegacyAdapterProxyPath: false
MizMutation: false
ExistingAARBaseEmbedded: false
ExistingAARBaseRecreated: false
ExistingAARAdapterRecreated: false
ExistingAARAdapterMutated: false
RuntimeObservation: CONTROLLER_GETSTATION_PLUS_MOOSE_SCHEDULER
ObserverIntervalSec: 5
```

Der naechste erforderliche Nachweis ist ein realer lokaler Build inklusive Hashes. Erst danach wird die manuelle Mission-Editor-Einbindung fuer den neuen DCS-Retest vorbereitet.

## 7. Gate 3

```text
GATE 3 CURRENT HEAD: RETEST REQUIRED
validated_in_dcs: false
```

Der vorherige PASS bleibt fuer den alten exakten Acceptance-Stand gueltig; der aktuelle Reconciliation-Stand ist noch nicht DCS-validiert.

## 8. ATO-Grenze

Der bisherige Test ist weiterhin kein vollstaendiger ATO-Test.

Getestet beziehungsweise im Retest erneut zu pruefen ist die vertikale Kette:

```text
MissionDemand
-> Air Support Request
-> Air Tasking Mission
-> Execution Attempt
-> accepted AAR runtime
```

Noch nicht implementiert oder getestet sind insbesondere ein vollstaendiger Air Tasking Plan/ATO-Planungszyklus, periodische Planerzeugung, Player-facing ATO-Produkte oder ein gesamter Tages-/Operationsplan.

## 9. Merge-Readiness

```text
MERGE TO MAIN NOW: NOT YET RECOMMENDED
```

Vor Integration noch erforderlich:

```text
local build and contract-test evidence for current reconciliation head
Gate-3 DCS retest for AIR-TASKING-AAR-VERTICAL-3
full branch diff review against current main
document metadata / registry / provenance review
documentation validator
owner merge decision
```

`source_commit: PENDING_MERGE` ist auf diesem ungemergten Branch zulaessig, darf aber nicht unveraendert auf `main` verbleiben.
