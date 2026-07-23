# 21 – Jalalabad Air Operations: Manifest, Testchronik und validierter Abschlussstand

## 1. Status und Autorität

Jalalabad Airfield / FOB Fenty ist als lokaler Air-Ops-Knoten technisch aufgebaut und im vollständigen DCS-Abschlusslauf validiert.

```text
Status: OPERATIONAL / ACCEPTED
Finaler DCS-Acceptance-Test: PASS
Draft-PR: #18
Branch: feature/jalalabad-air-operations-diagnostics
```

Dieses Dokument ist die verbindliche Jalalabad-spezifische Quelle für:

- lokale Luft-ORBAT,
- Spieler- und KI-Grenzen,
- MOOSE-AIRWING-/SQUADRON-Struktur,
- sichtbare Statics und virtuelle Reserve,
- Parkplatz- und Flächenmodell,
- Missionseditor-Namen,
- chronologische Test- und Fehlerhistorie,
- final bestätigte technische Baseline,
- Abgrenzung der noch nicht implementierten Kampagnenfunktionen.

Ergänzende autoritative Dokumente:

```text
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/23-jalalabad-parking-template-and-medevac-model.md
docs/24-jalalabad-ch47-static-parking-reservations.md
docs/25-jalalabad-final-validation-and-operational-baseline.md
mission/tests/jalalabad-air-operations/README.md
mission/tests/jalalabad-air-operations/expected/jalalabad-complete-node-acceptance.md
mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md
```

Ältere Abschnitte und Ergebnisberichte bleiben als historische Testnachweise gültig. Angaben wie `24/8/6`, vier Spielerplätze je Typ, 13 beziehungsweise 15 Runtime-Parkplätze, `JBAD-AIR-OPS-COMPLETE-2` oder ein noch ausstehender Jalalabad-Gesamttest sind jedoch nicht mehr aktuell.

## 2. Validierte technische Baseline

### 2.1 Testmission

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01(6).miz
SHA-256: 16c607a9ffe9157779c09ad0e7557287697f91239c60e53fa33fd91d22396e8f
```

Karte und Missionszeitraum:

```text
DCS: Afghanistan
Missionsdatum: 2. Mai 2011
DCS-Version des Abschlusslaufs: 2.9.28.26283 MT
```

### 2.2 MOOSE-Basis

```text
MOOSE Commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Build: 2026-06-14T16:11:05+02:00
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die MOOSE-Datei darf für reproduzierbare Regressionstests nicht stillschweigend ausgetauscht werden.

### 2.3 Final validiertes Bundle

```text
Source commit:   6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
Builder:         tools/build-jalalabad-air-operations-bundle.ps1
BuilderVersion:  JBAD-AIR-OPS-COMPLETE-5
Bundle in .miz:  l10n/DEFAULT/OMW_AirOps_Jalalabad.lua
Bundlegröße:     50273 Bytes
Bundle SHA-256:  13f6ef2235a8d1abd13924c0e6bc297515039795766e98d7e15572c1f06ea18a
GeneratedUtc:    2026-07-23T22:48:46.2604962Z
```

### 2.4 Abschlussnachweise

```text
dcs(57).log
SHA-256: 1460c11af132a29421b091496702f8a1da70636c9303e4c72c82513b4e58a836

debrief(14).log
SHA-256: 2ae6f3e48cd0adea313b5c622226f6e965adf9b1ed51c51abcc33642d4ca12e4
```

## 3. Historische und bildliche Evidenz

### 3.1 Task Force Shooter

Task Force Shooter in Jalalabad / FOB Fenty wird für die Mission als gemischter Heeresfliegerverband mit folgenden Mustern abgebildet:

- OH-58D,
- AH-64D,
- UH-60,
- CH-47.

Die frühere Planung ohne CH-47 war unvollständig und wurde verworfen.

### 3.2 Ausgewertete Satellitenaufnahme 2011

Mindestens sichtbar gezählt wurden:

```text
13 OH-58
 7 AH-64
 7 UH-60
 7 CH-47
 1 Mi-8
 1 UH-1
```

Die Aufnahme ist eine Momentaufnahme. Weitere Luftfahrzeuge können gleichzeitig:

