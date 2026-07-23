# 23 – Jalalabad: Parkplätze, Templates, Statics und MEDEVAC-Gruppenmodell

## Status

Dieses Dokument beschreibt das im finalen DCS-Abschlusslauf bestätigte Parkplatz-, Template-, Static- und MEDEVAC-Grundmodell für Jalalabad / FOB Fenty.

```text
Status: VALIDATED
Finaler Builder: JBAD-AIR-OPS-COMPLETE-5
Finaler Source-Commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
```

Ergänzend verbindlich:

```text
docs/21-jalalabad-air-operations-manifest.md
docs/24-jalalabad-ch47-static-parking-reservations.md
docs/25-jalalabad-final-validation-and-operational-baseline.md
```

## 1. Vier unterschiedliche Platzierungsarten

### 1.1 Spielerplätze

Spielergruppen benötigen echte, für den jeweiligen Typ geeignete DCS-Parkpositionen.

Jalalabad-Kernstand:

```text
6 reservierte Spielerpositionen

2 OH-58D
2 AH-64D
2 CH-47
```

Optional kommen zwei UH-60L-Spielerpositionen hinzu.

Unbesetzte Clientpositionen werden durch:

```lua
AIRWING:SetSafeParkingOn()
```

vor dynamischen KI-Spawns geschützt.

### 1.2 Dynamische KI-Parkplätze

MOOSE-AIRWING erzeugt die tatsächlichen Einsatzgruppen dynamisch am zugeordneten Flugplatz.

Dafür werden mindestens vier freie funktionale Runtime-Parkpositionen vorgehalten:

```text
mindestens 2 CH-47-taugliche Positionen
mindestens 2 kleine oder mittlere Hubschrauberpositionen
```

Diese vier Positionen entsprechen der globalen Obergrenze von maximal vier gleichzeitig aktiven KI-Unterstützungsluftfahrzeugen.

### 1.3 Late-Activation-Templates

Die fünf KI-Templategruppen enthalten zusammen sieben Luftfahrzeuge:

```text
2 OH-58D
2 AH-64D
1 UH-60A MEDEVAC Lead
1 UH-60A MEDEVAC Cover
1 CH-47F
```

Sie dienen als Authoring-/Seedvorlagen für:

- Luftfahrzeugtyp,
- Gruppengröße,
- Livery,
- Payload,
- Skill,
- Formation,
- Startart,
- weitere DCS-Gruppeneigenschaften.

Sie werden wegen `Late Activation` nicht als operative Gruppen aktiviert und nicht als sieben dauerhaft belegte Runtime-Parkplätze gezählt.

### 1.4 Sichtbare Statics

Statics sind eine visuelle Darstellung des logischen Bestands und kein zusätzlicher Bestand.

Regelfall:

- freie Apronplatzierung,
- ausreichender Rotorabstand,
- keine unbeabsichtigte Belegung funktionaler Spawn- oder Rückkehrpositionen.

Ausnahme:

Ein Static darf einen echten DCS-Parking-Node dauerhaft belegen, wenn:

1. diese Belegung missionsgestalterisch erforderlich ist,
2. Static und TerminalID ausdrücklich dokumentiert sind,
3. der TerminalID technisch aus dem MOOSE-Parkpool entfernt wird,
4. die verbleibende Kapazität ausreicht,
5. ein Validator die Zuordnung bestätigt.

Diese Ausnahme wird aktuell für vier CH-47-Statics verwendet.

## 2. Validiertes Runtime-Parkmodell

Die frühere Rechnung:

```text
20 Statics + 13 Operationspositionen = 33 von 36
```

war konzeptionell falsch, weil sie:

- frei platzierte Statics wie funktionale Parking-Nodes behandelte,
- Late-Activation-Templatepositionen als dauerhaft belegte Runtime-Plätze zählte.

Korrektes Runtime-Modell:

