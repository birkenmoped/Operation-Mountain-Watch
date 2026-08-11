---
document_id: OMW-TEST-AIRBORNE-AMMO-PARTIAL-CONSUMPTION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - targeted airborne cannon/ammunition consumption observation
  - read-only STORAGE correlation after real DCS weapon expenditure
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/airborne-ammo-partial-consumption
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/airops-storage-fuel-template-census
base_commit: baa92e90ef41ca3a2ec1f99ed278c8a834473c20
merged_to_main: false
---

# Airborne Ammo Partial Consumption

## Ziel

Dieser gezielte DCS-Test schliesst die drei offenen Bordwaffenpfade der Warehouse-TODO-Liste:

```text
AH-64D  -> M230 / M789
A-10C   -> GAU-8
OH-58D  -> M3P
```

Der Test simuliert keinen Verbrauch. Er erzwingt eine reale DCS-Waffenabgabe gegen testlokal gespawnte RED-Ziele und beobachtet danach:

```text
onboard ammo at assignment
onboard ammo at Landed
actual shell/gun/cannon consumption
STORAGE weapon debit at materialization
STORAGE weapon recredit after native AIRWING return
JETFUEL debit/recredit as secondary telemetry
```

## Testfaelle

Drei voneinander unabhaengige STORAGE-Lanes laufen parallel:

```text
Kandahar Main      TPL_AIR_US_KAF_A10C_CAS_2SHIP
Jalalabad          TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
Shindand Heliport  TPL_AIR_US_SHND_AH64D_CAS_2SHIP
```

Damit werden GAU-8, M3P und M230 gleichzeitig beobachtet, ohne Inventory-Deltas desselben Warehouses zu vermischen.

Die produktiven Two-Ship-Gruppierungen bleiben unveraendert. Der gepinnte MOOSE-Source zeigt, dass `AUFTRAG:SetRequiredAssets(1, 1)` eine Assetgruppe anfordert und `SQUADRON:SetGrouping(2)` die Assetgruppe auf zwei Units festlegt. Der Test versucht deshalb nicht, aus einem produktiven Two-Ship stillschweigend ein Single-Ship zu machen.

## RED-Testziel und V2-Zielplatzierung

Die aktuelle Mission `OMW_Template_v8_AirOps_rdy.miz` enthaelt vorhandene RED-Testseeds mit den Prefixen:

```text
TPL_TEST_RED_VEHICLE_
TPL_TEST_RED_PACKET_
```

Fuer diesen Test wird gezielt verwendet:

```text
TPL_TEST_RED_VEHICLE_02_01
```

Die am 12.08.2026 read-only aus der Mission gepruefte Gruppe enthaelt zwei Units vom DCS-Typ `tt_B8M1`. Das Mission-Archiv wurde nur gelesen, nicht strukturell veraendert.

Die V1-Annahme `Airbase + 10 km + feste Peilung` wurde verworfen. Sie garantiert weder ebenes Gelaende noch eine brauchbare Fahrzeugposition.

V2 bestimmt die Zielposition mit dem gepinnten MOOSE-Stand fail-closed:

```text
bevorzugte Distanz/Peilung
-> begrenzte Distanz-/Peilungsvarianten
-> COORDINATE:GetClosestPointToRoad()
-> COORDINATE:IsInFlatArea(35 m, 8 %)
-> erster gueltiger Kandidat
```

Bevorzugte Distanzen:

```text
Kandahar A-10C:      20 km
Jalalabad OH-58D:    12 km
Shindand AH-64D:     12 km
```

Findet der bounded Suchlauf keinen flachen Road-Kandidaten, scheitert nur dieser Testfall mit `TARGET_RESOLVE`; es wird kein ungepruefter Fallback-Punkt erzeugt.

## MOOSE-first Angriffspfad

Der productive SQUADRON wird nicht um eine Test-Capability erweitert.

1. Das exakte BLUE-ME-Template wird testlokal als ORBIT-Payload registriert.
2. Ein kurzer ORBIT-Auftrag materialisiert eine produktive Assetgruppe ueber den normalen MOOSE-Warehousepfad.
3. Nach `AIRWING:OnAfterFlightOnMission` wird auf dem zugewiesenen `FLIGHTGROUP` testlokal `SetOptionLandingRestrictPair()` gesetzt.
4. Dem selben `FLIGHTGROUP` wird ein oeffentlicher `AUFTRAG:NewSTRAFING()` in die Mission Queue gestellt.
5. `SetWeaponType(ENUMS.WeaponFlag.GunPod + ENUMS.WeaponFlag.BuiltInCannon)` beschraenkt den Strafing-Task auf Gun Pod/Built-in Cannon und verhindert absichtliche Rocket-Abgabe.
6. `SetWeaponExpend(AI.Task.WeaponExpend.QUARTER)` und `SetEngageQuantity(2)` sind DCS-AI-Vorgaben. Die tatsaechlich verbrauchte Rundenzahl wird **nicht vorausgesetzt**, sondern aus `FLIGHTGROUP:GetAmmoTot()` abgeleitet.
7. Native `Landed -> Arrived -> ReturnToLegion`-Semantik bleibt unangetastet.

