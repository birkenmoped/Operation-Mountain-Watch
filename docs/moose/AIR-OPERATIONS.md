# MOOSE-Luftoperationen in Operation Mountain Watch

## 1. Architektur

Militärische Luftoperationen werden grundsätzlich mit den MOOSE-OPS-Klassen umgesetzt:

```text
COMMANDER
├── AIRWING Jalalabad
│   └── SQUADRONs
├── AIRWING Salerno
│   └── SQUADRONs
├── weitere AIRWINGs
└── später gegebenenfalls BRIGADEs
```

`AUFTRAG` und `OPSTRANSPORT` werden an COMMANDER, AIRWING oder geeignete OPSGROUPs übergeben.

Aktuell praktisch bestätigte Referenzknoten:

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

```text
AW_US_SALERNO
├── SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK
├── SQ_US_SAL_OH58D_B_6_6_CAV
├── SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT
├── SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN
└── SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT
```

Der Jalalabad-Test bestätigt den vollständigen Grundstart mit leerer Missionsqueue. Der Salerno-Test bestätigt zusätzlich einen isolierten COMMANDER-gesteuerten CAS-Auftrag bis zum Zustand `started`.

## 2. AIRBASE

### Projektzweck

- DCS-Flugplatz über den MOOSE-Wrapper suchen;
- Airbase-Name und ID diagnostisch bestätigen;
- absichtlich belegte Parkpositionen aus dem MOOSE-Parking-Pool entfernen, sofern ein belastbarer lokaler Vertrag vorliegt.

### Aktuell verwendete Methoden

```lua
AIRBASE:FindByName(name)
airbase:GetName()
airbase:GetID()
airbase:SetParkingSpotBlacklist(ids)
```

### Validierter Einsatz

Jalalabad wurde gefunden und explizit an das AIRWING gebunden. Vier durch CH-47-Statics belegte DCS-Parking-Nodes wurden über die Blacklist geschützt.

Salerno wurde ebenfalls gefunden und an `AW_US_SALERNO` gebunden. Die dortige Terminal-ID-Kalibrierung bleibt als Evidenz erhalten; die operative Parking-Steuerung ist wegen nicht zuverlässig erzwungener Multi-Unit-Platzierung jedoch ausdrücklich `DEFERRED`.

### Einschränkung

Parking-IDs sind karten-, flugplatz- und DCS-versionsabhängig. Konfigurationswerte oder Asset-`parkingIDs` beweisen allein nicht die tatsächlich realisierte Spawnposition. Parking benötigt je Flugplatz einen separat beobachteten Runtime-Acceptance-Test.

## 3. AIRWING

### Projektzweck

Ein `AIRWING` ist der lokale MOOSE-Ressourcen- und Einsatzmanager eines Flugplatzes oder dauerhaften Luftfahrtknotens.

Es verwaltet:

- Squadrons;
- Asset-Gruppen;
- Payloads;
- Missionswarteschlangen;
- Warehouse-Funktion;
- Airbase-Bezug;
- Spawn- und Parking-Verhalten.

### Aktuell verwendete Methoden

```lua
AIRWING:New(warehouseName, airwingName)
airwing:SetAirbase(airbase)
airwing:SetTakeoffCold()
airwing:SetSafeParkingOn()
airwing:AddSquadron(squadron)
airwing:NewPayload(templateGroup, amount, missionTypes, performance)
airwing:GetSquadron(squadronName)
airwing:Start()
```

Zusätzlich praktisch beobachtete FSM-Callbacks:

```lua
airwing:OnAfterMissionAssign(From, Event, To, Mission, Legions)
airwing:OnAfterMissionRequest(From, Event, To, Mission, Assets)
airwing:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)
```

### Verbindliche Startreihenfolge

1. Warehouse-Anker muss existieren.
2. AIRBASE muss gefunden sein.
3. Lokale Parking-Mutationen dürfen nur bei belastbarem Vertrag gesetzt werden.
4. AIRWING wird konstruiert.
5. Airbase und Startart werden gesetzt.
6. Squadrons und Payloads werden vollständig registriert.
7. Validierung muss PASS sein.
8. Erst dann wird `AIRWING:Start()` aufgerufen.

### Validierter Einsatz

Jalalabad startete erfolgreich und blieb ohne spontane Missionen stabil.

Salerno startete mit fünf SQUADRONs, zwanzig registrierten Assets und zehn Payloaddefinitionen. Ein vom COMMANDER ausgewählter CAS-Auftrag wurde in die AIRWING-Missionsqueue übernommen; ein AH-64-Asset wurde angefordert und als `OpsOnMission` gemeldet. Der Auftrag erreichte `started`.

Nicht dadurch bewiesen sind taktische Zielbekämpfung, vollständiger Missionsabschluss, Rückkehr, Landung, Recovery oder persistente Bestandsbuchung.

## 4. SQUADRON

### Projektzweck

Ein `SQUADRON` bildet einen typgebundenen lokalen Luftfahrzeugbestand ab.

Ein Squadron enthält:

