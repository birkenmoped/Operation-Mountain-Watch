---
document_id: OMW-EVIDENCE-SALERNO-AIR-OPS-RUNTIME-2026-08-02
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_AND_LESSONS_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - complete chronology of Salerno AIRWING/SQUADRON/COMMANDER development
  - classification of Parking calibration, failures and deferral
  - root causes of invalid and failed COMMANDER stages
  - reusable rules for later airfield implementations
not_authoritative_for:
  - project-wide ORBAT
  - exact Parking compliance
  - tactical CAS completion or recovery
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/salerno-read-only-diagnostics
source_commit: dba0465afbff14fb719abdeb1f9b06e24ff24717
validated_in_dcs: true
---

# Salerno Runtime Acceptance, Fehlversuche und Lessons Learned

## 1. Reproduzierbarer PASS-Stand

```text
Branch:                  agent/salerno-read-only-diagnostics
Accepted source commit:  dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:          SAL-COMMANDER-SELECTION-18
Bundle SHA-256:          75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
Mission:                 OMW_Template_v5_Salerno.miz
Mission SHA-256:         4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf
DCS:                     2.9.28.26385
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:       e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 2. Belastbare Ausgangsbasis

```text
FOB Salerno / Airbase-ID 23
WH_AIR_US_SALERNO
6 Clients
5 KI-Templates / 8 Template-Units
15 Aircraft-Statics
1 Zone
1 AIRWING
5 SQUADRONs
20 registrierte Assetgruppen
```

## 3. Parking-Kalibrierung

Die Kalibrierung `SAL-ME-TERMINAL-CALIBRATION-1` bestätigte 32 Zuordnungen bei 44 Runtime-Nodes und null Fehlern. Die Kernlehre lautet:

```text
Mission-Editor-Parkinglabel != MOOSE TerminalID
```

Besonders relevante Zuordnungen:

```text
ME24 -> T41
ME25 -> T42
ME35 -> T38
```

Client-TerminalIDs:

```text
T18, T20, T25, T29, T39, T40
```

Der vollständige Datensatz steht im Manifest und im Kalibrierungsskript.

## 4. Parking-Vertrag: intern konsistent, real nicht akzeptiert

Type-Pools wurden an SQUADRONs und an die bereits registrierten Assets synchronisiert. Die Prüfung meldete:

```text
syncedAssets=20
violations=0
```

Visuell wurde dennoch ein Apache auf einem erwartbar geschützten Spielerbereich beobachtet. Bei einer Multi-Unit-Gruppe folgte die tatsächliche Platzierung nicht zuverlässig dem erwarteten Type-Pool.

Daraus folgt:

```yaml
parking_mapping: PASS
configuration_tables: PASS
actual_unit_placement: FAIL_NOT_PROVEN
client_protection: FAIL_NOT_PROVEN
operational_parking: DEFERRED
```

Die Arbeit war nicht wertlos: Die Zuordnung und die Ausschlussdaten bleiben verwertbar. Nicht haltbar war nur der Anspruch, die Konfiguration beweise die Realisierung.

## 5. MOOSE-Parking-Erkenntnis

Bei vorhandenen `asset.parkingIDs` nutzt der verwendete Warehouse-Allocator einen assetbezogenen Prüfpfad. Der generische AIRBASE-Blacklist-/Terminaltyp-Pfad ist dabei nicht identisch.

Konsequenzen:

- keine Client-TerminalID in Assetpools;
- AIRBASE-Blacklist allein ist kein ausreichender Beweis;
- Unitpositionen nach Spawn erfassen;
- Gruppenposition und Unitposition nicht gleichsetzen;
- konfigurierten Pool, tatsächliche Koordinate und nächsten TerminalID gemeinsam protokollieren.

Die konkrete Ursache des Salerno-Multi-Unit-Fehlverhaltens bleibt offen. Kandidaten wie DCS-Relocation, relative Templateoffsets, unvollständige Parkingdata oder Fallback wurden nicht als bewiesen erklärt.

## 6. Stage 15 – Parking deferred / direkter Dispatch

`SAL-PARKING-DEFERRED-15` entfernte Parkingmutationen und Parking-Gates. Direkte CAS-, RECON- und LIFT-Aufträge wurden angenommen und erreichten Laufzeitfortschritt.

Bestätigt:

- AIRWING/SQUADRON-Grundlage;
- Capabilities und Payloads;
- direkte Missionsanforderung.

Nicht bestätigt:

- kausal eindeutige Spawnposition;
- Cold-Ground-Start;
- Parking-Compliance.

## 7. Stage 16 – gemischter Test, ungültig

`SAL-COMMANDER-DISPATCH-16` vermischte noch laufende direkte CAS-/RECON-/LIFT-Missionen mit dem COMMANDER-Test.

Folgen:

- eine Blackhawk erschien direkt in der Luft;
- die Zeitachse zeigte, dass sie aus dem direkten LIFT-Auftrag stammte;
- der COMMANDER-CAS-Auftrag blieb `planned`;
- ein case-sensitiver Vergleich behandelte `planned` fälschlich nicht als Fehler;
- ein ungültiger PASS-Marker wurde ausgegeben.

Korrekte Klassifikation:

```yaml
stage_16: INVALID
blackhawk_source: DIRECT_LIFT
commander_progress: false
reported_pass: false_positive
```

## 8. Stage 17 – isolierter FAIL

`SAL-COMMANDER-ISOLATED-17` entfernte die direkten Missionen und bewertete `planned` korrekt als FAIL. Es erschien kein Luftfahrzeug.

Der Lauf bewies nicht, dass das AIRWING ungeeignet war. Er bewies, dass der COMMANDER-Auswahlzyklus nicht lief.

## 9. Root Cause – COMMANDER nicht gestartet

Die anschließende Prüfung der OMW-Dokumentation, des akzeptierten Jalalabad-Codes und des exakten MOOSE-Quellcodes zeigte:

```lua
commander = COMMANDER:New(...)
commander:AddAirwing(airwing)
commander:Start() -- fehlte in Stage 17
```

MOOSE-Verhalten:

```text
New() -> NotReadyYet
AddAirwing() -> Legion verknüpft, COMMANDER nicht gestartet
AddMission() -> Mission als PLANNED in Queue
Start() -> OnDuty und Statuszyklus
onafterStatus() -> CheckMissionQueue()
```

Der Fehler hätte früher auffallen müssen, weil die korrekte Sequenz bereits in der OMW-Dokumentation und im Jalalabad-Referenzcode vorhanden war.

## 10. Stage 18 – isolierter COMMANDER-PASS

Korrigierte Sequenz:

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:CanMission()
COMMANDER:AddMission()
COMMANDER:Status()
```

