---
document_id: OMW-TEST-STORAGE-WEAPON-CONSUMPTION-CORRELATION-INDEX
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - read-only STORAGE weapon-consumption correlation harness scope
  - seven-node weapon inventory delta observation protocol
  - accepted isolated Shindand AH-64D external-store debit correlation
  - interpretation boundary between observed DCS warehouse deltas and strategic CampaignState resources
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-weapon-consumption-correlation
source_commit: 4844c4fab70e1227e6e96a70b8747cc12238190d
validated_in_dcs: true
base_branch: agent/ammunition-exact-item-mapping
base_commit: e93b0ad022a6ba6c32d2899ac24bdabb80615008
base_status: BINDING_CHILD_BRANCH
merged_to_main: false
inherited_risk:
  - parent mapping contract and resource-ID decision are not yet merged to main
---

# STORAGE Weapon Consumption Correlation

## 1. Ziel

`STORAGE-WEAPON-CONSUMPTION-CORRELATION-1` beobachtet read-only, welche Weapon-Inventory-Keys des DCS-Warehouses sich waehrend einer isolierten Aircraft-/Payload-Aktion tatsaechlich aendern.

Der Harness schliesst fuer die dokumentierte AH-64D-CAS-Payload einen Teil der technischen Luecke aus `OMW-ARCH-AMMUNITION-ITEM-MAPPING-CONTRACT`: MOOSE stellt den STORAGE-Lesepfad bereit; die DCS-seitige Buchungssemantik wurde fuer M151, AGM-114K und IAFS ComboPak praktisch korreliert.

