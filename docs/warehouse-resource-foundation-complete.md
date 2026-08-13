---
document_id: OMW-WAREHOUSE-RESOURCE-FOUNDATION-COMPLETE
status: BINDING_PROJECT_DECISION
document_class: ARCHITECTURE_AND_ACCEPTANCE_SYNTHESIS
owning_policy: OMW-GOV-001
authoritative_for:
  - consolidated Warehouse and CampaignState resource-foundation decisions
  - final AirOps initial strategic store stocks for the documented foundation scope
  - resource ownership, mapping, return, loss and replenishment semantics
  - summary of accepted STORAGE, AIRWING, fuel, weapon and recovery runtime evidence
  - implementation boundary for bringing approved stocks into the mission
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fighter-store-runtime-correlation
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Warehouse-/Resource-Foundation – vollständiger Abschlussstand

## 1. Zweck

Dieses Dokument ist die konsolidierte Abschlussdokumentation der Warehouse-/Resource-Arbeiten für den aktuellen AirOps-Foundation-Scope von Operation Mountain Watch. Es ersetzt die detaillierten Fach-, Mapping-, Test- und Acceptance-Dokumente nicht, sondern verbindet deren verbindliche Entscheidungen und praktisch bestätigte Laufzeitbefunde zu einer einzigen lesbaren Gesamtbaseline.

Maßgebliche Detaildokumente bleiben insbesondere:

- `OMW-ARCH-CAMPAIGN-STATE` – `docs/04-campaign-state.md`;
- `OMW-LOGISTICS` – `docs/05-logistics.md`;
- `OMW-ARCH-AMMUNITION-RESOURCE-ID-CONTRACT` – `docs/ammunition-resource-id-contract.md`;
- `OMW-ARCH-AMMUNITION-ITEM-MAPPING-CONTRACT` – `docs/ammunition-item-mapping-contract.md`;
- `OMW-LOG-BAGRAM-FIGHTER-AA-DEPLOYMENT-STOCK` – `docs/bagram-fighter-deployment-ammunition-stock-policy.md`;
- `OMW-LOG-AIROPS-INITIAL-STOCK-FINALIZATION-2026-08-13` – `docs/evidence/air-operations-initial-stock-finalization-2026-08-13.md`;
- `OMW-ACC-FIGHTER-STORE-RUNTIME-CORRELATION-2026-08-13` – `docs/evidence/fighter-store-runtime-correlation-acceptance-2026-08-13.md`;
- `data/logistics/air-operations-initial-store-stock-v20.csv`;
- `scripts/logistics/OMW_AirOpsResourceManifest.lua`.

## 2. Abgeschlossener Scope

Für den dokumentierten Foundation-Scope sind abgeschlossen:

```text
strategic resource ownership                 CLOSED
CampaignState transaction foundation         CLOSED
fuel resource IDs and canonical unit         CLOSED
MOOSE STORAGE observation path               CLOSED
client native fuel exchange path             CLOSED
client native rearm exchange path            CLOSED
AI external-store debit/return semantics      CLOSED for tested payloads
M230/GAU-8/M3P direct-mirror boundary         CLOSED
physical aircraft loss/recovery policy        CLOSED
forced-landing recovery settlement            CLOSED
Bagram fighter finite A/A stock policy        CLOSED
fixed-wing external-tank classification       CLOSED
strategic pod/equipment classification        CLOSED
initial/target/reorder/critical store matrix  CLOSED
F-15E STRIKE GBU-31 exact item mapping        CLOSED
F-16 deployment AIM-9 exact item mapping      CLOSED
warehouse/resource foundation decision block  CLOSED
```

Dieser Abschluss bedeutet nicht, dass eine zukünftige produktive Initialisierungs- oder Missionsreservierungs-Implementierung bereits DCS-validiert wäre. Diese Implementierung ist der nächste Entwicklungsblock und muss die hier festgelegten Verträge unverändert konsumieren.

## 3. Ressourcenhoheit

### 3.1 Strategische Autorität

`CampaignState` ist alleinige strategische Autorität für Ressourcenmenge, Reservierung, Transfer, Verbrauch, Verlust und strategische Gutschrift.

