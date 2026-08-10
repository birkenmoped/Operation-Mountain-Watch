---
document_id: OMW-MOOSE-LOGISTICS-TRANSPORT
status: BINDING
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - CampaignState and MOOSE logistics responsibility split
  - planned use boundaries for WAREHOUSE, STORAGE, OPSTRANSPORT, CTLD and transport groups
  - STORAGE fuel adapter foundation scope
  - accepted CampaignState to STORAGE fuel sync foundation scope
not_authoritative_for:
  - completed transport runtime acceptance
  - completed CampaignState transaction, persistence or reverse-reconciliation acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified MOOSE logistics and transport reference
superseded_by:
source_branch: agent/campaignstate-storage-sync-foundation
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE-Logistik und Transport in Operation Mountain Watch

## 1. Verantwortungstrennung

```text
CampaignState
├── strategischer Bestand und Eigentum
├── Reservierungen und Cargo-IDs
├── Verluste und Persistenz
└── Standort- und Ressourcenstatus

MOOSE / DCS
├── WAREHOUSE, AIRWING und BRIGADE als operative Bestandsabbildung
├── STORAGE als DCS-Warehouse-Wrapper für Liquids und Items
├── OPSTRANSPORT als Transportauftrag
├── FLIGHTGROUP und ARMYGROUP als Carrier oder Cargo
├── CTLD als Spielerlogistik
├── CSAR/AICSAR als Recovery-Ausführung
└── RAT ausschließlich als atmosphärischer Verkehr
```

Der vollständige frühere Methoden- und Klassenstand bleibt erhalten:

- [`Legacy-MOOSE-Logistik und Transport`](../evidence/source-records/legacy-moose-logistics-and-transport.md)
- [`Resource-/Warehouse-Ownership-Vertrag`](../resource-warehouse-ownership-contract.md)

## 2. WAREHOUSE

Die Warehouse-Funktion ist für den dokumentierten AirOps-Grundstand als Asset-/AIRWING-Bestand belegt. Nicht allgemein validiert sind begrenzte Munition, Treibstoff, Nachschub, Assetzugang/-abgang, Wiederaufbau und Persistenz.

`WAREHOUSE`-Assetstock darf nicht mit CampaignState-Ressourcen oder DCS-Warehouse-Liquids/-Items gleichgesetzt werden.

## 3. STORAGE

Im gepinnten MOOSE-Stand `2.9.18`, Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, ist `STORAGE` der Wrapper um das native DCS-Airbase-Warehouse.

Source-reviewed öffentliche Pfade umfassen:

```text
STORAGE:FindByName(AirbaseName)
AIRBASE:GetStorage()
STORAGE:AddItem / SetItem / RemoveItem / GetItemAmount
STORAGE:AddLiquid / SetLiquid / RemoveLiquid / GetLiquidAmount
STORAGE:GetInventory()
```

Für Liquids führt der Quellstand getrennte Typen, darunter:

```text
STORAGE.Liquid.JETFUEL
STORAGE.Liquid.GASOLINE
```

Liquid-Mengen werden im geprüften Pfad in kg geführt.

Projektgrenze:

```text
CampaignState = strategische Wahrheit
STORAGE       = operativer DCS-Warehouse-Mirror
```

`STORAGE` ist **nicht** als strategische Ressourcenhoheit oder CampaignState-Persistenzmechanismus freigegeben. Die MOOSE-STORAGE-Save-/Load-Pfade benötigen DCS-Desanitization; OMW ändert `MissionScripting.lua` nicht automatisch.

### 3.1 STORAGE-Fuel-Adapter-Foundation

Auf dem Branch `agent/storage-fuel-adapter-foundation` existiert ein projektspezifischer, absichtlich kleiner Adapter:

```text
scripts/logistics/OMW_StorageFuelAdapter.lua
```

Er bildet ausschließlich die verbindlichen CampaignState-Fuel-IDs auf die MOOSE-Liquid-Typen ab:

```text
FUEL_JP8   -> STORAGE.Liquid.JETFUEL
FUEL_AVGAS -> STORAGE.Liquid.GASOLINE
canonical unit: kg
```

Der Adapter besitzt keine eigene strategische Hoheit. Der Aufrufer übergibt einen autoritativen Snapshot mit `nodeId`, `airbaseName` und `resourcesKg`. Der Adapter kann diesen Snapshot lesen/planen und nur durch einen expliziten Aufruf von `ApplySnapshot()` mit `STORAGE:SetLiquid()` spiegeln.

Foundation-Grenzen:

```text
no CampaignState mutation
no automatic aircraft fuel debit
no scheduler
no STORAGE file persistence
no OPSTRANSPORT
no CTLD
no reverse overwrite of CampaignState from DCS telemetry
```

