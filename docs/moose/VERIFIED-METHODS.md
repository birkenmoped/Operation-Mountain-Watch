# Verifizierte MOOSE-Methoden

## 1. Zweck

Dieses Dokument ist das projektspezifische Methodenregister für praktisch geprüfte MOOSE-Aufrufe.

Ein Eintrag bedeutet nicht, dass die gesamte Klasse oder jeder denkbare Ablauf validiert ist. Er belegt nur den beschriebenen Einsatz im angegebenen OMW-Teststand.

## 2. Aktuelle Nachweisgrenze

Der Jalalabad-Complete-Node-PASS dokumentiert den OMW-Commit und das beobachtete Verhalten. Der exakte MOOSE-Upstream-Commit und der Hash der geladenen `Moose.lua` wurden beim ursprünglichen Test nicht erfasst.

Daher gilt für die folgenden Einträge:

```text
OMW runtime behavior: validated
Exact MOOSE upstream revision: not recorded
```

Bei der nächsten Verwendung auf einem neu festgelegten MOOSE-Stand müssen die Signaturen erneut geprüft und der MOOSE-Commit ergänzt werden.

## 3. AIRBASE

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `AIRBASE:FindByName(name)` | `VALIDATED` | Jalalabad-Wrapper ermitteln | Airbase gefunden |
| `airbase:GetName()` | `VALIDATED` | Diagnose und Identitätsprüfung | Name ausgegeben |
| `airbase:GetID()` | `VALIDATED` | Diagnose und Identitätsprüfung | ID ausgegeben |
| `airbase:SetParkingSpotBlacklist(ids)` | `VALIDATED` | TerminalIDs 23, 35, 37 und 49 für CH-47-Statics sperren | Reservations bestätigt; kein unerwarteter Overlap |

OMW-Quelle:

```text
mission/tests/jalalabad-air-operations/src/01-jalalabad-bootstrap.lua
```

## 4. AIRWING

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `AIRWING:New(warehouseName, alias)` | `VALIDATED` | Jalalabad-AIRWING mit Warehouse-Anker erstellen | AIRWING konstruiert |
| `airwing:SetAirbase(airbase)` | `VALIDATED` | Explizite Zuordnung zu Jalalabad | AIRWING an richtigen Flugplatz gebunden |
| `airwing:SetTakeoffCold()` | `VALIDATED` für Grundkonfiguration | Cold-Start als Standard setzen | Start ohne Konfigurationsfehler |
| `airwing:SetSafeParkingOn()` | `VALIDATED` | Client-Parkpositionen schützen | Kein unerwarteter AI-Spawn auf Client-Positionen |
| `airwing:AddSquadron(squadron)` | `VALIDATED` | Vier Jalalabad-Squadrons anbinden | Alle vier Squadrons über `GetSquadron()` wiedergefunden |
| `airwing:NewPayload(group, amount, types, performance)` | `VALIDATED` für Registrierung | Payloads für RECON, CAS, Transport, Land und Escort registrieren | Alle erwarteten Payloadobjekte erzeugt |
| `airwing:GetSquadron(name)` | `VALIDATED` | Verknüpfung kontrollieren | Identisches Squadron-Objekt zurückgegeben |
| `airwing:Start()` | `VALIDATED` für Grundstart | Vollständig validierten Knoten starten | AIRWING operational; keine spontane Mission |

Noch nicht durch diesen Test validiert:

- Start eines echten AUFTRAG,
- Asset-Spawn,
- Taxi/Takeoff,
- Missionserfüllung,
- Recovery,
- Verlust- und Nachschubpfade.

## 5. SQUADRON

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `SQUADRON:New(template, numberOfGroups, name)` | `VALIDATED` | OH-58D, AH-64D, UH-60 und CH-47 Bestände erzeugen | 12/4/8/8 Asset-Gruppen konstruiert |
| `squadron:SetGrouping(size)` | `VALIDATED` | Two-Ship für OH-58D/AH-64D; Single-Ship für UH-60/CH-47 | Erwartete Gruppierung registriert |
| `squadron:SetSkill(AI.Skill.HIGH)` | `VALIDATED` für Konfiguration | AI-Skill festlegen | Kein Konstruktor-/Startfehler |
| `squadron:AddMissionCapability(types, performance)` | `VALIDATED` für Registrierung | Missionstypen pro Squadron freigeben | Capability-Konfiguration akzeptiert |

OMW-Quellen:

```text
mission/tests/jalalabad-air-operations/src/06-construct-oh58d-squadron.lua
mission/tests/jalalabad-air-operations/src/07-construct-ah64d-squadron.lua
mission/tests/jalalabad-air-operations/src/08-construct-uh60-squadron.lua
mission/tests/jalalabad-air-operations/src/09-construct-ch47-squadron.lua
```