```text
CampaignState
= strategic truth
```

DCS-/MOOSE-Objekte repräsentieren diese strategische Wahrheit nur operativ.

### 3.2 MOOSE WAREHOUSE / AIRWING

MOOSE `AIRWING`/`WAREHOUSE` verwaltet Aircraft-Assets, Payload-Fähigkeiten und den operativen Aircraft-Lifecycle. Ein MOOSE-WAREHOUSE erhält dadurch keine zweite strategische Munitionshoheit.

Bagram besitzt bewusst zwei AIRWING-/WAREHOUSE-Anker:

```text
AW_US_BGRM_455_AEW
-> WH_AIR_US_BAGRAM

AW_US_BGRM_TF_FALCON_10_CAB
-> WH_AIR_US_BAGRAM_ARMY
```

Diese Trennung bildet die Aircraft-/Asset-Organisation ab. Strategische Munition und Equipment werden trotzdem gemeinsam je `Node + Resource ID` gepoolt.

### 3.3 DCS/MOOSE STORAGE

MOOSE `STORAGE` ist operative Warehouse-Repräsentation und Telemetriequelle. Es darf CampaignState nicht als strategische Wahrheit überschreiben.

```text
CampaignState -> authoritative quantity/state
STORAGE       -> operational mirror / native DCS exchange / telemetry
AIRWING       -> aircraft and mission lifecycle
```

Es gibt keine dauerhaft gegeneinander arbeitenden Scheduler, die DCS-Bestände hochfrequent mit strategischen Sollwerten überschreiben.

## 4. Strategische Resource IDs

### 4.1 Fuel

```text
FUEL_JP8
FUEL_AVGAS
```

Kanonische Einheit: `kg`.

Operative MOOSE/DCS-Abbildung:

```text
FUEL_JP8   -> STORAGE.Liquid.JETFUEL
FUEL_AVGAS -> STORAGE.Liquid.GASOLINE
```

Die bisherige Fuel-Foundation belegt den einseitigen CampaignState-to-STORAGE-Sync-Pfad und native DCS-Fuel-Debit-/Return-Beobachtung. Die hier dokumentierte v20-Store-Matrix ist eine Store-/Ammunition-/Equipment-Matrix und enthält keine neu erfundenen Fuel-Startmengen. Fuel-Mengen bleiben deshalb nur dort verbindlich, wo sie in den dafür zuständigen Fuel-/Node-Artefakten ausdrücklich festgelegt sind.

### 4.2 Munition

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

### 4.3 Strategisches Mission Equipment

```text
EQUIPMENT_AAQ13
EQUIPMENT_AAQ14
EQUIPMENT_AAQ33
EQUIPMENT_AAQ28
```

Klasse: `RETURNABLE_STRATEGIC_EQUIPMENT`.

### 4.4 Weitere strategische Logistikressourcen

```text
MAINTENANCE_PARTS_LIGHT
MAINTENANCE_PARTS_HEAVY
AIRCRAFT_ENGINE_MODULE
```

Diese gehören weiterhin zur strategischen Ressourcenarchitektur, sind aber nicht Teil der aktuellen AirOps-v20-Store-Mengenmatrix.

## 5. Ressourcenklassen und Semantik

### `CONSUMABLE_STRATEGIC`

CampaignState führt die strategische Menge. Verbrauch reduziert den Bestand dauerhaft; Rückführung unbenutzter physischer Stores ist keine neue Ressource.

### `RETURNABLE_STRATEGIC` / konkrete Payload-Store-Pfade

Ein externer Store kann bei Materialisierung aus STORAGE debitiert und bei normalem unbenutztem Return nativ wieder gutgeschrieben werden. Strategisch entscheidend ist nicht der temporäre DCS-Ort, sondern ob der Store verbraucht, verloren oder zurückgeführt wurde.

### `RETURNABLE_STRATEGIC_EQUIPMENT`

Pods/Equipment sind strategische Assets:

```text
AVAILABLE
RESERVED
FITTED / IN USE
AVAILABLE after normal return
LOST after aircraft total loss / explicit write-off
```