- im Einsatz,
- in Wartung,
- in Hallen,
- auf nicht dargestellten Dispersal-Flächen,
- oder vorübergehend an anderen Standorten gewesen sein.

Die Zuordnung einzelner AH-64 und UH-60 ist wegen Auflösung, Schattenwurf und ähnlicher Silhouetten teilweise unsicher. Der Gesamtbefund belegt jedoch eindeutig eine gemischte Ramp-Belegung und ein substantielles CH-47-Kontingent.

Mi-8 und UH-1 werden als beobachtete externe oder transiente Luftfahrzeuge dokumentiert. Sie werden derzeit nicht dem US-Task-Force-Shooter-Bestand zugerechnet.

## 4. Verbindlicher logischer Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
-------------------
48 Luftfahrzeuge
```

Dieser Bestand ist nicht identisch mit der Zahl gleichzeitig sichtbarer oder aktiver Luftfahrzeuge.

## 5. Vier getrennte Darstellungsebenen

### 5.1 Logischer Bestand

Der CampaignState beziehungsweise der MOOSE-SQUADRON-Bestand ist die autoritative Anzahl noch vorhandener Luftfahrzeuge.

### 5.2 Aktive Luftfahrzeuge

Aktuell von Spielern oder KI verwendete beziehungsweise für einen Einsatz reservierte Maschinen.

### 5.3 Sichtbare Statics

Begrenzter visueller Ausschnitt der inaktiven Bestandsmaschinen auf der Ramp.

### 5.4 Virtuelle Reserve

Noch vorhandene Maschinen, die nicht sichtbar platziert sind. Sie gelten beispielsweise als:

- in Hallen,
- in Wartung,
- auf nicht modellierten Abstellflächen,
- oder als nicht sichtbarer Bereitschaftsbestand.

## 6. Verlust- und Nachrückregel

Ein endgültiger Verlust reduziert den logischen Gesamtbestand dauerhaft:

```text
verbleibender Bestand
= Ausgangsbestand
- endgültig verlorene Spielerflugzeuge
- endgültig verlorene KI-Flugzeuge
- zerstörte Bestands-Statics
```

Eine andere, zuvor virtuelle Bestandsmaschine darf später einen Einsatz übernehmen. Das ist kein externer Ersatz, sondern ein anderes bereits vorhandenes Luftfahrzeug.

Ein während der laufenden Mission zerstörtes Static wird nicht sofort sichtbar ersetzt. Eine kontrollierte neue Ramp-Verteilung erfolgt erst:

- beim nächsten Missionsstart,
- oder durch einen später ausdrücklich implementierten Ramp-/Wartungszyklus.

Maximal sichtbare Statics je Typ:

```text
min(
  konfigurierte Static-Obergrenze,
  verbleibender Bestand
  - aktive Spieler
  - aktive KI
  - bereits reservierte Einsätze
)
```

Die persistente Bestands-, Verlust- und Ramp-Neuverteilung ist noch nicht Bestandteil des abgeschlossenen Grundknotens.

## 7. Validierter Missionseditor-Bestand

### 7.1 Verpflichtende Spielergruppen

Je Gruppe genau ein Luftfahrzeug, Skill `Client`, Cold Start:

```text
CLIENT_US_JBAD_OH58D_01
CLIENT_US_JBAD_OH58D_02

CLIENT_US_JBAD_AH64D_01
CLIENT_US_JBAD_AH64D_02

CLIENT_US_JBAD_CH47_01
CLIENT_US_JBAD_CH47_02
```

Einheitennamen jeweils mit Suffix `-1`.

Lokales Spielerlimit:

```text
maximal 2 Spielerluftfahrzeuge je nutzbarem Typ in Jalalabad
```

Optionale UH-60L-Modvariante:

```text
CLIENT_US_JBAD_UH60L_01
CLIENT_US_JBAD_UH60L_02
```

Zulässig sind nur `0` oder `2` Gruppen. Der validierte modfreie Kernstand verwendet `0` UH-60L-Gruppen.

### 7.2 KI-Templates

Alle BLUE/USA, Skill `High`, Late Activation, nicht `Uncontrolled`, Cold Start:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP          2 OH-58D
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP            2 AH-64D
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP    1 UH-60A
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP   1 UH-60A
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP       1 CH-47F
```

