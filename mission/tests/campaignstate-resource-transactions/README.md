---
document_id: OMW-TEST-CAMPAIGNSTATE-RESOURCE-TRANSACTION-INDEX
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - CampaignState strategic resource transaction contract test scope
  - reservation, transfer, consumption, cancellation, loss and idempotency invariants
  - MOOSE-first boundary between strategic accounting and operational transport
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/campaignstate-resource-transaction-contract
source_commit: 04ea3a0b50dfd51483316bc989b14e6d5c4be731
validated_in_dcs: true
base_branch: agent/campaignstate-storage-multinode-sync
base_commit: 552377a6e2743edf2b884027963007227db84324
base_status: DRAFT_WITH_DCS_RUNTIME_EVIDENCE
merged_to_main: false
inherited_risk:
  - parent branch has a 7/7 DCS runtime PASS but lacks the executed MIZ and embedded-bundle hashes required for formal ACCEPTED_TECHNICAL_BASELINE promotion
---

# CampaignState Resource Transaction Contract

## 1. Ziel

Dieser Branch führt den nächsten strategischen Ressourcenbaustein nach dem CampaignState-zu-STORAGE-Fuel-Mirror ein. Er definiert ausschließlich die **CampaignState-Domänenlogik** für Reservierung, Transfer, Verbrauch, Verlust und Einmalgutschrift.

Er implementiert **keinen eigenen Transport-Dispatcher** und ersetzt keine MOOSE-Funktion.

Zielbild:

```text
CampaignState
  -> strategischer Bestand
  -> Reservation / Transaction
  -> später MOOSE OPSTRANSPORT oder MOOSE CTLD als operative Ausführung
  -> bestätigtes Laufzeitergebnis
  -> CampaignState terminaler Commit
  -> vorhandener STORAGE-Mirror für operative DCS-Abbildung
```

`CampaignState` bleibt die strategische Ressourcenhoheit.

## 2. MOOSE-First-Prüfung

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Geprüfte MOOSE-Bausteine im tatsächlich verwendeten `Moose.lua`:

```text
OPSTRANSPORT:New(...)
OPSTRANSPORT:AddCargoStorage(StorageFrom, StorageTo, CargoType, CargoAmount, CargoWeight, TransportZoneCombo)
OPSTRANSPORT:GetCargoStorages(...)
OPSTRANSPORT FSM / Delivered lifecycle
STORAGE:GetAmount(...)
STORAGE:GetItemAmount(...)
STORAGE:SetItem(...)
STORAGE:AddItem(...)
STORAGE:RemoveItem(...)
STORAGE:GetLiquidAmount(...)
STORAGE:SetLiquid(...)
CTLD stock / loaded-cargo APIs
```

`OPSTRANSPORT:AddCargoStorage(...)` ist im gepinnten Quellstand ausdrücklich für Fuel, Weapons und Equipment zwischen zwei DCS-`STORAGE`-Warehouses vorgesehen. Das Storage-Cargo-Modell führt dabei Runtimefelder wie `cargoAmount`, `cargoReserved`, `cargoLoaded`, `cargoLost` und `cargoDelivered`.

MOOSE übernimmt damit bereits wesentliche **operative Transportsemantik**. Diese wird von OMW nicht parallel neu implementiert.

### 2.1 Verbleibende projektspezifische Lücke

MOOSE stellt jedoch nicht die OMW-spezifische strategische CampaignState-Autorität bereit. Insbesondere sind folgende OMW-Domänenanforderungen nicht durch eine MOOSE-Transportinstanz ersetzt:

```text
persistent/stable resourceTransactionId
persistent/stable reservationId
persistent/stable cargoId
missionDemandId linkage
strategic reservation across transport implementations
one-time CampaignState destination credit
one-time CampaignState consumption debit
restart/persistence-ready transaction identity
CampaignState-only stock authority independent from CTLD/OPSTRANSPORT runtime stock tables
```

Die interne `OPSTRANSPORT`-Cargo-UID wird aus einem Laufzeitcounter erzeugt und ist deshalb kein OMW-persistenter CampaignState-Primärschlüssel.

Damit ist der hier ergänzte Code **CampaignState-Domänenlogik**, nicht eine genehmigungspflichtige MOOSE-Parallelimplementierung. Für die spätere physische Ausführung bleibt MOOSE primär.

### 2.2 Offizielle Beispiele

Die offiziellen MOOSE-Missionsrepositories wurden als Referenz geprüft. Die produktive OMW-Integration von `OPSTRANSPORT` oder CTLD wird erst umgesetzt, wenn der konkrete Transportpfad gewählt und als eigener Integrationsscope getestet wird.

## 3. Strategischer Vertrag

Unterstützte Transaktionstypen:

```text
TRANSFER
CONSUMPTION
```

Transfer-Lifecycle:

```text
RESERVED
-> LOADING
-> IN_TRANSIT
-> DELIVERED
```

Alternative Enden:

```text
RESERVED / LOADING -> CANCELLED
IN_TRANSIT -> LOST
```

Consumption-Lifecycle:

```text
RESERVED
-> CONSUMED
```

optional:

```text
RESERVED -> LOADING -> CONSUMED
RESERVED / LOADING -> CANCELLED
```

## 4. Buchungssemantik

### 4.1 Reservierung

Eine Reservierung:

- verändert den physischen Gesamtbestand noch nicht;
- reduziert den strategisch verfügbaren Bestand;
- blockiert Überreservierung;
- ist über `transactionId` idempotent, wenn dieselbe Spezifikation wiederholt wird;
- weist dieselbe ID mit abweichender Spezifikation zurück.

### 4.2 Transfer

Beim Übergang zu `IN_TRANSIT`:

