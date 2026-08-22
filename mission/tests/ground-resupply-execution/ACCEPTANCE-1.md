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

Der Test prüft erstmals die vollständige Kette von einem autoritativen Ground-Ressourcenmangel bis zur physischen MOOSE-Lieferung und strategischen Gutschrift.

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

## 2. Strategische Werte

```text
GROUND_NODE_JOYCE / GROUND_AMMO_PACKAGE
initial/target = 44

GROUND_NODE_HONAKER / GROUND_AMMO_PACKAGE
initial/target = 40
reorder = 20
critical = 10
supplyParent = GROUND_NODE_JOYCE
```

Der Testverbrauch von 20 Einheiten ist reine Acceptance-Vorbereitung und keine behauptete reale Feuerverbrauchsmenge.

Erwarteter Endzustand:

```text
JOYCE AMMO   44 -> 24
HONAKER AMMO 40 -> 20 -> 40
```

## 3. Physischer MOOSE-Vertrag

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

Die owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird nur für die straßenausgerichtete Materialisierung verwendet. Request-, Asset-, PLATOON-, ARMYGROUP- und AUFTRAG-Lifecycle bleiben MOOSE-owned.

CampaignState bleibt alleinige strategische Cargo-/Ressourcenautorität. `OPSTRANSPORT` wird in diesem Slice nicht verwendet.

## 4. Delivery- und Settlement-Gate

Delivery ist fail-closed:

```text
OnAfterMissionExecute
AND exact Mission == acceptance AMMOSUPPLY mission
AND ARMYGROUP:IsInZone(ZON_BLUE_GND_HONAKER_ACCESS) == true
```

Erst dann:

```text
CampaignState MarkDelivered(TRANSFER_ID)
MissionDemand reservationState = DELIVERED
MissionDemand SUCCESS
```

`MissionDone` allein ist kein Liefernachweis.

## 5. Rückkehr

```text
MissionDone
-> ARMYGROUP:RTZ(ZON_BLUE_GND_JOYCE_ACCESS, OnRoad)
-> OnAfterReturned
-> BRIGADE OnAfterAddAsset
-> physical group removed
```

## 6. Build-Provenienz

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
```

Buildklassifikation:

```text
BUILD PASS
bundle emitted: true
builder-reported bundle hash == independently calculated bundle hash: true
```

## 7. Ausgewählte Arbeits-MIZ / read-only Preflight

Der Projektinhaber listete am 2026-08-22 die aktuellen lokalen OMW-Missionen. Jüngster Kandidat war `OMW_Template_v16.miz`. Die hochgeladene Kopie `OMW_Template_v16(7).miz` wurde read-only geprüft und ist byte-identisch mit dem gelisteten lokalen Kandidaten.

```text
Selected work MIZ: OMW_Template_v16.miz
Uploaded inspection copy: OMW_Template_v16(7).miz
MIZ SHA-256: 91837A67121D769145136745BBAC2F12C92F4F054ED1EADD5E937EFB9533F8A9
internal mission SHA-256: BFC50C8FA4AA953D63B8D1AAEC8B927645253996FFA6990DF6D5118F98659AF7
```

### 7.1 Objektvertrag

Read-only in der internen `mission` bestätigt:

```text
WH_BLUE_GND_JOYCE
  static/warehouse anchor present
  DCS type: HESCO_generator

ZON_BLUE_GND_JOYCE_ACCESS
  trigger zone present
  radius: 152.4 m

ZON_BLUE_GND_HONAKER_ACCESS
  trigger zone present
  radius: 121.92 m

TPL_BLUE_GND_SUP_M1083
  ground template group present
  one unit: TPL_BLUE_GND_SUP_M1083_01
  DCS type: CHAP_M1083
  lateActivation: true
```

Damit ist der statische Namens-/Typvertrag für den Stage-1A-Scope erfüllt. DCS-Wegfindung und reale Materialisierung sind weiterhin ausschließlich Runtime-Gegenstand.

### 7.2 Eingebettete Startup-Ressourcen

```text
l10n/DEFAULT/Moose.lua
SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

