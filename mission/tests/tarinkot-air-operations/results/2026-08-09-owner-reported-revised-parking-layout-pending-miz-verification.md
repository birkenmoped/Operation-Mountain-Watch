---
document_id: OMW-TEST-TKOT-REVISED-PARKING-LAYOUT-OWNER-REPORT-2026-08-09
status: PLANNED
document_class: OWNER_REPORT_AND_VERIFICATION_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - owner-reported Tarinkot Mission Editor geometry changes on 2026-08-09
  - owner-provided complete Tarinkot ME-label to MOOSE TerminalID calibration
  - intended aircraft-family parking labels pending MIZ verification and client-conflict resolution
  - required verification before revised Lua parking pools are implemented
not_authoritative_for:
  - verified contents or hash of the revised MIZ
  - mapping independently extracted from the revised MIZ
  - removal of the former TerminalID 20 client exclusion
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

# Tarinkot – gemeldetes neues Parking-Layout und vollständige ID-Kalibrierung

## 1. Eigentümermeldung vom 9. August 2026

Der Projektinhaber meldet folgende Änderungen im Mission Editor:

- Standorte von Einheiten auf Tarinkot wurden angepasst;
- statische Revetment-Objekte wurden teilweise entfernt;
- folgende Mission-Editor-Parkplätze sollen künftig für KI-Luftfahrzeuge verwendet werden:

```yaml
AH64:
  mission_editor_labels: [C01-H, C21-H]
UH60:
  mission_editor_labels: [C11-H, C12-H, C14-H]
CH47:
  mission_editor_labels: [C08-H, C09-H, C10-H]
```

Die Meldung autorisiert die Dokumentation und technische Prüfung des geänderten
Layouts. Sie ist noch kein Nachweis, dass die Positionen frei, kollisionsfrei oder
mit der strengeren Parkplatzsuche von `WAREHOUSE:_FindParkingForAssets()` kompatibel
sind.

## 2. Vollständige vom Projektinhaber bereitgestellte Kalibrierung

Der Projektinhaber stellte am 9. August 2026 folgende vollständige Zuordnung
zwischen Mission-Editor-Bezeichnungen und MOOSE-/DCS-TerminalIDs bereit:

| ME-Parkplatz | MOOSE TerminalID | gemeldete Reservierung |
|---|---:|---|
| `C01-H` | `20` | Client AH-64 |
| `C02-H` | `5` | keine |
| `C03-H` | `17` | keine |
| `C04-H` | `21` | keine |
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

Diese Vollständigkeits- und Eindeutigkeitsprüfung bestätigt die innere
Konsistenz der bereitgestellten Tabelle. Sie beweist nicht, dass die aktuelle
Missionsdatei diese Werte enthält oder dass ein Platz frei und kollisionsfrei ist.
Die Aufteilung in 30 Nicht-Client-Anker und drei Clientreferenzen entspricht dem
gespeicherten G6A2-Ergebnis (`anchors=30`, `mapped=30`, `clientReferences=3`). Die
vollständigen damaligen Einzelzuordnungen wurden jedoch nicht im Repository
archiviert; die hier wiedergegebene Gesamttabelle bleibt daher als aktuelle
Eigentümerangabe gekennzeichnet.

## 3. Abgleich mit der vorhandenen G6A2-Kalibrierung

Die bisherige G6A2-Kalibrierung und die akzeptierten G6B-Ergebnisse belegen derzeit:

| Familie | ME-Label | bekannte MOOSE-/DCS-TerminalID | Evidenzstand | Bewertung für das neue Layout |
|---|---|---:|---|---|
| AH-64 | `C01-H` | `20` | G5/G6A2 kalibriert | ID bekannt; bisher als Clientplatz hart ausgeschlossen |
| AH-64 | `C21-H` | `19` | am 9. August 2026 vom Projektinhaber bereitgestellt | Mapping bekannt; aus aktualisierter MIZ noch nicht unabhängig bestätigt |
| UH-60 | `C11-H` | `23` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |
| UH-60 | `C12-H` | `27` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |
| UH-60 | `C14-H` | `30` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |
| CH-47 | `C08-H` | `32` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |
| CH-47 | `C09-H` | `29` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |
| CH-47 | `C10-H` | `10` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |

