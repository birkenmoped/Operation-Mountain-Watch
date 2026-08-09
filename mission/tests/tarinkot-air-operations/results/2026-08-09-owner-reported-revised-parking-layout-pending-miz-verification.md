---
document_id: OMW-TEST-TKOT-REVISED-PARKING-LAYOUT-OWNER-REPORT-2026-08-09
status: PLANNED
document_class: OWNER_REPORT_AND_VERIFICATION_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - owner-reported Tarinkot Mission Editor geometry changes on 2026-08-09
  - intended aircraft-family parking labels pending MIZ verification
  - required verification before revised Lua parking pools are implemented
not_authoritative_for:
  - verified contents or hash of the revised MIZ
  - final DCS or MOOSE TerminalID mapping for C21-H
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

# Tarinkot – gemeldetes neues Parking-Layout, MIZ-Prüfung ausstehend

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

## 2. Abgleich mit der vorhandenen ME-/TerminalID-Kalibrierung

Die bisherige G6A2-Kalibrierung und die akzeptierten G6B-Ergebnisse belegen derzeit:

| Familie | ME-Label | bekannte MOOSE-/DCS-TerminalID | Evidenzstand | Bewertung für das neue Layout |
|---|---|---:|---|---|
| AH-64 | `C01-H` | `20` | G5/G6A2 kalibriert | ID bekannt; bisher als Clientplatz hart ausgeschlossen |
| AH-64 | `C21-H` | unbekannt | keine gespeicherte belastbare Zuordnung | aus der aktualisierten MIZ zu ermitteln |
| UH-60 | `C11-H` | `23` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |
| UH-60 | `C12-H` | `27` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |
| UH-60 | `C14-H` | `30` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |
| CH-47 | `C08-H` | `32` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |
| CH-47 | `C09-H` | `29` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |
| CH-47 | `C10-H` | `10` | G6A2 kalibriert, G6B platziert | Mapping bekannt; Geometrie erneut zu prüfen |

Sieben Labels besitzen damit eine dokumentierte ID-Zuordnung. Der neue AH-64-Pool
ist trotzdem nicht implementierbar, solange `C21-H` nicht kalibriert und der frühere
Clientvertrag für `C01-H` nicht anhand der geänderten MIZ neu bewertet wurde.

## 3. Erforderliche Prüfung der aktualisierten MIZ

Vor einer Änderung von `SQUADRON:SetParkingIDs()` sind aus der tatsächlich geänderten
Missionsdatei mindestens festzustellen:

1. Dateihash und gespeicherter Missionsstand;
2. aktuelle Client-Slots mit `airdromeId`, `parking` und ME-Label;
3. Position und TerminalID von `C21-H`;
4. Status von `C01-H`: frei oder weiterhin durch einen Client beziehungsweise ein
   anderes Missionsobjekt reserviert;
5. verbleibende Statics, Revetments, Units und Scenery-Hindernisse im Scanbereich der
   acht beabsichtigten Plätze;
6. Terminaltyp aller acht IDs, erwartet `40 / HelicopterOnly`;
7. Eindeutigkeit der acht IDs und Ausschluss aller weiterhin existierenden Client-IDs.

Die ME-Bezeichnung allein darf nicht als Lua-ParkingID verwendet werden. Für
`SQUADRON:SetParkingIDs()` sind die geprüften numerischen TerminalIDs erforderlich.

## 4. Implementierungs-Gate

```yaml
owner_report_documented: true
revised_miz_available_in_repository_workspace: false
known_label_mappings: 7
required_label_mappings: 8
C21_H_terminal_id: UNVERIFIED
C01_H_previous_client_exclusion: REQUIRES_REEVALUATION
revised_parking_pool_lua: BLOCKED_PENDING_MIZ_VERIFICATION
DCS_rerun: NOT_AUTHORIZED_BY_THIS_DOCUMENT
G8_vertical_departure: NOT_PROVEN
```

Nach erfolgreicher MIZ-Prüfung wird der neue Pool zunächst in einem getrennten
Revalidierungsstand umgesetzt. Frühere G6B-/G7-PASS-Berichte bleiben historische
Nachweise für ihre damalige Mission und werden nicht rückwirkend umgeschrieben.
