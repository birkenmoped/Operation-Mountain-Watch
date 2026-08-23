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
source_commit: 9d282bf61e7e54f110b95a4ee9eb2bede01838a5
validated_in_dcs: false
---

# Air Tasking Plan – Main Reconciliation

## 0. Post-Merge-Status

PR #117 wurde nach ausdrücklicher Owner-Freigabe am 23.08.2026 zunächst auf Ready for Review gesetzt und anschließend nach erneutem GitHub-Readback integriert.

```text
PR: 117
status: MERGED
source_head: 0c654f2e699a4b8150b785f90fe14e53d2435016
merge_commit: d1ef605c510917b2e69bfb96c109ad9ff8e26654
reconciled_source_validated_in_dcs: false
```

Die Integration erweitert die historische `VERTICAL-2`-DCS-Evidenz nicht. `VERTICAL-3` bleibt Build-/Hash-/Lua-Contract-Evidenz ohne neuen DCS-PASS. Die dokumentierte Shared-Runtime-Grenze bleibt offen. Aussagen in späteren Abschnitten, die den Owner-Entscheid oder Merge noch als ausstehend beschreiben, sind als historischer Pre-Merge-Stand zu lesen.

## 1. Zweck

Dieser Branch übernimmt den belastbaren Endstand der bisherigen Air-Tasking-Foundation selektiv auf den aktuellen `main`-Stand. Die stark divergierte Entwicklungshistorie von `agent/air-tasking-plan-foundation` wird nicht als Ganzes gemergt.

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

Die Architekturautorität bleibt `docs/88-air-tasking-plan-foundation.md` auf `main`. Dieses Dokument führt keine konkurrierende Architektur ein.

## 2. Übernommener Implementierungsscope

In den frischen Reconciliation-Branch wurden nur die aktuell benötigten Implementierungs- und Testartefakte übernommen:

```text
scripts/air-operations/OMW_AirTasking_AARBridge.lua
scripts/air-operations/OMW_AirTasking_AARBootstrap.lua
mission/tests/air-tasking-aar-vertical/test_bridge.lua
mission/tests/air-tasking-aar-vertical/src/01-air-tasking-aar-vertical-acceptance.lua
tools/build-air-tasking-aar-additive-test.ps1
.github/workflows/air-tasking-validation.yml
```

Die Phase-0/1/2-Arbeitsdokumente des historischen Branches bleiben als Branch-Historie erhalten und werden nicht blind auf `main` portiert. Aktuelle Governance, Register, MissionDemand- und Ground-/AirOps-Baselines auf `main` werden nicht durch alte Branchkopien ersetzt.

## 3. Unveränderte Produktionskomponenten

Dieser Reconciliation-Schritt ändert, ersetzt oder dekoriert keine der folgenden akzeptierten Produktionskomponenten:

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

Die AAR Acceptance-7 bleibt die technische Baseline für den existierenden AAR-Produktionspfad.

## 4. Canonical MissionDemand boundary

Der aktuelle `main`-Vertrag aus `scripts/campaign/OMW_MissionDemand.lua` bleibt autoritativ für MissionDemand-Identität und Campaign-Domain-Status.

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

Die Reconciliation übersetzt deshalb explizit:

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

Terminale MissionDemands (`SUCCESS`, `FAILED`, `EXPIRED`) werden nicht neu für AAR-Unterstützung angenommen. Die produktive MissionDemand-Typmenge auf `main` bleibt unverändert:

```text
RESUPPLY
CAS_IMMEDIATE
```

Dieser Branch fügt keinen separaten `AAR`-MissionDemand-Typ hinzu.

## 5. Additive AAR integration boundary

Die Bootstrap-Schicht setzt voraus, dass die akzeptierte AAR-Facade bereits läuft:

```text
OMW.AirOps.AAR.Status == RUNNING
```

Sie erzeugt keinen zweiten AAR-Stack und keinen Ersatz für den Strategic Adapter.

Runtime-Beobachtung:

```text
existing Controller.GetStation(...)
+ MOOSE SCHEDULER every 5 seconds
+ Air Tasking internal ASR / ATM / EXE correlation
```

