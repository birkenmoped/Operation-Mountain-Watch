---
document_id: OMW-GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local acceptance plan and result for generic MissionDemand-driven Ground meta-resource RESUPPLY via AUFTRAG NOTHING
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground Meta RESUPPLY Acceptance 1 – AUFTRAG NOTHING

## 1. Owner-Entscheidung

Am 22.08.2026 hat der Projektinhaber den physischen Vertrag für `AUFTRAG:NewNOTHING(...)` als Ersatzkandidaten für abstrakte Ground-Meta-Waren bestätigt.

Der fehlgeschlagene `AUFTRAG:NewFUELSUPPLY(...)`-Pfad bleibt historische Negativ-Evidenz und wird nicht überschrieben.

## 2. Ziel

Erster Fixture bleibt bewusst `GROUND_FUEL_PACKAGE`, um gegenüber Stage 1B nur die physische Missionssemantik zu wechseln:

```text
HONAKER FUEL 36
-> test-only consumption 18
-> HONAKER FUEL 18 / REORDER
-> one MissionDemand RESUPPLY
-> CampaignState TRANSFER 18 Joyce -> Honaker
-> TPL_BLUE_CONVOY_FUEL_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(Honaker ACCESS)
-> OnRoad 27 kt
-> exact destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> mission cancel / MissionDone
-> 30 s settlement
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Erwarteter strategischer Endzustand:

```text
JOYCE FUEL   40 -> 22
HONAKER FUEL 36 -> 18 -> 36
```

## 3. Architekturgrenze

```text
CampaignState = alleinige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Zustand
AUFTRAG NOTHING = nur neutrale physische Bewegung / Aufenthalt
DCS group = temporäre physische Repräsentation
```

Nicht definiert:

```text
DCS fuel quantity
1 M978 = X GROUND_FUEL_PACKAGE
FUEL_LIGHT_06 capacity
physical cargo authority
```

## 4. MOOSE-First Nachweis

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Source-seitig bestätigt:

```lua
AUFTRAG:NewNOTHING(RelaxZone)
```

sowie `AUFTRAG.Type.NOTHING`, `AUFTRAG.SpecialTask.NOTHING`, Ground/Naval-Kategorie, zone objective, FullStop bei Ausführung und TaskCancel->TaskDone. Eine dedizierte offizielle Demo für den OMW-Roundtrip ist nicht belegt.

## 5. Physischer Vertrag

```text
PLATOON:AddMissionCapability(AUFTRAG.Type.NOTHING, 100)
AUFTRAG:NewNOTHING(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:AddMission(...)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird unverändert wiederverwendet.

## 6. Timeout-/Fail-fast-Vertrag

Der erste Stage-1C-Build verwendete `OutboundTimeoutSec = 600`. Das war ein Harness-Fehler: Joyce-ACCESS zu Honaker-ACCESS liegen bereits Luftlinie rund 16,9 km auseinander. Bei 27 kt (~50 km/h) beträgt die theoretische Mindestfahrzeit ohne Straßendetour und AI-Verlangsamung rund 1.218 s. Der 600-s-Timeout musste daher vor einer normalen Ankunft auslösen.

Nach `fail()` setzt der Harness `state.failed=true`; alle nachfolgenden MissionExecute-/MissionDone-/RTZ-Callbacks verlassen den Test dann absichtlich. Das erklärt den beobachteten Lauf: Der bereits geroutete Convoy fuhr physisch weiter nach Honaker, konnte nach dem vorzeitigen Test-FAIL aber keine Delivery-/Return-Kette mehr auslösen.

Korrigierter Vertrag:

```text
OutboundTimeoutSec = 1800
DestinationCheckIntervalSec = 15
DestinationExecutionGraceSec = 90
```

Der 1800-s-Wert entspricht wieder dem bereits in Stage 1A verwendeten Outbound-Fenster. Der eigentliche Fail-fast-Schutz bleibt erhalten: Erst nach tatsächlichem Eintritt in Honaker ACCESS muss `MissionExecute` binnen 90 Sekunden folgen; andernfalls `DESTINATION_EXECUTION_TIMEOUT`.

## 7. Build- und MIZ-Provenienz des Fehlversuchs

```text
Source/build commit: cb32f23886e68371bf45ab4f7a1394200f542c29
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-1
Bundle SHA-256: BC9A70327A456FC8718907B9701E83194303B0A5816F0EA0C309310D7118B8FE
Builder SHA-256: 68A58E3F2C0C05D79B0FFC642CEDEB70008748FE81EE56D31BE9437CDB070E37
Acceptance source SHA-256: 7B91D5DD74C874C03CB36FAF6CF9231201D45CB51FD749644EDA857A9FFD137E
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
Uploaded executed MIZ SHA-256: A4D04484584A04C092AAFF31981A477F9179203944B7DAAD4C7CF2D2DD8A63FF
Internal mission SHA-256: B68EDC033D9C8E2FE0F8F93C81A063425F019F1C7A38A30710833AD367BCA90A
Embedded bundle SHA-256: BC9A70327A456FC8718907B9701E83194303B0A5816F0EA0C309310D7118B8FE
Embedded Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Executed mission path from debrief: OMW_Template_v19.miz
```

Read-only MIZ-Preflight bestätigte den korrekten `ResKey_Action_243`, `triggerOnce`, beide Readiness-Flags, `TIME > 5`, keine alte AMMO/FUEL-Acceptance-Ressource sowie das unveränderte `TPL_BLUE_CONVOY_FUEL_LIGHT_06` mit `lateActivation=true` und sechs Fahrzeugen.

## 8. DCS-Lauf 2026-08-23 – Ergebnis und Korrektur

Beobachtet:

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

Die visuelle Owner-Beobachtung war, dass der Convoy anschließend Honaker erreichte und dort stehen blieb. Das widerspricht dem Log nicht: Der Timeout hatte den Acceptance-Harness bereits beendet, nicht die physische DCS-Route.

Der Lauf ist daher als **Harness-FALSE-FAIL durch zu kurzes Outbound-Fenster** zu behandeln. Er beweist weder einen `NewNOTHING`-Routingfehler noch einen Fehler der RTZ-Rückfahrt. Der Return-Pfad wurde durch `state.failed=true` nicht mehr verarbeitet.

Der DCS-Marker `CREATING PATH MAKES TOO LONG!!!!!` bleibt als diagnostischer Hinweis dokumentiert, ist aber nicht als Root Cause dieses fehlenden Returns belegt.

Log-Provenienz:

```text
dcs.log SHA-256: 23E2D0B31B66464A57D3BC5F45F92A75D4EF913413833311042CD4BC74F1AAA3
debrief.log SHA-256: 2574F8746F6D4A88E6D6F038AFC33DB5600DC4D52CC6A0E946A8E2155B0D8922
```

Detailresultat:

```text
results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-fail-1.md
```

## 9. Korrigierter Build-Stand

Owner-lokal am 23.08.2026 erfolgreich gebaut und unabhängig nachgehasht:

```text
Branch: agent/automatic-response-orchestration
Git HEAD: b34897403c4685061211b32cd081da3ac0e20000
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-2
Bundle SHA-256: 2B6C3357A51E19889B9420E766F7E5E408B4810B3545F30FDFFDFB399B19ED27
Independent bundle SHA-256: 2B6C3357A51E19889B9420E766F7E5E408B4810B3545F30FDFFDFB399B19ED27
Builder SHA-256: A7A5A730C581DBB3E5762B886A43C6FB64BF40CA4658E050F9F6127FDCDB125B
Acceptance source SHA-256: A21A88BD4BAC18FF4AE497C7A66C606E71DE888A9C55AA019AC1939B0F08D045
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
OutboundTimeoutSec: 1800
DestinationCheckIntervalSec: 15
DestinationExecutionGraceSec: 90
ReturnTimeoutSec: 1800
ReturnIssueDelaySec: 30
ReturnSettlementDelaySec: 12
FUELSUPPLY: false
OPSTRANSPORT: false
MizMutation: false
```

```text
Acceptance-1-1 result: HARNESS_FALSE_FAIL_OUTBOUND_TIMEOUT_TOO_SHORT
Corrected build: OWNER_LOCAL_BUILD_PASS
NewNOTHING runtime acceptance: NOT YET PROVEN
Next step: OWNER_MISSION_EDITOR_REINTEGRATION_AND_READ_ONLY_MIZ_PREFLIGHT
```

Kein Produktionsstatus und kein `VALIDATED` wird aus dem Fehlversuch oder dem Build-PASS abgeleitet.