- ein Mission-Editor-Template;
- eine Anzahl von Asset-Gruppen;
- eine Gruppierungsgröße;
- Skill;
- Mission Capabilities;
- Zuordnung zu einem AIRWING.

### Konstruktorregel

```lua
SQUADRON:New(templateGroupName, numberOfGroups, squadronName)
```

Der zweite Parameter zählt Gruppen, nicht einzelne Luftfahrzeuge.

Beispiel:

```text
24 OH-58D
2 Luftfahrzeuge je Template-Gruppe
= 12 Asset-Gruppen
```

### Aktuell verwendete Methoden

```lua
SQUADRON:New(templateName, assetGroups, squadronName)
squadron:SetGrouping(groupSize)
squadron:SetSkill(AI.Skill.HIGH)
squadron:AddMissionCapability(missionTypes, performance)
airwing:AddSquadron(squadron)
```

### Validierter Umfang

Jalalabad bestätigt vier typgebundene Bestände und deren Grundkonfiguration.

Salerno bestätigt fünf SQUADRONs und für den CAS-Pfad praktisch, dass die registrierte AH-64-Capability durch `COMMANDER:CanMission()` erkannt und ein zugehöriges Asset rekrutiert werden konnte.

## 5. Payloads

### Grundsatz

AIRWING-Assets benötigen passende Payloads für die jeweiligen Missionstypen. Ein vorhandenes Luftfahrzeug allein garantiert nicht, dass ein AUFTRAG ausgeführt werden kann.

### Aktuell verwendete Methode

```lua
airwing:NewPayload(templateGroup, amount, missionTypes, performance)
```

`-1` wird in technischen Baselines als unbegrenzte Payloadmenge verwendet. Dies ist noch kein persistentes Munitions- oder Nachschubmodell.

### Validierter Stand

Jalalabad bestätigt die Registrierung von RECON-, CAS-, MEDEVAC-/Transport-, Ground-Escort- und Heavy-Lift-Payloads.

Salerno bestätigt für den isolierten CAS-Pfad, dass eine passende AH-64-Payload in der COMMANDER-/AIRWING-Eignungs- und Rekrutierungskette verfügbar war. Die zehn registrierten Payloaddefinitionen wurden vom laufenden AIRWING ausgewiesen.

## 6. AUFTRAG

### Projektzweck

`AUFTRAG` ist das standardisierte MOOSE-Missionsobjekt für Luft-, Boden- und Seeeinsätze.

### Derzeit verwendete Missionstypen

```lua
AUFTRAG.Type.RECON
AUFTRAG.Type.CAS
AUFTRAG.Type.TROOPTRANSPORT
AUFTRAG.Type.CARGOTRANSPORT
AUFTRAG.Type.LANDATCOORDINATE
AUFTRAG.Type.GROUNDESCORT
```

### Praktisch bestätigter CAS-Pfad

Salerno verwendet:

```lua
AUFTRAG:NewCAS(zone, altitude, speed, coordinate, heading, leg)
mission:SetName(name)
mission:SetRequiredAssets(min, max)
mission:SetTime(start, stop)
mission:SetDuration(seconds)
mission:SetReturnToLegion(true)
mission:SetRepeat(0)
```

Beobachtete Zustandsfolge:

```text
planned
requested
scheduled
started
```

Anschließend wurde der Auftrag durch den Testharness kontrolliert abgebrochen und bereinigt.

### Validierungsgrenze

Validiert sind:

- Capability-Registrierung an SQUADRONs;
- Payload-Zuordnung zu Missionstypen;
- Konstruktion eines CAS-AUFTRAG;
- COMMANDER-Eignungsprüfung;
- Auswahl des Salerno-AIRWING;
- Assetanforderung;
- `OpsOnMission`;
- Fortschritt bis `started`.

Nicht validiert sind:

- tatsächliche Zielbekämpfung;
- taktische Success-/Failure-Erkennung;
- regulärer Abschluss ohne Test-Cleanup;
- Rückkehr, Recovery und Bestandsverbuchung;
- Verlustpfade;
- OPSTRANSPORT.

`AUFTRAG` bleibt deshalb trotz des bestätigten CAS-Dispatchpfads `IN_USE_PARTIAL`.

## 7. COMMANDER

### Projektzweck

Der `COMMANDER` verwaltet AIRWINGs, später gegebenenfalls BRIGADEs, und verteilt AUFTRAG- oder OPSTRANSPORT-Objekte an geeignete Legions.

### Aktuell verwendete Methoden

```lua
COMMANDER:New(coalition.side.BLUE, alias)
commander:AddAirwing(airwing)
commander:SetVerbosity(level)
commander:Start()
commander:CanMission(mission)
commander:AddMission(mission)
commander:Status()
commander:MissionCancel(mission)
```

Praktisch beobachtete Callbacks:

```lua
commander:OnAfterMissionAssign(From, Event, To, Mission, Legions)
commander:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)
```

### Verbindliche Sequenz

Der geprüfte MOOSE-Quellstand zeigt:

```text
COMMANDER:New()
  -> FSM-Zustand NotReadyYet

COMMANDER:AddAirwing()
  -> bindet Legion
  -> startet den COMMANDER nicht

COMMANDER:Start()
  -> Zustand OnDuty
  -> startet Status-Zyklus

COMMANDER:AddMission()
  -> Mission in missionqueue
  -> statusCommander=PLANNED

COMMANDER:Status()
  -> onafterStatus()
  -> CheckMissionQueue()
  -> Auswahl und Rekrutierung
```

Die Reihenfolge `New -> AddAirwing -> Start -> AddMission` ist verbindlich. Stage 17 ließ `Start()` aus und blieb deshalb korrekt auf `planned`; Stage 18 korrigierte diesen Testharness-Fehler.

### Validierter Umfang

Jalalabad bestätigt:

- Konstruktion;
- AIRWING-Einbindung;
- Start;
- stabilen Leerlauf ohne spontane Missionen.

Salerno bestätigt zusätzlich:

- Zustand `OnDuty`;
- `CanMission=true` für den isolierten CAS-Auftrag;
- Auswahl von `AW_US_SALERNO`;
- `MissionAssign`;
- Weitergabe an die AIRWING-Missionsqueue;
- AH-64-Assetanforderung und `OpsOnMission`;
- Auftrag bis `started`;
- kontrollierten Abbruch und Cleanup.

Noch nicht validiert:

```lua
commander:AddOpsTransport(transport)
```

### Produktionsarchitektur

Die lokalen COMMANDER-Objekte in Jalalabad- und Salerno-Testfixtures bleiben für reproduzierbare Acceptance-Tests erhalten.

Für die spätere Kampagnenruntime ist genau ein theaterweiter BLUE COMMANDER vorgesehen. Die einzelnen Flugplatzmodule sollen nur ihre AIRWINGs exportieren; ein zentrales, später geladenes Modul registriert die AIRWINGs und startet den gemeinsamen COMMANDER. Ein eigener Produktions-COMMANDER je Flugplatz ist nicht vorgesehen.

## 8. GROUP, UNIT und STATIC

### GROUP

```lua
GROUP:FindByName(templateName)
group:GetUnits()
```

Verwendung:

- Template vorhanden;
- korrekte Gruppengröße;
- korrekter DCS-Typ;
- Übergabe des Template-Wrappers an `AIRWING:NewPayload()`.

### UNIT

```lua
unit:GetName()
unit:GetTypeName()
UNIT:FindByName(name)
```

Verwendung:

- Typprüfung der Template-Einheiten;
- optionaler Warehouse-Anker als UNIT.

### STATIC

```lua
STATIC:FindByName(name, false)
static:GetTypeName()
```

Der zweite Parameter `false` ist bei erwartbar fehlenden Objekten relevant, damit die Suche nicht unnötig einen MOOSE-Fehler erzeugt.

## 9. ZONE

### Aktuell verwendete Methode

```lua
ZONE:FindByName(name)
```

Validiert sind die Existenzprüfungen benannter Mission-Editor-Zonen und die Verwendung einer Salerno-Zone als Zielraum für einen CAS-AUFTRAG. Vollständige operative Load-/Unload-, Presence- oder Besitzlogik ist separat zu testen.

## 10. Interne MOOSE-Daten

Für unbesetzte Client-Gruppen und Late-Activation-Templates wurde verwendet:

```lua
_DATABASE.Templates.Groups[groupName]
```

Diagnostisch wurden in Salerno außerdem COMMANDER-, AIRWING- und Missionsqueues sowie registrierte Tabellen gezählt. Solche Zugriffe sind nur für Testdiagnostik zulässig und keine stabile Produktions-API.

## 11. Verifizierter MOOSE-Stand für Salerno

```text
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA:  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Embedded Moose.lua size: 9773155 bytes
DCS version:             2.9.28.26385
OMW branch:              agent/salerno-read-only-diagnostics
OMW source commit:       dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:          SAL-COMMANDER-SELECTION-18
Bundle SHA-256:          75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
```

## 12. Quellen

- AIRWING: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Airwing.html>
- SQUADRON: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Squadron.html>
- AUFTRAG: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Auftrag.html>
- COMMANDER: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Commander.html>
- AIRBASE: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Wrapper.Airbase.html>
- GROUP: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Wrapper.Group.html>
- UNIT: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Wrapper.Unit.html>
- STATIC: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Wrapper.Static.html>
- ZONE: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Zone.html>
- Exact Salerno MOOSE source: commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, especially `Moose Development/Moose/Ops/Commander.lua` and `Ops/Legion.lua`.

## 13. OMW-Nachweise

- [`Luftoperations- und ORBAT-Umsetzung`](../18-air-operations-implementation.md)
- [`Jalalabad: finale Validierung und operative Grundbaseline`](../25-jalalabad-final-validation-and-operational-baseline.md)
- [`Jalalabad complete Air Operations node: PASS`](../../mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md)
- [`Salerno COMMANDER selection stage 18: PASS`](../../mission/tests/salerno-air-operations/results/2026-08-02-salerno-commander-selection-18-pass.md)
- [`Salerno COMMANDER isolated stage 17: FAIL`](../../mission/tests/salerno-air-operations/results/2026-08-02-salerno-commander-isolated-17-fail.md)