```text
origin stock -= quantity
origin reserved -= quantity
```

Bei `DELIVERED`:

```text
destination stock += quantity
```

Die Zielgutschrift erfolgt exakt einmal.

Bei `LOST` bleibt die Ursprungsabbuchung bestehen und das Ziel erhält keine Gutschrift.

### 4.3 Consumption

Bei `CONSUMED`:

```text
origin stock -= quantity
origin reserved -= quantity
```

Die Abbuchung erfolgt exakt einmal.

### 4.4 Cancellation

Bei `CANCELLED` vor Abgang:

```text
origin stock unchanged
origin reservation released
```

## 5. Kompatibilität mit Fuel Foundation

Die bestehende Fuel-API bleibt erhalten:

```text
CampaignState.ResourceId.JP8  = FUEL_JP8
CampaignState.ResourceId.AVGAS = FUEL_AVGAS
Store:GetResourceKg(...)
Store:GetFuelSnapshot(...)
```

Damit bleibt der vorhandene CampaignState-zu-STORAGE-Fuel-Mirror quellkompatibel.

Die interne Ressourcenrepräsentation ist jetzt generisch genug, um später weitere kanonische Einheiten wie `count` aufzunehmen. Das legt noch kein vollständiges Weapon-/Maintenance-Manifest fest.

## 6. Testmatrix

Test-ID:

```text
CAMPAIGNSTATE-RESOURCE-TRANSACTION-1
```

Der kombinierte Harness prüft in einem Lauf:

```text
legacy fuel snapshot compatibility
successful transfer
reservation availability
origin debit at IN_TRANSIT
one-time destination credit at DELIVERED
repeated DELIVERED idempotency
consumption debit
repeated CONSUMED idempotency
cancellation releases reservation without stock mutation
lost transfer receives no destination credit
over-reservation rejection
same transactionId + same spec idempotency
same transactionId + conflicting spec rejection
final stock invariants
```

Der Harness verwendet bewusst keine MOOSE-/DCS-Laufzeitfunktion. Er prüft die strategische Domain-Schicht isoliert.

## 7. Nicht Teil dieses Scopes

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

Diese Punkte folgen erst auf den bestätigten strategischen Transaktionsvertrag.

## 8. Source- und Build-Pfade

```text
scripts/campaign/OMW_CampaignState.lua
mission/tests/campaignstate-resource-transactions/src/01-campaignstate-resource-transactions.lua
tools/build-campaignstate-resource-transactions.ps1
mission/tests/campaignstate-resource-transactions/dist/OMW_CampaignState_Resource_Transaction_Test.lua
```

Builder-Version:

```text
CAMPAIGNSTATE-RESOURCE-TRANSACTION-1
```

## 9. Acceptance

Der Lauf vom 10.08.2026 ist für exakt den dokumentierten Stand `ACCEPTED_TECHNICAL_BASELINE`.

```text
Source/Builder commit: 04ea3a0b50dfd51483316bc989b14e6d5c4be731
BuilderVersion: CAMPAIGNSTATE-RESOURCE-TRANSACTION-1
DCS: 2.9.28.26385 MT
Executed MIZ: OMW_Template_v8_AirOps_rdy(5).miz
Executed MIZ SHA-256: a1058e7528953ab13ecab385fb1722a7fac6ced6385271a85a9408f4378518cf
Embedded bundle: l10n/DEFAULT/OMW_CampaignState_Resource_Transaction_Test.lua
Embedded bundle SHA-256: c054c24df9ddb8a9cc7671c2086e3bd414dbe9f0fba7bee3be998b534dceb4bf
Local build bundle SHA-256: c054c24df9ddb8a9cc7671c2086e3bd414dbe9f0fba7bee3be998b534dceb4bf
DCS log SHA-256: d73f5d665c5ec5488fd6f61c336a4e33f1e5fdc09362c57ed27af3c4d12bc862
Debrief SHA-256: f0303b498e37c87d59ac47f61b000025384d53c45b83a9b1ea9ee4478a3e36a8
```

Bestätigte Teilmarker:

```text
LEGACY_FUEL_SNAPSHOT_PASS
TRANSFER_DELIVERY_IDEMPOTENCY_PASS
CONSUMPTION_IDEMPOTENCY_PASS
CANCELLATION_RELEASE_PASS
LOSS_NO_DESTINATION_CREDIT_PASS
RESERVATION_AND_IDENTITY_GUARDS_PASS
```

Finaler Marker:

```text
RESULT testId=CAMPAIGNSTATE-RESOURCE-TRANSACTION-1 status=PASS transferDelivery=true consumption=true cancellation=true loss=true oneTimeCredit=true oneTimeDebit=true reservationGuard=true transactionIdentity=true persistence=false mooseTransport=false dcsStorageMutation=false
```

Damit sind für diesen exakten Stand strategische Reservierung, Transfer, Consumption, Cancellation, Loss, Einmalabbuchung, Einmalgutschrift und Transaction-ID-Guards praktisch bestätigt.

Nicht bestätigt sind weiterhin MOOSE-Transportausführung, CTLD, DCS-STORAGE-Mutation, Persistenz, Restart-Reconciliation oder Multiplayer-Synchronisation. Dieser Test hebt daher keinen MOOSE-Methodenstatus an; die im MOOSE-First-Review geprüften OPSTRANSPORT-/STORAGE-/CTLD-Pfade bleiben für ihre spätere operative Integration separat zu validieren.

Vollständiger Acceptance-Bericht:

- [`OMW-TEST-CAMPAIGNSTATE-RESOURCE-TRANSACTION-ACCEPTANCE`](expected/campaignstate-resource-transaction-acceptance.md)
