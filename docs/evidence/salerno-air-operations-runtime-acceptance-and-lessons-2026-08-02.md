---
document_id: OMW-EVIDENCE-SALERNO-AIR-OPS-RUNTIME-2026-08-02
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_AND_LESSONS_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - chronology of the Salerno AIRWING/SQUADRON/COMMANDER development and tests
  - classification of Salerno parking calibration, experiments, failures and deferral
  - root causes and corrections for invalid or failed Salerno test stages
  - accepted Salerno COMMANDER selection and AH-64 assignment path
  - reusable technical lessons for later airfield implementations
not_authoritative_for:
  - active project-wide ORBAT
  - exact parking compliance
  - tactical target engagement or normal mission completion
  - return, landing, recovery or persistent inventory booking
  - production theater COMMANDER design beyond the documented recommendation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/normalize-salerno-air-orbat
source_commit: 4ce9b9297f8c473ee2a789f14d187fb667d37647
validated_in_dcs: true
acceptance_branch: agent/salerno-read-only-diagnostics
acceptance_commit: dba0465afbff14fb719abdeb1f9b06e24ff24717
acceptance_mission: OMW_Template_v5_Salerno.miz
acceptance_mission_sha256: 4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
acceptance_builder_version: SAL-COMMANDER-SELECTION-18
acceptance_bundle_sha256: 75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
---

# FOB Salerno AIRWING/SQUADRON/COMMANDER – Runtime Acceptance und Lessons Learned

## 1. Zweck

Dieses Dokument bewahrt den vollständigen technischen Erkenntnisweg des Salerno-Arbeitsstrangs. Fehlversuche werden nicht entfernt oder nachträglich als Erfolg umgedeutet. Es trennt:

- belastbare Diagnose- und Kalibrierungsergebnisse;
- intern konsistente Konfiguration ohne bewiesene DCS-Realisierung;
- verunreinigte beziehungsweise ungültige Testläufe;
- korrekt erkannte FAILs;
- den abschließenden isolierten COMMANDER-PASS;
- weiterhin offene Produktionsfunktionen.

## 2. Akzeptierte Provenienz

```text
Branch:                  agent/salerno-read-only-diagnostics
Accepted source commit:  dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:          SAL-COMMANDER-SELECTION-18
Bundle SHA-256:          75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
Mission:                 OMW_Template_v5_Salerno.miz
Mission SHA-256:         4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf
DCS version:             2.9.28.26385
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA:  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Ausgangsvertrag

Mission Editor:

```text
6 Clientgruppen
5 Late-Activation-KI-Templates / 8 Template-Units
15 Luftfahrzeug-Statics
1 Warehouse-Anker
1 Funktionszone
```

MOOSE:

```text
1 AIRWING
5 SQUADRONs
20 registrierte Warehouse-Assetgruppen
5 Capability-Bereiche
10 interne Payloadtabelleneinträge
```

## 4. Read-only Diagnose

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

## 5. Mission-Editor-/TerminalID-Kalibrierung

```text
BuilderVersion: SAL-ME-TERMINAL-CALIBRATION-1
Runtime-Nodes:  44
Mappings:       32
Failures:       0
Result:         PASS
```

Vollständige Zuordnung:

```text
ME07=T08, ME08=T13, ME09=T14, ME10=T15, ME11=T16, ME12=T17,
ME14=T09, ME15=T10, ME16=T11, ME17=T12,
ME18=T21, ME19=T22, ME20=T19,
ME24=T41, ME25=T42, ME26=T43, ME27=T44, ME28=T45,
ME29=T32, ME30=T33, ME31=T34, ME32=T35, ME33=T36,
ME34=T37, ME35=T38,
ME37=T26, ME38=T27, ME39=T28,
ME41=T30, ME42=T31, ME43=T23, ME44=T24
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

Verbindliche Lehre:

```text
Mission-Editor-Parkinglabel != MOOSE TerminalID
```

Keine Mission-Editor-ID darf ungeprüft als MOOSE-`TerminalID` verwendet werden.

## 6. Type-spezifischer Parkingvertrag und Rückschlag

Arbeitsstand:

```text
SAL-TYPE-SPECIFIC-PARKING-14
```

Beispielpools:

```text
AH-64D: T28,T30
UH-60:  T33,T34,T37
OH-58D: T43,T44
CH-47:  linker Heavy-Lift-Pool
```

Der Vertrag setzte Parkingpools an SQUADRONs und synchronisierte sie zusätzlich auf bereits registrierte Warehouse-Assets. Die interne Prüfung meldete:

```text
syncedAssets=20
violations=0
```

Dies bewies ausschließlich die Konsistenz der Lua-/MOOSE-Tabellen. Visuell wurde mindestens ein Apache auf einem erwartbar geschützten beziehungsweise reservierten Spielerbereich beobachtet. Die tatsächliche Multi-Unit-Platzierung war damit nicht zuverlässig innerhalb des vorgesehenen Type-Pools nachgewiesen.

Nicht zulässige Gleichsetzungen:

```text
configured parkingIDs == realisierte Unitpositionen
contract violations=0 == tatsächliche Parking-Compliance
Safe Parking gesetzt == Clientpositionen nachweislich geschützt
```

Korrekte Bewertung:

```yaml
parking_calibration: PASS
parking_configuration_consistency: PASS
actual_spawn_compliance: NOT_ACCEPTED
operational_parking: DEFERRED
```

## 7. Abgrenzung zum Kandahar-Parkingfehler

In Kandahar war eine konkrete Ursache nachgewiesen worden: nach der Assetregistrierung geänderte SQUADRON-ParkingIDs wurden nicht automatisch in bereits registrierte Assets übernommen. Die dortige Lösung synchronisierte die Assetlisten nachträglich.

Salerno Stage 14 enthielt diese Synchronisierung bereits und meldete zwanzig synchronisierte Assets. Der reine Kandahar-Stale-Asset-Fehler erklärt Salerno daher nicht vollständig.

```text
Kandahar: nachgewiesener Stale-Asset-Parkingfehler
Salerno: Assetlisten synchron, tatsächliche Multi-Unit-Platzierung dennoch unzuverlässig
```

## 8. MOOSE-Quellcodeerkenntnis zum Parking

Im verwendeten MOOSE-Stand folgt der Warehouse-Allocator bei vorhandenen `asset.parkingIDs` dem assetbezogenen Prüfpfad. Der generische Airbase-Blacklist-/Terminaltyp-Pfad wird in diesem Zweig nicht identisch angewandt.

Konsequenzen:

- Clientpositionen dürfen niemals in Assetpools enthalten sein;
- eine Airbase-Blacklist allein ist bei assetbezogenen Pools kein ausreichender Nachweis;
- tatsächliche Unitkoordinaten müssen nach Spawn erfasst werden;
- Gruppenposition und einzelne Unitpositionen dürfen nicht gleichgesetzt werden;
- ein belastbarer Folgeversuch benötigt Actual-Spawn-Telemetrie mit nächster Runtime-TerminalID je Unit.

## 9. Parking bewusst zurückgestellt – Stage 15

Arbeitsstand:

```text
SAL-PARKING-DEFERRED-15
```

Änderung:

- aktive Parkingmutationen aus dem Bundle entfernt;
- Parking nicht mehr als Gate für AIRWING-Start oder Dispatch verwendet;
- Kalibrierung und experimentelle Dateien erhalten;
- Funktionsprüfung auf AIRWING, SQUADRON, Capabilities, Payloads und Dispatch konzentriert.

Direkte CAS-, RECON- und LIFT-Aufträge wurden angenommen und erreichten Fortschritt. Der Lauf bestätigte die AIRWING-/SQUADRON-Grundfunktion, war wegen paralleler Missionen jedoch ungeeignet für kausale Spawn- oder Parkingzuordnung.

## 10. Ungültiger gemischter COMMANDER-Test – Stage 16

Arbeitsstand:

```text
SAL-COMMANDER-DISPATCH-16
```

Fehler:

1. Direkte CAS-, RECON- und LIFT-Aufträge liefen noch, als der COMMANDER-Test begann.
2. Eine Blackhawk erschien in der Luft und wurde zunächst dem aktuellen COMMANDER-Kontext zugerechnet.
3. Die Zeitachse zeigte, dass diese Blackhawk aus der direkten LIFT-Mission stammte.
4. Der COMMANDER-CAS-Auftrag selbst blieb `planned`.
5. Die Auswertung prüfte auf `Planned`, während MOOSE `planned` zurückgab.
6. Dadurch entstand ein sachlich falscher PASS-Marker.

```yaml
stage_16: INVALID_FAIL
blackhawk_source: DIRECT_LIFT_TEST
commander_mission_progress: false
reported_pass_marker: invalid
```

Lehren:

- keine parallelen Dispatchpfade bei kausaler Auswahlprüfung;
- Missionstyp und sichtbarer Aircrafttyp müssen zusammenpassen;
- alle Aufträge gemeinsam auf einer Zeitachse auswerten;
- Zustände vor Vergleichen normalisieren;
- PASS positiv über erwartete Ereignisse definieren.

## 11. Korrekt isolierter FAIL – Stage 17

Arbeitsstand:

```text
SAL-COMMANDER-ISOLATED-17
```

Verbesserungen:

- direkte AIRWING-Testmissionen vollständig entfernt;
- genau ein COMMANDER-CAS-Auftrag;
- `planned` und `unknown` korrekt als fehlender Fortschritt bewertet.

Ergebnis:

```text
Mission blieb planned
kein Aircraft-Spawn
FINAL status=FAIL
```

## 12. Root Cause: COMMANDER nicht gestartet

Die Prüfung von OMW-Governance, MOOSE-first-Dokumentation, akzeptiertem Jalalabad-Code, offizieller MOOSE-Dokumentation und verwendetem MOOSE-Quellcode zeigte die fehlende Zeile:

```lua
commander:Start()
```

