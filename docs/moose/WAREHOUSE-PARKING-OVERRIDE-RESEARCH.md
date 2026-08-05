---
document_id: OMW-MOOSE-WAREHOUSE-PARKING-OVERRIDE-RESEARCH
status: BINDING
document_class: TECHNICAL_SOURCE_RESEARCH_AND_DECISION_INPUT
owning_policy: OMW-GOV-001
authoritative_for:
  - source-level influence paths for WAREHOUSE:_FindParkingForAssets
  - distinction between supported parking APIs and WAREHOUSE-local constants
  - Tarinkot G8 parking-block decision input
not_authoritative_for:
  - authorization of a MOOSE override or source patch
  - authorization of a MIZ or parking-pool change
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/reconcile-main-documentation-phase1
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# MOOSE-WAREHOUSE-Parking: Override- und Einflussrecherche

## 1. Ergebnis

Für den gepinnten MOOSE-Stand existiert **keine dokumentierte WAREHOUSE-Konfiguration und kein WAREHOUSE-Hook**, mit dem die lokalen Werte in `WAREHOUSE:_FindParkingForAssets()` gesetzt oder überschrieben werden können:

```lua
local scanradius = 25
local scanunits = true
local scanstatics = true
local scanscenery = false
local verysafe = false
```

Der MOOSE-Stand vom 3. August 2026 enthält weiterhin dieselbe Implementierung. Die Datei `Functional/Warehouse.lua` ist zwischen dem eingebundenen Commit und den geprüften aktuellen Heads byte-identisch.

Eine Veränderung dieser Werte ist im WAREHOUSE-Pfad daher nur durch einen nicht öffentlichen Eingriff möglich:

1. vollständiger Runtime-Ersatz von `_FindParkingForAssets()` auf einer einzelnen Instanz oder auf der Klasse;
2. Änderung beziehungsweise Fork von `Warehouse.lua`/`Moose.lua`;
3. wesentlich riskanterer globaler Eingriff in `COORDINATE:ScanObjects()`.

Keine dieser Varianten wird durch dieses Dokument genehmigt.

## 2. Geprüfte Stände

### 2.1 Eingebundener Stand