Zusammen enthalten die fünf Templategruppen sieben Luftfahrzeuge. Diese Gruppen sind Authoring-/Seedvorlagen und werden nicht als sieben dauerhaft belegte Runtime-Parkplätze gezählt.

### 7.3 Sichtbare Luftfahrzeug-Statics

```text
7 OH-58D:
STATIC_AIR_US_JBAD_OH58D_01 bis _07

4 AH-64D:
STATIC_AIR_US_JBAD_AH64D_01 bis _04

4 UH-60A:
STATIC_AIR_US_JBAD_UH60_01 bis _04

5 CH-47F:
STATIC_AIR_US_JBAD_CH47_01 bis _05
```

Gesamt:

```text
20 sichtbare Luftfahrzeug-Statics
```

Diese Statics sind Teil des logischen Bestands und kein zusätzlicher Bestand.

### 7.4 Warehouse-Anker

```text
WH_AIR_US_JALALABAD
Koalition: BLUE
Land: USA
```

Der Anker wurde von MOOSE als Static gefunden. Das native DCS-Warehouse und MOOSE-Storage sind verfügbar.

### 7.5 Funktionszonen

```text
ZONE_AIR_US_JBAD_STATIC_OH58D
ZONE_AIR_US_JBAD_STATIC_AH64D
ZONE_AIR_US_JBAD_STATIC_UH60
ZONE_AIR_US_JBAD_STATIC_CH47
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_CH47_READY
ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

Alle elf Zonen wurden im Abschlusslauf gefunden. Ihre spätere operative Verwendung durch AUFTRAG/OPSTRANSPORT ist noch separat zu testen.

## 8. Validierte DCS-Typen

```text
OH-58D: OH58D
AH-64D: AH-64D_BLK_II
UH-60A: UH-60A
CH-47F: CH-47Fbl1
```

Beide UH-60-MEDEVAC-Templates verwenden die validierte Livery:

```text
standard
```

## 9. MOOSE-Struktur und Bestandsabbildung

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

### 9.1 OH-58D

```text
Bestand: 24 Luftfahrzeuge
Templategröße: 2
MOOSE-Asset-Gruppen: 12
Capability: RECON
```

### 9.2 AH-64D

```text
Bestand: 8 Luftfahrzeuge
Templategröße: 2
MOOSE-Asset-Gruppen: 4
Capability: CAS
```

### 9.3 UH-60

```text
Bestand: 8 Luftfahrzeuge
Templategröße: 1
MOOSE-Asset-Gruppen: 8
Capabilities: TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE, GROUNDESCORT
```

Der Bestand wird als ein gemeinsames SQUADRON geführt. Lead und Cover sind getrennte Payload-/Templatevarianten, keine getrennten Bestände.

### 9.4 CH-47

```text
Bestand: 8 Luftfahrzeuge
Templategröße: 1
MOOSE-Asset-Gruppen: 8
Capabilities: TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE
Kanonischer DCS-Typ: CH-47Fbl1
```

## 10. MEDEVAC-Gruppenmodell

Das operative Two-Ship-Paket besteht aus zwei unabhängig taskbaren DCS-Gruppen:

```text
1 Lead-Single-Ship
+
1 Cover-Single-Ship
=
1 logisches MEDEVAC-Two-Ship-Paket
```

Verbindliche Regeln:

```text
PackageSize = 2
LeadAircraft = 1
CoverAircraft = 1
AllowSingleShip = false
DCSGroupModel = TWO_INDEPENDENT_SINGLE_SHIP_GROUPS
CoordinationModel = ONE_LOGICAL_MEDEVAC_PACKAGE
```

Der Grundaufbau und beide Payloads sind validiert. Der spätere Koordinator, der beide Assets atomar reserviert, gemeinsam startet, getrennt taskt und gemeinsam freigibt, ist noch ein eigener Laufzeittest.

## 11. Parkplatz- und Flächenmodell

### 11.1 DCS-Kapazität

```text
MOOSE-/DCS-Parking-Einträge: 50
für die reale Hubschrauberramp vergleichbare Positionen: ungefähr 36
```

Wichtige Bereiche:

```text
G01-G07   visueller OH-58D-Bereich
C01-C14   CH-47-/Heavy-Lift-Bereich
südliche und westliche Aprons für AH-64D und UH-60
```

### 11.2 Runtime-Parkbedarf

```text
6 reservierte Kern-Clientpositionen
4 freie dynamische KI-Reservepositionen
--------------------------------------
10 Runtime-Positionen im Kernstand

