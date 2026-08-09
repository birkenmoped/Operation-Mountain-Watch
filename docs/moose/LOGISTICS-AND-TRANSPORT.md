---
document_id: OMW-MOOSE-LOGISTICS-TRANSPORT
status: BINDING
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - CampaignState and MOOSE logistics responsibility split
  - planned use boundaries for WAREHOUSE, OPSTRANSPORT, CTLD and transport groups
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
├── OPSTRANSPORT als Transportauftrag
├── FLIGHTGROUP und ARMYGROUP als Carrier oder Cargo
├── CTLD als Spielerlogistik
├── CSAR/AICSAR als Recovery-Ausführung
└── RAT ausschließlich als atmosphärischer Verkehr
```

Der vollständige frühere Methoden- und Klassenstand bleibt erhalten:

- [`Legacy-MOOSE-Logistik und Transport`](../evidence/source-records/legacy-moose-logistics-and-transport.md)

## 2. WAREHOUSE

Die Warehouse-Funktion ist für den dokumentierten Jalalabad-AIRWING-Grundstand teilweise belegt. Nicht allgemein validiert sind begrenzte Munition, Treibstoff, Nachschub, Assetzugang/-abgang, Wiederaufbau und Persistenz.

## 3. OPSTRANSPORT

Geplant für taktische Truppen- und Frachttransporte zwischen definierten Lade-, Übergabe- und Entladezonen. Zu prüfen sind:

- Carrier-/Cargo-Eignung;
- Reservierung und Beladung;
- Route und Lifecycle;
- Entladung und stabile Endposition;
- Verlust, Abbruch und zerstörte Assets;
- Rückmeldung an CargoManifest und CampaignState.

## 4. CTLD und Dynamic Cargo

MOOSE CTLD sowie native DCS-Frachtfunktionen werden vorrangig geprüft. Ein Adapter darf nur die nachgewiesene Lücke schließen und benötigt Eigentümerfreigabe.

## 5. RAT

RAT-Verkehr ist rein atmosphärisch. Er verändert keine CampaignState-Bestände und transportiert keine strategischen Ressourcen.

## 6. Acceptance-Grenze

Jeder Transporttyp benötigt eigene Testfälle für Einmalgutschrift, Verlust, Teillieferung, Disconnect, Multiplayer, Persistenz und Missionsneustart.