```yaml
release_label: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
commit_date: 2026-06-14T16:11:05+02:00
commit_subject: Merge remote-tracking branch 'origin/master-ng' into develop
moose_lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Quellpfade:

- [`Functional/Warehouse.lua` am exakten Commit](https://github.com/FlightControl-Master/MOOSE/blob/73d3ed119cd9e7e3f2cfcabbaa34513d30529b54/Moose%20Development/Moose/Functional/Warehouse.lua)
- [`Wrapper/Airbase.lua` am exakten Commit](https://github.com/FlightControl-Master/MOOSE/blob/73d3ed119cd9e7e3f2cfcabbaa34513d30529b54/Moose%20Development/Moose/Wrapper/Airbase.lua)
- [`Functional/RAT.lua` am exakten Commit](https://github.com/FlightControl-Master/MOOSE/blob/73d3ed119cd9e7e3f2cfcabbaa34513d30529b54/Moose%20Development/Moose/Functional/RAT.lua)
- [`Core/Base.lua` am exakten Commit](https://github.com/FlightControl-Master/MOOSE/blob/73d3ed119cd9e7e3f2cfcabbaa34513d30529b54/Moose%20Development/Moose/Core/Base.lua)

### 2.2 Vergleichsstände am 5. August 2026

```yaml
master_ng_commit: 490c798848e5991c5d3e4b1ab445f5de9cda2eab
master_ng_date: 2026-08-03T17:22:39+02:00
develop_commit: 28a12c6eb3fcd370fe6fba24a9522162e0e7efbf
develop_date: 2026-08-03T17:23:04+02:00
warehouse_file_diff_from_pinned_commit: NONE
```

Damit bietet weder der geprüfte aktuelle `master-ng`- noch der `develop`-Stand eine spätere WAREHOUSE-API für die fünf Werte.

## 3. Exakter WAREHOUSE-Befund

### 3.1 Lokale Werte sind nicht von außen erreichbar

`WAREHOUSE:_FindParkingForAssets(airbase, assets)` besitzt nur zwei fachliche Argumente. Die fünf Scanwerte werden bei jedem Aufruf als lokale Variablen neu angelegt. Sie werden weder aus `self` noch aus einer Konfiguration gelesen.

Folgen:

| Wert | Wirkung im WAREHOUSE-Pfad | Öffentlicher WAREHOUSE-Einfluss |
|---|---|---|
| `scanradius=25` | Radius für `COORDINATE:ScanObjects()` | keiner |
| `scanunits=true` | Units werden als Hindernisse gesammelt | keiner |
| `scanstatics=true` | Statics werden als Hindernisse gesammelt | keiner |
| `scanscenery=false` | Scenery wird nicht gesammelt | keiner |
| `verysafe=false` | keine; Variable wird in dieser Methode nicht gelesen | keiner |

Die Zeile im Kommentar, es werde ein Radius von 100 Metern gescannt, widerspricht dem ausführbaren Wert `25`. Für das Verhalten ist der Codewert maßgeblich.

### 3.2 Hindernissammlung und Überlappung

Die Methode scannt um **jede** bekannte Parkposition und sammelt alle gefundenen Units und Statics in eine gemeinsame Hindernisliste. Danach prüft sie jeden Kandidaten gegen diese Liste:

```lua
local safedist = (l1 / 2 + l2 / 2) * 1.05
local safe = dist > safedist
```

Ein Static innerhalb des Scanradius blockiert einen Platz also nicht allein durch seine Anwesenheit. Entscheidend ist zusätzlich die berechnete Größenüberlappung. Der bisherige Tarinkot-Befund bleibt deshalb eine stark gestützte, aber ohne Hindernis-Telemetrie noch nicht abschließend instrumentierte Diagnose.

### 3.3 `asset.parkingIDs`, White-/Blacklist und `airbase.parking`

- `asset.parkingIDs` wählt Kandidaten aus, überspringt aber nicht die Hindernis- und Überlappungsprüfung.
- AIRBASE-White-/Blacklist wirkt nur im Zweig ohne `asset.parkingIDs`.
- `WAREHOUSE:SetParkingIDs()` und `airbase.parking` beeinflussen den Kandidatenbestand, nicht die fünf lokalen Scanwerte.

## 4. Korrektur zu `SetSafeParkingOn()` und `SetSafeParkingOff()`

Die offizielle WAREHOUSE-Dokumentation beschreibt `SetSafeParkingOn()` als Schutz für Clientplätze und Reservierungen ankommender Luftfahrzeuge. Der Quellcode des gepinnten Stands zeigt jedoch:

```lua
function WAREHOUSE:SetSafeParkingOn()
  self.safeparking = true
  return self
end

function WAREHOUSE:SetSafeParkingOff()
  self.safeparking = false
  return self
end
```

`self.safeparking` wird in `Warehouse.lua` außerhalb dieser beiden Zuweisungen und der Feldbeschreibung nicht gelesen. Die Klassenvorgabe enthält außerdem das abweichend geschriebene Feld `saveparking=false`. Dieser Befund ist im geprüften aktuellen `master-ng` unverändert.

Damit gilt für den gepinnten Pfad:

```text
SetSafeParkingOn/Off
  -> setzt einen Zustand
  -> ändert _FindParkingForAssets() nicht
  -> ändert scanradius/scanunits/scanstatics/scanscenery/verysafe nicht
  -> bietet keine Revetment-Lösung
