# 25 – TM01A-Erkenntnisse, Virtualisierung, Persistenz und Logistikfolgen

## Zweck

Dieses Dokument konsolidiert die seit der letzten allgemeinen Dokumentationsaufnahme gewonnenen Erkenntnisse aus:

- Implementierung und Review von TM01A;
- DCS-Laufzeittests des physischen Spawns und Straßenroutings;
- Verifikation der verwendeten MOOSE-APIs;
- Beobachtung des DCS-Straßenpathfindings;
- Entwurf der späteren Konvoi-Virtualisierung;
- Klärung der dauerhaften CampaignState-Persistenz;
- Neubewertung der logistischen Rolle von Bagram, Jalalabad/Fenty, FOBs, COPs und OPs.

Das Dokument unterscheidet nachgewiesene Testergebnisse, akzeptierte Architekturentscheidungen und noch offene Implementierungsarbeit.

## Zugehörige Entscheidungen

- [ADR 0011 – CampaignState als versionierte Snapshots persistieren](adr/0011-persist-campaign-state-as-versioned-snapshots.md)
- [ADR 0012 – Lufttransport zwischen strategischen Flugplätzen und Straßenkonvois für regionale Verteilung verwenden](adr/0012-use-airlift-between-strategic-airfields-and-road-convoys-for-regional-distribution.md)

## TM01A – implementierter Stand

### Repository- und Reviewstand

Die Road-Routing-Stufe besteht aus zwei Commits:

```text
82d2954 Add TM01A controlled road routing
9a7f876 Record TM01A road routing acceptance
```

Der zugehörige gestapelte Draft-PR ist:

```text
PR #6 – Add TM01A controlled road routing
base: feature/tm01a-physical-spawn
head: feature/tm01a-road-routing
```

Die Road-Routing-Implementierung baut auf dem kontrollierten physischen Spawn auf und verändert dessen Abnahmekriterien nicht.

### Getestete Umgebung

```text
DCS:                         2.9.27.25340 x86_64 MT
TM01A configuration:         TM01A-road-routing-1
TM01A bundle build:          2026-07-13T19:12:57Z
MOOSE release:               2.9.18
MOOSE embedded build:        2026-06-14T16:11:05+02:00
MOOSE embedded commit:       73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MOOSE file SHA-256:          e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die detaillierten Abnahmenachweise liegen unter:

```text
mission/tests/tm01-blue-convoy/results/2026-07-13-tm01a-physical-spawn.md
mission/tests/tm01-blue-convoy/results/2026-07-13-tm01a-road-routing.md
```

## Kontrollierter physischer Spawn

Nachgewiesen wurde:

- Bootstrap-Ergebnis `READY`;
- manueller Spawn erst nach F10-Befehl;
- genau eine Laufzeitgruppe;
- sechs erwartete und sechs tatsächliche Fahrzeuge;
- Laufzeitgruppe `TM01A_BLUE_CONVOY_001#001`;
- vollständige Mitgliedschaft in `ZONE_TM01_START_BAGRAM`;
- das Late-Activation-Template blieb inaktiv;
- ein zweiter Spawnversuch wurde abgewiesen;
- vor der Routenzuweisung blieb die Gruppe über mehrere Minuten stationär.

Der Spawncontroller und der Routencontroller bleiben getrennt. Spawn bedeutet nicht automatisch Bewegung.

## Kontrolliertes Straßenrouting

### Konfiguration

```text
Entity-ID:                   TEST.TM01.CONVOY.001
Route-ID:                    ROUTE_TM01_BAGRAM_JALALABAD
Anker:                       ZONE_TM01_ROUTE_01 bis _07
Ziel:                        ZONE_TM01_TARGET_JALALABAD
Gesamtzahl Wegpunkte:        8
Geschwindigkeit:             30 km/h
Formation:                   ON_ROAD → DCS "On Road"
```

Die sieben Anker und die Zielzone werden vollständig aufgelöst und in definierter Reihenfolge zu Wegpunkten umgewandelt, bevor genau eine Route an die Laufzeitgruppe übergeben wird.

### Zustandsmodell

```text
NOT_READY
READY
STARTING
EN_ROUTE
ARRIVED
ROUTE_FAILED
DESTROYED
```

Es gibt in dieser Stufe:

