---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-6
status: DCS_PENDING
owning_policy: OMW-GOV-001
authoritative_for:
  - combined ground return, partial-loss and damage acceptance gate
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: GIT_HISTORY
validated_in_dcs: false
base_branch: agent/army-ground-foundation-reconciliation
base_commit: 8cd87be143d76fcc81d92e034670f012b6c9b824
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch remains unmerged
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
  Ihre Verwendung in diesem Ground-Lifecycle ist bis zum DCS-Lauf nicht validiert.
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
