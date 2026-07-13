# 04 – Kampagnenzustand

## Grundsatz

`CampaignState` ist die einzige autoritative Quelle für strategische Ressourcen und Zustände. DCS-Gruppen, CTLD-Fracht, native DCS-Warehouses, MOOSE-`STORAGE`-Wrapper, Strongpoints und sichtbare Objekte bilden diesen Zustand ab, besitzen ihn aber nicht unabhängig.

Native Warehouses können während einer laufenden Mission operative Bestände verwalten. Persistenz, strategische Bewertung, Wiederherstellung und Konfliktauflösung erfolgen dennoch über den `CampaignState` und idempotente Transaktionen.

Die aktuellen TM01A-Testcontroller sind noch nicht an `CampaignState` angebunden. Ihre Spawn-, Routen- und Laufzeitzustände sind flüchtig und gehen bei Missionsende verloren. Die folgenden Regeln beschreiben den verbindlichen Zielzustand.

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

- stabile Cell-ID
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
- letzter bestätigter physischer Kontakt

### StrategicEntity

- stabile ID
- Koalition, Rolle und Zusammensetzung
- Zustand `VIRTUAL` oder `PHYSICAL`
- optionaler Concealment-Zustand
- logischer Ort und optionale Hide-Site-ID
- Position, Route, Geschwindigkeit und Auftrag
- Routenfortschritt als Segment, Segmentanteil und Entfernung entlang der Route
- konfigurierte und effektive Geschwindigkeit
- Verluste, Fracht und letzter Kontakt
- optionale Referenz auf eine DCS-Gruppe nur zur Laufzeit
- Materialisierungs- und Reconciliation-Status

Eine strategische Entität darf nicht gleichzeitig `VIRTUAL` und `PHYSICAL` sein.

### RouteProgress

Für virtuelle Bewegung wird mindestens folgender reproduzierbarer Zustand geführt:

```lua
{
  routeId = "ROUTE_FENTY_CONNOLLY_PRIMARY",
  segmentIndex = 18,
  segmentProgress = 0.42,
  routeDistanceMeters = 22450,
  configuredSpeedKph = 30,
  effectiveSpeedKph = 23,
  lastMovementUpdateCampaignTime = 18400,
}
```

Die aktuelle virtuelle Position wird aus der kanonischen Routenpolylinie und dem Fortschritt interpoliert. Bei physischer Darstellung wird die tatsächliche DCS-Koordinate auf die Route projiziert und der Fortschritt im `CampaignState` aktualisiert.

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

Bei physischen strategischen Entitäten gilt zusätzlich:

1. tatsächliche DCS-Gruppe und stabile Entity-ID zuordnen;
2. Lebendstatus, Fahrzeugslots, Verluste, Fracht und Position erfassen;
3. DCS-Position auf die kanonische Route projizieren;
4. bei plausibler Abweichung den Routenfortschritt aktualisieren;
5. bei großer ungeklärter Abweichung `ROUTE_DIVERGED` setzen und nicht dematerialisieren;
6. erst nach vollständigem Abgleich die physische Repräsentation entfernen.

## Persistenz

### Persistenzgrenze

Gespeichert werden strategische IDs und Domänendaten, nicht flüchtige MOOSE-Wrapper oder DCS-Controller-Zustände. Jeder Speichervorgang erhält eine Schema-Version für spätere Migrationen.

Persistiert werden mindestens:

- Campaign-ID, Schema-Version, Save-Sequenz und Kampagnenzeit;
- Warehouse-Knoten und strategische Bestände;
- noch nicht abgeschlossene Warehouse-Transaktionen;
- Mapping-Version und letzter erfolgreicher Abgleich;
- Cargo-Manifeste und Lieferstatus;
- blaue strategische Entitäten einschließlich Zusammensetzung, Verluste, Auftrag und Routenfortschritt;
- operative und Concealment-Zustände roter Zellen;
- logische Orte und Hide-Site-Reservierungen;
- bekannte beziehungsweise ausgeschlossene Hide Sites;
- Personal-, Munitions-, Fahrzeug- und Moralzustände roter Zellen;
- Strongpoint- und Cache-Zustände;
- Aufklärungsgrade;
- letzter bestätigter physischer Kontakt.