- keinen automatischen Spawn;
- keinen automatischen Routenstart;
- keinen Scheduler oder Polling-Loop;
- keine automatische Routenneuberechnung;
- keine Teleport-, Recovery- oder Unstuck-Logik;
- keinen Reset, Despawn oder Respawn;
- keine Cargo-, Warehouse-, Persistenz-, Feind- oder Hinterhaltlogik.

### Laufzeitergebnis

Nachgewiesen wurde:

- Route startete erst nach `Start convoy route`;
- `convoy_route_started` meldete sieben Anker und acht Wegpunkte;
- Status während der Fahrt war `EN_ROUTE`;
- `routeAssigned=true`;
- alle sechs Fahrzeuge blieben erhalten;
- die Gruppe erreichte vollständig die Zielzone;
- Endstatus war `ARRIVED`;
- `targetZoneMembership=true`;
- `convoy_route_arrived` wurde exakt einmal protokolliert;
- wiederholte Statusabfragen erzeugten kein zweites Ankunftsereignis;
- der Schutz gegen einen zweiten Routenbefehl wurde durch Operatorbeobachtung bestätigt; ein separates `convoy_route_rejected`-Ereignis wurde in dem archivierten Loglauf nicht erfasst.

Die physische Gesamtstrecke Bagram–Jalalabad ist damit für TM01A abgeschlossen. Eine spätere Verfeinerung der Anker dient Regression, Routenqualität oder produktionsnahen Routendaten, nicht dem noch ausstehenden Nachweis einer vollständigen Fahrt.

### Gemessene Fahrzeit

Die Route wurde bei Missionszeit `190.152` Sekunden gestartet und bei Missionszeit `25946.837` Sekunden als angekommen erkannt.

```text
simulierte Fahrzeit ab Routenzuweisung:
25756.685 Sekunden
≈ 7 Stunden 9 Minuten
```

Die reale Testdauer war durch DCS-Zeitbeschleunigung deutlich kürzer. Für Kampagnenbalancing ist die simulierte Fahrzeit maßgeblich.

## Verifizierte MOOSE-API-Verwendung

Die verwendeten Methoden wurden gegen die vendorte `Moose.lua` geprüft.

### `ZONE_BASE:GetCoordinate(Height)`

- liefert die `COORDINATE` des Zonenzentrums;
- der optionale Parameter verändert die Höhe;
- TM01A verwendet die deterministische Zonenmitte, keine Zufallskoordinate.

### `COORDINATE:WaypointGround(Speed, Formation, DCSTasks)`

- erwartet Geschwindigkeit in km/h;
- wandelt intern durch Division durch `3.6` in m/s um;
- verwendet den Formationswert als DCS-Wegpunktaktion;
- `30` wird daher unverändert übergeben;
- `ON_ROAD` wird auf `On Road` abgebildet.

### `CONTROLLABLE:Route(Route, DelaySeconds)`

- erwartet eine vollständige Routenpunkttabelle;
- erzeugt daraus eine RouteTask;
- setzt die Aufgabe über `SetTask`;
- liefert den Controllable-Wrapper oder `nil`, wenn kein DCS-Objekt verfügbar ist;
- TM01A verwendet Verzögerung `0`, wodurch `SetTask` unmittelbar ausgeführt wird.

## DCS-Straßenrouting – beobachtete Grenzen

Der Konvoi fuhr erfolgreich entlang des DCS-Straßennetzes, wählte aber erhebliche Umwege gegenüber der optisch naheliegenden Verbindung.

Mögliche Ursachen:

- unterbrochene oder nicht verbundene Abschnitte im Terrain-Straßengraphen;
- fehlerhafte Brücken- oder Kreuzungsverbindungen;
- ein Ankerzentrum liegt nicht exakt auf dem gewünschten Straßenabschnitt;
- DCS verbindet zwei `On Road`-Wegpunkte über einen anderen zulässigen Graphpfad;
- lokale Fahrbarkeitsregeln einzelner Fahrzeugtypen;
- große Distanz zwischen den wenigen groben Ankern.

Wichtig ist die Trennung:

- Der Controller bestimmte Ankerreihenfolge, Geschwindigkeit und einmalige Routenzuweisung korrekt.
- DCS bestimmte den konkreten Straßenpfad zwischen den Ankern.

Der beobachtete Umweg ist deshalb kein Controllerfehler, aber eine relevante Daten- und Missionsdesigngrenze.

## Folgerungen für produktive Routen

