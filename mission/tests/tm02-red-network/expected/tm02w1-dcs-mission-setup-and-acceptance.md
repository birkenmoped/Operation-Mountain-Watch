# TM02W1 – DCS-Missionsaufbau und Abnahme für RED Network Registry

## Status

```text
IMPLEMENTED LUA
DCS MISSION SETUP REQUIRED
DCS VALIDATION PENDING
```

TM02W1 prüft ausschließlich Mission-Editor-Registry, Site/Node-Trennung und einen allgemeinen Netzwerkgraphen. Es bewegt noch kein Personal und trifft keine Kommandeursentscheidung.

## Missionsname

Dateiname:

```text
OMW_TEST_TM02W1_RED_NETWORK_REGISTRY.miz
```

Anzeigename:

```text
OMW TM02W1 - RED Network Registry
```

Empfohlene Grundlage ist eine Kopie der zuletzt bestandenen TM02V-Testmission. Die TM02V-Skriptaktion wird in der Kopie entfernt oder deaktiviert. Die ursprüngliche TM02V-Mission bleibt unverändert.

## Benötigte graphische Punkte

Der kleinste vollständige TM02W1-Aufbau benötigt:

```text
6 kreisförmige Triggerzonen als Netzwerkstandorte
6 Late-Activation-Routengruppen
mindestens 2 Wegpunkte je Routengruppe
```

Damit sind mindestens vorhanden:

```text
6 Standortanker
12 Routenendpunkte/Wegpunkte
```

Zwischenwegpunkte sind erlaubt und für Geländekorridore empfohlen. Sie sind keine zusätzlichen Netzknoten.

Zusätzlich benötigt die Mission einen Blue-Client-Slot für das F10-Menü und die üblichen Skriptaktionen. Diese Objekte zählen nicht zum Netzwerkgraphen.

## Exakte Standortzonen

Alle sechs Standorte werden als kreisförmige Triggerzonen mit Radius `100 m` angelegt.

```text
OMW_RED_HQ_Test
OMW_RED_SUBHQ_Test
OMW_RED_SITE_RearCompound
OMW_RED_SITE_FrontFarm
OMW_RED_SITE_ValleyHouse
OMW_RED_SITE_ReplacementFarm
```

Regeln:

- Kreisradius exakt 100 m für den ersten Abnahmelauf;
- Abstand der Zonenmittelpunkte mindestens 250 m;
- Zonen dürfen sich nicht überlappen;
- keine weitere Zone mit einem Präfix `OMW_RED_HQ_`, `OMW_RED_SUBHQ_`, `OMW_RED_SITE_` oder `OMW_RED_NODEAREA_`;
- TM02W1 verwendet noch kein `OMW_RED_NODEAREA_*`;
- HQ und SUBHQ erzeugen jeweils einen aktiven Node am gleichnamigen Site;
- die vier normalen Sites bleiben unbesetzt und besitzen in W1 noch keinen Node.

### Wiederverwendung der bisherigen TM02-Zonen

Beim Kopieren der vorhandenen Testmission können sechs Zonen umbenannt werden:

```text
ZONE_TM02N_HQ  -> OMW_RED_HQ_Test
ZONE_TM02N_A   -> OMW_RED_SUBHQ_Test
ZONE_TM02N_B   -> OMW_RED_SITE_RearCompound
ZONE_TM02N_AA  -> OMW_RED_SITE_FrontFarm
ZONE_TM02N_AB  -> OMW_RED_SITE_ValleyHouse
ZONE_TM02N_BA  -> OMW_RED_SITE_ReplacementFarm
```

`ZONE_TM02N_BB` wird gelöscht oder erhält einen Namen ohne `OMW_RED_*`-Präfix.

Die geometrische Position der übernommenen Zonen darf angepasst werden, solange die Abstands- und Routenregeln eingehalten werden.

## Exakte Routengruppen

Jede Route ist eine RED-Bodengruppe mit genau einer Infanterieeinheit.

Empfohlene Einheit:

```text
Insurgents / Infantry AK
```

Gruppeneinstellungen:

```text
Late Activation:        aktiviert
Hidden on planner map:  aktiviert
Visible before start:   beliebig; Gruppe wird nicht aktiviert
Einheitenzahl:          genau 1
```

Wegpunkte:

```text
Typ:          Turning Point
Aktion:       Off Road
Geschwindigkeit: 5 km/h
Anzahl:       mindestens 2
```

Der erste Wegpunkt liegt vorzugsweise im Zentrum der Quellzone. Der letzte Wegpunkt liegt vorzugsweise im Zentrum der Zielzone. Jeder Endpunkt muss innerhalb genau einer Standortzone liegen.

Die Wegpunktrichtung dient nur der eindeutigen Registrierung und Logausgabe. Alle W1-Verbindungen werden logisch als bidirektional registriert.

### Route 1

```text
Gruppenname: OMW_RED_ROUTE_HQ_SubHQ
WP1: OMW_RED_HQ_Test
letzter WP: OMW_RED_SUBHQ_Test
```

### Route 2

```text
Gruppenname: OMW_RED_ROUTE_SubHQ_Rear
WP1: OMW_RED_SUBHQ_Test
letzter WP: OMW_RED_SITE_RearCompound
```

