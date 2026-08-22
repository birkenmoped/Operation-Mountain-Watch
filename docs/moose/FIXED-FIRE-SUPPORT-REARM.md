---
document_id: OMW-MOOSE-FIXED-FIRE-SUPPORT-REARM
status: DRAFT
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE-first composition for local fixed-fire-support ammunition materialization and rearm
  - support return-to-stock lifecycle for Bostick, Wright, Fortress and Honaker
  - LOCAL REARM CampaignState completion and restart-settlement boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE Fixed Fire Support Rearm

## 1. Zweck und Geltungsgrenze

Dieses Dokument beschreibt den MOOSE-first-Pfad für lokalen Munitionsnachschub der festen BLUE-Feuerunterstützungsstellungen Bostick, Wright, Fortress und Honaker.

```text
BOSTICK   -> L118
WRIGHT    -> L118
FORTRESS  -> L118
HONAKER   -> 2B11
```

`CampaignState` bleibt die einzige strategische Ressourcenautorität. MOOSE WAREHOUSE/BRIGADE/PLATOON bildet nur den operativen Asset-Lifecycle ab; DCS/MOOSE-Gruppen sind physische Repräsentationen.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für den produktionsnahen Fixed-Fire-Support-Pfad werden die im gepinnten Source vorhandenen öffentlichen Verträge verwendet:

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

Option B führt **keine neue MOOSE-API** ein. `ARTY OnAfterRearmed` bleibt der vorhandene Framework-Completion-Hook. Es gibt keinen eigenen Rearm-FSM, keinen FullAmmo-Scanner und keinen MOOSE-Patch.

## 3. Lokale Warehouse-Materialisierung

Für Fixed Fire Support wird pro Standort eine dedizierte Mission-Editor-RESUPPLY-Zone auf freiem Boden innerhalb der jeweiligen FOB/COP-Anlage verwendet.

Verwendeter Pfad:

```lua
WAREHOUSE:SetSpawnZone(Zone, MaxDist)
```

Bewusst ausgeschlossen:

```lua
WAREHOUSE:SetValidateAndRepositionGroundUnits(true)
```

### 3.1 Verifizierter Defekt im gepinnten MOOSE-Stand

Die Methode `WAREHOUSE:SetValidateAndRepositionGroundUnits(...)` ist real und in MOOSE dokumentiert. Der gepinnte OMW-Source ruft in der internen Helper-Kette jedoch `UTILS.GetCenterPoint(units)` auf; für den gepinnten Stand wurde keine Definition dieser Funktion gefunden. Der reale DCS-Lauf vom 22.08.2026 reproduzierte:

```text
attempt to call field 'GetCenterPoint' (a nil value)
ValidateAndRepositionGroundUnits
-> _SpawnAssetGroundNaval
-> _SpawnAssetRequest
-> onafterRequest
```

OMW patcht MOOSE nicht und baut `GetCenterPoint` nicht nach. `WAREHOUSE:SetSpawnZone(...)` mit kontrollierter ME-Zone erfüllt den benötigten lokalen Materialisierungsvertrag ohne Parallelframework.

## 4. Mission-Editor-Vertrag

