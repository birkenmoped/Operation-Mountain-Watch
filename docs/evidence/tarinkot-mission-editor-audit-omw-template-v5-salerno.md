---
document_id: OMW-EVIDENCE-TARINKOT-ME-AUDIT-OMW-TEMPLATE-V5-SALERNO
status: BINDING
owning_policy: OMW-GOV-001
document_class: MISSION_EDITOR_AUDIT
authoritative_for:
  - exact Tarinkot Mission Editor object inventory in the audited mission archive
  - exact Tarinkot client, template, static, warehouse-anchor, zone, and embedded-script names in the audited mission archive
  - source-mission and embedded-MOOSE provenance for the Tarinkot object-contract reconciliation
not_authoritative_for:
  - DCS runtime acceptance
  - MOOSE AIRWING, SQUADRON, AUFTRAG, COMMANDER, or OPSTRANSPORT behavior
  - runtime parking suitability or rotor-clearance acceptance
  - historical unit identity beyond separately cited ORBAT evidence
  - project-wide active inventory until merged into an authoritative decision document
scenario_period: 2010-08-01/2011-12-31
source_branch: agent/tarinkot-object-contract-reconciliation
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
source_mission_size_bytes: 2203812
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
evidence_state: REVIEWED
project_phase: TARINKOT_OBJECT_CONTRACT_RECONCILIATION
source_commit: PENDING_MERGE
supersedes: []
superseded_by: []
---

# Tarinkot Mission-Editor-Audit – `OMW_Template_v5_Salerno.miz`

## 1. Zweck

Dieses Dokument ersetzt für die Tarinkot-Objektvertragsarbeit den älteren Auditstand aus `OMW_Template(3).miz` als aktuelle strukturelle Missionsbeobachtung.

Die Prüfung ist ausschließlich lesend. Es wurde weder die `.miz` verändert noch Tarinkot-Lua implementiert oder eingebunden.

## 2. Provenienz

| Merkmal | Wert |
|---|---|
| Datei | `OMW_Template_v5_Salerno.miz` |
| SHA-256 | `203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5` |
| Größe | `2,203,812` Byte |
| Theater | `Afghanistan` |
| Missionsdatum | `2011-01-14` |
| Missionsstart | `55,500` Sekunden = `15:25:00` |
| eingebettete MOOSE-Datei | `l10n/DEFAULT/Moose.lua` |
| MOOSE SHA-256 | `e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915` |

Der MOOSE-Hash entspricht dem bereits für die aktuelle OMW-MOOSE-2.9.18-Baseline dokumentierten Artefakt. Diese Feststellung bestätigt nur die Dateigleichheit, nicht automatisch die Laufzeitakzeptanz eines neuen Tarinkot-Teststands.

## 3. Eingebundene Startskripte

Die Mission bindet beim Start folgende Skriptdateien ein:

1. `Moose.lua`
2. `TM01M.lua`
3. `OMW_AirOps_Jalalabad.lua`
4. `OMW_AirOps_Bagram.lua`
5. `OMW_AIROPS_KANDAHAR.lua`
6. `OMW_AirOps_Salerno_Diagnostics.lua`

Nicht vorhanden und nicht eingebunden:

```text
OMW_AirOps_Tarinkot.lua
Tarinkot-Diagnosebundle
Tarinkot-AIRWING-/SQUADRON-Runtime
Tarinkot-AUFTRAG-/COMMANDER-/OPSTRANSPORT-Runtime
```

## 4. Standortanker

### 4.1 DCS-Airbase

Die Tarinkot-Objekte referenzieren:

```yaml
dcsAirdromeId: 9
```

Der endgültige MOOSE-Airbase-Name beziehungsweise die passende `AIRBASE.Afghanistan.*`-Konstante wird in diesem Audit nicht erfunden. Er ist im späteren read-only Runtime-Diagnoseschritt aus dem tatsächlich geladenen MOOSE-/DCS-Stand zu protokollieren.

### 4.2 Technischer Warehouse-Anker

```yaml
name: WH_AIR_US_TARINKOT
type: container_20ft
category: Fortifications
unitId: 1608
groupId: 1521
x: -149179.91252612
y: -30960.324668625
```

Der Anker ist ein technisches Mission-Editor-Objekt. Er ist nicht automatisch ein historisch benanntes Lager, ein CampaignState-Depot oder ein freigegebenes Zielobjekt.