## 2. MOOSE-First

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Verwendete oeffentliche MOOSE-API:

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetInventory()
SCHEDULER:New()
```

Der Harness ruft keine STORAGE-Mutationsmethode auf und implementiert keine eigene Warehouse-Mechanik. Die isolierte Aircraft-Aktion erfolgt ueber den bereits vorhandenen MOOSE-AIRWING/AUFTRAG-Pfad der Shindand-Foundation.

## 3. Beobachtete Endpoints

```text
Bagram
Jalalabad
Kandahar
Kandahar Heliport
FOB Salerno
Tarinkot
Shindand Heliport
```

## 4. Ablauf

Der Harness:

```text
T+10 s  -> BASELINE_CAPTURED fuer alle sieben STORAGE-Endpunkte
T+20 s  -> ACTION_WINDOW_OPEN
T+20..100 s -> read-only Weapon-Inventory-Polling alle 2 s
T+100 s -> ACTION_WINDOW_CLOSE
T+110 s -> FINAL_SNAPSHOT und Delta-Zusammenfassung
```

Jede Aenderung eines Weapon-Inventory-Keys wird protokolliert als:

```text
WEAPON_DELTA nodeId=<...> item=<...> before=<...> after=<...> delta=<...>
```

Der Harness bewertet eine Mengenveraenderung nicht automatisch als strategischen CampaignState-Verbrauch. Die Zuordnung wird pro isoliertem Aircraft-/Payload-Lauf fachlich bewertet.

## 5. Isolationsregel fuer DCS

Pro Lauf wird genau **eine** bewusst ausgewaehlte Aircraft-/Payload-Aktion innerhalb des Action Window ausgefuehrt. Andere AI-/Player-Aircraft-Aktionen an den sieben beobachteten Endpoints sind waehrend dieses Fensters zu vermeiden.

Der akzeptierte Lauf vom 11.08.2026 verwendet den isolierten Shindand-G2-AH-64-CAS-Pfad. Die Shindand-SQUADRON ist mit `grouping=2` konfiguriert; `SetRequiredAssets(1,1)` materialisiert daher eine einzelne 2-Ship-Assetgruppe.

## 6. Akzeptierter DCS-Befund

Der akzeptierte Lauf bestaetigt am Endpoint `SHINDAND_HELIPORT` genau folgende drei Deltas:

```text
weapons.droptanks.{IAFS_ComboPak_100}: 100 -> 98, delta=-2
weapons.nurs.HYDRA_70_M151:            100 -> 24, delta=-76
weapons.missiles.AGM_114K:             100 -> 96, delta=-4
```

Die Mengen entsprechen der dokumentierten 2-Ship-AH-64D-CAS-Payload:

```text
per aircraft: 38 x M151, 2 x AGM-114K, 1 x IAFS ComboPak
per 2-ship asset group: 76 x M151, 4 x AGM-114K, 2 x IAFS ComboPak
```

Die zuvor vor dem Lauf formulierte Erwartung der halben Mengen war falsch, weil sie ein einzelnes Luftfahrzeug statt der `grouping=2`-Assetgruppe zugrunde legte. Die Runtime-Evidenz korrigiert diese Annahme.

An den uebrigen sechs beobachteten STORAGE-Endpunkten wurde kein Weapon-Inventory-Delta protokolliert.

Finaler Harness-Marker:

```text
RESULT testId=STORAGE-WEAPON-CONSUMPTION-CORRELATION-1 status=PASS nodesExpected=7 nodesReady=7 deltasObserved=3 mutation=false campaignStateMutation=false opstransport=false ctld=false
```

## 7. Acceptance-Provenienz

```text
Source/Builder commit: 4844c4fab70e1227e6e96a70b8747cc12238190d
BuilderVersion: STORAGE-WEAPON-CONSUMPTION-CORRELATION-1
DCS: 2.9.28.26385 MT
Executed MIZ: OMW_Template_v8_AirOps_rdy.miz
Uploaded executed-copy SHA-256: abfaff193ac3618d2e0e3414d0ffd88f51f009c5b4b7f35f3ba8350459207093
Internal mission SHA-256: 28fd89a1ac9c3556d97bb438a90ec9db6c47f60d6550e241ad904173b06c5819
Embedded correlation bundle SHA-256: 1fe44ed294784563a358148fb0463b6ce93fb7c8bbd506de1c43128a361cd729
Local build correlation bundle SHA-256: 1fe44ed294784563a358148fb0463b6ce93fb7c8bbd506de1c43128a361cd729
Embedded isolated G2 action harness SHA-256: 787cd3a54cacf7b3a4349bf8554d4124d778fe02607e680dc143474c24d0653f
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS log SHA-256: 45e9d0e1f3a74ba8cbf33829ec27835334412db3089a0ad94c25ebff7755093d
Debrief SHA-256: 88fa0088298c510ed7136655b41a53f1c8b23d2a789336d0bd8935462df499e3
```

Vollstaendiger Bericht:

- [`OMW-TEST-STORAGE-WEAPON-CONSUMPTION-CORRELATION-ACCEPTANCE`](expected/storage-weapon-consumption-correlation-acceptance.md)

## 8. Parking-Befund

Der verwendete historische G2-Harness meldete nach Materialisierung `terminalID=41 parkingAllowed=false`. Dieser bekannte Shindand-Parking-Befund ist fuer den Weapon-Correlation-Scope nicht akzeptanzrelevant und wird durch diesen Test nicht behoben. Die Warehouse-Deltas waren bereits eindeutig der isolierten 2-Ship-AH-64-Aktion zugeordnet.

## 9. Weiterhin offen

```text
M230/M789 direct STORAGE mapping
GAU-8 direct STORAGE mapping
OH-58 M3P container-to-round semantics
unused-store return/recredit semantics
CampaignState debit
STORAGE SetItem/AddItem/RemoveItem adapter behavior for weapons
AIRWING payload accounting mutation
OPSTRANSPORT
CTLD
persistence
restart/multiplayer reconciliation
```

Insbesondere erzeugte die AH-64-Materialisierung keinen zusaetzlich beobachteten M230/M789-Weapon-Inventory-Delta. `AMMUNITION_30MM_M230` bleibt deshalb ohne direkten STORAGE-Mirror.

## 10. Build

```text
mission/tests/storage-weapon-consumption-correlation/src/01-storage-weapon-consumption-correlation.lua
tools/build-storage-weapon-consumption-correlation.ps1
mission/tests/storage-weapon-consumption-correlation/dist/OMW_Storage_Weapon_Consumption_Correlation_Test.lua
```

BuilderVersion:

```text
STORAGE-WEAPON-CONSUMPTION-CORRELATION-1
```
