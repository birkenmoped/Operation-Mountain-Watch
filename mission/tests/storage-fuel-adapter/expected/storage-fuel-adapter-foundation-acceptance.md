---
document_id: OMW-TEST-STORAGE-FUEL-ADAPTER-FOUNDATION-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - planned acceptance criteria for STORAGE fuel adapter foundation
  - required runtime markers for separate JP-8 and AVGAS mirroring
  - explicit non-acceptance boundaries of the foundation test
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-fuel-adapter-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# STORAGE Fuel Adapter Foundation – Acceptance Plan

## 1. Gate

```text
Gate: STORAGE-FUEL-ADAPTER-FOUNDATION-1
Status: PLANNED / NOT_RUN
```

## 2. Statische Voraussetzungen

Vor einem DCS-Lauf müssen dokumentiert und identisch sein:

```text
Branch
Source-Commit
Builder-Version
Bundle-SHA-256
MIZ-SHA-256
interner mission-SHA-256
eingebetteter Bundle-SHA-256
MOOSE-Commit
Moose.lua-SHA-256
Kandahar Airbase-/Warehouse-Auflösung
```

Der Builder muss zusätzlich bestätigen:

```text
FuelResources: FUEL_JP8,FUEL_AVGAS
CanonicalUnit: kg
AutomaticAircraftDebit: ABSENT
CampaignStateMutation: ABSENT
Persistence: ABSENT
Transport: ABSENT
```

## 3. Positive Runtime-Kriterien

Der Rohlog muss alle folgenden Marker enthalten:

```text
BEGIN testId=STORAGE-FUEL-ADAPTER-FOUNDATION-1
PLAN_PASS changes=2
WRITE_READBACK_PASS
IDEMPOTENCY_PASS
RESTORE_PASS
RESULT testId=STORAGE-FUEL-ADAPTER-FOUNDATION-1 status=PASS
```

Zusätzlich muss der Endmarker bestätigen:

```text
jp8Separated=true
avgasSeparated=true
canonicalUnit=kg
automaticAircraftDebit=false
persistence=false
campaignStateMutation=false
```

## 4. Fail-Bedingungen

Der Test ist `FAIL` oder `INVALID`, wenn mindestens einer dieser Punkte eintritt:

- `STORAGE` oder der Kandahar-Warehouse-Wrapper ist nicht auflösbar;
- JETFUEL oder GASOLINE ist im verwendeten MOOSE-Stand nicht verfügbar;
- das Warehouse erscheint für Liquids unbegrenzt;
- ein Sollwert kann über `SetLiquid()` nicht gesetzt und exakt zurückgelesen werden;
- JP-8- und AVGAS-Werte können nicht getrennt geändert werden;
- die zweite Anwendung desselben Snapshots erzeugt erneut Änderungen;
- der ursprüngliche Bestand wird am Testende nicht wiederhergestellt;
- Lua-/Scheduler-/MOOSE-Fehler treten auf;
- Mission, Bundle oder Moose.lua stimmen nicht mit der dokumentierten Hashkette überein.

## 5. Nicht durch PASS belegt

Ein PASS belegt ausdrücklich nicht:

```text
CampaignState persistence
CampaignState transaction lifecycle
production stock quantities
automatic aircraft consumption
player refuel accounting
AI refuel accounting
AAR accounting
weapon inventory synchronization
multiplayer reconciliation
mission restart reconciliation
OPSTRANSPORT or CTLD delivery
```

## 6. Acceptance-Status

Vor einem realen DCS-Test bleibt dieses Dokument:

```text
status: PLANNED
validated_in_dcs: false
```

Eine spätere Hochstufung benötigt die vollständige Provenienz nach `docs/22-test-mission-build-transfer-and-validation-workflow.md` und `mission/tests/GOVERNANCE.md`.
