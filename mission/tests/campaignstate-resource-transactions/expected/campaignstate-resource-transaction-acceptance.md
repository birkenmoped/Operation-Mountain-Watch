---
document_id: OMW-TEST-CAMPAIGNSTATE-RESOURCE-TRANSACTION-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_REPORT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS acceptance provenance for CAMPAIGNSTATE-RESOURCE-TRANSACTION-1
  - strategic CampaignState transaction invariants in the documented scope
not_authoritative_for:
  - MOOSE OPSTRANSPORT runtime acceptance
  - CTLD runtime acceptance
  - DCS STORAGE mutation
  - persistence, restart reconciliation or multiplayer synchronization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/campaignstate-resource-transaction-contract
source_commit: 04ea3a0b50dfd51483316bc989b14e6d5c4be731
validated_in_dcs: true
---

# CampaignState Resource Transaction – Acceptance

## 1. Testidentität

```text
Test ID: CAMPAIGNSTATE-RESOURCE-TRANSACTION-1
Branch: agent/campaignstate-resource-transaction-contract
Source/Builder commit: 04ea3a0b50dfd51483316bc989b14e6d5c4be731
BuilderVersion: CAMPAIGNSTATE-RESOURCE-TRANSACTION-1
Base branch: agent/campaignstate-storage-multinode-sync
Base commit: 552377a6e2743edf2b884027963007227db84324
DCS: 2.9.28.26385 MT
```

## 2. Artefakt-Provenienz

```text
Executed MIZ: OMW_Template_v8_AirOps_rdy(5).miz
Executed MIZ SHA-256: a1058e7528953ab13ecab385fb1722a7fac6ced6385271a85a9408f4378518cf
Embedded bundle path: l10n/DEFAULT/OMW_CampaignState_Resource_Transaction_Test.lua
Embedded bundle SHA-256: c054c24df9ddb8a9cc7671c2086e3bd414dbe9f0fba7bee3be998b534dceb4bf
Local build bundle SHA-256: c054c24df9ddb8a9cc7671c2086e3bd414dbe9f0fba7bee3be998b534dceb4bf
DCS log SHA-256: d73f5d665c5ec5488fd6f61c336a4e33f1e5fdc09362c57ed27af3c4d12bc862
Debrief SHA-256: f0303b498e37c87d59ac47f61b000025384d53c45b83a9b1ea9ee4478a3e36a8
```

Der eingebettete Bundle-Hash stimmt exakt mit dem lokal erzeugten und unabhängig geprüften Build-Artefakt überein.

## 3. MOOSE-First-Grenze

Der getestete Harness enthält absichtlich keine operative MOOSE-Transportausführung. Vor der Domain-Implementierung wurden im gepinnten MOOSE-Stand insbesondere `OPSTRANSPORT`, `OPSTRANSPORT:AddCargoStorage(...)`, STORAGE-Item-/Liquid-Pfade und CTLD-Stock-/Cargo-Pfade geprüft.

MOOSE bleibt für die spätere physische Transportausführung primär. Dieser Test bestätigt ausschließlich OMW-spezifische CampaignState-Domänenlogik und führt keine parallele Carrier-, Routing-, Loading-, Unloading- oder Transport-FSM-Implementierung ein.

Kein MOOSE-Methodenstatus wird durch diesen Domain-Test auf `VALIDATED` angehoben.

## 4. Bestätigte Invarianten

Der Runtime-Lauf bestätigte:

```text
LEGACY_FUEL_SNAPSHOT_PASS
TRANSFER_DELIVERY_IDEMPOTENCY_PASS
CONSUMPTION_IDEMPOTENCY_PASS
CANCELLATION_RELEASE_PASS
LOSS_NO_DESTINATION_CREDIT_PASS
RESERVATION_AND_IDENTITY_GUARDS_PASS
```

Zusätzlich wurden die vorgesehenen Guard-Fälle erfolgreich zurückgewiesen:

```text
over-reservation -> expected failure
same transactionId with conflicting specification -> expected failure
```

Bestätigte Semantik:

```text
reservation reduces available quantity without immediate stock mutation
IN_TRANSIT performs origin debit exactly once
DELIVERED credits destination exactly once
repeated DELIVERED remains idempotent
CONSUMED debits exactly once
CANCELLED before departure releases reservation without stock mutation
LOST after departure receives no destination credit
duplicate transaction ID with identical specification is idempotent
duplicate transaction ID with conflicting specification is rejected
```

## 5. Finaler Runtime-Marker

```text
RESULT testId=CAMPAIGNSTATE-RESOURCE-TRANSACTION-1 status=PASS transferDelivery=true consumption=true cancellation=true loss=true oneTimeCredit=true oneTimeDebit=true reservationGuard=true transactionIdentity=true persistence=false mooseTransport=false dcsStorageMutation=false
```

Ergebnis:

```text
ACCEPTED_TECHNICAL_BASELINE
```

für exakt den in diesem Bericht dokumentierten Source-/Builder-/MIZ-/Bundle-/DCS-Stand.

## 6. Nicht belegt

Dieser Acceptance-Stand beweist ausdrücklich nicht:

```text
OPSTRANSPORT runtime integration
CTLD runtime integration
DCS STORAGE mutation
weapon/store mapping
automatic aircraft fuel debit
native DCS consumption reconciliation
LogisticsDemand generation
transport selection
physical cargo creation
persistence
restart reconciliation
multiplayer synchronization
```

Diese Punkte benötigen jeweils einen eigenen MOOSE-First-Integrations- und Acceptance-Scope.

## 7. Inherited Risk

Der Branch basiert auf `agent/campaignstate-storage-multinode-sync`. Für diesen Parent existiert ein 7/7-DCS-Runtime-PASS, aber der dortige Clean-Run besitzt weiterhin nicht die vollständige MIZ-/Embedded-Bundle-Provenienz für eine formale `ACCEPTED_TECHNICAL_BASELINE`-Promotion. Diese Parent-Grenze wird durch den vorliegenden Transaction-Acceptance-Bericht nicht aufgehoben.
