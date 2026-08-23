---
document_id: OMW-GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-FAIL-1
status: TEST_RESULT
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: cb32f23886e68371bf45ab4f7a1394200f542c29
validated_in_dcs: false
---

# Ground Meta RESUPPLY Acceptance 1 – FAIL 1

## Klassifikation

```text
HARNESS_FALSE_FAIL_OUTBOUND_TIMEOUT_TOO_SHORT
```

Der DCS-Lauf selbst ist durch vollständige Build-/MIZ-/Log-Provenienz gültig. Seine ursprüngliche Interpretation als Routing-FAIL wird jedoch korrigiert: Der Acceptance-Harness setzte nach 600 Simulationssekunden `state.failed=true`, obwohl die konfigurierte Fahrt physikalisch länger benötigt.

Die Owner-Beobachtung, dass der Convoy anschließend Honaker erreichte, aber nicht zurückfuhr, ist damit vereinbar: Die DCS-Gruppe fuhr nach dem Harness-FAIL weiter, während alle späteren Acceptance-Callbacks wegen `state.failed` absichtlich nicht mehr verarbeitet wurden.

## Provenienz

```text
Branch: agent/automatic-response-orchestration
Source/build commit: cb32f23886e68371bf45ab4f7a1394200f542c29
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-1
Bundle SHA-256: BC9A70327A456FC8718907B9701E83194303B0A5816F0EA0C309310D7118B8FE
Builder SHA-256: 68A58E3F2C0C05D79B0FFC642CEDEB70008748FE81EE56D31BE9437CDB070E37
Acceptance source SHA-256: 7B91D5DD74C874C03CB36FAF6CF9231201D45CB51FD749644EDA857A9FFD137E
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Executed mission path from debrief: OMW_Template_v19.miz
Uploaded MIZ SHA-256: A4D04484584A04C092AAFF31981A477F9179203944B7DAAD4C7CF2D2DD8A63FF
Internal mission SHA-256: B68EDC033D9C8E2FE0F8F93C81A063425F019F1C7A38A30710833AD367BCA90A
Embedded acceptance bundle SHA-256: BC9A70327A456FC8718907B9701E83194303B0A5816F0EA0C309310D7118B8FE
Embedded Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 23E2D0B31B66464A57D3BC5F45F92A75D4EF913413833311042CD4BC74F1AAA3
debrief.log SHA-256: 2574F8746F6D4A88E6D6F038AFC33DB5600DC4D52CC6A0E946A8E2155B0D8922
```

## Statischer MIZ-Preflight

Read-only bestätigt:

```text
ResKey_Action_243 -> OMW_Ground_Meta_Resupply_NOTHING_Acceptance_1.lua
triggerOnce
OMW_WAREHOUSE_READY == 1
OMW_GROUND_READY == 1
TIME > 5
embedded bundle hash matches owner build
embedded Moose.lua hash matches pinned MOOSE
no old AMMO/FUEL acceptance bundle embedded
TPL_BLUE_CONVOY_FUEL_LIGHT_06 present
TPL_BLUE_CONVOY_FUEL_LIGHT_06 lateActivation=true
6 units = CHAP_MATV / M978 / MaxxPro / M978 / MaxxPro / CHAP_MATV
ZON_BLUE_GND_JOYCE_ACCESS present
ZON_BLUE_GND_HONAKER_ACCESS present
```

## Runtime

Beobachtete Sequenz bis zum Harness-FAIL:

```text
START
DEMAND_RESERVED quantity=18
PHYSICAL_EXECUTION_READY physicalMission=NOTHING
BRIGADE_STARTED
MISSION_QUEUED type=NOTHING formation=OnRoad speedKt=27
ROAD_ALIGNED_WAREHOUSE_SPAWN units=6 formationLengthM=76.8 maxSnapM=2.1
GROUP_MATERIALIZED transferStatus=LOADING
ARMY_ON_MISSION mission=NOTHING transferStatus=IN_TRANSIT demandStatus=ACTIVE
WARNING TRANSPORT: CREATING PATH MAKES TOO LONG!!!!!
FAIL reason=OUTBOUND_TIMEOUT seconds=600 destinationObserved=false spawnCount=1 armyOnMissionCount=1 missionExecuteCount=0 missionDoneCount=0
```

Die Owner-Beobachtung war anschließend:

```text
Convoy reached Honaker physically
Convoy did not return
```

## Root Cause des fehlenden Returns in diesem Lauf

Die ACCESS-Zentren liegen rund 16,9 km Luftlinie auseinander. Bei 27 kt (~50 km/h) beträgt bereits die theoretische Mindestfahrzeit ohne Straßendetour und Ground-AI-Verlangsamung rund 1.218 Sekunden.

Damit war:

```text
OutboundTimeoutSec = 600
```

für diese Route zu kurz.

Der Acceptance-Code setzt bei Ablauf:

```text
state.failed = true
```

und die nachfolgenden Lifecycle-Callbacks beginnen mit einem `state.failed`-Guard. Deshalb konnten nach dem Timeout keine spätere Zielankunft, `MissionExecute`, Delivery, `MissionDone` oder `RTZ` mehr als Acceptance-Ereignisse verarbeitet werden. Die physische DCS-Gruppe selbst wurde dadurch nicht gestoppt und konnte weiter nach Honaker fahren.

Der Marker `CREATING PATH MAKES TOO LONG!!!!!` bleibt als diagnostische Beobachtung erhalten, ist aber durch diesen Lauf **nicht** als Ursache des fehlenden Returns belegt.

## Aussagegrenze

Dieser Lauf beweist nicht, dass `AUFTRAG:NewNOTHING(...)` für den OMW-Vertrag funktioniert. Er widerlegt es aber auch nicht. Der Test endete vor dem sinnvoll erreichbaren Zielzeitpunkt durch einen Harness-Fehler.

Nicht runtime-validiert bleiben:

```text
NOTHING MissionExecute at Honaker
CampaignState delivery settlement via NOTHING
MissionDone after cancel
same ARMYGROUP RTZ Joyce
Returned / Warehouse AddAsset
```

## Korrektur

```text
OUTBOUND_TIMEOUT_SEC: 600 -> 1800
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-2
DestinationCheckIntervalSec: remains 15
DestinationExecutionGraceSec: remains 90
```

Der 90-s-Fail-fast-Gate bleibt erhalten und greift erst nach tatsächlich beobachtetem Eintritt in die Zielzone.

## Nächster Schritt

```text
OWNER_PULL_BUILD_HASH_GATE
-> Mission Editor bundle replacement by owner
-> read-only MIZ preflight
-> one corrected DCS acceptance run
```
