---
document_id: OMW-HANDOFF-AIR-TASKING-MAIN-RECONCILIATION-2026-08-22
status: DRAFT
document_class: HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - handoff of the current Air Tasking main reconciliation work
  - current Air Tasking objective, decisions, evidence, known defects and remaining TODO
  - exact continuation boundary before Ready for Review and merge
not_authoritative_for:
  - replacement of BINDING architecture or governance documents
  - new DCS runtime acceptance
  - merge approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-main-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Handoff – Air Tasking Plan Main Reconciliation

Stand: 22.08.2026

## 1. Übergabeziel

Diese Übergabe dokumentiert den vollständigen Arbeitsstand der Air-Tasking-Reconciliation bis unmittelbar vor der ausdrücklichen Owner-Entscheidung zu `Ready for Review` und Merge von PR #117.

Das operative Ziel ist weiterhin:

```text
current main MissionDemand / CampaignState authority
        -> Air Tasking domain correlation
        -> small additive AAR bridge/bootstrap
        -> accepted AAR controller and strategic adapter
        -> existing MOOSE AAR execution
```

Die historische Entwicklung auf `agent/air-tasking-plan-foundation` wird nicht als Ganzes nach `main` integriert. Stattdessen wurde der belastbare Teil selektiv auf einen frischen, von aktuellem `main` abgeleiteten Reconciliation-Branch übernommen.

## 2. Verbindliche Arbeitsregeln für die Fortsetzung

Vor jeder weiteren fachlichen oder technischen Änderung mindestens prüfen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/88-air-tasking-plan-foundation.md
docs/89-aar-acceptance-7-finalization.md
docs/DOCUMENT-METADATA-POLICY.md
docs/DOCUMENT-REGISTRY.md
docs/SUBPROJECT-REGISTRY.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/AIR-TASKING-C2-LIFECYCLE.md
docs/air-tasking-plan-main-reconciliation.md
```

Für neue oder geänderte MOOSE-Nutzung gilt unverändert:

```text
MOOSE documentation
-> actually pinned Moose.lua
-> exact signatures / returns / events / FSM prerequisites
-> official MOOSE demos/tests when relevant
```

Keine neue MOOSE-API, kein DCS-Verhalten und keine Runtime-Acceptance dürfen aus Annahmen abgeleitet werden.

## 3. Aktueller GitHub-Stand

```text
repository:
birkenmoped/Operation-Mountain-Watch

historical Air Tasking branch:
agent/air-tasking-plan-foundation
historical documented head:
c4c2d56a3fdf8cc7fed2d4eb60451b446eba681d

clean reconciliation branch:
agent/air-tasking-plan-main-reconciliation

reconciliation base:
main @ 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c

reviewed PR head before handoff documentation commits:
49600cdbb7b7b50a15a723a4d21ed38753f271e0

pull request:
#117 Reconcile Air Tasking foundation onto current main

PR state:
OPEN
DRAFT
branch relation after handoff documentation: behind main=0
```

`mergeable` muss unmittelbar vor jeder Ready-/Merge-Entscheidung erneut real von GitHub gelesen werden und wird in dieser Übergabe nicht als dauerhafte Eigenschaft festgeschrieben.

PR #117 bleibt absichtlich Draft. Weder `Ready for Review` noch Merge wurden ohne Owner-Freigabe durchgeführt.

## 4. Zielarchitektur und Authority-Grenzen

Die autoritative Architektur bleibt die auf `main` vorhandene Air-Tasking-Baseline. Die Reconciliation fügt keine konkurrierende Architektur hinzu.

```text
CampaignState / MissionDemand
        |
        v
Air Tasking domain
        |
        v
small OMW adapter / correlation
        |
        v
COMMANDER / AIRWING / BRIGADE architecture as defined by project baseline
        |
        v
AUFTRAG / FLIGHTGROUP / ARMYGROUP
        |
        v
DCS
```

Für den aktuell tatsächlich implementierten AAR-Vertical-Scope gilt enger:

```text
canonical MissionDemand record
        -> Air Support Request (ASR)
        -> Air Tasking Mission (ATM)
        -> Execution Attempt (EXE)
        -> existing accepted AAR Controller
        -> existing CampaignState strategic adapter
        -> existing MOOSE tanker lifecycle