```text
6 Kern-Spielerpositionen
4 dynamische KI-Reservepositionen
--------------------------------
10 Runtime-Positionen im Kernstand

+ 2 optionale UH-60L-Spielerpositionen
= 12 Runtime-Positionen mit Modvariante
```

Zusätzliche bestätigte Werte:

```text
MOOSE-/DCS-Parking-Einträge: 50
visuell oder funktional vergleichbare Hubschrauberpositionen: ungefähr 36
Template-Luftfahrzeuge: 7, nicht dauerhaft runtimebelegend
```

Der Abschlussvalidator bestätigte:

```text
OK RAMP_MODEL inventoryVirtual=true clients=6 optionalClients=2 dynamicAIReserve=4 runtimeDemand=10or12 templateAircraft=7nonRuntime comparablePositions=36 ...
```

## 3. Müssen Templates auf echten Parkplätzen stehen?

Für die robuste Missionsdatei sollen Templates:

- am richtigen Flugplatz Jalalabad,
- mit gültigem `Takeoff from parking cold`,
- auf einer für den Typ geeigneten DCS-Parkposition

angelegt werden.

Das stellt eine korrekte Airbase-, Startart- und Routenvorlage sicher.

Die Templateposition ist jedoch keine dauerhaft reservierte spätere Einsatzposition. Der tatsächliche AIRWING-Spawn wird durch:

- AIRWING,
- zugeordnete Airbase,
- Parking-Blacklist,
- Safe Parking,
- zur Laufzeit verfügbare Positionen

bestimmt.

## 4. Rampbereiche G01-G07 und C01-C14

### 4.1 G01-G07

- visueller OH-58D-Bereich,
- sieben OH-58D-Statics,
- Statics frei und plausibel platziert,
- keine dokumentierte Belegung echter DCS-Parking-Nodes,
- operative Spieler-/KI-Positionen bleiben getrennt.

### 4.2 C01-C14

Der CH-47-/Heavy-Lift-Bereich umfasst 14 visuelle Positionen:

```text
5 sichtbare CH-47-Statics
2 CH-47-Clientpositionen
7 verbleibende Positionen
```

Die sieben verbleibenden Positionen sind für die festgelegten Betriebsgrenzen ausreichend.

Vier CH-47-Statics stehen absichtlich auf echten Parking-Nodes:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35
```

Blacklist:

```text
23,35,37,49
```

`STATIC_AIR_US_JBAD_CH47_05` steht frei und benötigt keinen Blacklist-Eintrag.

Der finale Validator bestätigte alle vier Reservierungen und keine unerwartete weitere Überlagerung.

## 5. Static-Parking-Validierung

Für deklarierte Reservierungen gilt:

- erwarteter Static-Name,
- erwarteter TerminalID,
- maximal 8 m Abstand vom Terminalmittelpunkt,
- TerminalID in der Blacklist.

Für nicht deklarierte Statics gilt:

- mindestens 8 m Abstand zum nächsten funktionalen Parking-Mittelpunkt.

Final bestätigte CH-47-Abstände:

```text
CH47_01 -> TerminalID 49 -> 4.1 m
CH47_02 -> TerminalID 37 -> 4.4 m
CH47_03 -> TerminalID 23 -> 4.7 m
CH47_04 -> TerminalID 35 -> 5.4 m
CH47_05 -> nächster Parking-Node -> 33.5 m
```

Finale Meldung:

```text
[OMW][AirOps.JBAD.PARKING] RESULT: PASS intentionalReservationsConfirmed=4 blacklistedTerminalIDs=23,35,37,49 ch47VisualPositionsRemaining=7 unexpectedOverlaps=0 AIRWING_START_BLOCKED=false
```

## 6. Warum MEDEVAC aus zwei Single-Ship-Gruppen besteht

`Two-Ship-Paket` bezeichnet die operative Einheit aus zwei Luftfahrzeugen, nicht zwingend eine einzige DCS-Gruppe mit zwei Units.

Gewünschtes Verhalten:

```text
Lead:
- fliegt zur Aufnahmezone,
- landet,
- übernimmt Verwundete oder Personal,
- fliegt anschließend zur Übergabezone.

