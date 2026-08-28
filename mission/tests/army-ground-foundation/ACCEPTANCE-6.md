---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-6
status: ACCEPTED_TECHNICAL_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - combined ground return, partial-loss and damage acceptance gate
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: c03af3bdf33c83d2fee5477f90f1479df1ec52d3
validated_in_dcs: true
base_branch: agent/army-ground-foundation-reconciliation
base_commit: 8cd87be143d76fcc81d92e034670f012b6c9b824
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch remains unmerged
document_class: DCS_RUNTIME_ACCEPTANCE
acceptance_branch: agent/army-ground-foundation-reconciliation
acceptance_commit: c03af3bdf33c83d2fee5477f90f1479df1ec52d3
acceptance_mission: OMW_Template_v13_ground_test(20260820-160651).miz
acceptance_mission_sha256: 7b10b96cd1fbebef7831ccf633e1f57c34b8a318238b38865606fd47dfeb59db
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# ARMY Ground Acceptance 6 – parallele Rückgabe, Teilverlust und Schaden

## Zweck

Ein einziger DCS-Lauf prüft drei Rückgabevarianten gleichzeitig. Produktionsbestände,
CampaignState-Baselines und .miz werden nicht geändert.

| Site | Ausfahrt | Testeingriff nach MissionDone | Rückkehr | Testgutschrift |
|---|---:|---|---:|---:|
| Fenty | 4 | keiner | 4 | 4 |
| Joyce | 4 | ein M-ATV wird durch MOOSE UNIT:Destroy(false) entfernt | 3 | 3 |
| Wright | 4 | ein M-ATV wird entfernt; ein Rückkehrer erhält MOOSE UNIT:SetLife(50) | 3 | 3 |

## Unveränderter Lifecycle

~~~text
CampaignState test store: Reserve 4 -> Consume 4
-> BRIGADE / PLATOON / WAREHOUSE
-> owner-approved Acceptance-3 road-aligned Warehouse spawn adapter
-> ARMYGROUP / AUFTRAG ARMOREDGUARD OnRoad
-> MissionDone -> 30 s settlement
-> test-only MOOSE loss/damage injection where applicable
-> ARMYGROUP:RTZ(existing site ACCESS zone, OnRoad)
-> Returned -> Warehouse AddAsset -> physical group removal
-> CreditResourceOnce(verified returning unit count)
~~~

MaintenanceTime bleibt beim MOOSE-Default 0. Zurückgekehrte Fahrzeuge sind
unabhängig von einem Schadenswert sofort wieder verfügbar; es gibt keine
Werkstatt-, Reparatur- oder Wartezeitlogik.

## MOOSE-First-Prüfung

- Der bestehende BRIGADE-/PLATOON-/WAREHOUSE-/ARMYGROUP-Lifecycle und die
  road-aligned Spawn-Ausnahme bleiben unverändert.
- GROUP:GetSize() überprüft die aktuelle Anzahl lebender DCS-Units.
- UNIT:Destroy(false) und UNIT:SetLife(50) sind vorhandene MOOSE-Wrapper im
  gepinnten Moose.lua (Commit
  73d3ed119cd9e7e3f2cfcabbaa34513d30529b54, SHA-256
  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915).
  Ihre Verwendung in diesem Ground-Lifecycle ist durch den nachstehenden A6-Lauf validiert.
- Keine neue Native-DCS-Spawn-, Routing-, Warehouse- oder Reparaturlogik.

## Pass-Kriterien

- Drei genau einmal materialisierte, road-aligned Gruppen; kein beobachtbarer
  Spawn-, Routen- oder Rückkehr-Teleport.
- Fenty: vier Rückkehrer und genau eine Gutschrift um vier.
- Joyce: drei Rückkehrer und genau eine Gutschrift um drei; keine Gutschrift
  für den Verlust.
- Wright: drei Rückkehrer, nachweisbarer Schaden an einem Rückkehrer und genau
  eine Gutschrift um drei.
- Je Site genau ein Returned und ein Warehouse AddAsset; danach ist die
  physische Gruppe entfernt.
- Keine globale Fehlermeldung und kein Return-Timeout.

## DCS-Testergebnis – 20.08.2026

~~~text
Tested source commit: c03af3bdf33c83d2fee5477f90f1479df1ec52d3
Builder/Test-ID: ARMY-GROUND-ACCEPTANCE-6-1
Bundle SHA-256: 17d0e5f534f67ca41088e3303e7f8ab9af346a6c8a637c987e4047eb99fc55da
MIZ: OMW_Template_v13_ground_test(20260820-160651).miz
MIZ SHA-256: 7b10b96cd1fbebef7831ccf633e1f57c34b8a318238b38865606fd47dfeb59db
internal mission SHA-256: 535d63cae7562062d96b686b937c2fcc3ac49775396f61e8f7f5088595f2930f
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS: 2.9.28.26385 MT
dcs.log SHA-256: da99733626b2b6886981d4e6b6420f9720d3967c873785a8db9143a97ad56614
debrief.log SHA-256: c17e0dc4b801025d726870806218da0be039c492da96f5a43c590e16b58feb7e
Result: PASS / owner visual acceptance without anomalies
~~~

Der Lauf materialisierte alle drei Gruppen genau einmal und bestätigte den unveränderten MOOSE-Lifecycle über MissionDone, 30-sekündige Settlement-Phase, mobilen ARMYGROUP:RTZ(..., OnRoad) zum jeweiligen bestehenden ACCESS-Marker, Returned, Warehouse AddAsset und kontrollierte Entfernung der temporären DCS-Gruppe. Kein A6-Timeout und kein A6-Laufzeitfehler wurde protokolliert.

- Fenty: vier Rückkehrer, Testcredit genau einmal um vier.
- Joyce: ein mit UNIT:Destroy(false) entfernter Verlust, drei Rückkehrer und Testcredit genau einmal um drei.
- Wright: ein Verlust, ein Rückkehrer durch UNIT:SetLife(50) von Life 4 auf 2 beschädigt, drei Rückkehrer und Testcredit genau einmal um drei.

Der Schadenswert ändert die unmittelbare Rückgabe nicht: Jeder tatsächlich zurückgekehrte Rückkehrer wird gemäß Eigentümerentscheidung sofort wieder verfügbar. Nicht zurückgekehrte Units werden nicht gutgeschrieben. Der isolierte Test-Store bleibt kein Produktionsbestand und keine Produktionsbuchung.