## 6. COMMANDER

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `COMMANDER:New(coalition, alias)` | `VALIDATED` | Blue Commander erstellen | Objekt erstellt |
| `commander:AddAirwing(airwing)` | `VALIDATED` | Jalalabad-AIRWING anbinden | AIRWING unter COMMANDER gestartet |
| `commander:Start()` | `VALIDATED` für Grundstart | Commander aktivieren | Stabiler Leerlauf; keine spontane Mission |

Noch nicht validiert:

```lua
commander:AddMission(mission)
commander:AddOpsTransport(transport)
```

## 7. GROUP und UNIT

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `GROUP:FindByName(name)` | `VALIDATED` | Late-Activation-Template finden | Alle fünf Templates gefunden |
| `group:GetUnits()` | `VALIDATED` | Gruppengröße und Einheiten prüfen | Erwartete 1- oder 2-Schiff-Größe bestätigt |
| `unit:GetName()` | `VALIDATED` | Diagnose | Namen ausgegeben |
| `unit:GetTypeName()` | `VALIDATED` | DCS-Typprüfung | OH58D, AH-64D_BLK_II, UH-60A und CH-47Fbl1 bestätigt |
| `UNIT:FindByName(name)` | `VALIDATED` als alternative Suche | Warehouse-Anker alternativ als UNIT prüfen | Kein Fehler; tatsächlicher Anker war verfügbar |

## 8. STATIC

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `STATIC:FindByName(name, false)` | `VALIDATED` | Warehouse-Anker und 20 sichtbare Aircraft-Statics prüfen | Fehlende optionale Objekte ohne unnötigen MOOSE-Fehler behandelbar; erwartete Statics gefunden |
| `static:GetTypeName()` | `VALIDATED` | Static-Typ prüfen | Alle erwarteten Typen bestätigt |

Wichtige Projekterkenntnis:

```lua
STATIC:FindByName(name, false)
```

ist bei erwartbar fehlenden Statics dem fehlerwerfenden Standardaufruf vorzuziehen.

## 9. ZONE

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `ZONE:FindByName(name)` | `VALIDATED` für Existenzprüfung | Elf Jalalabad-Zonen validieren | 11/11 Zonen gefunden |

Nicht validiert sind operative Load-/Unload-, Presence- oder Triggerabläufe dieser Zonen.

## 10. SCHEDULER

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `SCHEDULER:New(master, function, args, start)` | `VALIDATED` | Zeitlich geordnete Konstruktion der Testkomponenten | Alle Stufen liefen ohne relevanten OMW-Timerfehler |

Einschränkung:

Feste Startverzögerungen sind für die Testbaseline geeignet, ersetzen in produktiven Abläufen aber keine Zustands- oder Eventprüfung.

## 11. AUFTRAG-Typen

Die folgenden Werte wurden erfolgreich für Squadron-Capabilities und Payloadregistrierung verwendet:

```lua
AUFTRAG.Type.RECON
AUFTRAG.Type.CAS
AUFTRAG.Type.TROOPTRANSPORT
AUFTRAG.Type.CARGOTRANSPORT
AUFTRAG.Type.LANDATCOORDINATE
AUFTRAG.Type.GROUNDESCORT
```

Status:

`IN_USE_PARTIAL`.

Die Verwendung als Typkonstante ist bestätigt. Die Erstellung und vollständige Laufzeit eines konkreten AUFTRAG ist noch nicht validiert.

## 12. Interner Zugriff `_DATABASE`

Verwendeter Zugriff:

```lua
_DATABASE.Templates.Groups[groupName]
```

Zweck:

- unbesetzte Client-Gruppen,
- Late-Activation-Templates,
- Template-Livery

validieren, obwohl die Gruppe nicht als aktive Runtime-`GROUP` existiert.

Status:

`INTERNAL_RESTRICTED`.

Dieser Zugriff ist kein allgemeiner Projektstandard. Bei jedem MOOSE-Update ist die Struktur erneut zu prüfen. Vor einer produktiven Nutzung muss erneut nach einer öffentlichen MOOSE-Methode gesucht werden.

## 13. Noch nicht validierte, aber vorgesehene Methoden

Diese Liste ist ein Prüfauftrag und kein Nachweis:

```lua
FLIGHTGROUP:SetOptionPreferVertical()
COMMANDER:AddMission(mission)
COMMANDER:AddOpsTransport(transport)
AIRWING:AddMission(mission)
FLIGHTGROUP:AddMission(mission)
ARMYGROUP:AddMission(mission)
```

Vor Statusänderung sind Dokumentation, Quellcode, MOOSE-Version und DCS-Test erforderlich.

## 14. Acceptance-Nachweis

```text
OMW validated source commit:
6cee9a5db7abf1934d0f86bf9fdf91a0446374d0

BuilderVersion:
JBAD-AIR-OPS-COMPLETE-5

Result:
Jalalabad local Air Operations node OPERATIONAL / PASS
```

Bericht:

- [`2026-07-24-jalalabad-complete-node-pass.md`](../../mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md)

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