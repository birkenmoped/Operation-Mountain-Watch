# Jalalabad AirOps – korrigierter vollständiger Abschlussauftrag

## Grundsatz: Bestand ist nicht gleich sichtbare Ramp-Belegung

Nicht jedes Luftfahrzeug des lokalen SQUADRON-Bestands benötigt gleichzeitig ein sichtbares Static oder einen eigenen DCS-Parkplatz.

Verbindliche Ebenen:

1. **Logischer Bestand** – numerische CampaignState-/MOOSE-Reserve des Flugplatzes.
2. **Aktive Luftfahrzeuge** – aktuell von Spielern oder KI verwendete Maschinen.
3. **Sichtbare Statics** – begrenzter visueller Ausschnitt der inaktiven Reserve.
4. **Virtuelle Reserve** – verbleibende Maschinen in Hallen, Wartung, dispersal areas oder nicht dargestellten Abstellflächen.

Ein Verlust erzeugt keinen externen Ersatz:

```text
Bestand vor Verlust: 8
aktives Luftfahrzeug verloren: -1
verbleibender Bestand: 7
```

Eine andere Maschine aus der bislang unsichtbaren Reserve darf danach einen späteren Einsatz übernehmen oder bei einer späteren Ramp-Aktualisierung als Static sichtbar werden. Das ist kein Ersatz von außen, sondern ein anderes vorhandenes Bestandsluftfahrzeug.

Während derselben laufenden Mission wird ein zerstörtes Static nicht unmittelbar sichtbar ersetzt. Eine kontrollierte Neuverteilung sichtbarer Statics erfolgt erst beim nächsten Missionsstart oder einer später definierten Wartungs-/Ramp-Aktualisierung.

## Evidenzbasis der 2011er Momentaufnahme

Auf der ausgewerteten Satellitenaufnahme wurden mindestens gezählt:

```text
13 OH-58
 7 AH-64
 7 UH-60
 7 CH-47
 1 Mi-8
 1 UH-1
```

Die Aufnahme ist eine Momentaufnahme. Weitere Luftfahrzeuge können im Einsatz, in Wartungshallen oder auf anderen Flächen gewesen sein.

Mi-8 und UH-1 werden als beobachtete externe oder transiente Luftfahrzeuge dokumentiert, aber derzeit nicht dem US-Task-Force-Shooter-Bestand zugerechnet.

## Korrigierter logischer Jalalabad-Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
```

Diese 48 Luftfahrzeuge werden ausdrücklich nicht gleichzeitig physisch dargestellt.

## DCS-Parkplatzmodell

Für Jalalabad wurden 36 DCS-Positionen identifiziert, die den auf der Satellitenaufnahme erkennbaren Hubschrauberflächen entsprechen oder funktional vergleichbar sind.

Verbindliche Reduktion:

```text
maximale Spieler-Luftfahrzeuge je Typ und Basis: 2
```

### Kern-Spielerplätze

```text
CLIENT_US_JBAD_OH58D_01
CLIENT_US_JBAD_OH58D_02

CLIENT_US_JBAD_AH64D_01
CLIENT_US_JBAD_AH64D_02

CLIENT_US_JBAD_CH47_01
CLIENT_US_JBAD_CH47_02
```

Je Gruppe genau ein Luftfahrzeug, Skill `Client`, Cold Start.

### Optionale UH-60L-Spielerplätze

```text
CLIENT_US_JBAD_UH60L_01
CLIENT_US_JBAD_UH60L_02
```

Entweder beide oder keiner. Die Kernmission muss ohne Community-Mod lauffähig bleiben.

### KI-Templates

Alle als BLUE/USA, `High`, Late Activation, Cold Start:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP          2 Luftfahrzeuge
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP            2 Luftfahrzeuge
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP    1 Luftfahrzeug
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP   1 Luftfahrzeug
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP       1 Luftfahrzeug
```

Damit werden im Mission Editor 7 Template-Startpositionen benötigt.

### Formale Parkplatzrechnung

```text
6 verpflichtende Kern-Spielerplätze
7 KI-Template-Startpositionen
---------------------------------
13 reservierte Kern-Operationspositionen

+ 2 optionale UH-60L-Spielerplätze
= 15 reservierte Operationspositionen
```

Von 36 vergleichbaren Positionen verbleiben damit:

```text
23 Positionen ohne UH-60L-Mod
21 Positionen mit UH-60L-Mod
```

für sichtbare Statics und mindestens eine freie Sicherheits-/Ausweichposition.

## Sichtbare Static-Obergrenzen

