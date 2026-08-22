---
document_id: OMW-GROUND-AMMO-REARM-CURRENT-STATUS
status: DRAFT
document_class: WORKING_STATUS
owning_policy: OMW-GOV-001
authoritative_for:
  - current branch-local Ground ammo rearm implementation status and remaining work
  - handoff state for PR 112 before owner-gated Ready or Merge
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Ground Ammo Rearm Integration – aktueller Stand und TODO

Stand: 22.08.2026

## 1. Arbeitszweig und Autorität

```text
Repository: birkenmoped/Operation-Mountain-Watch
Arbeitsbranch: agent/ground-ammo-rearm-integration
Draft PR: #112 Integrate Ground ammo rearm lifecycle
Status: OPEN / DRAFT / NOT MERGED
Projektphase: COMPLETE_FOUNDATION_BUILD_PHASE
```

Projektweit verbindliche normative Wirkung entsteht erst nach dem Governance-konformen Integrationsweg nach `main`.

## 2. Ziel und Architektur

```text
fixed fire-support consumer
-> reale DCS-Munition wird verbraucht
-> MOOSE WAREHOUSE / BRIGADE / PLATOON materialisiert lokalen Ammo-Support
-> CampaignState bucht genau 1 GROUND_AMMO_PACKAGE
-> ARTY:SetRearmingGroup(...)
-> ARTY:Rearm()
-> DCS führt den Rearm aus
-> ARTY OnAfterRearmed
-> CampaignState transaction = COMPLETED
-> MOOSE ARTY support return
-> WAREHOUSE:AddAsset(...)
```

`CampaignState` bleibt einzige strategische Ressourcenautorität. Kein MIST, kein eigener Rearm-FSM, kein FullAmmo-Scanner, kein MOOSE-Patch.

## 3. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

`ARTY OnAfterRearmed` ist der vorhandene MOOSE-FSM-Completion-Hook. `WAREHOUSE:SetSpawnZone(...)` bleibt der lokale Materialisierungspfad. `WAREHOUSE:SetValidateAndRepositionGroundUnits(...)` bleibt wegen des real bestätigten `UTILS.GetCenterPoint`-Defekts ausgeschlossen.

## 4. Geschlossene Evidenz

Acceptance-1:

```text
Source: 213119ca03a6aeae529d4291b4bbe174ac0995c2
Bundle SHA-256: 94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7
Executed MIZ: OMW_Template_v15.miz
MIZ SHA-256: A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4
Runtime: 300 -> 296 -> 302
GROUND_AMMO_PACKAGE: 52 -> 51
Support: M1083
Result: PASS
```

2B11-Diagnose:

```text
Source: 5c5fa0ba7653ef51144ca0223dd7cad0ad36f0a7
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-7
Bundle SHA-256: 1655E4F2F5D4AB69BF4BDAFBD82CE3D8FF0049CD557245336B71C275F21BED3D
Executed mission: OMW_Template_v16.miz
dcs.log SHA-256: B3C218B81D5A3C386213E4721F1F1AF12C53DF840C8BB758FE7147E6BAF5FD10
debrief.log SHA-256: 0014C8FE4A4E3BD7DE3D3AF0BCB3DC30C30E786470F1EDA951EBD582F1A48FAE

2B11 40 -> 0 -> support request -> 0 -> 40 -> PASS
```

Korrigierte Evidenzgrenze:

```text
vollständige Entleerung = nachgewiesene Voraussetzung des getesteten 2B11-Rearm-Pfades
partielle Entleerung = NICHT als funktionierender 2B11-Rearm-Pfad nachgewiesen
```

Owner-Entscheidung:

```text
HONAKER support = TPL_BLUE_GND_SUP_M1083
keine weitere Bestätigung des M1083 erforderlich
M939 = historische Diagnosevariable, keine Produktionsalternative
```

## 5. Aktiver Vier-Consumer-Vertrag

```text
BOSTICK   -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
WRIGHT    -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
FORTRESS  -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
HONAKER   -> TPL_BLUE_GND_SUP_M1083 / 40 rounds / requireAmmoDepleted=true
```

Honaker darf den Rearm-Request erst nach `postFireAmmo == 0` auslösen.

Revision 2-10 wurde real gebaut und gehasht:

```text
Source / Git HEAD: f4e781a92bfc74062c48b46b91474f632e69d585
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-10
GeneratedUtc: 2026-08-22T13:44:16Z
Bundle SHA-256: 1180884FEB764F95CFD89D72CE2D04BE633A9FD73AE0939AE4B476179A5977C5
```

Revision 2-10 ist BUILD/HASH VERIFIED, wurde aber bewusst nicht als eigener zusätzlicher DCS-Einzeltest angesetzt.

## 6. LOCAL REARM Option B

Owner-approved Vertrag:

```text
Rearm accepted / physical service begins
-> GROUND_AMMO_PACKAGE = CONSUMED

ARTY OnAfterRearmed
-> transaction = COMPLETED

Restore mit CONSUMED aber nicht COMPLETED
-> exactly-once strategic compensation
-> transaction = COMPENSATED
-> old transaction remains historical/closed
-> no physical replay
-> later rearm requires a new transaction ID
```

Implementiert:

```text
CampaignState.TransactionStatus.COMPLETED
CampaignState.TransactionStatus.COMPENSATED
Store:CompleteConsumption(...)
Store:MarkConsumptionCompensated(...)
GroundAmmoRearmAdapter.ReconcileRestore(...)
```

Real bestätigte Produktionsbundle-Provenienz:

```text
Source / Git HEAD: 49f43a856c1f8bc32ca64835af856119a295640e
CampaignState source SHA-256: 18189A633DBD78FC7EAFBDAF09601BC3241ADAD115DF09DA3EF28B1D85E3E093

AirOps Warehouse Production Base
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
Bundle SHA-256: 472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

Ground Production Base
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
Bundle SHA-256: 9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB
```

## 7. Keine Tippelschritte – gebündelte finale Acceptance

Revision 2-11 führt die verbleibenden Runtime-Prüfungen in **einem DCS-Lauf** zusammen.

Phase A – reale MOOSE/DCS-Rearm-Legs:

```text
Bostick   M1083 / 4 rounds -> COMPLETED -> return-to-stock -> SITE_PASS
Wright    M1083 / 4 rounds -> COMPLETED -> return-to-stock -> SITE_PASS
Fortress  M1083 / 4 rounds -> COMPLETED -> return-to-stock -> SITE_PASS
Honaker   M1083 / 40 -> 0 -> COMPLETED -> return-to-stock -> SITE_PASS
```

Phase B – im selben DCS-Lauf auf isolierten `CampaignState.Restore(...)`-Kopien:

```text
CONSUMED -> exactly one restart credit -> COMPENSATED
second restore -> no duplicate credit
new transaction ID after compensation -> COMPLETED
COMPLETED restore -> no compensation
RESERVED restore -> CANCELLED
LOADING restore -> CANCELLED
authoritative runtime store remains unchanged
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

## 8. Persistenzgrenze

Repository-Prüfung bestätigt derzeit:

```text
CampaignState besitzt ExportSnapshot() und Restore().
GroundRuntimeIntegration erwartet einen vom Caller erzeugten oder wiederhergestellten Store.
AirOpsWarehouseProduction kann einen extern bereitgestellten campaignContext übernehmen.
Im aktuellen Branch existiert kein produktiver externer Dateisystem-/Server-Persistence-Host,
der CampaignState selbst auf Platte schreibt und beim Prozessneustart wieder lädt.
```

Revision 2-11 führt daher keine `io`-/`lfs`-Dateipersistenz, keine `MissionScripting.lua`-Änderung und keinen zweiten Persistenzpfad ein. Der gebündelte DCS-Lauf validiert den realen `ExportSnapshot -> Restore -> ReconcileRestore`-Settlementvertrag innerhalb der DCS-Laufzeit. Ein externer Prozess-/Server-Restart darf daraus nicht behauptet werden.

## 9. Revision 2-11 – Source/Builder-Stand

```text
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11
Acceptance harness: SOURCE COMPLETE / REMOTE
Builder gates: COMPLETE / REMOTE
Local build/hash: PENDING REAL OWNER OUTPUT
DCS runtime: PENDING
```

## 10. Dokumentationsstatus

```text
ACCEPTANCE-2.md: Revision 2-11 reconciled
FIXED-FIRE-SUPPORT-REARM.md: Revision 2-11 reconciled
CURRENT-STATUS-TODO.md: Revision 2-11 reconciled
README.md: classified as HISTORICAL_TEST_FIXTURE with metadata; previous full development record remains in Git history at blob 2f1622bdb1a6cd1beeb005af74db07c77af0beea
```

Es wird kein Dokumentationsvalidator-PASS behauptet, bevor ein aktueller Workflow-/Validator-Nachweis vorliegt.

## 11. Aktuelle TODO-Liste

```text
[x] Acceptance-1 Provenienz
[x] generalisierter Vier-Consumer-Pfad
[x] CampaignState Debit
[x] lokaler WAREHOUSE Support-Spawn
[x] SetSpawnZone
[x] defekter GetCenterPoint-Pfad ausgeschlossen
[x] ARTY-owned Support Return
[x] WAREHOUSE AddAsset Return-to-stock
[x] 2B11 40 -> 0 -> 40 Diagnose
[x] M1083 für Honaker owner-confirmed
[x] Option B owner-approved
[x] Option B source-seitig implementiert
[x] Option-B Produktionsbundles real gebaut/gehasht
[x] Revision 2-10 real gebaut/gehasht
[x] verbleibende Runtime-Prüfungen zu Revision 2-11 gebündelt
[x] externer Persistence-Host-Iststand geprüft
[x] branch-eigene README-Metadaten-Schuld bereinigt

[ ] Revision 2-11 lokal einmal bauen und hash-verifizieren
[ ] einen gebündelten DCS-Acceptance-Lauf durchführen
[ ] Logs gegen alle Physical-/Restore-Marker auswerten
[ ] aktuellen Dokumentationsvalidator-/CI-Stand prüfen
[ ] finalen Diff / Contract / Builder prüfen
[ ] Owner-Entscheidung PR #112 Ready / Merge
```

## 12. Reihenfolge

```text
Ground Ammo Rearm / Fixed Fire Support
        |
        +-- 2B11 Evidenzkorrektur             COMPLETE
        +-- M1083 Owner-Entscheidung          COMPLETE
        +-- LOCAL REARM Option B              SOURCE IMPLEMENTED / BUILD VERIFIED
        +-- Revision 2-10                     BUILD/HASH VERIFIED
        +-- Revision 2-11 bundled acceptance SOURCE/BUILDER COMPLETE
        +-- einmaliger lokaler Build/Hash     PENDING
        +-- EIN gebündelter DCS-Lauf          PENDING
        +-- finaler Review                    PENDING
        `-- Owner-Entscheidung PR #112 Ready / Merge
```