```

Authority:

```text
MissionDemand
= canonical demand identity and campaign-domain status

CampaignState
= strategic resource authority

Air Tasking
= ASR / ATM / EXE correlation and planning translation

accepted AAR Controller
= AAR area/profile policy and physical AAR orchestration

accepted AAR CampaignState adapter
= KC-135 strategic reservation / settlement integration

MOOSE
= physical mission execution
```

Es gibt keinen zweiten strategischen Ressourcenbestand und keinen parallelen Tanker-Dispatcher.

## 5. Selektiv übernommene Dateien

Der clean-main-Reconciliation-Branch enthält für diesen Scope folgende neue Air-Tasking-Artefakte:

```text
scripts/air-operations/OMW_AirTasking_AARBridge.lua
scripts/air-operations/OMW_AirTasking_AARBootstrap.lua
mission/tests/air-tasking-aar-vertical/test_bridge.lua
mission/tests/air-tasking-aar-vertical/src/01-air-tasking-aar-vertical-acceptance.lua
mission/tests/air-tasking-aar-vertical/README.md
tools/build-air-tasking-aar-additive-test.ps1
.github/workflows/air-tasking-validation.yml
docs/air-tasking-plan-main-reconciliation.md
docs/moose/AIR-TASKING-C2-LIFECYCLE.md
```

Zusätzlich wurden die aktuellen Main-Register selektiv erweitert:

```text
docs/DOCUMENT-REGISTRY.md
docs/SUBPROJECT-REGISTRY.md
docs/moose/PROJECT-CLASS-INDEX.md
```

Ältere Phase-0/1/2-Dokumente des historischen Branches wurden bewusst nicht blind auf `main` portiert.

## 6. Explizit unveränderte Produktionskomponenten

Folgende vorhandene und akzeptierte Komponenten wurden in PR #117 weder ersetzt noch umbenannt noch eingebettet noch zur Laufzeit dekoriert oder funktional überschrieben:

```text
scripts/air-operations/OMW_AAR_Base.lua
scripts/air-operations/OMW_AAR_Controller.lua
scripts/air-operations/OMW_AAR_CampaignStateAdapter.lua
scripts/air-operations/OMW_AAR_RuntimeIntegration.lua
scripts/campaign/OMW_MissionDemand.lua
CampaignState resource settlement
existing .miz files
existing Mission Editor trigger/load chains
```

Diese Grenze ist verbindlich. Eine zukünftige Änderung an einer dieser Komponenten erfordert vor Implementierung eine ausdrückliche Owner-Freigabe mit Benennung des betroffenen Artefakts, der notwendigen Änderung, der betroffenen Baseline und der geprüften additiven Alternative.

## 7. MissionDemand-Reconciliation

Das wichtigste fachliche Problem des historischen Branches war ein AAR-spezifisch geformter Demand-Vertrag, der nicht mehr zum produktiven MissionDemand auf `main` passte.

Der aktuelle `main`-MissionDemand-Vertrag bleibt unverändert. Die Bridge liest canonical fields wie:

```text
MissionDemand.id
MissionDemand.missionType
MissionDemand.priority
MissionDemand.status
```

Für den akzeptierten AAR-Controller wird intern ein kleiner Runtime-Demand übersetzt:

```text
MissionDemand.id
-> runtimeDemand.missionDemandId

Air Tasking planning fields
-> runtimeDemand.receiverProfile
-> runtimeDemand.operationsArea
-> runtimeDemand.supportMode