+ 2 optionale UH-60L-Clientpositionen
= 12 Runtime-Positionen mit Modvariante
```

Die sieben Template-Luftfahrzeuge werden nicht als dauerhaft belegte Runtime-Parkplätze gezählt.

### 11.3 CH-47-Ramp C01-C14

```text
14 visuelle Heavy-Lift-Positionen
- 5 sichtbare CH-47-Statics
- 2 CH-47-Clientpositionen
= 7 verbleibende Positionen
```

Sieben verbleibende CH-47-Positionen sind bei maximal vier gleichzeitig aktiven KI-Unterstützungsluftfahrzeugen ausreichend.

### 11.4 Dauerhafte CH-47-Static-Reservierungen

Vier CH-47-Statics stehen absichtlich auf echten DCS-Parking-Nodes:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49, Abstand 4.1 m
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37, Abstand 4.4 m
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23, Abstand 4.7 m
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35, Abstand 5.4 m
```

MOOSE-Blacklist:

```text
23,35,37,49
```

Zusätzlich schützt:

```lua
AIRWING:SetSafeParkingOn()
```

unbesetzte Clientpositionen vor dynamischen KI-Spawns.

`STATIC_AIR_US_JBAD_CH47_05` liegt mit 33.5 m Abstand nicht auf einem funktionalen Parking-Node.

Die automatische Prüfung bestätigte:

```text
intentionalReservationsConfirmed=4
blacklistedTerminalIDs=23,35,37,49
ch47VisualPositionsRemaining=7
unexpectedOverlaps=0
AIRWING_START_BLOCKED=false
```

Für OH-58D-, AH-64D- und UH-60-Statics bleibt freie Apronplatzierung der Regelfall. Eine echte Parking-Belegung ist nur nach ausdrücklicher Dokumentation und technischer Blacklist zulässig.

## 12. Aktivitätsgrenzen

```text
maximale Spieler-Luftfahrzeuge je nutzbarem Typ in Jalalabad: 2
maximale gleichzeitig aktive KI-Luftfahrzeuge je Typ und Basis: 4
maximale parallele Unterstützungsmissionen: 2
maximale Luftfahrzeuge je Unterstützungsmission: 2
maximale gleichzeitig aktive Unterstützungs-Luftfahrzeuge: 4
```

Diese Grenzen sind von der logischen SQUADRON-Größe zu unterscheiden.

## 13. Aktuelle Build-Reihenfolge

```text
01-jalalabad-bootstrap.lua
02-dump-airbase-parking.lua
03-probe-warehouse-anchor.lua
04-dump-aircraft-types.lua
05-validate-mission-templates.lua
06-construct-oh58d-squadron.lua
07-construct-ah64d-squadron.lua
08-construct-uh60-squadron.lua
09-construct-ch47-squadron.lua
10-validate-static-parking-clearance.lua
10-validate-and-start-complete-node.lua
```

Die Reihenfolge wird ausdrücklich durch den PowerShell-Builder festgelegt. Der doppelte numerische Präfix `10` ist technisch unschädlich, darf aber bei einer späteren Umbenennung nur zusammen mit dem Builder geändert werden.

## 14. Chronologische Test- und Fehlerhistorie

### 14.1 Branchwechsel und Pull auf falschem Branch

Ein lokal verändertes generiertes TM02-Bundle blockierte zunächst den Branchwechsel. Ein danach ausgeführtes `git pull --ff-only` aktualisierte den weiterhin aktiven falschen Branch.

Gegenmaßnahme:

- vor jedem Pull `git branch --show-current`,
- lokale Änderungen mit `git status --short` prüfen,
- blockierende Dateien gezielt staschen,
- erwarteten Commit mit `git rev-parse HEAD` kontrollieren.

### 14.2 Erster reproduzierbarer Build

