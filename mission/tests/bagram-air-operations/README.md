---
document_id: OMW-TEST-BAGRAM-AIR-OPERATIONS-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram dual-AIRWING foundation test layout
  - Bagram foundation build and Mission Editor prerequisites
  - Bagram AIRWING/SQUADRON parking-policy acceptance state
not_authoritative_for:
  - tactical tasking
  - physical AI parking materialization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - historical single-AIRWING Bagram test index
superseded_by: []
source_branch: agent/bagram-parking-policy-integration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Bagram Air Operations Foundation Test

## Scope

Dieser Testpfad validiert den produktionsnahen Bagram-AIRWING-/SQUADRON-Grundbau nach ADR 0006 einschließlich der OMW-Abbildung des 62nd-ERS-Bagram-LRE mit acht logischen MQ-1A und, auf dem aktuellen Branch, der Bagram-Parking-Policy.

```text
AW_US_BGRM_455_AEW
AW_US_BGRM_TF_FALCON_10_CAB
```

Nicht Bestandteil dieses Pfads sind COMMANDER, konkrete AUFTRAG-Instanzen, OPSTRANSPORT, F10-Teststeuerung, Bagram→Jalalabad-Bewegungen, Recovery oder Persistenz. Die aktuelle Parking-Acceptance prüft die MOOSE-Konfiguration und die Propagation von `SQUADRON:SetParkingIDs(...)` auf die 69 registrierten AIRWING-Assets. Sie prüft noch keine sichtbare AI-Materialisierung auf einem konkreten Stellplatz.

## Aktueller Parking-Gate-Status 28.08.2026

```text
Status: FAIL -> FIX STAGED FOR RETEST
Failed source commit: 64bce3494cde458636788c208039e9f12278e6a9
Failed BuilderVersion: BGRAM-AIR-OPS-DUAL-FOUNDATION-5
Failure class: ACCEPTANCE_HARNESS_LIFECYCLE_TIMING
```

Der DCS-Lauf bestätigte:

```text
PARKING_POLICY_PRESTART status=PASS blacklist=10 assignedAI=44
PARKING_POLICY_POSTSTART status=FAIL assetsChecked=0 expectedAssets=69 failed=0
```

Die separate 187/187-Bagram-TerminalID-Correlation blieb gleichzeitig PASS. Der Fehler lag nicht in den Parking-Pools, sondern in der synchronen Acceptance-Prüfung direkt nach `AIRWING:Start()`.

Der gepinnte MOOSE-Source zeigt den tatsächlichen Lifecycle:

```text
AIRWING:AddSquadron(...)
-> AIRWING:AddAssetToSquadron(...)
-> WAREHOUSE:AddAsset(...)
-> WAREHOUSE:__NewAsset(0.1, ...)
-> LEGION:onafterNewAsset(...)
-> asset.parkingIDs = cohort.parkingIDs
-> cohort:AddAsset(asset)
-> public OnAfterNewAsset callback
```

Der aktuelle Fix verschiebt deshalb ausschließlich die Parking-Asset-Acceptance auf den öffentlichen MOOSE-Callback `OnAfterNewAsset`. Es wird kein eigener Scheduler, kein Native-DCS-Fallback und kein MOOSE-Override eingeführt.

Vollständiger Bericht:

```text
mission/tests/bagram-air-operations/expected/bagram-parking-policy-acceptance.md
```

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

`WH_AIR_US_BAGRAM` ist der bestehende USAF-/Hauptanker. `WH_AIR_US_BAGRAM_ARMY` muss als separater Army-Aviation-Anker an Bagram angelegt sein. Beide dürfen nicht dasselbe DCS-Objekt sein.

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

Der MQ-1A-Seed gehört zur `SQ_US_BGRM_MQ1A_62_ERS` und wird als `AUFTRAG.Type.RECON`-Capability registriert. Die Foundation erzeugt noch keine konkrete RECON-AUFTRAG-Instanz.

## Parking policy

Die aktuelle Bagram-Parking-Policy verwendet die DCS-validierte TerminalID-Correlation und setzt die öffentlichen MOOSE-APIs:

```text
AIRBASE:SetParkingSpotBlacklist(...)
SQUADRON:SetParkingIDs(...)
```

Die sieben Squadron-Pools sind:

```text
F-15E: M01-M12
F-16C: M13-M24
MQ-1A: B01-B08
C-130: A10,S01-S05
HH-60G: R15-R16
UH-60: R17-R18
CH-47: R19-R20
```

Hart ausgeschlossen:

```text
A08 A09
M27 M28 M29 M30
R21 R22
HAZ01 HAZ02
```

Der Retest muss nach der asynchronen NewAsset-Initialisierung folgenden Marker liefern:

```text
PARKING_POLICY_POSTSTART status=PASS assetsChecked=69 expectedAssets=69 failed=0 lifecycle=WAREHOUSE_NEWASSET
```

## Build

```powershell
.\tools\build-bagram-air-operations-foundation.ps1
```

Generated bundle:

```text
mission\tests\bagram-air-operations\dist\OMW_AirOps_Bagram.lua
```

Die `dist`-Datei ist Buildartefakt und nicht Source of Truth.

Aktueller Builder für den Retest:

```text
BuilderVersion: BGRAM-AIR-OPS-DUAL-FOUNDATION-6
PostStartAssetValidation: NEWASSET_EVENT
```

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

## Historische Foundation-Acceptance 25.08.2026

Der sieben-SQUADRON-Foundation-Stand ohne Parking-Policy bleibt für seinen exakt dokumentierten Scope akzeptiert:

```text
Branch: agent/bagram-mq1a-lre-foundation
Source / acceptance commit: 4a327d998cb9214f698d0278bbb5fa657eb8deb6
BuilderVersion: BGRAM-AIR-OPS-DUAL-FOUNDATION-3
Generated / embedded bundle SHA-256: 681CEF282F06BAFA2DEF45402105584A726BDF907BEE618411E893E6CFBACB0D
Mission: OMW_Template_v20_BGRM_MQ1A_Foundation_Test.miz
Mission SHA-256: FE9287B27D32E26EA208B3079CE04F9A8F83568F111E4BB0B348EEB324310081
DCS: 2.9.28.26385
Embedded Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS log SHA-256: 03FDE3FD3170735620D7CA1116DAF1E162BC69ECF2E267E7D72723C30EDBF64A
Debrief log SHA-256: E0479D73498ACC6DD0269C810B951CCB55B1EAEB1130AE6E49B4580A79C86BC6
```

Runtime-Marker:

```text
RESULT status=RUNNING airwings=2 squadrons=7 registeredGroups=69 representedAirframes=81 logicalAirframes=83 logicalReserve=2 rolePayloads=8 usafRunning=true armyRunning=true missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false
```

Vollständige Foundation-Acceptance:

```text
mission/tests/bagram-air-operations/expected/bagram-mq1a-lre-foundation-acceptance.md
```

Dieser historische PASS validiert nicht Parking, Taxi, Start/Landung, konkreten MQ-1A-RECON-Dispatch, taktische Missionserfüllung, Recovery, Loss Accounting, Persistenz oder Multiplayer-Endurance.

Die Missionsdatei wird durch ChatGPT nicht automatisiert verändert oder neu gepackt.