Beobachtete Kette:

```text
NotReadyYet -> OnDuty
CanMission=true
MissionAssign -> AW_US_SALERNO
AIRWING MissionRequest
AH-64 AID-111 OpsOnMission
planned -> requested -> scheduled -> started
FINAL status=PASS
```

Der kontrollierte Abbruch nach dem Nachweis ist kein taktischer Missionserfolg. `graveyard = {}` bestätigt nur, dass kein Verlust erfasst wurde.

## 11. Akzeptanzgrenze

| Bereich | Status |
|---|---|
| Airbase/Warehouse/Objekte | PASS |
| AIRWING und fünf SQUADRONs | PASS |
| Capabilities/Payloads | PASS |
| COMMANDER Start/Eligibility/Selection | PASS |
| AH-64 Asset assignment | PASS |
| AUFTRAG bis `started` | PASS |
| Parking-Kalibrierung | PASS |
| tatsächliche Parking-Compliance | DEFERRED |
| taktische Zielbekämpfung | NOT TESTED |
| Rückkehr/Recovery/Persistenz | NOT TESTED |
| OPSTRANSPORT | NOT TESTED |

## 12. Verbindliche Lessons Learned

1. **Dokumentation zuerst:** OMW-Doku, verwendete MOOSE-Version, Quellcode und Demos vor Implementierung prüfen.
2. **Read-only vor Mutation:** Airbase, Warehouse, Templates, Clients, Statics und Zonen zuerst diagnostizieren.
3. **Parking kalibrieren:** ME-Labels nie direkt als TerminalIDs behandeln.
4. **Konfiguration ist kein Runtime-Beweis:** Tabellen-PASS und sichtbare Unitposition getrennt bewerten.
5. **Assetkopien beachten:** Nach Registrierung geänderte SQUADRON-Daten nicht automatisch als Assetdaten voraussetzen.
6. **Multi-Unit-Telemetrie:** jede Unit mit Koordinate, nächstem TerminalID und Poolprüfung erfassen.
7. **Isolierte Tests:** ein Dispatchpfad, ein Auftrag, ein erwarteter Assettyp.
8. **FSM korrekt starten:** Konstruktion und Binding ersetzen `Start()` nicht.
9. **Zustände normalisieren:** `planned` und `unknown` sind kein Fortschritt.
10. **Historische FAILs erhalten:** Fehlversuche nicht überschreiben.
11. **Test-COMMANDER abgrenzen:** lokaler Harness ist nicht theaterweite Produktion.
12. **Scope ehrlich halten:** Parking, Recovery und Persistenz bleiben offen, obwohl COMMANDER-Dispatch bestanden ist.

## 13. Spätere Parking-Telemetrie

Eine Wiederaufnahme benötigt mindestens:

```yaml
mission:
squadron:
asset_uid:
group:
unit:
type:
configured_asset_parking_ids:
configured_squadron_parking_ids:
unit_coordinate:
nearest_terminal_id:
me_mapping:
in_expected_pool:
in_client_pool:
in_static_exclusion:
spawn_mode:
```

## 14. Referenzen

- [`Salerno Manifest`](../81-salerno-air-operations-manifest.md)
- [`Salerno Abschluss-Handoff`](../handoffs/2026-08-02-salerno-complete-state-and-next-airfield-handoff.md)
- `mission/tests/salerno-air-operations/README.md`
- vollständige Ergebnisberichte unter `mission/tests/salerno-air-operations/results/`