```text
Commit: 69c037beb94bc38befb3eff78021e42da2f51d5c
Bundlegröße: 9489 Bytes
SHA-256: 7b754cd8f964a868b65b95c62b01c5c1891abf01160ebc72f5d20e0d3995036a
```

Builder-Ausgabe und unabhängiges `Get-FileHash` stimmten überein.

### 14.3 Erster DCS-Diagnoselauf: PARTIAL

PASS:

- Jalalabad erkannt,
- Airbase-ID 19,
- 50 Parking-Einträge,
- leerer Gruppen-/Static-/Zonenstand erkannt.

FAIL:

```text
STATIC not found for: WH_AIR_US_JALALABAD
Error in timer function
```

Ursache:

```lua
STATIC:FindByName(name)
```

wirft bei fehlendem Static in der verwendeten MOOSE-Version standardmäßig einen Fehler.

Korrektur:

```lua
STATIC:FindByName(name, false)
```

### 14.4 Retest ohne Warehouse-Anker: PASS

Der erwartete leere Zustand wurde ohne Timerfehler verarbeitet. DCS-Warehouse und MOOSE-Storage waren verfügbar; der Bootstrap wartete kontrolliert auf den Anker.

### 14.5 Erster Warehouse-Anker-Lauf: FAIL durch nicht gespeicherten Namen

Das Objekt war sichtbar, der Name `WH_AIR_US_JALALABAD` aber nicht korrekt in der gespeicherten Mission hinterlegt.

Erkenntnis:

Bei sichtbaren, aber nicht gefundenen ME-Objekten zuerst Gruppen-/Einheitenname und gespeicherte `.miz` prüfen.

### 14.6 Warehouse-Anker und AIRWING-Konstruktion: PASS

Bestätigt:

```text
STATIC found=true
coalition=Blue
country=USA
DCS warehouse available=true
MOOSE storage available=true
AIRWING constructed and explicitly linked
```

Das AIRWING blieb in dieser isolierten Stufe ungestartet.

### 14.7 OH-58D-SQUADRON: PASS

```text
Template: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
Typ: OH58D
Bestand: 24
Asset-Gruppen: 12
Capability: RECON
```

### 14.8 AH-64D-SQUADRON: PASS

```text
Template: TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
Typ: AH-64D_BLK_II
Bestand: 8
Asset-Gruppen: 4
Capability: CAS
```

### 14.9 Unbesetzte Client-Slots zunächst falsch geprüft

Unbesetzte `Client`-Gruppen sind nicht zuverlässig als aktive MOOSE-`GROUP` verfügbar.

Korrektur:

```lua
_DATABASE.Templates.Groups
```

wird zur Validierung von Client-Slots und Late-Activation-Templates verwendet.

### 14.10 Zu frühe Vollständigkeitserklärung `24/8/6`

Die erste Planung ließ das CH-47-Element aus und setzte den UH-60-Bestand zu niedrig an.

Verworfen:

```text
24 OH-58D / 8 AH-64D / 6 UH-60
```

Korrigiert:

```text
24 OH-58D / 8 AH-64D / 8 UH-60 / 8 CH-47
```

Der Abschlussgate wurde bis zur vollständigen Korrektur gesperrt.

### 14.11 Parkplatzanalyse und Spielerreduktion

Die reale Ramp ist in DCS nicht 1:1 reproduzierbar. Für den sichtbaren OH-58-Bereich mit mehr als zehn Maschinen stehen in DCS nur sieben geeignete G-Positionen zur Verfügung.

Entscheidung:

```text
Spielerplätze von 4 auf 2 je Typ reduzieren
Gesamtbestand virtuell führen
sichtbare Statics begrenzen
```

### 14.12 Vollständige Einheiten und Statics, Zonen noch fehlend: PARTIAL PASS

Bestätigt wurden:

```text
6/6 Clientgruppen
5/5 KI-Templates
20/20 Statics
4/4 SQUADRONs
```

Blocker:

```text
0/11 Zonen
```

Zusätzlich verwendete das UH-60-Cover-Template irrtümlich die Livery `Egyptian Air Force`. Die Livery wurde auf `standard` korrigiert und anschließend durch Code validiert.

### 14.13 Vollständiger Missionseditor-Stand, falscher Finalizer: PARTIAL

