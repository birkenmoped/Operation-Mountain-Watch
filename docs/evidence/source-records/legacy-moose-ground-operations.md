# MOOSE-Bodenoperationen in Operation Mountain Watch

## 1. Aktueller Status

Die aktuelle Jalalabad-Air-Operations-Baseline validiert keine vollständige MOOSE-Bodenoperationsarchitektur. Für Bodengruppen existieren im Gesamtprojekt bereits Anforderungen wie:

- dynamische und virtualisierte Verbände,
- Routenbewegung,
- Transport und Entpacken,
- Festfahrerkennung und Recovery,
- Schutz vor Teleportation bei Aufklärung oder Feindkontakt,
- persistente Verluste und Zustände,
- Einbindung in Missions- und Logistikabläufe.

Bevor diese Anforderungen durch weitere eigene Watchguard-, Routing- oder Zustandslogik umgesetzt werden, sind die folgenden MOOSE-Klassen verbindlich zu prüfen.

## 2. ARMYGROUP

### Vorgesehener Nutzen

`ARMYGROUP` ist die MOOSE-OPS-Abstraktion für eine laufende Bodengruppe.

Zu prüfen sind insbesondere:

- Erzeugung beziehungsweise Bindung an eine bestehende DCS-Gruppe,
- Routenzuweisung und Wegpunktfortschritt,
- Zustandsmodell und FSM-Events,
- Missionen über `AUFTRAG`,
- Verwendung als Cargo oder Carrier in `OPSTRANSPORT`,
- Verhalten nach Be- und Entladen,
- Verlust-, Dead- und Stuck-Zustände,
- Erreichbarkeit und Koordinatenabfrage.

### Projektstatus

`PLANNED`.

Die Klasse darf erst als validiert markiert werden, wenn sie mit einer normalen sowie einer zuvor transportierten und entpackten Gruppe praktisch getestet wurde.

## 3. BRIGADE

### Vorgesehener Nutzen

`BRIGADE` ist die landgestützte Legion-/Warehouse-Abstraktion für mehrere Platoons beziehungsweise Bodengruppen.

Mögliche Aufgaben:

- lokaler Fahrzeug- und Truppenbestand,
- Auswahl geeigneter Assets für AUFTRAG,
- Zusammenarbeit mit COMMANDER,
- Nachschub- und Recovery-Zonen,
- spätere Verbindung zu CampaignState.

### Projektstatus

`PLANNED`.

Vor Einführung muss entschieden werden, welche Bestände autoritativ in `CampaignState` liegen und welche Zustände BRIGADE nur zur Laufzeit abbildet.

## 4. SET_GROUP und weitere Sets

### Vorgesehener Nutzen

MOOSE-Sets können Gruppen dynamisch nach Coalition, Category, Prefix, Zone oder weiteren Kriterien filtern und aktuell halten.

Vor eigener Gruppenregistrierung oder periodischen Vollsuchen ist zu prüfen, ob `SET_GROUP` beziehungsweise ein anderes `Core.Set`-Objekt die gewünschte Menge bereits zuverlässig abbildet.

Mögliche Projektverwendung:

- alle verwalteten Konvois,
- alle entpackten Transportgruppen,
- alle gegnerischen Gruppen in einem Operationsraum,
- alle Gruppen, die für einen Watchguard relevant sind,
- alle Gruppen mit einem bestimmten Namenspräfix.

### Projektstatus

`PLANNED`.

## 5. SPAWN

### Grundsatz

`SPAWN` darf nicht automatisch verwendet werden, wenn die Gruppe eigentlich als Asset eines AIRWING, einer BRIGADE, eines WAREHOUSE oder eines OPSTRANSPORT-Lebenszyklus geführt werden muss.

Vor `SPAWN` ist zu prüfen:

1. Wird das Asset bereits durch eine OPS-/Legion-Klasse verwaltet?
2. Muss der Bestand persistent begrenzt werden?
3. Muss die Gruppe nach Verlust als endgültig verloren gelten?
4. Muss die Gruppe einem AUFTRAG oder OPSTRANSPORT zugeordnet werden?
5. Würde ein direkter Spawn den Warehouse- oder CampaignState-Bestand umgehen?

`SPAWN` ist vor allem für klar abgegrenzte, nicht anderweitig verwaltete Gruppen geeignet.

