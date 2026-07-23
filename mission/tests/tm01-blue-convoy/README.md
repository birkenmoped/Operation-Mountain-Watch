# TM01 – Blauer Straßenkonvoi Bagram–Jalalabad

## Ziel

TM01 untersucht die zuverlässige Führung eines blauen KI-Konvois auf der Hauptstraßenverbindung von Bagram nach Jalalabad.

Der Test trennt die physische MOOSE-Steuerung von der späteren Virtualisierung. Cargo Units, Ladung, Warehouses, Feindkräfte und CampaignState-Persistenz sind ausdrücklich nicht Bestandteil dieser Testreihe.

## Testobjekt

Vorgesehene physische Gruppe:

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
```

Entwurf der Zusammensetzung:

```text
1. Lead HMMWV oder MRAP
2. vorderer HMMWV, MRAP oder Gun Truck
3. schwerer Transport-Lkw
4. schwerer Transport-Lkw
5. Führungs-, Berge- oder Sicherungsfahrzeug
6. rückwärtiger HMMWV oder MRAP
```

Die Lkw führen in TM01 noch keine Cargo-Manifeste. Die Zusammensetzung prüft nur Gruppenführung, Reihenfolge, Geschwindigkeit, Engstellen und Verluste.

## Gemeinsame MOOSE-Komponenten

```text
TestMissionController
├── TestMenu
├── DebugReporter
├── RouteRegistry
├── RouteMonitor
└── ConvoyController
```

Stufe B ergänzt:

```text
ConvoyVirtualizer
MaterializationAnchorRegistry
```

## Stufe A – physische Baseline

Missionsdatei:

```text
TM01A-MOOSE-Blue-Convoy-Physical.miz
```

### Funktionsumfang

- MOOSE wird zuerst geladen;
- die Late-Activation-Templategruppe wird über `SPAWN` erzeugt;
- `ConvoyController` weist die geprüfte Route zu;
- RouteMonitor erfasst Kontrollpunkte, Geschwindigkeit und Stillstand;
- F10-Menü startet, stoppt und setzt den Test zurück;
- der Konvoi bleibt von Bagram bis Jalalabad physisch;
- keine Virtualisierung oder automatische Reparatur.

### Mission-Editor-Objekte

Pflichtobjekte:

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
ZONE_TM01_START_BAGRAM
ZONE_TM01_TARGET_JALALABAD
ZONE_TM01_ROUTE_01
ZONE_TM01_ROUTE_02
ZONE_TM01_ROUTE_03
ZONE_TM01_ROUTE_04
ZONE_TM01_ROUTE_05
ZONE_TM01_ROUTE_06
ZONE_TM01_ROUTE_07
```

Die Anzahl der Routenanker darf nach Streckenprüfung erhöht werden. Kritische Kreuzungen, Engstellen, Ortsdurchfahrten, Brücken und Richtungswechsel erhalten eigene Anker.

### Routing

Die Route wird als explizite, versionierte Reihenfolge von Ankern geführt. MOOSE baut daraus die physische Route und weist sie dem Konvoi zu.

Die Route muss:

- auf der gewünschten Hauptstraßenachse bleiben;
- an kritischen Abzweigungen eindeutig sein;
- keine unvalidierten Querfeldeinsegmente enthalten;
- abschnittsweise testbar sein;
- einen eindeutigen Zielbereich besitzen.

### Watchdog

Beobachtete Zustände:

```text
SPAWNING
ROUTING
MOVING
SLOW
STOPPED
STUCK
ARRIVED
DESTROYED
FAILED
```

Erster Richtwert für `STUCK`:

```text
Geschwindigkeit unter 1 km/h
für mindestens 120 Sekunden
außerhalb eines erlaubten Haltezustands
und außerhalb der Zielzone
```

Der Watchdog meldet den Fehler, verändert die Gruppe aber nicht automatisch.

### Abnahmekriterien

Stufe A ist bestanden, wenn:

1. genau eine physische Konvoigruppe erzeugt wird;
2. die sechs vorgesehenen Fahrzeuge korrekt vorhanden sind;
3. der Konvoi die Kontrollpunkte in der festgelegten Reihenfolge passiert;
4. kein überlebendes Fahrzeug dauerhaft an einer Engstelle verbleibt;
5. keine unplausible Abkürzung außerhalb der validierten Route erfolgt;
6. kurzfristiges Aufstauen sich ohne Skripteingriff auflöst;
7. der Konvoi die Jalalabad-Zielzone erreicht;
8. alle Zustandswechsel und Kontrollpunkte im Log erscheinen;
9. Reset keinen zweiten aktiven Konvoi zurücklässt.

