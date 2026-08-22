---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local DCS acceptance plan for the first MissionDemand-driven physical Ground AMMO RESUPPLY vertical slice
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground AMMO RESUPPLY Acceptance 1 – Joyce nach Honaker

## 1. Ziel

```text
Honaker AMMO 40
-> test-only consumption 20
-> Honaker AMMO 20
-> ResourceDemandPolicy = REORDER
-> one RESUPPLY MissionDemand
-> CampaignState TRANSFER Joyce -> Honaker / 20
-> one M1083 AMMOSUPPLY mission
-> physical arrival in Honaker ACCESS zone
-> CampaignState DELIVERED
-> Honaker AMMO 40
-> MissionDemand SUCCESS
-> M1083 RTZ Joyce
-> Warehouse AddAsset / physical cleanup
```

Erwarteter strategischer Endzustand:

```text
JOYCE AMMO   44 -> 24
HONAKER AMMO 40 -> 20 -> 40
```

## 2. Strategische / operative Grenze

```text
CampaignState = alleinige strategische Ressourcen-/Cargo-Autorität
MissionDemand = Demand-/Assignment-Zustand
MOOSE BRIGADE / PLATOON / ARMYGROUP / AUFTRAG = physische Ausführung
DCS group = temporäre physische Repräsentation
```

`OPSTRANSPORT` wird in diesem Slice nicht verwendet.

Physischer MOOSE-Vertrag:

```text
BRIGADE:New(...)
PLATOON:New(...)
PLATOON:AddMissionCapability(AUFTRAG.Type.AMMOSUPPLY, 100)
BRIGADE:AddPlatoon(...)
AUFTRAG:NewAMMOSUPPLY(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:AddMission(...)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die bereits owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird ausschließlich für road-aligned Materialisierung verwendet.

## 3. Delivery-/Settlement-Gate

Delivery ist fail-closed:

```text
OnAfterMissionExecute
AND exact Mission == acceptance AMMOSUPPLY mission
AND ARMYGROUP:IsInZone(ZON_BLUE_GND_HONAKER_ACCESS) == true
```

Erst danach:

```text
CampaignState MarkDelivered(TRANSFER_ID)
MissionDemand reservationState = DELIVERED
MissionDemand SUCCESS
```

`MissionDone` allein ist kein Liefernachweis.

## 4. Build-Provenienz

```text
Builder: tools/build-ground-ammo-resupply-acceptance-1.ps1
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-3
GitCommit: 99ea86bf61036f2d04008b17bcb8c1d6e236b030
GeneratedUtc: 2026-08-22T16:57:51Z
TestId: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
Bundle: mission/tests/ground-resupply-execution/dist/OMW_Ground_Ammo_Resupply_Acceptance_1.lua
Bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
Independent bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
Builder SHA-256: AEF56E16FE896854D32EAE409FC04A6C8C0BE20266EF591242DC5C866C5FB820
Acceptance source SHA-256: 38E099C801286768FD9D1D39014BB767BCF99055602D1E06EDACA48634856C83
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
GroundRoadSpawnAdapter source SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Build classification: PASS
```

## 5. Arbeits-MIZ / read-only Preflight

Ausgewählte Ausgangsmission:

```text
OMW_Template_v16.miz
MIZ SHA-256: 91837A67121D769145136745BBAC2F12C92F4F054ED1EADD5E937EFB9533F8A9
internal mission SHA-256: BFC50C8FA4AA953D63B8D1AAEC8B927645253996FFA6990DF6D5118F98659AF7
```

Required object contract read-only confirmed:

```text
WH_BLUE_GND_JOYCE
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
TPL_BLUE_GND_SUP_M1083
```

Embedded startup resources confirmed:

```text
l10n/DEFAULT/Moose.lua
SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

l10n/DEFAULT/OMW_AirOps_Warehouse_Base.lua
SHA-256: 472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

l10n/DEFAULT/OMW_Ground_Base.lua
SHA-256: 9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB
```

Startup mapping read-only confirmed:

```text
Mission Start -> Moose.lua
time > 1 s -> OMW_AirOps_Warehouse_Base.lua
time > 2 s AND OMW_WAREHOUSE_READY == 1
-> OMW_Ground_Base.lua
-> OMW.Ground.Base.Attach(existing OMW.AirOps.CampaignContext)
```

Read-only classification:

```text
MIZ identity: PASS
internal mission identity: PASS
required object contract: PASS
Moose.lua identity: PASS
Warehouse Base present: PASS
Ground Base present: PASS
CampaignState handoff: PASS
```

## 6. Owner embedding attempt – 2026-08-22

Owner created the dedicated work copy:

```text
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v16_Ground_Ammo_Resupply_Acceptance_1.miz
WorkCopyInitialSHA256: 91837A67121D769145136745BBAC2F12C92F4F054ED1EADD5E937EFB9533F8A9
```

Expected Mission Editor change:

```text
one ONCE trigger
conditions:
  OMW_WAREHOUSE_READY == 1
  OMW_GROUND_READY == 1
