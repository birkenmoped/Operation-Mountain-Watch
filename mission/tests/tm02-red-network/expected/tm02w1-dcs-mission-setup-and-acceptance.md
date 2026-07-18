# TM02W1 – DCS-Missionsaufbau und Abnahme fuer RED Network Registry

## Status

```text
IMPLEMENTED LUA
STATIC HARNESS PASS
DCS MISSION SETUP REQUIRED
DCS VALIDATION PENDING
```

TM02W1 prueft die Registrierung eines roten Standortnetzes mit getrenntem Fuehrungs- und Bewegungsgraphen sowie zwei Blue-Zielgebieten.

TM02W1 bewegt noch kein Personal, erzeugt keine Proxygruppe und trifft keine Kommandeursentscheidung.

## Keine Produktionsgrenze

Die nachfolgende Anzahl ist ausschliesslich die feste W1-Testtopologie. Sie ist weder Minimum noch Maximum fuer spaetere Missionen.

```text
11 rote Standorte
2 Blue-Zielgebiete
17 logische Bewegungsverbindungen
10 logische Fuehrungsverbindungen
```

Die zehn vorhandenen roten Vorlagengruppen aus TM02V bleiben unveraendert. Sie sind Personalstaerke-Vorlagen und haben nichts mit der Anzahl der Netzstandorte zu tun.

## Missionsname

Dateiname:

```text
OMW_TEST_TM02W1_RED_NETWORK_REGISTRY.miz
```

Anzeigename:

```text
OMW TM02W1 - RED Network Registry
```

## Ausgangspunkt

Die bestandene TM02V-Mission wird kopiert.

Unveraendert erhalten bleiben:

- die zehn Gruppen `TPL_TEST_RED_PACKET_01_01` bis `TPL_TEST_RED_PACKET_10_01`;
- der Blue-Client-Slot;
- MOOSE und die allgemeinen Testobjekte;
- die sieben vorhandenen Standortzonen als geometrische Ausgangspunkte.

Es werden keine Routengruppen und keine Routenwegpunkte angelegt.

## Netzwerkebenen

TM02W1 trennt drei Ebenen:

1. **Fuehrungsgraph** – wer an wen meldet und welchem Kommandobereich ein Standort zugeordnet ist;
2. **Bewegungsgraph** – zwischen welchen benachbarten Standorten Personal spaeter marschieren darf;
3. **Blue-Zielgebiete** – operative Ziele, aber keine roten Netzknoten.

Damit gilt:

```text
Fuehrungsweg ist nicht automatisch Marschweg.
```

Ein Standort kann dem linken SHQ unterstehen und trotzdem ueber zentrale oder rechte Nachbarknoten versorgt werden.

## Benoetigte Zonen

Gesamt:

```text
11 rote kreisfoermige Triggerzonen
2 blaue kreisfoermige Zielzonen
0 Routengruppen
0 Routenwegpunkte
```

### Vorhandene sieben Zonen umbenennen

```text
ZONE_TM02N_HQ -> OMW_RED_HQ_Main
ZONE_TM02N_A  -> OMW_RED_SUBHQ_Left
ZONE_TM02N_B  -> OMW_RED_SUBHQ_Right
ZONE_TM02N_AA -> OMW_RED_SITE_Left_01
ZONE_TM02N_AB -> OMW_RED_SITE_Left_02
ZONE_TM02N_BA -> OMW_RED_SITE_Right_01
ZONE_TM02N_BB -> OMW_RED_SITE_Right_02
```

### Vier neue zentrale RED-Sites

Neu als kreisfoermige Triggerzonen anlegen:

```text
OMW_RED_SITE_Central_01
OMW_RED_SITE_Central_02
OMW_RED_SITE_Central_03
OMW_RED_SITE_Central_04
```

Empfohlener Radius fuer alle roten W1-Zonen:

```text
100 m
```

### Zwei neue Blue-Zielgebiete

```text
OMW_BLUE_OBJECTIVE_FOB
OMW_BLUE_OBJECTIVE_Airport
```

Empfohlene Radien:

```text
FOB:      500 m
Airport:  800 m
```

Die Blue-Zonen sind keine Bewegungs- oder Fuehrungsknoten.

## Empfohlene Anordnung

Die genaue Anzahl und Geometrie ist nur fuer diesen Test fest. Abstaende sind in W1 keine PASS-/FAIL-Grenze.

```text
                              OMW_RED_HQ_Main

              Central_01                           Central_02

              Central_03                           Central_04

        OMW_RED_SUBHQ_Left                    OMW_RED_SUBHQ_Right

       Left_01          Left_02              Right_01         Right_02

             OMW_BLUE_OBJECTIVE_FOB       OMW_BLUE_OBJECTIVE_Airport
```

Praktische Platzierung:

- keine Zonen ueberlappen lassen;
- benachbarte rote Punkte fuer gute Lesbarkeit etwa 1,5 bis 3 km auseinander setzen;
- Blue-Ziele unterhalb beziehungsweise vor den zugeordneten Einsatzknoten platzieren;
- die alte TM02V-Geometrie darf dafuer angepasst werden;
- die Darstellung muss nicht exakt symmetrisch sein.

## Fuehrungsgraph

Der Fuehrungsgraph wird aus `commandParentId` aufgebaut.

```text
OMW_RED_HQ_Main
├── OMW_RED_SUBHQ_Left
│   ├── OMW_RED_SITE_Left_01
│   └── OMW_RED_SITE_Left_02
├── OMW_RED_SUBHQ_Right
│   ├── OMW_RED_SITE_Right_01
│   └── OMW_RED_SITE_Right_02
├── OMW_RED_SITE_Central_01
├── OMW_RED_SITE_Central_02
├── OMW_RED_SITE_Central_03
└── OMW_RED_SITE_Central_04
```

