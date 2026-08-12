---
document_id: OMW-TEST-WAREHOUSE-RESOURCE-FINAL-ACCEPTANCE
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - final Warehouse/resource integration acceptance gate
  - CampaignState recovery settlement to read-only STORAGE reconciliation boundary
  - restart-safe recovery credit idempotency
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/warehouse-resource-final-acceptance
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/storage-campaignstate-finalization
base_commit: 489f79a621dda8a48862aa0874f8234dd2c2834e
merged_to_main: false
---

# Finaler Warehouse-/Resource-Integration-Gate

## 1. Zweck

Dieser Gate bündelt ausschließlich die nach den bereits akzeptierten Warehouse-/STORAGE- und Forced-Landing-Grundlagen noch offene Integrationsgrenze:

```text
accepted forced-landing classification
-> RecoverySettlementCoordinator
-> CampaignState recovery state
-> exactly-once strategic remainder credit
-> snapshot / restore
-> duplicate credit remains blocked after restore
-> read-only STORAGE reconciliation signal
-> repair lock -> AVAILABLE
```

Bereits akzeptierte physische DCS-Grundlagen werden nicht erneut geflogen oder simuliert.

## 2. Geerbte technische Evidenz

Der Gate baut auf den dokumentierten Vorgänger-Acceptances auf:

```text
STORAGE read/reconciliation boundary
AI materialization and normal return semantics
client rearm/refuel native STORAGE behavior
physical total loss without recredit
forced-landing Land/EngineShutdown observation
5-km RECOVERABLE_FORCED_LANDING / OFF_FIELD_UNRECOVERABLE boundary
1800 s recovery delay
21600 s repair lock
CampaignState recovery settlement and snapshot/restore domain API
```

Die im Gate verwendete Entfernung `4782.4415407502 m` ist ein Replay der bereits akzeptierten Forced-Landing-Evidenz und keine neue physische DCS-Messung.

## 3. Neue Integrationskomponente

```text
scripts/logistics/OMW_RecoverySettlementCoordinator.lua
```

Der Coordinator ist bewusst klein und CampaignState-zentriert. Er:

```text
requires RECOVERABLE_FORCED_LANDING
uses the approved recovery policy timing
opens the CampaignState recovery record
completes recovery only after the policy timestamp
credits supplied remainder resources through CreditResourceOnce()
completes the repair lock through CampaignState
```

Er besitzt keine MOOSE-, STORAGE-, AIRWING-, WAREHOUSE-, Scheduler-, DCS- oder Filesystem-Abhängigkeit.

## 4. MOOSE-First-Grenze

Die operative Warehouse-Beobachtung verwendet weiterhin ausschließlich den bereits akzeptierten öffentlichen MOOSE-Pfad aus `OMW_StorageResourceObserver`:

```text
STORAGE:FindByName()
AIRBASE:FindByName() / AIRBASE:GetStorage() fallback
STORAGE:GetLiquidAmount()
STORAGE:GetItemAmount()
```

Der neue Coordinator implementiert keine Framework-Funktion parallel. MOOSE besitzt keine OMW-spezifische CampaignState-Recovery-Gutschrift oder strategische Restart-Idempotenz; diese Logik bleibt daher in der Campaign-Domain.

## 5. Testablauf

Nach 10 Sekunden:

```text
1. Shindand Heliport STORAGE read-only lesen.
2. CampaignState mit den beobachteten vollständigen Fuel-Mappings initialisieren.
3. Baseline CampaignState <-> STORAGE = MATCH prüfen.
4. Bereits akzeptiertes RECOVERABLE_FORCED_LANDING als Replay-Fixture an den Coordinator geben.
5. Recovery bei t=1000 beginnen -> completeAt=2800 / repairAt=24400.
6. Bei t=2800 deterministische 425 kg JP8 als Integrations-Fixture genau einmal strategisch gutschreiben.
7. Erwarteten, erklärten STORAGE-Drift von -425 kg erkennen; kein Reverse-Overwrite.
8. CampaignState Snapshot exportieren und wiederherstellen.
9. Dieselbe Recovery-Gutschrift erneut einspielen -> keine zweite Gutschrift.
10. Repair-Lock bei t=24400 abschließen -> AVAILABLE.
```

Die 425 kg sind ausschließlich eine deterministische Testmenge und keine Behauptung über den realen Resttreibstoff des akzeptierten AH-64D-Laufs.

## 6. Erwartete Marker

```text
BASELINE_PASS
RECOVERY_BEGIN_PASS
SETTLEMENT_PASS
RECONCILIATION_SIGNAL_PASS
RESTART_RECONCILIATION_PASS
REPAIR_LOCK_PASS
RESULT status=PASS
```

Final erwartet:

```text
campaignStateAuthority=true
storageReadOnly=true
reverseOverwrite=false
restartIdempotent=true
filesystemPersistence=false
inheritedForcedLandingEvidence=true
```

## 7. Persistenzgrenze

Dieser Gate validiert die **strategische Restart-Reconciliation-Semantik** durch `ExportSnapshot()` -> `CampaignState.Restore()` einschließlich persistierter Credit-IDs und Recovery-Zustände.

Er schreibt bewusst keine Datei. Im aktuellen verbindlichen Projektstand ist kein konkreter CampaignState-Dateipfad beziehungsweise Host-Persistenzadapter freigegeben, und OMW ändert `MissionScripting.lua` nicht automatisch. Ein Filesystem-Writer würde daher eine zusätzliche Persistenz-/Deployment-Entscheidung erfordern und wird nicht stillschweigend in die Warehouse-Integration eingebaut.

Damit trennt der Gate:

```text
Warehouse/resource correctness and restart-safe state semantics
!= deployment-specific durable file transport
```

## 8. Build

```text
Builder:
tools/build-warehouse-resource-final-acceptance.ps1

Bundle:
mission/tests/warehouse-resource-final-acceptance/dist/OMW_Warehouse_Resource_Final_Acceptance.lua

BuilderVersion:
WAREHOUSE-RESOURCE-FINAL-ACCEPTANCE-1
```

Für den DCS-Lauf ist nur die gepinnte `Moose.lua` vor dem Bundle zu laden. Es ist keine Spieleraktion erforderlich.