### Projektstatus

`PLANNED`.

## 6. OPSZONE und Zonenmodell

`OPSZONE` ist als mögliche Standardabstraktion für operative Zonen zu prüfen.

Mögliche Anforderungen:

- Besitz und Coalition,
- Eroberung oder Verlust,
- Einheiten in der Zone,
- Aktivierung von Missionen,
- Verbindung zum CampaignState,
- Übergabe an COMMANDER oder MissionGenerator.

### Projektstatus

`CANDIDATE`.

Es ist noch nicht entschieden, ob `OPSZONE` das strategische OMW-Zonenmodell vollständig abbilden kann oder nur als Laufzeitadapter verwendet wird.

## 7. INTEL und TARGET

### INTEL

Möglicher Nutzen:

- Erkennung und Klassifizierung gegnerischer Gruppen,
- gemeinsames Lagebild,
- Weitergabe erkannter Ziele an OPS-Klassen.

### TARGET

Möglicher Nutzen:

- standardisierte Zielobjekte für AUFTRAG,
- Gruppen-, Objekt-, Koordinaten- und Zonenziele,
- einheitliche Zielübergabe an Luft- und Bodeneinheiten.

### Projektstatus

Beide `CANDIDATE`.

Vor Einführung ist die Überschneidung mit `RedDirector`, `MissionGenerator`, eigener Aufklärung und CampaignState zu klären.

## 8. Watchguard- und Stuck-Recovery-Regeln

Für jede weitere Entwicklung der Festfahrerkennung gilt:

1. Zuerst MOOSE-Funktionen von `ARMYGROUP`, `OPSGROUP`, Routing-, Event- und Zonenklassen prüfen.
2. Direkte DCS-Gruppenabfragen nur verwenden, wenn MOOSE keine ausreichende öffentliche Methode bereitstellt.
3. Eine entpackte Transportgruppe muss denselben Schutz und dieselbe Überwachung erhalten wie eine normal gestartete Gruppe.
4. Recovery darf nicht teleportieren, wenn die Gruppe aufgeklärt, unter Beschuss, in unmittelbarer Feindnähe oder Teil eines laufenden Gefechts ist.
5. Versuchszähler, zurückgelegte Distanz und erfolgreiche Recovery-Schritte müssen als expliziter Zustandsautomat dokumentiert werden.
6. Vor einem eigenen Zustandsautomaten sind vorhandene FSM-Events und Zustände der OPS-Gruppe zu prüfen.
7. Jede Teleport-, Respawn- oder Routenänderung muss mit CampaignState und Verlustmodell vereinbar sein.

## 9. Noch erforderliche MOOSE-Recherche

Vor der nächsten Bodenoperations-Implementierung müssen mindestens geprüft und dokumentiert werden:

- `Ops.ArmyGroup`,
- gemeinsame `Ops.OpsGroup`-Funktionen,
- `Ops.Brigade`,
- `Ops.OpsTransport`,
- `Core.Set`, insbesondere `SET_GROUP`,
- `Core.Spawn`,
- `Core.Event`,
- `Core.Fsm`,
- `Core.Zone` und gegebenenfalls `Ops.OpsZone`,
- vorhandene Routing- und Wegpunktmethoden.

## 10. Quellen

- MOOSE Develop Index: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/index.html>
- ARMYGROUP: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.ArmyGroup.html>
- BRIGADE: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Brigade.html>
- OPSTRANSPORT: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.OpsTransport.html>
- SET: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Set.html>
- SPAWN: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Spawn.html>
- EVENT: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Event.html>
- FSM: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Fsm.html>

## 11. Validierungsanforderung

Ein Bodenoperationsmodul erhält den Status `VALIDATED` erst nach mindestens folgenden Tests:

- normal gestartete Gruppe,
- transportierte und entpackte Gruppe,
- Route ohne Feindkontakt,
- Route mit Feindkontakt,
- bewusst blockierte oder festgefahrene Gruppe,
- Recovery innerhalb des erlaubten Rahmens,
- gesperrte Recovery bei Aufklärung oder Gefecht,
- Verlust und CampaignState-Verbuchung,
- Missionsende beziehungsweise Cleanup ohne Timer- oder Coordinate-Fehler.