---
document_id: OMW-TEST-SHINDAND-FOUNDATION-ACCEPTANCE
status: VALIDATED
document_class: DCS_ACCEPTANCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - exact Shindand Heliport AIRWING/SQUADRON foundation runtime result documented below
  - post-start SQUADRON asset-count validation for the documented artifact chain
  - post-start inherited SQUADRON parking TerminalID validation for the documented artifact chain
not_authoritative_for:
  - COMMANDER or tactical dispatch
  - AUFTRAG or OPSTRANSPORT execution
  - actual helicopter spawn, taxi, takeoff, landing or recovery behavior
  - CampaignState persistence or resource accounting
  - any other DCS, MOOSE, mission, source or bundle version
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/shindand-heliport-parking-diagnostic
source_commit: d24c9d92470192dcee8467f3b24ed31548edd3a3
validated_in_dcs: true
validation_date: 2026-08-10
---

# Shindand Heliport – AIRWING/SQUADRON Foundation Acceptance

## 1. Umfang

Dieser Acceptance-Record dokumentiert ausschließlich den ausgeführten Foundation-Lauf für den separaten nativen DCS-/MOOSE-Knoten `Shindand Heliport`.

Getestet wurden:

- genau ein AIRWING;
- drei SQUADRONs;
- 16 registrierte MOOSE-Assetgruppen;
- 20 repräsentierte und 20 logische Luftfahrzeuge;
- post-start SQUADRON-Assetanzahl;
- Vererbung der owner-defined `SQUADRON:SetParkingIDs()`-Pools an die post-start Assets;
- Foundation-Idle-Zustand ohne COMMANDER, AUFTRAG-Instanz, OPSTRANSPORT oder F10-Steuerung.

Nicht getestet wurden tatsächlicher Spawn, Taxi, Abflug, Landung, Recovery, taktischer Dispatch oder Persistenz.

## 2. Exakte Artefaktkette

```text
Branch:
agent/shindand-heliport-parking-diagnostic

Source commit:
d24c9d92470192dcee8467f3b24ed31548edd3a3

Builder:
tools/build-shindand-air-operations-foundation.ps1

BuilderVersion:
SHND-AIR-OPS-FOUNDATION-1

Generated bundle:
OMW_AirOps_Shindand.lua

Local/embedded bundle SHA-256:
a7bd8a28ba9e72db2505a4237b6b5ea21465eba1ef09693cf6e6d461f8c6e2ea

MIZ:
OMW_Template_v7_Shindand.miz

Uploaded MIZ SHA-256:
f27abcc146e9c5f69b2d9f3e2a539d8494a7a400d60fe20b3393d34c393caeea

Internal mission SHA-256:
0197160bb41b408a1bc233fae811c8d590e2307ce44d6c8b5b5b88935dd1b391

Embedded Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

DCS log SHA-256:
ed6ef1cdb25008079be758ee4caa75e1ea24ac85d4f98db5510dbb8b4fc52fd4

Debrief SHA-256:
8ac5fc1b5a84b212c13e6beed094595bc400f2d478a3851b903b6ff500a162a0
```

Die im hochgeladenen `.miz` eingebettete `l10n/DEFAULT/OMW_AirOps_Shindand.lua` besitzt exakt denselben SHA-256 wie das zuvor lokal gebaute Bundle. Die eingebettete `Moose.lua` entspricht ebenfalls exakt dem gepinnten Projektartefakt.

## 3. DCS-Umgebung

```text
DCS: 2.9.28.26385
Architecture: x86_64
Mode: MT
OS: Windows
Test date: 2026-08-10
```

Der Debrief nennt als ausgeführte Missionsdatei:

```text
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v7_Shindand.miz
```

Der Debrief enthält:

```text
graveyard = {}
```

## 4. Runtime-Ergebnis

Nach `AIRWING:Start()` meldete der Foundation-Harness:

```text
SQUADRON_POSTSTART name=SQ_US_SHND_AH64D_ATTACK expectedAssets=4 actualAssets=4 parkingIDs=21,3,34,15 parkingSync=true
SQUADRON_POSTSTART name=SQ_US_SHND_UH60_UTILITY_MEDEVAC expectedAssets=8 actualAssets=8 parkingIDs=41,18,13,20,19 parkingSync=true
SQUADRON_POSTSTART name=SQ_US_SHND_CH47_HEAVYLIFT expectedAssets=4 actualAssets=4 parkingIDs=30,10,23 parkingSync=true
```

Finaler Ergebnismarker:

```text
RESULT status=RUNNING airbase=Shindand Heliport airbaseID=14 airwings=1 squadrons=3 registeredGroups=16 representedAirframes=20 logicalAirframes=20 logicalReserve=0 rolePayloads=3 running=true postStartAssetParkingSync=true missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false
```

Damit ist für diese exakte Artefaktkette bestätigt:

```text
Foundation runtime: PASS
Airbase identity: PASS
AIRWING running: PASS
SQUADRON count: PASS
Post-start asset counts: PASS
Inherited type-specific parkingIDs: PASS
Unexpected foundation dispatch: not observed by harness result
Commander created: false
F10 controls: false
Graveyard: empty
```

## 5. Bestätigter Parking-Vertrag dieses Foundation-Laufs

```text
AH-64D
ME 01,02,05,07
TerminalID 21,3,34,15

UH-60
ME 29,30,31,34,34a
TerminalID 41,18,13,20,19

CH-47
ME 41,39,37
TerminalID 30,10,23
```

Der Acceptance-Lauf bestätigt hier die SQUADRON-Konfiguration und die post-start Vererbung der TerminalID-Listen an die MOOSE-Assets. Er bestätigt noch nicht, dass ein später tatsächlich gespawntes Luftfahrzeug in jedem Fall auf einem dieser Plätze erscheint oder nach Recovery wieder in denselben Pool zurückkehrt.

Der vollständig freie allgemeine Pool `ME 11-19` und `ME 20-27` wurde in diesem Foundation-Inkrement nicht zusätzlich einem SQUADRON zugeordnet.

## 6. Unabhängiger Shutdown-Fehler

Beim Beenden von DCS erscheint erneut:

```text
C:\Users\Sven\Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua:168: attempt to index upvalue 'tcp' (a nil value)
```

Dieser Fehler tritt im externen Saved-Games-Hook beim DCS-Shutdown auf und liegt zeitlich nach dem erfolgreichen OMW-Foundation-`RESULT`-Marker. Er ist kein Fehler des Shindand-Foundation-Bundles.

## 7. Acceptance-Grenze

Status dieses Dokuments:

```yaml
foundation_runtime: VALIDATED
post_start_asset_counts: VALIDATED
post_start_parking_id_inheritance: VALIDATED
actual_spawn_parking: NOT_TESTED
takeoff: NOT_TESTED
mission_dispatch: NOT_TESTED
landing_recovery: NOT_TESTED
persistence: NOT_TESTED
```

`VALIDATED` gilt ausschließlich für die oben dokumentierte DCS-/MOOSE-/MIZ-/Bundle-/Commit-Kette.
