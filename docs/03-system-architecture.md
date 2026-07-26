# 03 – Systemarchitektur

## Verbindliche MOOSE-first-Regel

Diese Architektur unterliegt [`GOV-001`](00-project-governance.md).

MOOSE ist der verbindliche technische Grundstock des gesamten Projekts. Für jede Komponente und jede neue Mechanik werden zuerst alle einschlägigen MOOSE-Klassen, Funktionen und Framework-Muster identifiziert, kombiniert und getestet. Native DCS-Aufrufe, Eigenentwicklungen oder hybride Lösungen dürfen erst vorgeschlagen werden, nachdem die verbleibende MOOSE-Grenze dokumentiert wurde. Die Freigabe einer solchen Abweichung trifft ausschließlich der Projektinhaber.

## Technologiestack

- DCS Mission Editor für Karte, Slots, Zonen, Vorlagen und statische Infrastruktur
- MOOSE als verbindliches primäres Framework und erste Implementierungsebene
- MOOSE CTLD für Spielerlogistik und Fracht
- MOOSE CSAR für Rettungsfälle
- eigene Lua-Module für Kampagnenzustand, Persistenz, Virtualisierung, Warehouse-Synchronisierung, gegnerische Entscheidungslogik und verdeckte Zwischenstellungen nur dort, wo MOOSE die genehmigte Anforderung nicht vollständig erfüllt oder der Projektinhaber eine Ergänzung ausdrücklich freigegeben hat

MIST wird nicht zusätzlich geladen, solange keine konkrete technische Abhängigkeit dokumentiert und nach GOV-001 ausdrücklich genehmigt ist.

## Komponenten

### CampaignState

Autoritative Quelle für Basen, FOBs, Ressourcen, rote Zellen, strategische Entitäten, aktive Aufträge, CSAR-Fälle, Warehouse-Transaktionen, Concealment-Zustände und Intelligence-Fortschritt.

Vor einer Eigenimplementierung werden MOOSE-Zustands-, Event-, FSM-, Set-, Wrapper- und Persistenz-nahe Mechaniken darauf geprüft, welche Teile sie übernehmen oder strukturieren können.

### EntityManager

Verwaltet stabile strategische IDs, Zusammensetzung, Verluste, Aufträge und die Zuordnung zu temporären DCS-Gruppen.

### VirtualizationManager

Bewegt entfernte Verbände mathematisch, entscheidet über Materialisierung und Dematerialisierung und erhält Zusammensetzung sowie Zustand.

Virtuelle Bewegung erfolgt entlang einer kanonischen, versionierten Route. Der Manager speichert mindestens Segment, Fortschritt, Entfernung entlang der Route, konfigurierte und effektive Geschwindigkeit sowie den letzten Aktualisierungszeitpunkt. Bei physischer Darstellung wird die tatsächliche DCS-Position auf die kanonische Route projiziert und mit dem `CampaignState` abgeglichen.

Materialisierung erfolgt vor relevantem Spieler- oder Feindkontakt an geprüften Ankern. Direkte Sichtlinie, Sensorbeobachtung, Platzbedarf, Straßenzugang und plausible Verbindung zur virtuellen Position werden vor dem Spawn geprüft. Eine Entität darf nie gleichzeitig `VIRTUAL` und `PHYSICAL` sein.

MOOSE-Funktionen für Spawn, Respawn, Teleport, Routing, Zonen, Sets, Events, Schedulers, Detection und Tasking werden vor jeder eigenen Virtualisierungs- oder Recovery-Mechanik vollständig ausgeschöpft. Eine technische Grenze wird dokumentiert und dem Projektinhaber zur Entscheidung vorgelegt.

### LogisticsManager

Verarbeitet CTLD-Lieferungen, Konvois, Lufttransport, C-130J-Abwürfe und die Gutschrift von Ressourcen. Er erzeugt Liefertransaktionen, greift aber nicht direkt auf native DCS-Warehouse-Funktionen zu.

Die Transporthierarchie unterscheidet strategischen Zufluss und regionale Verteilung. Bagram und Kabul versorgen Jalalabad/Fenty regulär per Lufttransport oder abstrahiertem strategischem Transfer. Straßenkonvois beginnen im Kernprototyp in Jalalabad/Fenty und versorgen straßengebundene FOBs, COPs und Checkpoints. Abgelegene Standorte werden bevorzugt per Hubschrauber oder Luftabwurf versorgt. Details regelt ADR 0012.

### WarehouseAdapter

Kapselt DCS `Warehouse` und MOOSE `STORAGE`. Er registriert Warehouse-Knoten, bildet strategische Ressourcen auf native Items und Flüssigkeiten ab, synchronisiert Bestände, erkennt bestätigten Verbrauch und führt Reconciliation bei Abweichungen durch.

`CampaignState` bleibt die persistente Autorität. Native Warehouses werden nur an dauerhaften, spielerrelevanten Logistikknoten eingesetzt.