Der gepinnte `Moose.lua`-Stand bestaetigt:

```text
COORDINATE:GetClosestPointToRoad()
COORDINATE:IsInFlatArea(...)
AUFTRAG:NewSTRAFING(Target, Altitude, Length)
AUFTRAG:SetWeaponType(WeaponType)
AUFTRAG:SetWeaponExpend(WeaponExpend)
AUFTRAG:SetEngageQuantity(Quantity)
AUFTRAG:SetRequiredAssets(min, max)
OPSGROUP:AddMission(Mission)
OPSGROUP:GetAmmoTot()
FLIGHTGROUP:SetOptionLandingRestrictPair()
SPAWN:NewWithAlias(...):SpawnFromCoordinate(...)
ENUMS.WeaponFlag.GunPod
ENUMS.WeaponFlag.BuiltInCannon
```

## Recovery-/Parking-Grenze

Jalalabad verwendet produktiv typbezogene `SQUADRON:SetParkingIDs(...)`, eine Airbase-Parking-Blacklist und Safe Parking. Diese Mechanismen steuern die Materialisierung, belegen aber keine individuelle Return-Parking-ID fuer jedes Element eines Two-Ships.

V2 verwendet deshalb keine erfundene Parking-Zuweisung und keinen Despawn-Workaround. Stattdessen wird ausschliesslich die oeffentliche MOOSE-/DCS-Landing-Option

```text
FLIGHTGROUP:SetOptionLandingRestrictPair()
```

auf den drei Testfluegen gesetzt. Ziel ist, das gleichzeitige Paar-Landen als moegliche Ursache der beobachteten Recovery-Konflikte zu vermeiden.

Noch **nicht** behauptet wird:

```text
zwei garantiert unterschiedliche Parking-IDs
fehlerfreie Helicopter-Recovery
fehlerfreie A-10-Two-Ship-Recovery
```

Diese Wirkung ist Bestandteil des naechsten DCS-Laufs.

Bewusst ausgeschlossen:

```text
SetDespawnAfterLanding()
SetDespawnAfterHolding()
ReturnToLegion() durch den Test
produktive SQUADRON-Gruppierungs-Aenderung
zweiter testlokaler SQUADRON mit parallelem Bestand
native DCS-Parking-Manipulation
```

## Acceptance-Grenze

Ein strukturell erfolgreicher Fall muss mindestens zeigen:

```text
assignedAmmoShells > landedAmmoShells
```

oder einen anderen real gemessenen Gun/Cannon-Verbrauch. Ein `NO_GUN_CONSUMPTION` ist ein beobachtetes Testergebnis, kein erfundener Verbrauch.

Die STORAGE-Seite wird dynamisch ausgewertet. Es wird **kein** M230-, GAU-8- oder M3P-Storage-Key vorausgesetzt. Gerade das Vorhandensein oder Fehlen eines solchen Deltas ist Teil des Tests.

Zusaetzlich muss fuer eine verwertbare V2-Recovery-Beobachtung dokumentiert werden:

```text
TARGET_RESOLVED fuer den Fall
LANDING_OPTION restrictPair=true
Landed und Arrived oder klar klassifizierter Lifecycle-Abbruch
visuell auffaellige Recovery-/Parking-Ereignisse, falls vorhanden
```

`VALIDATED` ist erst nach dokumentiertem DCS-Lauf mit exaktem Mission-/Bundle-/DCS-/MOOSE-Stand zulaessig.

## Build

```text
Source:
mission/tests/airborne-ammo-partial-consumption/src/01-airborne-ammo-partial-consumption.lua

Builder:
tools/build-airborne-ammo-partial-consumption.ps1

BuilderVersion:
AIRBORNE-AMMO-PARTIAL-CONSUMPTION-2

Bundle:
mission/tests/airborne-ammo-partial-consumption/dist/OMW_Airborne_Ammo_Partial_Consumption.lua
```
