---
document_id: OMW-EVIDENCE-SALERNO-AIR-OPS-RUNTIME-2026-08-02
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_AND_LESSONS_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - chronology of the Salerno AIRWING/SQUADRON/COMMANDER development and tests
  - classification of Salerno parking results
  - root causes and corrections for failed or invalid Salerno stages
  - reusable technical lessons for later airfield implementations
not_authoritative_for:
  - active project-wide ORBAT
  - exact parking compliance
  - production theater COMMANDER design beyond the documented recommendation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/normalize-salerno-air-orbat
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_source_branch: agent/salerno-read-only-diagnostics
acceptance_source_commit: dba0465afbff14fb719abdeb1f9b06e24ff24717
---

# FOB Salerno AIRWING/SQUADRON/COMMANDER – Runtime Acceptance und Lessons Learned

## 1. Zweck

Dieses Dokument bewahrt den vollständigen technischen Erkenntnisweg des Salerno-Arbeitsstrangs. Es trennt:

- belastbare Kalibrierungs- und Diagnoseergebnisse;
- intern konsistente, aber nicht visuell bestätigte Konfiguration;
- ungültige oder verunreinigte Testläufe;
- korrekt erkannte FAILs;
- den abschließenden isolierten COMMANDER-PASS;
- weiterhin offene Produktionsfunktionen.

Fehlversuche werden nicht entfernt oder nachträglich als Erfolg umgedeutet. Sie sind Teil der technischen Evidenz und liefern verbindliche Regeln für folgende Flugplätze.

## 2. Akzeptierte Provenienz