### 4.3 Native DCS-Warehouse-Konfiguration

`warehouses.airports[9]` enthält:

```yaml
coalition: BLUE
unlimitedAircrafts: true
unlimitedMunitions: true
unlimitedFuel: true
dynamicCargo: true
dynamicSpawn: false
allowHotStart: false
```

Diese nativen DCS-Werte sind nicht die OMW-Kampagnenbestandsautorität.

## 5. Tarinkot-Clients

| Gruppe | Einheit | DCS-Typ | Aufgabe | Start | Label | interne Parking-ID |
|---|---|---|---|---|---|---:|
| `CLIENT_US_TKOT_AH64D_01` | `CLIENT_US_TKOT_AH64D_01_UNIT_01` | `AH-64D_BLK_II` | `CAS` | From Parking Area | `C01-H` | `20` als Stringwert |
| `CLIENT_US_TKOT_AH64D_02` | `CLIENT_US_TKOT_AH64D_02_UNIT_01` | `AH-64D_BLK_II` | `CAS` | From Parking Area | `C05-H` | `8` |
| `CLIENT_US_TKOT_CH47F_01` | `CLIENT_US_TKOT_CH47F_01_UNIT_01` | `CH-47Fbl1` | `Transport` | From Parking Area | `C07-H` | `3` |

Alle drei Gruppen referenzieren `airdromeId = 9`.

Die Labels `C01-H`, `C05-H` und `C07-H` sind für spätere Safe-Parking- und Blacklist-Tests als harte Client-Reservierungen zu behandeln. Der Audit beweist nicht, dass andere C-, K- oder G-Labels KI-tauglich sind.

## 6. Tarinkot-AI-Seeds

