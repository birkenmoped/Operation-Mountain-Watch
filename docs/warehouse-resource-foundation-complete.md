---
document_id: OMW-WAREHOUSE-RESOURCE-FOUNDATION-COMPLETE
status: BINDING_PROJECT_DECISION
document_class: ARCHITECTURE_AND_ACCEPTANCE_SYNTHESIS
owning_policy: OMW-GOV-001
authoritative_for:
  - Warehouse and CampaignState resource ownership
  - AirOps strategic resource identifiers and classes
  - AirOps initial, target, reorder and critical store stocks
  - Bagram finite fighter air-to-air deployment inventory
  - DCS/MOOSE STORAGE mapping boundaries
  - return, loss, recovery and replenishment semantics
  - closed Warehouse/resource foundation scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local Warehouse resource planning summaries for the same scope
superseded_by:
source_branch: agent/fighter-store-runtime-correlation
source_commit: e1b2456f89c0baec52661a03826a9efbc44ca027
validated_in_dcs: partial
---

# Warehouse-/Resource-Foundation – vollständiger Abschlussstand

## 1. Ergebnis

Der AirOps-Warehouse-/Resource-Foundation-Block ist für den vereinbarten Scope abgeschlossen.

```text
INITIAL_STOCK_DECISION_BLOCK = CLOSED
RESOURCE_OWNERSHIP_CONTRACT = CLOSED
FIGHTER_STORE_MAPPING_BLOCK = CLOSED
WAREHOUSE_RESOURCE_FOUNDATION = CLOSED
DCS_RUNTIME_GATE = PASS
```

Dieser Abschluss friert die strategischen Bestandsentscheidungen ein. Eine spätere produktive Initialisierungs-Lua oder Missionsreservierungslogik konsumiert diese Baseline; sie eröffnet die Mengenplanung nicht erneut.

## 2. Autoritätsmodell

`CampaignState` ist alleinige strategische Ressourcenhoheit. Es führt strategische Menge, Reservierung, Transfer, Verbrauch, Verlust und Gutschrift.

MOOSE/DCS-Komponenten haben getrennte operative Rollen:

```text
CampaignState                     strategische Wahrheit
MOOSE STORAGE / DCS Warehouse     operativer Spiegel, native Transaktionen, Telemetrie
MOOSE WAREHOUSE / AIRWING         Aircraft-/Asset- und Missions-Lifecycle
SQUADRON                           erlaubte Aircraft-/Payload-Fähigkeiten
DCS-Gruppen                        temporäre physische Repräsentation
```

Es gibt keine zweite strategische Munitions- oder Fuel-Hoheit in MOOSE WAREHOUSE, AIRWING oder DCS Warehouse. Ein DCS-/STORAGE-Bestand darf CampaignState nicht rückwärts als strategische Wahrheit überschreiben.

## 3. Strategische Ressourcen

Fuel:

```text
FUEL_JP8
FUEL_AVGAS
```

Kanonische Fuel-Einheit ist `kg`. Operative Abbildung:

```text
FUEL_JP8   -> STORAGE.Liquid.JETFUEL
FUEL_AVGAS -> STORAGE.Liquid.GASOLINE
```

Ammunition und Stores:

```text
AMMUNITION_30MM_M230
AMMUNITION_30MM_GAU8
AMMUNITION_50CAL_M3P
AMMUNITION_HELLFIRE
AMMUNITION_ROCKETS_70MM
AMMUNITION_AIM120
AMMUNITION_AIM9
AMMUNITION_GBU12
AMMUNITION_GBU38
AMMUNITION_GBU54
AMMUNITION_GBU31_V1
AMMUNITION_GBU31_V3
AMMUNITION_AGM65D
AMMUNITION_LUU2B
FLARES_CHAFF
```

Strategisches Mission Equipment:

```text
EQUIPMENT_AAQ13
EQUIPMENT_AAQ14
EQUIPMENT_AAQ33
EQUIPMENT_AAQ28
```

## 4. Ressourcenklassen

`CONSUMABLE_STRATEGIC`: strategischer Bestand mit dauerhaftem Verbrauch bei Einsatz/Verlust.

`RETURNABLE_STRATEGIC`: externer Store, der bei normalem unbenutztem Return operativ wieder verfügbar werden kann; tatsächlicher Verbrauch/Verlust reduziert die strategische Menge.

`RETURNABLE_STRATEGIC_EQUIPMENT`: strategische Pods/Equipment. Normaler Return stellt Verfügbarkeit wieder her; Totalverlust/Write-off reduziert den strategischen Bestand.

