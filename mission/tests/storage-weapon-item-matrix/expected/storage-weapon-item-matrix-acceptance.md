---
document_id: OMW-TEST-STORAGE-WEAPON-ITEM-MATRIX-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_REPORT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS acceptance provenance for STORAGE-WEAPON-ITEM-MATRIX-1
  - read-only seven-node MOOSE STORAGE weapon/item visibility in the documented scope
not_authoritative_for:
  - strategic resource-ID design decisions
  - CampaignState weapon synchronization
  - STORAGE weapon mutation
  - OPSTRANSPORT or CTLD runtime integration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-weapon-item-matrix
source_commit: 19836e4862e0b0a1d6bc1cee987cb9ce308ee3eb
validated_in_dcs: true
acceptance_branch: agent/storage-weapon-item-matrix
acceptance_commit: 19836e4862e0b0a1d6bc1cee987cb9ce308ee3eb
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: 9431918c103359d0207db9b98c1cdb938afc48e55e0b828c21a8eb1a15a39c11
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# STORAGE Weapon Item Matrix – Acceptance

## 1. Testidentität

```text
Test ID: STORAGE-WEAPON-ITEM-MATRIX-1
Branch: agent/storage-weapon-item-matrix
Source/Builder commit: 19836e4862e0b0a1d6bc1cee987cb9ce308ee3eb
BuilderVersion: STORAGE-WEAPON-ITEM-MATRIX-1
Base branch: agent/campaignstate-resource-transaction-contract
Base commit: a1f2c5997f07e164dddc839665cb83c321bfd4ae
DCS: 2.9.28.26385 MT
```

## 2. Artefakt-Provenienz

```text
Executed MIZ: OMW_Template_v8_AirOps_rdy.miz
Executed MIZ SHA-256: 9431918c103359d0207db9b98c1cdb938afc48e55e0b828c21a8eb1a15a39c11
Internal mission SHA-256: 1f186d3116844c9275421623b16d9b3798c8f75ee726ec07f31a67a6fd1ce53c
Embedded bundle path: l10n/DEFAULT/OMW_Storage_Weapon_Item_Matrix_Test.lua
Embedded bundle SHA-256: 46568c872d29e3542fddc47d781897f75d2f40a057b995e0b4c1437ae0877aa5
Local build bundle SHA-256: 46568c872d29e3542fddc47d781897f75d2f40a057b995e0b4c1437ae0877aa5
Embedded Moose.lua path: l10n/DEFAULT/Moose.lua
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
DCS log SHA-256: 2356ee23e2275ae10e959a196a1f6f62dfe2f7d390ea6ad6f39b757fb19c9361
Debrief SHA-256: 55cbc63b6244cbaf30b38f64362a29f11742825327a02c1f1ab1f4960752505c
```

Der eingebettete Bundle-Hash stimmt exakt mit dem lokal erzeugten Bundle überein. Die eingebettete `Moose.lua` stimmt exakt mit dem gepinnten Projektartefakt überein.

## 3. Runtime-Ergebnis

Alle sieben Endpunkte bestanden den read-only Prüfpfad:

```text
Bagram
Jalalabad
Kandahar
Kandahar Heliport
FOB Salerno
Tarinkot
Shindand Heliport
```

Finaler Marker:

```text
RESULT testId=STORAGE-WEAPON-ITEM-MATRIX-1 status=PASS nodesExpected=7 nodesPassed=7 nodesFailed=0 mutation=false campaignStateMutation=false opstransport=false ctld=false
```

Damit sind für den dokumentierten Stand praktisch bestätigt:

```text
AIRBASE resolution for all seven endpoints
AIRBASE:GetStorage() / STORAGE:FindByName() identity agreement
STORAGE:GetInventory() returns a readable weapon inventory table
STORAGE:GetItemAmount() returns numeric raw values for all 27 source-reviewed candidates
no test-side STORAGE mutation
no CampaignState mutation
no OPSTRANSPORT execution
no CTLD execution
```

## 4. Mapping-Befund

Der Lauf zeigt für die geprüften Warehouses unter anderem:

```text
weapons.missiles.AGM_114 = 100
weapons.missiles.AGM_114K = 100
selected HYDRA_70 nurs variants = 100
```

Zusätzlich wurden relevante Warehouse-Keys sichtbar, die in der initialen Candidate-Liste nicht vollständig enthalten waren, darunter:

```text
weapons.missiles.AGR_20A
weapons.missiles.AGR_20_M282
weapons.nurs.HYDRA_70_WTU1B
weapons.nurs.HYDRA_70_MK5
weapons.containers.OH58D_M3P_L100
weapons.containers.OH58D_M3P_L200
weapons.containers.OH58D_M3P_L300
weapons.containers.OH58D_M3P_L400
weapons.containers.OH58D_M3P_L500
```

Die geprüften M230-, GAU-8- und .50-cal-`gunmounts`/`shells` lieferten in diesem Warehouse-Pfad `0`. Das ist ein technischer Mapping-Befund, kein Beweis für fehlende reale Munition und keine Freigabe für eine strategische Resource-ID-Zuordnung.

## 5. Architekturgrenze

Der Test bestätigt ausdrücklich **nicht**, dass `AMMUNITION_30MM` als ein austauschbarer strategischer Pool für AH-64 M230 und A-10 GAU-8 geeignet ist. Die technische DCS-/MOOSE-Repräsentation ist verschieden; die strategische Resource-ID-Struktur bleibt eine Owner-Entscheidung.

Ebenso wird aus den OH-58-Container-Keys noch keine automatische `AMMUNITION_50CAL`-Buchungssemantik abgeleitet. Vor einer produktiven Synchronisation ist der konkrete Store-/Payload-Verbrauchspfad separat zu prüfen.

## 6. Acceptance

Für exakt den dokumentierten Branch-/Commit-/MIZ-/Bundle-/MOOSE-/DCS-Stand gilt:

```text
status: ACCEPTED_TECHNICAL_BASELINE
```

Die Acceptance umfasst ausschließlich die read-only Weapon-/Item-Matrix. STORAGE-Mutation, CampaignState-Synchronisation, Payload-Verbrauch, OPSTRANSPORT, CTLD, Persistenz und Multiplayer-Reconciliation sind separate Gates.