Kommandobereiche:

```text
CENTRAL
LEFT
RIGHT
```

Nur HQ und beide SHQs besitzen in W1 einen aktiven Node. Die acht normalen Sites bleiben zunaechst verfuegbar und unbesetzt.

## Bewegungsgraph

Die Bewegungsverbindungen werden ausschliesslich in `config-tm02w1.lua` definiert. Im Mission Editor werden dafuer keine Gruppen oder Wegpunkte benoetigt.

```text
HQ_Main     <-> Central_01
HQ_Main     <-> Central_02
Central_01  <-> Central_02
Central_01  <-> Central_03
Central_02  <-> Central_04
Central_03  <-> Central_04
Central_03  <-> SUBHQ_Left
Central_04  <-> SUBHQ_Right
Central_03  <-> SUBHQ_Right
Central_04  <-> SUBHQ_Left
SUBHQ_Left  <-> Left_01
SUBHQ_Left  <-> Left_02
Left_01     <-> Left_02
SUBHQ_Right <-> Right_01
SUBHQ_Right <-> Right_02
Right_01    <-> Right_02
Left_02     <-> Right_01
```

Die Links `Central_03 <-> SUBHQ_Right`, `Central_04 <-> SUBHQ_Left` und `Left_02 <-> Right_01` beweisen, dass Bewegung nicht an den Fuehrungsbereich gebunden ist.

W1 berechnet fuer jeden Bewegungslink nur:

```text
Luftlinienentfernung
rechnerische Laufzeit bei 5 km/h
Kommandobereichsueberschreitung ja/nein
```

Reale Knoten-zu-Knoten-Bewegung folgt erst in TM02W2.

## Blue-Zuordnungen

```text
OMW_BLUE_OBJECTIVE_FOB
├── OMW_RED_SITE_Left_01
└── OMW_RED_SITE_Left_02

OMW_BLUE_OBJECTIVE_Airport
├── OMW_RED_SITE_Right_01
└── OMW_RED_SITE_Right_02
```

Diese Zuordnungen stellen nur operative Relevanz her. Sie erzeugen keine Marschverbindung.

## Skript bauen

Branch:

```text
feature/tm02w-red-network-registry
```

PowerShell:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git fetch origin
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

In der kopierten Mission wird die bisherige TM02V-Skriptaktion entfernt oder deaktiviert.

Ein Trigger:

```text
Typ:       MISSION START
Bedingung: keine
```

Aktionen:

```text
1. DO SCRIPT FILE -> vendor/moose/Moose.lua
2. DO SCRIPT FILE -> mission/tests/tm02-red-network/dist/TM02W1.lua
```

Nach jeder Neuerzeugung von `TM02W1.lua` muss die Datei im Mission Editor erneut ausgewaehlt und die Mission gespeichert werden.

## Erwartetes F10-Menue

```text
F10 Other
└── OMW Tests
    └── TM02W1 RED Network Registry
        ├── Show validation summary
        ├── List RED locations
        ├── List command graph
        ├── List movement graph
        ├── List BLUE objectives
        └── Toggle markers
```

## Pflichtnachweis im DCS-Log

```text
event=red_network_registry_validation
configurationVersion=TM02W1-red-network-command-movement-3
configurationValid=true
redLocationCount=11
headquartersCount=1
subHeadquartersCount=2
ordinarySiteCount=8
activeNodeCount=3
nodeAreaCount=0
commandAreaCount=3
commandLinkCount=10
commandReachableFromHqCount=11
commandAcyclic=true
movementLinkCount=17
movementComponentCount=1
movementReachableFromHqCount=11
movementHasCycle=true
movementCrossAreaLinkCount=5
objectiveCount=2
objectiveAssociationCount=4
errorCount=0
```

Zusaetzlich:

```text
11 x event=red_network_location_registered
10 x event=red_command_link_registered
17 x event=red_movement_link_registered
 2 x event=blue_objective_registered
```

## PASS

TM02W1 besteht, wenn:

- alle 11 roten Standorte und beide Blue-Ziele erkannt werden;
- exakt ein HQ und zwei SHQs vorhanden sind;
- nur HQ und SHQs aktive Nodes besitzen;
- alle roten Standorte ueber den Fuehrungsgraphen vom HQ erreichbar sind;
- der Fuehrungsgraph keinen Zyklus enthaelt;
- alle roten Standorte ueber den Bewegungsgraphen vom HQ erreichbar sind;
- der Bewegungsgraph mindestens einen Zyklus und fuenf bereichsueberschreitende Links besitzt;
- beide Blue-Ziele jeweils zwei zugeordnete rote Sites besitzen;
- keine Gruppe aktiviert, erzeugt oder bewegt wird;
- kein `[OMW][TM02W1] level=ERROR` im Log erscheint.

## Automatische FAIL-Faelle

- fehlende oder zusaetzliche Zone mit einem W1-Praefix;
- falsches Praefix fuer die konfigurierte Rolle;
- kein HQ oder mehrere HQs;
- unbekannter, fehlender oder ungeeigneter Fuehrungsvorgesetzter;
- Zyklus oder nicht erreichbarer Standort im Fuehrungsgraphen;
- unbekannter, doppelter oder selbstreferenzierender Bewegungslink;
- nicht zusammenhaengender Bewegungsgraph;
- Bewegungsgraph ohne alternativen Weg;
- kein bereichsueberschreitender Bewegungslink;
- Blue-Ziel ohne gueltige Site-Zuordnung;
- Personalbewegung oder Kommandeursentscheidung in W1.
