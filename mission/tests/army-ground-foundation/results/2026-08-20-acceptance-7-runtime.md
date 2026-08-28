---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-7-RUNTIME
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Acceptance 7 runtime evidence for the exact recorded branch, bundle, MIZ, DCS and MOOSE stand
not_authoritative_for:
  - production CampaignState activation
  - untested Ground domains or later builds
  - general DCS/MOOSE behavior outside the recorded test stand
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: e049e34fe8e6de878fd390486888f3912bb179d8
validated_in_dcs: true
validation_date: 2026-08-20
supersedes:
superseded_by:
acceptance_branch: agent/army-ground-foundation-reconciliation
acceptance_commit: e049e34fe8e6de878fd390486888f3912bb179d8
acceptance_mission: OMW_Template_v14_ground_test.miz
acceptance_mission_sha256: 88184ec180837044ff4dcef7cca264fe7ee5fcf5d55a8af19b11125c41eab94d
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# ARMY Ground Foundation – Acceptance 7 Runtime Evidence

## 1. Ergebnis

Acceptance 7 ist fuer den exakt unten dokumentierten Stand technisch und visuell akzeptiert.

```text
Result: PASS / owner visual acceptance
Test-ID: ARMY-GROUND-ACCEPTANCE-7-1
```

Der Lauf bestaetigt den kleinen Ground-CampaignState-Settlement-Adapter gegen den bereits akzeptierten MOOSE-Ground-Lifecycle fuer Normalrueckkehr, Teilverlust, beschaedigten Rueckkehrer, Exactly-once-Settlement und Restart-Reconciliation.

## 2. Provenienz

```text
Branch:
agent/army-ground-foundation-reconciliation

Source commit / bundle GitCommit:
e049e34fe8e6de878fd390486888f3912bb179d8

BuilderVersion / Test-ID:
ARMY-GROUND-ACCEPTANCE-7-1

Built bundle:
mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_7.lua

Bundle SHA-256:
b591ccd746896c90064fa93d9b3d42626384f55e605efc748bf304ffccb86ec7

Test MIZ:
OMW_Template_v14_ground_test.miz

MIZ SHA-256:
88184ec180837044ff4dcef7cca264fe7ee5fcf5d55a8af19b11125c41eab94d

Internal mission SHA-256:
0d1cfecc0c600484cbe675e8a7bae5e053658c86aca30500b71a9b370b30518d

Embedded Acceptance-7 bundle SHA-256:
b591ccd746896c90064fa93d9b3d42626384f55e605efc748bf304ffccb86ec7

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Embedded Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

DCS:
2.9.28.26385 MT
```

Die MIZ-, interne Mission-, eingebettete Bundle- und Moose.lua-Pruefung wurde direkt am vom Projektinhaber bereitgestellten `OMW_Template_v14_ground_test.miz` durchgefuehrt. Der eingebettete Acceptance-7-Bundle-Hash stimmt exakt mit dem zuvor lokal erzeugten Builder-Hash ueberein.

## 3. Runtime-Nachweis

### Restart-Reconciliation

Der isolierte Restart-Store konsumierte ein offenes Commitment fuer:

```text
4 VEHICLE + 12 PERSONNEL
```

Nach Snapshot/Restore wurde es strategisch genau einmal rueckgebucht. Es wurde keine physische DCS-/MOOSE-Gruppe fortgesetzt oder respawned.

### Fenty – Normal Return

```text
materialized: 4 M-ATV
strategic consume: 4 VEHICLE + 12 PERSONNEL
returned: 4 M-ATV
strategic return credit: 4 VEHICLE + 12 PERSONNEL
exactly-once: PASS
Warehouse handoff: PASS
physical group removed after handoff: PASS
spawnCount: 1
```

### Joyce – Partial Loss

