# TM02 – Rote Relaisbewegung

## Ziel

TM02 untersucht die gestaffelte Verteilung roter Personengruppen von einem zentralen Hauptquartier über mehrere Zwischenquartiere bis in den Zielraum Bagram.

Jeder Knoten behält eine definierte Mindestbesatzung. Nur Personal oberhalb dieser Mindestbesatzung wird weitergeleitet. Nachschub erfolgt immer vom unmittelbar vorherigen Knoten und nicht bei jedem Bedarf direkt aus dem Hauptquartier.

## Bewegungsmodell

TM02 verwendet ein Relaismodell und kein taktisches Überschlagen.

```text
Hauptquartier
→ Zwischenknoten 1
→ Zwischenknoten 2
→ Zwischenknoten 3
→ Zwischenknoten 4
→ Zielraum Bagram
```

Regeln:

- kein Knoten wird übersprungen;
- jeder Knoten hält seine Mindestbesatzung;
- eintreffendes Personal füllt zuerst Unterbesetzung auf;
- verbleibender Überschuss wird als lokale Reserve geführt;
- nur vollständige Personnel Packets werden weitergeschickt;
- höchstens drei Marschgruppen dürfen gleichzeitig aktiv sein;
- das Hauptquartier ersetzt nur Verluste des ersten Zwischenknotens unmittelbar;
- weiter entfernte Knoten werden aus dem jeweils vorherigen Knoten aufgefüllt.

## Testwerte

Die folgenden Zahlen sind erste, konfigurierbare Entwurfswerte:

```text
Personnel Packet:          6 Kämpfer
Grundbesatzung HQ:         18 Kämpfer
Grundbesatzung je Knoten:  12 Kämpfer
maximale Marschgruppen:     3
```

Die endgültigen Werte werden nach physischem DCS-Test angepasst.

## Gemeinsame MOOSE-Komponenten

```text
TestMissionController
├── TestMenu
├── DebugReporter
├── RedNodeRegistry
├── RedRelayController
├── PersonnelPacketManager
├── MovementDispatcher
└── RouteMonitor
```

Stufe B ergänzt:

```text
RedMovementVirtualizer
MaterializationAnchorRegistry
```

## Knotenzustand

Jeder Knoten besitzt mindestens:

```lua
{
  nodeId = "RED_NODE_02",
  minimumGarrison = 12,
  currentGarrison = 12,
  localReserve = 0,
  predecessorNodeId = "RED_NODE_01",
  successorNodeId = "RED_NODE_03",
}
```

Physische Gruppen und logischer Personalbestand werden getrennt betrachtet. Die Testlogik muss jederzeit nachweisen können, welche Personen als Grundbesatzung, Reserve oder Marschgruppe geführt werden.

## Personnel Packets

Marschbewegungen erfolgen in festen Paketen.

```text
1 Personnel Packet = 6 Kämpfer
```

Jedes Packet erhält eine stabile ID:

```text
TEST.TM02.PACKET.001
TEST.TM02.PACKET.002
```

Packets werden nicht während des Marsches geteilt oder zusammengeführt. Eine spätere Kampagnenversion kann differenziertere Stärken zulassen; der Test verwendet bewusst feste Einheiten.

## Stufe A – vollständig physische Relaisbewegung

Missionsdatei:

```text
TM02A-MOOSE-Red-Relay-Physical.miz
```

### Funktionsumfang

- MOOSE wird zuerst geladen;
- alle Grundbesatzungen bleiben physisch an ihren Knoten;
- Marschgruppen werden über Late-Activation-Templates erzeugt;
- jede Marschgruppe wird von MOOSE zum nächsten Knoten geführt;
- maximal drei Marschgruppen sind gleichzeitig aktiv;
- der Dispatcher startet neue Bewegungen zeitversetzt;
- keine Virtualisierung, Persistenz oder Kampagnenlogik;
- keine dynamischen Feindkräfte.

### Mission-Editor-Objekte

Pflichtgruppen:

```text
TPL_TEST_RED_HQ_GARRISON_18_01
TPL_TEST_RED_NODE_GARRISON_12_01
TPL_TEST_RED_PACKET_06_01
```

