# 12 – Routennetz und Nachschubverbindungen

## Ziel

Das Routennetz verbindet strategische Reserven, regionale Lager, vorgeschobene Stützpunkte und rote Regenerationsräume. Es ist zugleich Grundlage für Konvois, Hinterhalte, Virtualisierung, QRF und Aufklärung.

## Erste Prototyproute

Der erste technische Test verwendet eine Verbindung zwischen:

- Jalalabad Airfield / FOB Fenty
- FOB Connolly

Diese Route soll folgende Systeme gleichzeitig prüfen:

- physischer und virtueller Konvoiverkehr
- Combat Logistics Patrols
- Hinterhalt- und IED-Bereiche
- QRF-Auslösung
- Versorgungsgutschrift am Ziel
- rote HUMINT-Meldungen
- Rückzug und Regeneration einer regionalen Zelle

## Zweite Ausbaustufe

Nach einem stabilen Prototyp wird der Operationsraum erweitert:

- Jalalabad / FOB Fenty
- Kunar River Valley
- FOB Blessing
- Pech Valley

Damit kommen längere Hubschrauberoperationen, abgelegene Außenposten, Bergtäler, Mörserdruck und grenznahe Versorgungsnetzwerke hinzu.

## Routenmodell

Eine Route ist keine einzelne Linie, sondern eine Folge geprüfter Segmente und Anker:

- Start- und Zielbereich
- Straßenwegpunkte
- Brücken, Engstellen und Flussquerungen
- Checkpoints
- Materialisierungs- und Dematerialisierungsanker
- mögliche Hinterhaltzonen
- Ausweich- und Alternativrouten
- Warte-, Sammel- und Wiederherstellungspunkte

Beispielhafte IDs:

- `ROUTE_FENTY_CONNOLLY_PRIMARY`
- `ROUTE_FENTY_CONNOLLY_ALTERNATE`
- `ANCHOR_FC_001`
- `AMBUSH_FC_001`
- `CHECKPOINT_FC_001`

## Praktische DCS-Prüfung

Jede physisch genutzte Route muss im Mission Editor und in einer Testmission geprüft werden:

- vollständige Befahrbarkeit durch die vorgesehenen Fahrzeugtypen
- Verhalten an Brücken, engen Kurven, Mauern und Siedlungen
- Formation und Abstand der Fahrzeuge
- Möglichkeit zum Anhalten, Ausweichen und Wiederanfahren
- geeignete Stellen zum Materialisieren
- Sichtschutz gegenüber Spielern
- Verhalten bei beschädigten oder ausgefallenen Fahrzeugen
- alternative Fortsetzung bei Blockade

Große physische Konvois werden in mehrere kleinere Gruppen oder Pulse geteilt.

## Virtualisierung

Unbegleitete Konvois dürfen außerhalb relevanter Kontakt- und Beobachtungsräume mathematisch entlang einer gespeicherten Straßenpolylinie bewegt werden. Eine Spielereskorte hält den Konvoi physisch.

Vor Materialisierung werden Position und Fahrtrichtung auf einen validierten Straßenanker gesetzt. Ein Proxy-Fahrzeug wird nicht als virtuelle Repräsentation verwendet.

## Rote Verbindungen

Rote Zellen besitzen getrennte Verbindungen für:

- Personalersatz
- Waffen und Munition
- Kuriere und Intelligence
- Fahrzeuge und schwere Mittel
- Rückzug und Zerstreuung

Diese Verbindungen führen durch Täler, Seitentäler, Pässe, Siedlungen und grenznahe Räume. Sie können vollständig virtuell sein, solange keine Spielerinteraktion möglich ist.

Aufklärung, Festnahmen, zerstörte Camps und kontrollierte Engstellen reduzieren Durchsatz, Zuverlässigkeit oder Geschwindigkeit dieser Verbindungen. Dadurch entsteht Regeneration aus nachvollziehbarer Logistik statt aus einem reinen Respawn-Timer.

## Noch zu erfassen

Für die Route Jalalabad/Fenty–Connolly werden benötigt:

- eine primäre und nach Möglichkeit eine alternative Strecke
- drei bis sechs plausible Hinterhaltstellen
- vier bis acht Materialisierungsanker
- mindestens ein afghanischer Checkpoint
- zwei Rückzugsräume für rote Kräfte
- sichere Konvoi-Start- und Zielbereiche
- Messwerte für Fahrzeit und typische Störungen
