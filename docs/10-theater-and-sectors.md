# 10 – Operationsraum und Sektoren

## Räumliche Staffelung

Die Kampagne verwendet vier räumliche Ebenen.

### Strategischer Raum

- Bagram Airfield
- Kabul
- Jalalabad

Dieser Raum bildet Führung, zentrale Reserven, Personalbewegung, schwere Wartung und strategischen Lufttransport ab.

### Operativer Raum

- Jalalabad und FOB Fenty
- Kabul River Valley
- Laghman
- Zugänge nach Kunar

Hier werden regionale Logistik, QRF, Hubschrauberoperationen, Aufklärung und Einsatzplanung organisiert.

### Taktischer Hauptkampfraum

- Kunar River Valley
- Pech Valley
- angrenzende Seitentäler
- Zugänge nach Nuristan

Dieser Raum bildet abgelegene Außenposten, Gebirgsoperationen, Mörserangriffe, Hinterhalte und grenznahe gegnerische Netzwerke ab.

### Erweiterungsraum

- Kapisa
- Logar
- Ghazni
- Khost
- Bamyan

Diese Gebiete bleiben zunächst außerhalb des vertikalen Prototyps und dienen späteren Kampagnenphasen oder multinationalen Nebenoperationen.

## Geplante Sektorstruktur

Die endgültigen Grenzen werden im DCS Mission Editor als Polygonzonen festgelegt. Vorläufige logische Sektoren sind:

- `SECTOR_BAGRAM_STRATEGIC`
- `SECTOR_KABUL_REAR`
- `SECTOR_JALALABAD_FENTY`
- `SECTOR_NANGARHAR_EAST`
- `SECTOR_LAGHMAN`
- `SECTOR_KUNAR_RIVER`
- `SECTOR_PECH_VALLEY`
- `SECTOR_NURISTAN_APPROACHES`
- `SECTOR_BORDER_NETWORK`

Jeder Sektor erhält mindestens:

- stabile ID und Anzeigename
- Missionseditor-Zone
- Gelände- und Zugangsprofil
- blaue und rote Einflusswerte
- bekannte Straßen, Pässe und Täler
- relevante Basen, Dörfer und Kontrollpunkte
- mögliche Camps, Hide Sites und Rückzugsräume
- Nachschub- und Regenerationsverbindungen

## Ortsmodell

Es wird keine vollständige Datenbank aller afghanischen Orte benötigt. Erfasst werden nur Orte mit spielerischer oder strategischer Funktion:

- Airbases und FOBs
- Städte und Dörfer entlang verwendeter Routen
- Pässe, Engstellen und Flussquerungen
- Checkpoints und Beobachtungsstellungen
- Camp-, Hinterhalt- und Rückzugsräume
- Landezonen und Drop Zones

Jeder relevante Ort wird über eine Mission-Editor-Zone oder einen validierten Anker referenziert.

## Gegnerspezifische Geografie

Täler und Seitentäler bilden natürliche Operationsräume regionaler Zellen. Bergpässe, Flussachsen und grenznahe Wege bestimmen Bewegung, Nachschub und Rückzug. Mehrere Zellen können sich zeitweise für einen größeren Angriff zusammenschließen und danach wieder in lokale Netzwerke zerfallen.

Rote Kräfte regenerieren nicht allein über einen Respawn-Timer. Personal, Waffen und Munition werden über reale oder virtuelle Grenz-, Tal- und Kurierverbindungen zugeführt. Aufklärung, Festnahmen, zerstörte Lager und gesperrte Routen reduzieren diese Zuflüsse.

## Noch im Mission Editor zu erfassen

- genaue Sektorgrenzen
- relevante Dörfer und Siedlungszonen
- Straßen- und Talachsen
- Camp-Slots und Hide Sites
- Materialisierungsanker
- Rückzugspunkte
- geeignete Hubschrauber-Landezonen
- Sicht- und Geländebeschränkungen