Verbindlicher erster Ramp-Zustand:

```text
7 OH-58D-Statics
4 AH-64D-Statics
4 UH-60A-Statics
5 CH-47-Statics
----------------
20 sichtbare Statics
```

Namen:

```text
STATIC_AIR_US_JBAD_OH58D_01 bis _07
STATIC_AIR_US_JBAD_AH64D_01 bis _04
STATIC_AIR_US_JBAD_UH60_01 bis _04
STATIC_AIR_US_JBAD_CH47_01 bis _05
```

Die 20 Statics plus 13 Kern-Operationspositionen ergeben 33 belegte beziehungsweise reservierte Positionen. Mit den zwei optionalen UH-60L-Slots sind es 35 von 36. Damit bleibt mindestens eine vergleichbare Position frei.

Statics dürfen auch frei auf geeigneten Apronflächen platziert werden, sofern sie keine DCS-Spawn-/Rückkehrposition, Rollroute oder Rotorscheibe blockieren. Sie sind keine zusätzlichen Luftfahrzeuge, sondern eine visuelle Darstellung des bestehenden Bestands.

## Empfohlene Flächenzuordnung

- `G01-G07`: bevorzugt sichtbarer OH-58D-Bereich entsprechend der Satellitenaufnahme.
- `C01-C14`: CH-47-Heavy-Lift-Bereich; Mischung aus fünf sichtbaren Statics, zwei Spielerpositionen sowie freien KI-/Rückkehrpositionen.
- südliche und westliche Aprons: gemischte AH-64D-/UH-60-Darstellung und deren Operationspositionen.
- keine Static-Platzierung auf einer Position, die für Spieler, Template-Start, KI-Spawn oder Rückkehr reserviert ist.

Die endgültige Einzelzuordnung der Parking-IDs erfolgt visuell im Mission Editor, weil DCS-Flächen und Satellitenpositionen nicht 1:1 übereinstimmen.

## Zonen

```text
ZONE_AIR_US_JBAD_STATIC_OH58D
ZONE_AIR_US_JBAD_STATIC_AH64D
ZONE_AIR_US_JBAD_STATIC_UH60
ZONE_AIR_US_JBAD_STATIC_CH47
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_CH47_READY
ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

## Technische SQUADRON-Struktur

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV             24 Luftfahrzeuge / 12 Two-Ship-Asset-Gruppen
├── SQ_US_JBAD_AH64D_B_1_10_AVN           8 Luftfahrzeuge /  4 Two-Ship-Asset-Gruppen
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC        8 Luftfahrzeuge /  8 Single-Ship-Asset-Gruppen
└── SQ_US_JBAD_CH47_HEAVYLIFT              8 Luftfahrzeuge /  8 Single-Ship-Asset-Gruppen
```

Der tatsächliche interne DCS-Typ des verfügbaren CH-47-Modells wird beim Test aus `TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP` erkannt und anschließend verbindlich für CH-47-Spielergruppen und Statics geprüft.

## Verlust- und Nachrücklogik

```text
verbleibender Bestand
= Ausgangsbestand
- endgültig verlorene Spielerflugzeuge
- endgültig verlorene KI-Flugzeuge
- zerstörte Statics
```

Maximal sichtbare Statics eines Typs:

```text
min(
  konfigurierte Static-Obergrenze,
  verbleibender Bestand - aktive Spieler - aktive KI - reservierte Einsätze
)
```

Ein unsichtbares Reserveflugzeug kann für einen späteren Auftrag nachrücken. Der Verlust selbst bleibt aber permanent und reduziert den Gesamtbestand.

## Repository-Workflow

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\build-jalalabad-air-operations-bundle.ps1
```

Danach `OMW_AirOps_Jalalabad.lua` im Mission Editor erneut als `DO SCRIPT FILE` auswählen und die Mission speichern.

## Abschlusstest

Mission mindestens 30 Sekunden laufen lassen. Das AIRWING darf nur starten, wenn alle fünf Templates, vier SQUADRONs, sechs Kern-Spielergruppen, 20 Statics, elf Zonen und der Warehouse-Anker korrekt erkannt wurden.

Erwartetes Ergebnis:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
[OMW][AirOps.JBAD.COMPLETE] SUMMARY inventory=OH58D:24/AH64D:8/UH60:8/CH47:8 corePlayerSlots=6 optionalUH60L=0or2 staticCaps=OH58D:7/AH64D:4/UH60:4/CH47:5 zones=11 templates=5 squadrons=4 medevac=1+1 virtualReserve=true.
```