## Stufe B – virtuelle Bewegung

Missionsdatei:

```text
TM01B-MOOSE-Blue-Convoy-Virtualized.miz
```

### Zustandsmodell

```text
VIRTUAL_MOVING
MATERIALIZING
PHYSICAL_MOVING
DEMATERIALIZING
VIRTUAL_MOVING
ARRIVED
FAILED
```

### Reveal-Abschnitte

Pflichtzonen:

```text
ZONE_TM01_REVEAL_01_ENTRY
ZONE_TM01_REVEAL_01_EXIT
ZONE_TM01_REVEAL_02_ENTRY
ZONE_TM01_REVEAL_02_EXIT
```

Der virtuelle Konvoi wird vor dem Entry-Anker materialisiert, durch den physischen `ConvoyController` geführt und nach dem Exit-Anker wieder dematerialisiert.

Die beiden Reveal-Abschnitte sollen unterschiedliche Routensituationen abdecken, beispielsweise:

- einen relativ geraden Straßenabschnitt;
- einen Abschnitt mit Kurven, Kreuzung oder enger Ortsdurchfahrt.

### Virtueller Zustand

Mindestens zu speichern:

```lua
{
  convoyId = "TEST.TM01.CONVOY.001",
  state = "VIRTUAL_MOVING",
  routeId = "ROUTE_TM01_BAGRAM_JALALABAD",
  segmentIndex = 1,
  segmentProgress = 0,
  survivingVehicleSlots = { 1, 2, 3, 4, 5, 6 },
  virtualSpeedKph = 30,
}
```

### Materialisierung

Beim Materialisieren:

1. aktuellen Segmentfortschritt auf einen geprüften Straßenanker abbilden;
2. das Template mit der noch vorhandenen Zusammensetzung erzeugen;
3. dieselbe physische Reststrecke wie in Stufe A zuweisen;
4. stabile Convoy-ID dem Laufzeitobjekt zuordnen;
5. doppelte physische Instanzen ausschließen.

Beim Dematerialisieren:

1. aktuelle Position und Segmentfortschritt bestimmen;
2. vorhandene Fahrzeuge und Verluste erfassen;
3. physischen Controller sauber beenden;
4. physische Gruppe entfernen;
5. virtuelle Bewegung mit demselben Zustand fortsetzen.

### Sichtbarer Debugmodus

TM01B soll das Ein- und Auspacken absichtlich beobachtbar machen:

- Spieler- oder Beobachterslots in der Nähe der Reveal-Abschnitte;
- Kartenmarker für virtuellen Fortschritt;
- Nachrichten vor Materialisierung und Dematerialisierung;
- sichtbare Kennzeichnung der Entry- und Exit-Zonen;
- optional verlangsamter Übergang im Debugmodus.

Diese Sichtbarkeit ist eine Testfunktion und kein Vorbild für die spätere Produktionsvirtualisierung.

### Abnahmekriterien

Stufe B ist bestanden, wenn:

1. der virtuelle Konvoi beide Reveal-Abschnitte in korrekter Reihenfolge erreicht;
2. bei jeder Materialisierung genau eine physische Gruppe entsteht;
3. die erste Materialisierung mit der erwarteten Zusammensetzung erfolgt;
4. die Gruppe im Reveal-Abschnitt durch denselben Controller wie Stufe A geführt wird;
5. nach jeder Dematerialisierung keine Restgruppe verbleibt;
6. Segmentfortschritt und Zeit nach dem Einpacken weiterlaufen;
7. ein absichtlich verlorenes Fahrzeug bei der zweiten Materialisierung fehlt;
8. Convoy-ID und Fahrzeugslot-Zuordnung erhalten bleiben;
9. der Konvoi abschließend Jalalabad erreicht;
10. kein Zustand gleichzeitig `VIRTUAL` und `PHYSICAL` ist.

## Nicht Bestandteil

- Fracht und Cargo Units;
- Warehouse-Gutschriften;
- Feindkontakte oder Hinterhalte;
- Spielerentfernungs- und Sichtlinienautomatik;
- Persistenz über Missionsneustart;
- automatische Teleport- oder Unstuck-Logik;
- mehrere Konvois oder Serials.

## Offene Mission-Editor-Arbeit

- genaue Hauptstraßenroute Bagram–Jalalabad abfahren und validieren;
- geeignete Routenanker platzieren;
- zwei Reveal-Abschnitte festlegen;
- Fahrzeuge des Templates gegen verfügbare DCS-Typen prüfen;
- Beobachter- und Debugslots anlegen;
- Streckenabschnitte einzeln testen, bevor der Gesamtlauf bewertet wird.