```text
materialized: 4 M-ATV
strategic consume: 4 VEHICLE + 12 PERSONNEL
confirmed loss: 1 M-ATV + 3 PERSONNEL
returned: 3 M-ATV
strategic return credit: 3 VEHICLE + 9 PERSONNEL
exactly-once: PASS
Warehouse handoff: PASS
physical group removed after handoff: PASS
spawnCount: 1
```

Der bestaetigte Verlust blieb von der Availability-Rueckgabe ausgeschlossen.

### Wright – Partial Loss with Damaged Survivor

```text
materialized: 4 M-ATV
strategic consume: 4 VEHICLE + 12 PERSONNEL
confirmed loss: 1 M-ATV + 3 PERSONNEL
damaged surviving vehicle observed: yes
returned: 3 M-ATV
strategic return credit: 3 VEHICLE + 9 PERSONNEL
exactly-once: PASS
Warehouse handoff: PASS
physical group removed after handoff: PASS
spawnCount: 1
```

Der beschaedigte Rueckkehrer wurde gemaess Settlement-Regel ohne Wartungs- oder Reparaturwartezeit sofort wieder strategisch verfuegbar.

## 4. Zentrale Runtime-Marker

Der reale `dcs.log` erreichte unter anderem:

```text
CAMPAIGNSTATE_RESTART_RECONCILED
CAMPAIGNSTATE_DEPLOYMENT_COMMITTED
CAMPAIGNSTATE_LOSS_RECORDED
CAMPAIGNSTATE_RETURN_CREDIT
CAMPAIGNSTATE_EXACTLY_ONCE
SCENARIO_DAMAGE_APPLIED
SCENARIO_DAMAGE_CONFIRMED
RETURN_RTZ_ISSUED
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
SITE_RUNTIME_PASS
RUNTIME_PASS_VISUAL_PENDING sites=3 passed=3
```

Es wurde kein Acceptance-7-`FAIL`-Marker festgestellt.

Die letzten Site-Ergebnisse waren:

```text
WRIGHT: SITE_RUNTIME_PASS, returningUnits=3, physicalGroupRemoved=true
JOYCE:  SITE_RUNTIME_PASS, returningUnits=3, physicalGroupRemoved=true
FENTY:  SITE_RUNTIME_PASS, returningUnits=4, physicalGroupRemoved=true
GLOBAL: RUNTIME_PASS_VISUAL_PENDING sites=3 passed=3
```

## 5. Owner Visual Acceptance

Rueckmeldung des Projektinhabers nach dem Lauf:

```text
soweit ich sehen konnte sah es gut aus
```

Diese Rueckmeldung wird konservativ als positive visuelle Acceptance fuer den beobachteten Lauf gewertet: Es wurden vom Projektinhaber keine sichtbaren Auffaelligkeiten gemeldet. Sie ist keine Aussage ueber unbeobachtete oder ausserhalb dieses Testlaufs liegende Situationen.

## 6. Acceptance-Grenze

Damit ist fuer diesen exakten Teststand bestaetigt:

```text
1 physical M-ATV = 1 VEHICLE + 3 PERSONNEL
confirmed returned unit -> immediate one-time strategic credit
confirmed non-returned unit -> permanent loss
damaged returned unit -> immediate availability
active nonterminal commitment at restart -> one-time strategic recredit
no physical DCS/MOOSE continuation or respawn
```

Nicht durch diesen Lauf aktiviert oder validiert:

```text
production CampaignState mutation
production Ground mission/order dispatch
Fortress/Honaker new strategic quantities
OPSTRANSPORT
maintenance / repair queues
general cross-domain persistence architecture
```

## 7. Naechster Gate

Nach dieser Acceptance darf die Produktionsintegration des bereits getesteten Ground-CampaignState-Adapters gegen den autoritativen CampaignState-Initialbestand vorbereitet werden. Die strategische Ressourcenhoheit bleibt ausschliesslich bei CampaignState; MOOSE bleibt fuer den operativen Ground-Lifecycle verantwortlich.