l10n/DEFAULT/OMW_AirOps_Warehouse_Base.lua
SHA-256: 472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

l10n/DEFAULT/OMW_Ground_Base.lua
SHA-256: 9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB
```

`Moose.lua` entspricht exakt dem für diese Acceptance gepinnten Stand.

### 7.3 Trigger-/Startup-Reihenfolge

Aus `mission.trig` und `l10n/DEFAULT/mapResource` read-only bestätigt:

```text
Trigger 1 / Mission Start
ResKey_Action_6 -> Moose.lua

Trigger 2 / time > 1 s
ResKey_Action_238 -> OMW_AirOps_Warehouse_Base.lua

Trigger 3 / time > 2 s AND OMW_WAREHOUSE_READY == 1
ResKey_Action_239 -> OMW_Ground_Base.lua
-> OMW.Ground.Base.Attach({
     store = OMW.AirOps.CampaignContext.store,
     campaignState = OMW.AirOps.CampaignContext.campaignState,
     restored = OMW.AirOps.CampaignContext.restored == true
   })
```

Damit verwendet Ground denselben autoritativen CampaignState-Kontext wie die Warehouse-Foundation.

`OMW_GROUND_READY` steht nicht als separate Bedingung im unveränderten `mission`-File. Das ist für den Preflight kein Fehler: `OMW_Ground_Base.lua` setzt das USERFLAG nach erfolgreichem Attach; das Acceptance-Bundle prüft vor eigener Ausführung fail-closed `OMW_WAREHOUSE_READY == 1` und `OMW_GROUND_READY == 1`.

Read-only Preflight-Klassifikation:

```text
MIZ identity: PASS
internal mission identity: PASS
required object contract: PASS
Moose.lua present/hash: PASS
Warehouse Base present: PASS
Ground Base present: PASS
CampaignState handoff: PASS
MIZ mutation: NOT STARTED
DCS runtime: NOT RUN
```

## 8. Erwartete Pflichtmarker

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

## 9. Nicht Teil dieses Gates

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

## 10. Aktueller Status

```text
Source review: COMPLETE FOR THIS TEST SCOPE
Acceptance source: STAGED
Builder: PASS
Independent bundle hash: MATCH
MIZ selected: OMW_Template_v16.miz
MIZ pre-mutation SHA-256: 91837A67121D769145136745BBAC2F12C92F4F054ED1EADD5E937EFB9533F8A9
internal mission pre-mutation SHA-256: BFC50C8FA4AA953D63B8D1AAEC8B927645253996FFA6990DF6D5118F98659AF7
MIZ object/startup preflight: PASS
MIZ embedding: NOT STARTED
post-mutation MIZ hash: UNKNOWN
embedded acceptance bundle hash: UNKNOWN
post-mutation embedded Moose.lua hash: UNKNOWN
DCS runtime: NOT RUN
Acceptance classification: NOT_RUN
```

## 11. Nächster Gate

Der nächste zulässige Schritt ist ausschließlich die owner-seitige Mission-Editor-Einbettung des bereits gebauten Bundles in eine neue Arbeitskopie von `OMW_Template_v16.miz` und danach die erneute Hash-/Strukturprüfung nach Dokument 22.

```text
copy v16 to dedicated acceptance MIZ
-> add exactly one DO SCRIPT FILE for OMW_Ground_Ammo_Resupply_Acceptance_1.lua
-> gate it after Warehouse/Ground readiness
-> save once
-> record new MIZ SHA-256
-> record new internal mission SHA-256
-> verify embedded acceptance bundle SHA-256 == local build hash
-> verify embedded Moose.lua SHA-256 unchanged
-> verify no duplicate acceptance resource/trigger
-> stop before DCS until this post-mutation preflight passes
```

Kein DCS-Lauf vor vollständigem statischem Post-Mutation-PASS.