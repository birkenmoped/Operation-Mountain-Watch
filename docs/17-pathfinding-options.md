# 17 – Pathfinding-Optionen

## Ziel

MOOSE stellt zwei unterschiedliche Arten der Wegfindung bereit, die nicht miteinander verwechselt werden dürfen:

1. direkte Nutzung des DCS-Straßen- oder Schienennetzes;
2. generisches A*-Pathfinding auf einem eigenen Knotenraster oder Graphen.

Beide Verfahren benötigen bekannte Start- und Zielpunkte. Keines erzeugt automatisch eine semantische Liste aller Städte und Dörfer.

## DCS-Straßen- und Schienenpfad

Für eine Verbindung zwischen zwei bekannten Koordinaten verwendet das Projekt bevorzugt:

```lua
local path, length, valid =
  startCoordinate:GetPathOnRoad(destinationCoordinate, true, false)
```

Für Schienen wird der Railroad-Parameter gesetzt:

```lua
local railPath, length, valid =
  startCoordinate:GetPathOnRoad(destinationCoordinate, true, true)
```

Vorteile:

- nutzt das karteneigene DCS-Netz;
- geringe eigene Modellierung;
- liefert eine konkrete Polylinie;
- eignet sich für Konvois und virtuelle straßengebundene Bewegung.

Grenzen:

- Start und Ziel müssen bereits bekannt sein;
- ein Pfad kann fehlen;
- die gelieferte Geometrie garantiert keine fehlerfreie AI-Fahrt;
- Hindernisse, militärische Risiken und zeitweilige Blockaden sind nicht automatisch enthalten.

## MOOSE ASTAR

Die MOOSE-Klasse `ASTAR` implementiert generisches A*-Pathfinding. Sie unterstützt:

- vordefinierte oder eigene Knoten;
- rechteckige Raster;
- Filter nach Oberflächentyp;
- eigene Regeln für gültige Nachbarn;
- eigene Kostenfunktionen;
- Distanz-, Sichtlinien- und Straßenverbindungsprüfungen;
- Rückgabe eines Knotenpfads zwischen Start und Ziel.

Beispielhafte Verwendung:

```lua
local finder = ASTAR:New()
  :SetStartCoordinate(startCoordinate)
  :SetEndCoordinate(destinationCoordinate)

finder:CreateGrid(
  { land.SurfaceType.LAND },
  20000,
  10000,
  1000,
  1000,
  false
)

finder:SetValidNeighbourDistance(1500)
finder:SetCostDist2D()

local nodes = finder:GetPath()
```

Die exakte Signatur und Eignung wird vor Implementierung gegen die eingebundene MOOSE-Version getestet.

## Straßenbasierte A*-Regeln

`ASTAR` kann Übergänge zwischen zwei Knoten danach bewerten, ob DCS zwischen ihnen einen Straßenpfad findet. Außerdem kann die Straßenentfernung als Kostenwert verwendet werden.

Dies ist sinnvoll, wenn wir einen eigenen Graphen aus strategischen Knoten aufbauen und zwischen mehreren möglichen Verbindungen auswählen wollen.

Es ersetzt nicht `GetPathOnRoad()` für die endgültige detaillierte Straßenpolylinie.

## Anwendungsfälle für Operation Mountain Watch

### Direkter DCS-Straßenpfad

Verwendung für:

- Jalalabad/Fenty–FOB Connolly;
- Versorgungskonvois;
- QRF-Fahrten;
- physische und virtuelle Straßenbewegung;
- alternative Routen zwischen bekannten Knoten.

### A*-Graph

Spätere Verwendung für:

- Auswahl zwischen mehreren strategischen Routen;
- rote Bewegungen durch Täler, Pässe und Seitentäler;
- Umgehung gesperrter oder kontrollierter Räume;
- Risikokosten für Checkpoints, Aufklärung und Luftpräsenz;
- geländebasierte Bewegung ohne vollständiges Straßennetz;
- Verbindung eines eigenen Orts- und Infrastrukturgraphen.

## Kostenmodell

Eine spätere projektspezifische Kostenfunktion kann berücksichtigen:

```text
Entfernung
+ Geländekosten
+ Steigung
+ Straßenqualität
+ bekannte Feindpräsenz
+ Checkpoint-Risiko
+ Luftaufklärungsrisiko
+ Tageszeit
+ Wetter
+ aktuelle Blockaden
```

Beispielhaft:

```lua
local function CampaignRouteCost(nodeA, nodeB, context)
  local cost = nodeA.coordinate:Get2DDistance(nodeB.coordinate)

  cost = cost * context.terrainMultiplier(nodeA, nodeB)
  cost = cost + context.threatPenalty(nodeA, nodeB)
  cost = cost + context.checkpointPenalty(nodeA, nodeB)

  return cost
end
```

## Keine automatische Siedlungserkennung

A* berechnet einen Pfad über bereitgestellte oder erzeugte Knoten. Es benennt keine Knoten als Stadt oder Dorf und erkennt keine militärische Bedeutung.

Siedlungskandidaten müssen deshalb weiterhin aus einem begrenzten Scenery-Scan, Mission-Editor-Zonen oder manueller Kartenerfassung stammen. Erst danach können sie als A*-Knoten verwendet werden.

## Performance

Ein feines Raster über große Teile Afghanistans ist für die Produktionsmission ungeeignet. Die Zahl der Knoten und möglichen Nachbarschaften steigt schnell an.

Regeln:

- nur begrenzte Sektoren untersuchen;
- Raster so grob wie fachlich möglich wählen;
- Ergebnisse cachen;
- große Berechnungen in Discovery- oder Build-Schritte verlagern;
- Produktionsmission nur mit freigegebenen Knoten und Kanten starten;
- Laufzeit-Neuberechnung nur bei relevanten Blockaden oder Lageänderungen.

## Entscheidung für den Prototyp

Der erste Prototyp verwendet:

1. ein eigenes Register bekannter Orte;
2. `GetPathOnRoad()` für die Route Fenty–Connolly;
3. manuelle Fahrtests und gespeicherte Routenanker.

`ASTAR` ist keine Pflichtkomponente des ersten Prototyps. Die Klasse wird für spätere rote Offroad-Bewegung und strategische Routenauswahl evaluiert.
