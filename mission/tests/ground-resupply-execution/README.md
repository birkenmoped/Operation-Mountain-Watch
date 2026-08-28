---
document_id: OMW-TEST-GROUND-RESUPPLY-EXECUTION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local test package for physical MissionDemand-driven Ground RESUPPLY execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: dac19985de5ecae89b6948854e4a4bd5906f765b
validated_in_dcs: partial
---

# Ground RESUPPLY Execution

## Zweck

Dieses Testpaket prüft MissionDemand-/CampaignState-gekoppelte physische Ground-RESUPPLY-Pfade. CampaignState bleibt strategische Ressourcenautorität; MOOSE übernimmt die physische Ausführung.

## Stage 1A – AMMO / akzeptiert

```text
GROUND_NODE_HONAKER
GROUND_AMMO_PACKAGE
40 -> 20 -> 40
CampaignState TRANSFER 20 from GROUND_NODE_JOYCE
TPL_BLUE_CONVOY_LIGHT_06
AUFTRAG AMMOSUPPLY
OnRoad 27 kt
30 s MissionDone -> RTZ settlement
same ARMYGROUP return
Returned -> Warehouse AddAsset -> physical cleanup
```

Status: `ACCEPTED_TECHNICAL_BASELINE`.

```text
src/01-ground-ammo-resupply-acceptance.lua
ACCEPTANCE-1.md
results/2026-08-22-ground-ammo-resupply-acceptance-1-pass-1.md
tools/build-ground-ammo-resupply-acceptance-1.ps1
```

## Stage 1B – FUELSUPPLY / geschlossen

Der Versuch, die abstrakte CampaignState-Meta-Ware `GROUND_FUEL_PACKAGE` mit `AUFTRAG:NewFUELSUPPLY(...)` als Warehouse-to-Warehouse-Roundtrip auszuführen, ist für diesen OMW-Scope fehlgeschlagen. `FUELSUPPLY` bleibt als MOOSE-API bestehen, wird für diesen OMW-Meta-RESUPPLY-Executor aber nicht weiterverwendet.

```text
src/02-ground-fuel-resupply-acceptance.lua
ACCEPTANCE-2.md
results/2026-08-22-ground-fuel-resupply-acceptance-1-fail-1.md
tools/build-ground-fuel-resupply-acceptance-1.ps1
```

## Stage 1C – generischer Meta-RESUPPLY / AUFTRAG NOTHING

Owner-approved physical contract vom 22.08.2026:

```text
CampaignState meta-resource shortage
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER
-> existing resource-appropriate convoy template
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(destination ACCESS zone)
-> destination-zone proof
-> CampaignState DELIVERED / MissionDemand SUCCESS
-> mission cancel / MissionDone
-> same ARMYGROUP RTZ origin
-> Returned -> Warehouse AddAsset
```

Erster Fixture:

```text
RESOURCE: GROUND_FUEL_PACKAGE
JOYCE 40 -> 22
HONAKER 36 -> 18 -> 36
TEMPLATE: TPL_BLUE_CONVOY_FUEL_LIGHT_06
PHYSICAL MISSION: AUFTRAG NOTHING
```

`AUFTRAG NOTHING` trägt keine strategische Fuel-/Cargo-Menge. Der sichtbare M978-Konvoi ist ausschließlich physische Repräsentation.

### Run 1 – Harness-FALSE-FAIL

Builder `GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-1` verwendete `OutboundTimeoutSec = 600`. Das war für Joyce -> Honaker zu kurz: rund 16,9 km Luftlinie bedeuten bei 27 kt bereits theoretisch rund 1.218 s Mindestfahrzeit.

Der Harness setzte nach 600 s `state.failed=true`. Der Convoy fuhr laut Owner-Beobachtung danach physisch bis Honaker weiter, aber spätere MissionExecute-/Delivery-/MissionDone-/RTZ-Callbacks wurden wegen des bereits gesetzten FAIL-Zustands nicht mehr verarbeitet.

```text
Run-1 classification: HARNESS_FALSE_FAIL_OUTBOUND_TIMEOUT_TOO_SHORT
NewNOTHING runtime acceptance: NOT YET PROVEN
```

Ergebnis:

```text
results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-fail-1.md
```

### Korrigierter Harness

```text
BuilderVersion = GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-2
OutboundTimeoutSec = 1800
DestinationCheckIntervalSec = 15
DestinationExecutionGraceSec = 90
ReturnTimeoutSec = 1800
ReturnIssueDelaySec = 30
ReturnSettlementDelaySec = 12
```

Der Fail-fast-Gate bleibt erhalten: Nach tatsächlichem Eintritt in Honaker ACCESS muss `MissionExecute` binnen 90 Sekunden folgen.

Dateien:

```text
src/03-ground-meta-resupply-nothing-acceptance.lua
ACCEPTANCE-3.md
tools/build-ground-meta-resupply-nothing-acceptance-1.ps1
```

Status: `CORRECTED / OWNER BUILD PENDING / DCS RETEST PENDING`.

## MOOSE-First

Pinned MOOSE:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Technische Review:

```text
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
```

Kein eigener Convoy-Dispatcher, kein MIST, kein nativer DCS-Eventlayer, kein OPSTRANSPORT, keine zweite Ressourcenautorität und keine `.miz`-Mutation durch ChatGPT.