### Route 3

```text
Gruppenname: OMW_RED_ROUTE_Rear_Front
WP1: OMW_RED_SITE_RearCompound
letzter WP: OMW_RED_SITE_FrontFarm
```

### Route 4

```text
Gruppenname: OMW_RED_ROUTE_Front_Valley
WP1: OMW_RED_SITE_FrontFarm
letzter WP: OMW_RED_SITE_ValleyHouse
```

### Route 5 – alternative Querverbindung

```text
Gruppenname: OMW_RED_ROUTE_Rear_Valley
WP1: OMW_RED_SITE_RearCompound
letzter WP: OMW_RED_SITE_ValleyHouse
```

Diese Route erzeugt zusammen mit Route 3 und Route 4 den erforderlichen alternativen Weg beziehungsweise Zyklus.

### Route 6 – späterer Ersatzstandort

```text
Gruppenname: OMW_RED_ROUTE_Rear_Replacement
WP1: OMW_RED_SITE_RearCompound
letzter WP: OMW_RED_SITE_ReplacementFarm
```

Der Replacement-Site bleibt in W1 unbesetzt. Er wird bereits in den Graph aufgenommen, damit dieselbe Missionsgeometrie später für W5 weiterverwendet werden kann.

## Erwartete Topologie

```text
OMW_RED_HQ_Test
       |
OMW_RED_SUBHQ_Test
       |
OMW_RED_SITE_RearCompound
       |             \
       |              \
OMW_RED_SITE_FrontFarm  OMW_RED_SITE_ReplacementFarm
       |              
       |              
OMW_RED_SITE_ValleyHouse
       ^
       |
       +--- alternative Verbindung von RearCompound
```

Graphwerte:

```text
Standorte/Vertices: 6
Routen/Edges:       6
Komponenten:        1
vom HQ erreichbar: 6
Alternative:       ja
```

## Skript bauen

Auf dem Branch:

```text
feature/tm02w-red-network-registry
```

PowerShell:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git switch feature/tm02w-red-network-registry
git pull --ff-only

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\build-tm02w1-bundle.ps1
```

Erzeugte Datei:

```text
mission/tests/tm02-red-network/dist/TM02W1.lua
```

## DCS-Trigger

In der kopierten Mission wird die bisherige TM02V-Skriptaktion entfernt.

Ein Trigger genügt:

```text
Typ:       MISSION START
Bedingung: keine
```

Aktionen in dieser Reihenfolge:

```text
1. DO SCRIPT FILE -> vendor/moose/Moose.lua
2. DO SCRIPT FILE -> mission/tests/tm02-red-network/dist/TM02W1.lua
```

TM02W1 benötigt für die Registry selbst keine MOOSE-Funktion. MOOSE bleibt geladen, damit die Testmission dem späteren Projektaufbau entspricht.

Nach jeder Neuerzeugung von `TM02W1.lua` muss die Datei im Mission Editor erneut ausgewählt und die Mission gespeichert werden.

## Erwartetes F10-Menü

```text
F10 Other
└── OMW Tests
    └── TM02W1 RED Network Registry
        ├── Show validation summary
        ├── List locations
        ├── List routes
        └── Toggle markers
```

## Pflichtnachweis im DCS-Log

```text
event=red_network_registry_validation
configurationVersion=TM02W1-red-network-registry-1
configurationValid=true
headquartersCount=1
subHeadquartersCount=1
ordinarySiteCount=4
nodeAreaCount=0
activeNodeCount=2
routeCount=6
locationCount=6
componentCount=1
connectedLocationCount=6
hasAlternativeConnection=true
errorCount=0
```

Zusätzlich müssen genau sechs Ereignisse `red_network_location_registered` und sechs Ereignisse `red_network_route_registered` vorhanden sein.

## PASS

TM02W1 besteht, wenn:

- exakt die sechs erwarteten Standortzonen registriert werden;
- exakt ein HQ und ein SUBHQ erkannt werden;
- nur HQ und SUBHQ aktive Nodes besitzen;
- die vier normalen Sites ohne Node registriert werden;
- exakt sechs Late-Activation-Routen erkannt werden;
- jeder Routenendpunkt eindeutig einer Standortzone zugeordnet wird;
- alle sechs Standorte vom HQ erreichbar sind;
- der Graph eine alternative Verbindung enthält und daher kein reiner Baum ist;
- Distanz und erwartete Reisezeit für jede Route berechnet werden;
- keine Gruppe aktiviert oder bewegt wird;
- kein `[OMW][TM02W1] level=ERROR` im Log erscheint.

## Automatische FAIL-Fälle

- fehlendes oder zusätzliches Objekt mit einem TM02W1-Präfix;
- mehrere HQs oder kein HQ;
- überlappende Standortzonen mit mehrdeutigem Routenendpunkt;
- Routengruppe nicht auf Late Activation;
- Routengruppe mit mehr oder weniger als einer Einheit;
- weniger als zwei Wegpunkte;
- Start und Ziel derselben Route im gleichen Site;
- nicht erreichbarer Standort;
- kein alternativer Weg beziehungsweise kein Zyklus;
- Bewegung, Auffüllung oder Kommandeursentscheidung in W1.