MissionDemand.priority
-> runtimeDemand.priority
```

Wichtige Entscheidung:

```text
No new AAR MissionDemand type was added.
```

Die aktuelle produktive MissionDemand-Typmenge auf `main` bleibt:

```text
RESUPPLY
CAS_IMMEDIATE
```

Der Vertical-Test verwendet einen canonical-shaped MissionDemand nur als read-only Korrelationsfixture. Daraus wird kein neuer produktiver AAR-Demand-Typ abgeleitet.

Terminale MissionDemands (`SUCCESS`, `FAILED`, `EXPIRED`) werden von der Bridge für eine neue AAR-Unterstützung abgelehnt.

## 8. Additive AAR-Integration

Der Bootstrap verlangt eine bereits laufende akzeptierte AAR-Facade:

```text
OMW.AirOps.AAR.Status == RUNNING
```

Er erzeugt keinen zweiten AAR-Stack und keinen Ersatzadapter.

Die Runtime-Korrelation erfolgt additiv über:

```text
Controller.GetStation(...)
+ MOOSE SCHEDULER
+ fixed observer interval: 5 seconds
```

Der Observer korreliert bereits vom AAR-Controller exponierte Runtimezustände zu stabilen Air-Tasking-IDs. Er ruft keine Strategic-Adapter-Settlement-Callbacks als Ersatz auf und monkey-patcht den akzeptierten Adapter nicht.

## 9. Entfernte beziehungsweise verworfene Fehlpfade

### 9.1 Falscher `.miz`-/AAR-Base-Pfad

Ein früherer Entwicklungsstand hatte einen Builder eingeführt, der eine `.miz` verändern beziehungsweise `OMW_AAR_Base.lua` ersetzen sollte. Das widersprach den Projektgrenzen.

Dieser Fehlpfad wurde vollständig verworfen und der Repository-Baum auf den Stand vor dieser Fehlentwicklung zurückgeführt.

Revert-/Restore-Nachweis:

```text
restored tree equivalent to:
3aea46a1cbfa1f62136bd932f0f48e67d332d680

forward corrective commit:
19a5091ef5504a2d9471962b4dc6e938607e2f46
```

Danach wurde ausschließlich ein additiver Test-/Bridge-Pfad verfolgt.

Verbindliche Konsequenz:

```text
ChatGPT does not mutate/build/generate .miz files.
The owner performs .miz changes manually.
Generated test artifacts are Lua files only.
```

### 9.2 Strategic-Adapter-Dekoration / Monkey-Patching

Ein nachfolgender additiver Versuch war formal noch problematisch, weil er den akzeptierten Adapter zur Laufzeit hätte dekorieren können.

Auch dieser Pfad wurde entfernt.

Der aktuelle Builder prüft explizit gegen unter anderem:

```text
SetStrategicAdapter(...)
adapter.OnMaterialized = ...
adapter.OnHandoff = ...
adapter.OnLost = ...
GetAdapterModule
baseAdapterModule
```

Aktueller gewünschter Zustand:

```text
ExistingAARAdapterRecreated: false
ExistingAARAdapterMutated: false
LegacyAdapterProxyPath: false
```

### 9.3 Stark divergierter historischer Branch

`agent/air-tasking-plan-foundation` war inzwischen stark von `main` abgewichen. Ein direkter Merge hätte veraltete Dokumente und Baselines zurückbringen können.

Lösung:

```text
fresh branch directly from current main
+ selective port of required implementation/evidence only
```

Daraus entstand:

```text
agent/air-tasking-plan-main-reconciliation
PR #117
```

### 9.4 Lokaler Branch-/Worktree-Konflikt

Der ursprüngliche lokale Projektordner befand sich nicht auf dem Air-Tasking-Branch, sondern auf:

```text
agent/automatic-response-orchestration
```

Ein `git pull --ff-only origin agent/air-tasking-plan-foundation` im falschen Worktree führte deshalb zu einer Divergenzmeldung.

Lösung war ein separater Git-Worktree für parallele Branch-Arbeit.

Tatsächlich angelegt wurde:

```text
P:\DCS-DEV\Operation-Mountain-Watch\Operation-Mountain-Watch-AirTasking
-> agent/air-tasking-plan-foundation
```

Hinweis: Der Pfad lag wegen der relativen `git worktree add`-Angabe innerhalb des bestehenden Repository-Verzeichnisses. Das war zunächst falsch kommuniziert, wurde anschließend mit `git worktree list` real verifiziert.

Der historische Air-Tasking-Worktree wurde danach erfolgreich bis auf:

```text
c4c2d56a3fdf8cc7fed2d4eb60451b446eba681d
```

aktualisiert.

Der neue clean-main-Reconciliation-Branch besitzt zum Zeitpunkt dieser Übergabe noch keinen separat lokal verifizierten Worktree. Lokale Änderungen daran sind vor der Owner-Mergeentscheidung nicht erforderlich.

### 9.5 Fehlender lokaler Lua-Interpreter

Auf dem Owner-System steht kein `lua`/`luac` zur Verfügung. Ein früherer lokaler Testaufruf schlug deshalb fehl.

Verbindliche Konsequenz:

```text
Do not instruct the owner to run lua, luac, Python or python3 locally.
```

Lösung für den Lua-Contract-Test:

```text
GitHub Actions
-> install Lua 5.1 on runner
-> run test_bridge.lua
```

### 9.6 Stales lokales dist-Artefakt

Nach einem fehlgeschlagenen Builder-/Pfadversuch wurde zunächst ein Hash eines bereits vorhandenen alten `dist`-Bundles angezeigt. Dieser Hash war keine neue Build-Evidenz.

Konsequenz:

```text
A hash is valid evidence only when the corresponding build completed successfully in the same verified source context.
```

Der spätere korrekte lokale Build erzeugte ein neues Bundle und der Hash wurde separat mit `Get-FileHash` bestätigt.

## 10. Historische DCS-Acceptance

Der physische Air-Tasking/AAR-Vertical-Pfad wurde bereits vor der MissionDemand-Reconciliation real in DCS getestet.

Exakte Provenienz:

```text
TestId:
AIR-TASKING-AAR-VERTICAL-2