Keine Damage-/Repair-Subzustände für Pods. Ein Pod ist strategisch verfügbar oder als Verlust abgeschrieben.

### `DEPLOYMENT_FINITE_STOCK`

Bagram-Fighter-A/A ist ein endlicher, deployment-derived Theaterbestand. Kein normaler automatischer Off-Map-Nachschub.

### `TECHNICAL_NON_STRATEGIC`

Technische DCS/STORAGE-Verfügbarkeit ohne CampaignState-Bestand. Darunter:

```text
F-16C 370-gal external tank
F-15E external tank
AH-64 IAFS ComboPak 100
```

Kein künstlicher AI-Normalreturn-Recredit.

### `TELEMETRY_ONLY`

Strategische Menge existiert, aber kein belastbarer direkter STORAGE-Round-Mirror. Verbrauch wird über Onboard-/Debrief-Telemetrie korreliert.

```text
AMMUNITION_30MM_M230
AMMUNITION_30MM_GAU8
```

### `STORE_WITHOUT_ROUND_CONVERSION`

Ein Containerpfad ist sichtbar, aber eine Container-zu-Round-Konversion ist nicht genehmigt.

```text
AMMUNITION_50CAL_M3P
CH-47 M60D container path
```

## 6. Node-Aggregation und Bestandsberechnung

Strategische Stores werden genau einmal je

```text
Node + Resource ID
```

geführt.

Es gibt keine getrennten strategischen Munitionspools pro Squadron oder Aircraft Type.

Verbindliche Berechnungsfolge:

```text
raw demand of all allowed profiles at node
-> aggregate by Node + Resource ID
-> determine pair multiple
-> at Bagram/Kandahar Main additionally apply verified logistics-pack multiple
-> round once
-> freeze Initial / Target / Reorder / Critical
```

Forward Nodes werden nicht künstlich auf vollständige Hub-Verpackungseinheiten aufgerundet. Paarweise geladene geplante Bestände bleiben gerade; tatsächliche Restbestände dürfen nach Verbrauch ungerade sein.

## 7. Finale AirOps Initial-Store-Matrix v20

Quelle der maschinenlesbaren Baseline:

```text
data/logistics/air-operations-initial-store-stock-v20.csv
```

### 7.1 Bagram

| Resource | Class | Initial | Target | Reorder | Critical | Parent |
|---|---|---:|---:|---:|---:|---|
| `AMMUNITION_AIM120` | `DEPLOYMENT_FINITE_STOCK` | 52 | 52 | 0 | 0 | `OFF_MAP` |
| `AMMUNITION_AIM9` | `DEPLOYMENT_FINITE_STOCK` | 26 | 26 | 0 | 0 | `OFF_MAP` |
| `AMMUNITION_GBU12` | `CONSUMABLE_STRATEGIC` | 102 | 102 | 84 | 36 | `OFF_MAP` |
| `AMMUNITION_GBU31_V1` | `CONSUMABLE_STRATEGIC` | 43 | 43 | 36 | 16 | `OFF_MAP` |
| `AMMUNITION_GBU31_V3` | `CONSUMABLE_STRATEGIC` | 43 | 43 | 36 | 16 | `OFF_MAP` |
| `AMMUNITION_GBU38` | `CONSUMABLE_STRATEGIC` | 216 | 216 | 180 | 84 | `OFF_MAP` |
| `AMMUNITION_GBU54` | `CONSUMABLE_STRATEGIC` | 120 | 120 | 96 | 48 | `OFF_MAP` |
| `EQUIPMENT_AAQ13` | `RETURNABLE_STRATEGIC_EQUIPMENT` | 16 | 16 | 13 | 10 | `OFF_MAP` |
| `EQUIPMENT_AAQ14` | `RETURNABLE_STRATEGIC_EQUIPMENT` | 16 | 16 | 13 | 10 | `OFF_MAP` |
| `EQUIPMENT_AAQ33` | `RETURNABLE_STRATEGIC_EQUIPMENT` | 16 | 16 | 13 | 10 | `OFF_MAP` |
| `FLARES_CHAFF` | `CONSUMABLE_STRATEGIC` | 16369 | 16369 | 14427 | 9576 | `OFF_MAP` |

