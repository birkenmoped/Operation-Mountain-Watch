---
document_id: OMW-MOOSE-STORAGE-WEAPON-ITEM-MAPPING
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE STORAGE weapon-item mapping candidates
  - boundaries for the OMW weapon inventory diagnostic
  - separation of CampaignState resource IDs from DCS/MOOSE warehouse item identifiers
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-weapon-item-matrix
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE STORAGE Weapon-/Item-Mapping

## 1. Zweck

Dieser Stand bereitet die nächste OMW-Ressourcenstufe nach dem akzeptierten CampaignState-Transaktionsvertrag vor. Ziel ist noch **keine produktive Munitionssynchronisation**, sondern die belastbare Ermittlung der DCS-/MOOSE-Warehouse-Item-IDs, die für die tatsächlich verwendeten OMW-Waffenfamilien relevant sind.

Die strategische Hoheit bleibt unverändert:

```text
CampaignState resource stock
!= AIRWING payload availability
!= MOOSE STORAGE / DCS warehouse weapon item count
```

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der tatsächlich verwendete `Moose.lua`-Stand bestätigt die öffentlichen STORAGE-Pfade:

```text
STORAGE:FindByName(AirbaseName)
AIRBASE:GetStorage()
STORAGE:GetInventory()
STORAGE:GetItemAmount(Name)
STORAGE:SetItem(Name, Amount)
STORAGE:AddItem(Name, Amount)
STORAGE:RemoveItem(Name, Amount)
```

`STORAGE:GetInventory()` gibt Aircraft-, Liquid- und Weapon-Tabellen des nativen DCS-Warehouses zurück. Bei einer auf unlimited gesetzten Kategorie kann die entsprechende Tabelle leer sein.

## 3. Read-only-Grenze des ersten Tests

Der erste OMW Weapon-/Item-Matrix-Test verwendet ausschließlich:

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetInventory()
STORAGE:GetItemAmount()
ENUMS.Storage.weapons
```

Er verwendet ausdrücklich nicht:

```text
STORAGE:SetItem()
STORAGE:AddItem()
STORAGE:RemoveItem()
STORAGE:IsUnlimited()
STORAGE:IsUnlimitedWeapons()
native DCS warehouse access
_DATABASE
OPSTRANSPORT
CTLD
AIRWING payload mutation
CampaignState mutation
persistence
scheduler
```

`STORAGE:IsUnlimited()` wird absichtlich nicht verwendet. Der gepinnte MOOSE-Quellpfad prüft Unlimited-Zustände durch temporäres Entfernen eines Items und gegebenenfalls anschließendes Wiederhinzufügen. Das ist für einen read-only Mapping-Test nicht akzeptabel.

## 4. Source-reviewed Kandidaten

Der gepinnte MOOSE-Stand enthält unter `ENUMS.Storage.weapons` unter anderem folgende für die aktuelle Ressourcenbaseline relevante IDs.

### 4.1 Hellfire

```text
ENUMS.Storage.weapons.missiles.AGM_114
  -> weapons.missiles.AGM_114

ENUMS.Storage.weapons.missiles.AGM_114K
  -> weapons.missiles.AGM_114K