`DEPLOYMENT_FINITE_STOCK`: endlicher deployment-derived Theaterbestand ohne normalen automatischen Kampagnennachschub.

`TECHNICAL_NON_STRATEGIC`: nur operative DCS/STORAGE-Verfügbarkeit, kein CampaignState-Stock. Dazu gehören F-16 370-gal-Tank, F-15E External Tank und AH-64 IAFS ComboPak 100.

`TELEMETRY_ONLY`: strategische Ressource ohne belastbaren direkten STORAGE-Round-Mirror. M230 und GAU-8 werden über Onboard-/Debrief-Telemetrie bewertet.

`STORE_WITHOUT_ROUND_CONVERSION`: Containerpfad sichtbar, aber keine genehmigte Container-zu-Round-Konversion. Das gilt insbesondere für OH-58 M3P; CH-47 M60D bleibt ebenfalls Container-/Telemetry-Sonderfall.

## 5. Node- und Aggregationsregel

Strategische Stores werden exakt einmal je `Node + Resource ID` geführt. SQUADRONs und AIRWINGs besitzen keine separaten strategischen Munitionspools.

Berechnungsreihenfolge:

```text
Raw demand aller zulässigen Profile eines Nodes
-> Aggregation nach Node + Resource ID
-> Pair-Multiple bestimmen
-> nur Bagram/Kandahar Main: belegtes Logistics-Pack-Multiple zusätzlich anwenden
-> genau einmal runden
-> Initial / Target / Reorder / Critical einfrieren
```

Forward Nodes werden nicht auf vollständige Hub-Verpackungseinheiten aufgerundet. Geplante paarweise geladene Bestände bleiben gerade; reale Restbestände dürfen nach Verbrauch ungerade sein.

## 6. Finale Initial-Stock-Matrix v20

Maschinenlesbare Baseline:

`data/logistics/air-operations-initial-store-stock-v20.csv`