Alle ME-Objekte und SQUADRONs waren korrekt. Der Builder band jedoch noch den veralteten Finalizer ein, der das aufgehobene Parkplatzmodell mit 13 beziehungsweise 15 Operationspositionen prüfte.

Korrektur:

- veralteten Finalizer entfernt,
- `10-validate-and-start-complete-node.lua` eingebunden,
- Builder auf `JBAD-AIR-OPS-COMPLETE-4` und anschließend `-5` angehoben.

### 14.14 CH-47-Statics zunächst als unerwünschte Parking-Überlappung bewertet

Vier CH-47-Statics lagen 4.1 bis 5.4 m von echten Parking-Mittelpunkten entfernt. Die erste Gegenmaßnahme verlangte fälschlich ein Verschieben.

Nach erneuter Bewertung wurde festgestellt:

- die DCS-Ramp bietet keine glaubwürdigen alternativen CH-47-Flächen,
- fünf Statics und zwei Clients lassen sieben C-Positionen frei,
- diese Kapazität reicht für die festgelegten Aktivitätsgrenzen.

Korrekte Lösung:

- Statics bleiben stehen,
- TerminalIDs `23,35,37,49` werden blacklisted,
- Safe Parking schützt Clientpositionen,
- Validator unterscheidet deklarierte Reservierungen von unbeabsichtigten Überlappungen.

### 14.15 Vollständiger DCS-Abschlusslauf: PASS

Finale Parkplatzmeldung:

```text
[OMW][AirOps.JBAD.PARKING] RESULT: PASS intentionalReservationsConfirmed=4 blacklistedTerminalIDs=23,35,37,49 ch47VisualPositionsRemaining=7 unexpectedOverlaps=0 AIRWING_START_BLOCKED=false
```

Finale Abschlussmeldung:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

Finale Zusammenfassung:

```text
inventory=OH58D:24/AH64D:8/UH60:8/CH47:8
corePlayerSlots=6
optionalUH60L=0or2
dynamicAIReserve=4
runtimeParking=10or12
templateAircraft=7nonRuntime
staticCaps=OH58D:7/AH64D:4/UH60:4/CH47:5
zones=11
templates=5
squadrons=4
medevac=twoIndependentSinglesAsOnePackage
virtualReserve=true
```

## 15. Runtime-Beobachtung des Abschlusslaufs

```text
Missionsdauer laut Debrief: 81.562 Sekunden
AIRWING/COMMANDER aktiv nach Abschlussmeldung: ungefähr 66 Sekunden
```

Registriert wurden:

- Missionsstart,
- Spielerübernahme von `CLIENT_US_JBAD_OH58D_01-1`,
- ein unabhängiger Engine-Start einer bestehenden OH-58D in Bagram bei ungefähr `t=78.5`,
- Missionsende.

Nicht registriert wurden für Jalalabad:

- KI-Birth/Spawn,
- Engine Start,
- Takeoff,
- Landing,
- Crash,
- Dead/Loss.

Damit ist das Kriterium `spontaneousSpawns=0` erfüllt.

## 16. Externe Fehler und Meldungen

Kein relevanter OMW-Jalalabad-Lua- oder Timerfehler trat auf.

Der bekannte externe Shutdown-Fehler blieb bestehen:

```text
Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua:168
attempt to index upvalue 'tcp' (a nil value)
```

Er tritt nach `Dispatcher Stop` auf und gehört nicht zum Jalalabad-AirOps-Bundle.

Weitere DCS-, Terrain-, Modul-, OH-58D- und CH-47-Warnungen unterbrachen den Test nicht und erzeugten keinen OMW-Fehler.

## 17. Was gut funktioniert hat

- Repository-basierter Source-/Builder-Workflow.
- Reproduzierbarer PowerShell-Build mit Commit- und SHA-Ausgabe.
- Hashnachweis des tatsächlich in die `.miz` eingebetteten Bundles.
- Zuverlässige MOOSE-Erkennung von Jalalabad und allen 50 Parking-Einträgen.
- Benannter Static als AIRWING-Warehouse-Anker.
- Explizite AIRWING-Airbase-Zuordnung.
- Korrekte Umrechnung von Luftfahrzeugbestand in Asset-Gruppen.
- Typ- und Liveryprüfung über Mission-Templates.
- Fail-safe Abschlussgate bei fehlenden Objekten oder falscher Konfiguration.
- Parking-Blacklist für absichtlich belegte Static-Parkplätze.
- Safe Parking für Client-Slots.
- vollständiger AIRWING- und COMMANDER-Start ohne spontane Mission.
- `dcs.log` als Standardnachweis; `.miz` nur an entscheidenden Meilensteinen.

