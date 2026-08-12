---
document_id: OMW-MOOSE-STORAGE-CLIENT-REARM-EXCHANGE
status: PLANNED
document_class: MOOSE_TOPIC_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE-first client rearm observation path
  - Bagram F-16 STORAGE exchange diagnostic boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-client-rearm-exchange
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Client-Rearm-/STORAGE-Beobachtung

## Zweck

Dieses Dokument beschreibt den read-only MOOSE-Pfad fuer den geplanten Bagram-F-16-Client-Rearm-Test. Ziel ist nicht, Rearm nachzubauen, sondern zu messen, ob DCS beim normalen Ground-Crew-Rearm alte Stores zurueckbucht und neue Stores aus `STORAGE` abbucht.

## Gepinnter Stand

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Source-reviewed Methoden

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetInventory()
SET_CLIENT:New()
SET_CLIENT:FilterCategories()
SET_CLIENT:FilterTypes()
SET_CLIENT:FilterStart()
SET_CLIENT:ForEachClient()
UNIT:GetAmmo()
EVENTHANDLER:New()
BASE:HandleEvent()
EVENTS.WeaponRearm
SCHEDULER:New()
MESSAGE:New(...):ToAll()
```

`UNIT:GetAmmo()` ruft im gepinnten Source read-only `DCSUnit:getAmmo()` auf. Die Auswertung kann `desc.typeName` und `count` verwenden. Diese Aircraft-Ammo-Sicht ist nur Zusatztelemetrie; Targeting Pods und externe Tanks koennen als Warehouse-Items relevant sein, ohne in der Ammo-Tabelle als Waffenposition aufzutauchen.

`EVENTS.WeaponRearm` verwendet `world.event.S_EVENT_WEAPON_REARM` oder `-1`, falls der jeweilige DCS-Stand das Event nicht bereitstellt. Der Test darf deshalb nicht allein von diesem Event abhaengen. Ein bounded Polling von `STORAGE:GetInventory()` und `UNIT:GetAmmo()` alle fuenf Sekunden ist fuer diesen Diagnosezweck vorgesehen.

## Architekturgrenze

```text
CampaignState = spaetere strategische Autoritaet
DCS STORAGE = operative Warehouse-Repräsentation und Beobachtungsquelle
physical client loadout = zusaetzliche Return-/Exchange-Evidenz
```

Der Gate mutiert keine dieser Ebenen. Erst nach dem DCS-Lauf wird entschieden, ob der native DCS-Rearm fuer OMW ausreicht oder ob eine eng begrenzte Reconciliation-Ergaenzung erforderlich ist.

## Testreferenz

```text
mission/tests/storage-client-rearm-exchange/README.md
mission/tests/storage-client-rearm-exchange/src/01-storage-client-rearm-exchange.lua
tools/build-storage-client-rearm-exchange.ps1
```

Bis zum dokumentierten DCS-Lauf bleibt der Methodenstatus `SOURCE_REVIEWED` beziehungsweise `PLANNED`; kein neuer `VALIDATED`-Eintrag wird aus Source-Review allein abgeleitet.