Nicht persistiert werden:

- konkrete Runtime-Gruppennamen;
- MOOSE-Wrapper;
- DCS-Controller und Objekt-IDs;
- Scheduler, F10-Menüs und Callbackobjekte;
- Lua-Funktionen oder Closures.

### Speicherverfahren

Die erste Implementierung verwendet:

- einen vollständigen versionierten Snapshot;
- eine monoton steigende `saveSequence`;
- atomisches Schreiben über temporäre Datei und Umbenennung;
- mindestens einen letzten gültigen Backup-Snapshot;
- ein kleines Transaktionsjournal für genau-einmalige Cargo- und Warehouse-Buchungen;
- einen austauschbaren `PersistenceAdapter`;
- einen `NoopPersistenceAdapter` für Tests;
- einen `FilePersistenceAdapter` für den dedizierten Server, sofern die Sandbox-Konfiguration den vorgesehenen Zugriff erlaubt.

Das endgültige Serialisierungsformat und der Serverpfad werden bei der Implementierung festgelegt. Details regelt ADR 0011.

### Speicherzeitpunkte

Erste Richtwerte:

- periodisch alle 60 bis 120 Sekunden;
- kontrolliertes Missionsende;
- Materialisierung und Dematerialisierung;
- bestätigter Verlust;
- Route gestartet, Ziel erreicht oder Auftrag fehlgeschlagen;
- Lieferung abgeschlossen oder Fracht zerstört;
- Warehouse-Transaktion abgeschlossen oder Reconciliation erforderlich;
- Hide Site gewechselt;
- rote Zelle aufgedeckt, in Kampf übergegangen oder zurückgezogen.

Nicht jede interne Positionsaktualisierung muss sofort auf Datenträger geschrieben werden.

### Wiederherstellung

Beim Laden werden Snapshot und Journal zuerst validiert und bei Bedarf migriert. Danach werden native Warehouses, DCS-Gruppen, Strongpoints und andere physische Repräsentationen aus den geladenen Domänendaten rekonstruiert oder abgeglichen.

Runtime-Gruppen erhalten neue Laufzeitnamen. Ihre Identität stammt ausschließlich aus der stabilen strategischen ID.

Ein beschädigter oder unvollständiger Snapshot führt nicht zu einem stillschweigenden leeren Kampagnenzustand. Der `PersistenceManager` versucht den letzten gültigen Backup-Snapshot und protokolliert den Fehler.

### Offlinezeit

Für den ersten Prototyp friert die Kampagnenzeit ein, solange Server oder Mission nicht laufen. Virtuelle Konvois, rote Operationen, taktische Gefechte und laufender Verbrauch werden nicht anhand der Wall Clock unbeobachtet weitergerechnet.

Ein späterer kontrollierter Offlinefortschritt für ausgewählte strategische Systeme benötigt eine eigene Entscheidung.

## Erster Persistenztest

Der kleinste vertikale Persistenztest enthält:

- eine blaue `StrategicEntity` mit virtueller Route, Fortschritt und einem dokumentierten Fahrzeugverlust;
- eine rote `RedCell` mit operativem Zustand, Concealment-Zustand, Hide Site und Aufklärungsgrad;
- einen Snapshot mit Schema-Version und Save-Sequenz;
- vollständigen Missionsneustart;
- reproduzierbare Wiederherstellung beider stabilen IDs;
- neue Runtime-Gruppennamen nach Materialisierung;
- Rückfall auf einen Backup-Snapshot;
- eine genau einmal abgeschlossene Testtransaktion.

Beim Laden werden native Warehouses, DCS-Gruppen und Strongpoint-Repräsentationen aus diesen Daten neu aufgebaut oder abgeglichen.