### 7.2 Jalalabad

| Resource | Class | Initial | Target | Reorder | Critical | Parent |
|---|---|---:|---:|---:|---:|---|
| `AMMUNITION_30MM_M230` | `CONSUMABLE_STRATEGIC` | 7920 | 7920 | 6480 | 2880 | `BAGRAM` |
| `AMMUNITION_50CAL_M3P` | `CONSUMABLE_STRATEGIC` | 44640 | 44640 | 36000 | 14400 | `BAGRAM` |
| `AMMUNITION_HELLFIRE` | `CONSUMABLE_STRATEGIC` | 54 | 54 | 44 | 20 | `BAGRAM` |
| `AMMUNITION_ROCKETS_70MM` | `CONSUMABLE_STRATEGIC` | 1575 | 1575 | 1287 | 567 | `BAGRAM` |
| `FLARES_CHAFF` | `CONSUMABLE_STRATEGIC` | 6173 | 6173 | 5724 | 4608 | `BAGRAM` |

### 7.3 Kandahar Main

| Resource | Class | Initial | Target | Reorder | Critical | Parent |
|---|---|---:|---:|---:|---:|---|
| `AMMUNITION_30MM_GAU8` | `CONSUMABLE_STRATEGIC` | 37375 | 37375 | 33350 | 22425 | `OFF_MAP` |
| `AMMUNITION_AGM65D` | `CONSUMABLE_STRATEGIC` | 26 | 26 | 24 | 20 | `OFF_MAP` |
| `AMMUNITION_GBU12` | `CONSUMABLE_STRATEGIC` | 12 | 12 | 12 | 6 | `OFF_MAP` |
| `AMMUNITION_GBU38` | `CONSUMABLE_STRATEGIC` | 156 | 156 | 132 | 78 | `OFF_MAP` |
| `AMMUNITION_HELLFIRE` | `CONSUMABLE_STRATEGIC` | 56 | 56 | 46 | 20 | `OFF_MAP` |
| `AMMUNITION_LUU2B` | `CONSUMABLE_STRATEGIC` | 232 | 232 | 208 | 156 | `OFF_MAP` |
| `AMMUNITION_ROCKETS_70MM` | `CONSUMABLE_STRATEGIC` | 212 | 212 | 192 | 136 | `OFF_MAP` |
| `EQUIPMENT_AAQ28` | `RETURNABLE_STRATEGIC_EQUIPMENT` | 20 | 20 | 16 | 12 | `OFF_MAP` |
| `FLARES_CHAFF` | `CONSUMABLE_STRATEGIC` | 17134 | 17134 | 14994 | 9648 | `OFF_MAP` |

### 7.4 Kandahar Heliport

| Resource | Class | Initial | Target | Reorder | Critical | Parent |
|---|---|---:|---:|---:|---:|---|
| `AMMUNITION_30MM_M230` | `CONSUMABLE_STRATEGIC` | 12960 | 12960 | 10080 | 3600 | `KANDAHAR_MAIN` |
| `AMMUNITION_50CAL_M3P` | `CONSUMABLE_STRATEGIC` | 49920 | 49920 | 38400 | 14400 | `KANDAHAR_MAIN` |
| `AMMUNITION_HELLFIRE` | `CONSUMABLE_STRATEGIC` | 88 | 88 | 68 | 24 | `KANDAHAR_MAIN` |
| `AMMUNITION_ROCKETS_70MM` | `CONSUMABLE_STRATEGIC` | 2113 | 2113 | 1652 | 653 | `KANDAHAR_MAIN` |
| `FLARES_CHAFF` | `CONSUMABLE_STRATEGIC` | 13597 | 13597 | 12096 | 8352 | `KANDAHAR_MAIN` |

### 7.5 Salerno