## 18. Was nicht gut funktioniert hat

- Zu viele kleine Einzelschritte verlängerten die Umsetzung unnötig.
- Branch und lokaler Status wurden anfangs nicht ausreichend abgesichert.
- Ein nicht gespeicherter ME-Name wurde zunächst wie ein Codefehler behandelt.
- Client-Slots sollten zunächst über die falsche Runtime-Abstraktion geprüft werden.
- Historische ORBAT und Satellitenbilder wurden zu spät vollständig berücksichtigt.
- Logischer Bestand, Statics und Parking wurden zunächst vermischt.
- Der Builder band zeitweise einen veralteten Finalizer ein.
- Eine legitime CH-47-Static-Belegung wurde zunächst pauschal als Kollision bewertet.
- Zwischenstände blieben in mehreren Dokumenten länger als aktuelle Vorgabe stehen.

## 19. Projektweite Gegenmaßnahmen

- verbindlicher Testmissions-Workflow in Dokument 22,
- Branch, Status und Commit vor jedem Build prüfen,
- Bundlehash nach jedem Build prüfen,
- Bundle im Mission Editor erneut auswählen und `.miz` speichern,
- keine Vollständigkeitserklärung ohne historische Plausibilitätsprüfung und DCS-Gesamttest,
- Bestand, aktive Assets, Statics und virtuelle Reserve getrennt modellieren,
- erwartete Objektfehler nicht durch fehlerwerfende Wrapperaufrufe behandeln,
- Client-Slots über Mission-Template-Datenbank validieren,
- Static-Parking-Ausnahmen explizit dokumentieren und technisch blacklisten,
- nach Abschluss eines Meilensteins alle autoritativen Dokumente auf veraltete Zwischenstände prüfen.

## 20. Verbindlicher Repository- und Übertragungsablauf

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
git switch feature/jalalabad-air-operations-diagnostics
git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"

Get-FileHash `
  .\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua `
  -Algorithm SHA256
```

Danach im DCS-Missionseditor:

1. vorhandene Aktion `DO SCRIPT FILE` öffnen,
2. `OMW_AirOps_Jalalabad.lua` erneut auswählen,
3. Mission speichern,
4. Test gemäß Acceptance-Dokument ausführen,
5. standardmäßig nur die aktuelle `dcs.log` bereitstellen.

Ein externer Neubau aktualisiert eine bereits gespeicherte `.miz` nicht automatisch.

## 21. Abschlussentscheidung und Folgeumfang

Der lokale Jalalabad-Air-Ops-Grundknoten ist abgeschlossen und validiert.

Bestätigt sind:

- komplette Missionseditor-Namen, Typen und Anzahlen,
- Airbase-ID 19 und 50 Parking-Einträge,
- Warehouse-Anker, DCS-Warehouse und MOOSE-Storage,
- vier SQUADRONs und deren Bestandsabbildung,
- Payloadregistrierung,
- CH-47-Parking-Blacklist und Safe Parking,
- AIRWING-Start,
- COMMANDER-Verknüpfung und Start,
- keine spontane Jalalabad-KI-Mission.

Noch nicht Bestandteil dieses Abschlusses sind:

- taktische AUFTRAG-Erzeugung und Missionsabschluss,
- OPSTRANSPORT für Truppen und Fracht,
- operative Nutzung der Lade-/Entladezonen,
- vollständiger 1+1-MEDEVAC-Laufzeitkoordinator,
- persistente Verlustrechnung über Missionsneustarts,
- persistente Static-/Ramp-Neuverteilung,
- Combat-Damage-, Recovery- und Replacement-State-Integration.

Diese Punkte sind eigenständige nächste Projektstufen und keine offenen Fehler des validierten Jalalabad-Grundaufbaus.
