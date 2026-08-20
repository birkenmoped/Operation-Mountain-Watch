---
document_id: OMW-GROUND-PRODUCTION-BASE
status: PLANNED
document_class: GROUND_RUNTIME_PACKAGING
owning_policy: OMW-GOV-001
authoritative_for:
  - production packaging contract for the accepted ARMY Ground strategic foundation
  - Ground production bundle path, load contract and readiness flags
not_authoritative_for:
  - new Ground-order generation
  - Mission Editor template placement
  - new MOOSE Ground lifecycle behavior
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-production-base
source_commit: 9b85bbf00e79a99ac747546eae30ce0341d154c6
validated_in_dcs: false
---

# ARMY Ground Production Base

## Zweck

Die bereits nach `main` integrierte ARMY-Ground-Foundation wird als dauerhaft ladbares Produktionsbundle paketiert. Das Bundle ersetzt keine Acceptance-Harnesses durch neue Logik, sondern bündelt ausschließlich die bereits akzeptierten produktiven Ground-Module hinter einem stabilen Einstiegspunkt.

## Produktionsquellen

```text
scripts/logistics/OMW_GroundInitialStock.lua
scripts/ground/OMW_GroundCampaignStateAdapter.lua
scripts/ground/OMW_GroundRuntimeIntegration.lua
scripts/ground/OMW_GroundBase.lua
```

`CampaignState` bleibt alleinige strategische Ressourcenautorität. Die Ground Production Base erzeugt keinen zweiten Store und enthält keine MOOSE-/DCS-Spawn-, Routing-, Warehouse- oder Schedulerlogik.

## Builder und Artefakt

Builder:

```text
tools/build-ground-production-base.ps1
```

Generiertes Artefakt:

```text
mission/ground-operations/dist/OMW_Ground_Base.lua
```

Der Builder ist per Git-Commit deterministisch: Der Bundle-Inhalt enthält keine Buildzeit. Das Artefakt wird lokal erzeugt und ist nicht als eigenständige strategische Quelle autoritativ.

## Load- und Ready-Vertrag

Nach Laden des Bundles gilt:

```text
OMW.Ground.Base
OMW_GROUND_BASE_LOADED = 1
OMW_GROUND_READY = 0
```

Erst ein erfolgreicher Aufruf von:

```lua
OMW.Ground.Base.Attach({
  store = CampaignStateStore,
  campaignState = CampaignState,
  restored = false,
})
```

setzt:

```text
OMW_GROUND_READY = 1
```

Bei RESTORE wird `restored = true` übergeben; die vorhandene `GroundRuntimeIntegration` führt dann die bereits akzeptierte Restart-Reconciliation aus. Die Production Base selbst führt keine physische DCS-/MOOSE-Fortsetzung oder Respawns durch.

## Strategische Ground-Nodes

```text
GROUND_NODE_JALALABAD
GROUND_NODE_FORTRESS
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_HONAKER
GROUND_NODE_BOSTICK
```

Die bestehenden Settlement-Regeln bleiben unverändert, darunter der derzeit akzeptierte Motorized-Patrol-Vertrag:

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
```

## Mission-Editor-Grenze

Die folgenden physischen Darstellungen bleiben Mission-Editor-Assets und werden von `OMW_Ground_Base.lua` nicht erzeugt:

```text
TPL_BLUE_GND_PATROL_*
TPL_BLUE_GND_QRF_*
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2
```

Insbesondere bleiben die standortgebundenen ARTY-/Mörsergruppen an ihren exakten Mission-Editor-Stellungen.

## Lokale Build-Verifikation 21.08.2026

Vom Projektinhaber auf dem Branch `agent/ground-production-base` ausgeführt:

```text
GitCommit: 9b85bbf00e79a99ac747546eae30ce0341d154c6
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-1
GroundBaseSchema: OMW-GROUND-PRODUCTION-BASE-1
Bundle: mission/ground-operations/dist/OMW_Ground_Base.lua
Length: 23038 bytes
Builder SHA-256: e8a007030e2d05d9054a1131dba33a331cd296a35971d598646a09de52dd7076
Independent SHA-256: e8a007030e2d05d9054a1131dba33a331cd296a35971d598646a09de52dd7076
GroundLifecycleMutation: false
MOOSEOverride: false
MizMutation: false
```

Die Build- und Independent-Hashes stimmen überein. Dies ist ein Packaging-/Build-Nachweis, kein neuer DCS-Runtime-Nachweis.

## Testgrenze

Die zugrunde liegenden Ground-Lifecycle- und Settlement-Pfade sind durch die bereits gemergten Acceptance-Stände der ARMY Ground Foundation belegt. Dieses Production-Bundle führt keine neue physische MOOSE-/DCS-Funktion ein.

Falls später ein neuer produktiver Startup-Pfad zusammen mit weiteren Ground-Runtime-Komponenten in DCS geprüft werden muss, erfolgt dies nicht als neue Einzelabnahme, sondern als gebündelte Ground-Integrations-/Sammelmission.

## Offener Abschluss

Vor Merge dieses Packaging-Branches sind noch erforderlich:

```text
- vollständiger Diff gegen main
- git diff --check
- erneuter lokaler Builder-/Hash-Nachweis auf dem finalen Branch-Head
- Review des Load-/Ready-Vertrags
- ausdrückliche Projektinhaberfreigabe für Ready for Review und Merge
```
