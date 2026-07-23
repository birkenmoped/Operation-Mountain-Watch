# 23 – Jalalabad: Parkplätze, Templates, Statics und MEDEVAC-Gruppenmodell

## Status

Dieses Dokument präzisiert und korrigiert die Parkplatz- und Template-Regeln aus älteren Jalalabad-Arbeitsständen.

Es ist für folgende Punkte verbindlich:

- Nutzung echter DCS-Parkpositionen,
- Platzierung sichtbarer Luftfahrzeug-Statics,
- Bedeutung der Late-Activation-Templatepositionen,
- Runtime-Parkplatzreserve für MOOSE-AIRWING,
- Aufbau des MEDEVAC-Two-Ship-Pakets.

## 1. Drei unterschiedliche Platzierungsarten

### 1.1 Spielerplätze

Spielergruppen benötigen echte, für den jeweiligen Typ geeignete DCS-Parkpositionen.

Diese Positionen gelten im Runtime-Parkmodell als reserviert und dürfen nicht gleichzeitig durch Statics oder dynamische KI-Spawns belegt werden.

Jalalabad-Kernstand:

```text
6 reservierte Spielerpositionen

2 OH-58D
2 AH-64D
2 CH-47
```

Optional kommen zwei UH-60L-Spielerpositionen hinzu.

### 1.2 Dynamische KI-Parkplätze

MOOSE-AIRWING spawnt die tatsächlichen Einsatzgruppen dynamisch am zugeordneten Flugplatz.

Dafür werden mindestens vier freie, funktionale Runtime-Parkpositionen reserviert:

```text
2 CH-47-taugliche Positionen
2 kleine oder mittlere Hubschrauberpositionen
```

Diese vier Positionen entsprechen der globalen Obergrenze von maximal vier gleichzeitig aktiven KI-Unterstützungsluftfahrzeugen.

Sie dürfen nicht durch Statics blockiert werden.

### 1.3 Sichtbare Statics

Sichtbare Luftfahrzeug-Statics sollen grundsätzlich **nicht auf den Mittelpunkten funktionaler DCS-Parkpositionen** stehen.

Bevorzugt werden:

- frei nutzbare Apronflächen zwischen oder neben den DCS-Parkknoten,
- optisch plausible Abstellflächen ohne funktionalen Parking-Node,
- Randflächen der historischen Ramp,
- Wartungs-, Dispersal- oder Shelterbereiche.

Ein Static darf ausnahmsweise auf einer echten DCS-Parkposition stehen, wenn diese Position bewusst dauerhaft aus dem operativen Pool entfernt wird.

Dann gilt:

```text
Static auf funktionaler Parking-Position
= Parking-Position für Spieler, KI-Spawn und Rückkehr gesperrt
```

## 2. Korrektur der früheren 36-Positionen-Rechnung

Die frühere Rechnung

```text
20 Statics + 13 Operationspositionen = 33 von 36
```

war zu konservativ und konzeptionell falsch, weil sie frei platzierte Statics wie funktionale DCS-Parkpositionen behandelte.

Korrektes Runtime-Modell:

```text
6 Kern-Spielerpositionen
4 dynamische KI-Reservepositionen
--------------------------------
10 Runtime-Positionen im Kernstand

+ 2 optionale UH-60L-Spielerpositionen
= 12 Runtime-Positionen mit Mod
```

Die sieben im Mission Editor sichtbaren Template-Luftfahrzeuge werden nicht als sieben Runtime-Parkplätze gezählt.

## 3. Bedeutung der Late-Activation-Templates

Die fünf KI-Templategruppen enthalten zusammen sieben Luftfahrzeuge:

```text
2 OH-58D
2 AH-64D
1 UH-60A MEDEVAC Lead
1 UH-60A MEDEVAC Cover
1 CH-47
```

Diese Gruppen dienen MOOSE ausschließlich als Vorlage für:

- Luftfahrzeugtyp,
- Gruppengröße,
- Livery,
- Payload,
- Skill,
- Formation,
- Startart und weitere DCS-Gruppeneigenschaften.

Sie werden wegen `Late Activation` nicht als operative Gruppen aktiviert.

### 3.1 Müssen Templates auf einem echten Parkplatz stehen?

Für die robuste Missionsdatei sollen sie:

- am richtigen Flugplatz Jalalabad,
- mit gültigem `Takeoff from parking cold`,
- auf einer für den Typ geeigneten DCS-Parkposition

