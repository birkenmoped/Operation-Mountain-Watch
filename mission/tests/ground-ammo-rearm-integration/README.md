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

> `HISTORICAL_TEST_FIXTURE`: Der vollständige frühere README-Inhalt bleibt über die Git-Historie bis einschließlich Blob `2f1622bdb1a6cd1beeb005af74db07c77af0beea` erhalten. Der aktuelle kombinierte Vertrags- und Acceptance-Stand wird in `ACCEPTANCE-2.md` und `CURRENT-STATUS-TODO.md` geführt. Diese Datei besitzt keine neuere Produktionsautorität.

## Historischer Zweck

`GROUND-AMMO-REARM-ACCEPTANCE-1` war der erste lokale OMW-Ground-Rearm-Vertical-Slice:

```text
Bostick fixed L118 battery
-> controlled ARTY firing
-> observable ammunition reduction
-> Bostick M1083 WAREHOUSE self-request
-> CampaignState GROUND_AMMO_PACKAGE CONSUMPTION
-> ARTY:Rearm()
-> native DCS rearm effect
-> ARTY Rearmed
-> full-ammo confirmation
```

Der Test führte keine eigene strategische Ressourcenhoheit ein und verwendete den an `OMW.Ground.Base` gebundenen autoritativen `CampaignState`-Store.

## MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Geschlossene Acceptance-1-Provenienz

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

Die späteren Invalid-/Diagnose-/Reconciliation-Schritte des Entwicklungsverlaufs sind weiterhin vollständig in der Git-Historie dieses Dokuments nachvollziehbar. Die aktive Fixed-Fire-Support-Architektur, Honaker-Vollentleerungsbedingung, Option-B-Completion-/Restore-Semantik und die gebündelte finale Acceptance sind in folgenden aktuellen Dokumenten definiert:

```text
mission/tests/ground-ammo-rearm-integration/ACCEPTANCE-2.md
mission/tests/ground-ammo-rearm-integration/CURRENT-STATUS-TODO.md
docs/moose/FIXED-FIRE-SUPPORT-REARM.md
```