---
document_id: OMW-MOOSE-LOGISTICS-TRANSPORT
status: BINDING
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - CampaignState and MOOSE logistics responsibility split
  - planned use boundaries for WAREHOUSE, STORAGE, OPSTRANSPORT, CTLD and transport groups
  - STORAGE fuel adapter foundation scope
not_authoritative_for:
  - completed transport runtime acceptance
  - completed STORAGE fuel adapter runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified MOOSE logistics and transport reference
superseded_by:
source_branch: agent/storage-fuel-adapter-foundation
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

Die Warehouse-Funktion ist für den dokumentierten Jalalabad-AIRWING-Grundstand teilweise belegt. Nicht allgemein validiert sind begrenzte Munition, Treibstoff, Nachschub, Assetzugang/-abgang, Wiederaufbau und Persistenz.

`WAREHOUSE`-Assetstock darf nicht mit CampaignState-Ressourcen oder DCS-Warehouse-Liquids/-Items gleichgesetzt werden.

## 3. STORAGE

Im gepinnten MOOSE-Stand `2.9.18`, Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, ist `STORAGE` source-reviewed als Wrapper um das DCS-Warehouse.

Geprüfte öffentliche Pfade umfassen:

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

`STORAGE` ist damit **nicht** als strategische Ressourcenhoheit oder Persistenzmechanismus freigegeben. Die Save-/Load-Pfade benötigen DCS-Desanitization; OMW ändert `MissionScripting.lua` nicht automatisch.

### 3.1 STORAGE-Fuel-Adapter-Foundation

Auf dem Branch `agent/storage-fuel-adapter-foundation` existiert erstmals ein projektspezifischer, absichtlich kleiner Adapter:

```text
scripts/logistics/OMW_StorageFuelAdapter.lua
```

Er bildet ausschließlich die verbindlichen CampaignState-Fuel-IDs auf die source-reviewed MOOSE-Liquid-Typen ab:

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

`PlanSnapshot()` ist der read/compare-Pfad. `ApplySnapshot()` ist der explizite Mirror-Pfad und prüft den anschließenden `GetLiquidAmount()`-Readback. Die Anwendung desselben Soll-Snapshots soll bei unverändertem Warehouse `changeCount=0` ergeben.

Der geplante DCS-Test steht unter:

- [`OMW-TEST-STORAGE-FUEL-ADAPTER-INDEX`](../../mission/tests/storage-fuel-adapter/README.md)
- [`OMW-TEST-STORAGE-FUEL-ADAPTER-FOUNDATION-ACCEPTANCE`](../../mission/tests/storage-fuel-adapter/expected/storage-fuel-adapter-foundation-acceptance.md)

Bis zu diesem DCS-Lauf bleibt die Adapterwirkung **nicht validiert**.

### 3.2 Unlimited-Prüfung

Der Foundation-Adapter ruft `STORAGE:IsUnlimitedLiquids()` bewusst nicht auf. Der geprüfte MOOSE-Quellpfad dieser Methode testet Unlimited-Zustände durch temporäres Entfernen und gegebenenfalls Wiederhinzufügen einer Einheit. Für einen read-only Reconciliation-Plan wäre das eine unerwünschte Mutation.

Der Test-Harness erkennt stattdessen nur einen offensichtlichen Unlimited-Sentinel als Stop-Bedingung. Diese Heuristik gehört zum Test und ist keine CampaignState-Regel.

## 4. OPSTRANSPORT

Geplant für taktische Truppen- und Frachttransporte zwischen definierten Lade-, Übergabe- und Entladezonen. Zu prüfen sind:

- Carrier-/Cargo-Eignung;
- Reservierung und Beladung;
- Route und Lifecycle;
- Entladung und stabile Endposition;
- Verlust, Abbruch und zerstörte Assets;
- Rückmeldung an CargoManifest und CampaignState.

Ein MOOSE-`Delivered`- oder vergleichbares Runtime-Ereignis ist ein operatives Signal. Die strategische Zielgutschrift bleibt an die CampaignState-Prüfung der stabilen Cargo-ID, Zielbedingungen und Einmalgutschrift gebunden.

Der tatsächliche MOOSE-Quellstand enthält außerdem den Storage-Transportpfad über `OPSTRANSPORT:AddCargoStorage(...)`. Dieser Pfad ist für OMW weiterhin nur `PLANNED`; er ist nicht Bestandteil des STORAGE-Fuel-Adapter-Foundation-Tests.

## 5. CTLD und Dynamic Cargo

MOOSE CTLD sowie native DCS-Frachtfunktionen werden vorrangig geprüft. Ein Adapter darf nur die nachgewiesene Lücke schließen und benötigt Eigentümerfreigabe.

CTLD-/Dynamic-Cargo-Objekte besitzen keine eigene strategische Ressourcenhoheit und dürfen bei Umschlag keine neue Ressource erzeugen.

## 6. RAT

RAT-Verkehr ist rein atmosphärisch. Er verändert keine CampaignState-Bestände und transportiert keine strategischen Ressourcen.

## 7. Acceptance-Grenze

Jeder Transporttyp benötigt eigene Testfälle für Einmalgutschrift, Verlust, Teillieferung, Disconnect, Multiplayer, Persistenz und Missionsneustart.

Für `STORAGE` sind zusätzlich mindestens zu prüfen:

- Fuel-Read/Write auf einem OMW-Airbase-Warehouse;
- getrennte JETFUEL-/GASOLINE-Behandlung;
- Waffen-/Item-Mapping für tatsächlich verwendete OMW-Stores;
- CampaignState→STORAGE-Synchronisation ohne Rückhoheit;
- Reconciliation bei abweichendem DCS-Bestand;
- Mission-Restart ohne Ressourcenverdopplung.

Der erste Foundation-Test deckt davon nur Fuel-Read/Write, JETFUEL-/GASOLINE-Trennung, Readback, Idempotenz und Wiederherstellung am Testknoten Kandahar ab. Alle weiteren Punkte bleiben offen.
