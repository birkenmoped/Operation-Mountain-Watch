---
document_id: OMW-TEST-TM02-RELAY-A-V
status: HISTORICAL_TEST_FIXTURE
authoritative_for:
  - historical TM02A and TM02B relay test procedure
  - accounting and representation regression evidence
production_architecture: false
superseded_by:
  - TM02W and successors
  - OMW-REVIEW-TM01-TM02-MOOSE-FIRST
source_branch: feature/tm02-red-proxy-movement
validated_in_dcs: historical_fixture_only
---

# TM02 – Rote Relaisbewegung

## Status und Autorität

```text
HISTORICAL_TEST_FIXTURE
NOT_PRODUCTION_ARCHITECTURE
SUPERSEDED_FOR_PRODUCTION_BY: TM02W AND SUCCESSORS
```

Dieses Dokument beschreibt die technischen Teststufen TM02A und TM02B. Die Tests bleiben für folgende Nachweise relevant:

- Personal- und Packet-Buchhaltung;
- Erhaltung des Gesamtpersonalbestands;
- eindeutige Quell-/Zielzuordnung;
- begrenzte Parallelität;
- physische und virtuelle Repräsentationszustände;
- Materialisierung und Dematerialisierung;
- Vermeidung gleichzeitiger physischer und virtueller Doppelrepräsentation;
- eindeutige Ankunfts- und Fehlerzustände.

Nicht mehr produktiv verbindlich sind:

- starre lineare Relaiskette;
- Verbot des Überspringens jedes Knotens als allgemeine Netzwerkregel;
- Versorgung ausschließlich vom direkten Vorgänger;
- feste Mindestgarnison an jedem Standort;
- vollständige dauerhafte Besetzung aller Knoten;
- feste Personnel Packets von sechs Kämpfern als Produktionsgröße;
- maximal drei Marschgruppen als allgemeine Produktionsgrenze;
- Austausch historischer Standorte ohne Änderung des Relaismodells.

Produktionsrichtung ab TM02W:

```text
gewichtetes Bewegungsnetz
mehrere mögliche Quellen
alternative Wege
getrennte Kommando-, Bewegungs- und Personalnetze
Guard Floor / Readiness Target / Hard Capacity
variable, zweckgebundene Teams
bounded command cycles
MOOSE-first für physische Ausführung und Lifecycle
```

## Historischer Testzweck

TM02A/B untersucht die gestaffelte Verteilung roter Personengruppen von einem HQ über Zwischenknoten bis in einen technischen Zielraum bei Bagram.

Historisches Fixture-Modell:

```text
HQ
→ Knoten 1
→ Knoten 2
→ Knoten 3
→ Knoten 4
→ Zielraum Bagram
```

Historische Testwerte:

```text
Personnel Packet:          6 Kämpfer
Grundbesatzung HQ:         18 Kämpfer
Grundbesatzung je Knoten:  12 Kämpfer
maximale Marschgruppen:     3
```

Diese Werte dienen ausschließlich der reproduzierbaren Regression der alten Testlogik.

## Komponenten des Fixtures

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

TM02B ergänzt:

```text
RedMovementVirtualizer
MaterializationAnchorRegistry
```

## Historischer Knotenzustand

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

Diese Struktur ist Teil des Fixtures. Produktionsmodelle verwenden keine verpflichtende lineare Vorgänger-/Nachfolgerbeziehung und trennen stattdessen Standortkapazität, Bereitschaft, Personalbestand, Bewegungskanten und Kommandobeziehungen.

## Personnel Packets

Historische Testdefinition:

```text
1 Personnel Packet = 6 Kämpfer
```

Beispiel-IDs:

```text
TEST.TM02.PACKET.001
TEST.TM02.PACKET.002
```

Packets werden innerhalb dieses Fixtures nicht geteilt oder zusammengeführt. Produktionsbewegungen dürfen variable Teamgrößen und zwei gleichzeitig eingesetzte Teams verwenden, sofern CampaignState, Capacity- und Readiness-Regeln dies erlauben.

## TM02A – vollständig physische Relaisbewegung

Missionsdatei:

```text
TM02A-MOOSE-Red-Relay-Physical.miz
```

### Fixture-Funktionsumfang

- MOOSE wird zuerst geladen;
- Grundbesatzungen bleiben physisch an ihren Knoten;
- Marschgruppen entstehen aus Late-Activation-Templates;
- MOOSE führt jede Gruppe zum nächsten Fixture-Knoten;
- höchstens drei Fixture-Bewegungen sind gleichzeitig aktiv;
- keine Persistenz, dynamische Rekrutierung oder Produktionskampagnenlogik.

### Missionseditorobjekte

