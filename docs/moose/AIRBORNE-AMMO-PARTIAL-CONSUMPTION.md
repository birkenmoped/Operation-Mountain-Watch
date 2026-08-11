---
document_id: OMW-MOOSE-AIRBORNE-AMMO-PARTIAL-CONSUMPTION
status: TECHNICAL_DRAFT
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-MOOSE-FIRST
authoritative_for:
  - source-reviewed MOOSE path for targeted airborne cannon expenditure tests
  - test-local RED target spawning boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/airborne-ammo-partial-consumption
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Airborne Ammo Partial Consumption

## Zweck

Diese Notiz dokumentiert den source-reviewten MOOSE-Pfad fuer den gezielten Verbrauchstest der offenen Bordwaffenfamilien M230/M789, GAU-8 und M3P.

## Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Source-reviewed APIs

```text
SPAWN:NewWithAlias(template, alias)
SPAWN:SpawnFromCoordinate(coordinate)
AIRWING:NewPayload(...)
AUFTRAG:NewORBIT(...)
AUFTRAG:NewSTRAFING(Target, Altitude, Length)
AUFTRAG:SetWeaponType(WeaponType)
AUFTRAG:SetWeaponExpend(WeaponExpend)
AUFTRAG:SetEngageQuantity(Quantity)
OPSGROUP:AddMission(Mission)
OPSGROUP:GetAmmoTot()
STORAGE:GetInventory()
STORAGE.Liquid.JETFUEL
```

`AUFTRAG:NewSTRAFING()` setzt im gepinnten Source standardmaessig Guns/Cannons plus Rockets. Fuer den OMW-Kanonentest wird danach mit `SetWeaponType()` auf die MOOSE-Enums

```text
ENUMS.WeaponFlag.GunPod       = 268435456
ENUMS.WeaponFlag.BuiltInCannon = 536870912
```

beschraenkt. Die Summe entspricht dem im MOOSE-TaskStrafing-Beispiel dokumentierten Cannon-Flag `805306368`.

`SetWeaponExpend(AI.Task.WeaponExpend.QUARTER)` ist nur eine DCS-AI-Vorgabe. OMW interpretiert sie nicht als garantierte Rundenzahl. Der reale Verbrauch wird aus `GetAmmoTot()` vor und nach dem Einsatz abgeleitet.

## RED-Testseed

Die Mission `OMW_Template_v8_AirOps_rdy.miz` wurde am 12.08.2026 read-only inspiziert. Vorhanden sind unter anderem die Prefixe:

```text
TPL_TEST_RED_VEHICLE_
TPL_TEST_RED_PACKET_
```

Fuer den ersten gezielten Kanonentest wird `TPL_TEST_RED_VEHICLE_02_01` verwendet. Die Gruppe enthaelt zwei Units vom DCS-Typ `tt_B8M1`.

Die `.miz` wurde fuer diese Feststellung nicht geschrieben, entpackt/repackt oder strukturell veraendert.

## Testgrenze

Der Test darf:

- vorhandene RED-ME-Seeds mit MOOSE `SPAWN` testlokal klonen;
- pro Fall eine Zielposition 10 km von der Heimatbasis berechnen;
- einen echten MOOSE-STRAFING-Auftrag in die Queue eines bereits ueber AIRWING materialisierten `FLIGHTGROUP` stellen;
- Ammo-, STORAGE- und Fuel-Telemetrie read-only erfassen.

Der Test darf nicht:

- CampaignState veraendern;
- STORAGE-Bestaende direkt veraendern;
- `coalition.addGroup()` direkt verwenden;
- `ReturnToLegion()` selbst aufrufen;
- eine kuenstliche Munitionsmenge als realen Verbrauch buchen.

## DCS-offen

Noch nicht praktisch belegt sind:

- ob A-10C, OH-58D und AH-64D den queued STRAFING-Auftrag in diesem Harness wie vorgesehen ausfuehren;
- welche reale Rundenzahl bei `QUARTER` / zwei Attack-Runs abgegeben wird;
- ob und unter welchem STORAGE-Key M230/M789, GAU-8 oder M3P beim Return korreliert werden;
- ob `GetAmmoTot()` fuer alle drei Muster den erwarteten Shell/Gun/Cannon-Delta liefert.

Bis zum dokumentierten DCS-Lauf bleibt dieser Pfad `SOURCE_REVIEWED`, nicht `VALIDATED`.
