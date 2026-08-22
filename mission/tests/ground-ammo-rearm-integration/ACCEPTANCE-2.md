---
document_id: OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - combined DCS acceptance of fixed fire-support rearm for Bostick, Wright, Fortress and Honaker
  - required Mission Editor target- and local resupply-zone contract for that combined run
  - Option-B durable completion and restore-settlement runtime acceptance boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Ground Fire Support Acceptance 2 – gebündelter Abschlusslauf

## 1. Ziel

Die verbleibenden Runtime-Prüfungen von PR #112 werden nicht als Einzeltests ausgeführt. Revision 2-11 bündelt in **einem DCS-Lauf**:

```text
Phase A: reale MOOSE/DCS-Rearm-Legs
Bostick   L118 / M1083 / 4 rounds
Wright    L118 / M1083 / 4 rounds
Fortress  L118 / M1083 / 4 rounds
Honaker   2B11 / M1083 / 40 -> 0

Phase B: CampaignState Restore-Settlement auf isolierten Snapshot-Kopien
CONSUMED   -> COMPENSATED exactly once
COMPENSATED -> repeated restore without duplicate credit
COMPLETED  -> preserved without compensation
RESERVED   -> CANCELLED
LOADING    -> CANCELLED
new transaction after compensation -> new ID -> COMPLETED
```

`CampaignState` bleibt einzige strategische Ressourcenautorität.

## 2. MOOSE-Provenienz und zulässiger Pfad

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendete öffentliche MOOSE-Verträge:

```text
WAREHOUSE:SetSpawnZone(...)
WAREHOUSE:AddAsset(...)
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:SetRearmingDistance(...)
ARTY:Rearm()
ARTY OnAfterRearmed
SCHEDULER:New(...)
```

Bewusst ausgeschlossen:

```text
WAREHOUSE:SetValidateAndRepositionGroundUnits(...)
MIST
MOOSE patch / UTILS.GetCenterPoint fallback
private/native DCS spawn/rearm parallel path
```

Der gepinnte `SetValidateAndRepositionGroundUnits`-Pfad ist wegen des real reproduzierten fehlenden `UTILS.GetCenterPoint` ausgeschlossen. Lokale Materialisierung erfolgt über kontrollierte Mission-Editor-RESUPPLY-Zonen und `WAREHOUSE:SetSpawnZone(...)`.

## 3. 2B11-Evidenz und Honaker-Vertrag

Der real bestätigte Diagnosepfad lautet:

```text
2B11 40 -> 0
-> support request
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

Belegbare Grenze:

```text
vollständige Entleerung = nachgewiesene Voraussetzung des getesteten 2B11-Rearm-Pfades
partielle Entleerung = NICHT als funktionierender 2B11-Rearm-Pfad nachgewiesen
```

Owner-Entscheidung vom 22.08.2026:

```text
Honaker support template: TPL_BLUE_GND_SUP_M1083
weitere Bestätigung des M1083 als Supportfahrzeug: NICHT ERFORDERLICH
M939: historische Diagnosevariable, keine Produktionsalternative
```

Aktiver physischer Vertrag:

```text
BOSTICK   -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
WRIGHT    -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
FORTRESS  -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
HONAKER   -> TPL_BLUE_GND_SUP_M1083 / 40 rounds / requireAmmoDepleted=true
```

Honaker löst den Support-/Rearm-Request erst bei `postFireAmmo == 0` aus.

## 4. Option B – Completion-/Restore-Vertrag

Owner-approved:

```text
Rearm accepted / physical service begins
-> GROUND_AMMO_PACKAGE = CONSUMED

ARTY OnAfterRearmed
-> CampaignState transaction = COMPLETED

Restore mit CONSUMED aber nicht COMPLETED
-> deterministic CreditResourceOnce
-> transaction = COMPENSATED
-> no physical replay
-> old transaction remains closed
-> later rearm requires a new transaction ID
```

Implementierte Domain-/Adapter-Verträge:

```text
CampaignState.TransactionStatus.COMPLETED
CampaignState.TransactionStatus.COMPENSATED
Store:CompleteConsumption(...)
Store:MarkConsumptionCompensated(...)
Store:ExportSnapshot()
CampaignState.Restore(...)
GroundAmmoRearmAdapter.ReconcileRestore(...)
```

## 5. Produktionsbundle-Provenienz

Vom Projektinhaber real gebaut und gehasht:

```text
Source / Git HEAD: 49f43a856c1f8bc32ca64835af856119a295640e
CampaignState source SHA-256: 18189A633DBD78FC7EAFBDAF09601BC3241ADAD115DF09DA3EF28B1D85E3E093

AirOps Warehouse Production Base
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
SHA-256: 472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

