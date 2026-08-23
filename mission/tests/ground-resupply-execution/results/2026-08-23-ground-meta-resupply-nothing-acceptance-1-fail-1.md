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
FAIL
```

Der Test ist nach nachträglichem read-only MIZ-Preflight für die hochgeladene ausgeführte Arbeitsmission als gültiger technischer FAIL klassifiziert. `AUFTRAG:NewNOTHING(...)` wurde materialisiert und dem ARMYGROUP zugewiesen, aber der Convoy erreichte die Honaker-ACCESS-Zone innerhalb des Acceptance-Fensters nicht.

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

Beobachtete Sequenz:

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

Nicht erreicht:

```text
DESTINATION_OBSERVED
MissionExecute
DELIVERY_CONFIRMED
MissionDone
RTZ
Returned
Warehouse AddAsset
```

## Bewertung

Dieser Lauf widerlegt nicht die source-seitige Verfügbarkeit von `AUFTRAG:NewNOTHING(...)`, zeigt aber, dass der aktuelle OMW Joyce->Honaker NOTHING-Pfad den bestehenden Ground-Routingvertrag nicht erfolgreich bis zur Zielzone ausführt.

Der auffällige DCS-Marker `CREATING PATH MAKES TOO LONG!!!!!` erscheint unmittelbar nach `ARMY_ON_MISSION`. Die nächste Untersuchung muss deshalb den tatsächlich erzeugten Ground-Route/Waypoint-Pfad von NOTHING mit dem DCS-bestätigten AMMOSUPPLY-Pfad vergleichen. Keine Timer-, Radius- oder Warehouse-Verschiebung auf Verdacht.

## Nächster freigegebener Schritt

```text
COMPARE_AMMOSUPPLY_VS_NOTHING_GROUND_ROUTE_GENERATION
```

Kein weiterer DCS-Lauf, bevor der Routing-Unterschied source-seitig erklärt und der kleinste belegbare Fix festgelegt ist.