```

Client-Templates werden stattdessen direkt durch `allowSpawnOnClientSpots` gesteuert. Der Konstruktor setzt dieses Feld auf `false`; `SetAllowSpawnOnClientParking()` setzt es auf `true`. Dieser Mechanismus ist unabhängig von `safeparking`, für Tarinkot fachlich gesperrt und für Static-Hindernisse wirkungslos.

Offizielle Referenz:

- [WAREHOUSE:SetSafeParkingOff/On](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Functional.Warehouse.html)

## 5. Vorhandene unterstützte MOOSE-APIs außerhalb des WAREHOUSE-Pfads

### 5.1 `AIRBASE:FindFreeParkingSpotForAircraft()`

MOOSE besitzt bereits eine öffentliche AIRBASE-Methode mit genau diesen Parametern:

```lua
AIRBASE:FindFreeParkingSpotForAircraft(
  group,
  terminaltype,
  scanradius,
  scanunits,
  scanstatics,
  scanscenery,
  verysafe,
  nspots,
  parkingdata
)
```

Die Parameter sind offiziell dokumentiert. Die Methode kann daher außerhalb von WAREHOUSE unterstützt konfiguriert aufgerufen werden: [AIRBASE-Klassenreferenz](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Airbase.html).

Diese API löst den G8-Block **nicht direkt**, weil `WAREHOUSE:_FindParkingForAssets()` sie nicht aufruft. WAREHOUSE implementiert eine eigene, assetbasierte Mehrgruppen-Suche und arbeitet nicht mit der von AIRBASE erwarteten bereits existierenden `GROUP`-Instanz.

### 5.2 RAT

RAT bietet öffentliche Setter für einen Teil derselben Semantik:

```lua
RAT:SetParkingScanRadius()
RAT:SetParkingScanSceneryON/OFF()
RAT:SetParkingSpotSafeON/OFF()
```

RAT reicht seine Felder an `AIRBASE:FindFreeParkingSpotForAircraft()` weiter. Diese Setter gelten nur für RAT und werden von WAREHOUSE/AIRWING nicht gelesen: [RAT-Klassenreferenz](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Functional.RAT.html).

Die Existenz dieser APIs zeigt, dass MOOSE konfigurierbare Parking-Scans grundsätzlich kennt. Sie ist aber kein indirekter Hook für WAREHOUSE.

## 6. Technisch mögliche, aber nicht unterstützte Eingriffe

### 6.1 Instanzbezogener Methodenoverride

MOOSE-Objekte sind Lua-Tabellen. `BASE:Inherit()` erzeugt eine Child-Tabelle und verbindet sie über `__index` mit dem Parent. Eine direkt auf einer AIRWING-/WAREHOUSE-Instanz gesetzte Funktion `_FindParkingForAssets` würde deshalb vor der geerbten Methode gefunden.

Bewertung:

```yaml
technically_possible: true
official_api: false
documented_hook: false
scope_possible: single_instance
implementation_cost: full_method_replacement_or_equivalent
authorization: NOT_AUTHORIZED
```

Ein Wrapper um die Originalmethode reicht nicht aus, weil die lokalen Werte nicht als Argumente oder Upvalues von außen erreichbar sind. Ein Fallback nach `nil` müsste die komplette alternative Auswahl selbst durchführen und dieselben Rückgabe-, Multi-Asset-, Client-, Größen- und Reservierungsverträge einhalten.

### 6.2 Klassenweiter Override

Eine Zuweisung an `WAREHOUSE._FindParkingForAssets` wäre ebenfalls technisch möglich, würde aber alle WAREHOUSE-/AIRWING-Instanzen der Mission betreffen. Das ist für einen Tarinkot-spezifischen Konflikt ein unnötig großer Wirkungsbereich.

### 6.3 Änderung von `Warehouse.lua` oder `Moose.lua`

Eine Quelländerung könnte die lokalen Werte in Instanzfelder beziehungsweise einen neuen Setter überführen. Das wäre technisch klarer als ein versteckter Monkey-Patch, erzeugt aber einen projektspezifischen MOOSE-Fork und beendet die Gleichheit mit dem dokumentierten Upstream-Artefakt. Alle MOOSE-Provenienz- und Revalidierungsregeln würden greifen.

### 6.4 Override von `COORDINATE:ScanObjects()`

Ein globales oder zeitweise umgeschaltetes Override könnte Static-Ergebnisse filtern. Es beträfe jedoch zahlreiche andere MOOSE-Klassen, wäre scheduler- und reentrancy-anfällig und würde die Ursache außerhalb des WAREHOUSE-Vertrags verstecken. Dieser Weg ist technisch möglich, aber für OMW nicht als seriöse Lösung einzustufen.

### 6.5 Lua-Debug-Upvalue-Manipulation

Die Werte sind keine dauerhaften Closure-Upvalues, sondern werden bei jedem Methodenaufruf neu erzeugt. `debug.setupvalue()` bietet deshalb keinen stabilen Zugriff. Abhängigkeit von der in DCS verfügbaren beziehungsweise sandboxed Debug-Bibliothek wäre zusätzlich nicht tragfähig.

## 7. Demos, Issues, Pull Requests und Forum

### 7.1 Offizielle Demo-/Testmissionen

Geprüft wurde `FlightControl-Master/MOOSE_MISSIONS` am Commit:

```text
5f90c5af4dbf4dfd3cb69e1e904d4a266344f9e5
```

Die vorhandenen `Functional/Warehouse`-Lua-Demos verwenden WAREHOUSE-Konstruktion, Assets und Requests. Keine Demo verwendet:

```text
_FindParkingForAssets override
SetSafeParkingOn/Off
SetAllowSpawnOnClientParking
scanradius/scanunits/scanstatics/scanscenery/verysafe override
```

Repository: [MOOSE_MISSIONS](https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/master/Functional/Warehouse)

### 7.2 GitHub-Issues und Pull Requests

Die Suche im MOOSE-Repository nach den Methodennamen, Variablennamen sowie Kombinationen aus `WAREHOUSE`, `parking`, `static`, `obstacle`, `radius` und `scenery` ergab keinen Setter- oder Hook-Vorschlag.

Relevante Treffer:

- [PR #986 – WAREHOUSE v0.5.1](https://github.com/FlightControl-Master/MOOSE/pull/986): führte die grundlegende WAREHOUSE-/Parking-Implementierung ein; kein externer Scan-Override.
- [PR #1987 – Misc Bug Fixes](https://github.com/FlightControl-Master/MOOSE/pull/1987): korrigierte die Größenberechnung, weil falsche Assetgrößen `_FindParkingForAssets()` blockierten; kein Setter oder Hook.
- [Issue #1795](https://github.com/FlightControl-Master/MOOSE/issues/1795): Parkingprüfung trotz angefordertem Airstart; betrifft die Aufrufbedingung, nicht die Scanparameter.
- [Issue #1047](https://github.com/FlightControl-Master/MOOSE/issues/1047): frühe WAREHOUSE-/Dispatcher-Integration; kein Overridepfad.

### 7.3 Eagle-Dynamics-/DCS-Forum

Die öffentlich zugängliche Suche im MOOSE-Hauptthread und im DCS-Forum nach den exakten Namen und den Kombinationen `MOOSE WAREHOUSE parking static/obstacle/safe parking` ergab keinen etablierten WAREHOUSE-Override.

Gefundene fachnahe Beiträge:

- Der MOOSE-Releasebeitrag beschreibt die öffentliche AIRBASE-Freiparkroutine und deren optionale Static-/Scenery-Prüfung, aber keinen WAREHOUSE-Hook: [MOOSE-Hauptthread, Seite 48](https://forum.dcs.world/topic/115625-moose-mission-object-oriented-scripting-framework/page/48/).
- Für direkte SPAWN-Nutzung wird `SPAWN:SpawnAtParkingSpot()` empfohlen; das ist nicht der WAREHOUSE-/AIRWING-Pfad: [Spawning planes at a specific parking spot with MOOSE](https://forum.dcs.world/topic/236390-spawning-planes-at-a-specific-parking-spot-with-moose/).
- Allgemeine DCS-Parking-ID-Probleme betreffen DCS-`parking`/`parking_id`, nicht die fünf lokalen MOOSE-Werte: [Airbase.getParking missing parking_id data](https://forum.dcs.world/topic/288057-airbasegetparking-missing-parking_id-data/).

Eine öffentliche, durchsuchbare MOOSE-Discord-Historie war nicht verfügbar. Nicht öffentlich indexierte Discord-Aussagen können deshalb weder bestätigt noch als Projektbeleg verwendet werden.

## 8. Bewertungsmatrix

| Variante | MOOSE-Unterstützung | Löst lokale Werte direkt | Eingriffsbereich | Aktueller Status |
|---|---|---:|---|---|
| WAREHOUSE-Setter/Hook | nicht vorhanden | nein | keiner | ausgeschlossen |
| `SetSafeParkingOff()` | dokumentiert, im Quellpfad ohne Leser | nein | keiner nachweisbar | ausgeschlossen |
| `SetAllowSpawnOnClientParking()` | dokumentiert | nur Clientliste | Warehouse-Instanz | fachlich gesperrt, irrelevant |
| AIRBASE-Freiparkroutine direkt | dokumentiert | ja, in eigener API | Aufrufer | nicht in WAREHOUSE verdrahtet |
| RAT-Setter | dokumentiert | nur RAT | RAT-Instanz | irrelevant |
| Instanzoverride `_FindParkingForAssets` | Lua-technisch möglich | ja | eine Instanz | nicht autorisiert |
| Klassenoverride | Lua-technisch möglich | ja | alle Warehouses | nicht autorisiert |
| `Warehouse.lua`-/`Moose.lua`-Patch | technisch möglich | ja | Framework-Artefakt | nicht autorisiert |
| `COORDINATE:ScanObjects`-Override | technisch möglich | indirekt | frameworkweit | nicht empfohlen/nicht autorisiert |
| MIZ-Geometrie ändern | außerhalb MOOSE | Hindernisursache | Mission | blockiert |
| Parking-Pool ändern | vorhandene APIs | umgeht betroffene Kandidaten | Tarinkot-Pools | blockiert |

## 9. Entscheidungspunkt nach Abschluss der Recherche

Die vorgeschriebene Quellenrecherche ist abgeschlossen. Sie genehmigt noch keine Implementierung.

Der nächste zulässige Schritt ist eine Eigentümerentscheidung zwischen:

```text
A  Instanzbezogenen, eng begrenzten WAREHOUSE-Override konzipieren
B  MOOSE-Quelländerung/Upstream-fähigen Setter konzipieren
C  Revetment-/Missionsgeometrie ändern
D  andere WAREHOUSE-kompatible ParkingIDs wählen
E  zuerst ausschließlich instrumentierte Parking-Diagnostik genehmigen
```

Für eine risikoarme Ursachenbestätigung ist `E` der kleinste nächste Schritt: `WAREHOUSE:SetDebugOn()` kann im vorhandenen Quellpfad den Namen, Typ, die Größe und Distanz des ersten blockierenden Hindernisses ausgeben. Das verändert weder die Parkingentscheidung noch die fünf Scanwerte. Es benötigt dennoch einen neuen DCS-Lauf und bleibt bis zur Eigentümerfreigabe gesperrt.

## 10. Fortbestehende Gates

```yaml
G8_first_runtime_attempt: BLOCKED_MISSING_TARGET_ZONE
G8_second_runtime_attempt: BLOCKED_MOOSE_WAREHOUSE_PARKING_OBSTACLE_CONFLICT
G8_vertical_departure: NOT_PROVEN
MOOSE_parking_override_research: COMPLETE
next_action: OWNER_DECISION
DCS_rerun: BLOCKED
MIZ_mutation: BLOCKED
parking_pool_change: BLOCKED
MOOSE_override: NOT_AUTHORIZED
```