```text
OMW branch:              agent/salerno-read-only-diagnostics
Accepted source commit:  dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:          SAL-COMMANDER-SELECTION-18
Bundle SHA-256:          75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
Mission:                 OMW_Template_v5_Salerno.miz
Mission SHA-256:         4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf
DCS version:             2.9.28.26385
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA:  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Ausgangsbasis

Mission-Editor-Vertrag:

```text
6 Clientgruppen
5 Late-Activation-KI-Templates / 8 Template-Units
15 Luftfahrzeug-Statics
1 Warehouse-Anker
1 Funktionszone
```

MOOSE-Vertrag:

```text
1 AIRWING
5 SQUADRONs
20 registrierte Warehouse-Assetgruppen
5 Capability-Bereiche
10 interne Payloadtabelleneinträge
```

## 4. Chronologie

### 4.1 Read-only Diagnose

Der erste technische Schritt löste ausschließlich folgende Objekte auf:

- `AIRBASE.Afghanistan.FOB_Salerno`;
- `airdromeId = 23`;
- `WH_AIR_US_SALERNO`;
- sechs Clientgruppen;
- fünf KI-Templates;
- fünfzehn Luftfahrzeug-Statics;
- `ZONE_AIR_US_SAL_CSAR_UNLOAD`;
- Runtime-Parkingnodes.

Der read-only Ansatz war richtig. Er verhinderte, dass mutierende AIRWING-, SQUADRON- oder Spawnlogik auf unbestätigten Objekt- oder Airbaseannahmen aufbaute.

### 4.2 Mission-Editor-/TerminalID-Kalibrierung

Builder:

```text
SAL-ME-TERMINAL-CALIBRATION-1
```

Ergebnis:

```text
44 Runtime-Nodes
32 eindeutige ME->TerminalID-Mappings
0 Zuordnungsfehler
COMPLETE PASS
```

Die Kalibrierung bewies, dass Mission-Editor-Parkinglabels nicht mit MOOSE-TerminalIDs gleichgesetzt werden dürfen.

Vollständige Zuordnung:

```text
7=8, 8=13, 9=14, 10=15, 11=16, 12=17,
14=9, 15=10, 16=11, 17=12,
18=21, 19=22, 20=19,
24=41, 25=42, 26=43, 27=44, 28=45,
29=32, 30=33, 31=34, 32=35, 33=36,
34=37, 35=38,
37=26, 38=27, 39=28,
41=30, 42=31, 43=23, 44=24
```

Clientpositionen:

```text
T18 = ME13 CH-47 Client
T20 = ME21 CH-47 Client
T25 = ME36 AH-64D Client
T29 = ME40 AH-64D Client
T39 = ME22 OH-58D Client
T40 = ME23 OH-58D Client
```

### 4.3 Erster Fehlerkomplex – ME-Labels als MOOSE-IDs

Frühere Parkingansätze behandelten Mission-Editor-Labels zu direkt als MOOSE-TerminalIDs. Das war technisch falsch. Die Kalibrierung ersetzte diese Annahme durch beobachtete Runtime-Zuordnungen.

Verbindliche Lehre:

```text
Keine Parking-ID aus dem Mission Editor darf ungeprüft an MOOSE übergeben werden.
```

### 4.4 Type-spezifischer Parkingvertrag

Arbeitsstand:

```text
SAL-TYPE-SPECIFIC-PARKING-14
```

Beispielpools:

```text
AH-64D: T28,T30
UH-60:  T33,T34,T37
OH-58D: T43,T44
CH-47:  LEFT_HEAVY-Pool
```

Der Vertrag setzte Parkingpools an SQUADRONs und synchronisierte sie zusätzlich auf bereits registrierte Warehouse-Assets. Die interne Prüfung meldete:

```text
syncedAssets=20
violations=0
```

Diese Prüfung bewies ausschließlich die Konsistenz der Lua-/MOOSE-Tabellen.

### 4.5 Zweiter Fehlerkomplex – Konfigurations-PASS mit Realisierungs-PASS verwechselt

Visuell wurde mindestens ein Apache auf einem erwartbar geschützten beziehungsweise reservierten Spielerbereich beobachtet. Eine Multi-Unit-Gruppe realisierte ihre Positionen nicht zuverlässig innerhalb des vorgesehenen Type-Pools.

Damit waren folgende Aussagen nicht zulässig:

```text
configured parkingIDs == realisierte Unitpositionen
contract violations=0 == tatsächliche Parking-Compliance
Safe Parking gesetzt == Clientpositionen nachweislich geschützt
```

Die korrekte Bewertung lautet:

```yaml
calibration: PASS
configuration_consistency: PASS
actual_spawn_compliance: FAIL_NOT_PROVEN
parking_acceptance: DEFERRED
```

### 4.6 Abgleich mit Kandahar

In Kandahar war eine konkrete Ursache nachgewiesen worden: SQUADRON-ParkingIDs wurden nach Assetregistrierung geändert; bereits registrierte Assets behielten kopierte ältere Listen. Die dortige Lösung synchronisierte die registrierten Assets nachträglich.

Salerno Stage 14 enthielt diese Synchronisierung bereits und meldete zwanzig synchronisierte Assets. Der reine Kandahar-Stale-Asset-Fehler erklärt Salerno daher nicht vollständig.

Verbindliche Unterscheidung:

```text
Kandahar: nachgewiesener Stale-Asset-Parkingfehler
Salerno: Assetlisten synchron, tatsächliche Multi-Unit-Platzierung trotzdem nicht zuverlässig
```

### 4.7 MOOSE-Quellcodeerkenntnis zum Parking

Im verwendeten MOOSE-Stand folgt der Warehouse-Allocator bei vorhandenen `asset.parkingIDs` dem assetbezogenen Prüfpfad. Der generische Airbase-Blacklist-/Terminaltyp-Pfad wird in diesem Zweig nicht identisch angewandt.

Konsequenzen:

- Clientpositionen dürfen niemals in Assetpools aufgenommen werden;
- eine Airbase-Blacklist allein ist bei assetbezogenen Pools kein ausreichender Sicherheitsnachweis;
- tatsächliche Unitkoordinaten müssen nach Spawn erfasst werden;
- Gruppen- und Unitpositionen dürfen nicht gleichgesetzt werden.

### 4.8 Parking wird bewusst zurückgestellt

Arbeitsstand:

```text
SAL-PARKING-DEFERRED-15
```

Änderung:

- Parkingmutationen aus dem aktiven Bundle entfernt;
- Parking nicht mehr als Gate für AIRWING-Start oder Dispatch verwendet;
- Kalibrierung und experimentelle Dateien erhalten;
- akzeptierte Funktionstests auf AIRWING/SQUADRON/COMMANDER fokussiert.

Der Rückzug des Parkinganspruchs war eine Korrektur des Acceptance-Scopes, kein Verlust der Kalibrierungsarbeit.

### 4.9 Direkter AIRWING-Dispatch

Mit deaktiviertem Parking wurden direkte CAS-, RECON- und LIFT-Aufträge an das AIRWING gegeben. Die Aufträge wurden angenommen und erreichten Fortschritt.

Bestätigt:

- AIRWING lief;
- fünf SQUADRONs waren registriert;
- Capabilities und Payloads waren nutzbar;
- direkte Missionen konnten Assets anfordern und starten.

Nicht bestätigt:

- genaue Spawnposition;
- kausale Zuordnung eines sichtbaren Luftfahrzeugs bei parallelen Aufträgen;
- isolierte Parking- oder Startart-Compliance.

### 4.10 Ungültiger gemischter COMMANDER-Test

Arbeitsstand:

```text
SAL-COMMANDER-DISPATCH-16
```

Fehler:

1. Direkte CAS-, RECON- und LIFT-Aufträge liefen noch, als der COMMANDER-Test begann.
2. Eine Blackhawk erschien in der Luft und wurde zunächst dem aktuellen Testkontext zugeordnet.
3. Die Zeitachse zeigte anschließend, dass die Blackhawk aus der direkten LIFT-Mission stammte.
4. Der COMMANDER-CAS-Auftrag selbst blieb `planned`.
5. Die Auswertung prüfte gegen `Planned`, während MOOSE `planned` zurückgab.
6. Dadurch entstand ein sachlich falscher PASS-Marker.

Bewertung:

```yaml
commander_dispatch_stage_16: INVALID_FAIL
blackhawk_source: DIRECT_LIFT_TEST
commander_mission_progress: false
reported_pass_marker: invalid
```

Lehren:

- keine parallelen Dispatchpfade bei kausaler Auswahlprüfung;
- Missionstyp und sichtbarer Aircrafttyp müssen zusammenpassen;
- Zeitachsen aller Aufträge gemeinsam auswerten;
- Zustände vor Vergleichen normalisieren;
- PASS-Bedingungen positiv definieren, nicht nur einzelne Fehlerzustände ausschließen.

### 4.11 Isolierter COMMANDER-Test

Arbeitsstand:

```text
SAL-COMMANDER-ISOLATED-17
```

Verbesserungen:

- direkte AIRWING-Testmissionen vollständig aus dem Bundle entfernt;
- nur ein COMMANDER-CAS-Auftrag;
- `planned` und `unknown` korrekt als kein Fortschritt bewertet.

Ergebnis:

```text
Mission blieb planned
kein Aircraft-Spawn
FINAL status=FAIL
```

### 4.12 Dritter Fehlerkomplex – COMMANDER konstruiert, aber nicht gestartet

Die umfassende Prüfung von:

- OMW-Governance;
- MOOSE-first-Dokumentation;
- OMW-MOOSE-Index;
- akzeptiertem Jalalabad-Code;
- offiziellem MOOSE-Quellcode am verwendeten Commit

zeigte die fehlende Zeile:

```lua
commander:Start()
```

Die erforderliche Sequenz lautet:

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:AddMission()
Status-/CheckMissionQueue-Zyklus
```

