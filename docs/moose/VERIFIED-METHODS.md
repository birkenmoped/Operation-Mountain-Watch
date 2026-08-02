# Verifizierte MOOSE-Methoden

## 1. Zweck

Dieses Dokument ist das projektspezifische Methodenregister für praktisch geprüfte MOOSE-Aufrufe.

Ein Eintrag bedeutet nicht, dass die gesamte Klasse oder jeder denkbare Ablauf validiert ist. Er belegt nur den beschriebenen Einsatz im angegebenen OMW-Teststand.

## 2. Nachweisstände

### Jalalabad-Grundbaseline

Der Jalalabad-Complete-Node-PASS dokumentiert das beobachtete Laufzeitverhalten. Der exakte MOOSE-Upstream-Stand wurde im ursprünglichen Lauf nicht zeitgleich protokolliert; die spätere Rekonstruktion aus dem identischen Artefakt bleibt als solche gekennzeichnet.

### Salerno COMMANDER-Dispatch

Der Salerno-Stage-18-PASS besitzt vollständige Artefaktprovenienz:

```text
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA:  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS version:             2.9.28.26385
OMW branch:              agent/salerno-read-only-diagnostics
OMW source commit:       dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:          SAL-COMMANDER-SELECTION-18
Bundle SHA-256:          75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
Mission:                 OMW_Template_v5_Salerno.miz
```

## 3. AIRBASE

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `AIRBASE:FindByName(name)` | `VALIDATED` | Jalalabad und Salerno ermitteln | Erwartete AIRBASE-Wrapper gefunden |
| `airbase:GetName()` | `VALIDATED` | Diagnose und Identitätsprüfung | Namen ausgegeben |
| `airbase:GetID()` | `VALIDATED` | Diagnose und Identitätsprüfung | IDs ausgegeben |
| `airbase:SetParkingSpotBlacklist(ids)` | `VALIDATED` für Jalalabad | TerminalIDs für CH-47-Statics sperren | Jalalabad-Reservations bestätigt |

Salerno-Parking bleibt trotz erfolgreicher Terminal-ID-Kalibrierung `DEFERRED`, weil tatsächliche Multi-Unit-Spawns den konfigurierten Parking-Vertrag nicht zuverlässig einhielten.

## 4. AIRWING

| Methode / Callback | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `AIRWING:New(warehouseName, alias)` | `VALIDATED` | Jalalabad- und Salerno-AIRWING konstruieren | AIRWINGs erstellt |
| `airwing:SetAirbase(airbase)` | `VALIDATED` | Explizite Flugplatzzuordnung | Richtiger lokaler Knoten gebunden |
| `airwing:SetTakeoffCold()` | `VALIDATED` für Grundkonfiguration | Cold-Start als Standard setzen | Konfiguration ohne Fehler; konkrete Salerno-Bodenspawnrealisierung nicht Teil von Stage 18 |
| `airwing:SetSafeParkingOn()` | `VALIDATED` nur für Jalalabad-Baseline | Jalalabad-Clientpositionen schützen | Jalalabad-Grundtest ohne unerwarteten Overlap |
| `airwing:AddSquadron(squadron)` | `VALIDATED` | Squadrons anbinden | Jalalabad 4/4, Salerno 5/5 registriert |
| `airwing:NewPayload(group, amount, types, performance)` | `VALIDATED` für Registrierung | Payloads registrieren | Erwartete Payloadobjekte vorhanden; Salerno meldete zehn Definitionen |
| `airwing:GetSquadron(name)` | `VALIDATED` | Verknüpfung kontrollieren | Identisches Squadron-Objekt zurückgegeben |
| `airwing:Start()` | `VALIDATED` | Vollständig validierten Knoten starten | Jalalabad und Salerno liefen im Zustand `Running` |
| `airwing:OnAfterMissionAssign(From, Event, To, Mission, Legions)` | `VALIDATED` als Callback | COMMANDER-Übergabe diagnostizieren | Salerno-MissionAssign beobachtet |
| `airwing:OnAfterMissionRequest(From, Event, To, Mission, Assets)` | `VALIDATED` als Callback | AIRWING-Missionsanforderung diagnostizieren | Salerno-MissionRequest beobachtet |
| `airwing:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)` | `VALIDATED` als Callback | Operativ gebundene Fluggruppe erfassen | AH-64-OPSGROUP für Salerno-CAS gemeldet |

Durch Stage 18 praktisch bestätigt:

- eine COMMANDER-ausgewählte Mission wurde in der Salerno-AIRWING-Queue geführt;
- ein Asset war `OnMission: Total=1, Active=1`;
- der AUFTRAG erreichte `started`.

Nicht validiert sind taktische Zielbekämpfung, reguläre Rückkehr, Landung, Recovery und persistente Bestandsbuchung.

