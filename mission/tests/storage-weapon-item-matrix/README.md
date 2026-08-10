---
document_id: OMW-TEST-STORAGE-WEAPON-ITEM-MATRIX-INDEX
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - read-only MOOSE STORAGE weapon-item matrix test scope
  - seven-node warehouse mapping diagnostics
  - candidate item families for OMW ammunition resource reconciliation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-weapon-item-matrix
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_branch: agent/storage-weapon-item-matrix
acceptance_commit: 19836e4862e0b0a1d6bc1cee987cb9ce308ee3eb
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: 9431918c103359d0207db9b98c1cdb938afc48e55e0b828c21a8eb1a15a39c11
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
base_branch: agent/campaignstate-resource-transaction-contract
base_commit: a1f2c5997f07e164dddc839665cb83c321bfd4ae
base_status: ACCEPTED_TECHNICAL_BASELINE_CHILD_BRANCH
merged_to_main: false
inherited_risk:
  - parent transaction contract is accepted for its exact documented scope but the stacked parent chain is not yet merged to main
---

# STORAGE Weapon Item Matrix

## 1. Ziel

`STORAGE-WEAPON-ITEM-MATRIX-1` ermittelt in **einem** DCS-Lauf die MOOSE-/DCS-Warehouse-Item-Sicht für die aktuell relevanten OMW-Munitionsfamilien über alle sieben bereits verwendeten STORAGE-Endpunkte.

Der Test ist absichtlich read-only. Er verändert weder CampaignState noch DCS-Warehouse-Bestände.

## 2. MOOSE-First

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Verwendete öffentliche MOOSE-API:

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetInventory()
STORAGE:GetItemAmount()
ENUMS.Storage.weapons
```

Nicht verwendet:

```text
STORAGE:SetItem/AddItem/RemoveItem
STORAGE:IsUnlimited/IsUnlimitedWeapons
native DCS warehouse access
_DATABASE
OPSTRANSPORT
CTLD
AIRWING mutation
CampaignState mutation
scheduler
persistence
```

`IsUnlimited*` ist absichtlich ausgeschlossen, weil der gepinnte MOOSE-Quellpfad zur Unlimited-Erkennung temporär Warehouse-Mengen verändert.

## 3. Endpoints

```text
Bagram
Jalalabad
Kandahar
Kandahar Heliport
FOB Salerno
Tarinkot
Shindand Heliport
```

## 4. Candidate Families

Der Test fragt source-reviewed Kandidaten ab, ohne daraus bereits produktive Resource-Mappings abzuleiten.

```text
HELLFIRE
  weapons.missiles.AGM_114
  weapons.missiles.AGM_114K

HYDRA_70
  weapons.nurs.HYDRA_70_M151
  weapons.nurs.HYDRA_70_M151_M433
  weapons.nurs.HYDRA_70_M229
  weapons.nurs.HYDRA_70_M259
  weapons.nurs.HYDRA_70_M274
  weapons.nurs.HYDRA_70_M282
  weapons.nurs.HYDRA_70_MK1
  weapons.nurs.HYDRA_70_MK61

AH64_M230_30MM
  weapons.gunmounts.M230
  weapons.shells.M230_30
  weapons.shells.M230_HEDP M789
  weapons.shells.M230_HEI M799
  weapons.shells.M230_TP M788

A10_GAU8_30MM
  weapons.shells.GAU8_30_AP
  weapons.shells.GAU8_30_TP

OH58_M3P_50CAL
  weapons.gunmounts.OH58D_M3P_L100
  weapons.gunmounts.OH58D_M3P_L200
  weapons.gunmounts.OH58D_M3P_L300
  weapons.gunmounts.OH58D_M3P_L500
  weapons.shells.M2_12_7
  weapons.shells.M2_12_7_T
  weapons.shells.50Browning_Ball_M2
  weapons.shells.50Browning_AP_M2
  weapons.shells.50Browning_API_M8
  weapons.shells.50Browning_APIT_M20
