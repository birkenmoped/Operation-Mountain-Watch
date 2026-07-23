# 04 – Kampagnenzustand

## Grundsatz

`CampaignState` ist die einzige autoritative Quelle für strategische Ressourcen und Zustände. DCS-Gruppen, CTLD-Fracht, native DCS-Warehouses, MOOSE-`STORAGE`-Wrapper, Strongpoints und sichtbare Objekte bilden diesen Zustand ab, besitzen ihn aber nicht unabhängig.

Native Warehouses können während einer laufenden Mission operative Bestände verwalten. Persistenz, strategische Bewertung, Wiederherstellung und Konfliktauflösung erfolgen dennoch über den `CampaignState` und idempotente Transaktionen.

## Hauptobjekte

### Airbase

- stabile ID und DCS-Airbase-Referenz
- Rolle und Fähigkeiten
- strategische Lagerbestände
- optionale native Warehouse-ID und Warehouse-Capabilities
- verfügbare Luft- und Bodenverbände
- angeschlossene Routen und versorgte FOBs

### FOB

- Zustand: `OPERATIONAL`, `DEGRADED`, `CRITICAL`, `OVERRUN`, `DESTROYED`, `REBUILDING`
- Personal, Munition, Treibstoff, Baumaterial und Fahrzeuge
- maximale Kapazitäten
- Garnison und Verteidigungsfähigkeit
- Heli-Landezonen, Drop Zone und Straßenanbindung
- physische Ausbau- und Schadensstufe
- Warehouse-Modus: `NATIVE`, `ABSTRACT` oder `DISABLED`
- optionale Warehouse-ID, Depotobjekt und Übergabezonen

### RedCell

- Region, Camps und Verstecke
- verfügbarer Aufenthaltsort und reservierte Hide Site
- operativer Zellzustand
- Concealment-Zustand
- verfügbare Fluchtwege und Strongpoint-Verknüpfungen
- verfügbares Personal, Waffen und Fahrzeuge
- Moral, Bereitschaft und Wiederaufbauzeit
- laufende Operation und reservierte Kräfte
- bekannte blaue Ziele und gemeldete Bewegungen
- Aufklärungsgrad beider Seiten

### StrategicEntity

- stabile ID
- Koalition, Rolle und Zusammensetzung
- Zustand `VIRTUAL` oder `PHYSICAL`
- optionaler Concealment-Zustand
- logischer Ort und optionale Hide-Site-ID
- Position, Route, Geschwindigkeit und Auftrag
- Verluste, Fracht und letzter Kontakt
- optionale Referenz auf eine DCS-Gruppe

### WarehouseNode

- stabile Warehouse-ID
- zugehörige Airbase-, Base- oder FOB-ID
- Modus `NATIVE`, `ABSTRACT` oder `DISABLED`
- native DCS-/MOOSE-Referenz nur zur Laufzeit
- Capabilities für Items, Flüssigkeiten, Flugzeuge und Cargo
- strategische Sollbestände und Kapazitäten
- bekannte native Istbestände
- Warehouse-Mapping-Version
- Übergabezonen
- Synchronisationsstatus und letzte Reconciliation

### WarehouseTransaction

- stabile Transaktions-ID
- Warehouse-ID
- Quelle und Quell-ID, zum Beispiel Cargo-Manifest oder bestätigter Verbrauch
- Ressource und Menge
- Status: `PENDING`, `APPLIED_DCS`, `APPLIED_CAMPAIGN`, `COMPLETED`, `REJECTED` oder `RECONCILE_REQUIRED`
- Erstellungs- und Abschlusszeit
- Fehler- und Diagnoseinformationen

Eine Transaktions-ID darf nur einmal erfolgreich abgeschlossen werden.

### HideSite

- stabile ID und logischer Ort
- Missionseditor-Zone oder validierte Koordinate
- Deckungstyp und Kapazität
- erlaubte Rollen
- Belegungs- und Reservierungsstatus
- vorbereitete Fluchtwege
- Eignung für Hinterhalt, Beobachtung, Mörser oder Strongpoint
- Validierungsstatus und DCS-Version

### Strongpoint

- stabile ID und logischer Ort
- physische Repräsentation, zum Beispiel bewaffnetes Haus oder vorbereitetes Compound
- verknüpfte rote Zelle
- Personal- und Munitionskapazität
- Schadens- und Zerstörungswirkung
- Zustand und Aufklärungsgrad

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

Nur Ressourcen mit belastbarer DCS-Abbildung werden zusätzlich auf native Warehouse-Items oder Flüssigkeiten projiziert. Die strategischen Ressourcennamen bleiben unabhängig von DCS-internen Itemnamen.

## Autorität und Reconciliation

Bei widersprüchlichen Daten gilt:

1. abgeschlossene Warehouse-Transaktionen auswerten;
2. bestätigten nativen Verbrauch seit der letzten Synchronisierung berücksichtigen;
3. strategischen Sollbestand aus `CampaignState` bestimmen;
4. unbekannte Differenz als `RECONCILE_REQUIRED` markieren;
5. keine stillschweigende Bestandskorrektur ohne Logeintrag durchführen.

Der Server ist die einzige Instanz, die Warehouse- und CampaignState-Bestände verändert.

## Persistenz

Gespeichert werden strategische IDs und Domänendaten, nicht flüchtige MOOSE-Wrapper oder DCS-Controller-Zustände. Jeder Speichervorgang erhält eine Schema-Version für spätere Migrationen.

Zusätzlich werden persistiert:

- Warehouse-Knoten und strategische Bestände;
- noch nicht abgeschlossene Warehouse-Transaktionen;
- Mapping-Version und letzter erfolgreicher Abgleich;
- operative und Concealment-Zustände roter Zellen;
- logische Orte und Hide-Site-Reservierungen;
- bekannte beziehungsweise ausgeschlossene Hide Sites;
- Strongpoint- und Cache-Zustände;
- Aufklärungsgrade.

Beim Laden werden native Warehouses, DCS-Gruppen und Strongpoint-Repräsentationen aus diesen Daten neu aufgebaut oder abgeglichen.
