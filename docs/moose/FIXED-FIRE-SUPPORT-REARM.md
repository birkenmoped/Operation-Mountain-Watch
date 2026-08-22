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
source_branch: agent/ground-ammo-rearm-integration
source_commit: PENDING_MERGE
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

Provenienz:

```text
Source: 5c5fa0ba7653ef51144ca0223dd7cad0ad36f0a7
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-7
Bundle SHA-256: 1655E4F2F5D4AB69BF4BDAFBD82CE3D8FF0049CD557245336B71C275F21BED3D
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v16.miz
dcs.log SHA-256: B3C218B81D5A3C386213E4721F1F1AF12C53DF840C8BB758FE7147E6BAF5FD10
debrief.log SHA-256: 0014C8FE4A4E3BD7DE3D3AF0BCB3DC30C30E786470F1EDA951EBD582F1A48FAE
```

Daraus folgt ausschließlich:

```text
kein 2B11-Defekt nachgewiesen
kein Custom-Rearm erforderlich
vollständige Entleerung = nachgewiesene Voraussetzung des getesteten Pfads
partielle Entleerung = NICHT als funktionierender 2B11-Rearm-Pfad nachgewiesen
```

Die frühere Interpretation, bei 40 -> 36 müsse lediglich länger gewartet werden, ist verworfen.

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

Revision 2-10 korrigierte diesen Vertrag und wurde real gebaut/gehasht:

```text
Source / Git HEAD: f4e781a92bfc74062c48b46b91474f632e69d585
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-10
GeneratedUtc: 2026-08-22T13:44:16Z
Bundle SHA-256: 1180884FEB764F95CFD89D72CE2D04BE633A9FD73AE0939AE4B476179A5977C5
```

Sie wird nicht als isolierter zusätzlicher DCS-Test ausgeführt; die Runtime-Prüfung geht in Revision 2-11 auf.

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

Die allgemeine Ground-Reconciliation bleibt getrennt; `GroundRuntimeIntegration` ruft bei `restored=true` zuerst den allgemeinen Ground-Pfad und danach Local Rearm auf.

## 8. Persistenzarchitektur – tatsächlicher Iststand

`CampaignState` besitzt:

```lua
Store:ExportSnapshot()
CampaignState.Restore(snapshot)
```

Der Store selbst enthält bewusst kein Dateisystem-I/O. `GroundBase` erzeugt keinen CampaignState; der Caller liefert den neuen oder wiederhergestellten Store. `AirOpsWarehouseProduction` kann einen extern bereitgestellten `campaignContext` übernehmen.

Im aktuellen Branch ist **kein produktiver externer Dateisystem-/Server-Persistence-Host vorhanden**, der diesen Snapshot selbst auf Platte schreibt und nach einem Prozessrestart wieder einliest.

Deshalb gilt:

```text
Revision 2-11 darf ExportSnapshot -> Restore -> ReconcileRestore in DCS validieren.
Revision 2-11 darf keinen echten externen Server-/Prozess-Restart-Persistence-Nachweis behaupten.
```

Keine `io`-/`lfs`-Persistenz wird dafür neu eingeführt; keine `MissionScripting.lua`-Änderung und keine zweite Persistenzautorität.

## 9. Gebündelte Revision 2-11

Statt weiterer Einzeltests umfasst ein DCS-Lauf:

```text
Phase A
Bostick/Wright/Fortress physical M1083 rearm
Honaker 2B11 40 -> 0 then M1083 rearm
all four -> COMPLETED -> support return -> SITE_PASS

Phase B on isolated CampaignState restored copies
CONSUMED -> COMPENSATED exactly once
second restore -> no duplicate credit
new transaction ID after compensation -> COMPLETED
COMPLETED survives restore without compensation
RESERVED -> CANCELLED
LOADING -> CANCELLED
authoritative runtime store remains unchanged by restore fixtures
```

Restore-Marker:

```text
RESTORE_PHASE_START
RESTORE_INTERRUPTED_SNAPSHOT
RESTORE_COMPENSATION_PASS
RESTORE_IDEMPOTENCE_PASS
RESTORE_NEW_TRANSACTION_PASS
RESTORE_COMPLETED_PRESERVED_PASS
RESTORE_PRECOMMIT_CANCEL_PASS case=RESERVED
RESTORE_PRECOMMIT_CANCEL_PASS case=LOADING
RESTORE_SETTLEMENT_PASS
```

Gesamt-PASS:

```text
PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=4 restoreSettlement=true
```

## 10. Produktionsbundle-Provenienz

```text
Source / Git HEAD: 49f43a856c1f8bc32ca64835af856119a295640e
CampaignState source SHA-256:
18189A633DBD78FC7EAFBDAF09601BC3241ADAD115DF09DA3EF28B1D85E3E093

AirOps Warehouse Production
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
Bundle SHA-256:
472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

Ground Production
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
Bundle SHA-256:
9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB
```

Diese Produktionsbundles bleiben unverändert.

## 11. Status

```text
MOOSE source review: COMPLETE for documented APIs
Pinned reposition defect: RUNTIME CONFIRMED / excluded
M1083 support choice for Honaker: OWNER CONFIRMED
2B11 40 -> 0 -> 40 diagnostic: RUNTIME CONFIRMED for exact provenance
2B11 partial-ammo rearm: NOT PROVEN
Option B source implementation: COMPLETE
Option B production bundles: BUILD/HASH VERIFIED
Revision 2-10 corrected acceptance: BUILD/HASH VERIFIED / no isolated rerun
Revision 2-11 bundled acceptance: SOURCE/BUILDER COMPLETE / local build-hash PENDING
External filesystem/server persistence host: NOT PRESENT IN CURRENT BRANCH
Revision 2-11 DCS acceptance: PENDING
```
