---
document_id: OMW-MOOSE-STORAGE-CLIENT-REARM-EXCHANGE
status: ACCEPTED_TECHNICAL_BASELINE
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
validated_in_dcs: true
acceptance_branch: agent/storage-client-rearm-exchange
acceptance_commit: f4e5352eba4afb51c365768641c6a456a065b929
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: 76735e0ba85634a2f84716b38debab7add411851896cb14b1ba5f23cb7b47181
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
acceptance_bundle_sha256: 291b8ade7cc59e363f73995dea4f73863aa96068bfe0ee85153a6b6c097dcf62
---

# MOOSE Client-Rearm-/STORAGE-Beobachtung

## Zweck

Dieses Dokument beschreibt den read-only MOOSE-Pfad und die Runtime-Acceptance fuer den Bagram-F-16-Client-Rearm-Test. Ziel ist nicht, Rearm nachzubauen, sondern zu messen, ob DCS beim normalen Ground-Crew-Rearm alte Stores zurueckbucht und neue Stores aus `STORAGE` abbucht.

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
CampaignState = strategische Autoritaet
DCS STORAGE = operative Warehouse-Repräsentation und Beobachtungsquelle
physical client loadout = zusaetzliche Return-/Exchange-Evidenz
```

Der Gate mutiert keine dieser Ebenen. Der Runtime-Lauf entscheidet nur, ob der native DCS-Rearm im dokumentierten Scope fuer OMW als physischer Exchange-Pfad ausreicht.

## Runtime-Acceptance 2026-08-12

Getesteter Stand:

```text
DCS 2.9.28.26385 MT
branch agent/storage-client-rearm-exchange
commit f4e5352eba4afb51c365768641c6a456a065b929
client CLIENT_US_BGRM_F16_01_UNIT_01
node Bagram
mission OMW_Template_v8_AirOps_rdy.miz
mission SHA-256 76735e0ba85634a2f84716b38debab7add411851896cb14b1ba5f23cb7b47181
bundle SHA-256 291b8ade7cc59e363f73995dea4f73863aa96068bfe0ee85153a6b6c097dcf62
```

Das in der getesteten MIZ eingebettete Testbundle hatte exakt den dokumentierten Bundle-Hash; das eingebettete `Moose.lua` hatte exakt den gepinnten MOOSE-Hash.

Praktisch bestaetigt:

| Pfad/Methode | Status | Belegter Umfang |
|---|---|---|
| `AIRBASE:FindByName("Bagram")` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Bagram-Aufloesung fuer den Client-Rearm-Harness |
| `AIRBASE:GetStorage()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | operative Bagram-STORAGE-Aufloesung im Runtime-Lauf |
| `STORAGE:FindByName("Bagram")` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Registry-Aufloesung; Wrapper-Identitaet zum Airbase-STORAGE-Pfad bestaetigt |
| `STORAGE:GetInventory()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | wiederholte Weapon-Deltas bei Client-Rearm sichtbar |
| `SET_CLIENT` Filter-/Iteration-Pfad | `VALIDATED_FOR_DOCUMENTED_SCOPE` | aktiver Bagram-F-16-Client gebunden |
| `UNIT:GetAmmo()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Waffen-Deltas spiegelbildlich zu Warehouse-Deltas beobachtet |
| `EVENTHANDLER:New()` + `BASE:HandleEvent()` + `EVENTS.WeaponRearm` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | sieben Client-WeaponRearm-Events im Lauf geliefert |
| `SCHEDULER:New()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | 5-s-Polling lieferte geordnete Delta-Snapshots |

Beobachtete Exchange-Semantik:

```text
new mounted weapon       -> STORAGE debit
removed weapon           -> STORAGE recredit
370-gal external tank    -> debit und Rueckgabe
AN/AAQ-33                 -> debit und Rueckgabe
AAQ-28 LITENING           -> debit und Rueckgabe
ALQ-184                    -> debit und Rueckgabe
LAU-88                     -> debit und Rueckgabe
```

Wiederholte Waffenbeispiele umfassten GBU-12, GBU-38, Mk-82, AIM-120C, AIM-9X und AGM-65H. Bei den durch `UNIT:GetAmmo()` sichtbaren Waffen verliefen Aircraft-AMMO- und STORAGE-Deltas in den beobachteten Rearm-Schritten konsistent spiegelbildlich.

## Architekturentscheidung aus dem Gate

Fuer den exakt dokumentierten Runtime-Scope gilt:

```text
DCS native client rearm exchange: sufficient
removed stores -> warehouse return: PASS
new stores -> warehouse debit: PASS
reusable external stores -> observable debit/return: PASS
EVENTS.WeaponRearm -> delivered
```

Daraus folgt fuer OMW:

```text
do not reimplement client rearm
```

Der spaetere CampaignState-Adapter soll den nativen DCS/STORAGE-Vorgang beobachten, gegen den autoritativen strategischen Ledger reconciliieren und die strategische Transaktion idempotent committen. Eine parallele Rearm-Mechanik ist fuer diesen belegten Scope nicht zu bauen.

## Grenzen

Die Acceptance belegt nicht automatisch:

```text
andere Flugzeugtypen
andere Airbases
AI-Rearm
Weapon expenditure
Fuel-only refuel exchange
Rearm-Blockierung bei strategischem Fehlbestand
produktive CampaignState-Reconciliation
andere DCS- oder MOOSE-Versionen
```

Der Harness schrieb keinen abschliessenden `RESULT`-Marker, weil die Mission vor dem 3600-s-Safety-Timeout beendet wurde. Die fuer die Gate-Entscheidung benoetigten Debit-/Return-Sequenzen waren zu diesem Zeitpunkt bereits mehrfach vollstaendig beobachtet.

## Testreferenz

```text
mission/tests/storage-client-rearm-exchange/README.md
mission/tests/storage-client-rearm-exchange/src/01-storage-client-rearm-exchange.lua
tools/build-storage-client-rearm-exchange.ps1
```

Naechster Ressourcen-Gate: **Client Refuel**. Vor eigener Fuel-Korrekturlogik ist analog zuerst der native DCS/STORAGE-Pfad zu beobachten.
