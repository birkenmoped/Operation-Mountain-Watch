---
document_id: OMW-MOOSE-STORAGE-TECHNICAL-AVAILABILITY
status: BINDING
document_class: MOOSE_TECHNICAL_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - technical non-strategic AirOps STORAGE availability quantities
  - node assignment of external tanks and AH-64 IAFS
  - CampaignState exclusion for technical non-strategic stores
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - quantity-open wording in section 10.3 of OMW-MOOSE-STORAGE-WAREHOUSE-RESOURCE-FOUNDATION
superseded_by:
source_branch: agent/air-ops-initial-stock-runtime-data
source_commit: 9ba4e149846805669e9d1032053c7145632f2a0b
validated_in_dcs: false
---

# STORAGE Technical Availability

## 1. Owner-Entscheidung

Für die drei bereits als `TECHNICAL_NON_STRATEGIC` klassifizierten AirOps-Stores wird die operative Anfangsverfügbarkeit auf **1000 Stück je relevantem Node und Store** festgelegt.

Diese Menge ist eine technische Missionskonfiguration. Sie ist kein strategischer Bestand und eröffnet die abgeschlossene Warehouse-/Resource-Stockplanung nicht erneut.

## 2. Runtime-Baseline

Maschinenlesbare Quelle:

```text
scripts/logistics/OMW_AirOpsTechnicalAvailability.lua
```

Verbindliche Zuordnung:

```text
BAGRAM
  F16_370GAL_TANK        = 1000
  F15E_EXTERNAL_TANK     = 1000

JALALABAD
  AH64_IAFS_COMBOPAK_100 = 1000

KANDAHAR_HELI
  AH64_IAFS_COMBOPAK_100 = 1000

SALERNO
  AH64_IAFS_COMBOPAK_100 = 1000

SHINDAND_HELI
  AH64_IAFS_COMBOPAK_100 = 1000

TARINKOT
  AH64_IAFS_COMBOPAK_100 = 1000
```

Die Node-Zuordnung folgt dem aktuellen genehmigten AirOps-Payload-/Node-Scope: F-16C und F-15E liegen im aktuellen Foundation-Scope in Bagram; AH-64D-IAFS wird an den dokumentierten AH-64D-Helikopterknoten bereitgestellt.

## 3. Strategische Grenze

Für diese Einträge gilt weiterhin:

```text
CampaignState quantity = none
strategic consumption = none
strategic replenishment = none
artificial return credit = none
```

Die Werte werden ausschließlich über `OMW_AirOpsTechnicalAvailabilityInitializer.lua` einmalig in die operative MOOSE/DCS-STORAGE-Repräsentation geschrieben. Es gibt keinen periodischen Reset auf 1000 und keine automatische Wiederauffüllung während einer Mission.

## 4. Größenordnung

Die bereits dokumentierte operative Materialisierung zeigte für Two-Ships:

```text
AH-64D: 2 x IAFS
F-16C:  4 x 370-gal external tank
F-15E:  4 x external tank
```

Damit entsprechen 1000 Stück rechnerisch mindestens:

```text
AH-64D: 500 Two-Ship-Materialisierungen je konfiguriertem Node
F-16C:  250 Two-Ship-Materialisierungen in Bagram
F-15E:  250 Two-Ship-Materialisierungen in Bagram
```

Das ist eine Kapazitätsabschätzung aus den bereits dokumentierten Payload-Debits, keine strategische Verbrauchsplanung.

## 5. Acceptance-Grenze

Die Owner-Entscheidung über 1000 Stück ist `BINDING`. Die tatsächliche one-shot STORAGE-Initialisierung und der Readback dieses neuen produktiven Datenpfads sind bis zu einem dokumentierten DCS-Lauf **nicht** `VALIDATED`.
