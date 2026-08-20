---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-7
status: PLANNED
document_class: ACCEPTANCE_TEST_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Acceptance 7 bundled Ground CampaignState settlement gate
  - expected runtime evidence for return, loss, damage and restart reconciliation
not_authoritative_for:
  - production CampaignState activation
  - final production resource mutation
  - DCS runtime behavior before documented execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_TEST
validated_in_dcs: false
supersedes:
superseded_by:
---

# ARMY Ground Foundation – Acceptance 7

## 1. Ziel

Acceptance 7 prüft den kleinen Ground-CampaignState-Settlement-Adapter gegen den bereits akzeptierten MOOSE-Ground-Lifecycle. Der Test führt keine neue DCS-/MOOSE-Lifecycle-, Warehouse- oder Persistenzarchitektur ein.

Verbindliche Korrelation für den getesteten motorisierten Verband:

```text
1 physisches M-ATV = 1 VEHICLE + 3 PERSONNEL
4 M-ATV            = 4 VEHICLE + 12 PERSONNEL
```

Die strategischen Regeln stammen aus `docs/ground/ARMY-GROUND-RETURN-SETTLEMENT-DECISION-PREPARATION.md`:

```text
confirmed return -> immediate one-time credit
confirmed loss -> permanent loss
returned damaged vehicle -> immediate one-time credit
active nonterminal commitment at stop/crash -> one-time strategic recredit at next startup
no physical DCS/MOOSE continuation or respawn
```

## 2. Teststand

Runtime source:

```text
mission/tests/army-ground-foundation/src/07-army-ground-acceptance-7.lua
```

Builder:

```text
tools/build-army-ground-acceptance-7.ps1
```

Generated bundle:

```text
mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_7.lua
```

BuilderVersion / Test-ID:

```text
ARMY-GROUND-ACCEPTANCE-7-1
```

MOOSE-Pin:

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Testumfang

Der Lauf verwendet drei bereits etablierte Ground-Domains gleichzeitig:

```text
FENTY  / GROUND_NODE_JALALABAD
JOYCE  / GROUND_NODE_JOYCE
WRIGHT / GROUND_NODE_WRIGHT
```

Isolierte, produktionsnah geformte Testbestände:

```text
FENTY:  VEHICLE 48 / PERSONNEL 480
JOYCE:  VEHICLE 20 / PERSONNEL 180
WRIGHT: VEHICLE 22 / PERSONNEL 120
```

Diese Stores dienen ausschließlich dem Acceptance-Lauf. Sie aktivieren keine produktive CampaignState-Buchung.

## 4. Erwartete Szenarien

### Fenty – Normal Return

```text
4 M-ATV materialisiert
-> consume 4 VEHICLE + 12 PERSONNEL
-> 4 Rückkehrer
-> credit 4 VEHICLE + 12 PERSONNEL genau einmal
```

### Joyce – Teilverlust

```text
4 M-ATV materialisiert
-> consume 4 VEHICLE + 12 PERSONNEL
-> 1 M-ATV / 3 PERSONNEL als bestätigter Verlust
-> 3 Rückkehrer
-> credit 3 VEHICLE + 9 PERSONNEL genau einmal
-> Verlust bleibt dauerhaft nicht verfügbar
```

### Wright – Teilverlust mit beschädigtem Rückkehrer

```text
4 M-ATV materialisiert
-> consume 4 VEHICLE + 12 PERSONNEL
-> 1 M-ATV / 3 PERSONNEL als bestätigter Verlust
-> 1 überlebendes Fahrzeug erhält Testschaden
-> 3 Rückkehrer insgesamt
-> credit 3 VEHICLE + 9 PERSONNEL genau einmal
-> beschädigter Rückkehrer erhält keine Reparaturwartezeit
```

### Restart-Reconciliation

Ein separater isolierter Store simuliert einen exportierten Zustand mit offenem, bereits konsumiertem Commitment:

```text
consume 4 VEHICLE + 12 PERSONNEL
-> snapshot / restore
-> ReconcileRestore()
-> 4 VEHICLE + 12 PERSONNEL genau einmal zurückbuchen
-> keine DCS-/MOOSE-Gruppe fortsetzen oder respawnen
```

