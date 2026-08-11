---
document_id: OMW-TEST-STORAGE-AIRWING-WEAPON-LIFECYCLE-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - read-only STORAGE/AIRWING weapon lifecycle correlation scope
  - Shindand AH-64D no-fire recovery and second-sortie redebit protocol
  - interpretation boundary for landing, arrival, ReturnToLegion and warehouse recredit evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-airwing-weapon-lifecycle
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/storage-weapon-consumption-correlation
base_commit: 503467665e9810398b0c9f20c29019bf958a589b
base_status: ACCEPTED_TECHNICAL_BASELINE_CHILD_BRANCH
merged_to_main: false
inherited_risk:
  - parent ammunition mapping and resource-ID branches remain unmerged
---

# STORAGE / AIRWING Weapon Lifecycle

## 1. Ziel

`STORAGE-AIRWING-WEAPON-LIFECYCLE-1` erweitert den akzeptierten AH-64D External-Store-Debit-Nachweis zu einem zusammenhängenden MOOSE-first Lifecycle-Gate.

Ein einzelner DCS-Lauf soll beantworten:

```text
initial STORAGE stock
-> first 2-ship AH-64D materialization / debit
-> no-fire sortie
-> landing
-> arrival / native ReturnToLegion path
-> possible STORAGE recredit
-> second mission dispatch
-> second materialization / redebit
-> second no-fire recovery
-> final stable STORAGE state
```

Der Test implementiert keine eigene Recovery-, Warehouse- oder Asset-FSM.

## 2. MOOSE-First

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-reviewed fuer diesen Gate:

```text
AIRWING:AddMission()
AIRWING:CountAssets()
AIRWING:CountAssetsOnMission()
FLIGHTGROUP:IsLanding()
FLIGHTGROUP:IsLanded()
FLIGHTGROUP:IsArrived()
FLIGHTGROUP:GetAmmoTot()
FLIGHTGROUP OnAfterLanded callback
FLIGHTGROUP OnAfterArrived callback
FLIGHTGROUP internal onafterArrived -> ReturnToLegion(1) for AI AIRWING assets
STORAGE:FindByName()
STORAGE:GetInventory()
SCHEDULER:New()
AUFTRAG:NewCAS()
```

Der gepinnte `Moose.lua` fuehrt bei einem AI-`FLIGHTGROUP` mit zugeordnetem AIRWING im nativen `onafterArrived`-Pfad `ReturnToLegion(1)` aus. Der Test beobachtet diesen Lifecycle nur; er ruft `ReturnToLegion()` nicht selbst auf.

## 3. Testbedingungen

- `OMW_AirOps_Shindand.lua` bzw. der Shindand-Foundation-Build muss geladen und `RUNNING` sein.
- Die Shindand Final-Foundation-Acceptance mit zusaetzlichen UH-60-/CH-47-Dispatches bleibt deaktiviert.
- Im CAS-Testgebiet befinden sich keine absichtlich gesetzten Ziele; die beiden Lifecycle-Sorties sind als **no-fire** vorgesehen.
- Keine Client-/Rearm-/weitere AI-Payload-Aktion an den sieben beobachteten STORAGE-Endpunkten waehrend des Gates.
- Der Test mutiert weder STORAGE noch CampaignState.

## 4. Beobachtung

Sieben STORAGE-Endpunkte werden read-only beobachtet:

```text
Bagram
Jalalabad
Kandahar
Kandahar Heliport
FOB Salerno
Tarinkot
Shindand Heliport
```

Weapon-Inventory-Deltas werden fortlaufend protokolliert. Zusaetzlich werden Snapshots an Lifecycle-Grenzen erzeugt:

```text
BASELINE
FIRST_ASSIGNED
FIRST_LANDED
FIRST_ARRIVED
FIRST_POST_RETURN
SECOND_ASSIGNED
SECOND_LANDED
SECOND_ARRIVED
SECOND_POST_RETURN
FINAL
```

Fuer jede zugewiesene FLIGHTGROUP werden MOOSE-Ammo-Summen (`MissilesAG`, `Rockets`, `Bombs`, `Guns`) bei Assignment, Landed und Arrived protokolliert. Damit kann ein unerwarteter Waffenverbrauch den no-fire-Lauf als nicht isoliert kennzeichnen.

## 5. Erwartungsbild, aber keine Vorwegnahme

Aus dem akzeptierten Parent-Gate ist fuer eine materialisierte Shindand-2-Ship-AH-64D-CAS-Assetgruppe belegt:

```text
HYDRA_70_M151: -76
AGM_114K: -4
IAFS_ComboPak_100: -2
```

Der neue Gate nimmt **nicht** vorweg, ob und wann diese Stores zurueckgebucht werden. Moegliche Runtime-Ergebnisse sind insbesondere:

```text
recredit at landing
recredit at arrived / ReturnToLegion
delayed recredit after recovery
partial recredit
no recredit
```

Die zweite Sortie prueft zusaetzlich, ob ein zurueckgekehrtes AIRWING-Asset erneut rekrutiert und die bekannte Payload erneut aus STORAGE abgebucht werden kann.

## 6. PASS-Semantik

Harness-PASS bedeutet ausschliesslich:

```text
all seven STORAGE endpoints resolved
first mission assigned
first flight reached Landed and Arrived
post-return observation completed
second mission assigned after first recovery window
second flight reached Landed and Arrived
final observation completed
no test-side STORAGE mutation
no CampaignState mutation
no custom ReturnToLegion call
```

Die konkrete Recredit-Semantik wird erst nach Auswertung der Deltas als DCS-Laufzeitbefund akzeptiert.

## 7. Nicht Teil dieses Gates

```text
controlled partial weapon expenditure
combat-target engagement
intentional aircraft destruction / loss accounting
M230/GAU-8/M3P mapping
CampaignState debit or credit
STORAGE mutation adapter
OPSTRANSPORT
CTLD
persistence
restart/multiplayer reconciliation
parking acceptance
```

Diese Grenzen verhindern, dass Return/Recredit, Wiederverwendung und Verlustpfad in einem einzigen unklaren Szenario vermischt werden.

## 8. Build

```text
mission/tests/storage-airwing-weapon-lifecycle/src/01-storage-airwing-weapon-lifecycle.lua
tools/build-storage-airwing-weapon-lifecycle.ps1
mission/tests/storage-airwing-weapon-lifecycle/dist/OMW_Storage_Airwing_Weapon_Lifecycle_Test.lua
```

BuilderVersion:

```text
STORAGE-AIRWING-WEAPON-LIFECYCLE-1
```