Pflichtzonen:

```text
ZONE_TM02_HQ
ZONE_TM02_NODE_01
ZONE_TM02_NODE_02
ZONE_TM02_NODE_03
ZONE_TM02_NODE_04
ZONE_TM02_TARGET_BAGRAM
```

Zwischen den Knoten werden geprüfte Routenkorridore und bei Bedarf zusätzliche Ankerzonen angelegt.

### Standortwahl

Der endgültige Hauptquartiersstandort und die Zwischenquartiere sind noch festzulegen.

Für den ersten technischen Test gelten folgende Anforderungen:

- zusammenhängender Bewegungsraum;
- physisch laufbare Segmente;
- keine extremen Steilhänge;
- keine erzwungene Flussquerung ohne validierten Übergang;
- möglichst wenige problematische Gebäudekollisionen;
- kurze bis mittlere Segmentlängen für schnelle Testzyklen;
- mindestens ein später als Reveal-Bereich geeigneter Zwischenabschnitt.

Der technische Test muss nicht sofort die endgültige historische Kette verwenden. Standort und Routen werden später gegen den geplanten Operationsraum ausgetauscht, ohne das Relaismodell zu ändern.

### Dispatcher

Globaler Grenzwert:

```text
MAX_ACTIVE_RED_MOVEMENTS = 3
```

Ein Dispatch-Zyklus:

1. Unterbesetzte Knoten vom Ziel rückwärts priorisieren;
2. prüfen, ob der direkte Vorgängerknoten genügend Personal oberhalb seiner Mindestbesatzung besitzt;
3. freien Movement Slot prüfen;
4. höchstens ein neues Packet pro Zyklus starten;
5. nächster Zyklus erst nach der konfigurierten Verzögerung.

Dadurch starten nicht alle Gruppen gleichzeitig.

### Ankunft

Bei Ankunft eines Packets:

1. Packet-ID und Zielknoten validieren;
2. Personenzahl dem Zielknoten zuordnen;
3. Unterbesetzung bis zur Mindestbesatzung auffüllen;
4. Rest als lokale Reserve führen;
5. physische Marschgruppe entfernen oder als ausdrücklich definierte lokale Reserve darstellen;
6. späteren Weitertransport nur durch neuen Dispatch auslösen.

### Physische Darstellung der Grundbesatzung

Grundbesatzungen:

- bleiben in unmittelbarer Nähe ihrer Unterkunft;
- besitzen keine Route zum nächsten Knoten;
- verwenden defensives Verhalten;
- werden nicht automatisch in Marschgruppen umgewandelt;
- bleiben während des gesamten Tests sichtbar.

Marschgruppen verwenden für den reinen Bewegungstest restriktive Einsatzregeln, damit zufällige Ziele nicht die Route dominieren.

### Zielraum Bagram

Der Test verwendet eine klar abgegrenzte Zielzone in oder unmittelbar bei Bagram.

Für TM02A dürfen keine blauen Kampfkräfte den Testablauf beeinflussen. Ziel ist die Bewegungs- und Relaislogik, nicht ein Angriff auf den Flugplatz.

### Abnahmekriterien

Stufe A ist bestanden, wenn:

1. Hauptquartier und alle Zwischenknoten ihre Mindestbesatzung erreichen;
2. Grundbesatzungen ihre Knoten nicht verlassen;
3. nur Personal oberhalb der Mindestbesatzung weitergeleitet wird;
4. kein Packet einen Knoten überspringt;
5. höchstens drei Marschgruppen gleichzeitig aktiv sind;
6. ein unterbesetzter Knoten vor einer Weiterleitung aufgefüllt wird;
7. Überschüsse schrittweise bis zum Zielraum weitergegeben werden;
8. jedes Packet genau einem Quell- und Zielknoten zugeordnet bleibt;
9. keine Person durch Spawn, Ankunft oder Gruppenentfernung dupliziert wird;
10. der Gesamtpersonalbestand erhalten bleibt;
11. alle Marschgruppen entweder ankommen oder einen eindeutigen Fehlerstatus erhalten;
12. überzähliges Personal abschließend den Bagram-Zielraum erreicht.

