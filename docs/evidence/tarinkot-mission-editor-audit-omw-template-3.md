---
document_id: OMW-EVIDENCE-TARINKOT-ME-AUDIT-OMW-TEMPLATE-3
status: BINDING_EVIDENCE
document_class: MISSION_EDITOR_STRUCTURAL_AUDIT
owning_policy: OMW-GOV-001
authoritative_for:
  - structural contents of the inspected OMW_Template(3).miz file
  - exact Tarinkot object names types counts and confirmed client parking identifiers in that file
  - exact technical warehouse anchor present in that file
not_authoritative_for:
  - DCS runtime acceptance
  - MOOSE AIRWING or SQUADRON acceptance
  - safe AI parking identifiers not explicitly assigned in the mission
  - historical aircraft strength
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/tarinkot-air-operations-baseline
source_mission: OMW_Template(3).miz
source_mission_sha256: 2c0d94bdece19db797aa7f6ece79c6ca38901c4b06ced69b954fc484db6f5a83
source_mission_size_bytes: 2129499
validated_in_dcs: false
---

# Tarinkot Mission-Editor-Audit – `OMW_Template(3).miz`

## 1. Prüfgegenstand und Grenze

Geprüft wurde die vom Projektinhaber bereitgestellte Missionsdatei:

```text
OMW_Template(3).miz
SHA-256: 2c0d94bdece19db797aa7f6ece79c6ca38901c4b06ced69b954fc484db6f5a83
Größe: 2.129.499 Bytes
```

Die Prüfung war eine strukturelle Auswertung der entpackten Dateien `mission` und `warehouses`. Sie bestätigt vorhandene Objekte, Namen, Typen, Zähler, Koordinaten, Late-Activation-Status und explizit gespeicherte Parking-IDs. Sie bestätigt nicht:

- einen erfolgreichen Missionsstart;
- kollisionsfreie MOOSE-Spawns;
- sichere AI-Rückkehr;
- AIRWING-/SQUADRON-Verhalten;
- AUFTRAG-Ausführung;
- Rotorabstände im laufenden DCS;
- bislang nicht explizit zugewiesene AI-Parkplätze.

## 2. Airbase- und Warehouse-Befund

Die drei Tarinkot-Clientgruppen verwenden:

```text
airdromeId = 9
```

Der DCS-Warehouse-Eintrag `airports[9]` besitzt im geprüften Stand:

```yaml
coalition: BLUE
unlimitedAircrafts: true
unlimitedMunitions: true
unlimitedFuel: true
dynamicSpawn: false
allowHotStart: false
```

Diese nativen DCS-Warehouse-Werte sind keine OMW-Bestandsentscheidung und dürfen nicht als CampaignState- oder SQUADRON-Luftfahrzeugbestand verwendet werden.

### Technischer MOOSE-Warehouse-Anker

```yaml
name: WH_AIR_US_TARINKOT
group_name: WH_AIR_US_TARINKOT
unit_name: WH_AIR_US_TARINKOT
type: container_20ft
category: Fortifications
coalition_context: BLUE mission object
x: -149179.91252612
y: -30960.324668625
heading_rad: 0.62831853071796
unitId: 1608
```

Der Anker ist vorhanden und eindeutig benannt. Seine tatsächliche Verwendbarkeit durch den gepinnten MOOSE-Stand ist noch nicht in DCS bestätigt.

## 3. Clientgruppen

| Gruppe | Unit | DCS-Typ | Skill | Aufgabe | Parking-ID | interner Parking-Wert | Airbase-ID |
|---|---|---|---|---|---|---:|---:|
| `CLIENT_US_TKOT_AH64D_01` | `CLIENT_US_TKOT_AH64D_01_UNIT_01` | `AH-64D_BLK_II` | `Client` | `CAS` | `C01-H` | 20 | 9 |
| `CLIENT_US_TKOT_AH64D_02` | `CLIENT_US_TKOT_AH64D_02_UNIT_01` | `AH-64D_BLK_II` | `Client` | `CAS` | `C05-H` | 8 | 9 |
| `CLIENT_US_TKOT_CH47F_01` | `CLIENT_US_TKOT_CH47F_01_UNIT_01` | `CH-47Fbl1` | `Client` | `Transport` | `C07-H` | 3 | 9 |

Alle drei Clientgruppen starten mit:

```text
action = From Parking Area
type = TakeOffParking
```

Nicht vorhanden sind:

```text
CLIENT_US_TKOT_CH47F_02
CLIENT_US_TKOT_UH60L_01
CLIENT_US_TKOT_UH60L_02
```

## 4. KI-Templates

| Gruppe | Units | DCS-Typ | Skill | Aufgabe | Late Activation | Parking-ID | erster Wegpunkt |
|---|---:|---|---|---|---|---|---|
| `TPL_AIR_US_TKOT_AH64D_CAS_2SHIP` | 2 | `AH-64A` | `High` | `CAS` | ja | keine | `Turning Point` |
| `TPL_AIR_US_TKOT_UH60_MEDEVAC_LEAD_1SHIP` | 1 | `UH-60A` | `High` | `Transport` | ja | keine | `Turning Point` |
| `TPL_AIR_US_TKOT_UH60_MEDEVAC_COVER_1SHIP` | 1 | `UH-60A` | `High` | `Transport` | ja | keine | `Turning Point` |
| `TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP` | 1 | `CH-47D` | `High` | `Transport` | ja | keine | `Turning Point` |

