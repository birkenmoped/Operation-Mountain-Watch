---
document_id: OMW-HANDOFF-AWACS-EXTERNAL-LIFECYCLE-TODO-2026-08-24
status: PLANNED
document_class: HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS external lifecycle completion record
  - PR 121 merge and post-merge production provenance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: main
source_commit: 837ce24aee76c85efa008cd404afc3e4e5aed383
validated_in_dcs: true
---

# AWACS External Lifecycle – Produktivisierung zu `OMW_AWACS_Base.lua`

## 1. Integrierter Stand

```text
Merged PR: #121 – Stage external AWACS lifecycle base
Main merge commit: 837ce24aee76c85efa008cd404afc3e4e5aed383
Getesteter Source-Lifecycle-Stand: 2bda2f066ce1ad11aeed5eb7b98b294d2e399e2d
Base-Package-Stand vor Merge: c738052037c741f4b52cc6d2f0c818a6b24babc5
Finaler Review-Stand: 8b264ec0ffcb2c50a29074245e2578bc72b47083
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 2. Funktionaler DCS-Abschluss

Der vollständige Lauf vom 24.08.2026 bestätigt funktional den wiederhergestellten V3-Lifecycle mit minimaler MOE-Erweiterung:

```text
WIZARD external spawn
-> ROSIE ingress
-> FL350 / 270 KIAS
-> APOC FL320 / 250 KIAS
-> LISA planned AAR
-> Refueled
-> APOC rejoin / sensor restore
-> MOE planned second AAR
-> Refueled
-> APOC rejoin / sensor restore
-> ROSIE outbound
-> external handoff
-> despawn / strategic recredit
```

Der zweite AAR ist in der Laufzeitevidenz mit `OMW_AAR_KC135_MOE#001`, `AAR_REFUELED`, `SECOND_CYCLE_COMPLETE` und anschließendem `AAR_RETURN_ON_STATION` belegt.

## 3. Erfolgreiche Architektur

```text
Controller:
OMW_AWACS_Controller_FullLifecycle_V3.lua

Minimal extension:
OMW_AWACS_MOE_Relief.lua

AAR 1:
LISA

AAR 2:
MOE

Dedicated tanker geometry for both:
33.6233926368 N / 68.6395554105 E
FL250 / 270 KIAS / 340T / 20 NM
```

Der verworfene V4-/Live-Retask-Pfad mit `ClearWaypoints()` ist nicht Bestandteil des finalen Stands.

## 4. Produktivartefakt

```text
tools/build-awacs-base.ps1
-> mission/runtime/air-operations/OMW_AWACS_Base.lua
```

Der frühere Einstieg `tools/build-awacs-foundation.ps1` ist nur noch ein Kompatibilitätswrapper und delegiert an den Base-Builder.

Die AWACS-Base enthält Produktionscode für CampaignState-Integration, strategische AWACS-Bestandsinitialisierung, WIZARD-Lifecycle, LISA/MOE-AAR, Service-/Sensorzustand, APOC-Rejoin und External Handoff/Recredit. Acceptance-Code, V4-Controller, AARDemandAdapter und `ClearWaypoints`-Live-Retask sind nicht Bestandteil der Base.

## 5. Mission-Ladeordnung

```text
Moose.lua
shared common foundations
OMW_AAR_Base.lua
OMW_AWACS_Base.lua
other AirOps systems
```

`OMW_AAR_Base.lua` bleibt die allgemeine Tankerbasis. `OMW_AWACS_Base.lua` bleibt Eigentümer des WIZARD-spezifischen Lifecycle einschließlich der dedizierten LISA-/MOE-Geometrie. CampaignState bleibt strategische Ressourcenautorität.

## 6. Base- und Mission-Provenienz vor Merge

Real lokal gebauter und anschließend in DCS gesmoketesteter Base-Stand:

```text
BuilderVersion: OMW-AIROPS-AWACS-BASE-1
Git commit: c738052037c741f4b52cc6d2f0c818a6b24babc5
Base SHA-256:
c4e2ab13c2a3be9165993bb4f92bb1b81e34cddfd9dee0e0e7139a12a97ca213
Controller SHA-256:
19da3f455fd01d9a46b20fd748a094873d20bac0c3a8b937976f362e8d06e71a
MOE Relief SHA-256:
8ad43e871980eff4aec4bf9ac8674f3cef763dd35cf78bf5e00592ac5c403d34
```

