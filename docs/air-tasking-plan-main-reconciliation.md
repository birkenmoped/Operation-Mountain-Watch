---
document_id: OMW-AIR-TASKING-PLAN-MAIN-RECONCILIATION
status: DRAFT
document_class: INTEGRATION_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local reconciliation of the Air Tasking implementation with current main
  - branch-local adoption scope for the AAR bridge and additive observer
  - branch-local provenance and known limitations of the reconciled implementation
not_authoritative_for:
  - repository-wide architecture beyond BINDING documents on main
  - new DCS runtime acceptance of the reconciled implementation
  - owner approval to merge the branch
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-main-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Main Reconciliation

## 1. Zweck

Dieser Branch uebernimmt den belastbaren Endstand der bisherigen Air-Tasking-Foundation selektiv auf den aktuellen `main`-Stand. Die stark divergierte Entwicklungshistorie von `agent/air-tasking-plan-foundation` wird nicht als Ganzes gemergt.

Ausgangslage:

```text
current main base:
28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c

historical Air Tasking branch:
agent/air-tasking-plan-foundation

historical branch head after reconciliation notes:
c4c2d56a3fdf8cc7fed2d4eb60451b446eba681d

reconciled executable source provenance:
93cae7cee601f2af242cfcc963accf499ddea7d8
```

Die Architekturautoritaet bleibt `docs/88-air-tasking-plan-foundation.md` auf `main`. Dieses Dokument fuehrt keine konkurrierende Architektur ein.

## 2. Uebernommener Implementierungsscope

In den frischen Reconciliation-Branch werden nur die aktuell benoetigten Implementierungs- und Testartefakte uebernommen:

```text
scripts/air-operations/OMW_AirTasking_AARBridge.lua
scripts/air-operations/OMW_AirTasking_AARBootstrap.lua
mission/tests/air-tasking-aar-vertical/test_bridge.lua
mission/tests/air-tasking-aar-vertical/src/01-air-tasking-aar-vertical-acceptance.lua
tools/build-air-tasking-aar-additive-test.ps1
```

Die zahlreichen Phase-0/1/2-Arbeitsdokumente des historischen Branches bleiben als Branch-Historie erhalten und werden nicht blind auf `main` portiert. Aktuelle Governance, Register, MissionDemand- und Ground-/AirOps-Baselines auf `main` werden nicht durch alte Branchkopien ersetzt.

## 3. Unveraenderte Produktionskomponenten

Dieser Reconciliation-Schritt aendert, ersetzt oder dekoriert keine der folgenden akzeptierten Produktionskomponenten:

```text
scripts/air-operations/OMW_AAR_Base.lua
scripts/air-operations/OMW_AAR_Controller.lua
scripts/air-operations/OMW_AAR_CampaignStateAdapter.lua
scripts/air-operations/OMW_AAR_RuntimeIntegration.lua
scripts/campaign/OMW_MissionDemand.lua
CampaignState resource settlement
existing mission .miz resources
existing Mission Editor trigger/load chain
```

Die AAR Acceptance-7 bleibt die technische Baseline fuer den existierenden AAR-Produktionspfad.

## 4. Canonical MissionDemand boundary

Der aktuelle `main`-Vertrag aus `scripts/campaign/OMW_MissionDemand.lua` bleibt autoritativ fuer MissionDemand-Identitaet und Campaign-Domain-Status.

Die Air-Tasking-Bridge liest insbesondere:

```text
MissionDemand.id
MissionDemand.missionType
MissionDemand.priority
MissionDemand.status
```

Die Bridge schreibt den MissionDemand-Status nicht und erzeugt keine zweite MissionDemand-Registry.

Der bestehende AAR-Controller erwartet dagegen seinen kleinen Runtime-Demand-Vertrag:

```text
missionDemandId
receiverProfile
operationsArea
supportMode
priority
```

Daher gilt die explizite Uebersetzung:

```text
MissionDemand.id
-> runtimeDemand.missionDemandId

Air Tasking planning input
-> runtimeDemand.receiverProfile
-> runtimeDemand.operationsArea
-> runtimeDemand.supportMode

MissionDemand.priority
-> runtimeDemand.priority
```

Terminale MissionDemands (`SUCCESS`, `FAILED`, `EXPIRED`) werden nicht neu fuer AAR-Unterstuetzung angenommen.

Die erste produktive MissionDemand-Typmenge auf `main` bleibt unveraendert:

```text
RESUPPLY
CAS_IMMEDIATE
```

Dieser Branch fuegt keinen separaten `AAR`-MissionDemand-Typ hinzu.

## 5. Additive AAR integration boundary

Die Bootstrap-Schicht setzt voraus, dass die akzeptierte AAR-Facade bereits laeuft:

```text
OMW.AirOps.AAR.Status == RUNNING
```

Sie erzeugt keinen zweiten AAR-Stack und keinen Ersatz fuer den Strategic Adapter.

Runtime-Beobachtung:

```text
existing Controller.GetStation(...)
+ MOOSE SCHEDULER every 5 seconds
+ Air Tasking internal ASR / ATM / EXE correlation
```