`PlanSnapshot()` ist der read/compare-Pfad. `ApplySnapshot()` ist der explizite Mirror-Pfad und prüft den anschließenden `GetLiquidAmount()`-Readback. Die Anwendung desselben Soll-Snapshots ergibt bei unverändertem Warehouse `changeCount=0`.

Der DCS-Test ist für exakt den dokumentierten Kandahar-Scope als `ACCEPTED_TECHNICAL_BASELINE` bestätigt:

```text
Branch: agent/storage-fuel-adapter-foundation
Acceptance commit: 0e5992f96a37b7400d7859fbcd3e98829f935d68
BuilderVersion: STORAGE-FUEL-ADAPTER-FOUNDATION-1
DCS: 2.9.28.26385 MT
MIZ SHA-256: 54e9bd5d1d841a6c22980e59e07b463aef580032813f3441f1030b221fec66e9
Bundle SHA-256: 16faa7da140334ddd3a001480e6f2677842b3dcc3cff64626796e039cd0769db
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: WRITE_READBACK_PASS / IDEMPOTENCY_PASS / RESTORE_PASS / status=PASS
```

Vollständige Provenienz:

- [`OMW-TEST-STORAGE-FUEL-ADAPTER-INDEX`](../../mission/tests/storage-fuel-adapter/README.md)
- [`OMW-TEST-STORAGE-FUEL-ADAPTER-FOUNDATION-ACCEPTANCE`](../../mission/tests/storage-fuel-adapter/expected/storage-fuel-adapter-foundation-acceptance.md)

### 3.2 Limited-/Unlimited-Liquids-Grenze

Der erste DCS-Lauf mit aktiviertem `Unlimited Liquids` lieferte keinen veränderbaren begrenzten Fuel-Bestand und endete beim Sollwert-Readback mit `FAIL`. Der akzeptierte Lauf verwendete Kandahar mit deaktivierter Unlimited-Option und initial jeweils `100 t` JETFUEL/GASOLINE. `STORAGE:GetLiquidAmount()` las dafür jeweils `100000 kg` zurück.

Damit gilt für den akzeptierten OMW-Mirror-Pfad:

```text
CampaignState-managed DCS STORAGE fuel node
-> Unlimited Liquids = OFF
-> explicit limited initial quantity
```

Diese Voraussetzung gilt für OMW/CampaignState-verwaltete Fuel-Nodes. Nicht verwaltete Afghanistan-Airports werden dadurch nicht automatisch auf Limited Liquids umgestellt.

Der Foundation-Adapter ruft `STORAGE:IsUnlimitedLiquids()` bewusst nicht auf. Der geprüfte MOOSE-Quellpfad dieser Methode testet Unlimited-Zustände durch temporäres Entfernen und gegebenenfalls Wiederhinzufügen einer Einheit. Für einen read-only Reconciliation-Plan wäre das eine unerwünschte Mutation.

### 3.3 WAREHOUSE und STORAGE sind keine doppelte Fuel-Hoheit

Die an AirOps-Knoten vorhandenen MOOSE-`WAREHOUSE`-Objekte gehören zum AIRWING-/SQUADRON-Asset-Lifecycle. Das native DCS-Airbase-Warehouse wird über MOOSE `STORAGE` angesprochen.

```text
MOOSE WAREHOUSE / AIRWING asset stock
!= MOOSE STORAGE / DCS warehouse liquids
!= CampaignState strategic fuel quantity
```

Der akzeptierte STORAGE-Test verändert ausschließlich den nativen DCS-Airbase-Warehouse-Liquidpfad. Er weist keine Fuel-Buchung im AIRWING-`WAREHOUSE` nach und darf nicht als solche interpretiert werden.

### 3.4 CampaignState → STORAGE Sync Foundation