```text
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Anforderung:

```text
- innerhalb der jeweiligen FOB/COP-Anlage
- nahe dem lokalen Warehouse
- freier, für einen M1083 geeigneter Boden
- nicht als Straßen-/Convoy-Zone auslegen
- Abstand zu HESCOs, Gebäuden, Statics und anderen Ground Units berücksichtigen
```

Der private `OMW_GroundRoadSpawnAdapter` bleibt außerhalb des produktionsnahen Fixed-Fire-Support-Pfades. Die kombinierte Acceptance 2 verwendet für alle vier Standorte den normalen M1083-/SetSpawnZone-Vertrag ohne Road-Spawn-Ausnahme.

## 5. ARTY-Rearm und Rückkehr

Im gepinnten Source vorhanden:

```lua
ARTY:SetRearmingGroup(Group)
ARTY:SetRearmingGroupOnRoad(false)
ARTY:SetRearmingDistance(100)
ARTY:Rearm()
```

`ARTY:onafterRearm(...)` speichert die Ausgangskoordinate der RearmingGroup. `ARTY:onafterRearmed(...)` übernimmt bei ausreichender Distanz die physische Rückkehr zur gemerkten Ausgangskoordinate.

OMW erzeugt keinen eigenen Return-Wegpunkt. Ein MOOSE-`SCHEDULER` prüft alle 5 s die Rückkehrgrenze; nach bestätigter Rückkehr erfolgt:

```lua
WAREHOUSE:AddAsset(Group)
```

Damit bleibt der operative Asset-/Stock-Lifecycle MOOSE-owned. CampaignState bleibt alleinige strategische Autorität für `GROUND_AMMO_PACKAGE`.

## 6. Korrigierte DCS-Rearm-Interpretation und 2B11-Diagnose

Frühere partielle 2B11-Entleerungen wurden zunächst als möglicher Support-/Weapon-Type-Fehler interpretiert. Die anschließende Diagnose zeigte für den exakt getesteten Stand:

```text
2B11 40 -> 0
-> Support request
-> 0 -> 40
-> SITE_REARMED
-> SITE_SUPPORT_RETURNED
-> SITE_PASS
-> aggregate PASS
```

Diagnose-Provenienz:

```text
Source: 5c5fa0ba7653ef51144ca0223dd7cad0ad36f0a7
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-7
Bundle SHA-256: 1655E4F2F5D4AB69BF4BDAFBD82CE3D8FF0049CD557245336B71C275F21BED3D
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v16.miz
dcs.log SHA-256: B3C218B81D5A3C386213E4721F1F1AF12C53DF840C8BB758FE7147E6BAF5FD10
debrief.log SHA-256: 0014C8FE4A4E3BD7DE3D3AF0BCB3DC30C30E786470F1EDA951EBD582F1A48FAE
```

Belegbare Schlussfolgerung:

```text
- kein 2B11-Defekt nachgewiesen
- keine M1083-Inkompatibilität nachgewiesen
- DCS bestimmt den tatsächlichen Rearm-Zeitpunkt
- kein Custom-Rearm für 2B11 erforderlich
```

Die zwischenzeitliche M939-/40-Schuss-Vollentleerungsvariante bleibt Diagnoseevidenz und ist kein Produktionsvertrag.

## 7. Produktiver Fixed-Fire-Support-Vertrag nach Diagnose-Rückbau

Der aktive kombinierte Acceptance-Vertrag verwendet wieder einheitlich:

```text
BOSTICK   -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
WRIGHT    -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
FORTRESS  -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
HONAKER   -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
```

Nicht mehr aktiv:

```text
TPL_BLUE_GND_SUP_M939 for Honaker
fireShells = 40
requireAmmoDepleted
HONAKER_AMMO_DEPLETED
HONAKER_REARM_REQUEST_AFTER_EMPTY
HONAKER_AMMO_NOT_DEPLETED
```

Revision 2-8 wurde real gebaut und gehasht:

```text
Source / Git HEAD: 02093710b7feabf3440cb04674f7799207b9da5e
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-8
GeneratedUtc: 2026-08-22T12:49:12Z
Bundle SHA-256: 54019389DF61173BAA732524F716DFAC7930B2E74B226445167588380554FF0B
```

Dieser Nachweis ist Build-/Contract-Evidenz, kein zusätzlicher DCS-Runtime-PASS.

## 8. LOCAL REARM Restart/Replay – Option B

Owner-Entscheidung vom 22.08.2026: **Option B genehmigt**.

Verbindlicher Lifecycle:

```text
Rearm accepted / physical service begins
-> GROUND_AMMO_PACKAGE transaction = CONSUMED

ARTY OnAfterRearmed
-> transaction = COMPLETED

restored startup with CONSUMED but not COMPLETED
-> exactly-once strategic compensation
-> transaction = COMPENSATED
-> old transaction remains historical/closed
-> no physical replay
-> any later rearm requires a new transaction ID
```

Implementierungsgrenze:

```text
CampaignState.TransactionStatus.COMPLETED
CampaignState.TransactionStatus.COMPENSATED
CampaignState:CompleteConsumption(...)
CampaignState:MarkConsumptionCompensated(...)
GroundAmmoRearmAdapter.ReconcileRestore(...)
```

Korrelation:

```text
reservationId = GROUND-LOCAL-REARM:<transactionId>
restart creditId = GROUND-LOCAL-REARM-RESTART:<transactionId>
```

Restore-Reihenfolge:

```text
existing general Ground ReconcileRestore()
-> Local Rearm ReconcileRestore()
```

Damit bleibt die allgemeine Ground-Restart-Reconciliation unverändert; Local Rearm ergänzt nur den speziellen Completion-/Settlement-Vertrag.

## 9. Genau-einmal-Restart-Settlement

Für eine wiederhergestellte Local-Rearm-Transaktion gilt:

```text
COMPLETED
-> keine Gutschrift
-> bleibt historisch abgeschlossen und konsumiert