Der frühere `GetAdapterModule()`-/`baseAdapterModule`-Proxy-Pfad ist nicht Bestandteil des reconcilierten Codes. Es existiert kein vorgesehener Pfad zum Neuerzeugen, Ersetzen oder Dekorieren der akzeptierten AAR-Strategic-Adapter-Callbacks.

## 6. MOOSE-First Grenze

Physische AAR-Ausführung bleibt beim bestehenden MOOSE-basierten AAR-Pfad. Air Tasking implementiert keinen parallelen Dispatcher für Tanker, kein eigenes Routing und keinen zweiten Assetbestand.

Der additive Observer nutzt `SCHEDULER` mit festem 5-Sekunden-Intervall. Das ist eine kleine Korrelationsschicht über den bereits exponierten `Controller.GetStation(...)`-Zustand; AAR-Lifecycle und strategische Settlement-Events verbleiben beim bestehenden Controller/Adapter.

## 7. Historische DCS-Evidenz

`AIR-TASKING-AAR-VERTICAL-2` wurde auf dem historischen Branch real in DCS bestanden:

```text
executable source commit: 1e52a9a685a58d54d0ebc6321d9b1aa81ab4427d
mission: OMW_Template_v16(6).miz
mission SHA-256: 5bc2382cf6ea30a77297b4ff3b36b65488dbcb34429d02c9618f1f449814dada
bundle SHA-256: 30701722eb739fb17b1f827fc681729a6ee781dedd223eab3b03fc72e78ab8a0
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
result: PASS
```

Der Lauf bestätigte für genau diesen Stand LISA-Reserve-Materialisierung, ASR/ATM/EXE-Korrelation, natürlichen Anflug, Handoff und exact-once AL_UDEID-Recredit. Diese Evidenz bleibt für den damaligen Stand gültig, wird aber nicht als DCS-Validation des reconcilierten Codes ausgegeben.

## 8. Reconciled local build evidence

Der Projektinhaber hat den MissionDemand-reconcilierten Source-Stand lokal gebaut:

```text
executable source commit: 93cae7cee601f2af242cfcc963accf499ddea7d8
BuilderVersion: OMW-AIR-TASKING-AAR-ADDITIVE-TEST-3
TestId: AIR-TASKING-AAR-VERTICAL-3
MissionDemandContract: CANONICAL_MAIN_SHAPE_READ_ONLY
AARRuntimeDemandTranslation: true
LegacyAdapterProxyPath: false
MizMutation: false
```

Reale lokale Hash-Evidenz:

```text
AirTaskingBridgeSHA256: 7054d2a88262dba5546e13fe3dd51f01cdbd1a9efcabc41031b063c5336bb66f
AirTaskingBootstrapSHA256: 81876fed138533d667aa1f6bcbde2d232cd1bf49a54b83b54464cefb2da5f12a
HarnessSHA256: 01ab6f5d5bf65c9d64a656d338a39eac67b063afa38ec02f95325c1974f1cb11
BundleSHA256: dc840397ca311802cee99cf98f7448c0371ce40388f324b31dd01de7bf1c82f3
```

Der unabhängige lokale `Get-FileHash` bestätigte denselben Bundle-Hash. Ein lokaler Lua-Interpreter war nicht vorhanden; deshalb wurde lokal kein Lua-Contract-PASS behauptet.

## 9. PR-#117-CI-Evidenz

Für PR #117 wurde ein eigener Air-Tasking-Workflow ergänzt. Der reale GitHub-Actions-Lauf auf dem PR-Merge-Ref meldete:

```text
Air Tasking validation: PASS
Lua 5.1 bridge contract: AIR_TASKING_AAR_BRIDGE_TEST_PASS
PowerShell bundle build: PASS
MissionDemandContract: CANONICAL_MAIN_SHAPE_READ_ONLY
AARRuntimeDemandTranslation: true
MizMutation: false
ExistingAARBaseEmbedded: false
ExistingAARBaseRecreated: false
ExistingAARAdapterRecreated: false
ExistingAARAdapterMutated: false
LegacyAdapterProxyPath: false
```

Der im selben CI-Lauf erzeugte Bundle-Hash wurde unabhängig mit `sha256sum` gegengeprüft und stimmte mit dem Builder-Output überein.