Eine produktive Route darf nicht nur aus Start, wenigen groben Ankern und Ziel bestehen. Sie benötigt einen versionierten Routendatensatz mit:

- kanonischer, gespeicherter Polylinie;
- Gesamtlänge;
- konfigurierter Geschwindigkeit;
- gemessener effektiver Reisegeschwindigkeit;
- typischer Fahrzeit;
- Fahrzeugklassen;
- Brücken, Engstellen und bekannten DCS-Problemen;
- validierten Materialisierungsankern;
- Hinterhalt- und Reveal-Abschnitten;
- letzter Validierung und DCS-Version.

`GetPathOnRoad()` kann Kandidaten erzeugen. Der resultierende Pfad bleibt ein DCS-Terrainvorschlag und muss mit den vorgesehenen Fahrzeugklassen praktisch gefahren werden.

## Virtuelle Konvoibewegung

### Grundsatz

Verdecktes oder virtualisiertes Fahren bedeutet nicht, dass eine unsichtbare DCS-Gruppe weiterfährt. Die physische Gruppe existiert außerhalb relevanter Beobachtung nicht. Der `CampaignState` führt die strategische Entität mathematisch entlang einer kanonischen Route weiter.

Zustandsmodell:

```text
VIRTUAL_MOVING
→ MATERIALIZING
→ PHYSICAL_MOVING
→ DEMATERIALIZING
→ VIRTUAL_MOVING
→ ARRIVED
```

### Virtueller Fortschritt

Mindestens zu halten sind:

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

Die aktuelle Position wird bei Bedarf aus Routenfortschritt, effektiver Geschwindigkeit und vergangener Kampagnenzeit interpoliert. Eine Koordinate muss nicht in jedem Frame persistiert werden.

### Konfigurierte und effektive Geschwindigkeit

Die konfigurierte DCS-Geschwindigkeit bleibt beispielsweise `30 km/h`. Für die virtuelle Reisezeit wird nach praktischer Kalibrierung eine effektive Geschwindigkeit oder typische Kantenfahrzeit verwendet. Kurven, Steigungen, Stau, Fahrzeugabstände und DCS-Wegfindung verhindern, dass die reale Durchschnittsgeschwindigkeit dauerhaft dem Sollwert entspricht.

### Materialisierung

Spieler oder relevante gegnerische Kräfte dürfen die Entität nicht erst im letzten Moment erscheinen sehen. Die Materialisierung beginnt in einem größeren Vorbereitungsradius:

```text
Annäherung oder Aufklärung erkannt
→ virtuelle Position bestimmen
→ Materialisierungsanker vorprüfen
→ Spielerentfernung, Sichtlinie und Sensorbeobachtung prüfen
→ sicheren Anker reservieren
→ Gruppe mit erhaltenen Fahrzeugslots erzeugen
→ verbleibende physische Route zuweisen
→ PHYSICAL_MOVING
```

Materialisiert wird nicht zwingend auf dem mathematisch exakten Punkt, sondern am nächsten sicheren, plausiblen und getesteten Anker. Ein kleiner Versatz entlang der Route ist einem sichtbaren Pop-in oder einem Spawn in ungeeigneter Geometrie vorzuziehen.

### Materialisierungsregeln

Vor dem Spawn werden mindestens geprüft:

- keine direkte Sichtlinie eines nahen Spielers;
- keine unmittelbare Nähe zu blauen oder roten physischen Einheiten;
- keine eindeutige aktive Sensorbeobachtung;
- ausreichender Platz für alle verbleibenden Fahrzeuge;
- plausible Verbindung zur virtuellen Position;
- stabile Ausfahrt auf die Reststrecke;
- keine bekannte problematische Brücke, Kreuzung oder Engstelle am Spawnpunkt.

Kann kein sicherer Punkt gefunden werden, bleibt die Entität virtuell, wird früher und weiter entfernt materialisiert oder wartet kontrolliert. Offenes sichtbares Erscheinen ist kein regulärer Fallback.

### Physischer Abgleich

Sobald die Gruppe physisch existiert, ist ihre tatsächliche DCS-Position die operative Bewegungsposition. Sie wird regelmäßig auf die kanonische Route projiziert:

```text
DCS-Koordinate
→ nächster plausibler Punkt der Polylinie
→ segmentIndex und routeDistanceMeters
→ CampaignState aktualisieren
```