Die konkrete Aufteilung zwischen MOOSE `STORAGE`, MOOSE-Warehouse-Funktionen, nativer DCS-Warehouse-API und Projektcode unterliegt einer dokumentierten GOV-001-Entscheidung.

### RedDirector

Wählt Ziele, reserviert Kräfte, plant Angriffe, steuert Rückzug und Wiederaufbau und reagiert auf abstrakte HUMINT-Meldungen.

Für Scheduling, Tasking, Events, FSMs, Detection, Sets und Gruppensteuerung werden die verfügbaren MOOSE-Mechaniken als Grundlage verwendet.

### ConcealmentManager

Verwaltet Hide Sites, deren Belegung, Concealment-Zustände, vorbereitete Fluchtwege und Strongpoints. Er bewertet Spielerentfernung, Sichtlinie, Aufklärungsgrad und Deckung, bevor eine virtuelle rote Gruppe materialisiert wird.

Beliebige Scenery-Gebäude werden nicht als automatisch begehbar oder garnisonierbar vorausgesetzt.

### CSARCampaignManager

Verknüpft MOOSE-CSAR mit roten Capture-Teams, Gefangenschaft, Evasion, Persistenz und Folgeoperationen.

### MissionGenerator

Erzeugt spielbare Aufträge aus dem aktuellen Kampagnenzustand. Dazu gehören neben Kampf- und Logistikaufträgen auch Aufklärung, Durchsuchung, Hide-Site-Eingrenzung und Strongpoint-Angriffe.

### PersistenceManager

Speichert ausschließlich strategischen Zustand. MOOSE- oder DCS-Objekte werden beim Laden aus diesem Zustand rekonstruiert. Warehouse-Transaktionen, Warehouse-Mapping-Versionen und Concealment-Zustände werden als Domänendaten persistiert.

Die erste Persistenzimplementierung verwendet versionierte Snapshots, atomisches Schreiben, einen letzten gültigen Backup-Snapshot und ein kleines Transaktionsjournal für genau-einmalige Cargo- und Warehouse-Buchungen. Der Dateizugriff wird über einen austauschbaren Adapter gekapselt. Details regelt ADR 0011.

## Implementierungsstatus

Die TM01A-Testcontroller sind noch vollständig flüchtig. Spawnzustand, Runtime-Gruppenname, Route und Ankunft existieren nur während der laufenden Mission. Die erfolgreichen physischen Tests belegen noch keine Persistenz über Missions- oder Serverneustarts.

Für den ersten vertikalen Persistenztest werden mindestens eine blaue `StrategicEntity` und eine rote `RedCell` gespeichert, die Mission vollständig neu gestartet und beide Entitäten aus stabilen Domänendaten rekonstruiert. Runtime-Gruppennamen und Frameworkobjekte werden dabei bewusst nicht wiederverwendet.

Die Kampagnenzeit friert im ersten Prototyp ein, solange Server oder Mission nicht laufen. Unbeobachtete taktische Gefechte, Konvoibewegungen oder rote Operationen werden nicht anhand der realen Wall Clock fortgeschrieben.

## Abhängigkeitsregel

Domänenlogik darf nicht direkt von einem konkreten DCS-Gruppennamen, Warehouse-Objekt, Scenery-Objekt oder internen DCS-Itemnamen abhängen. DCS- und MOOSE-Aufrufe werden in Adapter- oder Systemmodulen gekapselt.

Die Kapselung ist keine Erlaubnis, MOOSE zu umgehen. Adapter verwenden MOOSE, wo eine geeignete Framework-Funktion existiert. Ein direkter nativer DCS-Aufruf oder eine Eigenimplementierung benötigt die dokumentierte Prüfung und Entscheidung nach GOV-001.

Insbesondere gilt:

- `LogisticsManager` bucht gegen strategische Ressourcen und Liefertransaktionen;
- `WarehouseAdapter` übernimmt die genehmigte MOOSE-/DCS-Projektion;
- `RedDirector` entscheidet über operative Absicht;
- `ConcealmentManager` entscheidet über physische verdeckte Repräsentation;
- `VirtualizationManager` erzeugt und entfernt physische Gruppen auf Grundlage der verfügbaren MOOSE-Lifecycle-Mechanismen;
- nur `CampaignState` wird persistent gespeichert.

## Geplanter Startumfang

Ein vertikaler Prototyp umfasst:

- eine Hauptbasis mit nativer Warehouse-Anbindung;
- einen FOB mit nativer Warehouse-Anbindung;
- einen kleinen Posten mit ausschließlich abstraktem Bestand;
- eine getestete regionale Straßenroute Fenty–Connolly;
- einen blauen Konvoi;
- eine rote Zelle mit virtueller Hide Site und physischer Materialisierung;
- einen versionierten CampaignState-Snapshot mit Wiederherstellung;
- einen C-130J-Abwurf sowie eine gelandete Lieferung;
- einen CSAR-Fall.

Die Bagram–Jalalabad-Route bleibt als technische Langstrecken- und Regressionsteststrecke erhalten, ist aber keine reguläre Produktionskonvoiroute.
