---
document_id: OMW-TEST-CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - planned acceptance criteria for CampaignState to STORAGE fuel sync
  - one-way synchronization runtime markers
  - explicit non-acceptance boundaries of the sync foundation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/campaignstate-storage-sync-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/storage-fuel-adapter-foundation
base_commit: e79ed1ae7bbe62160b3a4dce83e1dd25028ce0fb
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch may still be revised
---

# CampaignState → STORAGE Sync Foundation – Acceptance Plan

## 1. Gate

```text
Gate: CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1
Status: PLANNED / NOT_RUN
```

## 2. Statische Voraussetzungen

Vor dem DCS-Lauf müssen dokumentiert sein:

```text
Branch
Source commit
Builder version
Bundle SHA-256
MIZ SHA-256
internal mission SHA-256
embedded bundle SHA-256
MOOSE commit
Moose.lua SHA-256
Kandahar limited-liquids configuration
parent STORAGE acceptance provenance
```

Der Builder muss bestätigen:

```text
Direction: CampaignState-to-STORAGE
FuelResources: FUEL_JP8,FUEL_AVGAS
CanonicalUnit: kg
CampaignStateRuntimeMutation: ABSENT
ReverseOverwrite: ABSENT
Persistence: ABSENT
Transport: ABSENT
AutomaticAircraftDebit: ABSENT
```

## 3. Positive Runtime-Kriterien

Der Rohlog muss enthalten:

```text
BEGIN testId=CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1
CAMPAIGNSTATE_SNAPSHOT_PASS
SYNC_PLAN_PASS changes=2
SYNC_WRITE_READBACK_PASS
SYNC_IDEMPOTENCY_PASS
NO_REVERSE_MUTATION_PASS
RESTORE_PASS
RESULT testId=CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1 status=PASS
```

Zusätzlich muss der Endmarker bestätigen:

```text
direction=CampaignState-to-STORAGE
campaignStateMutation=false
reverseOverwrite=false
persistence=false
automaticAircraftDebit=false
```

## 4. Fail-/Invalid-Bedingungen

Der Lauf ist `FAIL` oder `INVALID`, wenn:

- der CampaignState-Store keinen gültigen Fuel-Snapshot für `HUB_KANDAHAR` liefert;
- der Snapshot nicht `FUEL_JP8` und `FUEL_AVGAS` getrennt in kg enthält;
- `PlanNode()` nicht beide erwarteten Änderungen erkennt;
- `ApplyNode()` den Sollwert nicht exakt über den bereits akzeptierten STORAGE-Adapter spiegeln kann;
- die zweite identische Anwendung erneut Änderungen erzeugt;
- CampaignState durch DCS-/STORAGE-Telemetrie mutiert wird;
- die ursprünglichen DCS-Warehouse-Werte nicht wiederhergestellt werden;
- Lua-/MOOSE-Fehler auftreten;
- Mission, Bundle oder MOOSE-Artefakt nicht zur dokumentierten Hashkette passen.

## 5. Nicht durch PASS belegt

Ein PASS belegt ausdrücklich nicht:

```text
CampaignState runtime transaction semantics
CampaignState persistence
resource reservations
resource delivery accounting
automatic aircraft consumption
player or AI refuel accounting
AAR accounting
weapon/item synchronization
multiplayer reconciliation
mission restart reconciliation
continuous scheduler-based synchronization
OPSTRANSPORT or CTLD delivery
reverse reconciliation into CampaignState
```

## 6. Acceptance-Status

Bis zum realen DCS-Test bleibt dieses Dokument:

```text
status: PLANNED
validated_in_dcs: false
```