Cover:
- bleibt unabhängig steuerbar,
- hält Orbit oder Sicherungsposition,
- übernimmt Escort-/Ground-Escort-Aufgabe,
- landet nicht zwingend zusammen mit dem Lead.
```

Eine gemeinsame DCS-Gruppe mit zwei Units teilt grundsätzlich Gruppenroute und Gruppenauftrag. Das verhindert beziehungsweise erschwert:

```text
Luftfahrzeug 1 landet
Luftfahrzeug 2 bleibt gleichzeitig im Sicherungsorbit
```

Deshalb werden verwendet:

```text
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
```

Beide Gruppen stammen aus demselben logischen UH-60-SQUADRON-Bestand von acht Luftfahrzeugen.

```text
1 Lead-Single-Ship-Gruppe
+
1 Cover-Single-Ship-Gruppe
=
1 logisches MEDEVAC-Two-Ship-Paket
```

Es handelt sich nicht um zwei unabhängige MEDEVAC-Missionen und nicht um zwei getrennte Bestände.

## 7. Validierter MEDEVAC-Grundstand

Im Bundle festgeschrieben und im Abschlussvalidator bestätigt:

```text
PackageSize = 2
LeadAircraft = 1
CoverAircraft = 1
AllowSingleShip = false
DCSGroupModel = TWO_INDEPENDENT_SINGLE_SHIP_GROUPS
CoordinationModel = ONE_LOGICAL_MEDEVAC_PACKAGE
```

Beide Templates:

```text
Typ: UH-60A
Livery: standard
Gruppengröße: 1
```

Das gemeinsame SQUADRON:

```text
SQ_US_JBAD_UH60_UTILITY_MEDEVAC
8 Luftfahrzeuge
8 Single-Ship-Asset-Gruppen
```

Der Abschlussvalidator meldete:

```text
OK MEDEVAC_MODEL package=2 DCSgroups=1lead+1cover independentTasking=true logicalPackage=true.
```

## 8. Noch nicht validierter MEDEVAC-Folgeumfang

Noch separat umzusetzen und zu testen ist ein Laufzeitkoordinator, der:

1. Lead und Cover atomar reserviert,
2. beide Assets gemeinsam startet,
3. Lead und Cover getrennt taskt,
4. einen Auftrag ohne vollständiges 1+1-Paket verhindert,
5. bei Ausfall einer Maschine korrekt abbricht oder neu bewertet,
6. beide Assets nach Abschluss gemeinsam freigibt,
7. Bestands- und Verlustzustand persistent aktualisiert.

Dieser Folgeumfang ist kein offener Fehler des validierten Jalalabad-Grundknotens.

## 9. Verbindliche Platzierungsregel

```text
Spieler:
auf echten, reservierten DCS-Parkpositionen
und durch Safe Parking geschützt

Dynamische KI:
mindestens vier echte freie Runtime-Parkpositionen
unter Berücksichtigung der Blacklist

Templates:
auf gültigen typgerechten Jalalabad-Parkpositionen,
aber nicht als dauerhaft belegte Runtime-Parkplätze zählen

Statics:
bevorzugt frei auf Apronflächen;
echte Parking-Belegung nur als ausdrücklich deklarierte,
blackgelistete und validierte Ausnahme
```

## 10. Abschlussnachweis

Der finale DCS-Lauf bestätigte:

- korrekte Client- und Templategruppen,
- 20 Statics,
- vier CH-47-Parking-Reservierungen,
- keine undeclared Static-Parking-Überlappung,
- Safe Parking,
- vier SQUADRONs,
- AIRWING-Start,
- COMMANDER-Verknüpfung,
- keine spontane Jalalabad-KI-Mission.

Damit sind Parkplatz-, Template-, Static- und MEDEVAC-Grundmodell für den lokalen Knoten angenommen.