```

Diese Fundstellen beweisen die Warehouse-Item-IDs im MOOSE-Enum, aber noch nicht, welche Variante ein konkretes OMW-Payload tatsächlich aus dem DCS-Warehouse entnimmt.

### 4.2 Hydra 70 / 2.75-inch rocket family

Source-reviewed Kandidaten umfassen unter anderem:

```text
weapons.nurs.HYDRA_70_M151
weapons.nurs.HYDRA_70_M151_M433
weapons.nurs.HYDRA_70_M229
weapons.nurs.HYDRA_70_M259
weapons.nurs.HYDRA_70_M274
weapons.nurs.HYDRA_70_M282
weapons.nurs.HYDRA_70_MK1
weapons.nurs.HYDRA_70_MK61
```

Zusätzlich existieren AGR-20/APKWS-bezogene Einträge. Diese werden nicht automatisch der strategischen Ressource `AMMUNITION_ROCKETS_70MM` zugeschlagen; die OMW-Payload- und historische Baseline entscheidet später, welche Varianten tatsächlich in den produktiven Ressourcenvertrag gehören.

### 4.3 AH-64 M230 30 mm

Source-reviewed Kandidaten umfassen:

```text
weapons.gunmounts.M230
weapons.shells.M230_30
weapons.shells.M230_HEDP M789
weapons.shells.M230_HEI M799
weapons.shells.M230_TP M788
```

### 4.4 A-10 GAU-8 30 mm

Der gleiche MOOSE-Enum enthält eigenständige GAU-8-Munition, unter anderem:

```text
weapons.shells.GAU8_30_AP
weapons.shells.GAU8_30_TP
```

Damit ist bereits auf Source-Ebene belegt, dass die bisherige strategische Baseline-ID

```text
AMMUNITION_30MM
```

nicht stillschweigend als ein einziges austauschbares Warehouse-Item behandelt werden darf. AH-64-M230- und A-10-GAU-8-Munition sind technisch getrennte DCS-/MOOSE-Itemfamilien. Ob CampaignState dafür künftig getrennte strategische Resource IDs erhält, ist eine Owner-Entscheidung und wird durch diesen Test nicht vorweggenommen.

### 4.5 .50 cal / OH-58D

Source-reviewed Kandidaten umfassen unter anderem:

```text
weapons.gunmounts.OH58D_M3P_L100
weapons.gunmounts.OH58D_M3P_L200
weapons.gunmounts.OH58D_M3P_L300
weapons.gunmounts.OH58D_M3P_L500
weapons.shells.M2_12_7
weapons.shells.M2_12_7_T
weapons.shells.50Browning_Ball_M2
weapons.shells.50Browning_AP_M2
weapons.shells.50Browning_API_M8
weapons.shells.50Browning_APIT_M20
```

Auch hier ist erst im Runtime-/Payload-Abgleich zu klären, welche DCS-Warehouse-Items für die OMW-OH-58D-Konfiguration tatsächlich maßgeblich sind.

## 5. AIRWING-Payload-Grenze

`AIRWING:NewPayload(...)` bleibt die operative MOOSE-Payloadregistrierung. Die dort geführte Payloadanzahl ist keine strategische CampaignState-Munitionsmenge.

Der spätere Vertrag muss deshalb zwei Fragen getrennt beantworten:

```text
1. Welches AIRWING-Payload darf eine Mission ausführen?
2. Welche CampaignState-Ressourcen werden für diese konkrete Payload reserviert/verbrauchsgebucht?
```

Erst nach verifiziertem Weapon-/Item-Mapping darf ein Adapter diese Ebenen korrelieren.

## 6. Geplanter Runtime-Nachweis

Der kombinierte Test `STORAGE-WEAPON-ITEM-MATRIX-1` liest in einem DCS-Lauf dieselben sieben verwalteten STORAGE-Endpunkte wie die Fuel-Multi-Node-Foundation:

```text
Bagram
Jalalabad
Kandahar
Kandahar Heliport
FOB Salerno
Tarinkot
Shindand Heliport
```

Pro Endpoint werden geprüft beziehungsweise protokolliert:

- AIRBASE-/STORAGE-Auflösung;
- Identität von `AIRBASE:GetStorage()` und `STORAGE:FindByName()`;
- erfolgreicher read-only `STORAGE:GetInventory()`-Aufruf;
- Anzahl der im Weapon-Inventar gelieferten Keys;
- rohe `GetItemAmount()`-Werte für die festgelegten Kandidaten;
- alle Inventory-Keys, die auf Hellfire/Hydra/M230/GAU-8/.50-cal-Kandidaten passen.

Ein leeres Weapon-Inventar wird **nicht** als „keine Munition vorhanden“ interpretiert, weil `GetInventory()` bei Unlimited Weapons ebenfalls eine leere Weapon-Tabelle liefern kann.

## 7. Nicht Teil dieses Scopes

```text
strategic resource-ID split decision
initial ammunition stocks
Target/Reorder/Critical quantities
weapon consumption events
unused weapon return semantics
SetItem/AddItem/RemoveItem runtime mutation
CampaignState-to-STORAGE weapon synchronization
AIRWING payload debit
OPSTRANSPORT/CTLD delivery
countermeasure mapping acceptance
persistence/restart/multiplayer
```

Erst nach diesem Mapping-Nachweis wird entschieden, welche Itemfamilien in den produktiven Multi-Resource-Warehouse-Test eingehen.