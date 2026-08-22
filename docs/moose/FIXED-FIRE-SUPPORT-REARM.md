---
document_id: OMW-MOOSE-FIXED-FIRE-SUPPORT-REARM
status: DRAFT
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE-first composition for local fixed-fire-support ammunition materialization and rearm
  - support return-to-stock lifecycle for Bostick, Wright, Fortress and Honaker
  - LOCAL REARM CampaignState completion and restore-settlement boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: main
source_commit: 761f392bbd4e9ffee416e2e598235d9040a9a752
validated_in_dcs: partial
---

# MOOSE Fixed Fire Support Rearm

## 1. Zweck und Architekturgrenze

Lokaler Munitionsnachschub für:

```text
BOSTICK   -> L118
WRIGHT    -> L118
FORTRESS  -> L118
HONAKER   -> 2B11
```

`CampaignState` ist alleinige strategische Ressourcenautorität. MOOSE WAREHOUSE/BRIGADE/PLATOON und DCS-Gruppen bilden den operativen bzw. physischen Lifecycle ab.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Produktionsnah verwendet:

```lua
WAREHOUSE:SetSpawnZone(...)
WAREHOUSE:AddAsset(...)
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:SetRearmingDistance(...)
ARTY:Rearm()
ARTY OnAfterRearmed
SCHEDULER:New(...)
```

`ARTY OnAfterRearmed` ist der vorhandene MOOSE-Completion-Hook. Es gibt keinen eigenen Rearm-FSM, keinen FullAmmo-Scanner und keinen MOOSE-Patch.

## 3. Warehouse-Materialisierung

Pro Standort wird eine kontrollierte RESUPPLY-Zone verwendet:

```text
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Materialisierung:

```lua
WAREHOUSE:SetSpawnZone(Zone, MaxDist)
```

Bewusst ausgeschlossen:

```lua
WAREHOUSE:SetValidateAndRepositionGroundUnits(true)
```

Der gepinnte Source ruft dort intern `UTILS.GetCenterPoint(units)` auf; im gepinnten Stand wurde keine Definition gefunden. Der reale DCS-Lauf reproduzierte `attempt to call field 'GetCenterPoint' (a nil value)`. OMW patcht MOOSE nicht und baut diese Funktion nicht nach.

Der private `OMW_GroundRoadSpawnAdapter` bleibt außerhalb dieses Fixed-Fire-Support-Pfads.

## 4. ARTY-Rearm und Support-Rückkehr

```text
WAREHOUSE local M1083 materialization
-> GroundAmmoRearmAdapter reservation
-> ARTY:SetRearmingGroup(...)
-> ARTY:Rearm()
-> OnBeforeRearm
-> CampaignState CONSUMED
-> physical DCS/MOOSE rearm
-> ARTY OnAfterRearmed
-> CampaignState COMPLETED
-> ARTY-owned return to remembered origin
-> bounded MOOSE SCHEDULER confirmation
-> WAREHOUSE:AddAsset(Group)
```

OMW erzeugt keinen eigenen Return-Wegpunkt. Erfolgreicher Rearm erstattet keine `GROUND_AMMO_PACKAGE`-Ressource zurück.

## 5. 2B11-Evidenzgrenze

Der gezielte Diagnosevertrag verlangte:

```text
fireShells = 40
requireAmmoDepleted = true
postFireAmmo == 0
Support request erst nach bestätigter Vollentleerung
```

Real bestätigt:

```text
2B11 40 -> 0
-> Support request
-> 0 -> 40
-> SITE_REARMED
-> SITE_SUPPORT_RETURNED
-> SITE_PASS
-> aggregate PASS
```

Daraus folgt ausschließlich:

```text
kein 2B11-Defekt nachgewiesen
kein Custom-Rearm erforderlich
vollständige Entleerung = nachgewiesene Voraussetzung des getesteten Pfads
partielle Entleerung = NICHT als funktionierender 2B11-Rearm-Pfad nachgewiesen
```

## 6. M1083 Owner-Entscheidung

```text
Honaker verwendet TPL_BLUE_GND_SUP_M1083.
Weitere Bestätigung des M1083 als Supportfahrzeug ist nicht erforderlich.
M939 bleibt historische Diagnoseevidenz.
```

Aktiver Vertrag:

```text
BOSTICK   -> M1083 / 4 rounds
WRIGHT    -> M1083 / 4 rounds
FORTRESS  -> M1083 / 4 rounds
HONAKER   -> M1083 / 40 rounds / requireAmmoDepleted=true / request only at postFireAmmo=0
```

## 7. LOCAL REARM Option B

Owner-approved Lifecycle:

```text
physical rearm begins
-> GROUND_AMMO_PACKAGE transaction = CONSUMED

ARTY OnAfterRearmed
-> transaction = COMPLETED

