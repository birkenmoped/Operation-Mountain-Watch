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
PHASE 3  First Vertical Integration – AAR                BUILD PASS / PRIOR DCS EVIDENCE RETAINED
PHASE 4  Player-Facing Mission Products                  NOT STARTED
PHASE 5  Ground Alert / CAS Request Lifecycle            NOT STARTED
PHASE 6  Dynamic Planning / Retasking / Persistence      NOT STARTED
```

`AIR-TASKING-AAR-VERTICAL-2` bleibt eine reale technische Acceptance fuer seinen exakt dokumentierten Stand. Der aktuelle Branch-Head wurde danach mit dem inzwischen auf `main` integrierten MissionDemand-Vertrag reconciliert. Der Projektinhaber hat am 22.08.2026 entschieden, den LISA-spezifischen DCS-Retest nicht erneut durchzufuehren. Der neue Source-Head wird deshalb ausdruecklich nicht als erneut in DCS validiert bezeichnet.

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

Der erfolgreiche `AIR-TASKING-AAR-VERTICAL-2`-Lauf bleibt dokumentierte technische Evidenz fuer den damaligen exakten Stand:

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

Dieser PASS wird gemaess Governance nicht auf den geaenderten aktuellen Source-Head uebertragen. Er bleibt jedoch gueltige Teil-Evidenz fuer den unveraendert gebliebenen physischen AAR-/LISA-/Handoff-/Settlement-Pfad.

## 6. Aktueller Reconciliation-Stand

Realer lokaler Build durch den Projektinhaber am 22.08.2026 auf:

```text
GitCommit: 93cae7cee601f2af242cfcc963accf499ddea7d8
SourceCommitUtc: 2026-08-22T19:06:02+02:00
BuilderVersion: OMW-AIR-TASKING-AAR-ADDITIVE-TEST-3
TestId: AIR-TASKING-AAR-VERTICAL-3
MissionDemandContract: CANONICAL_MAIN_SHAPE_READ_ONLY
AARRuntimeDemandTranslation: true
MizMutation: false
ExistingAARBaseEmbedded: false
ExistingAARBaseRecreated: false
ExistingAARAdapterRecreated: false
ExistingAARAdapterMutated: false
LegacyAdapterProxyPath: false
RuntimeObservation: CONTROLLER_GETSTATION_PLUS_MOOSE_SCHEDULER
ObserverIntervalSec: 5
WaitsForExistingAARFacade: true
MissionEditorAdditionalScriptRequired: true
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
AirTaskingBridgeSHA256: 7054d2a88262dba5546e13fe3dd51f01cdbd1a9efcabc41031b063c5336bb66f
AirTaskingBootstrapSHA256: 81876fed138533d667aa1f6bcbde2d232cd1bf49a54b83b54464cefb2da5f12a
HarnessSHA256: 01ab6f5d5bf65c9d64a656d338a39eac67b063afa38ec02f95325c1974f1cb11
BundleSHA256: dc840397ca311802cee99cf98f7448c0371ce40388f324b31dd01de7bf1c82f3
```

Der anschliessende unabhaengige lokale `Get-FileHash` bestaetigte denselben Bundle-Hash:

```text
DC840397CA311802CEE99CF98F7448C0371CE40388F324B31DD01DE7BF1C82F3
```

Damit gilt fuer den aktuellen Reconciliation-Stand:

```text
BUILD: PASS
BUNDLE HASH CROSS-CHECK: PASS
LOCAL LUA CONTRACT TEST: NOT RUN - no local Lua interpreter available
CURRENT SOURCE HEAD DCS VALIDATION: NOT RUN BY OWNER DECISION
```

Der LISA-spezifische Acceptance-Harness wurde vom Projektinhaber bereits aus der Arbeitsmission entfernt. Dies ist keine Ruecknahme der historischen `VERTICAL-2`-Acceptance; es bedeutet nur, dass der reconciliierte Source-Head nicht erneut mit diesem Harness in DCS getestet wird.

## 7. Gate 3

```text
GATE 3 HISTORICAL VERTICAL-2: PASS FOR EXACT DOCUMENTED PROVENANCE
GATE 3 CURRENT RECONCILED HEAD: BUILD PASS / NOT REVALIDATED IN DCS
validated_in_dcs: false
```

Damit ist Phase 3 fuer die weitere Branch-Reconciliation nicht mehr durch einen geplanten LISA-Retest blockiert. Eine Aussage `VALIDATED IN DCS` fuer den aktuellen Reconciliation-Stand bleibt unzulaessig.

## 8. ATO-Grenze

Der bisherige Test ist weiterhin kein vollstaendiger ATO-Test.

Nachgewiesen beziehungsweise reconciliert ist die vertikale Kette:

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
full branch diff review against current main
document metadata / registry / provenance review
documentation validator
owner merge decision
```

Ein erneuter LISA-DCS-Retest ist nach der ausdruecklichen Projektinhaberentscheidung vom 22.08.2026 kein Merge-Gate mehr. Der aktuelle Source-Head bleibt dennoch `validated_in_dcs: false`.

`source_commit: PENDING_MERGE` ist auf diesem ungemergten Branch zulaessig, darf aber nicht unveraendert auf `main` verbleiben.
