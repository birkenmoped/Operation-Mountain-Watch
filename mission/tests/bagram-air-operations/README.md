---
document_id: OMW-TEST-BAGRAM-AIR-OPERATIONS-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram dual-AIRWING foundation test layout
  - Bagram foundation build and Mission Editor prerequisites
not_authoritative_for:
  - DCS runtime acceptance
  - tactical tasking or parking acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - historical single-AIRWING Bagram test index
superseded_by: []
source_branch: agent/bagram-mq1a-lre-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Bagram Air Operations Foundation Test

## Scope

Dieser Testpfad validiert ausschließlich den produktionsnahen Bagram-AIRWING-/SQUADRON-Grundbau nach ADR 0006 einschließlich der OMW-Abbildung des 62nd-ERS-Bagram-LRE mit acht logischen MQ-1A.

```text
AW_US_BGRM_455_AEW
AW_US_BGRM_TF_FALCON_10_CAB
```

Nicht Bestandteil dieses Pfads sind COMMANDER, konkrete AUFTRAG-Instanzen, OPSTRANSPORT, F10-Teststeuerung, Bagram→Jalalabad-Bewegungen, Parking-Overrides beziehungsweise Parking-Whitelist/-Blacklist, Recovery oder Persistenz.

## Required Mission Editor objects

Airbase:

```text
Bagram
```

Warehouse anchors:

```text
WH_AIR_US_BAGRAM
WH_AIR_US_BAGRAM_ARMY
```

`WH_AIR_US_BAGRAM` ist der bestehende USAF-/Hauptanker. `WH_AIR_US_BAGRAM_ARMY` muss als separater Army-Aviation-Anker an Bagram angelegt werden. Beide dürfen nicht dasselbe DCS-Objekt sein.

Required Late Activation templates:

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
TPL_AIR_US_BGRM_MQ1A_RECON_1SHIP
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP
```

Für physisch identische Hubschrauber-Konfigurationen werden keine zusätzlichen rollenbezogenen Mission-Editor-Seeds angelegt. `CSAR_LEAD`/`CSAR_COVER` beim HH-60G sowie `TRANSPORT`/`UTILITY` beim Army-UH-60 werden über MOOSE-Mission-Capabilities und Tasking unterschieden, nicht durch identische Template-Dubletten.

Der MQ-1A-Seed gehört zur `SQ_US_BGRM_MQ1A_62_ERS` und wird als `AUFTRAG.Type.RECON`-Capability registriert. Die Foundation erzeugt noch keine konkrete RECON-AUFTRAG-Instanz und setzt keine ParkingIDs.

Der alte Branch verwendete für den F-16-CAS-Seed teilweise `TPL_AIR_US_BGRM_F16_CAS_2SHIP`. Der Neubau normalisiert diesen Identifier bewusst auf `F16C`; die Mission-Editor-Gruppe ist vor dem Test entsprechend zu benennen.

## Build

```powershell
.\tools\build-bagram-air-operations-foundation.ps1
```

Generated bundle:

```text
mission\tests\bagram-air-operations\dist\OMW_AirOps_Bagram.lua
```

Die `dist`-Datei ist Buildartefakt und nicht Source of Truth.

## MOOSE pin

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Expected foundation accounting

```text
2 AIRWINGs
7 SQUADRONs
69 MOOSE asset groups
81 represented airframes
83 logical airframes
2 logical fighter reserve airframes
8 role-payload registrations
0 created missions
0 created transports
0 COMMANDER
0 F10 controls
```

Der frühere sechs-SQUADRON-DCS-PASS ist für diesen erweiterten Foundation-Vertrag nicht übertragbar. Ein neuer DCS-PASS gilt nur für die vom Projektinhaber tatsächlich getestete MIZ samt Hash, DCS-Version, eingebettetem Bundle und eingebetteter Moose.lua.

Die Missionsdatei wird durch ChatGPT nicht automatisiert verändert oder neu gepackt.
