---
document_id: OMW-TEST-TKOT-REVISED-PARKING-LAYOUT-OWNER-REPORT-2026-08-09
status: PLANNED
document_class: OWNER_DECISION_AND_IMPLEMENTATION_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - owner-confirmed Tarinkot Mission Editor geometry changes on 2026-08-09
  - owner-provided complete Tarinkot ME-label to MOOSE TerminalID calibration
  - current Tarinkot client-terminal exclusions
  - revised aircraft-family parking labels and Lua parking pools
not_authoritative_for:
  - verified contents or hash of the revised MIZ
  - mapping independently extracted from the revised MIZ
  - WAREHOUSE compatibility or successful aircraft spawning
  - G8 vertical-departure acceptance
source_branch: agent/tarinkot-revised-parking-layout
source_commit: PENDING_MERGE
validated_in_dcs: false
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
---

# Tarinkot – bestätigtes neues Parking-Layout und Lua-Vertrag

## 1. Eigentümermeldung vom 9. August 2026

Der Projektinhaber bestätigt folgende Änderungen im Mission Editor als verbindliche
Arbeitsgrundlage für den neuen Lua-Vertrag:

- Standorte von Einheiten auf Tarinkot wurden angepasst;
- statische Revetment-Objekte wurden teilweise entfernt;
- die AH-64-Clients wurden auf `C04-H` und `C05-H` verschoben;
- `C01-H` ist dadurch für KI-AH-64 freigegeben;
- folgende Mission-Editor-Parkplätze sollen künftig für KI-Luftfahrzeuge verwendet werden:

```yaml
AH64:
  mission_editor_labels: [C01-H, C21-H]
UH60:
  mission_editor_labels: [C11-H, C12-H, C14-H]
CH47:
  mission_editor_labels: [C08-H, C09-H, C10-H]
```

Diese Eigentümerentscheidung autorisiert die Umsetzung der numerischen IDs über
`SQUADRON:SetParkingIDs()`. Sie ist kein DCS-Runtimenachweis für kollisionsfreies
Spawning oder für die strengere Parkplatzsuche von
`WAREHOUSE:_FindParkingForAssets()`.

## 2. Vollständige vom Projektinhaber bereitgestellte Kalibrierung

Der Projektinhaber stellte am 9. August 2026 folgende vollständige Zuordnung
zwischen Mission-Editor-Bezeichnungen und MOOSE-/DCS-TerminalIDs bereit:

| ME-Parkplatz | MOOSE TerminalID | gemeldete Reservierung |
|---|---:|---|
| `C01-H` | `20` | KI AH-64 |
| `C02-H` | `5` | keine |
| `C03-H` | `17` | keine |
| `C04-H` | `21` | Client AH-64 |
| `C05-H` | `8` | Client AH-64 |
| `C06-H` | `34` | keine |
| `C07-H` | `3` | Client CH-47 |
| `C08-H` | `32` | keine |
| `C09-H` | `29` | keine |
| `C10-H` | `10` | keine |
| `C11-H` | `23` | keine |
| `C12-H` | `27` | keine |
| `C13-H` | `15` | keine |
| `C14-H` | `30` | keine |
| `C15-H` | `12` | keine |
| `C16-H` | `7` | keine |
| `C17-H` | `2` | keine |
| `C18-H` | `4` | keine |
| `C19-H` | `16` | keine |
| `C20-H` | `26` | keine |
| `C21-H` | `19` | keine |
| `G01` | `14` | keine |
| `G02` | `6` | keine |
| `G03` | `11` | keine |
| `K01` | `24` | keine |
| `K02` | `18` | keine |
| `K03` | `25` | keine |
| `K04` | `0` | keine |
| `K05` | `33` | keine |
| `K06` | `22` | keine |
| `K07` | `13` | keine |
| `K08` | `28` | keine |
| `K09` | `1` | keine |

Strukturelle Prüfung der bereitgestellten Tabelle:

```yaml
me_labels: 33
unique_me_labels: 33
terminal_ids: 33
unique_terminal_ids: 33
non_client_anchor_labels: 30
client_reference_labels: 3
terminal_id_range: 0-34
ids_not_present: [9, 31]
duplicate_terminal_ids: []
C21_H_terminal_id: 19
```

Diese Vollständigkeits- und Eindeutigkeitsprüfung bestätigt die innere Konsistenz der
bereitgestellten Tabelle. Die Aufteilung bleibt bei 30 Nicht-Client-Ankern und drei
Clientreferenzen; geändert wurde die Nutzung von `C01-H` und `C04-H`. Die Tabelle
ist eine verbindliche Eigentümerangabe, jedoch noch kein DCS-Runtimenachweis für
Freiheit und Kollisionsfreiheit der Positionen.