Gebundene Mission des Base-Smoke-Tests:

```text
Mission: OMW_Template_v20.miz
MIZ SHA-256:
22220f7c7686228897ac6e7fc0f7bb34ce068cc929a6b7fcf08213f8f5b2be0c
internal mission SHA-256:
ed02eab1ffc4c353ee16f929d44f3c55fe28093b78ea80508f2fa71fd692775f
embedded Base SHA-256:
c4e2ab13c2a3be9165993bb4f92bb1b81e34cddfd9dee0e0e7139a12a97ca213
```

## 7. Base-Packaging-Smoke-Test

Der DCS-Smoke-Lauf mit `OMW_AWACS_Base.lua` war erfolgreich. Belegt wurden Base-Load, V3-Controllerstart, AWACS-Bootstrap, MOE-Relief-Start, WIZARD-Materialisierung, APOC-Orbit und Acceptance-4-Telemetrie ohne AWACS-bezogenen Lua-Abbruch im untersuchten Zeitfenster.

## 8. Finaler PR-/CI-Review

Aktuelle Produktionswerte wurden vor Merge in den zuständigen verbindlichen Dokumenten reconciliert:

```text
WIZARD transit: FL350 / 270 KIAS
APOC:           FL320 / 250 KIAS / 017T / 30 NM
AAR 1:          LISA
AAR 2:          MOE
AAR track:      FL250 / 270 KIAS / 340T / 20 NM
```

CI für Review-Head `8b264ec0ffcb2c50a29074245e2578bc72b47083`:

```text
AWACS validation run #92: SUCCESS
Documentation validation run #1134: FAILURE
- 18 pre-existing ARMY-ground metadata/provenance errors
- 0 AWACS documentation errors
```

## 9. Merge und post-merge Main-Build

Der Projektinhaber gab zunächst Ready for Review und anschließend den Merge frei. PR #121 wurde auf `main` gemerged.

```text
Main merge commit:
837ce24aee76c85efa008cd404afc3e4e5aed383
```

Der reale lokale post-merge Build wurde aus einem eigenen `main`-Worktree ausgeführt:

```text
Worktree: P:\DCS-DEV\Operation-Mountain-Watch-main
Branch: main
HEAD: 837ce24aee76c85efa008cd404afc3e4e5aed383
BuilderVersion: OMW-AIROPS-AWACS-BASE-1
GitCommit embedded in generated Base: 837ce24aee76c85efa008cd404afc3e4e5aed383
Base SHA-256:
510c876ff132d0ec612bb6e719529836fe21b4163ab9143d9e27495a6c4d4be3
```

Alle eingebundenen Source-Komponenten besitzen im post-merge Build weiterhin exakt dieselben SHA-256-Werte wie im vor dem Merge DCS-gesmoketesteten Base-Build, insbesondere:

```text
Controller SHA-256:
19da3f455fd01d9a46b20fd748a094873d20bac0c3a8b937976f362e8d06e71a
MOE Relief SHA-256:
8ad43e871980eff4aec4bf9ac8674f3cef763dd35cf78bf5e00592ac5c403d34
Bootstrap SHA-256:
ea5d624c15f8aa2b07d8c41b877f57422f5163fc93263f5fe472d77b113578eb
```

Der geänderte Base-Bundle-Hash entsteht durch die Build-Provenienz im generierten Header (`GitCommit` und `SourceCommitUtc`) des post-merge Builds. Er ist deshalb nicht als neue fachliche Source-Änderung zu interpretieren.

## 10. Abschlussstand

```text
[x] functional full lifecycle DCS run
[x] LISA first AAR
[x] MOE second AAR
[x] both APOC rejoins
[x] final ROSIE egress / external handoff
[x] source architecture frozen on V3 + minimal MOE relief
[x] production Base builder
[x] Foundation compatibility wrapper
[x] Base MIZ integration
[x] Base packaging smoke test
[x] final PR diff / binding-document reconciliation
[x] final AWACS CI review
[x] owner Ready-for-Review authorization
[x] PR #121 Ready for Review
[x] owner merge authorization
[x] PR #121 merged to main
[x] post-merge main build and real Base SHA-256
```

Die AWACS-Produktivisierung ist damit abgeschlossen. Der post-merge Base-Hash ist als Build-Provenienz dokumentiert; ein erneuter vollständiger DCS-Lifecycle ist durch diesen reinen Header-/Provenienzunterschied nicht automatisch impliziert.