Weicht DCS erheblich von der gespeicherten Route ab, wird nicht blind dematerialisiert. Stattdessen wird beispielsweise `ROUTE_DIVERGED` gesetzt und die Gruppe bleibt physisch, bis ein plausibler Abgleich möglich ist.

### Dematerialisierung

Dematerialisierung ist nur zulässig, wenn:

- keine Spieler oder relevanten Gegner in Reichweite sind;
- keine Sichtlinie oder Sensorbeobachtung besteht;
- kein Beschuss oder aktiver Kontakt läuft;
- kein Fahrzeug in ungeklärtem Stuck-Zustand ist;
- tatsächliche Position, Verluste, Fracht und Fahrzeugslots übernommen wurden;
- eine Abkühlzeit seit dem letzten Kontakt abgelaufen ist.

Danach wird die physische Gruppe entfernt und derselbe strategische Verband als `VIRTUAL_MOVING` fortgeführt.

### TM01B.1 – kontrollierter Cache-Zyklus

Der nächste Konvoimeilenstein prüft die grundlegende Repräsentationsumschaltung zunächst kontrolliert und innerhalb derselben Mission auf der bestehenden Bagram–Jalalabad-Stressroute.

Für diese isolierte Stufe gelten bewusst reduzierte Übergangsregeln:

- Materialisierung und Dematerialisierung werden manuell über F10 ausgelöst;
- Entry- und Exit-Zonen sind vorab im Mission Editor validierte Testanker;
- der virtuelle Übergang zwischen zwei Reveal-Abschnitten darf manuell fortgeschrieben werden;
- Spielerentfernung, Sichtlinie, Sensoren und automatische Zeitfortschreibung sind noch nicht Teil der Abnahme;
- Fahrzeugslots, Verluste, stabile Entity-ID und Ausschluss doppelter physischer Instanzen bleiben verbindlich.

Der Testvertrag liegt unter:

```text
mission/tests/tm01-blue-convoy/expected/caching-acceptance.md
```

## Persistenz – aktueller und geplanter Stand

### Aktueller Teststand

TM01A ist flüchtig. Seine Lua-Zustände existieren nur innerhalb der laufenden Mission. Weder Spawnzustand noch Route, Laufzeitgruppe oder Fortschritt werden über einen Neustart gespeichert.

Auch TM01B.1 verwendet zunächst ausschließlich einen flüchtigen `CampaignState` im Arbeitsspeicher. Dauerhafte CampaignState-Persistenz ist keine Voraussetzung für den kontrollierten Cache-Zyklus und bleibt ein eigener vertikaler Meilenstein.

ADR 0011 bleibt vollständig gültig. Geändert wird nur die Implementierungsreihenfolge: Snapshot, Backup und Journal werden umgesetzt, sobald ein Test Neustartwiederherstellung oder dauerhafte genau-einmalige Transaktionen tatsächlich benötigt.

### Zielmodell

```text
DCS- und MOOSE-Laufzeitobjekte
        ↓ Reconciliation
CampaignState im Arbeitsspeicher
        ↓ PersistenceManager
versionierter Snapshot + Transaktionsjournal
```

Persistiert werden stabile Domänendaten, nicht Runtime-Wrapper. Details legt ADR 0011 fest.

### Blaue und rote Zustände

Für blaue Verbände werden unter anderem gespeichert:

- stabile Entity-ID;
- `VIRTUAL` oder `PHYSICAL`;
- Route und Fortschritt;
- Zusammensetzung und Verluste;
- Cargo-Manifest und Auftrag;
- letzter bestätigter Kontakt;
- konfigurierte und effektive Geschwindigkeit.

Für rote Zellen werden unter anderem gespeichert:

- stabile Cell-ID;
- operativer Zustand;
- Concealment-Zustand;
- logischer Ort und Hide Site;
- Personal, Munition, Fahrzeuge und Moral;
- Intelligence- und Aufklärungsgrad;
- reservierte Fluchtwege und Strongpoints;
- letzter physischer Kontakt.

Konkrete DCS-Gruppennamen werden nicht gespeichert. Eine nach dem Neustart rekonstruierte Gruppe darf einen neuen Runtime-Namen erhalten.

### Offlinezeit

Im ersten Prototyp friert die Kampagnenzeit ein, solange Server oder Mission nicht laufen. Konvois, rote Operationen, Verbrauch und Gefechte werden nicht unbeobachtet anhand der Wall Clock weitergerechnet.

## Neubewertung der Logistikroute

### Bagram–Jalalabad

