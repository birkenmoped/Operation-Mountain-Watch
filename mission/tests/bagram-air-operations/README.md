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
validated_in_dcs: true
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

## Local build verification 25.08.2026

Der Projektinhaber hat den Builder im separaten lokalen Worktree

```text
P:\DCS-DEV\Operation-Mountain-Watch-bagram-mq1a-lre
```

zunächst auf folgendem Remote-Quellstand ausgeführt:

```text
Branch: agent/bagram-mq1a-lre-foundation
Git HEAD: 34a3d6008ee61ee91b01a1d572ee29fbae3011b8
BuilderVersion: BGRAM-AIR-OPS-DUAL-FOUNDATION-3
LifecycleGuard: PASS
Airwings: 2
Squadrons: 7
RegisteredGroups: 69
RepresentedAirframes: 81
LogicalAirframes: 83
LogicalReserve: 2
RolePayloadsExpected: 8
TestDispatch: ABSENT
AUFTRAGInstances: ABSENT
OPSTRANSPORTInstances: ABSENT
Commander: ABSENT
ParkingOverride: ABSENT
```

Die real zurückgemeldeten lokalen SHA-256-Werte dieses ersten Laufs lauten:

```text
Generated bundle:
311AFE593C4869EA530232A8C742CF09A5080A2EBD47A3266C24306541B436FC

Source Lua:
550C33C4AC221171C80439008047F7D36C7D1DBD6F7C37ED772004E673D78505

Builder:
B33DF31ECDE305465C4EA14E02465754462C3A5B8093D19AD469EE94969D3E2A
```

Nach Dokumentation dieses Laufs wurde der lokale Worktree per Fast-Forward auf folgenden Remote-Stand aktualisiert und erneut gebaut:

```text
Git HEAD: 58d026746e2af75f69859cdec38f498700be3b66
BuilderVersion: BGRAM-AIR-OPS-DUAL-FOUNDATION-3
LifecycleGuard: PASS
Airwings: 2
Squadrons: 7
RegisteredGroups: 69
RepresentedAirframes: 81
LogicalAirframes: 83
LogicalReserve: 2
RolePayloadsExpected: 8
TestDispatch: ABSENT
AUFTRAGInstances: ABSENT
OPSTRANSPORTInstances: ABSENT
Commander: ABSENT
ParkingOverride: ABSENT
```

Die real zurückgemeldeten SHA-256-Werte dieses zweiten Laufs lauten:

```text
Generated bundle:
A060CE3A796943698348D75BDB869F0F3B0485E50E08689F136718E87E8E42D2

Source Lua:
550C33C4AC221171C80439008047F7D36C7D1DBD6F7C37ED772004E673D78505

Builder:
B33DF31ECDE305465C4EA14E02465754462C3A5B8093D19AD469EE94969D3E2A
```

Der geänderte Bundle-Hash zwischen den beiden Läufen ist erwartbar, weil der Builder den jeweiligen `GitCommit` in den generierten Bundle-Header schreibt. Source-Lua und Builder blieben byte-identisch.

## DCS foundation acceptance 25.08.2026

Der finale eingefrorene Testkandidat wurde in DCS mit folgender Provenienz ausgeführt:

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

Der Runtime-Marker lautet:

```text
RESULT status=RUNNING airwings=2 squadrons=7 registeredGroups=69 representedAirframes=81 logicalAirframes=83 logicalReserve=2 rolePayloads=8 usafRunning=true armyRunning=true missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false
```

Der MQ-1A-LRE-Pool wurde dabei erfolgreich registriert:

```text
SQUADRON_REGISTERED name=SQ_US_BGRM_MQ1A_62_ERS wing=usaf template=TPL_AIR_US_BGRM_MQ1A_RECON_1SHIP assetGroups=8 grouping=1 representedAircraft=8 logicalAircraft=8 residualAircraft=0 payloads=1
```

Damit lautet das Foundation-Ergebnis für diesen exakt dokumentierten Stand:

```text
PASS
```

Die vollständige Acceptance liegt unter:

```text
mission/tests/bagram-air-operations/expected/bagram-mq1a-lre-foundation-acceptance.md
```

Dieser PASS validiert ausschließlich den Foundation-Scope. Er validiert nicht Parking, Taxi, Start/Landung, konkreten MQ-1A-RECON-Dispatch, taktische Missionserfüllung, Recovery, Loss Accounting, Persistenz oder Multiplayer-Endurance.

Der frühere sechs-SQUADRON-DCS-PASS bleibt für seinen exakt dokumentierten historischen Stand erhalten und wird nicht auf die neue Konfiguration übertragen.

Die Missionsdatei wird durch ChatGPT nicht automatisiert verändert oder neu gepackt.