| Node | Resource | Class | Initial | Target | Reorder | Critical | Supply Parent |
|---|---|---|---:|---:|---:|---:|---|
| BAGRAM | AMMUNITION_AIM120 | DEPLOYMENT_FINITE_STOCK | 52 | 52 | 0 | 0 | OFF_MAP |
| BAGRAM | AMMUNITION_AIM9 | DEPLOYMENT_FINITE_STOCK | 26 | 26 | 0 | 0 | OFF_MAP |
| BAGRAM | AMMUNITION_GBU12 | CONSUMABLE_STRATEGIC | 102 | 102 | 84 | 36 | OFF_MAP |
| BAGRAM | AMMUNITION_GBU31_V1 | CONSUMABLE_STRATEGIC | 43 | 43 | 36 | 16 | OFF_MAP |
| BAGRAM | AMMUNITION_GBU31_V3 | CONSUMABLE_STRATEGIC | 43 | 43 | 36 | 16 | OFF_MAP |
| BAGRAM | AMMUNITION_GBU38 | CONSUMABLE_STRATEGIC | 216 | 216 | 180 | 84 | OFF_MAP |
| BAGRAM | AMMUNITION_GBU54 | CONSUMABLE_STRATEGIC | 120 | 120 | 96 | 48 | OFF_MAP |
| BAGRAM | EQUIPMENT_AAQ13 | RETURNABLE_STRATEGIC_EQUIPMENT | 16 | 16 | 13 | 10 | OFF_MAP |
| BAGRAM | EQUIPMENT_AAQ14 | RETURNABLE_STRATEGIC_EQUIPMENT | 16 | 16 | 13 | 10 | OFF_MAP |
| BAGRAM | EQUIPMENT_AAQ33 | RETURNABLE_STRATEGIC_EQUIPMENT | 16 | 16 | 13 | 10 | OFF_MAP |
| BAGRAM | FLARES_CHAFF | CONSUMABLE_STRATEGIC | 16369 | 16369 | 14427 | 9576 | OFF_MAP |
| JALALABAD | AMMUNITION_30MM_M230 | CONSUMABLE_STRATEGIC | 7920 | 7920 | 6480 | 2880 | BAGRAM |
| JALALABAD | AMMUNITION_50CAL_M3P | CONSUMABLE_STRATEGIC | 44640 | 44640 | 36000 | 14400 | BAGRAM |
| JALALABAD | AMMUNITION_HELLFIRE | CONSUMABLE_STRATEGIC | 54 | 54 | 44 | 20 | BAGRAM |
| JALALABAD | AMMUNITION_ROCKETS_70MM | CONSUMABLE_STRATEGIC | 1575 | 1575 | 1287 | 567 | BAGRAM |
| JALALABAD | FLARES_CHAFF | CONSUMABLE_STRATEGIC | 6173 | 6173 | 5724 | 4608 | BAGRAM |
| KANDAHAR_HELI | AMMUNITION_30MM_M230 | CONSUMABLE_STRATEGIC | 12960 | 12960 | 10080 | 3600 | KANDAHAR_MAIN |
| KANDAHAR_HELI | AMMUNITION_50CAL_M3P | CONSUMABLE_STRATEGIC | 49920 | 49920 | 38400 | 14400 | KANDAHAR_MAIN |
| KANDAHAR_HELI | AMMUNITION_HELLFIRE | CONSUMABLE_STRATEGIC | 88 | 88 | 68 | 24 | KANDAHAR_MAIN |
| KANDAHAR_HELI | AMMUNITION_ROCKETS_70MM | CONSUMABLE_STRATEGIC | 2113 | 2113 | 1652 | 653 | KANDAHAR_MAIN |
| KANDAHAR_HELI | FLARES_CHAFF | CONSUMABLE_STRATEGIC | 13597 | 13597 | 12096 | 8352 | KANDAHAR_MAIN |
| KANDAHAR_MAIN | AMMUNITION_30MM_GAU8 | CONSUMABLE_STRATEGIC | 37375 | 37375 | 33350 | 22425 | OFF_MAP |
| KANDAHAR_MAIN | AMMUNITION_AGM65D | CONSUMABLE_STRATEGIC | 26 | 26 | 24 | 20 | OFF_MAP |
| KANDAHAR_MAIN | AMMUNITION_GBU12 | CONSUMABLE_STRATEGIC | 12 | 12 | 12 | 6 | OFF_MAP |
| KANDAHAR_MAIN | AMMUNITION_GBU38 | CONSUMABLE_STRATEGIC | 156 | 156 | 132 | 78 | OFF_MAP |
| KANDAHAR_MAIN | AMMUNITION_HELLFIRE | CONSUMABLE_STRATEGIC | 56 | 56 | 46 | 20 | OFF_MAP |
| KANDAHAR_MAIN | AMMUNITION_LUU2B | CONSUMABLE_STRATEGIC | 232 | 232 | 208 | 156 | OFF_MAP |
| KANDAHAR_MAIN | AMMUNITION_ROCKETS_70MM | CONSUMABLE_STRATEGIC | 212 | 212 | 192 | 136 | OFF_MAP |
| KANDAHAR_MAIN | EQUIPMENT_AAQ28 | RETURNABLE_STRATEGIC_EQUIPMENT | 20 | 20 | 16 | 12 | OFF_MAP |
| KANDAHAR_MAIN | FLARES_CHAFF | CONSUMABLE_STRATEGIC | 17134 | 17134 | 14994 | 9648 | OFF_MAP |
| SALERNO | AMMUNITION_30MM_M230 | CONSUMABLE_STRATEGIC | 6480 | 6480 | 5040 | 2880 | KANDAHAR_MAIN |
| SALERNO | AMMUNITION_50CAL_M3P | CONSUMABLE_STRATEGIC | 12000 | 12000 | 9120 | 4800 | KANDAHAR_MAIN |
| SALERNO | AMMUNITION_HELLFIRE | CONSUMABLE_STRATEGIC | 44 | 44 | 34 | 20 | KANDAHAR_MAIN |
| SALERNO | AMMUNITION_ROCKETS_70MM | CONSUMABLE_STRATEGIC | 865 | 865 | 692 | 433 | KANDAHAR_MAIN |
| SALERNO | FLARES_CHAFF | CONSUMABLE_STRATEGIC | 4428 | 4428 | 4100 | 3600 | KANDAHAR_MAIN |
| SHINDAND_HELI | AMMUNITION_30MM_M230 | CONSUMABLE_STRATEGIC | 6480 | 6480 | 5040 | 2880 | KANDAHAR_MAIN |
| SHINDAND_HELI | AMMUNITION_HELLFIRE | CONSUMABLE_STRATEGIC | 44 | 44 | 34 | 20 | KANDAHAR_MAIN |
| SHINDAND_HELI | AMMUNITION_ROCKETS_70MM | CONSUMABLE_STRATEGIC | 653 | 653 | 538 | 365 | KANDAHAR_MAIN |
| SHINDAND_HELI | FLARES_CHAFF | CONSUMABLE_STRATEGIC | 3168 | 3168 | 2941 | 2592 | KANDAHAR_MAIN |
| TARINKOT | AMMUNITION_30MM_M230 | CONSUMABLE_STRATEGIC | 11340 | 11340 | 8820 | 5040 | KANDAHAR_MAIN |
| TARINKOT | AMMUNITION_HELLFIRE | CONSUMABLE_STRATEGIC | 76 | 76 | 60 | 34 | KANDAHAR_MAIN |
| TARINKOT | AMMUNITION_ROCKETS_70MM | CONSUMABLE_STRATEGIC | 1143 | 1143 | 941 | 639 | KANDAHAR_MAIN |
| TARINKOT | FLARES_CHAFF | CONSUMABLE_STRATEGIC | 3114 | 3114 | 2880 | 2520 | KANDAHAR_MAIN |

