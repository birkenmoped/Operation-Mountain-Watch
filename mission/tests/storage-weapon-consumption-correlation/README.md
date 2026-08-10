---
document_id: OMW-TEST-STORAGE-WEAPON-CONSUMPTION-CORRELATION-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - read-only STORAGE weapon-consumption correlation harness scope
  - seven-node weapon inventory delta observation protocol
  - interpretation boundary between observed DCS warehouse deltas and strategic CampaignState resources
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-weapon-consumption-correlation
source_commit: PENDING_MERGE
validated_in_dcs: false
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

Der Harness soll die verbleibende technische Luecke aus `OMW-ARCH-AMMUNITION-ITEM-MAPPING-CONTRACT` schliessen: MOOSE stellt den STORAGE-Lesepfad bereit; ungeklaert ist die DCS-seitige Buchungssemantik konkreter Aircraft-/Payload-Aktionen.

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

Der Harness ruft keine STORAGE-Mutationsmethode auf und implementiert keine eigene Warehouse-Mechanik.

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

Der Harness bewertet eine Mengenveraenderung nicht automatisch als strategischen Verbrauch. Die Zuordnung wird erst nach einem isolierten Lauf mit dokumentierter Aircraft-/Payload-Aktion fachlich bewertet.

## 5. Isolationsregel fuer DCS

Pro Lauf wird genau **eine** bewusst ausgewaehlte Aircraft-/Payload-Aktion innerhalb des Action Window ausgefuehrt. Andere AI-/Player-Aircraft-Aktionen an den sieben beobachteten Endpoints sind waehrend dieses Fensters zu vermeiden.

Die erste Auswertung soll mit einer bereits verbindlich definierten OMW-Beladung erfolgen. Fuer AH-64D existiert die projektweite CAS-Baseline mit M151/Hellfire/M789. A-10- und OH-58-Mapping werden erst dann als akzeptiert bewertet, wenn ihre konkrete im Lauf verwendete Beladung ebenfalls dokumentiert ist.

## 6. Ergebnissemantik

Ein Harness-PASS bedeutet ausschliesslich:

```text
alle sieben STORAGE-Endpunkte aufgeloest
Baseline und Final-Snapshot lesbar
Polling ohne Harnessfehler abgeschlossen
keine testseitige STORAGE-Mutation
keine CampaignState-Mutation
```

Der finale Marker lautet:

```text
RESULT testId=STORAGE-WEAPON-CONSUMPTION-CORRELATION-1 status=PASS nodesExpected=7 nodesReady=7 deltasObserved=<N> mutation=false campaignStateMutation=false opstransport=false ctld=false
```

`deltasObserved=0` ist ein gueltiges Diagnoseergebnis und kein automatischer Harness-FAIL.

## 7. Nicht Teil dieses Scopes

```text
CampaignState debit
STORAGE SetItem/AddItem/RemoveItem
AIRWING payload accounting mutation
OPSTRANSPORT
CTLD
persistence
restart/multiplayer reconciliation
invented shell/container conversion factors
```

## 8. Build

```text
mission/tests/storage-weapon-consumption-correlation/src/01-storage-weapon-consumption-correlation.lua
tools/build-storage-weapon-consumption-correlation.ps1
mission/tests/storage-weapon-consumption-correlation/dist/OMW_Storage_Weapon_Consumption_Correlation_Test.lua
```

BuilderVersion:

```text
STORAGE-WEAPON-CONSUMPTION-CORRELATION-1
```
