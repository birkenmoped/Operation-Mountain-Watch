---
document_id: OMW-GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1
status: SUPERSEDED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - historical record of the rejected Joyce/convoy test setup created during Stage 2B
  - explanation why the 2026-08-30 run provides no evidence for Fortress infantry return
not_authoritative_for:
  - Stage 2B Fortress Ground return architecture
  - suitability of Joyce for Stage 2B
  - suitability of the native MOOSE Warehouse spawnzone for Fortress infantry
  - removal or replacement of ZON_BLUE_GND_*_ACCESS zones
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-STAGE-2B-FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2
source_branch: agent/fob-attack-support-demand
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Superseded – Joyce native-homezone Acceptance 1

## Status

Dieser Testaufbau wird **nicht weiterverwendet**.

Er entstand fälschlich aus einem älteren Joyce-Convoy-Präzedenzfall, obwohl die offene Stage-2B-Frage bereits eindeutig auf Fortress und die dort verwendete Infanterie begrenzt war.

Der Projektinhaber hat die Korrektur ausdrücklich klargestellt:

```text
Stage 2B test site: Fortress
Ground asset class: Infantry
Origin Warehouse: WH_BLUE_GND_FORTRESS
Template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
No additional Mission Editor test zones
Existing ZON_BLUE_GND_FORTRESS_ACCESS only if a later MOOSE spawnzone override is actually required
```

## Warum der Joyce-Test ungültig ist

Der historische Test verwendete:

```text
WH_BLUE_GND_JOYCE
TPL_BLUE_GND_PATROL_MATV_4
ZON_BLUE_GND_JOYCE_PATROL_TEST_01
```

Damit wich er in drei entscheidenden Punkten vom aktuellen Prüfgegenstand ab:

```text
wrong site       -> Joyce statt Fortress
wrong asset type -> vehicle/convoy statt infantry
wrong prerequisite -> zusätzliche historische PATROL_TEST-Zone
```

Der letzte Punkt widerspricht zusätzlich der aktuellen Designrichtung, für den Stage-2B-Test **keine neuen Mission-Editor-Testtrigger** zu verlangen. Die erforderliche Threat-/Objective-Geometrie wird mit vorhandenen Fortress-Objekten und MOOSE-Runtime-Zonen erzeugt.

## Realer DCS-Lauf vom 30.08.2026

Der Lauf brach bereits an der fehlenden Mission-Editor-Vorbedingung ab:

```text
FAIL missing destination zone=ZON_BLUE_GND_JOYCE_PATROL_TEST_01
```

Daraus folgt:

```text
Ground group materialized: NO
Native ReturnToLegion tested: NO
Warehouse 250 m spawnzone return tested: NO
Fortress infantry tested: NO
```

Der Lauf ist deshalb weder ein PASS noch ein fachlicher MOOSE-FAIL.

Klassifikation:

```text
INVALID_TEST_SETUP
```

## Weiterführung

Die offene MOOSE-Frage wird nicht mehr isoliert mit Joyce/Convoy geprüft. Sie wird unmittelbar in den vollständigen Fortress-Stage-2B-Test integriert:

```text
Fortress real BLUE infantry sentry
-> runtime OPSZONE threat
-> CAS_IMMEDIATE / Jalalabad AH-64D
-> Fortress infantry QRF / GROUNDATTACK
-> threat clear
-> normal AUFTRAG mission closure
-> native MOOSE ReturnToLegion
-> origin Fortress Legion spawnzone
-> Returned
-> WH_BLUE_GND_FORTRESS AddAsset
-> CampaignState settlement
```

Der erste integrierte Lauf verwendet bewusst:

```text
no BRIGADE/WAREHOUSE SetSpawnZone override
no SetReturnToLegion(false)
no explicit ARMYGROUP:RTZ(...)
no additional ME test zone
```

Wenn die native Warehouse-zentrierte Fortress-Geometrie visuell oder durch DCS-Ground-Pathfinding ungeeignet ist, folgt als nächster MOOSE-first-Schritt ausschließlich die Konfiguration der bestehenden Fortress-ACCESS-Zone als MOOSE-Spawn-/Homezone. Ein eigener OMW-Return-Controller bleibt ausgeschlossen, solange MOOSE diese Anforderung selbst abbildet.