Die v20-Matrix ist eine Store-/Ammunition-/Equipment-Matrix. Sie erfindet keine Fuel-Startmengen; Fuel-Mengen bleiben nur dort verbindlich, wo sie in zuständigen Fuel-/Node-Artefakten ausdrücklich festgelegt sind.

## 7. Bagram Fighter A/A

AIM-120 und AIM-9 sind kein normaler Days-of-Supply-Bestand. Sie bilden einen endlichen deployment-derived Theaterbestand.

Für je 13 F-16C und 13 F-15E gilt:

```text
Initial Warehouse AIM-120 = 52
Initial Warehouse AIM-9   = 26

Fitted arrival:
F-16 AIM-120 = 26
F-15E AIM-120 = 26
F-15E AIM-9 = 26

Theater total:
AIM-120 = 104
AIM-9   = 52
```

`WAREHOUSE + FITTED` ist ein gemeinsamer endlicher strategischer Theaterbestand. Abfeuern oder Totalverlust eines Luftfahrzeugs mit fitted missiles reduziert den Theaterbestand dauerhaft. Normaler Return, Rearm oder Redeployment ist nur eine Orts-/Zustandsänderung. Es gibt keinen automatischen Off-Map-Ersatz.

## 8. Pods / Equipment

AAQ-13, AAQ-14, AAQ-33 und AAQ-28 sind strategische, rückführbare Equipment-Ressourcen.

Planungsmodell:

```text
one complete pod set per logical aircraft
+ 20% technical reserve
Initial = Target
Reorder = 80% of Target, rounded to whole units
Critical = 60% of Target, rounded to whole units
```

Daraus:

```text
Bagram AAQ-13 = 16 / 13 / 10
Bagram AAQ-14 = 16 / 13 / 10
Bagram AAQ-33 = 16 / 13 / 10
Kandahar AAQ-28 = 20 / 16 / 12
```

Normaler Return stellt Equipment wieder `AVAILABLE`. Totalverlust/Write-off reduziert den strategischen Bestand. Es gibt für Pods in diesem Foundation-Scope keine Damage-/Repair-Unterzustände.

## 9. Exakte DCS/MOOSE-Item-Mappings

Praktisch bestätigte relevante Store-Mappings:

```text
AMMUNITION_GBU31_V1 -> weapons.bombs.GBU_31
AMMUNITION_GBU31_V3 -> weapons.bombs.GBU_31_V_3B
AMMUNITION_AIM9     -> weapons.missiles.AIM_9
AMMUNITION_AIM120   -> weapons.missiles.AIM_120C
AMMUNITION_GBU12    -> weapons.bombs.GBU_12
AMMUNITION_GBU38    -> weapons.bombs.GBU_38
AMMUNITION_GBU54    -> weapons.bombs.GBU_54_V_1B
AMMUNITION_AGM65D   -> weapons.missiles.AGM_65D
AMMUNITION_LUU2B    -> weapons.bombs.LUU_2B
AMMUNITION_HELLFIRE -> weapons.missiles.AGM_114K for the validated AH-64 payload
AMMUNITION_ROCKETS_70MM -> weapons.nurs.HYDRA_70_M151 for the validated AH-64/OH-58 path
AMMUNITION_ROCKETS_70MM -> weapons.nurs.HYDRA_70_M156 for the validated A-10 path
EQUIPMENT_AAQ13 -> weapons.containers.F-15E_AAQ-13_LANTIRN
EQUIPMENT_AAQ14 -> weapons.containers.F-15E_AAQ-14_LANTIRN
EQUIPMENT_AAQ33 -> weapons.containers.AN_AAQ_33
EQUIPMENT_AAQ28 -> weapons.containers.AAQ-28_LITENING
```