Die repositoryweite `Documentation validation` ist in PR #117 rot, jedoch ausschließlich wegen 18 bereits auf `main` vorhandener Ground-Metadaten-/Acceptance-Provenienzfehler. Der Validator meldete `0 warning(s)` und keinen Fehler in einer Air-Tasking-Datei dieses PR oder in der aktuellen Übergabedatei. Diese fremden Ground-Fehler werden in PR #117 bewusst nicht repariert.

## 10. Owner decision zum erneuten LISA-Retest

Der Projektinhaber hat am 22.08.2026 entschieden, den bereits entfernten LISA-Acceptance-Harness nicht erneut in die Arbeitsmission einzubauen und den `VERTICAL-3`-DCS-Retest nicht als weiteres Reconciliation-/Merge-Gate zu verlangen.

Damit gilt:

```text
historical VERTICAL-2 DCS evidence: retained for exact tested provenance
reconciled source local build/hash: PASS
reconciled bridge contract in CI: PASS
current reconciled code validated_in_dcs: false
new LISA DCS retest: NOT RUN BY OWNER DECISION
```

Es wird kein neuer DCS-PASS behauptet.

## 11. Bekannte Grenze: shared runtime correlation

Die aktuelle Bridge korreliert einen beobachteten `runtimeId` mit genau einem Air-Tasking-Record:

```text
executionByRuntimeId[runtimeId] -> one record / one EXE
```

Mehrere Air-Tasking-Demands, die denselben bereits laufenden Tanker-Runtime gemeinsam nutzen, sind damit nicht als vollständige Mehrfachkorrelation implementiert. Der historische Vertical-Slice prüfte bewusst einen Demand gegen LISA.

Diese Grenze wird in der Main-Reconciliation nicht stillschweigend redesigniert. Eine spätere Mehrfachnutzung benötigt eine eigene fachliche Entscheidung und einen separaten Integrations-/Acceptance-Scope.

## 12. ATO-Grenze

Diese Reconciliation implementiert keinen vollständigen ATO-Planungszyklus.

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
vollständiger Tages-/Operationsplan
Player-facing ATO product
allgemeines Retasking mehrerer Missionstypen
```

## 13. Finaler Diff-Review und Merge-Grenze

Der vollständige PR-#117-Diff gegen aktuellen `main` wurde erneut geprüft. Der Branch ist `ahead` und `behind_by=0`; die akzeptierten AAR-Produktionsdateien und `OMW_MissionDemand.lua` erscheinen nicht im Änderungsumfang.

Für den aktuellen Scope wurden keine neuen blockierenden Air-Tasking-Codefehler festgestellt. Die dokumentierte shared-runtime-Grenze bleibt bewusst offen und wird nicht als verdeckter Merge-Blocker umgedeutet.

Gemäß `docs/DOCUMENT-METADATA-POLICY.md` ist `source_commit: 121edd572f596e9a156c6c9137e24f5c9fdc72cc` auf einem offenen PR-Branch zulässig. Der Wert bleibt bis zur tatsächlichen Integration bestehen und darf auf `main` anschließend nicht verbleiben.

Vor einer Integration ist damit nur noch die ausdrückliche Owner-Freigabe für `Ready for Review` beziehungsweise Merge erforderlich. Der aktuelle GitHub-`mergeable`-Status ist unmittelbar vor einer tatsächlichen Integration erneut real zu lesen; er wird nicht als statische Eigenschaft dieses Dokuments behandelt.

## 14. Übergabe und aktualisierte TODO-Liste

Der vollständige Übergabestand mit Ziel, aktuellem Status, Entscheidungen, Fehlern, Lösungen, Evidenz, lokalen Worktree-Hinweisen und den verbleibenden Schritten bis zur Integration ist hier dokumentiert:

- [`OMW-HANDOFF-AIR-TASKING-MAIN-RECONCILIATION-2026-08-22`](handoffs/2026-08-22-air-tasking-plan-main-reconciliation-handoff.md)

Diese Übergabe ist für die Fortsetzung maßgeblich, ersetzt aber keine BINDING-Governance- oder Architekturentscheidung.