CONSUMED
-> CreditResourceOnce(...)
-> COMPENSATED
-> keine physische Mission wird wiederhergestellt

COMPENSATED
-> keine zweite Gutschrift

RESERVED / LOADING
-> Cancel
-> Reservation wird freigegeben
```

Die Genau-einmal-Wirkung basiert auf dem bereits vorhandenen autoritativen CampaignState-`CreditResourceOnce`-Vertrag mit deterministischer Credit-ID. Es wird kein zweites Persistenzsystem eingeführt.

## 10. Real bestätigte Option-B-Build-Provenienz

Vom Projektinhaber am 22.08.2026 real ausgeführt und zurückgemeldet:

```text
Source / Git HEAD:
49f43a856c1f8bc32ca64835af856119a295640e

CampaignState source SHA-256:
18189A633DBD78FC7EAFBDAF09601BC3241ADAD115DF09DA3EF28B1D85E3E093
```

AirOps Warehouse Production:

```text
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
Bundle SHA-256: 472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735
```

Ground Production:

```text
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
GroundBaseSchema: OMW-GROUND-PRODUCTION-BASE-2
GroundRuntimeIntegrationSchema: OMW-GROUND-RUNTIME-INTEGRATION-2
GroundAmmoRearmAdapterSchema: OMW-GROUND-AMMO-REARM-ADAPTER-2
Bundle SHA-256: 9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB
```

Fixed Fire Support Acceptance:

```text
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-9
GeneratedUtc: 2026-08-22T13:06:55Z
Bundle SHA-256: D0E628C58567CB46126048AA2903F17C9D15F316C415FFB755FD0192B230EA09
```

Die Builder-Ausgaben und die unmittelbar danach separat ausgeführten `Get-FileHash -Algorithm SHA256`-Prüfungen stimmen für alle drei Bundles exakt überein.

Bestätigte Builder-Gates:

```text
LocalRearmRestartCompensation: true
LocalRearmPhysicalReplay: false
DurableRearmCompletion: true
ValidateAndRepositionGroundUnits: false
PinnedMooseRepositionDefectGuard: true
ApprovedRoadSpawnException: false
SupportReturnToStock: true
HonakerM939Diagnostic: false
MizMutation: false
```

Dieser Nachweis bestätigt Build, Contract-Gates und Hash-Konsistenz. Er validiert noch nicht den neuen `COMPLETED`- oder Restart-Compensation-Pfad in DCS.

## 11. Acceptance-Grenze

Für einen neuen erfolgreichen Runtime-Nachweis muss die kombinierte Acceptance nachweisen:

```text
fire
-> ammo decrease
-> local M1083 materialization
-> exactly one CampaignState GROUND_AMMO_PACKAGE consumed
-> ARTY OnAfterRearmed
-> CampaignState transaction COMPLETED
-> SITE_REARM_COMPLETED
-> ARTY-owned support return
-> WAREHOUSE AddAsset return-to-stock
-> no physical support group remains
-> SITE_PASS
```

Aggregate PASS nur bei vier `SITE_PASS`.

Der Restart-Compensation-Pfad darf nur dann als DCS-validiert markiert werden, wenn zusätzlich eine reale Snapshot-/Restore-Provenienz den Fall `CONSUMED && not COMPLETED -> COMPENSATED exactly once` belegt. Source-/Builder-Verifikation allein reicht dafür nicht.

## 12. Status

```text
MOOSE source review: COMPLETE for documented APIs
Pinned reposition defect: RUNTIME CONFIRMED / excluded
M1083 local SetSpawnZone path: RUNTIME CONFIRMED for prior acceptance provenance
2B11 40 -> 0 -> 40 diagnosis: RUNTIME CONFIRMED for exact diagnostic provenance
Diagnostic rollback: BUILD VERIFIED
Option B source implementation: COMPLETE
Option B production bundles: BUILD/HASH VERIFIED
Option B DCS COMPLETED-path acceptance: PENDING
Option B DCS restart-compensation acceptance: PENDING REAL RESTORE PROVENANCE
```