`AddAirwing()` verknüpft die Legion, startet aber den COMMANDER nicht. `AddMission()` stellt den Auftrag zunächst nur als `PLANNED` in die Queue.

Warum der Fehler früher hätte auffallen müssen:

- der akzeptierte Jalalabad-Code enthielt die korrekte Sequenz bereits;
- `VERIFIED-METHODS.md` führte `commander:Start()` als validierten Grundaufruf;
- der exakte MOOSE-Quellcode zeigt den FSM-Startzustand `NotReadyYet` und den Statuszyklus nach `Start()`.

### 4.13 Korrigierter COMMANDER-Auswahltest

Arbeitsstand:

```text
SAL-COMMANDER-SELECTION-18
```

Ergänzungen:

- `commander:Start()`;
- Prüfung `NotReadyYet -> OnDuty`;
- `COMMANDER:CanMission()`;
- expliziter öffentlicher `COMMANDER:Status()`-Trigger;
- FSM-Telemetrie für `MissionAssign`, `MissionRequest` und `OpsOnMission`;
- isolierter Auftrag;
- positive PASS-Kriterien.

Beobachtete Kette:

```text
COMMANDER OnDuty
-> CanMission true
-> mission in commander queue
-> CheckMissionQueue selection
-> MissionAssign to AW_US_SALERNO
-> AIRWING MissionRequest
-> AH-64 asset recruited
-> OpsOnMission
-> AUFTRAG started
```

Ergebnis:

```yaml
eligibility: true
selected: true
assigned_event: true
requested_event: true
ops_on_mission_event: true
progressed: true
final: PASS
```

### 4.14 Cleanup und Debrief

