---
document_id: OMW-TEST-BAGRAM-PARKING-POLICY-ACCEPTANCE
status: PLANNED
document_class: DCS_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram AIRWING/SQUADRON parking policy acceptance
  - exact failed 2026-08-28 parking-policy DCS run
not_authoritative_for:
  - tactical AUFTRAG dispatch
  - physical AI parking materialization
  - taxi, takeoff, landing or recovery behavior
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/bagram-parking-policy-integration
source_commit: 64bce3494cde458636788c208039e9f12278e6a9
acceptance_branch: agent/bagram-parking-policy-integration
acceptance_commit: 64bce3494cde458636788c208039e9f12278e6a9
acceptance_mission: OMW_Template_v20_BGRM_Parking_Correlation_1.miz
acceptance_mission_sha256: e254cc4e07e1ef1c0c8a46387fa3af27eb9bed6a81cb8a925e39ab25697a7906
dcs_version: 2.9.29.27278
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
---

# Bagram Parking Policy Acceptance

## Aktueller Gate-Status

```text
Result: FAIL
Test date: 2026-08-28
Scope: AIRWING_SQUADRON_FOUNDATION_WITH_PARKING_POLICY
Failure class: ACCEPTANCE_HARNESS_LIFECYCLE_TIMING
```

Der erste DCS-Lauf der Bagram-Parking-Policy hat die Parking-Konfiguration nicht widerlegt. Er hat einen Fehler im Zeitpunkt der Acceptance-Prüfung nachgewiesen.

## Exakte Testprovenienz

```text
Branch: agent/bagram-parking-policy-integration
Source commit: 64bce3494cde458636788c208039e9f12278e6a9
BuilderVersion: BGRAM-AIR-OPS-DUAL-FOUNDATION-5
Generated / embedded bundle SHA-256: AFCBB41CBDB341FD39D2FBD324D6132B02472137650E10FD735FD02866053F3F
Source Lua SHA-256: C6C28EE1805758EB0D48DA0C11028792E3A870C5F8C05C943ABE0D0128E54258
Builder SHA-256: 890BE30E5ADFFC640DBC18ADB14F4A923A87B009F705ABE1C66A777E7DD7545B
Mission: OMW_Template_v20_BGRM_Parking_Correlation_1.miz
Mission SHA-256: E254CC4E07E1EF1C0C8A46387FA3AF27EB9BED6A81CB8A925E39AB25697A7906
Internal mission SHA-256: 0308FBE509E4192FDDAECFA59D8AFD23D0EE7637CE258C36F42739E08A93FC36
Embedded Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Embedded parking-correlation bundle SHA-256: 7C99719A8733480793DE79AFAEF5F5072DC1EBD82B193516212CE7F7F2B78782
DCS: 2.9.29.27278 MT
DCS log artifact SHA-256: 0802C377CB2EFD5880B4237143AD5D3F2EAE0C36BF27ACB3834AE67AD84D7FE4
Debrief artifact SHA-256: 3A41B46C62FC982010EBBA0C16CA715E9E4A0A966EA8B56CE57B963859BC7F32
```

Die Log- und Debrief-Hashes beziehen sich auf die vom Projektinhaber nach dem Lauf bereitgestellten unveränderlichen Upload-Artefakte, nicht auf später veränderte Live-Dateien im Saved-Games-Logverzeichnis.

## Beobachtetes Ergebnis

Die statische Parking-Policy bestand den Pre-Start-Check:

```text
PARKING_POLICY_PRESTART status=PASS blacklist=10 assignedAI=44
```

Die unmittelbar nach `AIRWING:Start()` ausgeführte Assetprüfung fand jedoch noch keine SQUADRON-Assets:

```text
PARKING_POLICY_POSTSTART status=FAIL assetsChecked=0 expectedAssets=69 failed=0
```

Darauf folgte erwartungsgemäß der harte Acceptance-Fehler:

```text
Bagram parking policy did not propagate to all AIRWING assets
```

Gleichzeitig bestand der separate Parking-Correlation-Test weiterhin mit:

```text
candidates=187
mapped=187
missingSpots=0
runtimeParkingSpots=187
runtimeUniqueTerminalIDs=187
runtimeDuplicateIDs=0
unexpectedRuntimeIDs=0
```

## Root Cause gegen gepinnten MOOSE-Source

Der gepinnte MOOSE-Stand zeigt für den relevanten Pfad:

```text
AIRWING:AddSquadron(Squadron)
-> AIRWING:AddAssetToSquadron(Squadron, Squadron.Ngroups)
-> WAREHOUSE:AddAsset(..., assignment=Squadron.name)
-> WAREHOUSE:onafterAddAsset(...)
-> WAREHOUSE:__NewAsset(0.1, asset, assignment)
-> LEGION:onafterNewAsset(...)
-> asset.parkingIDs = cohort.parkingIDs
-> cohort:AddAsset(asset)
-> public OnAfterNewAsset callback
```

Damit war die bisherige synchrone Prüfung direkt nach `AIRWING:Start()` zu früh. `squadron.assets` ist zu diesem Zeitpunkt zulässigerweise noch leer. Der Runtime-Befund `assetsChecked=0` ist mit dem gepinnten MOOSE-Source konsistent.

## Korrekturpfad

Die Parking-Policy selbst bleibt unverändert. Die Acceptance-Prüfung wird auf den öffentlichen MOOSE-FSM-Callback `OnAfterNewAsset` verschoben. Dieser Callback läuft nach dem internen `LEGION:onafterNewAsset` und damit nach der Zuweisung von `asset.parkingIDs` und der Aufnahme in `cohort.assets`.

Kein eigener Scheduler, kein Frame-Scan, kein Native-DCS-Fallback und kein MOOSE-Override werden eingeführt.

Der Folgebuild muss mindestens folgende Marker enthalten:

```text
BuilderVersion: BGRAM-AIR-OPS-DUAL-FOUNDATION-6
PostStartAssetValidation: NEWASSET_EVENT
PARKING_POLICY_POSTSTART status=PENDING ... lifecycle=AWAITING_WAREHOUSE_NEWASSET
PARKING_POLICY_POSTSTART status=PASS assetsChecked=69 expectedAssets=69 failed=0 lifecycle=WAREHOUSE_NEWASSET
parkingPolicy=PASS parkingAssetsChecked=69
```

## Acceptance-Grenze

Ein künftiger PASS dieses Tests bestätigt:

```text
- die sieben SQUADRON-Parking-Pools sind konfiguriert;
- die zehn hard-excluded IDs bleiben außerhalb der Pools;
- MOOSE propagiert die SQUADRON parkingIDs auf alle 69 registrierten AIRWING-Assets;
- beide AIRWINGs laufen im Foundation-Scope ohne AUFTRAG-/OPSTRANSPORT-/COMMANDER-Dispatch.
```

Er bestätigt weiterhin nicht die sichtbare Materialisierung eines konkreten AI-Flugzeugs auf einem freigegebenen Parking-Spot. Dafür ist ein separater kontrollierter Dispatch-/Spawn-Test erforderlich.
