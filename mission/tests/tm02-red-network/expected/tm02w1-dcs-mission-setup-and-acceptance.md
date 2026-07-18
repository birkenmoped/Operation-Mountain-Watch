# TM02W1 – DCS-Missionsaufbau und Abnahme für RED Network Registry

## Status

```text
IMPLEMENTED LUA
DCS MISSION SETUP REQUIRED
DCS VALIDATION PENDING
```

TM02W1 setzt direkt auf der bestandenen TM02V-Testmission auf. Es prüft ausschließlich die Registrierung der vorhandenen Netzwerkstandorte, die Trennung von Site und Node sowie den allgemeinen Graphen.

TM02W1 bewegt noch kein Personal und trifft keine Kommandeursentscheidung.

## Missionsname

Dateiname:

```text
OMW_TEST_TM02W1_RED_NETWORK_REGISTRY.miz
```

Anzeigename:

```text
OMW TM02W1 - RED Network Registry
```

## Was aus TM02V unverändert übernommen wird

Die bestehende TM02V-Mission wird kopiert.

Unverändert erhalten bleiben:

- die zehn roten Vorlagengruppen `TPL_TEST_RED_PACKET_01_01` bis `TPL_TEST_RED_PACKET_10_01`;
- der Blue-Client-Slot;
- die vorhandenen Positionen von HQ, A, B, AA, AB, BA und BB;
- MOOSE und die übrigen allgemeinen Testmissionsobjekte.

Die zehn roten Gruppen sind Stärkevorlagen. Sie sind keine Netzverbindungen und werden in W1 nicht aktiviert.

## Benötigte Netzwerkpunkte

Es werden keine neuen Netzwerkpunkte benötigt.

Die vorhandene TM02V-Struktur besitzt bereits genau die sieben benötigten Standorte:

```text
1 Haupt-HQ
2 Unter-HQs: A und B
4 normale Sites: AA, AB, BA und BB
```

Gesamt:

```text
7 kreisförmige Triggerzonen einschließlich HQ
0 zusätzliche Routengruppen
0 zusätzliche Routenwegpunkte
```

## Exakte Umbenennung der vorhandenen Zonen

```text
ZONE_TM02N_HQ -> OMW_RED_HQ_Test
ZONE_TM02N_A  -> OMW_RED_SUBHQ_A
ZONE_TM02N_B  -> OMW_RED_SUBHQ_B
ZONE_TM02N_AA -> OMW_RED_SITE_AA
ZONE_TM02N_AB -> OMW_RED_SITE_AB
ZONE_TM02N_BA -> OMW_RED_SITE_BA
ZONE_TM02N_BB -> OMW_RED_SITE_BB
```

Die Zonenpositionen und Radien dürfen für den ersten W1-Lauf unverändert bleiben.

Es darf keine weitere Triggerzone mit einem der folgenden Präfixe existieren:

```text
OMW_RED_HQ_
OMW_RED_SUBHQ_
OMW_RED_SITE_
OMW_RED_NODEAREA_
```

HQ sowie A und B werden als vorhandene aktive Nodes registriert. AA, AB, BA und BB werden als verfügbare, noch unbesetzte Sites registriert.

## Logische Netzwerkverbindungen

Die Verbindungen werden für W1 in `config-tm02w1.lua` definiert. Dafür werden keine zusätzlichen DCS-Gruppen benötigt.

```text
HQ <-> A
HQ <-> B
A  <-> AA
A  <-> AB
B  <-> BA
B  <-> BB
AB <-> BA
```

Die letzte Verbindung `AB <-> BA` ist die Querverbindung. Sie beweist, dass das Produktionsnetz kein reiner Baum sein muss.

Erwartete Topologie:

```text
                 OMW_RED_HQ_Test
                    /       \
                   /         \
       OMW_RED_SUBHQ_A     OMW_RED_SUBHQ_B
           /       \           /       \
          /         \         /         \
OMW_RED_SITE_AA  OMW_RED_SITE_AB---OMW_RED_SITE_BA  OMW_RED_SITE_BB
```

## Warum W1 keine Wegpunkte benötigt

W1 validiert nur den logischen Graphen. Es bewegt keine DCS-Gruppe.

Für jeden Link berechnet W1 lediglich:

```text
Luftlinienentfernung zwischen den Zonenmittelpunkten
rechnerische Laufzeit bei 5 km/h
```

Diese Werte dienen nur der Registry- und Graphprüfung.

Ab TM02W2 bewegen sich reale Laufgruppen Knoten für Knoten entlang des Graphen. Für den ersten W2-Test kann die bereits bekannte direkte Off-Road-Bewegung zwischen den vorhandenen Testzonen verwendet werden. Geländespezifische Wegpunktvorlagen oder Routenkorridore werden nur dann ergänzt, wenn die spätere Afghanistan-Produktionsmission sie wegen unpassierbaren Geländes tatsächlich benötigt.

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

Nach jeder Neuerzeugung von `TM02W1.lua` muss die Datei im Mission Editor erneut ausgewählt und die Mission gespeichert werden.

## Erwartetes F10-Menü

```text
F10 Other
└── OMW Tests
    └── TM02W1 RED Network Registry
        ├── Show validation summary
        ├── List locations
        ├── List links
        └── Toggle markers
```

## Pflichtnachweis im DCS-Log

```text
event=red_network_registry_validation
configurationVersion=TM02W1-red-network-registry-2
configurationValid=true
headquartersCount=1
subHeadquartersCount=2
ordinarySiteCount=4
nodeAreaCount=0
activeNodeCount=3
linkCount=7
locationCount=7
componentCount=1
connectedLocationCount=7
hasAlternativeConnection=true
errorCount=0
```

Zusätzlich müssen genau sieben Ereignisse `red_network_location_registered` und sieben Ereignisse `red_network_link_registered` vorhanden sein.

## PASS

TM02W1 besteht, wenn:

- exakt die sieben bestehenden TM02-Zonen unter ihren neuen Präfixnamen registriert werden;
- exakt ein HQ und zwei Unter-HQs erkannt werden;
- HQ, A und B aktive Nodes besitzen;
- AA, AB, BA und BB als Sites ohne aktiven Node registriert werden;
- exakt sieben konfigurierte Links registriert werden;
- alle sieben Standorte vom HQ erreichbar sind;
- die Querverbindung `AB <-> BA` erkannt wird;
- der Graph dadurch nicht auf einen Baum beschränkt ist;
- für jeden Link direkte Entfernung und rechnerische Laufzeit berechnet werden;
- keine Gruppe aktiviert oder bewegt wird;
- kein `[OMW][TM02W1] level=ERROR` im Log erscheint.

## Automatische FAIL-Fälle

- fehlende oder zusätzliche Zone mit einem W1-Präfix;
- mehrere Haupt-HQs oder kein Haupt-HQ;
- fehlender Link-Endpunkt;
- doppelter Linkname;
- Link von einem Site zu sich selbst;
- nicht erreichbarer Standort;
- fehlende Querverbindung;
- Bewegung, Auffüllung oder Kommandeursentscheidung in W1.