## 5. SQUADRON

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `SQUADRON:New(template, numberOfGroups, name)` | `VALIDATED` | Typgebundene Bestände erzeugen | Jalalabad und Salerno vollständig konstruiert |
| `squadron:SetGrouping(size)` | `VALIDATED` | Single-/Two-Ship-Gruppierung festlegen | Erwartete Gruppierung registriert |
| `squadron:SetSkill(AI.Skill.HIGH)` | `VALIDATED` für Konfiguration | AI-Skill setzen | Kein Konstruktor-/Startfehler |
| `squadron:AddMissionCapability(types, performance)` | `VALIDATED` | Missionstypen freigeben | Salerno-AH-64 wurde für CAS durch COMMANDER als geeignet erkannt |

## 6. COMMANDER

| Methode / Callback | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `COMMANDER:New(coalition, alias)` | `VALIDATED` | Blue Commander erstellen | Objekt im Zustand `NotReadyYet` erstellt |
| `commander:AddAirwing(airwing)` | `VALIDATED` | AIRWING als Legion anbinden | Salerno in `commander.legions`; Reverse-Link gesetzt |
| `commander:SetVerbosity(level)` | `VALIDATED` für Diagnose | MOOSE-Auswahllogging erhöhen | Status- und Queueausgaben erzeugt |
| `commander:Start()` | `VALIDATED` | COMMANDER-FSM aktivieren | Salerno `NotReadyYet -> OnDuty` |
| `commander:CanMission(mission)` | `VALIDATED` für isolierten CAS | Eignung der angebundenen Legions prüfen | `true` für Salerno-CAS |
| `commander:AddMission(mission)` | `VALIDATED` für isolierten CAS | CAS-AUFTRAG in COMMANDER-Queue aufnehmen | Mission zunächst `PLANNED`, anschließend ausgewählt |
| `commander:Status()` | `VALIDATED` | Öffentlichen FSM-Statuszyklus auslösen | `CheckMissionQueue()`-Pfad führte zur Auswahl |
| `commander:MissionCancel(mission)` | `VALIDATED` für Test-Cleanup | Auftrag nach Nachweiserbringung abbrechen | Aufruf erfolgreich; AIRWING anschließend ohne aktive Mission |
| `commander:OnAfterMissionAssign(From, Event, To, Mission, Legions)` | `VALIDATED` als Callback | Auswahlentscheidung protokollieren | `AW_US_SALERNO` als ausführende Legion gemeldet |
| `commander:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)` | `VALIDATED` als Callback | operative Assetbindung protokollieren | AH-64-OPSGROUP gemeldet |