action:
  DO SCRIPT FILE -> OMW_Ground_Ammo_Resupply_Acceptance_1.lua
```

Returned post-mutation preflight evidence:

```text
post-mutation MIZ SHA-256:
91837A67121D769145136745BBAC2F12C92F4F054ED1EADD5E937EFB9533F8A9

internal mission SHA-256:
BFC50C8FA4AA953D63B8D1AAEC8B927645253996FFA6990DF6D5118F98659AF7

object occurrences:
WH_BLUE_GND_JOYCE = 2
ZON_BLUE_GND_JOYCE_ACCESS = 1
ZON_BLUE_GND_HONAKER_ACCESS = 1
TPL_BLUE_GND_SUP_M1083 = 2

ready-flag references in internal mission:
OMW_WAREHOUSE_READY = 16
OMW_GROUND_READY = 0

preflight result:
FAIL before resource-mapping / embedded-bundle verification
reason: Required readiness flag reference missing: OMW_GROUND_READY
```

### 6.1 Bewertung

Die MIZ-SHA-256 und der interne `mission`-SHA-256 sind nach dem angeblichen Mission-Editor-Schritt exakt identisch mit der unveränderten Ausgangsmission. Gleichzeitig fehlt jede `OMW_GROUND_READY`-Referenz im internen `mission`-File.

Daraus folgt für diesen Gate ausschließlich:

```text
NO_MIZ_MUTATION_OBSERVED
```

Nicht behauptet wird, warum die Änderung nicht gespeichert wurde. Mögliche Ursachen wie falsche geöffnete Datei, nicht gespeicherte Mission oder nicht angelegter Trigger bleiben unbestätigt und werden nicht als Root Cause ausgegeben.

Der ursprüngliche read-only Preflight bleibt gültig; es wurde keine veränderte Test-MIZ nachgewiesen. DCS ist weiterhin nicht freigegeben.

## 7. Erwartete Runtime-Pflichtmarker

```text
START testId=GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
DEMAND_RESERVED
PHYSICAL_EXECUTION_READY
BRIGADE_STARTED
MISSION_QUEUED type=AMMOSUPPLY
GROUP_MATERIALIZED
ARMY_ON_MISSION
DELIVERY_CONFIRMED
MISSION_DONE deliveryCommitted=true
RETURN_RTZ_ISSUED
RETURN_RTZ_ACTIVE
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS originFinal=24 destinationFinal=40 transferQuantity=20 demandStatus=SUCCESS spawnCount=1 returnedCount=1 warehouseAddAssetCount=1
```

Jeder `FAIL reason=...`-Marker macht den Lauf FAIL.

## 8. Nicht Teil dieses Gates

```text
FUEL RESUPPLY
generic SUPPLY
multiple concurrent resupply demands
convoy under attack
CAS / BLUE COMMANDER
CSAR
real external process/server persistence
production orchestration scheduler
```

## 9. Aktueller Status

```text
Source review: COMPLETE FOR THIS TEST SCOPE
Acceptance source: STAGED
Builder: PASS
Independent bundle hash: MATCH
MIZ selected: OMW_Template_v16.miz
MIZ object/startup preflight: PASS
dedicated work copy: CREATED
owner embedding attempt: NO_MIZ_MUTATION_OBSERVED
post-mutation MIZ hash: unchanged from source
post-mutation internal mission hash: unchanged from source
OMW_GROUND_READY reference in internal mission: 0
embedded acceptance bundle hash: NOT REACHED / UNKNOWN
post-mutation embedded Moose.lua hash: NOT REACHED / UNKNOWN
DCS runtime: NOT RUN
Acceptance classification: NOT_RUN
```

## 10. Nächster Gate

Nur die dedizierte Acceptance-Arbeitskopie darf erneut im Mission Editor geöffnet werden. Der Acceptance-Trigger muss real angelegt, die Mission gespeichert und der Editor geschlossen werden. Danach zuerst MIZ- und interner mission-Hash prüfen.

```text
work copy must change bytes
AND internal mission hash must change
AND OMW_GROUND_READY reference must exist
```

Erst danach folgen Resource-Mapping-, embedded bundle-, Moose- und vollständige Strukturprüfung. Kein DCS-Lauf bis zum vollständigen Post-Mutation-PASS.
