# MOOSE-Luftoperationen in Operation Mountain Watch

## 1. Architektur

Militärische Luftoperationen werden grundsätzlich mit den MOOSE-OPS-Klassen umgesetzt:

```text
COMMANDER
└── AIRWING
    ├── SQUADRON
    ├── SQUADRON
    └── SQUADRON

AUFTRAG und OPSTRANSPORT werden an COMMANDER, AIRWING oder geeignete OPSGROUPs übergeben.
```

Aktuell validierter Referenzknoten:

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

## 2. AIRBASE

### Projektzweck

- DCS-Flugplatz über den MOOSE-Wrapper suchen,
- Airbase-Name und ID diagnostisch bestätigen,
- absichtlich durch Statics belegte Parkpositionen aus dem MOOSE-Parking-Pool entfernen.

### Aktuell verwendete Methoden

```lua
AIRBASE:FindByName(name)
airbase:GetName()
airbase:GetID()
airbase:SetParkingSpotBlacklist({ 23, 35, 37, 49 })
```

### Validierter Einsatz

Jalalabad wurde gefunden und explizit an das AIRWING gebunden. Vier absichtlich durch CH-47-Statics belegte DCS-Parking-Nodes wurden über die Blacklist geschützt.

### Einschränkung

Parking-IDs sind karten-, flugplatz- und möglicherweise DCS-versionsabhängig. Sie dürfen nicht ungeprüft auf andere Flugplätze oder Kartenversionen übertragen werden.

## 3. AIRWING

### Projektzweck

Ein `AIRWING` ist der lokale MOOSE-Ressourcen- und Einsatzmanager eines Flugplatzes oder dauerhaften Luftfahrtknotens.

Es verwaltet:

- Squadrons,
- Asset-Gruppen,
- Payloads,
- Missionswarteschlangen,
- Warehouse-Funktion,
- Airbase-Bezug,
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

### Verbindliche Startreihenfolge

1. Warehouse-Anker muss existieren.
2. AIRBASE muss gefunden sein.
3. Parking-Blacklist muss gesetzt sein.
4. AIRWING wird konstruiert.
5. Airbase, Startart und Safe Parking werden gesetzt.
6. Squadrons und Payloads werden vollständig registriert.
7. Validierung muss PASS sein.
8. Erst dann wird `AIRWING:Start()` aufgerufen.

### Validierter Einsatz

Der Jalalabad-Referenzknoten startete erfolgreich. Es wurden keine spontanen Missionen oder unerwarteten Aircraft-Spawns erzeugt.

## 4. SQUADRON

### Projektzweck

Ein `SQUADRON` bildet einen typgebundenen lokalen Luftfahrzeugbestand ab.

Ein Squadron enthält:

- ein Mission-Editor-Template,
- eine Anzahl von Asset-Gruppen,
- eine Gruppierungsgröße,
- Skill,
- Mission Capabilities,
- Zuordnung zu einem AIRWING.

### Konstruktorregel

```lua
SQUADRON:New(templateGroupName, numberOfGroups, squadronName)
```

Der zweite Parameter zählt **Gruppen**, nicht einzelne Luftfahrzeuge.

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

### Validierte Squadrons

| Squadron | Bestand | Asset-Gruppen | Grouping | Capabilities |
|---|---:|---:|---:|---|
| OH-58D | 24 | 12 | 2 | `RECON` |
| AH-64D | 8 | 4 | 2 | `CAS` |
| UH-60 | 8 | 8 | 1 | `TROOPTRANSPORT`, `CARGOTRANSPORT`, `LANDATCOORDINATE`, `GROUNDESCORT` |
| CH-47 | 8 | 8 | 1 | `TROOPTRANSPORT`, `CARGOTRANSPORT`, `LANDATCOORDINATE` |

## 5. Payloads

### Grundsatz

AIRWING-Assets benötigen passende Payloads für die jeweiligen Missionstypen. Ein vorhandenes Luftfahrzeug allein garantiert nicht, dass ein AUFTRAG ausgeführt werden kann.

### Aktuell verwendete Methode

```lua
airwing:NewPayload(templateGroup, -1, missionTypes, performance)
```

`-1` wurde im Jalalabad-Grundtest als unbegrenzte Payloadmenge verwendet. Dies ist eine technische Baseline und noch kein persistentes Munitions- oder Nachschubmodell.

### Validierter Stand