Technische Nicht-Strategic-Items:

```text
F-16 external tank -> weapons.droptanks.fuel_tank_370gal
F-15E external tank -> weapons.droptanks.F-15E_Drop_Tank
AH-64 IAFS -> weapons.droptanks.{IAFS_ComboPak_100}
```

## 10. Guns und Sonderfälle

M230 und GAU-8 besitzen in der bestätigten STORAGE-Sicht keinen belastbaren direkten Round-Mirror. Strategische Round-Zählung darf deshalb nicht aus einem erfundenen STORAGE-Key abgeleitet werden.

OH-58 M3P zeigt einen Containerpfad (`OH58D_M3P_L500`), aber daraus wird keine 500-Round-Konversion abgeleitet. CH-47 M60D zeigt Container-Debit/Recredit, ebenfalls ohne Round-Konversion. UH-60A lieferte im dokumentierten Scope keine belastbare Waffen-/Round-Abbildung.

## 11. Native DCS-Transaktionen

Client Rearm und Client Refuel werden nicht parallel neu implementiert. DCS/MOOSE STORAGE führt die operative Bodencrew-Transaktion; CampaignState beobachtet/reconciled die strategische Wirkung.

Für AI materialization/return gilt ebenfalls: vorhandene AIRWING/SQUADRON-/STORAGE-Lifecycle-Pfade werden genutzt; kein paralleler Spawn-/Return-/Warehouse-Controller.

## 12. Physical loss und Forced Landing

Totalverlust reduziert strategisch Aircraft, verbleibenden Fuel und fitted Stores. Eine recoverable Forced Landing innerhalb der genehmigten Recovery-Bedingungen führt nach der festgelegten Recovery-Zeit zu einmaliger Gutschrift der tatsächlich verbleibenden recoverable Ressourcen; das Aircraft bleibt bis zum Ende der Repair-Sperrzeit gebunden.

V1-Policy:

```text
Recovery envelope: 5 km um recovery-fähige freundliche Infrastruktur
Recovery delay:    1800 s
Repair lock:        21600 s
```

Settlement muss restart-sicher und idempotent sein. Eine bereits gebuchte Resource-Gutschrift darf nach Restore nicht erneut entstehen.

## 13. Runtime-Provenienz des letzten offenen Mapping-Gates

```text
DCS: 2.9.28.26385 MT
Source/Builder commit: d95a15275f148cba02a9a2728dfbf825c274e366
BuilderVersion: FIGHTER-STORE-RUNTIME-CORRELATION-1
Bundle SHA-256: c8a19305c6c15b222233283612c0f2780b156c1e49f2c8fc1d2287a26d4e776b
Executed MIZ SHA-256: 4ede299ae1bee8d030c9d1109ce7b827b4441da374976f2e261f7676e265e7de
Internal mission SHA-256: 0f38447dade1934d63baa8e08ac536edd7865f47897f734450a8575594a19a2c
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: ec0238a8211d5804b1d1152190497b5e46ee8af45946e723abbe629efa22683f
debrief.log SHA-256: 89bca4398de33df36dffdbe67dca27b0e19a6ba330b02e5b0d927b28824f2fc5
Result: PASS
```

Damit sind F-15E STRIKE GBU-31(V)1/V3 und F-16 Deployment AIM-9 technisch geschlossen.

## 14. Implementierungsgrenze für die Mission

Die festgelegten Stocks werden nicht manuell in mehrere AIRWING-Dateien verteilt und nicht zur Laufzeit aus Excel eingelesen.

Vorgesehene Trennung:

```text
OMW_AirOpsInitialStock.lua
  -> freigegebene Initial/Target/Reorder/Critical-Daten je Node

OMW_AirOpsResourceManifest.lua
  -> Resource-ID, Klasse und DCS/MOOSE-Mapping

OMW_CampaignState.lua
  -> aktueller strategischer Zustand

kleiner CampaignState/STORAGE Initializer
  -> initialisiert zulässige operative STORAGE-Repräsentationen
```

Die produktive Initial-Stock-Lua und der Initializer sind nachgelagerte Implementierungsarbeit. Sie dürfen die hier eingefrorenen Mengen nicht stillschweigend verändern und benötigen vor Eigenlogik erneut die MOOSE-First-Prüfung.
