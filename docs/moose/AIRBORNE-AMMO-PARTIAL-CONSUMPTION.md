---
document_id: OMW-MOOSE-AIRBORNE-AMMO-PARTIAL-CONSUMPTION
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-MOOSE-FIRST
authoritative_for:
  - source-reviewed MOOSE path for targeted airborne cannon expenditure tests
  - test-local RED target spawning and placement boundary
  - test-local landing-pair restriction boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/airborne-ammo-partial-consumption
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Airborne Ammo Partial Consumption

## Zweck

Diese Notiz dokumentiert den source-reviewten MOOSE-Pfad fuer den gezielten Verbrauchstest der offenen Bordwaffenfamilien M230/M789, GAU-8 und M3P. Sie dokumentiert ausserdem die Korrekturen fuer die im vorherigen AirOps-Lifecycle-Lauf sichtbar gewordenen Zielplatzierungs- und Two-Ship-Recovery-Risiken.

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
COORDINATE:GetClosestPointToRoad()
COORDINATE:IsInFlatArea(radius, maxSteepnessPercent)
AIRWING:NewPayload(...)
AUFTRAG:NewORBIT(...)
AUFTRAG:SetRequiredAssets(min, max)
AUFTRAG:NewSTRAFING(Target, Altitude, Length)
AUFTRAG:SetWeaponType(WeaponType)
AUFTRAG:SetWeaponExpend(WeaponExpend)
AUFTRAG:SetEngageQuantity(Quantity)
OPSGROUP:AddMission(Mission)
OPSGROUP:GetAmmoTot()
FLIGHTGROUP:SetOptionLandingRestrictPair()
STORAGE:GetInventory()
STORAGE.Liquid.JETFUEL
```

`AUFTRAG:NewSTRAFING()` setzt im gepinnten Source standardmaessig Guns/Cannons plus Rockets. Fuer den OMW-Kanonentest wird danach mit `SetWeaponType()` auf die MOOSE-Enums

```text
ENUMS.WeaponFlag.GunPod         = 268435456
ENUMS.WeaponFlag.BuiltInCannon = 536870912
```

beschraenkt. Die Summe entspricht dem im MOOSE-TaskStrafing-Beispiel dokumentierten Cannon-Flag `805306368`.

`SetWeaponExpend(AI.Task.WeaponExpend.QUARTER)` ist nur eine DCS-AI-Vorgabe. OMW interpretiert sie nicht als garantierte Rundenzahl. Der reale Verbrauch wird aus `GetAmmoTot()` vor und nach dem Einsatz abgeleitet.

## Gruppierungsgrenze

Der gepinnte Source bestaetigt zwei fuer diesen Test entscheidende Punkte:

1. `SQUADRON:SetGrouping(n)` bestimmt die Unit-Anzahl jeder MOOSE-Assetgruppe der SQUADRON. Beim ersten Einlagern passt `LEGION:onafterNewAsset()` das Asset-Template auf genau diese Gruppierung an.
2. `AUFTRAG:SetRequiredAssets(min, max)` fordert **Assetgruppen**, nicht einzelne Luftfahrzeuge.

Damit bedeutet bei den produktiven A-10C-, OH-58D- und AH-64D-SQUADRONs mit `Grouping=2`:

```text
SetRequiredAssets(1, 1)
= eine MOOSE-Assetgruppe
= ein produktives Two-Ship
```

Der Test aendert diese produktive Gruppierung nicht. Ein testlokaler zweiter SQUADRON mit `Grouping=1` wuerde eine parallele Bestandsrepraesentation riskieren und ist fuer diesen Warehouse-Test nicht zulaessig. Eine produktive Umstellung auf Single-Ship-Assets waere eine eigene Architekturentscheidung und kein Test-Harness-Fix.

## Zielplatzierung

Die erste Testfassung leitete das RED-Ziel nur aus `Airbase + feste Entfernung + feste Peilung` ab. Das beweist weder ebenes Gelaende noch eine fuer Bodenfahrzeuge brauchbare Zielposition.

V2 verwendet deshalb ausschliesslich vorhandene MOOSE-Funktionen:

```text
bevorzugte Entfernung/Peilung je Fall
-> bounded distance/bearing search
-> COORDINATE:GetClosestPointToRoad()
-> COORDINATE:IsInFlatArea(35 m, 8 %)
-> erster gueltiger Kandidat
-> sonst fail closed
```

Die bevorzugten Distanzen sind:

```text
A-10C:  20 km
OH-58D: 12 km
AH-64D: 12 km
```

Die A-10 erhaelt bewusst mehr Anflugraum als die Helikopter. Das ist eine Test-Harness-Konfiguration und noch keine DCS-validierte optimale Strafing-Distanz.

## Two-Ship-Recovery

`SQUADRON:SetParkingIDs()` ist im gepinnten Source eine Spawn-Parking-Einschraenkung fuer SQUADRON-Assets; daraus folgt keine belegte individuelle Return-Parking-Garantie fuer jedes Element eines Two-Ships.

MOOSE stellt jedoch einen oeffentlichen Landing-Option-Pfad bereit:

```text
AIRWING:SetLandingRestrictPair()
-> AIRWING:onafterFlightOnMission(...)
-> FLIGHTGROUP:SetOptionLandingRestrictPair()
```

Der Test verwendet die FLIGHTGROUP-Methode gezielt nur fuer die drei ihm zugewiesenen Testfluege. Damit bleibt die produktive AIRWING-/SQUADRON-Konfiguration unveraendert, waehrend DCS angewiesen wird, das Two-Ship nicht als Paar landen zu lassen.

Das ist **keine** Behauptung, dass DCS dadurch zwei bestimmte oder unterschiedliche Parking-IDs garantiert. Genau diese physische Recovery-Wirkung muss im naechsten DCS-Lauf beobachtet werden.

Bewusst nicht verwendet werden:

```text
SetDespawnAfterLanding()
SetDespawnAfterHolding()
ReturnToLegion() durch den Test
produktive SQUADRON-Gruppierungs-Aenderung
native DCS-Parking-Manipulation
```

Damit bleibt der reale `Landed -> Arrived -> ReturnToLegion`-Pfad messbar und es wird kein sichtbarer Despawn-Workaround eingefuehrt.

## RED-Testseed

Die Mission `OMW_Template_v8_AirOps_rdy.miz` wurde am 12.08.2026 read-only inspiziert. Vorhanden sind unter anderem die Prefixe:

```text
TPL_TEST_RED_VEHICLE_
TPL_TEST_RED_PACKET_
```

Fuer den gezielten Kanonentest wird `TPL_TEST_RED_VEHICLE_02_01` verwendet. Die Gruppe enthaelt zwei Units vom DCS-Typ `tt_B8M1`.

Die `.miz` wurde fuer diese Feststellung nicht geschrieben, entpackt/repackt oder strukturell veraendert.

## Testgrenze

Der Test darf:

- vorhandene RED-ME-Seeds mit MOOSE `SPAWN` testlokal klonen;
- Zielkoordinaten mit einem bounded MOOSE Road-/Flatness-Suchlauf bestimmen;
- einen echten MOOSE-STRAFING-Auftrag in die Queue eines bereits ueber AIRWING materialisierten `FLIGHTGROUP` stellen;
- auf genau diesen Test-FLIGHTGROUPs `SetOptionLandingRestrictPair()` setzen;
- Ammo-, STORAGE- und Fuel-Telemetrie read-only erfassen.

Der Test darf nicht:

- CampaignState veraendern;
- STORAGE-Bestaende direkt veraendern;
- `coalition.addGroup()` direkt verwenden;
- `ReturnToLegion()` selbst aufrufen;
- Landing-/Holding-Despawn als Recovery-Workaround aktivieren;
- produktive SQUADRON-Gruppierung veraendern;
- eine kuenstliche Munitionsmenge als realen Verbrauch buchen.

## DCS-offen

Noch nicht praktisch belegt sind:

- ob die Road-/Flatness-Suche in der ausgefuehrten Afghanistan-Mission fuer alle drei Basen einen taktisch brauchbaren Zielpunkt findet;
- ob A-10C, OH-58D und AH-64D den queued STRAFING-Auftrag in diesem Harness wie vorgesehen ausfuehren;
- ob `SetOptionLandingRestrictPair()` das beobachtete Two-Ship-Recovery-Problem fuer A-10C und Helikopter praktisch verhindert;
- welche realen Parking-IDs beziehungsweise Recovery-Wege DCS danach verwendet;
- welche reale Rundenzahl bei `QUARTER` / zwei Attack-Runs abgegeben wird;
- ob und unter welchem STORAGE-Key M230/M789, GAU-8 oder M3P beim Return korreliert werden;
- ob `GetAmmoTot()` fuer alle drei Muster den erwarteten Shell/Gun/Cannon-Delta liefert.

Bis zum dokumentierten DCS-Lauf bleibt dieser Pfad `SOURCE_REVIEWED`, nicht `VALIDATED`.