Restore mit CONSUMED aber nicht COMPLETED
-> CreditResourceOnce(...)
-> transaction = COMPENSATED
-> old transaction remains closed
-> no physical replay
-> later physical rearm requires new transaction ID
```

Korrelation:

```text
reservationId = GROUND-LOCAL-REARM:<transactionId>
restart creditId = GROUND-LOCAL-REARM-RESTART:<transactionId>
```

`GroundAmmoRearmAdapter.ReconcileRestore(...)` behandelt:

```text
CONSUMED   -> exactly-once compensation -> COMPENSATED
COMPLETED  -> no compensation
COMPENSATED -> no duplicate compensation
RESERVED / LOADING -> Cancel
```

## 8. Persistenzarchitektur – tatsächlicher Iststand

`CampaignState` besitzt:

```lua
Store:ExportSnapshot()
CampaignState.Restore(snapshot)
```

Der Store selbst enthält bewusst kein Dateisystem-I/O. `GroundBase` erzeugt keinen CampaignState; der Caller liefert den neuen oder wiederhergestellten Store. `AirOpsWarehouseProduction` kann einen extern bereitgestellten `campaignContext` übernehmen.

Auf dem integrierten `main`-Stand ist **kein produktiver externer Dateisystem-/Server-Persistence-Host vorhanden**, der diesen Snapshot selbst auf Platte schreibt und nach einem Prozessrestart wieder einliest.

Deshalb gilt:

```text
Acceptance 2-11 validiert ExportSnapshot -> Restore -> ReconcileRestore in DCS.
Acceptance 2-11 beweist keinen echten externen Server-/Prozess-Restart-Persistence-Pfad.
```

Die Restore-Settlement-Phase von Acceptance 2-11 lief auf isolierten `CampaignState.Restore(...)`-Kopien **innerhalb derselben DCS-Session**. Sie ist kein physischer Server-Restart-Test und kein externer Persistenznachweis.

Keine `io`-/`lfs`-Persistenz wird dafür neu eingeführt; keine `MissionScripting.lua`-Änderung und keine zweite Persistenzautorität.

## 9. Acceptance 2-11 – realer DCS-PASS

```text
Acceptance source/build commit:
d52a47a418fe3a1a996a5b68198b8dc033ff86c4

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11

Acceptance Bundle SHA-256:
CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B

Executed mission:
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v16.miz

Executed mission SHA-256:
388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620

DCS:
2.9.28.26385 MT
```

Physische Phase:

```text
BOSTICK   300 -> 296 -> 301 / M1083 / COMPLETED / return-to-stock / PASS
WRIGHT    300 -> 296 -> 300/301 / M1083 / COMPLETED / return-to-stock / PASS
FORTRESS  150 -> 146 -> 151 / M1083 / COMPLETED / return-to-stock / PASS
HONAKER    40 ->   0 ->  40 / M1083 / COMPLETED / return-to-stock / PASS
```

Restore-Settlement innerhalb derselben DCS-Laufzeit:

```text
CONSUMED -> COMPENSATED exactly once                       PASS
second restore -> no duplicate credit                     PASS
new transaction after compensation -> new ID -> COMPLETED PASS
COMPLETED restore -> no compensation                      PASS
RESERVED restore -> CANCELLED                             PASS
LOADING restore -> CANCELLED                              PASS
authoritative runtime store isolation                     PASS
```

Gesamtmarker:

```text
PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=4 restoreSettlement=true
```

Vollständige Evidenz:

```text
mission/tests/ground-ammo-rearm-integration/results/2026-08-22-acceptance-2-11-runtime.md
```

## 10. Merge und Post-Merge Produktionsbuild

PR #112 wurde nach ausdrücklicher Owner-Freigabe auf Ready gesetzt und anschließend nach `main` gemerged:

```text
PR: 112
Merge commit: 761f392bbd4e9ffee416e2e598235d9040a9a752
```

Danach wurden die produktiven Bundles real auf `main` neu gebaut:

```text
AirOps Warehouse Production
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
Output: mission/runtime/logistics/OMW_AirOps_Warehouse_Base.lua
Builder-reported BundleSHA256:
F4FBF6DB71E56AADBF0B31C931638754FF4DDB75F90E570BA127E56A0251974F

Ground Production
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
Output: mission/ground-operations/dist/OMW_Ground_Base.lua
Builder-reported SHA256:
A5D2A101FFEC3F1C222463002D7D5668C77EF6ACDEEDE1D8B8FEEB5E19D2E026
```

Die separaten direkten `Get-FileHash`-Readbacks der beiden korrekten Ausgabepfade stehen noch aus. Bis zu dieser realen Rückmeldung gelten die beiden Werte ausschließlich als Builder-Ausgabe.

## 11. Mission-Editor Cleanup nach Acceptance

Der kombinierte Acceptance-Harness ist nicht Teil der produktiven OMW-Runtime.

Aus einer normalen Arbeits-/Produktionsmission entfernen:

```text
OMW_Ground_Fire_Support_Acceptance_2.lua
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET
```

Produktiv erhalten bleiben:

```text
Moose.lua
OMW_AirOps_Warehouse_Base.lua
OMW_Ground_Base.lua
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Die bytegenau nachgewiesene `OMW_Template_v16.miz` mit SHA-256 `388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620` bleibt als unverändertes Acceptance-Artefakt erhalten. Weitere Missionsentwicklung erfolgt auf einer neuen Arbeitsrevision.

## 12. Status

```text
MOOSE source review: COMPLETE for documented APIs
Pinned reposition defect: RUNTIME CONFIRMED / excluded
M1083 support choice for Honaker: OWNER CONFIRMED
2B11 40 -> 0 -> 40: RUNTIME CONFIRMED
2B11 partial-ammo rearm: NOT PROVEN
Option B source implementation: COMPLETE / MERGED TO MAIN
Acceptance 2-11 build/hash: VERIFIED
Acceptance 2-11 physical rearm: DCS PASS
Acceptance 2-11 restore settlement: DCS PASS within same-session runtime snapshot/restore scope
Exact runtime MIZ provenance: CLOSED
PR #112: MERGED
Post-merge production rebuild: COMPLETE
Post-merge direct production artifact hash readback: PENDING
External filesystem/server persistence host: NOT PRESENT / NOT TESTED / NOT CLAIMED
```