## Stufe B – virtuelle Relaisbewegung

Missionsdatei:

```text
TM02B-MOOSE-Red-Relay-Virtualized.miz
```

### Grundregel

Grundbesatzungen bleiben physisch an ihren Knoten. Nur Marschgruppen werden zwischen den Reveal-Bereichen virtualisiert.

### Zustandsmodell eines Packets

```text
QUEUED
MATERIALIZING
PHYSICAL_MOVING
DEMATERIALIZING
VIRTUAL_MOVING
ARRIVED
FAILED
```

Beispielzustand:

```lua
{
  packetId = "TEST.TM02.PACKET.014",
  strength = 6,
  sourceNodeId = "RED_NODE_02",
  destinationNodeId = "RED_NODE_03",
  segmentIndex = 1,
  segmentProgress = 0.61,
  state = "VIRTUAL_MOVING",
}
```

### Reveal-Bereiche

Pflichtzonen:

```text
ZONE_TM02_REVEAL_INTERMEDIATE_ENTRY
ZONE_TM02_REVEAL_INTERMEDIATE_EXIT
ZONE_TM02_TARGET_BAGRAM
```

Ablauf:

```text
virtueller Marsch
→ Materialisierung vor Zwischenbereich
→ physischer Marsch durch Zwischenbereich
→ Dematerialisierung nach Zwischenbereich
→ virtueller Marsch
→ Materialisierung im Bagram-Zielraum
```

Nicht jedes Packet muss zwingend denselben Reveal-Bereich passieren, sofern seine Route dort nicht entlangführt. Für den ersten Test wird die Kette so angelegt, dass mindestens ein Packet beide Materialisierungen durchläuft.

### Virtualisierung

Der virtuelle Adapter speichert mindestens:

- Packet-ID;
- Personenzahl;
- Quell- und Zielknoten;
- Segment und Fortschritt;
- virtuelle Geschwindigkeit;
- Dispatch- und erwartete Ankunftszeit;
- Verluststatus;
- Kennzeichnung, ob eine physische Gruppe existiert.

Beim Materialisieren wird dasselbe physische Routing verwendet wie in Stufe A.

### Abnahmekriterien

Stufe B ist bestanden, wenn:

1. maximal drei logische Marschgruppen gleichzeitig aktiv sind;
2. Grundbesatzungen unverändert an ihren Knoten bleiben;
3. außerhalb der Reveal-Bereiche keine physischen Marschgruppen existieren;
4. jedes materialisierte Packet die korrekte ID und Stärke besitzt;
5. derselbe PhysicalMovementAdapter wie in Stufe A verwendet wird;
6. nach Dematerialisierung keine Restgruppe verbleibt;
7. ein Packet niemals gleichzeitig physisch und virtuell geführt wird;
8. Segmentfortschritt und Marschzeit erhalten bleiben;
9. Ankunft einen Knoten korrekt auffüllt oder Reserve erzeugt;
10. kein Knoten übersprungen wird;
11. das letzte Packet im Bagram-Zielraum physisch materialisiert;
12. Gesamtpersonalbestand und Verteilung dem erwarteten Endzustand entsprechen.

## Nicht Bestandteil

- Kampf um Bagram;
- Waffen-, Munitions- oder Versorgungstransport;
- Cargo Units;
- Warehouse- oder CampaignState-Persistenz;
- dynamische Rekrutierung;
- zivile Bewegungen;
- zufällige Feindkontakte;
- automatische Sichtlinienerkennung;
- taktisches Bounding oder Fire-and-Movement;
- Gebäudeinnenraum-Navigation.

## Offene Entscheidungen

- endgültiger Hauptquartiersstandort;
- reale Zwischenquartiere oder Dörfer;
- Anzahl der Zwischenknoten;
- Grundbesatzung und Ausgangsreserve je Knoten;
- physische Segmentlängen;
- endgültige Infanterie-Templates und DCS-Typnamen;
- Verhalten einer sichtbar eingetroffenen lokalen Reserve;
- Behandlung physischer Verluste während eines Reveal-Abschnitts.