Der fruehere tote `GetAdapterModule()`-/`baseAdapterModule`-Proxy-Pfad wurde vor dieser Reconciliation aus der Air-Tasking-Schicht entfernt. Es existiert im uebernommenen Code kein vorgesehener Pfad zum Neuerzeugen, Ersetzen oder Dekorieren der akzeptierten AAR-Strategic-Adapter-Callbacks.

## 6. MOOSE-First Grenze

Physische AAR-Ausfuehrung bleibt beim bestehenden MOOSE-basierten AAR-Pfad. Air Tasking implementiert keinen parallelen Dispatcher fuer Tanker, kein eigenes Routing und keinen zweiten Assetbestand.

Der additive Observer nutzt `SCHEDULER` mit festem 5-Sekunden-Intervall. Das ist eine kleine Korrelationsschicht ueber den bereits oeffentlich exponierten `Controller.GetStation(...)`-Zustand; AAR-Lifecycle und strategische Settlement-Events verbleiben beim bestehenden Controller/Adapter.

## 7. Historische DCS-Evidenz

`AIR-TASKING-AAR-VERTICAL-2` wurde auf dem historischen Branch real in DCS bestanden:

```text
executable source commit:
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

Der Lauf bestaetigte fuer genau diesen Stand unter anderem LISA-Reserve-Materialisierung, ASR/ATM/EXE-Korrelation, natuerlichen Anflug, Handoff und exact-once AL_UDEID-Recredit.

Diese Evidenz bleibt gueltig fuer den damaligen Stand, wird aber nicht als DCS-Validation des reconcilierten Codes ausgegeben.

## 8. Reconciled build evidence

Der Projektinhaber hat den MissionDemand-reconcilierten Source-Stand lokal gebaut:

```text
executable source commit:
93cae7cee601f2af242cfcc963accf499ddea7d8

BuilderVersion:
OMW-AIR-TASKING-AAR-ADDITIVE-TEST-3

TestId:
AIR-TASKING-AAR-VERTICAL-3

MissionDemandContract:
CANONICAL_MAIN_SHAPE_READ_ONLY

AARRuntimeDemandTranslation:
true

LegacyAdapterProxyPath:
false

MizMutation:
false
```

Reale Hash-Evidenz:

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

Ein unabhaengiger lokaler `Get-FileHash` bestaetigte denselben Bundle-Hash.

Lokaler Lua-Contract-Test:

```text
NOT RUN - local Lua interpreter unavailable
```

Diese fehlende Evidenz wird nicht als PASS dargestellt.

## 9. Owner decision zum erneuten LISA-Retest

Der Projektinhaber hat am 22.08.2026 entschieden, den bereits entfernten LISA-Acceptance-Harness nicht erneut in die Arbeitsmission einzubauen und den `VERTICAL-3`-DCS-Retest nicht als weiteres Reconciliation-/Merge-Gate zu verlangen.

Damit gilt:

```text
historical VERTICAL-2 DCS evidence: retained for exact tested provenance
reconciled source build: PASS
reconciled bundle hash cross-check: PASS
current reconciled code validated_in_dcs: false
new LISA DCS retest: NOT RUN BY OWNER DECISION
```

Es wird kein neuer DCS-PASS behauptet.

## 10. Bekannte Grenze: shared runtime correlation

Die aktuelle Bridge korreliert einen beobachteten `runtimeId` mit genau einem Air-Tasking-Record:

```text
executionByRuntimeId[runtimeId] -> one record / one EXE
```

Mehrere Air-Tasking-Demands, die denselben bereits laufenden Tanker-Runtime gemeinsam nutzen, sind damit nicht als vollstaendige Mehrfachkorrelation implementiert. Der historische Vertical-Slice pruefte bewusst einen Demand gegen LISA.

Diese Grenze wird in der Main-Reconciliation nicht stillschweigend redesigniert. Eine spaetere Mehrfachnutzung benoetigt eine eigene fachliche Entscheidung und einen separaten Integrations-/Acceptance-Scope.

## 11. ATO-Grenze

Diese Reconciliation implementiert keinen vollstaendigen ATO-Planungszyklus.

Vorhanden beziehungsweise reconciliert ist der vertikale Integrationsbaustein:

```text
MissionDemand
-> Air Support Request
-> Air Tasking Mission
-> Execution Attempt
-> accepted AAR runtime
```

Nicht durch diesen Scope implementiert:

```text
periodische ATO-/Air-Tasking-Plan-Erzeugung
vollstaendiger Tages-/Operationsplan
Player-facing ATO product
allgemeines Retasking mehrerer Missionstypen
```

## 12. Merge-Gates

Vor einer Owner-Mergeentscheidung bleiben mindestens erforderlich:

```text
full fresh-branch diff review against current main
MOOSE project documentation reconciliation
document metadata / document registry reconciliation
real PR creation and subproject registry entry
documentation validator / CI review
available static or syntax checks
owner merge approval
```

Ein Merge nach `main` erfolgt nicht automatisch.
