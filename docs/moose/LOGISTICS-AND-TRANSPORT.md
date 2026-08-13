---
document_id: OMW-MOOSE-LOGISTICS-TRANSPORT
status: BINDING
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - CampaignState and MOOSE logistics responsibility split
  - planned use boundaries for WAREHOUSE, STORAGE, OPSTRANSPORT, CTLD and transport groups
not_authoritative_for:
  - completed transport runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified MOOSE logistics and transport reference
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
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
STORAGE       = geplanter operativer DCS-Warehouse-Adapter
```

`STORAGE` ist damit **nicht** als strategische Ressourcenhoheit oder Persistenzmechanismus freigegeben. Die Save-/Load-Pfade benötigen DCS-Desanitization; OMW ändert `MissionScripting.lua` nicht automatisch.

## 4. OPSTRANSPORT

Geplant für taktische Truppen- und Frachttransporte zwischen definierten Lade-, Übergabe- und Entladezonen. Zu prüfen sind:

- Carrier-/Cargo-Eignung;
- Reservierung und Beladung;
- Route und Lifecycle;
- Entladung und stabile Endposition;
- Verlust, Abbruch und zerstörte Assets;
- Rückmeldung an CargoManifest und CampaignState.

Ein MOOSE-`Delivered`- oder vergleichbares Runtime-Ereignis ist ein operatives Signal. Die strategische Zielgutschrift bleibt an die CampaignState-Prüfung der stabilen Cargo-ID, Zielbedingungen und Einmalgutschrift gebunden.

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