Verbindliche Erkenntnis:

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:AddMission()
COMMANDER Status/CheckMissionQueue cycle
```

`New + AddAirwing + AddMission` ohne `Start()` ist unvollständig. Stage 17 blieb deshalb auf `planned`; Stage 18 bestätigte nach Korrektur den normalen Auswahl- und Rekrutierungspfad.

Noch nicht validiert:

```lua
commander:AddOpsTransport(transport)
```

## 7. AUFTRAG

| Methode / Callback | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `AUFTRAG:NewCAS(zone, altitude, speed, coordinate, heading, leg)` | `VALIDATED` für Salerno-Testgeometrie | Isolierten CAS-Auftrag erzeugen | AUFTRAG erstellt und vom COMMANDER akzeptiert |
| `mission:SetName(name)` | `VALIDATED` | Stabilen Testnamen setzen | Name in COMMANDER- und AIRWING-Queues sichtbar |
| `mission:SetRequiredAssets(min, max)` | `VALIDATED` | Genau ein Missionsasset verlangen | AIRWING meldete `Assets=1/1` |
| `mission:SetTime(start, stop)` | `VALIDATED` für Testkonfiguration | Ausführungsfenster setzen | Auftrag wurde innerhalb des Testfensters bearbeitet |
| `mission:SetDuration(seconds)` | `VALIDATED` für Konfiguration | Missionsdauer setzen | Ohne Konfigurationsfehler übernommen |
| `mission:SetReturnToLegion(true)` | `VALIDATED` für Konfiguration | Rückkehrpolicy setzen | Konfiguration akzeptiert; reguläre Recovery nicht getestet |
| `mission:SetRepeat(0)` | `VALIDATED` für Konfiguration | Wiederholung deaktivieren | Kein erneuter Auftrag im Testfenster |
| `mission:OnAfterStarted(From, Event, To)` | `VALIDATED` als Callback | Fortschritt nachweisen | `scheduled -> started` beobachtet |
| `mission:OnAfterDone(From, Event, To)` | `VALIDATED` als Callback für Cleanup | kontrolliertes Ende protokollieren | `started -> done` nach Test-Cleanup |

Beobachtete Zustandsfolge:

```text
planned -> requested -> scheduled -> started
```

Der spätere `done`-/`success`-Pfad entstand durch kontrollierten Testabbruch und beweist keine taktische Zielbekämpfung.

`AUFTRAG` bleibt insgesamt `IN_USE_PARTIAL`, weil regulärer Missionsabschluss, Zielwirkung, Rückkehr, Recovery und Verlustpfade noch offen sind.

## 8. GROUP und UNIT

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `GROUP:FindByName(name)` | `VALIDATED` | Late-Activation-Templates finden | Erwartete Templates gefunden |
| `group:GetUnits()` | `VALIDATED` | Gruppengröße und Einheiten prüfen | Erwartete 1- oder 2-Schiff-Größe bestätigt |
| `unit:GetName()` | `VALIDATED` | Diagnose | Namen ausgegeben |
| `unit:GetTypeName()` | `VALIDATED` | DCS-Typprüfung | Erwartete Luftfahrzeugtypen bestätigt |
| `UNIT:FindByName(name)` | `VALIDATED` als alternative Suche | Warehouse-Anker alternativ prüfen | Aufruf ohne Fehler |

## 9. STATIC

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `STATIC:FindByName(name, false)` | `VALIDATED` | Warehouse-Anker und sichtbare Statics prüfen | Erwartete Objekte gefunden; fehlende optionale Objekte kontrolliert behandelbar |
| `static:GetTypeName()` | `VALIDATED` | Static-Typ prüfen | Erwartete Typen bestätigt |

Wichtige Projekterkenntnis:

```lua
STATIC:FindByName(name, false)
```

ist bei erwartbar fehlenden Statics dem fehlerwerfenden Standardaufruf vorzuziehen.

## 10. ZONE

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `ZONE:FindByName(name)` | `VALIDATED` | Benannte Mission-Editor-Zonen ermitteln | Erwartete Zonen gefunden |
| `zone:GetCoordinate()` | `VALIDATED` für Salerno-CAS | Zielkoordinate an `AUFTRAG:NewCAS()` übergeben | CAS-AUFTRAG konstruiert und gestartet |

Operative Load-/Unload-, Presence- und Besitzlogik bleibt separat zu testen.

## 11. SCHEDULER

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `SCHEDULER:New(master, function, args, start)` | `VALIDATED` | Geordnete Konstruktion, Snapshots und Cleanup | Teststufen liefen ohne relevanten OMW-Timerfehler |

Feste Verzögerungen sind für Testfixtures zulässig, ersetzen in der Produktionsruntime aber keine FSM- oder Zustandsprüfung.

## 12. Interner Zugriff `_DATABASE` und Objektfelder

Verwendete Diagnosezugriffe:

```lua
_DATABASE.Templates.Groups[groupName]
commander.legions
commander.missionqueue
airwing.cohorts
airwing.payloads
airwing.missionqueue
mission.statusCommander
```

Status:

`INTERNAL_RESTRICTED`.

Diese Zugriffe dienten ausschließlich der Diagnose und Acceptance-Telemetrie. Sie sind keine allgemeine stabile Produktions-API und müssen bei einem MOOSE-Wechsel erneut geprüft werden.

## 13. Noch nicht validierte, aber vorgesehene Methoden

```lua
FLIGHTGROUP:SetOptionPreferVertical()
COMMANDER:AddOpsTransport(transport)
AIRWING:AddMission(mission) -- als produktiver Architekturpfad separat zu bewerten
FLIGHTGROUP:AddMission(mission)
ARMYGROUP:AddMission(mission)
```

## 14. Acceptance-Nachweise

### Jalalabad

```text
OMW source commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
BuilderVersion:    JBAD-AIR-OPS-COMPLETE-5
Result:            local Air Operations node OPERATIONAL / PASS
```

- [`2026-07-24-jalalabad-complete-node-pass.md`](../../mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md)

### Salerno

```text
OMW source commit: dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:    SAL-COMMANDER-SELECTION-18
Bundle SHA-256:    75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
MOOSE commit:      73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result:            isolated COMMANDER CAS selection and progress to started / PASS
```

- [`2026-08-02-salerno-commander-selection-18-pass.md`](../../mission/tests/salerno-air-operations/results/2026-08-02-salerno-commander-selection-18-pass.md)

## 15. Vorlage für neue Einträge

```text
MOOSE module/class:
Method/event:
Exact signature:
Purpose in OMW:
MOOSE branch:
MOOSE commit:
Moose.lua SHA-256:
OMW branch:
OMW commit:
Source path:
Mission:
Test case:
Observed result:
Known limitations:
Official documentation:
MOOSE source reference:
Official demo/test reference:
Status:
```
