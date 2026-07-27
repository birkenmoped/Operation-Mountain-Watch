# 04 – Kampagnenzustand

## Grundsatz

`CampaignState` ist die einzige autoritative Quelle für strategische Ressourcen und Zustände. DCS-Gruppen, CTLD-Fracht, MOOSE-Warehouses und sichtbare Objekte bilden diesen Zustand ab, besitzen ihn aber nicht unabhängig.

## Hauptobjekte

### Airbase

- stabile ID und DCS-Airbase-Referenz
- Rolle und Fähigkeiten
- strategische Lagerbestände
- verfügbare Luft- und Bodenverbände
- angeschlossene Routen und versorgte FOBs

### FOB

- Zustand: `OPERATIONAL`, `DEGRADED`, `CRITICAL`, `OVERRUN`, `DESTROYED`, `REBUILDING`
- Personal, Munition, Treibstoff, Baumaterial und Fahrzeuge
- maximale Kapazitäten
- Garnison und Verteidigungsfähigkeit
- Heli-Landezonen, Drop Zone und Straßenanbindung
- physische Ausbau- und Schadensstufe

### RedCell

- Region, Camps und Verstecke
- verfügbares Personal, Waffen und Fahrzeuge
- Moral, Bereitschaft und Wiederaufbauzeit
- laufende Operation und reservierte Kräfte
- bekannte blaue Ziele und gemeldete Bewegungen

### StrategicEntity

- stabile ID
- Koalition, Rolle und Zusammensetzung
- Zustand `VIRTUAL` oder `PHYSICAL`
- Position, Route, Geschwindigkeit und Auftrag
- Verluste, Fracht und letzter Kontakt
- optionale Referenz auf eine DCS-Gruppe

### CSARCase

- Pilot und Koalition
- Position und Status
- Informationsstand beider Seiten
- Rettungs- oder Capture-Team
- Rücktransport, Gefangenschaft oder Abschluss

## Anfangsressourcen

Für den Prototyp werden nur folgende Ressourcen getrennt geführt:

- `PERSONNEL`
- `AMMUNITION`
- `FUEL`
- `CONSTRUCTION`
- `VEHICLES`

Weitere Ressourcen werden nur ergänzt, wenn daraus ein klarer spielerischer Nutzen entsteht.

## Persistenz

Gespeichert werden strategische IDs und Domänendaten, nicht flüchtige MOOSE-Wrapper oder DCS-Controller-Zustände. Jeder Speichervorgang erhält eine Schema-Version für spätere Migrationen.