Alle acht beabsichtigten Labels besitzen damit eine dokumentierte ID-Zuordnung.
Der neue AH-64-Pool ist trotzdem nicht implementierbar: Die gleiche aktuelle
Eigentümermeldung bezeichnet `C01-H` weiterhin als AH-64-Clientplatz. Damit würde
`TerminalID 20` gleichzeitig einem Client und dem KI-Pool zugewiesen. Diese
Doppelbelegung verletzt den bestehenden harten Clientausschluss und den
G7-Parking-Vertrag.

## 4. Aus der Kalibrierung abgeleitete Pool-IDs

```yaml
AH64:
  requested_ME: [C01-H, C21-H]
  derived_terminal_ids: [20, 19]
  status: BLOCKED_CLIENT_CONFLICT_ON_TERMINAL_20
UH60:
  requested_ME: [C11-H, C12-H, C14-H]
  derived_terminal_ids: [23, 27, 30]
  status: MAPPING_COMPLETE_PENDING_REVISED_MIZ_GEOMETRY_CHECK
CH47:
  requested_ME: [C08-H, C09-H, C10-H]
  derived_terminal_ids: [32, 29, 10]
  status: MAPPING_COMPLETE_PENDING_REVISED_MIZ_GEOMETRY_CHECK
```

Die Reihenfolge der IDs folgt hier den vom Projektinhaber genannten
Mission-Editor-Labels. MOOSE verlangt für `SQUADRON:SetParkingIDs()` die numerischen
TerminalIDs, nicht die ME-Bezeichnungen.

## 5. Erforderliche Prüfung der aktualisierten MIZ

Vor einer Änderung von `SQUADRON:SetParkingIDs()` sind aus der tatsächlich geänderten
Missionsdatei mindestens festzustellen:

1. Dateihash und gespeicherter Missionsstand;
2. aktuelle Client-Slots mit `airdromeId`, `parking` und ME-Label;
3. unabhängige Bestätigung `C21-H -> TerminalID 19`;
4. Auflösung des Nutzungskonflikts von `C01-H`: Clientplatz oder KI-Parking,
   nicht beides;
5. verbleibende Statics, Revetments, Units und Scenery-Hindernisse im Scanbereich der
   acht beabsichtigten Plätze;
6. Terminaltyp aller acht IDs, erwartet `40 / HelicopterOnly`;
7. Eindeutigkeit der acht IDs und Ausschluss aller weiterhin existierenden Client-IDs.

Die ME-Bezeichnung allein darf nicht als Lua-ParkingID verwendet werden. Für
`SQUADRON:SetParkingIDs()` sind die geprüften numerischen TerminalIDs erforderlich.

## 6. Implementierungs-Gate

```yaml
owner_report_documented: true
revised_miz_available_in_repository_workspace: false
owner_provided_label_mappings: 33
structurally_unique_label_mappings: 33
known_requested_pool_label_mappings: 8
required_label_mappings: 8
C21_H_terminal_id: OWNER_PROVIDED_19_PENDING_MIZ_CONFIRMATION
C01_H_current_owner_label: CLIENT_AH64
C01_H_AI_pool_request: CONFLICTS_WITH_CLIENT_RESERVATION
revised_parking_pool_lua: BLOCKED_PENDING_CLIENT_CONFLICT_RESOLUTION_AND_MIZ_VERIFICATION
DCS_rerun: NOT_AUTHORIZED_BY_THIS_DOCUMENT
G8_vertical_departure: NOT_PROVEN
```

Nach erfolgreicher MIZ-Prüfung wird der neue Pool zunächst in einem getrennten
Revalidierungsstand umgesetzt. Frühere G6B-/G7-PASS-Berichte bleiben historische
Nachweise für ihre damalige Mission und werden nicht rückwirkend umgeschrieben.