`COMMANDER:New()` erzeugt den FSM im Zustand `NotReadyYet`. `AddAirwing()` verknüpft die Legion, startet den COMMANDER aber nicht. `AddMission()` stellt den AUFTRAG zunächst als `PLANNED` in die Queue. Erst der gestartete Statuszyklus führt `CheckMissionQueue()` aus.

Verbindliche Sequenz:

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:CanMission()
COMMANDER:AddMission()
COMMANDER:Status() / normaler Statuszyklus
```

Warum der Fehler früher hätte auffallen müssen:

- der akzeptierte Jalalabad-Code enthielt `COMMANDER:Start()`;
- `VERIFIED-METHODS.md` führte den Start als validierten Grundaufruf;
- der MOOSE-Quellcode zeigt `NotReadyYet` und den Statuszyklus nach `Start()`.

## 13. Korrigierter PASS – Stage 18

Arbeitsstand:

```text
SAL-COMMANDER-SELECTION-18
```

Ergänzungen:

- `commander:Start()`;
- Prüfung `NotReadyYet -> OnDuty`;
- `COMMANDER:CanMission()`;
- öffentlicher `COMMANDER:Status()`-Trigger zur sofortigen Ausführung des normalen Auswahlpfads;
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

```yaml
eligibility: true
selected: true
assigned_event: true
requested_event: true
ops_on_mission_event: true
progressed: true
final: PASS
```

Der Test brach den Auftrag nach dem Funktionsnachweis kontrolliert ab. Ein späterer Done-/Success-Übergang ist deshalb kein taktischer Missionserfolg. Der Debrief enthielt:

```text
graveyard = {}
```

## 14. Akzeptanzmatrix

| Bereich | Ergebnis | Grenze |
|---|---|---|
| Airbase-/Warehouse-Auflösung | PASS | FOB Salerno ID 23, Warehouse gefunden |
| Objektvertrag | PASS | Clients, Templates, Statics, Zone vollständig |
| AIRWING-Konstruktion/Start | PASS | Running |
| SQUADRON-Konstruktion/Registrierung | PASS | 5/5, 20 Gruppenassets |
| Capabilities/Payloads | PASS | CAS-Eligibility praktisch bestätigt |
| COMMANDER-Konstruktion/Start | PASS | `NotReadyYet -> OnDuty` |
| COMMANDER-Auswahl | PASS | Salerno ausgewählt |
| AH-64-Assetrekrutierung | PASS | `OpsOnMission` |
| AUFTRAG-Fortschritt | PASS | bis `started` |
| Parking-Kalibrierung | PASS | 32 Mappings, 0 Fehler |
| tatsächliche Parking-Compliance | DEFERRED | visuell nicht zuverlässig |
| taktische Zielbekämpfung | NOT TESTED | außerhalb des Harness |
| Rückkehr/Landung/Recovery | NOT TESTED | außerhalb des Harness |
| Persistenz/Verlustbuchung | NOT TESTED | außerhalb des Harness |
| OPSTRANSPORT | NOT TESTED | außerhalb des Harness |
| theaterweiter COMMANDER | NOT IMPLEMENTED | lokaler Test-COMMANDER בלבד |

## 15. Verbindliche Lessons Learned

1. Dokumentation und tatsächlicher MOOSE-Quellcode sind vor jeder eigenen Implementierung zu prüfen.
2. Ein bekannter funktionierender Referenzknoten ist zeilenweise gegen neue Initialisierungssequenzen zu vergleichen.
3. Kalibrierung, Konfigurationskonsistenz und tatsächliche DCS-Realisierung sind getrennte Acceptance-Ebenen.
4. Mehrere Missionen dürfen nicht parallel laufen, wenn Auswahl, Aircrafttyp, Spawn oder Parking kausal geprüft werden.
5. Sichtbeobachtung benötigt Zuordnung über Zeitachse, Mission, Asset-ID und Unit-Telemetrie.
6. Zustände sind zu normalisieren; PASS verlangt positive erwartete Ereignisse.
7. FAIL-Berichte und ungültige Teststände bleiben erhalten.
8. Parking darf eine fachlich akzeptierte AIRWING-/COMMANDER-Grundfunktion nicht blockieren, wenn Parking ausdrücklich aus dem Acceptance-Scope entfernt wurde.
9. Produktionsarchitektur soll später genau einen theaterweiten BLUE COMMANDER verwenden; lokale COMMANDER-Objekte bleiben Test-Fixtures.
10. Das nächste Flugplatzinkrement muss jeden Test mit exakt einer Fragestellung und ohne konkurrierenden Dispatchpfad durchführen.

## 16. Weiterhin offene Arbeit

- Actual-Spawn-Telemetrie je Unit einschließlich nächster Runtime-TerminalID;
- genaue Parking- und Cold-Ground-Spawn-Acceptance;
- taktische Zielbekämpfung und normaler Missionsabschluss;
- Rückkehr, Landung und Recovery;
- persistente Bestands-, Verlust- und Rückgabebuchung;
- OPSTRANSPORT;
- Multiplayer- und Langzeittest;
- theaterweiter Produktions-COMMANDER.