| Resource | Class | Initial | Target | Reorder | Critical | Parent |
|---|---|---:|---:|---:|---:|---|
| `AMMUNITION_30MM_M230` | `CONSUMABLE_STRATEGIC` | 6480 | 6480 | 5040 | 2880 | `KANDAHAR_MAIN` |
| `AMMUNITION_50CAL_M3P` | `CONSUMABLE_STRATEGIC` | 12000 | 12000 | 9120 | 4800 | `KANDAHAR_MAIN` |
| `AMMUNITION_HELLFIRE` | `CONSUMABLE_STRATEGIC` | 44 | 44 | 34 | 20 | `KANDAHAR_MAIN` |
| `AMMUNITION_ROCKETS_70MM` | `CONSUMABLE_STRATEGIC` | 865 | 865 | 692 | 433 | `KANDAHAR_MAIN` |
| `FLARES_CHAFF` | `CONSUMABLE_STRATEGIC` | 4428 | 4428 | 4100 | 3600 | `KANDAHAR_MAIN` |

### 7.6 Shindand Heliport

| Resource | Class | Initial | Target | Reorder | Critical | Parent |
|---|---|---:|---:|---:|---:|---|
| `AMMUNITION_30MM_M230` | `CONSUMABLE_STRATEGIC` | 6480 | 6480 | 5040 | 2880 | `KANDAHAR_MAIN` |
| `AMMUNITION_HELLFIRE` | `CONSUMABLE_STRATEGIC` | 44 | 44 | 34 | 20 | `KANDAHAR_MAIN` |
| `AMMUNITION_ROCKETS_70MM` | `CONSUMABLE_STRATEGIC` | 653 | 653 | 538 | 365 | `KANDAHAR_MAIN` |
| `FLARES_CHAFF` | `CONSUMABLE_STRATEGIC` | 3168 | 3168 | 2941 | 2592 | `KANDAHAR_MAIN` |

### 7.7 Tarinkot

| Resource | Class | Initial | Target | Reorder | Critical | Parent |
|---|---|---:|---:|---:|---:|---|
| `AMMUNITION_30MM_M230` | `CONSUMABLE_STRATEGIC` | 11340 | 11340 | 8820 | 5040 | `KANDAHAR_MAIN` |
| `AMMUNITION_HELLFIRE` | `CONSUMABLE_STRATEGIC` | 76 | 76 | 60 | 34 | `KANDAHAR_MAIN` |
| `AMMUNITION_ROCKETS_70MM` | `CONSUMABLE_STRATEGIC` | 1143 | 1143 | 941 | 639 | `KANDAHAR_MAIN` |
| `FLARES_CHAFF` | `CONSUMABLE_STRATEGIC` | 3114 | 3114 | 2880 | 2520 | `KANDAHAR_MAIN` |

## 8. Bagram Fighter A/A – finite Theaterbestände

Verbindlicher Deploymentbestand:

```text
warehouse at start:
AIM-120 = 52
AIM-9   = 26

fitted on arrival:
F-16 AIM-120 = 26
F-15E AIM-120 = 26
F-15E AIM-9 = 26

theater total:
AIM-120 = 104
AIM-9   = 52
```

Regel:

```text
WAREHOUSE + FITTED = one finite strategic theater inventory
```

Verschuss oder Verlust mit Totalverlust des Aircraft reduziert den Theaterbestand dauerhaft. Normaler Return, Rearm oder Redeployment verschiebt Bestand nur zwischen Zuständen/Orten. Kein automatischer normaler Off-Map-Ersatz.

## 9. Exakte DCS/MOOSE Store-Mappings

### Fighter

```text
AMMUNITION_AIM120   -> weapons.missiles.AIM_120C
AMMUNITION_AIM9     -> weapons.missiles.AIM_9
AMMUNITION_GBU12    -> weapons.bombs.GBU_12
AMMUNITION_GBU38    -> weapons.bombs.GBU_38
AMMUNITION_GBU54    -> weapons.bombs.GBU_54_V_1B
AMMUNITION_GBU31_V1 -> weapons.bombs.GBU_31
AMMUNITION_GBU31_V3 -> weapons.bombs.GBU_31_V_3B
```

Der letzte Fighter-Gate vom 13.08.2026 bestätigte:

```text
F-15E STRIKE two-ship:
weapons.bombs.GBU_31      -2
weapons.bombs.GBU_31_V_3B -2

F-16 client native rearm:
weapons.missiles.AIM_9 cumulative -2
Aircraft ammo AIM_9 cumulative +2
```

### A-10C II

```text
AMMUNITION_GBU38       -> weapons.bombs.GBU_38
AMMUNITION_AGM65D      -> weapons.missiles.AGM_65D
AMMUNITION_LUU2B       -> weapons.bombs.LUU_2B
AMMUNITION_ROCKETS_70MM -> weapons.nurs.HYDRA_70_M156 for current A-10 payload
EQUIPMENT_AAQ28        -> weapons.containers.AAQ-28_LITENING
```

### AH-64D / OH-58D

```text
AMMUNITION_HELLFIRE      -> weapons.missiles.AGM_114K for current AH-64 payload
AMMUNITION_ROCKETS_70MM  -> weapons.nurs.HYDRA_70_M151 for current AH-64/OH-58 payloads
AMMUNITION_50CAL_M3P     -> weapons.containers.OH58D_M3P_L500 container path only
```

No `L500 == 500 strategic rounds` assumption is permitted.

### Strategic pods

```text
EQUIPMENT_AAQ13 -> weapons.containers.F-15E_AAQ-13_LANTIRN
EQUIPMENT_AAQ14 -> weapons.containers.F-15E_AAQ-14_LANTIRN
EQUIPMENT_AAQ33 -> weapons.containers.AN_AAQ_33
EQUIPMENT_AAQ28 -> weapons.containers.AAQ-28_LITENING
```

## 10. Gun ammunition boundary

### AH-64 M230

Real gun expenditure was observed, but no reliable direct STORAGE round mirror exists.

```text
AMMUNITION_30MM_M230
-> CampaignState strategic count
-> FLIGHTGROUP:GetAmmoTot()/debrief telemetry
-> no direct STORAGE round mapping
```

### A-10 GAU-8

Real expenditure and physical normal return were observed. Direct shell candidate items did not yield a reliable strategic mirror.

```text
AMMUNITION_30MM_GAU8
-> CampaignState strategic count
-> onboard/debrief telemetry
-> no direct STORAGE round mapping
```

### OH-58 M3P

The L500 container path is visible, but no approved container-round conversion exists.

```text
AMMUNITION_50CAL_M3P
-> CampaignState strategic count
-> current payload container path visible
-> no container-to-round conversion
```

## 11. Utility helicopter gun findings

```text
UH-60A:
GetAmmoTot = 0 in documented test scope
no weapon STORAGE delta established

CH-47F:
GetAmmoTot().Guns = 800
weapons.containers.{CH47_PORT_M60D} spawn -1 / normal return +1
weapons.containers.{CH47_STBD_M60D} spawn -1 / normal return +1
no approved round/container conversion
```

No further Utility-helicopter gun investigation is required for the closed Warehouse foundation block.

## 12. External tanks and IAFS

Observed:

```text
F-16 370-gal tank: spawn debit, no normal AI return recredit
F-15E drop tank:  spawn debit, no normal AI return recredit
AH-64 IAFS:       spawn debit, no normal return recredit
```

Owner decision:

```text
TECHNICAL_NON_STRATEGIC
no CampaignState stock
no strategic consumption
no artificial recredit
DCS/STORAGE operational availability only
```

## 13. Strategic pod policy

Planned stock equals one pod set per logical aircraft plus 20% reserve, rounded up:

```text
Bagram AAQ-13: 13 operational + 3 reserve = 16
Bagram AAQ-14: 13 operational + 3 reserve = 16
Bagram AAQ-33: 13 operational + 3 reserve = 16
Kandahar AAQ-28: 16 operational + 4 reserve = 20
```

Thresholds:

```text
Target   = 100% planned stock
Reorder  = ceil(Target * 0.80)
Critical = ceil(Target * 0.60)
```

Lifecycle:

```text
mission planned -> availability check
mission committed/assets assigned -> reserve required equipment
materialized -> reservation becomes fitted/in-use
cancel before materialization -> release reservation
normal return -> available
redeployment -> moves with aircraft to destination node
aircraft total loss -> fitted strategic equipment lost
```