Ground Production Base
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
SHA-256: 9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB
```

Diese Produktionsbundles bleiben für Revision 2-11 unverändert.

Korrigierte Revision 2-10 wurde ebenfalls real gebaut/gehasht, aber bewusst nicht als zusätzlicher Einzel-DCS-Test angesetzt:

```text
Source / Git HEAD: f4e781a92bfc74062c48b46b91474f632e69d585
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-10
GeneratedUtc: 2026-08-22T13:44:16Z
Bundle SHA-256: 1180884FEB764F95CFD89D72CE2D04BE633A9FD73AE0939AE4B476179A5977C5
```

## 6. Revision 2-11 – gebündelte Runtime-Acceptance

### Phase A – reale physische Rearms

Pro Standort müssen nachgewiesen werden:

```text
SITE_START
SITE_FIRE_COMPLETE
SITE_REARM_REQUEST
SITE_SUPPORT_MATERIALIZED
SITE_CONSUMPTION_COMMITTED
SITE_REARM_COMPLETED
SITE_REARMED
SITE_SUPPORT_RETURNED
SITE_PASS
```

Zusätzlich Honaker:

```text
initialAmmo = 40
postFireAmmo = 0
HONAKER_AMMO_DEPLETED
HONAKER_REARM_REQUEST_AFTER_EMPTY
supportTemplate = TPL_BLUE_GND_SUP_M1083
```

### Phase B – Restore-Settlement im selben DCS-Lauf

Nach vier `SITE_PASS` exportiert der Harness den aktuellen autoritativen Snapshot. Sämtliche Restore-Fixtures laufen auf `CampaignState.Restore(...)`-Kopien; der autoritative Runtime-Store darf nicht verändert werden.

Geprüfte Fälle:

```text
1. CONSUMED interruption
   -> Restore
   -> ReconcileRestore
   -> exactly one restart credit
   -> COMPENSATED

2. repeated restore
   -> COMPENSATED bleibt geschlossen
   -> keine zweite Gutschrift

3. new transaction after compensation
   -> neue transactionId
   -> COMPLETED
   -> weiterer Restore
   -> keine Compensation für COMPLETED

4. RESERVED on restore
   -> CANCELLED
   -> Reservation freigegeben

5. LOADING on restore
   -> CANCELLED
   -> Reservation freigegeben
```

Pflichtmarker:

```text
PHYSICAL_REARM_PHASE_PASS
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

## 7. Persistenzgrenze

Die Repository-Prüfung ergibt:

```text
CampaignState besitzt ExportSnapshot() und Restore().
GroundRuntimeIntegration erwartet einen vom Caller erzeugten oder wiederhergestellten Store.
AirOpsWarehouseProduction kann einen extern bereitgestellten campaignContext übernehmen.
Im aktuellen Branch existiert kein produktiver externer Dateisystem-/Server-Persistence-Host,
der den CampaignState-Snapshot selbst auf Platte schreibt und nach Prozessneustart wieder lädt.
```

Revision 2-11 führt daher ausdrücklich **keine** neue Dateipersistenz ein:

```text
kein io/lfs
keine MissionScripting.lua-Änderung
kein zweiter Persistence-Host
keine zweite Ressourcenautorität
```

Der DCS-Lauf kann den realen `ExportSnapshot -> Restore -> ReconcileRestore`-Settlementvertrag in der DCS-Laufzeit validieren. Er beweist **nicht** einen externen Prozess-/Server-Restart über einen noch nicht vorhandenen Persistence-Host. Diese Grenze muss in der Ergebnisdokumentation erhalten bleiben.

## 8. Mission-Editor-Vertrag

RESUPPLY-Zonen:

```text
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Zielzonen:

```text
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET
```

## 9. Revision-2-11 Buildstatus

```text
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11
Source/Builder: REMOTE COMPLETE
Local build/hash: PENDING REAL OWNER OUTPUT
DCS runtime: PENDING
```

Kein Bundle-Hash wird vor der realen lokalen Builder-/`Get-FileHash`-Ausgabe angenommen.

## 10. Status

```text
Revision-2-7 full-depletion diagnostic: DCS PASS for exact provenance
Revision-2-8/2-9 Honaker four-round rollback: HISTORICAL / invalid Honaker acceptance contract
Revision-2-10 corrected contract: BUILD/HASH VERIFIED; no isolated DCS rerun
Revision-2-11 bundled final acceptance: SOURCE/BUILDER COMPLETE, local build/hash PENDING
M1083 as Honaker support: OWNER CONFIRMED / no further confirmation required
Option-B production implementation: SOURCE COMPLETE / production bundles BUILD/HASH VERIFIED
External filesystem/server persistence host: NOT PRESENT IN CURRENT BRANCH / not claimed by this acceptance
VALIDATED for Revision-2-11 runtime claims: false
```