Der Test brach den Auftrag nach dem Nachweis kontrolliert ab. Ein späterer Done-/Success-Übergang ist deshalb kein taktischer Missionserfolg.

Debrief:

```text
graveyard = {}
```

Es wurde kein Verlust registriert.

## 5. Akzeptanzmatrix

| Bereich | Ergebnis | Grenze |
|---|---|---|
| Airbase-/Warehouse-Auflösung | PASS | FOB Salerno ID 23, Warehouse gefunden |
| Objektvertrag | PASS | Clients, Templates, Statics, Zone vollständig |
| AIRWING-Konstruktion/Start | PASS | Running |
| SQUADRON-Konstruktion/Registrierung | PASS | 5/5, 20 Gruppenassets |
| Capabilities/Payloads | PASS | CAS-Eligibility praktisch bestätigt |
| COMMANDER-Konstruktion/Start | PASS | NotReadyYet -> OnDuty |
| COMMANDER-Auswahl | PASS | Salerno ausgewählt |
| AH-64-Assetrekrutierung | PASS | OpsOnMission |
| AUFTRAG-Fortschritt | PASS | bis `started` |
| Parking-Kalibrierung | PASS | 32 Mappings |
| tatsächliche Parking-Compliance | DEFERRED | visuell nicht zuverlässig |
| taktische Zielbekämpfung | NOT TESTED | außerhalb des Harness |
| Rückkehr/Recovery | NOT TESTED | außerhalb des Harness |
| Persistenz/Verlustbuchung | NOT TESTED | außerhalb des Harness |

## 6. Verbindliche Regeln für den letzten Flugplatz

1. Erst aktuelle Hauptdokumentation und relevante Branches prüfen.
2. Exakten MOOSE-Commit und die tatsächlich geladene `Moose.lua` prüfen.
3. Read-only Objekt-, Airbase-, Warehouse- und Parkingdiagnose vor Mutationen.
4. ME-Parkinglabels niemals als MOOSE-TerminalIDs voraussetzen.
5. SQUADRON- und Assetgruppenanzahl explizit auseinanderhalten.
6. Nach Registration geänderte SQUADRON-Werte nicht ungeprüft als Assetwerte annehmen.
7. Jeden Acceptance-Test auf einen Dispatchpfad und einen erwarteten Assettyp begrenzen.
8. MOOSE-FSMs nach dokumentierter Sequenz starten.
9. Zustände normalisieren; `planned` und `unknown` sind kein Fortschritt.
10. Konfiguration, interne Konsistenz und tatsächliche DCS-Realisierung separat bewerten.
11. FAILs und ungültige Läufe als historische Fixtures erhalten.
12. Parking nur akzeptieren, wenn jede realisierte Unitposition telemetrisch und visuell belegt ist.

## 7. Erforderliche Parking-Telemetrie für eine spätere Wiederaufnahme

Mindestens zu protokollieren:

```yaml
mission_name:
mission_type:
squadron_name:
warehouse_asset_uid:
group_name:
unit_name:
unit_type:
configured_asset_parking_ids:
configured_squadron_parking_ids:
unit_world_coordinate:
nearest_runtime_terminal_id:
mission_editor_mapping:
inside_expected_pool:
inside_client_reserved_pool:
inside_static_exclusion:
inside_left_heavy_sector:
inside_right_rotary_sector:
spawn_mode_ground_or_air:
```

Nur damit lassen sich Assetauswahl, Gruppenoffset, DCS-Relocation, Parkingdata und Fallbackpfade voneinander trennen.

## 8. Architekturfolge

Produktiv wird später genau ein theaterweiter BLUE COMMANDER empfohlen. Flugplatzmodule sollen ihre AIRWINGs bereitstellen; das COMMANDER-Modul wird danach geladen und bindet die verfügbaren AIRWINGs zentral.

Historische Acceptance-Fixtures bleiben unverändert, damit ihre Tests reproduzierbar bleiben.

## 9. Zugehörige Quellen

- [`FOB Salerno Air Operations Manifest`](../81-salerno-air-operations-manifest.md);
- [`Salerno Abschluss- und Nachfolger-Handoff`](../handoffs/2026-08-02-salerno-complete-state-and-next-airfield-handoff.md);
- `mission/tests/salerno-air-operations/README.md` auf dem Acceptance-Branch;
- Stage-17-FAIL- und Stage-18-PASS-Berichte auf dem Acceptance-Branch;
- Parking-Kalibrierungs- und experimentelle Parking-Skripte auf dem Acceptance-Branch.
