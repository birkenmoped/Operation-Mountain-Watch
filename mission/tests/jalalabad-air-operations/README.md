# Jalalabad Air Operations

## Korrigierter Arbeitsstand

Die lokale ORBAT wird nicht 1:1 auf sichtbare Statics oder DCS-Parkpositionen abgebildet.

```text
logischer Bestand = CampaignState-/MOOSE-Reserve
sichtbare Statics = begrenzter visueller Ausschnitt
aktive Spieler/KI = momentan eingesetzte Luftfahrzeuge
virtuelle Reserve = Hallen, Wartung und nicht dargestellte Abstellflächen
```

Ein verlorenes Luftfahrzeug reduziert den Gesamtbestand dauerhaft. Eine andere, bislang unsichtbare Bestandsmaschine kann anschließend einen späteren Einsatz übernehmen. Das ist kein externer Ersatz.

Ein zerstörtes Static wird während derselben laufenden Mission nicht sofort sichtbar ersetzt. Bei einer späteren kontrollierten Ramp-Aktualisierung oder beim nächsten Missionsstart kann jedoch ein anderes überlebendes Reserveflugzeug einen freien Static-Platz einnehmen.

## 2011er Ramp-Momentaufnahme

Mindestens sichtbar:

```text
13 OH-58
 7 AH-64
 7 UH-60
 7 CH-47
 1 Mi-8
 1 UH-1
```

Mi-8 und UH-1 werden als beobachtete externe oder transiente Luftfahrzeuge geführt und derzeit nicht dem US-Task-Force-Shooter-Bestand zugerechnet.

## Logischer Jalalabad-Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
```

## DCS-Kapazitätsmodell

Für die realitätsnahen Hubschrauberflächen wurden 36 vergleichbare DCS-Positionen erfasst.

Jalalabad verwendet deshalb eine lokale Spielerbegrenzung von zwei Luftfahrzeugen je nutzbarem Typ:

```text
2 OH-58D-Spielerplätze
2 AH-64D-Spielerplätze
2 CH-47-Spielerplätze
0 oder 2 optionale UH-60L-Spielerplätze
```

KI-Templates benötigen zusammen sieben Mission-Editor-Startpositionen. Damit werden 13 Kern-Operationspositionen beziehungsweise 15 mit optionalem UH-60L reserviert.

Sichtbare Static-Obergrenzen:

```text
7 OH-58D
4 AH-64D
4 UH-60A
5 CH-47
```

Die 20 Statics plus 13 Kern-Operationspositionen ergeben 33 von 36 Positionen. Mit zwei optionalen UH-60L-Plätzen sind es 35. Statics dürfen auf geeigneten Apronflächen frei platziert werden, dürfen aber keine Spawn-, Rückkehr- oder Rollflächen blockieren.

## Technische Struktur

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

Templates:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
```

Der CH-47-DCS-Typ wird aus dem Mission-Editor-Template erkannt und anschließend für Spielergruppen und Statics verbindlich validiert.

## Gültige bestätigte Ergebnisse

- Jalalabad als MOOSE-Airbase ID 19,
- 50 auslesbare Parking-Einträge,
- Warehouse-Anker `WH_AIR_US_JALALABAD`,
- natives DCS-Warehouse und MOOSE-Storage,
- AIRWING-Konstruktion und explizite Airbase-Zuordnung,
- OH-58D-Typ und OH-58D-SQUADRON-Konstruktion,
- AH-64D-Typ und AH-64D-SQUADRON-Konstruktion.

## Aktueller Missionseditor-Arbeitsauftrag

```text
expected/jalalabad-complete-node-acceptance.md
```

## Repository-Workflow

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git pull --ff-only

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\build-jalalabad-air-operations-bundle.ps1
```

Nach dem Build muss `OMW_AirOps_Jalalabad.lua` im Mission Editor erneut ausgewählt und die Mission gespeichert werden.
