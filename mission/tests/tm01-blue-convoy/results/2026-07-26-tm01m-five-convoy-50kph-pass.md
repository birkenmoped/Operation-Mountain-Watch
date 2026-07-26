# TM01M – Fünf gleichzeitige MSR-Konvois mit 50 km/h: DCS-PASS

Datum: 26. Juli 2026  
Ergebnis: **PASS**

## Validierter Stand

```text
Branch:               feature/tm01m-moose-native-baseline
Commit:               da2714af9d312d92913a0b325ca3c2e8e91f8064
Konfiguration:        TM01M-moose-native-five-convoys-1
DCS:                  2.9.28.26283
Sollgeschwindigkeit:  50 km/h
Formation:            On Road
Konvois:              5
Fahrzeuge je Konvoi:  6
Gesamtfahrzeuge:      30
```

## Beweismittel

```text
dcs(87).log
SHA-256: 001da2ab13274c725f59d66f40e2a05a4a26e7d6978cbbc0cd6d67bf1c9ab5b3

debrief(40).log
SHA-256: 0f88067b1b12aaaf2a8111a97714fd478890ee1157e8adfb6a45ad1e50855523
```

## Bootstrap und Routenplanung

Der Bootstrap meldete:

```text
configurationVersion=TM01M-moose-native-five-convoys-1
convoyCount=5
msrPathlineCount=6
sourcePointCount=1618
compiledPointCount=1883
totalRouteLengthMeters=450405
speedKph=50
formation=On Road
outcome=READY
```

Alle fünf Routenpläne wurden erfolgreich aus den sechs Mission-Editor-PATHLINEs erzeugt.

## Spawn-Ergebnis

Alle fünf Gruppen wurden aus demselben Template erzeugt. Jeder Verband bestand aus sechs Fahrzeugen; insgesamt wurden 30 Fahrzeuge gespawnt.

```text
EAST_E3_BGR_KBL       maximumSpawnRoadSnapMeters=2
EAST_E2_KBL_JBAD      maximumSpawnRoadSnapMeters=1
EAST_E1_TRK_JBAD      maximumSpawnRoadSnapMeters=4
KUNAR_K1_JBAD_ASAD    maximumSpawnRoadSnapMeters=0
CAL_ASAD_BOSTIK       maximumSpawnRoadSnapMeters=2
```

Visuelle Beobachtung des Projektinhabers:

- alle fünf Spawnaufstellungen waren ausgezeichnet;
- keine Fahrzeuge erschienen in Gebäuden, Mauern oder auf Dächern;
- die individuelle straßengerechte Positionierung und Ausrichtung funktionierte bei allen 30 Fahrzeugen.

## Routenzuweisung

```text
EAST_E3_BGR_KBL
routeLengthMeters=61748
waypointCount=27
maximumWaypointRoadSnapMeters=11

EAST_E2_KBL_JBAD
routeLengthMeters=151450
waypointCount=63
maximumWaypointRoadSnapMeters=17

EAST_E1_TRK_JBAD
routeLengthMeters=73746
waypointCount=32
maximumWaypointRoadSnapMeters=9

KUNAR_K1_JBAD_ASAD
routeLengthMeters=96073
waypointCount=41
maximumWaypointRoadSnapMeters=88

CAL_ASAD_BOSTIK
routeLengthMeters=66840
waypointCount=30
maximumWaypointRoadSnapMeters=4
```

Alle fünf Gruppen erhielten genau eine MOOSE-PATHLINE-basierte Route mit `speedKph=50` und `formation=On Road`.

## Ankünfte

```text
15:57:48  EAST_E3_BGR_KBL       Kabul       survivingVehicles=6
15:58:37  CAL_ASAD_BOSTIK       FOB Bostik  survivingVehicles=6
16:00:11  EAST_E1_TRK_JBAD      Jalalabad   survivingVehicles=6
16:02:18  KUNAR_K1_JBAD_ASAD    Asadabad    survivingVehicles=6
16:09:42  EAST_E2_KBL_JBAD      Jalalabad   survivingVehicles=6
```

Abschließender technischer Nachweis:

```text
event=all_convoys_arrived
convoyCount=5
speedKph=50
survivingVehicles=30
```

Damit haben alle 30 Fahrzeuge ihre jeweils vorgesehene Zielzone erreicht.

## Fachliche Beobachtung: Jalalabad

Die gleichzeitige beziehungsweise zeitlich versetzte Nutzung der eng überlappenden Zielbereiche in Jalalabad funktionierte, war nach der Ankunft jedoch räumlich kritisch. Dies ist kein Fehler der Route oder der Ankunftserkennung, sondern ein Lebenszyklusproblem: Angekommene Konvois verblieben dauerhaft im Zielbereich und belegten dort Straßenraum.

Für den Kampagnenbetrieb ist ein dauerhaftes Abstellen auf der Zielstraße nicht erforderlich. Als Folgeinkrement wird deshalb nach erkannter vollständiger Ankunft eine Abklingzeit von 60 Sekunden verwendet. Danach wird die Gruppe über MOOSE `GROUP:Destroy(false, 60)` ohne künstliche Dead-/Crash-Ereignisse entfernt.

## PASS-Bewertung

Bestanden wurden:

- fünf parallele MOOSE-Konvois;
- 30 korrekt platzierte Fahrzeuge aus einem gemeinsamen Template;
- sechs Mission-Editor-PATHLINEs;
- automatische Vorwärts-/Rückwärtsorientierung der MSR-Geometrie;
- CAL-C1/CAL-C2-Verkettung;
- 50 km/h Sollgeschwindigkeit für alle fünf Verbände;
- parallele DCS-Ground-AI-Wegfindung;
- vollständige Ankunft aller fünf Gruppen;
- 30 überlebende Fahrzeuge;
- keine TM01M-Lua-Fehler im relevanten Lauf.

## Folgeinkrement

```text
TM01M-moose-native-five-convoys-2
```

Ergänzt wird ausschließlich der kontrollierte Zielbereichs-Lebenszyklus:

```text
Ankunft vollständig erkannt
→ 60 Sekunden Abklingzeit
→ MOOSE GROUP:Destroy(false, 60)
→ keine Dead-/Crash-Ereignisse
→ Zielstraße wird wieder freigegeben
```

Die erfolgreiche Fünf-Konvoi-Routen- und Spawn-Baseline bleibt unverändert.