## 3. Abgleich mit der vorhandenen G6A2-Kalibrierung

Die bisherige G6A2-Kalibrierung und die akzeptierten G6B-Ergebnisse belegen derzeit:

| Familie | ME-Label | bekannte MOOSE-/DCS-TerminalID | Evidenzstand | Bewertung für das neue Layout |
|---|---|---:|---|---|
| AH-64 | `C01-H` | `20` | G5/G6A2 kalibriert; Nutzung am 9. August geändert | für KI freigegeben |
| AH-64 | `C21-H` | `19` | vom Projektinhaber bereitgestellt | für KI freigegeben |
| UH-60 | `C11-H` | `23` | G6A2 kalibriert, G6B platziert | für KI freigegeben |
| UH-60 | `C12-H` | `27` | G6A2 kalibriert, G6B platziert | für KI freigegeben |
| UH-60 | `C14-H` | `30` | G6A2 kalibriert, G6B platziert | für KI freigegeben |
| CH-47 | `C08-H` | `32` | G6A2 kalibriert, G6B platziert | für KI freigegeben |
| CH-47 | `C09-H` | `29` | G6A2 kalibriert, G6B platziert | für KI freigegeben |
| CH-47 | `C10-H` | `10` | G6A2 kalibriert, G6B platziert | für KI freigegeben |

Alle acht beabsichtigten Labels besitzen eine dokumentierte ID-Zuordnung. Der frühere
Konflikt auf TerminalID `20` ist aufgehoben: Die aktuellen AH-64-Clientausschlüsse
sind TerminalID `21` (`C04-H`) und `8` (`C05-H`). Der CH-47-Client bleibt auf
TerminalID `3` (`C07-H`).

## 4. Aus der Kalibrierung abgeleitete Pool-IDs

```yaml
AH64:
  requested_ME: [C01-H, C21-H]
  derived_terminal_ids: [20, 19]
  status: OWNER_CONFIRMED_FOR_IMPLEMENTATION
UH60:
  requested_ME: [C11-H, C12-H, C14-H]
  derived_terminal_ids: [23, 27, 30]
  status: OWNER_CONFIRMED_FOR_IMPLEMENTATION
CH47:
  requested_ME: [C08-H, C09-H, C10-H]
  derived_terminal_ids: [32, 29, 10]
  status: OWNER_CONFIRMED_FOR_IMPLEMENTATION
```

Die Reihenfolge der IDs folgt hier den vom Projektinhaber genannten
Mission-Editor-Labels. MOOSE verlangt für `SQUADRON:SetParkingIDs()` die numerischen
TerminalIDs, nicht die ME-Bezeichnungen.

## 5. Implementierter Lua-Vertrag

```lua
ah64Squadron:SetParkingIDs({ 20, 19 })
uh60Squadron:SetParkingIDs({ 23, 27, 30 })
ch47Squadron:SetParkingIDs({ 32, 29, 10 })
```

Die konkrete Projektimplementierung führt dieselben Tabellen über den jeweiligen
SQUADRON-Vertrag zu. Die harten Clientausschlüsse lauten:

```yaml
client_terminal_ids: [21, 8, 3]
```

Die ME-Bezeichnung allein wird nicht als Lua-ParkingID verwendet.

## 6. Implementierungs- und Test-Gate

```yaml
owner_report_documented: true
revised_miz_available_in_repository_workspace: false
owner_provided_label_mappings: 33
structurally_unique_label_mappings: 33
known_requested_pool_label_mappings: 8
required_label_mappings: 8
C21_H_terminal_id: OWNER_CONFIRMED_19
C01_H_current_owner_label: AI_AH64
AH64_client_labels: [C04-H, C05-H]
revised_parking_pool_lua: SOURCE_STATIC_VALIDATION_PASS_BUILDER_VALIDATION_PENDING
DCS_rerun: NOT_AUTHORIZED_BY_THIS_DOCUMENT
G8_vertical_departure: NOT_PROVEN
```

Vor einem DCS-Lauf sind Bundle, Builderguards und Dokumentation statisch zu prüfen.
Im DCS-Lauf müssen insbesondere tatsächlicher Spawn, Parkplatzzuordnung,
Kollisionsfreiheit, Rotorfreiheit und vertikaler Abflug geprüft werden. Frühere
G6B-/G7-PASS-Berichte bleiben historische Nachweise für ihre damalige Mission und
werden nicht rückwirkend umgeschrieben.