Auf dem Folgebranch `agent/campaignstate-storage-sync-foundation` ist der kleinste one-way Integrationspfad praktisch bestätigt:

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_CampaignStateStorageSync.lua
scripts/logistics/OMW_StorageFuelAdapter.lua
```

Der CampaignState-Store liefert ausschließlich einen read-only Fuel-Snapshot. Der Sync-Koordinator liest diesen Snapshot und delegiert Plan/Apply vollständig an den bereits akzeptierten STORAGE-Fuel-Adapter.

```text
CampaignState
-> OMW_CampaignStateStorageSync
-> OMW_StorageFuelAdapter
-> MOOSE STORAGE
-> DCS Kandahar warehouse
```

Der DCS-Lauf vom 10.08.2026 bestätigt für exakt den dokumentierten Stand:

```text
Branch: agent/campaignstate-storage-sync-foundation
Source/Builder commit: 94ce64365e5bd3836030cdfd8a3e5049b2b477a8
BuilderVersion: CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1
DCS: 2.9.28.26385 MT
MIZ SHA-256: 1d8824b7849d01e6b63a9d51d819fb8da39cdc85eda2c7426b393cb78bf5cd91
Internal mission SHA-256: a0f6ef17c57d318ff095c81dd098264acb87ea826292ab81bf459d5486b98256
Embedded bundle SHA-256: 6f2678c853d27f273e73fab51eb39921e7d658d1b6cb3c13f857afdee4f2c4a7
DCS log SHA-256: 940f548b4ad0fc6a54f9e698e353792db63c412334de22332ccd7f7187cb61da
Debrief SHA-256: 82d61abb24f1209a0bcd57b14186de172c6b0e29ffd44caf4d300d2d6ac72c95
Result: CAMPAIGNSTATE_SNAPSHOT_PASS / SYNC_PLAN_PASS / SYNC_WRITE_READBACK_PASS / SYNC_IDEMPOTENCY_PASS / NO_REVERSE_MUTATION_PASS / RESTORE_PASS / status=PASS
```

Bestätigt ist damit ausschließlich ein expliziter, one-way Sollwert-Mirror. Nicht bestätigt sind CampaignState-Transaktionen, Reservierungen, Persistenz, kontinuierliche Scheduler-Synchronisation, Aircraft-Verbrauch, Transport oder Reverse-Reconciliation.

Vollständige Provenienz:

- [`OMW-TEST-CAMPAIGNSTATE-STORAGE-SYNC-INDEX`](../../mission/tests/campaignstate-storage-sync/README.md)
- [`OMW-TEST-CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-ACCEPTANCE`](../../mission/tests/campaignstate-storage-sync/expected/campaignstate-storage-sync-foundation-acceptance.md)

## 4. OPSTRANSPORT

Geplant für taktische Truppen- und Frachttransporte zwischen definierten Lade-, Übergabe- und Entladezonen. Zu prüfen sind:

- Carrier-/Cargo-Eignung;
- Reservierung und Beladung;
- Route und Lifecycle;
- Entladung und stabile Endposition;
- Verlust, Abbruch und zerstörte Assets;
- Rückmeldung an CargoManifest und CampaignState.

Ein MOOSE-`Delivered`- oder vergleichbares Runtime-Ereignis ist ein operatives Signal. Die strategische Zielgutschrift bleibt an die CampaignState-Prüfung der stabilen Cargo-ID, Zielbedingungen und Einmalgutschrift gebunden.

Der tatsächliche MOOSE-Quellstand enthält außerdem den Storage-Transportpfad über `OPSTRANSPORT:AddCargoStorage(...)`. Dieser Pfad ist für OMW weiterhin nur `PLANNED`; er ist nicht Bestandteil der STORAGE-Fuel- oder CampaignState-Sync-Foundation-Tests.

## 5. CTLD und Dynamic Cargo

MOOSE CTLD sowie native DCS-Frachtfunktionen werden vorrangig geprüft. Ein Adapter darf nur die nachgewiesene Lücke schließen und benötigt Eigentümerfreigabe.

CTLD-/Dynamic-Cargo-Objekte besitzen keine eigene strategische Ressourcenhoheit und dürfen bei Umschlag keine neue Ressource erzeugen.

## 6. RAT

RAT-Verkehr ist rein atmosphärisch. Er verändert keine CampaignState-Bestände und transportiert keine strategischen Ressourcen.

## 7. Acceptance-Grenze

Jeder Transporttyp benötigt eigene Testfälle für Einmalgutschrift, Verlust, Teillieferung, Disconnect, Multiplayer, Persistenz und Missionsneustart.

Für `STORAGE` bzw. die CampaignState-Integration sind weiterhin zusätzlich zu prüfen:

- Waffen-/Item-Mapping für tatsächlich verwendete OMW-Stores;
- CampaignState-Transaktions- und Reservierungsmodell;
- Reconciliation bei abweichendem DCS-Bestand;
- Mission-Restart ohne Ressourcenverdopplung;
- Multiplayer-Verhalten;
- automatische oder ereignisbasierte Aircraft-Verbrauchsbuchung nur nach eigenem Vertrag.

Die bisherigen Foundation-Tests haben für Kandahar Fuel-Read/Write, JETFUEL-/GASOLINE-Trennung, kg-Abbildung, Readback, Idempotenz, Wiederherstellung sowie den one-way CampaignState→STORAGE-Sollwertpfad bestätigt. Diese Acceptance ist nicht auf andere Knoten oder die offenen Integrationspunkte zu extrapolieren.