## 5. MOOSE-/CampaignState-Grenze

MOOSE bleibt verantwortlich für:

```text
BRIGADE / PLATOON
WAREHOUSE materialization
AUFTRAG / ARMYGROUP
RTZ
Returned
Warehouse AddAsset
controlled physical group removal
```

CampaignState bleibt verantwortlich für:

```text
ReserveResource
Consume
CreditResourceOnce
strategic return settlement
loss audit
restart reconciliation
```

Der Ground-Adapter enthält selbst keine DCS- oder MOOSE-Aufrufe.

Die bereits freigegebene interne Ausnahme für road-aligned Warehouse-Materialisierung aus Acceptance 3-2 wird unverändert wiederverwendet. Acceptance 7 führt keine weitere private MOOSE-Abweichung ein.

## 6. Statische Gate-Kriterien

Vor dem DCS-Lauf muss der Builder mindestens bestätigen:

```text
correct Acceptance-7 source path
CampaignState source present
Ground CampaignState adapter present
required settlement markers present
required MOOSE lifecycle markers present
approved private Warehouse spawn adapter exactly once
forbidden Native-DCS/MIST/persistence patterns absent
pinned MOOSE commit/hash written into bundle header
bundle SHA-256 emitted
```

Der statische Review ersetzt keinen DCS-Test.

## 7. DCS-Acceptance-Kriterien

Der Lauf gilt nur dann als technisch bestanden, wenn reale Logs und Owner-Beobachtung zusammen mindestens bestätigen:

```text
FENTY:
  one materialization
  four returning vehicles
  VEHICLE credit 4 exactly once
  PERSONNEL credit 12 exactly once

JOYCE:
  one materialization
  one confirmed vehicle loss
  three returning vehicles
  VEHICLE credit 3 exactly once
  PERSONNEL credit 9 exactly once

WRIGHT:
  one materialization
  one confirmed vehicle loss
  one damaged surviving vehicle observed
  three returning vehicles
  VEHICLE credit 3 exactly once
  PERSONNEL credit 9 exactly once

ALL SITES:
  Returned -> Warehouse AddAsset
  physical group removed after handoff
  no duplicate spawn
  no duplicate return credit
  no cross-site group/state collision
  no visible teleport/despawn before the accepted Warehouse handoff

RESTART:
  unresolved 4 VEHICLE + 12 PERSONNEL commitment recredited exactly once
  no physical group continuation or respawn
```

Die erwarteten zentralen Logmarker sind:

```text
CAMPAIGNSTATE_DEPLOYMENT_COMMITTED
CAMPAIGNSTATE_LOSS_RECORDED
CAMPAIGNSTATE_RETURN_CREDIT
CAMPAIGNSTATE_EXACTLY_ONCE
CAMPAIGNSTATE_RESTART_RECONCILED
SCENARIO_DAMAGE_APPLIED
SCENARIO_DAMAGE_CONFIRMED
RETURN_RTZ_ISSUED
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
SITE_RUNTIME_PASS
RUNTIME_PASS_VISUAL_PENDING
```

Jeder `FAIL`-Marker verwirft den Lauf.

## 8. Erforderliche reale Evidenz

Nach dem Lauf werden ausschließlich reale Werte dokumentiert:

```text
branch and source commit
builder version / test ID
bundle SHA-256
MIZ filename and SHA-256
internal mission hash if available through the established verification workflow
embedded bundle/resource hash
DCS version
loaded Moose.lua commit/hash
DCS log
Debrief log
Owner visual observations
```

Ohne diese Evidenz bleibt Acceptance 7 `DCS_PENDING` und darf nicht als `VALIDATED` oder technische Baseline bezeichnet werden.

## 9. Ausgeschlossen

Nicht Bestandteil von Acceptance 7:

```text
production CampaignState activation
production inventory mutation
new Fortress/Honaker quantities
ATO or Ground-order architecture
general cross-domain persistence architecture
OPSTRANSPORT
maintenance / repair queues
physical group persistence across restart
MIZ modification by ChatGPT
```
