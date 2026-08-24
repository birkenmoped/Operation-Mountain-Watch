---
document_id: OMW-HANDOFF-AWACS-EXTERNAL-LIFECYCLE-TODO-2026-08-24
status: PLANNED
document_class: HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local AWACS external lifecycle completion order
  - current progress and remaining work for PR 121
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# AWACS External Lifecycle – Produktivisierung zu `OMW_AWACS_Base.lua`

## 1. Aktueller Branch

```text
Branch: agent/awacs-external-lifecycle-foundation
PR: #121 – Stage external AWACS lifecycle base
Getesteter Source-Lifecycle-Stand: 2bda2f066ce1ad11aeed5eb7b98b294d2e399e2d
Base-Package-Stand: c738052037c741f4b52cc6d2f0c818a6b24babc5
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

Die Entwicklungsbezeichnung `OMW_AWACS_Foundation.lua` ist durch ein eigenes Produktionsbundle abgelöst:

```text
tools/build-awacs-base.ps1
-> mission/runtime/air-operations/OMW_AWACS_Base.lua
```

Der frühere Einstieg `tools/build-awacs-foundation.ps1` ist nur noch ein Kompatibilitätswrapper und delegiert an den Base-Builder.

Die AWACS-Base enthält ausschließlich Produktionscode für:

```text
CampaignState integration
strategic AWACS stock initialization
WIZARD full lifecycle
LISA first planned AAR
MOE second planned AAR
service/sensor state
APOC rejoin
external handoff / recredit
```

Nicht Bestandteil der Base:

```text
OMW_AWACS_Acceptance_4.lua
Acceptance 5 matrix
V4 controller
AARDemandAdapter
ClearWaypoints live retask
```

## 5. Mission-Ladeordnung

```text
Moose.lua
shared common foundations
OMW_AAR_Base.lua
OMW_AWACS_Base.lua
other AirOps systems
```

`OMW_AAR_Base.lua` bleibt die allgemeine Tankerbasis. `OMW_AWACS_Base.lua` bleibt Eigentümer des WIZARD-spezifischen Lifecycle einschließlich der dedizierten LISA-/MOE-Geometrie. Es wird keine doppelte strategische Ressourcenautorität eingeführt.

## 6. Reale Base-Provenienz

Lokaler Build des Produktionsartefakts:

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

Gebundene Mission nach Mission-Editor-Umstellung auf `OMW_AWACS_Base.lua`:

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

Der DCS-Smoke-Lauf mit der neuen `OMW_AWACS_Base.lua` war erfolgreich.

Belegte Runtime-Sequenz:

```text
22:06:45 AWACS.FullLifecycleV3 MATERIALIZED runtime=AWACS-0001
22:06:45 AWACS.FullLifecycleV3 STARTED mode=FULL_FUEL_DRIVEN_AAR_V5
22:06:45 AirOps.AWACS.Bootstrap RUNNING ... area=APOC fir=ROSIE
22:06:45 AWACS.MOERelief STARTED mode=MINIMAL_SECOND_TANKER_ONLY
22:06:58 AWACS.FullLifecycleV3 PERSISTENT_ORBIT ... altitudeFt=32000 speedKIAS=250
22:06:58 AWACS.FullLifecycleV3 LATE_APPROACH_PASSED ... action=ADD_PERSISTENT_ORBIT
22:06:58 AWACS.Acceptance4 SERVICE_STATE ... INBOUND -> STANDBY
22:06:58 AWACS.Acceptance4 TELEMETRY ... runtime=AWACS-0001
22:12:00 AWACS.FullLifecycleV3 EGRESS_ORDERED ... target=ROSIE
```

Damit ist die Packaging-/Load-Grenze der neuen Base in DCS bestätigt. Im untersuchten Smoke-Zeitfenster wurde kein AWACS-bezogener `SCRIPTING ERROR`, `stack traceback` oder nil-Zugriffsfehler gefunden.

## 8. Aktueller Abschlussstand

```text
[x] functional full lifecycle DCS run
[x] LISA first AAR
[x] MOE second AAR
[x] both APOC rejoins
[x] final ROSIE egress / external handoff
[x] source architecture frozen on V3 + minimal MOE relief
[x] documentation reconciled for Base productization
[x] create tools/build-awacs-base.ps1
[x] deprecate foundation builder to compatibility wrapper
[x] update CI and final build verifier to OMW_AWACS_Base.lua
[x] local Base build and real SHA-256
[x] replace Foundation with Base in mission editor test copy
[x] short DCS load/smoke confirmation for renamed Base artifact
[x] bind final MIZ/internal-mission hashes for Base smoke test
[x] document Base smoke result
[ ] final PR diff / CI reconciliation
[ ] owner authorization for Ready for Review
[ ] merge only after authorization
```

## 9. Entscheidungsgrenze

Es wird keine weitere Lifecycle- oder Routing-Architektur geändert, solange ein neuer DCS-Befund dies nicht erzwingt. Die Produktivisierung `Foundation -> Base` ist abgeschlossen. Offen sind nur noch der finale PR-/CI-Review und die explizite Owner-Freigabe für Ready for Review beziehungsweise Merge.
