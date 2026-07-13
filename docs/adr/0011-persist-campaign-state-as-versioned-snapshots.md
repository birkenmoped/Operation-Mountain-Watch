# ADR 0011 – CampaignState als versionierte Snapshots persistieren

- Status: Accepted
- Date: 2026-07-13

## Context

Die bisherigen TM01A-Testcontroller halten Spawn-, Routen- und Laufzeitzustände ausschließlich in Lua-Tabellen der laufenden Mission. Beim Stoppen oder Neustarten der Mission gehen diese Werte verloren. Dasselbe würde ohne zusätzliche Persistenz für virtuelle blaue Verbände, rote Zellen, Hide-Site-Belegungen, Cargo-Manifeste, Warehouse-Transaktionen und Intelligence-Zustände gelten.

DCS-Gruppen, MOOSE-Wrapper, Controller, Scheduler, Menüs und automatisch erzeugte Laufzeitnamen sind nicht stabil genug, um sie über einen Missions- oder Serverneustart hinweg zu speichern. Die bereits festgelegte Architektur bestimmt deshalb `CampaignState` als einzige autoritative Quelle für strategische Domänendaten.

Persistenz muss außerdem Teilbuchungen, beschädigte Dateien und Schemaänderungen beherrschbar machen. Eine Kampagne darf nach einem Absturz weder Ressourcen duplizieren noch bestätigte Verluste stillschweigend vergessen.

## Decision

Operation Mountain Watch persistiert ausschließlich stabile Domänendaten aus `CampaignState`.

Die erste Implementierung verwendet:

- einen versionierten vollständigen Snapshot;
- eine monoton steigende `saveSequence`;
- atomisches Schreiben über temporäre Datei und Umbenennung;
- mindestens einen letzten gültigen Backup-Snapshot;
- ein kleines Transaktionsjournal für genau-einmalige Cargo- und Warehouse-Buchungen;
- einen `PersistenceManager` mit austauschbarem Adapter;
- einen `NoopPersistenceAdapter` für Tests ohne Dateizugriff;
- einen `FilePersistenceAdapter` für den dedizierten Server, sofern dessen Sandbox-Konfiguration den vorgesehenen Dateizugriff erlaubt.

Der konkrete Serverpfad und das endgültige Serialisierungsformat werden bei der Implementierung festgelegt. Das Format muss deterministisch lesbar, schema-versioniert und ohne Speicherung von Lua-Funktionsreferenzen oder Frameworkobjekten auskommen.

## Zu persistierende Daten

Mindestens gespeichert werden:

- Campaign-ID, Schema-Version, Save-Sequenz und Kampagnenzeit;
- stabile Entity-, Cell-, Cargo-, Warehouse-, Route- und Transaktions-IDs;
- strategische Ressourcen und Warehouse-Sollbestände;
- noch nicht abgeschlossene Warehouse-Transaktionen;
- Cargo-Manifeste und genau-einmaliger Lieferstatus;
- blaue `StrategicEntity`-Zustände einschließlich Zusammensetzung, Verluste, Fracht, Auftrag und virtueller Routenfortschritt;
- operative und Concealment-Zustände roter Zellen;
- logische Orte, reservierte Hide Sites, bekannte und ausgeschlossene Hide Sites;
- Personal-, Munitions-, Fahrzeug- und Moralzustände roter Zellen;
- Intelligence- und Aufklärungsgrade;
- Strongpoint-, Cache-, FOB-, Depot- und Wiederaufbauzustände;
- letzter bestätigter physischer Kontakt und letzte relevante Zustandsänderung.

Nicht persistiert werden:

- MOOSE-Wrapper;
- DCS-Controller;
- konkrete Runtime-Gruppennamen wie `TM01A_BLUE_CONVOY_001#001`;
- F10-Menüobjekte;
- Scheduler- und Callbackobjekte;
- Lua-Funktionen oder Closures;
- flüchtige DCS-Objekt-IDs.

## Virtuelle Bewegung

Ein virtueller Verband speichert keinen kontinuierlichen Strom einzelner Koordinaten. Gespeichert werden reproduzierbare Fortschrittsdaten:

```lua
{
  entityId = "BLUE_CONVOY_FENTY_CONNOLLY_001",
  representationState = "VIRTUAL",
  routeId = "ROUTE_FENTY_CONNOLLY_PRIMARY",
  segmentIndex = 18,
  segmentProgress = 0.42,
  routeDistanceMeters = 22450,
  configuredSpeedKph = 30,
  effectiveSpeedKph = 23,
  lastMovementUpdateCampaignTime = 18400,
  survivingVehicleSlots = { 1, 2, 3, 4, 6 },
  cargoManifestId = "CARGO_FENTY_CONNOLLY_027",
}
```

Die aktuelle virtuelle Position wird aus gespeicherter Route, Fortschritt, effektiver Geschwindigkeit und vergangener Kampagnenzeit bestimmt. Bei physischer Darstellung wird die tatsächliche DCS-Position regelmäßig auf die kanonische Route projiziert und der Fortschritt im `CampaignState` abgeglichen.

## Speicherzeitpunkte

Ein Snapshot wird periodisch und bei wichtigen Zustandsübergängen angefordert. Erste Richtwerte:

- periodisch alle 60 bis 120 Sekunden;
- Materialisierung oder Dematerialisierung;
- bestätigter Verlust;
- Route gestartet, Ziel erreicht oder Auftrag fehlgeschlagen;
- Lieferung abgeschlossen oder Fracht zerstört;
- Warehouse-Transaktion abgeschlossen oder Reconciliation erforderlich;
- Hide Site gewechselt;
- rote Zelle aufgedeckt, in Kampf übergegangen oder erfolgreich zurückgezogen;
- kontrolliertes Missionsende.

Häufige Laufzeitaktualisierungen dürfen im Speicher stattfinden, ohne jede Einzeländerung sofort auf Datenträger zu schreiben.

## Wiederherstellung

Beim Laden werden strategische Daten zuerst validiert und migriert. Danach werden native Warehouses, physische Gruppen, Strongpoints und andere DCS-Repräsentationen aus dem geladenen Zustand rekonstruiert oder abgeglichen.

Eine Entität darf nach dem Laden nicht gleichzeitig `VIRTUAL` und `PHYSICAL` sein. Persistierte Runtime-Namen werden nicht zur Wiederherstellung verwendet. Physische Gruppen erhalten neue Laufzeitnamen und werden über ihre stabile strategische ID zugeordnet.

## Offlinezeit

Für den ersten vertikalen Prototyp friert die Kampagnenzeit ein, solange Mission oder Server nicht laufen. Konvois, Kämpfe, Verbrauch und rote Operationen werden nicht anhand der realen Wall Clock unbeobachtet fortgeschrieben.

Ein späterer kontrollierter Offlinefortschritt für ausgewählte Systeme wie Produktion, Reparatur oder strategische Transfers benötigt eine eigene Entscheidung und darf keine unbeobachteten taktischen Gefechte simulieren.

## Consequences

### Positive

- blaue und rote Zustände überleben Missions- und Serverneustarts;
- DCS- und MOOSE-Laufzeitobjekte bleiben austauschbare Repräsentationen;
- virtuelle Bewegung kann reproduzierbar fortgesetzt werden;
- Cargo- und Warehouse-Buchungen können idempotent behandelt werden;
- Schemaänderungen und Migrationen werden explizit steuerbar;
- defekte oder unvollständige Schreibvorgänge können erkannt werden.

### Negative

- Snapshot-, Journal-, Migrations- und Validierungslogik erhöhen den Implementierungsumfang;
- direkter Dateizugriff hängt von der Server- und Sandbox-Konfiguration ab;
- physische Zustände müssen vor dem Speichern zuverlässig in Domänendaten überführt werden;
- Wiederherstellung und Reconciliation benötigen eigene Integrationstests.

## Required validation

- eine blaue `StrategicEntity` und eine rote `RedCell` speichern;
- Mission vollständig neu starten;
- beide Entitäten mit identischen stabilen IDs und Domänendaten laden;
- Runtime-Gruppen mit neuen Namen rekonstruieren;
- virtuelle Routenposition reproduzierbar wiederherstellen;
- unvollständigen Snapshot erkennen und auf Backup zurückfallen;
- eine Cargo- oder Warehouse-Transaktion trotz Neustart genau einmal abschließen;
- Schema-Version und Migration mindestens mit einem künstlichen älteren Testdatensatz prüfen.