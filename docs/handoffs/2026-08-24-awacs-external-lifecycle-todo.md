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
PR: #121 – Stage external AWACS lifecycle foundation
Getesteter Source-Stand: 2bda2f066ce1ad11aeed5eb7b98b294d2e399e2d
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 2. Funktionaler DCS-Abschluss

Der Abschlusslauf vom 24.08.2026 bestätigt funktional den wiederhergestellten V3-Lifecycle mit minimaler MOE-Erweiterung:

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

Der zweite AAR ist in der Laufzeitevidenz explizit mit `OMW_AAR_KC135_MOE#001`, `AAR_REFUELED`, `SECOND_CYCLE_COMPLETE` und anschließendem `AAR_RETURN_ON_STATION` belegt.

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

Die Entwicklungsbezeichnung `OMW_AWACS_Foundation.lua` wird jetzt durch ein eigenes Produktionsbundle ersetzt:

```text
tools/build-awacs-base.ps1
-> mission/runtime/air-operations/OMW_AWACS_Base.lua
```

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

`OMW_AAR_Base.lua` bleibt die allgemeine Tankerbasis. `OMW_AWACS_Base.lua` bleibt Eigentümer des validierten WIZARD-spezifischen Lifecycle einschließlich der dedizierten LISA-/MOE-Geometrie. Es wird keine doppelte strategische Ressourcenautorität eingeführt.

## 6. Provenienzstatus

Bekannte reale Buildwerte des getesteten Foundation-Artefakts:

```text
Controller SHA-256:
19da3f455fd01d9a46b20fd748a094873d20bac0c3a8b937976f362e8d06e71a

MOE Relief SHA-256:
8ad43e871980eff4aec4bf9ac8674f3cef763dd35cf78bf5e00592ac5c403d34

Foundation bundle SHA-256:
66f6b33e694098fed0727d7d9b8c72ab32285cc3c608de97ff9d1c6850dcd7dc

Acceptance-4 bundle SHA-256:
23da975a90816569bc7b4269bb7977b2b3e878f9b784005e0993aaaa638cc747
```

DCS/debrief meldet als Mission:

```text
OMW_Template_v20.miz
```

Für eine formale Anhebung zu `ACCEPTED_TECHNICAL_BASELINE` fehlen weiterhin die real gebundenen SHA-256-Werte der exakt ausgeführten finalen MIZ und ihres internen `mission`-Eintrags. Diese werden nicht geraten.

## 7. Noch offen bis Branch-Abschluss

```text
[x] functional full lifecycle DCS run
[x] LISA first AAR
[x] MOE second AAR
[x] both APOC rejoins
[x] final ROSIE egress / external handoff
[x] source architecture frozen on V3 + minimal MOE relief
[x] documentation reconciled for Base productization
[ ] create tools/build-awacs-base.ps1
[ ] update CI and final build verifier to OMW_AWACS_Base.lua
[ ] local Base build and real SHA-256
[ ] replace Foundation with Base in mission editor test copy
[ ] short DCS load/smoke confirmation for renamed Base artifact
[ ] bind final MIZ/internal-mission hashes
[ ] final acceptance metadata reconciliation
[ ] owner authorization for Ready for Review
[ ] merge only after authorization
```

## 8. Entscheidungsgrenze

Es wird ab jetzt **keine weitere Lifecycle- oder Routing-Architektur geändert**, solange ein neuer DCS-Befund dies nicht erzwingt. Die Produktivisierung `Foundation -> Base` ist eine Packaging-/Naming-Änderung auf der funktional bestätigten Source-Logik.