angelegt werden.

Das stellt eine korrekte Airbase-, Startart- und Routenvorlage sicher.

### 3.2 Müssen diese Template-Parkplätze dauerhaft frei bleiben?

Nein.

Die Templateposition ist eine Authoring-/Seedposition, nicht der verbindliche spätere Spawnplatz des AIRWING-Assets.

Der tatsächliche Einsatzspawn wird durch AIRWING, Airbase und die zur Laufzeit freien Parkpositionen bestimmt.

Trotzdem dürfen Templategruppen im Mission Editor nicht fehlerhaft außerhalb des Flugplatzes, auf ungeeigneten Typenpositionen oder mit Start in der Luft angelegt werden, weil diese Eigenschaften Teil der Vorlage werden können.

## 4. G01-G07 und C01-C14

Die Bezeichnungen beschreiben primär historische beziehungsweise visuelle Rampbereiche.

Sie bedeuten nicht, dass jeder sichtbare Static exakt auf einem funktionalen DCS-Parking-Node stehen muss.

### G01-G07

- visueller OH-58D-Bereich,
- Statics möglichst frei zwischen oder neben funktionalen Parking-Nodes platzieren,
- mindestens notwendige Spieler-/KI-Spots freihalten.

### C01-C14

- visueller CH-47-Heavy-Lift-Bereich,
- zwei CH-47-Spielerplätze reservieren,
- mindestens zwei weitere CH-47-taugliche Runtime-Spots für dynamische KI freihalten,
- CH-47-Statics auf den verbleibenden Apronflächen frei platzieren.

## 5. Warum MEDEVAC aus zwei Single-Ship-Gruppen besteht

`Two-Ship-Paket` bezeichnet die operative Einheit aus zwei Luftfahrzeugen, nicht zwingend eine einzige DCS-Gruppe mit zwei Units.

Gewünschtes Verhalten:

```text
Lead:
- landet an der Aufnahmezone,
- übernimmt Verwundete oder Personal,
- fliegt anschließend zur Übergabezone.

Cover:
- bleibt unabhängig steuerbar,
- hält Orbit oder Sicherungsposition,
- übernimmt Escort-/Ground-Escort-Aufgabe,
- landet nicht zwingend zusammen mit dem Lead.
```

Eine DCS-Gruppe mit zwei Units teilt grundsätzlich die Gruppenroute und den Gruppenauftrag. Das erschwert beziehungsweise verhindert die gewünschte Trennung in:

```text
Luftfahrzeug 1 landet
Luftfahrzeug 2 bleibt gleichzeitig im Sicherungsorbit
```

Deshalb werden verwendet:

```text
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
```

Beide Gruppen stammen aus demselben logischen UH-60-SQUADRON-Bestand.

Sie werden später durch den MEDEVAC-Koordinator gemeinsam reserviert und als **ein logisches Paket** gestartet:

```text
1 Lead-Single-Ship-Gruppe
+
1 Cover-Single-Ship-Gruppe
=
1 MEDEVAC-Two-Ship-Paket
```

Es handelt sich nicht um zwei unabhängige MEDEVAC-Missionen und nicht um zwei getrennte Bestände.

## 6. Aktueller Implementierungsstand

Im aktuellen Testbundle ist bereits festgeschrieben:

```text
DCSGroupModel = TWO_INDEPENDENT_SINGLE_SHIP_GROUPS
CoordinationModel = ONE_LOGICAL_MEDEVAC_PACKAGE
```

Der abschließende Missionskoordinator, der Lead und Cover atomar reserviert, gemeinsam startet und gemeinsam freigibt, ist ein eigener nachfolgender Laufzeittest.

Die bisherige SQUADRON-Konstruktion und die beiden Payloadvorlagen allein beweisen noch nicht, dass die vollständige 1+1-Koordination im Einsatz bereits funktioniert.

## 7. Verbindliche Platzierungsregel

```text
Spieler:
auf echten, reservierten DCS-Parkpositionen

Dynamische KI:
mindestens vier echte freie Runtime-Parkpositionen reservieren

Templates:
auf gültigen typgerechten Jalalabad-Parkpositionen anlegen,
aber nicht als dauerhaft belegte Runtime-Parkplätze zählen

Statics:
bevorzugt frei auf Apronflächen,
nicht auf funktionalen Parking-Nodes
```
