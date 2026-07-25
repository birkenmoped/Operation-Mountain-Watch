# Verifizierte MOOSE-Methoden

## 1. Zweck

Dieses Dokument ist das projektspezifische Methodenregister für praktisch geprüfte MOOSE-Aufrufe.

Ein Eintrag bedeutet nicht, dass die gesamte Klasse oder jeder denkbare Ablauf validiert ist. Er belegt nur den beschriebenen Einsatz im angegebenen OMW-Teststand.

## 2. Aktuelle Nachweisgrenze

Der Jalalabad-Complete-Node-PASS dokumentiert den OMW-Commit und das beobachtete Verhalten. Der exakte MOOSE-Upstream-Commit und der Hash der geladenen `Moose.lua` wurden beim ursprünglichen Test nicht erfasst.

Daher gilt für die folgenden älteren Einträge:

```text
OMW runtime behavior: validated
Exact MOOSE upstream revision: not recorded
```

Für die Phase-1-Funktionstests ab 2026-07-25 ist dagegen folgender MOOSE-Stand festgelegt:

```text
MOOSE branch: pinned project revision
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Bei jeder Verwendung auf einem anderen MOOSE-Stand müssen Signaturen und Verhalten erneut geprüft werden.

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
| `airwing:AddMission(mission)` | `RUNTIME_OBSERVED_PARTIAL` | AUFTRAG an Jalalabad-AIRWING übergeben | Assets wurden rekrutiert, gestartet und auf Mission geschickt; vollständige Abnahme je Missionstyp weiterhin testabhängig |
| `AIRWING:OnAfterLegionAssetReturned(...)` | `RUNTIME_VALIDATED` für beobachtete Rückgaben | Autoritative Freigabe eines zurückgekehrten Assets | UH-60 und CH-47 wurden nach Jalalabad-Rückkehr an das jeweilige Squadron zurückgegeben |

Noch nicht vollständig validiert:

- alle Missionstypen End-to-End;
- Verlust- und Nachschubpfade;
- parallele Missionen unter Ressourcenknappheit.

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
| `STATIC:FindByName(name, false)` | `VALIDATED` | Warehouse-Anker und sichtbare Aircraft-Statics prüfen | Fehlende optionale Objekte ohne unnötigen MOOSE-Fehler behandelbar; erwartete Statics gefunden |
| `static:GetTypeName()` | `VALIDATED` | Static-Typ prüfen | Erwartete Typen bestätigt |
| `static:IsInZone(zone)` | `RUNTIME_OBSERVED_WITH_LIMITATION` | Physische CH-47-Slingload-Zielprüfung | Ausgangsposition validierbar; nach DCS-Slingload-Aufnahme kann der ursprüngliche Static-Wrapper nicht mehr zuverlässig als fortbestehendes Zielobjekt gewertet werden |

Wichtige Projekterkenntnis:

```lua
STATIC:FindByName(name, false)
```

ist bei erwartbar fehlenden Statics dem fehlerwerfenden Standardaufruf vorzuziehen.

## 9. ZONE

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `ZONE:FindByName(name)` | `VALIDATED` für Existenzprüfung | Benannte Jalalabad-Zonen validieren | Erwartete Zonen gefunden |
| `zone:GetCoordinate()` | `SOURCE_VERIFIED_RUNTIME_PARTIAL` | Missions-, Egress- und Landezonenkoordinaten | Für OPSTRANSPORT und Routing verwendet; jeder operative Pfad bleibt separat abzunehmen |

## 10. SCHEDULER

| Methode | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `SCHEDULER:New(master, function, args, start)` | `VALIDATED` | Zeitlich geordnete Konstruktion, Polling und verzögerte Callback-Auswertung | Laufzeitpfade ohne relevanten OMW-Timerfehler beobachtet |

Einschränkung:

Feste Startverzögerungen ersetzen keine Zustands- oder Eventprüfung.

## 11. AUFTRAG-Typen und Ergebnissemantik

Verwendete Typen:

```lua
AUFTRAG.Type.RECON
AUFTRAG.Type.CAS
AUFTRAG.Type.TROOPTRANSPORT
AUFTRAG.Type.CARGOTRANSPORT
AUFTRAG.Type.LANDATCOORDINATE
AUFTRAG.Type.GROUNDESCORT
```

Status: `IN_USE_PARTIAL`.

### Ergebnissemantik

Der gepinnte MOOSE-Stand beschreibt Success- und Failure-Conditions als Bedingungen, bei deren Erfüllung der laufende Auftrag zunächst abgebrochen wird. Im AH-64-CAS-Lauf wurde entsprechend folgende reguläre Erfolgssequenz beobachtet:

```text
CANCELLED -> DONE -> SUCCESS
```

Projektentscheidung:

- `CANCELLED` ist bei normalen AUFTRAG-Missionen kein eigenständiger Fehler;
- es wird als nicht blockierender Zwischenzustand der Ergebnisauswertung behandelt;
- nur bei einem ausdrücklich auf Abbruch ausgelegten Test ist `CANCELLED` der erwartete Terminalzustand;
- `FAILED` wird nur dann als Fehler übernommen, wenn der erwartete Erfolgszustand vorher nicht erreicht wurde.

OMW-Quelle:

```text
mission/tests/jalalabad-air-operations/src/14-phase1-test-controller.lua
```

Status: `SOURCE_AND_RUNTIME_SEQUENCE_VALIDATED`; korrigierte PASS-Klassifizierung muss erneut in DCS bestätigt werden.

## 12. OPSTRANSPORT

| Methode / Ereignis | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `OPSTRANSPORT:New(Cargo, PickupZone, DeployZone)` | `RUNTIME_VALIDATED` für UH-60-Pfad | Truppentransport konstruieren | Native Zustände bis `DELIVERED` beobachtet |
| `SetPickupZone`, `SetEmbarkZone`, `SetDeployZone`, `SetDisembarkZone` | `RUNTIME_VALIDATED` für getestete Geometrie | Carrier-Landezonen von Ein-/Aussteigezonen trennen | UH-60 nahm Truppen auf, setzte sie ab und kehrte zurück |
| `OnAfterDelivered` | `RUNTIME_VALIDATED` | Native Transporterfüllung | `DELIVERED` als autoritativer OPSTRANSPORT-Terminalzustand beobachtet |

## 13. FLIGHTGROUP

| Methode / Ereignis | Status | OMW-Verwendung | Beobachtetes Ergebnis |
|---|---|---|---|
| `FLIGHTGROUP:SetOptionPreferVertical()` | `RUNTIME_OBSERVED_ADVISORY` | Vertikales Starten/Landen bevorzugen | Option wurde gesetzt; CH-47 startete vertikal, AH-64-Two-Ship taxierte dennoch zur Startbahn. Die Methode ist als Präferenz, nicht als Garantie zu behandeln. |
| `FLIGHTGROUP:AddWaypoint(...)` | `RUNTIME_OBSERVED_PARTIAL` | OH-58D-Recovery-Korridor ergänzen | Quell- und Laufzeitpfad vorhanden; vollständige Abnahme weiterhin offen |
| `FLIGHTGROUP:UpdateRoute()` | `RUNTIME_OBSERVED_PARTIAL` | Ergänzte Route aktivieren | Zusammen mit OH-58D-Recovery-Korridor eingesetzt |
| `OnAfterRTB` | `RUNTIME_VALIDATED` als Beobachtung | RTB-Anforderung protokollieren | RTB-Ereignisse für UH-60, CH-47 und AH-64 beobachtet |

## 14. AUFTRAG-Routing und Formation

### `AUFTRAG:SetFormation(Formation)`

Exact signature:

```lua
mission:SetFormation(Formation)
```

OMW-Verwendung:

```lua
mission:SetFormation(ENUMS.Formation.RotaryWing.EchelonRight.D300)
```

Zweck:

- OH-58D- und AH-64D-Two-Ship nicht pauschal in Vee/Wedge fliegen lassen;
- DCS-seitig verfügbare Annäherung an `Combat Cruise Right` verwenden.

Einschränkung:

DCS/MOOSE stellt keine Formation mit dem Namen `Combat Cruise` bereit. `EchelonRight.D300` ist eine technische Annäherung und keine behauptete Doktrinäquivalenz.

Status: `SOURCE_VERIFIED`; neuer DCS-Lauf erforderlich.

### `AUFTRAG:SetMissionEgressCoord(Coordinate, Altitude, Speed)`

Exact signature:

```lua
mission:SetMissionEgressCoord(Coordinate, AltitudeFeet, SpeedKnots)
```

OMW-Verwendung:

- AH-64-CAS-Rückflug über einen terrain-geprüften Egress-Korridor;
- Geländeabtastung CAS-Zone -> `ZONE_TEST_US_JBAD_RECON_01` -> Jalalabad;
- Höhe: höchster abgetasteter Geländepunkt plus 500 m Freiraum;
- Geschwindigkeit: 100 kt.

OMW-Quelle:

```text
mission/tests/jalalabad-air-operations/src/16-phase1-moose-first-readiness-routing.lua
```

Status: `SOURCE_VERIFIED`; neuer DCS-Lauf erforderlich.

## 15. CH-47 CARGOTRANSPORT Adapter

MOOSE-Konstruktor:

```lua
AUFTRAG:NewCARGOTRANSPORT(StaticCargo, DropZone)
```

Festgestellte Einschränkung im gepinnten MOOSE-Stand:

- der Konstruktor erzeugt eine äußere `ComboTask` mit einer inneren DCS-Task `CargoTransportation`;
- `groupId` und `zoneId` werden am äußeren Parameterobjekt gesetzt;
- DCS führt die innere Task aus.

OMW-Entscheidung:

- AUFTRAG bleibt operative Autorität;
- kein eigener Transport-FSM;
- dünner Adapter kopiert ausschließlich die bereits von MOOSE ermittelten `groupId`/`zoneId` in die innere Task.

OMW-Quelle:

```text
mission/tests/jalalabad-air-operations/src/13-phase1-mission-factory.lua
```

Erforderlicher Laufzeitmarker:

```text
CARGOTRANSPORT_TASK_BOUND authority=AUFTRAG:NewCARGOTRANSPORT adapter=INNER_DCS_TASK_PARAMETERS
```

Status: `SOURCE_VERIFIED`; der Lauf aus `dcs(80).log` enthielt diesen Marker nicht und validiert den Adapter daher nicht.

## 16. Interner Zugriff `_DATABASE`

Verwendeter Zugriff:

```lua
_DATABASE.Templates.Groups[groupName]
```

Zweck:

- unbesetzte Client-Gruppen;
- Late-Activation-Templates;
- Template-Livery

validieren, obwohl die Gruppe nicht als aktive Runtime-`GROUP` existiert.

Status: `INTERNAL_RESTRICTED`.

Dieser Zugriff ist kein allgemeiner Projektstandard. Bei jedem MOOSE-Update ist die Struktur erneut zu prüfen. Vor einer produktiven Nutzung muss erneut nach einer öffentlichen MOOSE-Methode gesucht werden.

## 17. Noch nicht validierte, aber vorgesehene Methoden

```lua
COMMANDER:AddMission(mission)
COMMANDER:AddOpsTransport(transport)
FLIGHTGROUP:AddMission(mission)
ARMYGROUP:AddMission(mission)
```

Vor Statusänderung sind Dokumentation, Quellcode, MOOSE-Version und DCS-Test erforderlich.

## 18. Acceptance-Nachweise

### Complete Node

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

### Phase-1 CH-47/AH-64 Analyse

Bericht:

- [`2026-07-25-ch47-ah64-false-negative-and-mountain-recovery.md`](../../mission/tests/jalalabad-air-operations/results/2026-07-25-ch47-ah64-false-negative-and-mountain-recovery.md)

Status:

```text
Source and log analysis complete
Corrected DCS runtime PASS pending
```

## 19. Vorlage für neue Einträge

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
