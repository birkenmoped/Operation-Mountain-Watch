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

`STORAGE-AIRWING-WEAPON-LIFECYCLE-2` erweitert den akzeptierten AH-64D External-Store-Debit-Nachweis zu einem zusammenhängenden MOOSE-first Lifecycle-Gate.

Ein einzelner DCS-Lauf soll beantworten:

```text
initial STORAGE stock
-> first 2-ship AH-64D materialization / validated debit
-> no-fire sortie
-> optional Landed telemetry
-> Arrived / native ReturnToLegion path
-> possible STORAGE recredit
-> second mission dispatch
-> second materialization / possible redebit
-> second no-fire recovery
-> final stable STORAGE state
```

Der Test implementiert keine eigene Recovery-, Warehouse- oder Asset-FSM.

## 2. Korrektur nach verworfenem V1-Lauf

Der erste Lauf von `STORAGE-AIRWING-WEAPON-LIFECYCLE-1` am 2026-08-11 ist **kein gueltiger STORAGE-Lifecycle-Nachweis**. Der V1-Harness behandelte `STORAGE:GetInventory()` faelschlich wie eine einzelne strukturierte Tabelle. Im gepinnten MOOSE-Stand liefert die Methode jedoch exakt drei Rueckgabewerte:

```lua
local aircraft, liquids, weapons = storage:GetInventory()
```

Dadurch wurde in V1 die Weapon-Tabelle verworfen, `weaponKeys=0` protokolliert und ein False-Positive-Harness-PASS erzeugt. Dieser Lauf darf nicht als Recredit-/Rede-bit-Evidenz verwendet werden.

Der Lauf bleibt nur fuer folgende beobachtete AIRWING-/FLIGHTGROUP-Teilergebnisse informativ:

```text
first Arrived observed
second dispatch after first return observed
second Arrived observed
both sorties retained 4 AGM / 76 rockets in GetAmmoTot telemetry
Landed user callback was not observed in either sortie
```

V2 behebt nicht nur den direkten API-Fehler, sondern fuegt Fail-Fast-Kontrollen hinzu, damit ein leerer oder falsch gelesener Weapon-Bestand keinen PASS mehr erzeugen kann.

## 3. MOOSE-First

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-reviewed fuer diesen Gate:

```text
STORAGE:GetInventory() -> aircraft, liquids, weapons
AIRWING:AddMission()
AIRWING:CountAssets()
AIRWING:CountAssetsOnMission()
FLIGHTGROUP:GetAmmoTot()
FLIGHTGROUP OnAfterLanded callback
FLIGHTGROUP OnAfterArrived callback
FLIGHTGROUP internal onafterArrived -> ReturnToLegion(1) for AI AIRWING assets
STORAGE:FindByName()
SCHEDULER:New()
AUFTRAG:NewCAS()
```

Der gepinnte `Moose.lua` fuehrt bei einem AI-`FLIGHTGROUP` mit zugeordnetem AIRWING und ohne Pickup-/Transportzustand im nativen `onafterArrived`-Pfad `ReturnToLegion(1)` aus. Der Test beobachtet diesen Lifecycle nur; er ruft `ReturnToLegion()` nicht selbst auf.

## 4. Testbedingungen

- `OMW_AirOps_Shindand.lua` bzw. der Shindand-Foundation-Build muss geladen und `RUNNING` sein.
- Die Shindand Final-Foundation-Acceptance mit zusaetzlichen UH-60-/CH-47-Dispatches bleibt deaktiviert.
- Im CAS-Testgebiet befinden sich keine absichtlich gesetzten Ziele; beide Lifecycle-Sorties sind als **no-fire** vorgesehen.
- Keine Client-/Rearm-/weitere AI-Payload-Aktion an den sieben beobachteten STORAGE-Endpunkten waehrend des Gates.
- Der Test mutiert weder STORAGE noch CampaignState.

## 5. Fail-Fast STORAGE-Kontrollen

V2 akzeptiert die STORAGE-Beobachtung nur, wenn alle folgenden Bedingungen vor dem ersten Dispatch erfuellt sind:

```text
all seven AIRBASE/STORAGE wrappers resolve
AIRBASE:GetStorage() == STORAGE:FindByName()
GetInventory() returns three tables
weapon inventory is non-empty at every observed node
Shindand baseline contains numeric:
  weapons.nurs.HYDRA_70_M151
  weapons.missiles.AGM_114K
  weapons.droptanks.{IAFS_ComboPak_100}
Shindand baseline has enough stock for the known first 2-ship debit
```

Nach der ersten Assignment-Grenze ist zusaetzlich der aus dem akzeptierten Parent-Gate bekannte Kontroll-Delta zwingend:

```text
HYDRA_70_M151: -76
AGM_114K: -4
IAFS_ComboPak_100: -2
```

Nur wenn dieser Kontroll-Delta exakt beobachtet wird, setzt der Harness `firstDebitValidated=true`. Eine falsche STORAGE-Signatur, leere Weapon-Tabelle oder fehlender Kontroll-Delta beendet den Gate mit `status=FAIL`.

## 6. Beobachtung

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
FIRST_LANDED        optional, falls MOOSE den User-Callback liefert
FIRST_ARRIVED       required recovery anchor
FIRST_POST_RETURN
SECOND_ASSIGNED
SECOND_LANDED       optional, falls MOOSE den User-Callback liefert
SECOND_ARRIVED      required recovery anchor
SECOND_POST_RETURN
FINAL
```

Fuer jede zugewiesene FLIGHTGROUP werden MOOSE-Ammo-Summen (`MissilesAG`, `Rockets`, `Bombs`, `Guns`) bei Assignment und Arrived sowie optional bei Landed protokolliert. Assignment und Arrived muessen fuer beide Sorties identische Ammo-Summen liefern, sonst ist die no-fire-Bedingung nicht erfuellt.

## 7. Landed versus Arrived

Der verworfene V1-Lauf zeigte in beiden Sorties:

```text
Landed user callback: not observed
Arrived user callback: observed
```

Daher ist `Landed` in V2 zusaetzliche Telemetrie, aber kein PASS-Kriterium. `Arrived` ist der fuer diesen konkreten MOOSE-/DCS-Pfad erforderliche Recovery-Anker. Das entspricht dem source-reviewed internen MOOSE-Pfad, in dem `onafterArrived` fuer AI-AIRWING-Assets `ReturnToLegion(1)` ausloest.

## 8. PASS-Semantik

Harness-PASS bedeutet ausschliesslich:

```text
all seven STORAGE endpoints resolved with valid three-return GetInventory contract
non-empty weapon inventories observed
Shindand required weapon keys validated
known first 2-ship STORAGE debit exactly validated
first mission assigned and Arrived observed
first sortie no-fire by GetAmmoTot assignment/arrival comparison
post-return observation completed
second mission assigned after first recovery window
second flight Arrived observed
second sortie no-fire by GetAmmoTot assignment/arrival comparison
final STORAGE observation completed
no test-side STORAGE mutation
no CampaignState mutation
no custom ReturnToLegion call
```

`firstLanded` und `secondLanded` werden im RESULT weiterhin protokolliert, sind aber keine zwingenden PASS-Bedingungen.

Die konkrete Recredit-Semantik wird erst nach Auswertung der validen Deltas als DCS-Laufzeitbefund akzeptiert. Der Harness nimmt nicht vorweg, ob die Gutschrift bei Landing, Arrived/ReturnToLegion, spaeter, teilweise oder gar nicht erfolgt.

## 9. Nicht Teil dieses Gates

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

## 10. Build

```text
mission/tests/storage-airwing-weapon-lifecycle/src/01-storage-airwing-weapon-lifecycle.lua
tools/build-storage-airwing-weapon-lifecycle.ps1
mission/tests/storage-airwing-weapon-lifecycle/dist/OMW_Storage_Airwing_Weapon_Lifecycle_Test.lua
```

BuilderVersion:

```text
STORAGE-AIRWING-WEAPON-LIFECYCLE-2
```

Der Builder prueft zusaetzlich statisch, dass der Harness die drei `GetInventory()`-Rueckgabewerte explizit entgegennimmt und verbietet die fehlerhafte V1-Form `local inventory = storage:GetInventory()` sowie Zugriffe auf `inventory.weapon`/`inventory.weapons`.