```

## 5. Assertions und Ausgabe

Der Test muss für jeden Endpoint:

```text
NODE_RESOLVE_PASS
STORAGE_IDENTITY_PASS
INVENTORY_READ_PASS
CANDIDATE_READ_PASS
NODE_PASS
```

erreichen.

`INVENTORY_READ_PASS` bedeutet nur, dass MOOSE eine gültige Weapon-Inventory-Tabelle zurückliefert. Eine leere Tabelle ist zulässig und wird als `weaponKeys=0` protokolliert; sie beweist weder fehlenden Bestand noch Unlimited Weapons.

`CANDIDATE_READ_PASS` verlangt für jeden source-reviewed Candidate einen numerischen Rückgabewert von `STORAGE:GetItemAmount()`. Der Wert wird unverändert protokolliert, aber in diesem Diagnose-Scope nicht als strategischer Bestand interpretiert.

Zusätzlich protokolliert der Harness relevante Inventory-Keys anhand enger String-Patterns, damit Varianten sichtbar werden, die nicht in der initialen Candidate-Liste enthalten sind.

Aggregate PASS:

```text
RESULT testId=STORAGE-WEAPON-ITEM-MATRIX-1 status=PASS nodesExpected=7 nodesPassed=7 nodesFailed=0 mutation=false campaignStateMutation=false opstransport=false ctld=false
```

## 6. Architekturentscheidung, die dieser Test vorbereitet

Die bestehende Baseline enthält unter anderem:

```text
AMMUNITION_ROCKETS_70MM
AMMUNITION_HELLFIRE
AMMUNITION_30MM
AMMUNITION_50CAL
```

Der MOOSE-Enum trennt jedoch beispielsweise AH-64-M230- und A-10-GAU-8-30-mm-Items. Deshalb darf `AMMUNITION_30MM` nicht ohne weiteren Owner-Entscheid als austauschbarer Einheitsbestand implementiert werden.

Der Runtime-Lauf bestätigte zusätzlich, dass relevante Warehouse-Items nicht immer den zunächst vermuteten `gunmounts`-/`shells`-Kandidaten entsprechen. Insbesondere wurden OH-58-M3P-Container-Keys mit Bestand sichtbar, während die geprüften M3P-`gunmounts` und .50-cal-`shells` im selben Warehouse-Pfad `0` lieferten. Daraus wird noch keine produktive Resource-Zuordnung abgeleitet.

## 7. Source- und Build-Pfade

```text
mission/tests/storage-weapon-item-matrix/src/01-storage-weapon-item-matrix.lua
tools/build-storage-weapon-item-matrix.ps1
mission/tests/storage-weapon-item-matrix/dist/OMW_Storage_Weapon_Item_Matrix_Test.lua
```

BuilderVersion:

```text
STORAGE-WEAPON-ITEM-MATRIX-1
```

## 8. Acceptance

Der Lauf vom 10.08.2026 ist für exakt den dokumentierten Stand `ACCEPTED_TECHNICAL_BASELINE`.

```text
Source/Builder commit: 19836e4862e0b0a1d6bc1cee987cb9ce308ee3eb
BuilderVersion: STORAGE-WEAPON-ITEM-MATRIX-1
DCS: 2.9.28.26385 MT
Executed MIZ: OMW_Template_v8_AirOps_rdy.miz
Executed MIZ SHA-256: 9431918c103359d0207db9b98c1cdb938afc48e55e0b828c21a8eb1a15a39c11
Internal mission SHA-256: 1f186d3116844c9275421623b16d9b3798c8f75ee726ec07f31a67a6fd1ce53c
Embedded bundle: l10n/DEFAULT/OMW_Storage_Weapon_Item_Matrix_Test.lua
Embedded bundle SHA-256: 46568c872d29e3542fddc47d781897f75d2f40a057b995e0b4c1437ae0877aa5
Local build bundle SHA-256: 46568c872d29e3542fddc47d781897f75d2f40a057b995e0b4c1437ae0877aa5
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS log SHA-256: 2356ee23e2275ae10e959a196a1f6f62dfe2f7d390ea6ad6f39b757fb19c9361
Debrief SHA-256: 55cbc63b6244cbaf30b38f64362a29f11742825327a02c1f1ab1f4960752505c
```

Bestätigter finaler Marker:

```text
RESULT testId=STORAGE-WEAPON-ITEM-MATRIX-1 status=PASS nodesExpected=7 nodesPassed=7 nodesFailed=0 mutation=false campaignStateMutation=false opstransport=false ctld=false
```

Vollständiger Acceptance-Bericht:

- [`OMW-TEST-STORAGE-WEAPON-ITEM-MATRIX-ACCEPTANCE`](expected/storage-weapon-item-matrix-acceptance.md)

Die Acceptance umfasst ausschließlich die read-only Weapon-/Item-Matrix. STORAGE-Mutation, CampaignState-Synchronisation, Payload-Verbrauch, OPSTRANSPORT, CTLD, Persistenz und Multiplayer-Reconciliation bleiben separate Gates.
