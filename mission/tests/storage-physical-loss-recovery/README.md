---
document_id: OMW-TEST-STORAGE-PHYSICAL-LOSS-RECOVERY
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - physical aircraft-loss STORAGE recovery correlation
  - distinction between OPSGROUP despawn loss and real DCS explosion loss
  - AH-64D external-store, aircraft and liquid recovery observation after destruction
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-physical-loss-recovery
source_commit: PENDING_DCS_TEST
validated_in_dcs: false
base_branch: agent/airborne-ammo-parking-correlation
base_commit: 8724c670f2898f5ed14aee676afb365e126ca7a8
merged_to_main: false
---

# Physischer Aircraft-Loss und STORAGE-Recovery

## Ziel

Der bisherige kontrollierte Aircraft-Loss-Test verwendete `OPSGROUP:Destroy()`. Der gepinnte MOOSE-Quellstand zeigt, dass dieser Pfad fuer Flugzeuge ein `UnitLost`-Event erzeugt und die DCS-Unit anschliessend mit `unit:destroy()` entfernt. Der dabei beobachtete STORAGE-Recredit ist deshalb kein ausreichender Nachweis fuer einen physisch zerstoerten Totalverlust.

Dieser Harness isoliert genau diese offene Frage:

```text
AH-64D TwoShip materialisieren
-> bekannten STORAGE-Debit bestaetigen
-> beide realen DCS-Units ueber MOOSE UNIT:Explode() physisch zerstoeren
-> 30 s warten
-> Aircraft-, Liquid- und Weapon-STORAGE erneut lesen
-> Recredit klassifizieren
```

Der Harness mutiert weder STORAGE noch CampaignState.

## MOOSE-First-Pruefung

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Im tatsaechlich verwendeten `Moose.lua` ist `UNIT:Explode(power, delay)` als oeffentliche Wrapper-Methode vorhanden. Sie erzeugt ueber `self:GetCoordinate():Explosion(power)` eine Explosion an der aktuellen Unit-Position. Fuer diesen Test wird daher keine native `trigger.action.explosion`-Parallellogik eingefuehrt.

Der Harness verwendet fuer die zu zerstoerenden Flugzeuge:

```text
FLIGHTGROUP:GetGroup()
-> GROUP:GetUnits()
-> UNIT:Explode(1500)
```

Die Explosion ist damit eine reale DCS-Schadensursache, waehrend die Ausloesung vollstaendig ueber eine vorhandene MOOSE-Funktion erfolgt.

Explizit nicht verwendet:

```text
OPSGROUP:Destroy()
FlightGroup:Destroy()
unit:destroy()
trigger.action.explosion
coalition.addGroup
SPAWN
STORAGE mutation
CampaignState mutation
custom ReturnToLegion()
```

## Testobjekt

```text
Node: Shindand Heliport
AIRWING: bestehende OMW Shindand Foundation
SQUADRON: AH-64D
Mission: no-fire CAS, WeaponHold
Asset request: eine TwoShip-Assetgruppe
```

Bekannter Materialisierungsvertrag:

```text
HYDRA_70_M151       -76
AGM_114K             -4
IAFS_ComboPak_100    -2
```

Der Harness bricht ab, wenn dieser bereits bestaetigte Spawn-Debit nicht reproduzierbar ist. Erst danach wird die physische Zerstoerung ausgeloest.

## Messung

`STORAGE:GetInventory()` wird mit dem bestaetigten Drei-Rueckgaben-Vertrag gelesen:

```lua
local aircraft, liquids, weapons = storage:GetInventory()
```

Es werden drei Ebenen separat ausgewertet:

```text
Aircraft items
Liquid items
Weapon items
```

Fuer jede beim Spawn verringerte Position wird nach der Explosion klassifiziert:

```text
NONE
PARTIAL
FULL
NOT_OBSERVED
```

Die bekannten AH-64-Stores M151, AGM-114K und IAFS werden zusaetzlich separat protokolliert.

## Interpretation

Moegliche Ergebnisse:

```text
A) physisch zerstoert, Stores bleiben abgebucht
   -> bisheriger Recredit war spezifisch fuer programmgesteuertes Destroy/Despawn
   -> Totalverlust kann strategisch ohne Recredit modelliert werden

B) physisch zerstoert, Stores werden ganz oder teilweise gutgeschrieben
   -> reales DCS/STORAGE-Verhalten
   -> CampaignState darf diesen Runtime-Recredit bei Totalverlust nicht ungeprueft uebernehmen

C) Aircraft oder Fuel werden anders behandelt als Weapons
   -> Resource-Semantik muss je Ressourcentyp getrennt werden
```

Der Test trifft selbst keine produktive Loss-Entscheidung. Er liefert nur Runtime-Evidenz fuer die anschliessende Owner-Entscheidung.

## Acceptance-Grenze

`PASS` bedeutet nur, dass der Harness vollstaendig ausgefuehrt wurde und die Post-Explosion-Snapshots vorliegen. Der konkrete Recredit-Status ist das Messergebnis und darf nicht durch den Harness vorgegeben werden.

`VALIDATED` ist erst zulaessig, wenn fuer den tatsaechlichen Lauf dokumentiert sind:

```text
Branch
Source commit
BuilderVersion
Bundle SHA-256
MIZ filename + SHA-256
DCS version
MOOSE release/commit/SHA-256
dcs.log SHA-256
debrief.log SHA-256
```

## Build

```text
Source:
mission/tests/storage-physical-loss-recovery/src/01-storage-physical-loss-recovery.lua

Builder:
tools/build-storage-physical-loss-recovery.ps1

Bundle:
mission/tests/storage-physical-loss-recovery/dist/OMW_Storage_Physical_Loss_Recovery_Test.lua

BuilderVersion:
STORAGE-PHYSICAL-LOSS-RECOVERY-1
```