Strategic equipment shortage is a hard payload/materialization constraint.

## 14. Supply topology

Strategic hubs:

```text
Bagram       -> OFF_MAP
Kandahar Main -> OFF_MAP
```

Forward-node parent topology for the current matrix:

```text
Jalalabad        <- Bagram
Kandahar Heliport <- Kandahar Main
Salerno          <- Kandahar Main
Shindand Heliport <- Kandahar Main
Tarinkot         <- Kandahar Main
```

No magical direct forward-node refill is permitted. Forward stock replenishment must follow its configured parent/logistics chain.

## 15. Runtime evidence summary

### STORAGE item visibility

`STORAGE-WEAPON-ITEM-MATRIX-1` confirmed numeric item visibility on all tested STORAGE endpoints.

### AH-64 external store debit

Observed two-ship materialization:

```text
HYDRA_70_M151 -76
AGM_114K      -4
IAFS ComboPak -2
```

### Client fuel exchange

Native DCS ground refuel/defuel changes STORAGE. OMW observes this path rather than replacing it with a parallel refuel system.

### Client rearm exchange

Native ground-crew rearm changes DCS/STORAGE items and was used for exact F-16 AIM-9 correlation.

### Airborne gun/ammo correlation

Practically confirmed real expenditure paths include A-10 GAU-8, F-16/F-15E M61 and AH-64 M230. OH-58 M3P clean predecessor evidence remains the round-telemetry reference; the later tree-collision run is not used as a clean round-return proof.

### Physical loss / forced landing / recovery

The accepted recovery foundation separates physical aircraft state from strategic resource settlement and uses restart-safe/idempotent settlement semantics. Fuel returned by a recovered physical aircraft is actual remaining fuel, not full nominal fuel.

### Final fighter gate

Provenance:

```text
DCS: 2.9.28.26385 MT
Source/Builder commit: d95a15275f148cba02a9a2728dfbf825c274e366
BuilderVersion: FIGHTER-STORE-RUNTIME-CORRELATION-1
Bundle SHA-256: c8a19305c6c15b222233283612c0f2780b156c1e49f2c8fc1d2287a26d4e776b
Executed MIZ SHA-256: 4ede299ae1bee8d030c9d1109ce7b827b4441da374976f2e261f7676e265e7de
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: ec0238a8211d5804b1d1152190497b5e46ee8af45946e723abbe629efa22683f
debrief.log SHA-256: 89bca4398de33df36dffdbe67dca27b0e19a6ba330b02e5b0d927b28824f2fc5
Result: PASS
```

## 16. Wie die festgelegten Stocks in die Mission gelangen sollen

Die Mengen sollen **nicht** manuell in jeder AIRWING-Lua dupliziert und nicht pro Squadron als eigene strategische Bestände geführt werden.

Empfohlene produktive Schichtung:

```text
1. OMW_AirOpsInitialStock.lua
   -> reine Daten
   -> Node + Resource ID + Initial/Target/Reorder/Critical + parent

2. OMW_AirOpsResourceManifest.lua
   -> Resource class
   -> canonical unit
   -> exact DCS/MOOSE STORAGE mapping
   -> return/loss/mapping semantics

3. OMW_CampaignState.lua
   -> constructs authoritative strategic node resources
   -> owns quantity/reservation/transactions

4. small MOOSE STORAGE initialization/sync adapter
   -> applies only mapped operational resources to the corresponding STORAGE
   -> verifies write result
   -> never imports STORAGE as strategic truth

5. AIRWING/SQUADRON foundations
   -> consume aircraft/payload availability
   -> do not own strategic ammunition quantities
```

### Warum eine eigenständige Lua-Datendatei sinnvoll ist

Ja: Für die Missionsintegration ist eine eigenständige Lua für die **Initial-Stock-Daten** die sauberste Lösung. DCS-Missionsskripte sollen nicht zur Laufzeit CSV/XLSX über freies Filesystem-I/O laden. Die Repository-CSV und das Workbook bleiben Planungs-/Audit-Artefakte; die Mission erhält eine deterministische, buildbare Lua-Datenrepräsentation.