Alle vier Gruppen besitzen:

```text
uncontrolled = false
```

Die Templates sind Authoring-Seeds außerhalb regulärer Parkpositionen. Sie reservieren im Mission Editor keine Stellplätze. Direkte DCS-Aktivierung ist daher nicht als bestätigter Parking-Start zu behandeln. Die spätere MOOSE-Implementierung muss ein eigenes Safe-Parking-/Blacklist-Verfahren verwenden.

## 5. Statische Luftfahrzeuge

### AH-64-Repräsentation

Acht statische `AH-64A` sind vorhanden:

| Objekt | x | y | heading rad |
|---|---:|---:|---:|
| `STATIC_AIR_US_TKOT_AH64_01` | -148933.78654830 | -31031.483870312 | 2.1991148575129 |
| `STATIC_AIR_US_TKOT_AH64_02` | -148952.83939765 | -31047.039887200 | 2.1991148575129 |
| `STATIC_AIR_US_TKOT_AH64_03` | -149013.33661180 | -31092.045540989 | 2.1991148575129 |
| `STATIC_AIR_US_TKOT_AH64_04` | -149108.96180095 | -30961.946548983 | 5.3407075111026 |
| `STATIC_AIR_US_TKOT_AH64_05` | -149089.21447001 | -30946.885025383 | 5.3407075111026 |
| `STATIC_AIR_US_TKOT_AH64_06` | -149049.13408221 | -30915.423176086 | 5.3407075111026 |
| `STATIC_AIR_US_TKOT_AH64_07` | -149029.38675127 | -30900.780028142 | 5.3407075111026 |
| `STATIC_AIR_US_TKOT_AH64_08` | -149011.56394834 | -30886.973631508 | 5.3407075111026 |

### UH-60-Repräsentation

Vier statische `UH-60A` sind vorhanden:

| Objekt | Rolle | x | y | heading rad |
|---|---|---:|---:|---:|
| `STATIC_AIR_US_TKOT_UH60_UTILITY_01` | Utility | -148858.77238053 | -31115.439470785 | 2.1642082724730 |
| `STATIC_AIR_US_TKOT_UH60_UTILITY_02` | Utility | -148908.70063128 | -31146.670310762 | 2.1642082724730 |
| `STATIC_AIR_US_TKOT_UH60_UTILITY_03` | Utility | -149038.43649241 | -30972.192563030 | 5.3407075111026 |
| `STATIC_AIR_US_TKOT_UH60_MEDEVAC_01` | MEDEVAC | -149077.06957459 | -31003.733729065 | 5.3407075111026 |

### CH-47-Repräsentation

```text
Keine statische CH-47 in Tarinkot.
```

## 6. Bestandsbilanz des geprüften Authoring-Stands

| Muster | logischer OMW-Bestand | Statics | Client-Slots | maximal vorgesehene AI-Luftfahrzeuge | Rest bei Vollbelegung |
|---|---:|---:|---:|---:|---:|
| AH-64D-Familie | 14 | 8 | 2 | 4 | 0 |
| UH-60-Familie | 6 | 4 | 0 | 2 | 0 |
| CH-47-Familie | 2 | 0 | 1 | 1 | 0 |
| OH-58D | 0 | 0 | 0 | 0 | 0 |

Die in der Datei vorhandenen Templates sind Seeds. Für AH-64 kann derselbe Two-Ship-Seed maximal zweimal durch die spätere SQUADRON-Verwaltung materialisiert werden, sofern Bestand, globale KI-Grenze und Parking dies erlauben.

## 7. Funktionszonen

Im geprüften Missionsstand existiert keine Zone mit dem Präfix:

```text
ZONE_AIR_US_TKOT_
```

Flugplatzspezifische Funktionszonen müssen daher noch im Mission Editor angelegt, positioniert und anschließend erneut auditiert werden.

## 8. Parking-Befund

Strukturell bestätigt und hart für Clients reserviert sind:

```text
C01-H  CLIENT_US_TKOT_AH64D_01
C05-H  CLIENT_US_TKOT_AH64D_02
C07-H  CLIENT_US_TKOT_CH47F_01
```

Für die KI-Templates sind keine Parking-IDs gespeichert. Eine vollständige sichere AI-Parking-Liste kann aus dieser Datei allein nicht seriös behauptet werden, weil die manuell platzierten Statics selbst keine `parking_id` besitzen. Ihre Koordinaten sind deshalb für eine geometrische Ausschlussprüfung dokumentiert.

## 9. Abnahme dieses Audits

Der Missionseditorstand ist hinsichtlich folgender Punkte strukturell konsistent:

- acht AH-64-Statics;
- vier UH-60-Statics;
- kein CH-47-Static;
- zwei AH-64D-Clients;
- ein CH-47F-Client;
- vier korrekt benannte Late-Activation-KI-Seeds;
- eindeutiger Warehouse-Anker;
- keine rechnerische Überschreitung des lokalen Bestands bei maximal 4 AH-64-AI, 2 UH-60-AI und 1 CH-47-AI.

Offen bleiben DCS-/MOOSE-Laufzeit, Safe Parking, Rückkehr, Verlustverarbeitung, AUFTRAG-Integration und Zonen.