Die lange Strecke hat ihren Zweck als technischer Belastungs- und Regressionstest erfüllt. Sie wird jedoch nicht als reguläre Produktionskonvoiroute verwendet.

Begründung:

- Bagram und Jalalabad verfügen über Flugplätze;
- Bagram ist strategischer Rückraum mit Lufttransportkapazität;
- Jalalabad/Fenty ist regionaler Logistikhub;
- der DCS-Konvoi benötigte mehr als sieben Stunden simulierte Fahrzeit;
- regelmäßige physische Straßenkonvois würden unverhältnismäßig lange laufen und geringe taktische Dichte erzeugen.

Neue Einordnung:

```text
ROUTE_TM01_BAGRAM_JALALABAD
classification = TEST_STRESS_ROUTE
productionLogistics = false
```

Die Route bleibt für Langzeit-, Pathfinding-, Virtualisierungs- und Regressionstests erhalten.

### Strategischer Zufluss

```text
Bagram / Kabul
→ Fixed-Wing-Lufttransport oder strategisch abstrahierter Transfer
→ Jalalabad Airfield / FOB Fenty
```

Ein physischer Straßenkonvoi Bagram–Jalalabad ist nur als ausdrücklich begründetes Sonderereignis vorgesehen.

### Regionale Verteilung

```text
Jalalabad/Fenty
├── Straßenkonvoi → FOB Connolly und andere validierte Straßenstandorte
├── kleiner Straßenkonvoi → COPs und Checkpoints
├── CH-47/UH-60/UH-1 → abgelegene FOBs, COPs und OPs
└── Luftabwurf → abgeschnittene oder zeitkritische Ziele
```

Die primäre Produktionsroute des vertikalen Prototyps ist:

```text
ROUTE_FENTY_CONNOLLY_PRIMARY
```

Sie benötigt eine neue Routenaufnahme, praktische Fahrprüfung, typische Fahrzeit, Engstellen, Materialisierungsanker und nach Möglichkeit eine unabhängige Alternative.

## Aktualisierte Arbeitsreihenfolge

1. Persistenz-ADR, Transporthierarchie und TM01A-Erkenntnisse dokumentieren.
2. TM01B.1 als kontrollierten In-Memory-Cache-Zyklus auf der bestehenden Stressroute implementieren.
3. Physical-to-Virtual- und Virtual-to-Physical-Übergänge, Fahrzeugslots, Verluste und Duplikatschutz in DCS validieren.
4. Reveal-Zonen und Materialisierungsanker für den kontrollierten Test praktisch prüfen.
5. Fenty–Connolly als operative Route erfassen und vollständig physisch validieren.
6. Kanonische Polylinie, Länge, typische Fahrzeit, Engstellen und Materialisierungsanker speichern.
7. Die nachgewiesene Caching- und Virtualisierungslogik auf Fenty–Connolly übertragen.
8. Interest-, Proximity-, Sichtlinien- und Sensorlogik ergänzen.
9. Versionierte Persistenz, Backup-Recovery und Journal implementieren, sobald Neustartwiederherstellung oder dauerhafte Transaktionen Teil des nächsten Testvertrags sind.
10. Cargo- und Warehouse-Transaktionen erst an eine stabile Zustands-, Reconciliation- und Persistenzschicht anbinden.

## Offene Punkte

- Platzierung und praktische Validierung der vier TM01B-Reveal-Zonen;
- zuverlässige Fahrzeugslot-Erkennung über mehrere physische Generationen;
- kontrolliertes Entfernen einer physischen Gruppe ohne künstliches Verlustereignis;
- Wiederaufbau einer Gruppe mit ausschließlich erhaltenen Fahrzeugslots;
- Auswahl zwischen effektiver Geschwindigkeit und typischer Fahrzeit je Routenkante;
- Projektion physischer DCS-Koordinaten auf die kanonische Polylinie;
- Toleranz für `ROUTE_DIVERGED`;
- Materialisierungsradien nach Einheitstyp, Spielerplattform und Sensorlage;
- Validierung von Fenty–Connolly und möglicher Alternativroute;
- endgültiges Snapshotformat;
- zulässiger Serverpfad und DCS-Sandbox-Konfiguration;
- genaue Speicherintervalle unter Last;
- Transportwegentscheidung für Fahrzeuge und übergroße Fracht;
- kontrollierter späterer Offlinefortschritt für ausgewählte strategische Systeme.