historical executable source commit:
1e52a9a685a58d54d0ebc6321d9b1aa81ab4427d

mission:
OMW_Template_v16(6).miz

mission SHA-256:
5bc2382cf6ea30a77297b4ff3b36b65488dbcb34429d02c9618f1f449814dada

bundle SHA-256:
30701722eb739fb17b1f827fc681729a6ee781dedd223eab3b03fc72e78ab8a0

DCS:
2.9.28.26385 MT

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

result:
PASS
```

Der Lauf bestätigte im exakt getesteten Stand:

```text
accepted existing AAR facade retained
four STANDARD tanker tracks stable
LISA reserve materialization
MD / ASR / ATM / EXE correlation
natural FIR ingress
natural track arrival
EndAAR COMPLETE
natural egress / OFFMAP_HANDOFF
ATM COMPLETED
ASR FULFILLED
AL_UDEID exact-once strategic recredit
runtime_id not persisted in Air Tasking snapshot
```

Diese Acceptance bleibt gültige historische Teil-Evidenz, darf aber nicht als DCS-PASS des später reconcilierten Source-Stands ausgegeben werden.

## 11. MissionDemand-reconciled Source- und lokale Build-Evidenz

Reconciled executable source provenance:

```text
93cae7cee601f2af242cfcc963accf499ddea7d8
```

Der Owner hat diesen Stand real lokal gebaut.

```text
BuilderVersion:
OMW-AIR-TASKING-AAR-ADDITIVE-TEST-3

TestId:
AIR-TASKING-AAR-VERTICAL-3

MissionDemandContract:
CANONICAL_MAIN_SHAPE_READ_ONLY

AARRuntimeDemandTranslation:
true

MizMutation:
false

ExistingAARBaseEmbedded:
false

ExistingAARBaseRecreated:
false

ExistingAARAdapterRecreated:
false

ExistingAARAdapterMutated:
false

LegacyAdapterProxyPath:
false

RuntimeObservation:
CONTROLLER_GETSTATION_PLUS_MOOSE_SCHEDULER

ObserverIntervalSec:
5
```

Reale lokale Source-/Bundle-Hashes:

```text
AirTaskingBridgeSHA256:
7054d2a88262dba5546e13fe3dd51f01cdbd1a9efcabc41031b063c5336bb66f

AirTaskingBootstrapSHA256:
81876fed138533d667aa1f6bcbde2d232cd1bf49a54b83b54464cefb2da5f12a

HarnessSHA256:
01ab6f5d5bf65c9d64a656d338a39eac67b063afa38ec02f95325c1974f1cb11