- OH-58D RECON-Payload,
- AH-64D CAS-Payload,
- UH-60 MEDEVAC-Lead-/Transport-Payload,
- UH-60 Cover-/Ground-Escort-Payload,
- CH-47 Heavy-Lift-Payload.

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

### Aktueller Validierungsumfang

Validiert sind:

- Capability-Registrierung an SQUADRONs,
- Payload-Zuordnung zu Missionstypen,
- AIRWING- und COMMANDER-Grundstart mit leerer Missionswarteschlange.

Noch nicht validiert sind:

- taktische AUFTRAG-Erzeugung,
- Auswahl eines geeigneten Squadrons,
- Spawn und Start eines Missionsassets,
- Missionsdurchführung,
- Success-/Failure-Erkennung,
- Rückkehr, Recovery und Bestandsverbuchung,
- Abbruch- und Verlustpfade.

`AUFTRAG` bleibt deshalb im Klassenindex `IN_USE_PARTIAL`.

## 7. COMMANDER

### Projektzweck

Der `COMMANDER` verwaltet AIRWINGs, später gegebenenfalls BRIGADEs, und verteilt AUFTRAG- oder OPSTRANSPORT-Objekte an geeignete Legions.

### Aktuell verwendete Methoden

```lua
COMMANDER:New(coalition.side.BLUE, "OMW_BLUE_COMMANDER")
commander:AddAirwing(airwing)
commander:Start()
```

### Validierter Umfang

- Konstruktion,
- Einbindung des Jalalabad-AIRWING,
- Start,
- stabiler Leerlauf ohne spontane Missionen.

Noch nicht validiert:

```lua
commander:AddMission(mission)
commander:AddOpsTransport(transport)
```

## 8. GROUP, UNIT und STATIC

### GROUP

```lua
GROUP:FindByName(templateName)
group:GetUnits()
```

Verwendung:

- Template vorhanden,
- korrekte Gruppengröße,
- korrekter DCS-Typ,
- Übergabe des Template-Wrappers an `AIRWING:NewPayload()`.

### UNIT

```lua
unit:GetName()
unit:GetTypeName()
UNIT:FindByName(name)
```

Verwendung:

- Typprüfung der Template-Einheiten,
- optionaler Warehouse-Anker als UNIT.

### STATIC

```lua
STATIC:FindByName(name, false)
static:GetTypeName()
```

Der zweite Parameter `false` ist bei erwartbar fehlenden Objekten relevant, damit die Suche nicht unnötig einen MOOSE-Fehler erzeugt.

Verwendung:

- Warehouse-Anker,
- sichtbare Luftfahrzeug-Statics,
- Typprüfung.

## 9. ZONE

### Aktuell verwendete Methode

```lua
ZONE:FindByName(name)
```

Validiert wurde bislang die Existenz der Jalalabad-Zonen. Ihre spätere operative Verwendung als Lade-, Entlade-, MEDEVAC-, Ready- oder Missionszone ist noch separat zu testen.

## 10. Interne Template-Datenbank

Für unbesetzte Client-Gruppen und Late-Activation-Templates wurde verwendet:

```lua
_DATABASE.Templates.Groups[groupName]
```

Grund:

Unbesetzte Client-Gruppen sind nicht zwingend als aktive Runtime-`GROUP` verfügbar.

Bewertung:

- zulässig für Diagnose und Mission-Editor-Validierung,
- nicht als allgemeine stabile Produktions-API behandeln,
- Zugriff bei MOOSE-Updates erneut prüfen,
- möglichst durch eine öffentliche MOOSE-Methode ersetzen, falls eine geeignete Methode vorhanden ist.

## 11. Quellen

- AIRWING: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Airwing.html>
- SQUADRON: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Squadron.html>
- AUFTRAG: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Auftrag.html>
- COMMANDER: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Commander.html>
- AIRBASE: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Wrapper.Airbase.html>
- GROUP: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Wrapper.Group.html>
- UNIT: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Wrapper.Unit.html>
- STATIC: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Wrapper.Static.html>
- ZONE: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Zone.html>

## 12. OMW-Nachweise

- [`Luftoperations- und ORBAT-Umsetzung`](../18-air-operations-implementation.md)
- [`Jalalabad: finale Validierung und operative Grundbaseline`](../25-jalalabad-final-validation-and-operational-baseline.md)
- [`Jalalabad complete Air Operations node: PASS`](../../mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md)
- [`Jalalabad-Testquellen`](../../mission/tests/jalalabad-air-operations/src/)