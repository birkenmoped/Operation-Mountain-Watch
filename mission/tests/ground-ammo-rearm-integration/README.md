---
document_id: OMW-GROUND-AMMO-REARM-README
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_README
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Ground ammo rearm Acceptance-1 development record
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2
source_branch: agent/ground-ammo-rearm-integration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Bostick M1083 / L118 Rearm Acceptance

> Historischer Acceptance-1-Entwicklungsnachweis. Der aktuelle kombinierte Vertrags- und Acceptance-Stand wird in `ACCEPTANCE-2.md` und `CURRENT-STATUS-TODO.md` geführt. Diese Datei definiert keine neuere Produktionsarchitektur.

## Ziel

`GROUND-AMMO-REARM-ACCEPTANCE-1` ist der gebündelte Runtime-Nachweis für den ersten lokalen OMW-Ground-Rearm-Vertical-Slice.

```text
Bostick fixed L118 battery
-> controlled ARTY firing
-> observable ammunition reduction
-> Bostick M1083 WAREHOUSE self-request
-> road-aligned ACCESS materialization
-> CampaignState GROUND_AMMO_PACKAGE CONSUMPTION
-> ARTY:Rearm()
-> native DCS rearm effect
-> ARTY Rearmed
-> full-ammo confirmation
```

Der Test führt keine eigene strategische Ressourcenhoheit ein. Er verwendet ausschließlich den bereits an `OMW.Ground.Base` gebundenen autoritativen `CampaignState`-Store.

## Historische Missionsbasis

Owner-provided Mission-Editor-Artefakt:

```text
OMW_Template_v15(3).miz
SHA-256: DE19EC3727591E5BEC1FB00E6EEF2D63FF688C97D57390A2BF68607A15E5D84D
```

Erforderliche Objekte des damaligen Acceptance-1-Stands:

```text
WH_BLUE_GND_BOSTICK
ZON_BLUE_GND_BOSTICK_ACCESS
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
TPL_BLUE_GND_SUP_M1083
```

## MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der damalige Test verwendete insbesondere `ARTY:New`, `AssignTargetCoord`, `GetAmmo`, `SetRearmingGroup`, `Rearm` sowie die ARTY-FSM-Hooks. Die spätere produktionsnahe Fixed-Fire-Support-Architektur, der Wechsel auf lokale RESUPPLY-Zonen, der Ausschluss des gepinnten `SetValidateAndRepositionGroundUnits`-Defekts, der Return-to-stock-Vertrag und Option B sind in der aktuellen Fach-/Acceptance-Dokumentation beschrieben und überschreiben diesen historischen README-Kontext.

## Acceptance-1 Provenienz

Vom Projektinhaber real ausgeführt und zurückgemeldet:

```text
Source/Build commit:
213119ca03a6aeae529d4291b4bbe174ac0995c2

BuilderVersion:
GROUND-AMMO-REARM-ACCEPTANCE-1

GeneratedUtc:
2026-08-21T19:59:08Z

Bundle SHA-256:
94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7

Executed MIZ:
OMW_Template_v15.miz

MIZ SHA-256:
A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4

Runtime:
300 -> 296 -> 302
GROUND_AMMO_PACKAGE 52 -> 51
M1083
PASS
```

Diese Provenienz bleibt als historischer technischer Nachweis erhalten. Für den aktuellen Vier-Consumer-/Option-B-Scope sind ausschließlich `ACCEPTANCE-2.md`, `CURRENT-STATUS-TODO.md` und `docs/moose/FIXED-FIRE-SUPPORT-REARM.md` maßgeblich.