BundleSHA256:
dc840397ca311802cee99cf98f7448c0371ce40388f324b31dd01de7bf1c82f3
```

Der Bundle-Hash wurde anschließend unabhängig mit lokalem `Get-FileHash` erneut bestimmt und stimmte exakt überein.

Lokaler Lua-Teststatus:

```text
NOT RUN
reason: no local Lua interpreter available
```

## 12. GitHub-Actions-Evidenz auf PR #117

Für den clean-main-Reconciliation-Branch wurde ein eigener Workflow hinzugefügt:

```text
.github/workflows/air-tasking-validation.yml
```

Der Workflow führt aus:

```text
install Lua 5.1
run mission/tests/air-tasking-aar-vertical/test_bridge.lua
run PowerShell builder
hash generated Lua bundle independently
```

Realer Contract-Test:

```text
AIR_TASKING_AAR_BRIDGE_TEST_PASS
```

Damit ist die zuvor lokal fehlende Lua-Contract-Evidenz auf dem PR-Merge-Ref vorhanden.

Der GitHub-Build bestätigte ebenfalls die Schutzmarker gegen `.miz`-Mutation sowie Base-/Adapter-Recreation und -Mutation.

Wichtig: Der im CI erzeugte Bundle-Hash ist wegen des PR-Merge-Refs und des in den generierten Header aufgenommenen Git-Commits nicht identisch mit dem früher lokal aus `93cae7c...` gebauten Bundle. Beide Hashes sind nur für ihre jeweilige Provenienz gültig.

## 13. Repositoryweite Documentation Validation

Die allgemeine Documentation-Validation des Repositorys bleibt rot.

Der geprüfte Lauf meldete:

```text
18 errors
0 warnings
```

Die 18 Fehler liegen in bereits auf `main` vorhandenen, fachfremden Ground-/Army-Ground-Dokumenten, darunter Metadaten-/Acceptance-Provenienzfehler. Der Validator meldete keinen Air-Tasking-spezifischen Fehler aus PR #117 und keinen Fehler in dieser Übergabedatei.

Entscheidung:

```text
Do not repair unrelated Ground documentation inside PR #117.
```

Diese Fehler sind ein repositoryweiter separater Cleanup-Scope und kein Air-Tasking-Codefehler.

## 14. Owner-Entscheidung zum VERTICAL-3-LISA-Retest

Der zusätzliche LISA-Test-Harness war aus der Arbeitsmission bereits entfernt worden.

Der Owner hat am 22.08.2026 entschieden:

```text
Do not reinsert the LISA harness solely to repeat VERTICAL-3.
Do not require another DCS run as merge gate for this reconciliation.
```

Daraus folgt formal:

```text
VERTICAL-2
= historical exact-provenance DCS PASS