### 6.1 AH-64D CAS

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
├── TPL_AIR_US_TKOT_AH64D_CAS_2SHIP_UNIT_01
└── TPL_AIR_US_TKOT_AH64D_CAS_2SHIP_UNIT_02
```

Eigenschaften:

```yaml
lateActivation: true
uncontrolled: false
task: CAS
aircraftPerGroup: 2
dcsType: AH-64D_BLK_II
initialWaypoint: Turning Point
parkingIds: none
skill: High
```

Beide Luftfahrzeuge speichern die projektweite AH-64D-CAS-Baseline:

```text
2 × M261_MK151
2 × einzelne AGM-114K auf den M299-Außenpositionen
IAFS_ComboPak_100
25 Prozent Gun
1,140 kg interner Kraftstoffwert
```

### 6.2 UH-60 MEDEVAC

```text
TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
└── TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP_UNIT_01
```

Eigenschaften:

```yaml
lateActivation: true
uncontrolled: false
aircraftPerGroup: 1
dcsType: UH-60A
initialWaypoint: Turning Point
parkingIds: none
skill: High
pylons: none
```

Wichtige Abweichung zum älteren Manifest:

```text
Es existieren keine getrennten LEAD- und COVER-Templates.
```

Ein späterer Two-Ship-MEDEVAC-Vertrag müsste daher zwei Gruppen aus demselben 1-Ship-Seed erzeugen oder nach nachgewiesener technischer Notwendigkeit einen zweiten Seed erhalten. Die Entscheidung darf erst nach Prüfung der tatsächlich eingebundenen MOOSE-2.9.18-Quellen erfolgen.

### 6.3 CH-47 Heavy Lift

```text
TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
└── TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP_UNIT_01
```

Eigenschaften:

```yaml
lateActivation: true
uncontrolled: false
aircraftPerGroup: 1
dcsType: CH-47Fbl1
initialWaypoint: Turning Point
parkingIds: none
skill: High
livery: us army dark green
```

Gespeicherte Bewaffnung:

```text
CH47_PORT_M60D
CH47_STBD_M60D
```

Wichtige Abweichung zum älteren Manifest:

```text
Der aktuelle Seed verwendet CH-47Fbl1 und nicht CH-47D.
```

## 7. Tarinkot-Statics

### 7.1 AH-64

```text
STATIC_AIR_US_TKOT_AH64_01
STATIC_AIR_US_TKOT_AH64_02
STATIC_AIR_US_TKOT_AH64_03
STATIC_AIR_US_TKOT_AH64_04
STATIC_AIR_US_TKOT_AH64_05
STATIC_AIR_US_TKOT_AH64_06
STATIC_AIR_US_TKOT_AH64_07
STATIC_AIR_US_TKOT_AH64_08
```

Typverteilung:

```text
_01 bis _06: AH-64D_BLK_II
_07:          AH-64D
_08:          AH-64D_BLK_II
```

`STATIC_AIR_US_TKOT_AH64_07` ist damit eine dokumentierte statische Typabweichung. Sie verändert weder den vorgesehenen AIRWING-Seed noch den logischen Kampagnenbestand. Eine Normalisierung im Mission Editor ist eine separate Eigentümerentscheidung und kein Vorwand für eine stillschweigende Änderung.

### 7.2 UH-60

```text
STATIC_AIR_US_TKOT_UH60_UTILITY_01
STATIC_AIR_US_TKOT_UH60_UTILITY_02
STATIC_AIR_US_TKOT_UH60_UTILITY_03
STATIC_AIR_US_TKOT_UH60_MEDEVAC_01
```

Alle vier verwenden `UH-60A`.

### 7.3 CH-47 und OH-58D

```text
keine Tarinkot-CH-47-Statics
keine Tarinkot-OH-58D-Statics
```

## 8. Direkte physische Repräsentation im Mission Editor

Late-Activation-Seeds sind Authoring-Objekte und nicht automatisch aktive Bestandsbelegung. Für die reine Objektzählung enthält die MIZ:

| Musterfamilie | Statics | Clients | Seed-Einheiten | direkte Objektanzahl |
|---|---:|---:|---:|---:|
| AH-64 | 8 | 2 | 2 | 12 |
| UH-60 | 4 | 0 | 1 | 5 |
| CH-47 | 0 | 1 | 1 | 2 |
| OH-58D | 0 | 0 | 0 | 0 |

Diese Tabelle ist keine Kampagnenbestandsrechnung. Insbesondere kann ein Seed mehrfach als MOOSE-Asset registriert werden, sofern der später geprüfte SQUADRON-Vertrag dies ausdrücklich und ohne Doppelzählung vorsieht.

## 9. Zonen

Vorhanden:

```text
OMW_LOG_NODE_TARINKOT
```

Nicht vorhanden:

```text
ZONE_AIR_US_TKOT_AH64_RAMP
ZONE_AIR_US_TKOT_UH60_RAMP
ZONE_AIR_US_TKOT_MEDEVAC_READY
ZONE_AIR_US_TKOT_CH47_READY
ZONE_AIR_US_TKOT_ROTARY_STAGING
ZONE_AIR_US_TKOT_LOGISTICS_LOAD
ZONE_AIR_US_TKOT_LOGISTICS_UNLOAD
ZONE_AIR_US_TKOT_HELO_RECOVERY
ZONE_AIR_US_TKOT_TRANSIENT_FIXED_WING
```

Nicht vorhandene Zonen werden nicht im Lua-Code simuliert oder durch erfundene Koordinaten ersetzt. Sie sind zunächst als fehlende Mission-Editor-Vertragsobjekte zu behandeln.

## 10. Festgestellte Abweichungen zum älteren Tarinkot-Baseline-Branch

| Bereich | älterer Stand | aktuelle MIZ |
|---|---|---|
| Quellmission | `OMW_Template(3).miz` | `OMW_Template_v5_Salerno.miz` |
| AH-64-Seed | `AH-64A` dokumentiert | `AH-64D_BLK_II` |
| UH-60-Seeds | Lead + Cover | ein `MEDEVAC_1SHIP`-Seed |
| CH-47-Seed | `CH-47D` dokumentiert | `CH-47Fbl1` |
| operative Zonen | erforderlich, nicht vorhanden | weiterhin nicht vorhanden |
| Tarinkot-Lua | nicht vorhanden | weiterhin nicht vorhanden |

## 11. Konsequenz für den nächsten Schritt

Dieser Audit erlaubt ausschließlich die Konsolidierung des Tarinkot-Objektvertrags.

Weiterhin gesperrt:

```text
Tarinkot-Lua-Implementierung
AIRWING-/SQUADRON-Erzeugung
Payload-Registrierung
Spawn- oder Parking-Test
AUFTRAG
COMMANDER
OPSTRANSPORT
```

Nach Annahme des Objektvertrags ist der erste zulässige Runtime-Schritt ein read-only Diagnosebundle, das Namen, Airbase-Auflösung, Warehouse-Anker, Clients, Templates, Statics, Zonen und DCS-/MOOSE-Parkingdaten nur protokolliert.
