# Jalalabad – Hubschrauberformationen und AH-64D-Loadout-Baseline

## Status

Dieses Dokument übernimmt die projektweite Baseline aus:

```text
docs/27-helicopter-formations-and-ah64-afghanistan-configuration.md
```

und konkretisiert sie für den Jalalabad-/FOB-Fenty-Air-Ops-Knoten.

Die bestehende Abschlussbewertung `OPERATIONAL / ACCEPTED` bleibt unverändert. Der bisherige Abschlusslauf validierte den strukturellen Grundknoten, nicht das taktische Flugverhalten einer gestarteten Mission.

## 1. Betroffene SQUADRONs

```text
SQ_US_JBAD_OH58D_6_6_CAV
SQ_US_JBAD_AH64D_B_1_10_AVN
SQ_US_JBAD_UH60_UTILITY_MEDEVAC
SQ_US_JBAD_CH47_HEAVYLIFT
```

## 2. Verbindliche Formationsbaseline

### OH-58D und AH-64D

```text
Regelfall:             Combat Cruise
Alternative:           Combat Cruise Left/Right
Enge Täler/Korridore:  Combat Trail
Offene Gefahrenräume:  Combat Spread
Vee:                   kein allgemeiner taktischer Standard
```

Two-Ship-Assets sollen nicht allein aus optischen Gründen in einer starren Vee fliegen. Formation und Abstand müssen je Missionsphase, Gelände und Bedrohung gewählt werden.

### UH-60 und CH-47

```text
Transit:               Combat Cruise oder gestaffelte Formation
Enge Täler/LZ-Zugang:  Combat Trail
Offene Querung:        Combat Spread möglich
LZ-Anflug:             Trail, Echelon, Spread oder Vee nach LZ-Plan
```

Vee ist nur eine mögliche Anflug- beziehungsweise Landeformation und keine projektweite Marschformation.

### MEDEVAC

```text
1 Lead-Single-Ship
+
1 Cover-Single-Ship
=
1 logisches MEDEVAC-Paket
```

Lead und Cover erfüllen unterschiedliche Rollen. Eine symmetrische Vee zwischen Lead und Cover ist nicht vorgeschrieben. Der Cover-Hubschrauber muss eine geeignete Sicherungsposition einnehmen, während der Lead den Landeplatz anfliegt.

## 3. Verbindliche AH-64D-Konfigurationsbaseline

Für `SQ_US_JBAD_AH64D_B_1_10_AVN` gilt als Standard:

```text
DCS-Typ:               AH-64D_BLK_II
Paketgröße:            Two-Ship
FCR:                   nicht auf jeder Maschine; standardmäßig non-FCR bevorzugt
IAFS / Robbie Tank:    installiert
30-mm-Munition:        300 Schuss
```

### Zulässige Abweichungen

FCR-ausgerüstete Einzelmaschinen oder Pakete bleiben zulässig, wenn der Auftrag dies begründet, beispielsweise durch:

- besonders eingeschränkte Sicht,
- spezielle Zielsuche,
- einen ausdrücklich geplanten FCR-/non-FCR-Teamansatz,
- einen später belegten einheitsspezifischen Konfigurationsnachweis.

Eine Konfiguration ohne IAFS und mit höherer 30-mm-Munitionsmenge bleibt für kurze, feuerkraftintensive Einsätze oder FARP-nahe Sondermissionen zulässig.

Jede Abweichung von der Standardbaseline muss im Template-, Missions- oder Testergebnis dokumentiert werden.

## 4. DCS-/MOOSE-Umsetzungsregel

Vor eigener Logik für Formation, Abstand oder Positionswechsel sind die vorhandenen Möglichkeiten der tatsächlich eingebundenen MOOSE-Version zu prüfen.

Verbindlicher Ablauf:

1. passende MOOSE-Klassen und Methoden prüfen,
2. MOOSE-Quellcode und Demo-/Testmissionen prüfen,
3. DCS-AI-Verhalten praktisch validieren,
4. erst danach eine begründete projektspezifische Ergänzung entwickeln.

Wo DCS oder das verwendete AI-Asset FCR, IAFS, Munitionsmenge oder Formation nicht getrennt abbilden kann, ist die nächstliegende Darstellung zu verwenden. Die Einschränkung muss im Ergebnisbericht ausdrücklich genannt werden.

## 5. Anforderungen an künftige taktische Jalalabad-Tests

Künftige Tests für `AUFTRAG`, Escort, Armed Reconnaissance, CAS, OPSTRANSPORT oder MEDEVAC müssen mindestens protokollieren:

```text
- eingesetzte SQUADRON und Templategruppe
- Paketgröße
- Formation beim Abflug
- Formation im Transit
- Formation im Ziel- oder LZ-Bereich
- Formation beim Rückflug
- FCR-Darstellung je AH-64D
- IAFS-/30-mm-Konfiguration
- beobachtete DCS-AI-Abweichungen
- verwendete MOOSE-Klassen und Methoden
```

### Mindestakzeptanz

- keine starre Vee als pauschale Standardformation für den gesamten Auftrag,
- Combat Cruise beziehungsweise eine begründete taktische Alternative im Transit,
- keine unbegründete vollständige FCR-Ausstattung aller AH-64D,
- IAFS + 300 Schuss als AH-64D-Standard, sofern das Asset dies abbildet,
- jede technisch erzwungene Abweichung dokumentiert,
- keine eigene Formationssteuerung ohne vorherige MOOSE-First-Prüfung.

## 6. Keine Änderung des bereits akzeptierten Grundknotens

Diese Baseline verändert nicht:

- den logischen Bestand `24 / 8 / 8 / 8`,
- die Zahl der Client- oder KI-Templates,
- Parking-Reservierungen und Blacklists,
- Warehouse-, AIRWING- oder COMMANDER-Struktur,
- den Status der vorhandenen Abschlussvalidierung.

Sie wird erst bei der taktischen Missions- und AUFTRAG-Ausführung zum zusätzlichen Prüfmaßstab.