VERTICAL-3 reconciled source
= local BUILD PASS
= local HASH PASS
= GitHub Lua 5.1 CONTRACT PASS
= GitHub BUILD PASS
= NOT DCS-validated
```

`validated_in_dcs` bleibt für den reconcilierten aktuellen Source deshalb `false`.

Es darf kein neuer VERTICAL-3-DCS-PASS erfunden oder aus VERTICAL-2 übertragen werden.

## 15. Bekannte fachliche Grenze: shared AAR runtime

Aktuell gilt intern:

```text
executionByRuntimeId[runtimeId]
-> one Air Tasking record / one EXE correlation
```

Damit ist die Situation mehrerer logisch unabhängiger Air-Tasking-Demands, die denselben bereits laufenden Tanker-Runtime gemeinsam nutzen, noch nicht als vollständige Mehrfachkorrelation implementiert.

Diese Grenze wurde absichtlich nicht stillschweigend in der Reconciliation redesigniert.

Status:

```text
KNOWN LIMITATION
not a hidden implementation claim
not part of the passed single-demand vertical fixture
future owner/design decision required before implementation
```

## 16. ATO-Grenze

Die aktuelle Reconciliation ist noch kein vollständiger ATO-/Air-Tasking-Plan-Generator.

Implementiert beziehungsweise reconciliert ist der vertikale AAR-Integrationsbaustein:

```text
MissionDemand
-> ASR
-> ATM
-> EXE
-> accepted AAR runtime
```

Noch nicht durch diesen Scope implementiert:

```text
periodic ATO generation
full day/operations Air Tasking Plan
player-facing ATO product
general multi-mission-type retasking
full planner for all Air Tasking mission types
```

Das übergeordnete Projektziel "Air Tasking Plan Foundation" ist daher nach dem Merge von PR #117 nicht automatisch vollständig abgeschlossen; PR #117 schafft die saubere Main-Basis für die weitere Foundation-Arbeit.

## 17. Aktueller TODO-Stand

### A. Unmittelbares Ziel: PR #117 sauber integrieren

```text
[COMPLETE] historical branch audited and not merged wholesale
[COMPLETE] clean reconciliation branch created from current main
[COMPLETE] canonical MissionDemand boundary reconciled
[COMPLETE] no new AAR MissionDemand type introduced
[COMPLETE] legacy adapter proxy/decorator path removed
[COMPLETE] accepted AAR production components excluded from diff
[COMPLETE] .miz mutation excluded
[COMPLETE] local PowerShell build performed
[COMPLETE] local bundle hash independently cross-checked
[COMPLETE] GitHub Lua 5.1 bridge contract test PASS
[COMPLETE] GitHub PowerShell bundle build PASS
[COMPLETE] MOOSE Air Tasking lifecycle reference added
[COMPLETE] MOOSE project class index reconciled
[COMPLETE] document registry reconciled
[COMPLETE] subproject registry reconciled
[COMPLETE] full PR diff reviewed against current main
[COMPLETE] known shared-runtime limitation documented
[COMPLETE] owner decision recorded: no repeated LISA VERTICAL-3 DCS gate
[COMPLETE] repository-wide documentation CI failure triaged as unrelated Ground metadata debt
[COMPLETE] dedicated handoff/TODO document created and validator produced no new Air-Tasking/handoff error
[PENDING OWNER DECISION] authorize PR #117 Ready for Review
[PENDING OWNER DECISION] authorize PR #117 merge
[POST-MERGE REQUIRED] replace all PR-local source_commit: PENDING_MERGE values that land on main with valid full commit provenance
[POST-MERGE REQUIRED] verify final main diff/readback and exact merge commit
[POST-MERGE REQUIRED] update SUBPROJECT-REGISTRY from open PR #117 to merged history if required by current registry policy
[POST-MERGE REQUIRED] update this handoff / reconciliation status or supersede it with a finalization record
```

### B. Nach sauberem Merge: Air Tasking Foundation fortsetzen

Die genaue Reihenfolge muss aus `docs/88-air-tasking-plan-foundation.md` und den dann aktuellen Main-Baselines abgeleitet werden. Aus dem aktuellen Scope bleiben mindestens folgende fachliche Themen offen:

```text
[OPEN DESIGN] shared-runtime multi-demand correlation decision
[OPEN DESIGN] broader ASR / ATM lifecycle beyond AAR vertical slice
[OPEN DESIGN] COMMANDER/AIRWING execution integration for additional mission types
[OPEN DESIGN] periodic or event-driven Air Tasking Plan / ATO generation
[OPEN DESIGN] player-facing tasking product and assignment workflow
[OPEN DESIGN] retasking / cancellation / replacement semantics across mission types
[OPEN DESIGN] persistence/restore semantics for Air Tasking domain records beyond current snapshot boundary
[OPEN ACCEPTANCE] DCS acceptance for every newly introduced runtime path; no inherited blanket validation
```

Keine dieser offenen Aufgaben darf stillschweigend als Bestandteil von PR #117 ausgeweitet werden.

## 18. Nächster zulässiger Schritt

Der technische Reconciliation-Scope von PR #117 ist reviewbereit vorbereitet, aber die Governance-Grenze ist erreicht.

Der nächste Schritt ist ausschließlich eine Owner-Entscheidung:

```text
Option 1:
Authorize Ready for Review only.

Option 2:
Authorize Ready for Review and Merge.

Option 3:
Keep PR #117 Draft and request additional review/change.
```

Ohne ausdrückliche Entscheidung wird weder der Draft-Status geändert noch gemergt.

## 19. Empfohlene Fortsetzungsprüfung nach Owner-Freigabe

Vor dem tatsächlichen Merge erneut real prüfen:

```text
PR #117 current mergeable state
PR head SHA has not changed unexpectedly
branch is not behind main
Air Tasking validation latest applicable run is PASS
accepted AAR production files remain absent from diff
OMW_MissionDemand.lua remains absent from diff
no .miz files are in diff
no unresolved review thread introduces a blocker
```

Für den Merge ist der tatsächlich geprüfte Head-SHA als `expected_head_sha` zu verwenden, damit ein zwischenzeitlich veränderter PR nicht versehentlich gemergt wird.

## 20. Lokale Arbeitsumgebung / Übergabehinweise

Bekannte lokale Worktrees zuletzt:

```text
P:\DCS-DEV\Operation-Mountain-Watch
-> agent/automatic-response-orchestration

P:\DCS-DEV\Operation-Mountain-Watch\Operation-Mountain-Watch-AirTasking
-> agent/air-tasking-plan-foundation

