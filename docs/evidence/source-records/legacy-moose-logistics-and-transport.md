# MOOSE-Logistik und Transport in Operation Mountain Watch

## 1. Grundsatz

Logistik und Transport werden nicht durch eine einzige Klasse abgebildet. Für OMW sind mehrere Ebenen zu unterscheiden:

```text
CampaignState
├── strategischer Bestand und Persistenz
├── endgültige Verluste
└── Ressourcen- und Standortzustände

MOOSE
├── WAREHOUSE / AIRWING / BRIGADE als Laufzeitbestand
├── OPSTRANSPORT als Transportauftrag
├── FLIGHTGROUP / ARMYGROUP als Carrier oder Cargo
├── CTLD als Spielerlogistik
├── CSAR als Rettungsmechanik
└── RAT ausschließlich als atmosphärischer Verkehr
```

`CampaignState` bleibt die autoritative strategische Quelle. MOOSE bildet den aktuellen Laufzeitzustand ab und darf keine unkontrollierten Ersatzbestände erzeugen.

## 2. WAREHOUSE

### Aktueller Einsatz

Die Warehouse-Funktion wird im validierten Jalalabad-Knoten über `AIRWING` verwendet.

```lua
AIRWING:New(warehouseName, airwingName)
```

Das benannte Warehouse-Objekt muss als MOOSE-referenzierbares `STATIC` oder `UNIT` existieren.

### Validierter Stand

- Warehouse-Anker `WH_AIR_US_JALALABAD` vorhanden,
- AIRWING erfolgreich konstruiert,
- Airbase explizit gesetzt,
- `WAREHOUSE / AIRWING` erfolgreich gestartet.

### Noch nicht validiert

- begrenzte Munition und Payloadbestände,
- Treibstoffbestände,
- Nachschublieferungen,
- Asset-Zugang und -Abgang während der Mission,
- Persistenz über Missionsneustarts,
- Wiederaufbau zerstörter Infrastruktur,
- direkter Einsatz von `WAREHOUSE:New()` außerhalb eines AIRWING.

## 3. OPSTRANSPORT

### Vorgesehener Einsatz

`OPSTRANSPORT` soll taktische Truppen- und Frachttransporte zwischen definierten Lade- und Entladezonen abbilden.

Mögliche Carrier:

- `FLIGHTGROUP` für Hubschrauber und Transportflugzeuge,
- `ARMYGROUP` für Bodenfahrzeuge,
- gegebenenfalls weitere OPSGROUP-Ableitungen.

Mögliche Cargo-Objekte:

- transportierbare `ARMYGROUP`-Gruppen,
- Fracht- oder Logistikobjekte gemäß MOOSE-Unterstützung,
- projektseitig referenzierte Manifeste, soweit MOOSE das strategische Modell nicht selbst abbildet.

### Projektstatus

`PLANNED`.

Die Jalalabad-Baseline enthält bereits Transport-Capabilities und Lade-/Entladezonen, aber noch keinen validierten OPSTRANSPORT-Laufzeitfluss.

### Verbindliche Testfälle

1. Carrier wird aus geeignetem AIRWING/SQUADRON ausgewählt.
2. Carrier startet vertikal beziehungsweise mit geeigneter Hubschrauberoption.
3. Carrier erreicht die Ladezone.
4. Cargo wird geladen.
5. Carrier fliegt oder fährt zur Entladezone.
6. Cargo wird entladen und als aktive Gruppe weitergeführt.
7. Transport wird erfolgreich beendet.
8. Carrier-Verlust vor dem Laden führt zu FAIL.
9. Carrier-Verlust nach dem Laden führt zu FAIL und korrektem Cargo-Zustand.
10. Carrier-Verlust nach dem Entladen darf den Transport nicht fälschlich dauerhaft `ACTIVE` oder `NOT_RUN` lassen.
11. Ein zerstörtes Asset beendet Telemetrie und Scheduler ohne fortlaufende Coordinate-Fehler.
12. Entpackte Gruppen werden anschließend durch Bodenlogik und Watchguard weiter überwacht.

### Relevante COMMANDER-Methode

```lua
commander:AddOpsTransport(transport)
```

Diese Methode ist im OMW-Grundknoten noch nicht praktisch validiert.

## 4. FLIGHTGROUP

### Vorgesehener Einsatz

`FLIGHTGROUP` bildet die laufende MOOSE-OPS-Fluggruppe ab, die aus einem AIRWING-Asset hervorgeht oder an eine bestehende Gruppe gebunden wird.

Zu prüfen sind insbesondere:

- Zeitpunkt, zu dem das FLIGHTGROUP-Objekt verfügbar ist,
- sichere Zuordnung zum richtigen Asset,
- Missions- und Transportstatus,
- Landung und Recovery,
- Fuel- und Coordinate-Abfragen,
- Verlust- und Dead-Zustände,
- FSM-Events.

### Hubschrauberoption

Für Hubschrauber ist folgende MOOSE-Methode als vorgesehene Standardlösung zu prüfen und versionsbezogen zu validieren:

```lua
flightGroup:SetOptionPreferVertical()
```

Sie darf erst als OMW-validiert dokumentiert werden, wenn:

- die Methode in der tatsächlich geladenen MOOSE-Version vorhanden ist,
- sie vor dem relevanten Start-/Dispatch-Zeitpunkt gesetzt wird,
- sie für OH-58D, AH-64D, UH-60 und CH-47 praktisch geprüft wurde,
- sie auch bei OPSTRANSPORT-Assets wirksam ist,
- keine unerwünschten Start- oder Landeeffekte auftreten.

### Projektstatus

`PLANNED` beziehungsweise `IN_USE_PARTIAL`, sobald ein konkreter Entwicklungsbranch die Bindung implementiert. Der zentrale Klassenindex darf erst nach Prüfung und DCS-Nachweis aktualisiert werden.

## 5. CTLD

### Vorgesehener Einsatz

MOOSE CTLD ist für spielergesteuerte Logistik vorgesehen, beispielsweise:

- Truppen aufnehmen und absetzen,
- Fracht transportieren,
- FOB- oder Stellungskomponenten bewegen,
- Slingload- und interne Frachtabläufe,
- spielergesteuerte Nachschubaufgaben.

### Abgrenzung

CTLD ersetzt nicht automatisch:

- strategischen CampaignState,
- KI-gesteuerten OPSTRANSPORT,
- AIRWING- oder BRIGADE-Bestände,
- persistente Verlustbuchung,
- die OMW-Missionsgenerierung.

Vor Implementierung ist festzulegen, welche CTLD-Ereignisse in CampaignState übernommen werden und wie doppelte Bestandsführung verhindert wird.

### Projektstatus

`PLANNED`.

## 6. CSAR und MEDEVAC

### CSAR

MOOSE CSAR ist für die Rettung abgeschossener oder ausgestiegener Besatzungen vorgesehen.

### MEDEVAC

OMW-MEDEVAC ist ein eigener taktischer Missionsfall mit einem verbindlichen Paket aus:

```text
1 Lead-Hubschrauber
1 Cover-Hubschrauber
```

CSAR und MEDEVAC dürfen nicht ohne klare Zuständigkeit vermischt werden.

Zu klären sind:

- Welche Personentypen erzeugt MOOSE CSAR?
- Welche Ereignisse werden durch DCS und MOOSE geliefert?
- Wie wird ein CSAR-Fall persistent?
- Wann wird ein AUFTRAG oder OPSTRANSPORT erzeugt?
- Wie wird das 1+1-MEDEVAC-Paket koordiniert?
- Wie werden Erfolg, Teilverlust und vollständiger Fehlschlag verbucht?

### Projektstatus

`PLANNED`.

## 7. RAT

### Verbindliche Rolle

RAT wird ausschließlich für nicht persistenten atmosphärischen Hintergrundverkehr verwendet.

```lua
ratTraffic = {
  atmosphericOnly = true,
  persistent = false,
  affectsInventory = false,
  transfersResources = false,
  continuousTraffic = false
}
```

RAT-Flüge dürfen:

- keine strategischen Ressourcen übertragen,
- keine lokalen Bestände verändern,
- keine echten Logistikmissionen ersetzen,
- keine permanenten Luftfahrzeuge erzeugen,
- die globale taktische Supportgrenze nicht umgehen.

### Projektstatus

`PLANNED`.

## 8. Lade-, Entlade- und Übergabezonen

Jalalabad enthält bereits benannte Zonen für:

- MEDEVAC Ready,
- CH-47 Ready,
- Heavy-Lift Load,
- Logistics Load,
- Logistics Unload,
- Sling Pickup,
- C-130 Unload.

Bislang validiert ist nur ihre Existenz. Noch zu testen sind:

- Zonenradius und Geländeeignung,
- Erkennung von Carrier und Cargo,
- gleichzeitige Nutzung durch mehrere Gruppen,
- Feindkontakt und Abbruch,
- Verhalten bei zerstörtem Carrier,
- Entpacken und Weiterführung der Cargo-Gruppe,
- Persistenz und Cleanup.

## 9. Verbotene Abkürzungen

Folgende Implementierungen sind ohne vorherige MOOSE-Prüfung nicht zulässig:

- eigener kompletter Transport-Zustandsautomat, obwohl OPSTRANSPORT den Ablauf bereits abbildet,
- direkter `SPAWN` von Ersatztransportern ohne Bestandsprüfung,
- manuelles Teleportieren von Cargo ohne Prüfung des MOOSE-Transportzustands,
- parallele Bestandsführung in CTLD, WAREHOUSE und CampaignState ohne eindeutige Autorität,
- RAT als echter Ressourcentransport,
- direkte Nutzung interner MOOSE-Tabellen, wenn öffentliche Events oder Methoden existieren.

## 10. Quellen

- WAREHOUSE: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Warehouse.html>
- AIRWING: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Airwing.html>
- OPSTRANSPORT: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.OpsTransport.html>
- FLIGHTGROUP: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.FlightGroup.html>
- ARMYGROUP: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.ArmyGroup.html>
- CTLD: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.CTLD.html>
- CSAR: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.CSAR.html>
- RAT: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Rat.html>

## 11. OMW-Nachweise

- [`Luftoperations- und ORBAT-Umsetzung`](../18-air-operations-implementation.md)
- [`Jalalabad Air Operations Manifest`](../21-jalalabad-air-operations-manifest.md)
- [`Jalalabad complete Air Operations node: PASS`](../../mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md)