Vorgeschlagener Dateiname:

```text
scripts/logistics/OMW_AirOpsInitialStock.lua
```

Diese Datei soll **keine** MOOSE- oder DCS-Aufrufe enthalten. Sie gibt ausschließlich eine Lua-Tabelle zurück.

Beispielstruktur:

```lua
return {
  BAGRAM = {
    AMMUNITION_AIM120 = { initial = 52, target = 52, reorder = 0, critical = 0, parent = "OFF_MAP" },
    AMMUNITION_AIM9 = { initial = 26, target = 26, reorder = 0, critical = 0, parent = "OFF_MAP" },
  },
}
```

Ein getrenntes kleines Initialisierungsmodul darf anschließend CampaignState und die belegten STORAGE-Mappings verbinden. Diese Trennung verhindert, dass Planungsdaten, strategische Domainlogik und MOOSE/DCS-Adapter in einer Datei vermischt werden.

### Startreihenfolge in der Mission

Die geplante Reihenfolge ist:

```text
Moose.lua
-> OMW_AirOpsInitialStock.lua
-> OMW_AirOpsResourceManifest.lua
-> OMW_CampaignState.lua
-> approved CampaignState/STORAGE initializer
-> AIRWING/SQUADRON foundations
-> higher mission orchestration
```

Die konkrete produktive Initialisierungs-Lua ist **noch nicht** als DCS-validiert zu bezeichnen. Ihre Implementierung ist der nächste Entwicklungsblock nach Integration dieser Foundation-Baseline.

## 17. Was nicht wieder geöffnet wird

Ohne neue ausdrückliche Owner-Entscheidung werden durch die Implementierung nicht neu verhandelt:

- Initial/Target/Reorder/Critical-Mengen der v20-Store-Matrix;
- `CampaignState` als strategische Autorität;
- Bagram finite A/A policy;
- GBU-31 V1/V3 Trennung;
- F-16/F-15E external tanks als `TECHNICAL_NON_STRATEGIC`;
- AAQ-13/14/28/33 als strategisches Equipment;
- M230/GAU-8 ohne direkten STORAGE-Round-Mirror;
- M3P ohne Container-to-round conversion;
- Node + Resource ID Aggregation;
- Supply parents.

## 18. Merge-/Main-Grenze

Die in diesem Branch bestätigten Runtime-Ergebnisse sind für ihre exakte Provenienz technisch akzeptiert. Repository-weite normative Wirkung entsteht gemäß `OMW-GOV-001` erst nach Integration nach `main`.

Vor einem Merge nach `main` müssen mindestens erfüllt sein:

1. Branch gegen den aktuellen `main` reconciled;
2. keine alten `PENDING_MERGE`-Frontmatterwerte auf dem resultierenden `main`;
3. `DOCUMENT-REGISTRY.md` und `SUBPROJECT-REGISTRY.md` konsistent;
4. vollständiger Diff gegen den aktuellen `main` geprüft;
5. Dokumentationsvalidator/CI erfolgreich oder jeder verbleibende Tooling-Blocker ausdrücklich dokumentiert;
6. keine ungewollte Rücknahme der 13 Commits, die `main` derzeit vor diesem Branch liegt;
7. Owner-Freigabe für Merge/Ready-for-Review.

Stand 13.08.2026 ist der aktuelle Branch gegenüber `main` nicht einfach fast-forward-fähig: er enthält einen großen gestapelten Warehouse-Entwicklungsverlauf und `main` hat zwischenzeitlich zusätzliche Commits. Daher ist vor dem Merge eine gezielte Reconciliation erforderlich; ein blindes Direkt-Merge ist nicht freigegeben.

## 19. Abschlussstatus

```text
Warehouse/Resource planning and foundation work = COMPLETE
final strategic store matrix                 = FROZEN for current scope
fighter exact runtime mappings              = VALIDATED
next work                                    = main reconciliation, then productive initial-stock integration
additional Warehouse DCS test cycle          = NOT REQUIRED for this closed block
```