P:\DCS-DEV\OMW-JBAD
-> fix/jbad-generic-uh60-medevac-seed

P:\DCS-DEV\Operation-Mountain-Watch-towns-discovery
-> agent/towns-discovery
```

Nicht davon ausgehen, dass ein Worktree inzwischen noch auf demselben Commit steht. Vor branchspezifischen lokalen Befehlen immer real prüfen:

```powershell
git branch --show-current
git status -sb
git rev-parse HEAD
```

Untracked lokale Test-/dist-Artefakte in anderen Worktrees nicht löschen oder bereinigen, nur um einen Air-Tasking-Schritt zu vereinfachen.

Für parallele Branch-Arbeit Git-Worktrees verwenden statt einen belegten Arbeitsbaum unnötig umzuschalten.

## 21. Wichtige Dateien für die nächste Bearbeitung

```text
Architecture / governance:
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/88-air-tasking-plan-foundation.md
docs/89-aar-acceptance-7-finalization.md

Current reconciliation:
docs/air-tasking-plan-main-reconciliation.md
docs/handoffs/2026-08-22-air-tasking-plan-main-reconciliation-handoff.md

MOOSE:
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/AIR-TASKING-C2-LIFECYCLE.md
docs/moose/VERIFIED-METHODS.md
actual pinned Moose.lua

Implementation:
scripts/air-operations/OMW_AirTasking_AARBridge.lua
scripts/air-operations/OMW_AirTasking_AARBootstrap.lua
scripts/air-operations/OMW_AAR_Controller.lua
scripts/air-operations/OMW_AAR_Base.lua
scripts/air-operations/OMW_AAR_CampaignStateAdapter.lua
scripts/campaign/OMW_MissionDemand.lua

Tests/build:
mission/tests/air-tasking-aar-vertical/README.md
mission/tests/air-tasking-aar-vertical/test_bridge.lua
mission/tests/air-tasking-aar-vertical/src/01-air-tasking-aar-vertical-acceptance.lua
tools/build-air-tasking-aar-additive-test.ps1
.github/workflows/air-tasking-validation.yml

Registers:
docs/DOCUMENT-REGISTRY.md
docs/SUBPROJECT-REGISTRY.md
```

## 22. Kurzfassung für eine neue Chat-/Bearbeitungssitzung

```text
We are reconciling the historical Air Tasking foundation onto current main.
Do NOT merge the historical agent/air-tasking-plan-foundation branch wholesale.
Use clean branch agent/air-tasking-plan-main-reconciliation and PR #117.
PR #117 is Draft and requires explicit owner approval before Ready/Merge.
Do NOT change accepted OMW_AAR_Base/Controller/CampaignStateAdapter/RuntimeIntegration or OMW_MissionDemand without a new explicit owner decision.
The Air Tasking AAR bridge is additive and consumes canonical MissionDemand read-only, translating AAR planning fields to the existing accepted AAR controller runtime-demand contract.
No AAR MissionDemand type was added.
No .miz is mutated by ChatGPT.
Historical AIR-TASKING-AAR-VERTICAL-2 is DCS PASS only for its exact provenance.
The reconciled VERTICAL-3 source has local BUILD/HASH PASS and GitHub Lua 5.1 CONTRACT/BUILD PASS, but no new DCS validation by explicit owner decision.
Known limitation: one Air Tasking correlation per observed AAR runtimeId; multi-demand shared-runtime correlation remains future design work.
Repository-wide Documentation validation is red because of 18 unrelated pre-existing Ground metadata/provenance errors; do not repair them inside PR #117.
Next action: obtain explicit owner decision for Ready for Review and/or Merge, then re-check exact PR head/mergeability/CI/diff before changing PR state.
```

## 23. Abschlussstatus dieser Übergabe

```text
Air Tasking historical research/development branch:
RETAINED AS EVIDENCE

clean main reconciliation:
IMPLEMENTED

canonical MissionDemand reconciliation:
IMPLEMENTED

accepted AAR production baseline:
UNCHANGED

local reconciled build/hash:
PASS

GitHub Lua contract/build:
PASS

new DCS validation of reconciled source:
NOT RUN BY OWNER DECISION

PR #117:
DRAFT / OWNER DECISION PENDING

handoff:
CURRENT AS OF 2026-08-22
```