```text
TPL_TEST_RED_HQ_GARRISON_18_01
TPL_TEST_RED_NODE_GARRISON_12_01
TPL_TEST_RED_PACKET_06_01

ZONE_TM02_HQ
ZONE_TM02_NODE_01
ZONE_TM02_NODE_02
ZONE_TM02_NODE_03
ZONE_TM02_NODE_04
ZONE_TM02_TARGET_BAGRAM
```

Diese Namen und Zonen bleiben nur für die Reproduktion des historischen Tests autoritativ.

### Fixture-Dispatcher

```text
MAX_ACTIVE_RED_MOVEMENTS = 3
```

Ein Zyklus:

1. unterbesetzte Fixture-Knoten vom Ziel rückwärts priorisieren;
2. Überschuss des direkten Vorgängers prüfen;
3. freien Fixture-Movement-Slot prüfen;
4. höchstens ein Packet starten;
5. nächsten Zyklus nach konfigurierter Verzögerung ausführen.

Dieser Algorithmus ist keine Produktionsentscheidung mehr.

### Fixture-Ankunft

1. Packet-ID und Ziel validieren;
2. Personenzahl dem Ziel zuordnen;
3. Fixture-Unterbesetzung auffüllen;
4. Rest als lokale Reserve führen;
5. physische Marschgruppe entfernen oder als Fixture-Reserve darstellen;
6. Weitertransport nur durch neuen Fixture-Dispatch.

### TM02A-Abnahmekriterien

TM02A gilt als erfolgreich reproduziert, wenn:

1. Fixture-Knoten ihre Zielbesatzungen erreichen;
2. Grundbesatzungen ihre Knoten nicht verlassen;
3. nur Fixture-Überschuss weitergeleitet wird;
4. kein Packet im linearen Test einen Knoten überspringt;
5. höchstens drei Bewegungen aktiv sind;
6. Packet-ID, Quelle und Ziel eindeutig bleiben;
7. kein Personal dupliziert wird;
8. Gesamtpersonal erhalten bleibt;
9. jede Bewegung ankommt oder einen eindeutigen Fehlerstatus erhält;
10. der erwartete Fixture-Endzustand erreicht wird.

## TM02B – virtuelle Relaisbewegung

Missionsdatei:

```text
TM02B-MOOSE-Red-Relay-Virtualized.miz
```

### Fixture-Zustände

```text
QUEUED
MATERIALIZING
PHYSICAL_MOVING
DEMATERIALIZING
VIRTUAL_MOVING
ARRIVED
FAILED
```

Beispiel:

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

```text
ZONE_TM02_REVEAL_INTERMEDIATE_ENTRY
ZONE_TM02_REVEAL_INTERMEDIATE_EXIT
ZONE_TM02_TARGET_BAGRAM
```

Fixture-Ablauf:

```text
virtuell
→ Materialisierung
→ physischer Abschnitt
→ Dematerialisierung
→ virtuell
→ Materialisierung im Zielraum
```

### TM02B-Abnahmekriterien

1. maximal drei logische Fixture-Bewegungen;
2. Grundbesatzungen bleiben an Fixture-Knoten;
3. außerhalb der Reveal-Bereiche keine physische Marschgruppe;
4. Materialisierung mit korrekter ID und Stärke;
5. derselbe PhysicalMovementAdapter wie in TM02A;
6. keine Restgruppe nach Dematerialisierung;
7. niemals gleichzeitig physisch und virtuell;
8. Fortschritt und Marschzeit bleiben erhalten;
9. Ankunft aktualisiert den Fixture-Knoten korrekt;
10. Gesamtpersonal und Endverteilung stimmen.

## Nicht Bestandteil dieses Fixtures

- Produktionskampagnenarchitektur;
- TM02W-Netzwerk- und Quellenauswahl;
- Warehouse-/CampaignState-Persistenz;
- Waffen-, Munitions- oder Versorgungstransporte;
- Candidate Sites und dynamischer Standortbau;
- HUMINT/SIGINT;
- variable Teamstärken;
- Produktionsregeln für Garnison, Readiness oder Capacity;
- allgemeine Offroad-Navigation;
- Kampf um Bagram.

## MOOSE-First-Regel für Weiterverwendung

Keine Komponente dieses historischen Fixtures darf unverändert in die Produktionsarchitektur übernommen werden, bevor:

1. passende MOOSE-Klassen und Methoden geprüft wurden;
2. die konkrete technische Lücke dokumentiert wurde;
3. die kleinste verbleibende Eigenlogik abgegrenzt wurde;
4. der Projektinhaber die Ausnahme ausdrücklich genehmigt hat;
5. eine neue DCS-Acceptance gegen TM02W oder einen Nachfolger vorliegt.
