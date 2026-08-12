---
document_id: OMW-TEST-WAREHOUSE-RESOURCE-FINAL-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - final Warehouse/resource integration acceptance gate
  - CampaignState recovery settlement to read-only STORAGE reconciliation boundary
  - restart-safe recovery credit idempotency
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/warehouse-resource-final-acceptance
source_commit: 1bd94f8a382905d40377d01586d263e6325f32e4
validated_in_dcs: true
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

## 6. DCS-Acceptance 2026-08-13

Runtime:

```text
DCS: 2.9.28.26385 MT
Source / Builder commit: 1bd94f8a382905d40377d01586d263e6325f32e4
BuilderVersion: WAREHOUSE-RESOURCE-FINAL-ACCEPTANCE-1
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Executed MIZ SHA-256: c5d948c9cf734ac56586a7ea0081fb0412827f297532fa89270ad8ed59ae533b
Internal mission SHA-256: 4f2cacfeb4f66d443a3d4409f182f66ef7d2737102c2fef2721c372f5ceb33d3
Embedded/local gate SHA-256: 535b988e2bb2f5de82a5c30dd1cd1d29195188a6c22ceb397e050a14d525b800
dcs.log SHA-256: 5af67666d119f0bedd6bb04860c38583da5345af5a3ad914ee2a04d6e2957184
debrief.log SHA-256: e841d9a27dc8f1eb961ec35a7986dedea51401524986d20e2d423bdd97dd14d6
```

Observed final markers:

```text
BASELINE_PASS jp8Kg=100000.000 avgasKg=100000.000
RECOVERY_BEGIN_PASS recoveryCompleteAt=2800 repairCompleteAt=24400
SETTLEMENT_PASS resourceId=FUEL_JP8 creditKg=425 creditsCreated=1
RECONCILIATION_SIGNAL_PASS resourceId=FUEL_JP8 delta=-425.000 reverseOverwrite=false
RESTART_RECONCILIATION_PASS duplicateCredit=false recoveryChanged=false
REPAIR_LOCK_PASS repairSeconds=21600 status=AVAILABLE
RESULT status=PASS campaignStateAuthority=true storageReadOnly=true reverseOverwrite=false restartIdempotent=true filesystemPersistence=false inheritedForcedLandingEvidence=true
```

Die produktiven AIROPS-Foundations liefen im selben Missionslauf weiter; insbesondere Shindand erreichte seinen dokumentierten `RESULT status=RUNNING` vor Ausführung des Gates. Damit ist auch bestätigt, dass der read-only Final-Gate mit dem produktionsnahen AirOps-Foundation-Stack koexistiert.

Die im Gesamtdokument vorhandenen älteren Forced-Landing-FAIL-Marker stammen aus vorherigen Läufen derselben DCS-Logdatei und sind historische Evidenz. Sie gehören nicht zum finalen Gate-Lauf um 22:58 UTC und ändern dessen PASS nicht. Der bekannte `bhHook.lua:168`-Shutdownfehler stammt aus dem externen Saved-Games-Hook und ist nicht dem OMW-Gate zuzuordnen.

Acceptance-Ergebnis:

```text
ACCEPTED_TECHNICAL_BASELINE
```

für exakt den oben dokumentierten Branch-, Commit-, MIZ-, Bundle-, MOOSE- und DCS-Stand.

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
