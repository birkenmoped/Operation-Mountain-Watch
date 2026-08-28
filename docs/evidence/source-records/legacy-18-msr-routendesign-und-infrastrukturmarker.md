# 18 – MSR-Routendesign und Infrastrukturmarker

## Zweck dieses Dokuments

Dieses Dokument hält den bisherigen Entwurfsstand für Main Supply Routes (MSR), Routensegmente, MOOSE-PATHLINEs, Routenanker und Infrastrukturmarker fest.

Es dokumentiert ausdrücklich auch verworfene und widersprüchliche Zwischenstände. Diese sind relevant, weil aus ihnen die heute gültige Trennung zwischen Routengeometrie, Routinglogik und Infrastrukturmetadaten entstanden ist.

Der Stand ist eine Designgrundlage, noch keine abgeschlossene Implementierungsspezifikation.

---

## 1. Ausgangslage und Ziel

Operation Mountain Watch benötigt dynamisch nutzbare Bodenrouten für:

- Versorgungskonvois;
- Quick Reaction Forces;
- Patrouillen;
- virtuelle und physisch dargestellte Bodenbewegungen;
- Begleit-, Aufklärungs- und Route-Clearance-Aufträge;
- spätere Sperrungen, zerstörte Brücken, Hinterhalte und alternative Routen.

Die Mission soll nicht ausschließlich auf statischen Wegpunkten einzelner, im Mission Editor angelegter Gruppen beruhen. Routen müssen als wiederverwendbare Missionsdaten vorliegen und von MOOSE beziehungsweise projektspezifischen Lua-Modulen ausgewertet werden können.

Daraus ergeben sich drei getrennte Anforderungen:

1. **Wo soll die Route grundsätzlich verlaufen?**
2. **Welche Punkte muss die KI zwingend anfahren, damit DCS die gewünschte Straße benutzt?**
3. **Welche taktisch oder infrastrukturell relevanten Objekte liegen entlang der Route?**

Die zentrale Erkenntnis der bisherigen Diskussion ist, dass diese drei Aufgaben nicht durch dieselben Marker erfüllt werden sollten.

---

## 2. Aktuelle Routensegmentierung

### Strategische Ost-West- beziehungsweise Hauptverbindungen

- `MSR_EAST_E01`: Torkham → Jalalabad
- `MSR_EAST_E02`: Jalalabad → Kabul
- `MSR_EAST_E03`: Kabul → Bagram

### Regionale Verbindung

- `MSR_KUNAR_K01`: Jalalabad → Asadabad

### Historische MSR California

- `MSR_CAL_C01`: Asadabad → Asmar
- `MSR_CAL_C02`: Asmar → Naray / FOB Bostick

`MSR California` ist historisch belegt. `MSR EAST` und `MSR KUNAR` sind projektinterne Bezeichnungen.

Die Segmentierung ist erforderlich, weil einzelne Teilstrecken unabhängig voneinander befahren, gesperrt, bewertet oder als Bestandteil längerer Verbindungen kombiniert werden können.

---

## 3. Routenknoten und Segmentgrenzen

Die physischen Endpunkte der Segmente bilden einen Routengraphen:

```text
NODE_TORKHAM
    │ E01
    ▼
NODE_JALALABAD
    │ E02
    ▼
NODE_KABUL
    │ E03
    ▼
NODE_BAGRAM

NODE_JALALABAD
    │ K01
    ▼
NODE_ASADABAD
    │ C01
    ▼
NODE_ASMAR
    │ C02
    ▼
NODE_BOSTICK_GATE
```

Ein physischer Knoten kann mehrere Rollen besitzen:

| Physischer Knoten | Logische Rollen |
|---|---|
| Torkham | `E01_START` |
| Jalalabad | `E01_END`, `E02_START`, `K01_START` |
| Kabul | `E02_END`, `E03_START` |
| Bagram | `E03_END` |
| Asadabad | `K01_END`, `C01_START` |
| Asmar | `C01_END`, `C02_START` |
| Bostick Gate | `C02_END` |

Die Draw-Linien müssen an gemeinsamen Segmentgrenzen exakt dieselben Koordinaten verwenden. Kleine sichtbare oder rechnerische Lücken von wenigen Metern sind zu vermeiden, weil spätere Graph- und Zuordnungslogik sonst unnötig kompliziert wird.

### Warum nicht je Segment ein eigener sichtbarer Start- und Endmarker?

Zwei übereinanderliegende sichtbare Marker für denselben physischen Ort erzeugen im Mission Editor keinen Mehrwert. Ein gemeinsamer physischer `NODE_` ist ausreichend, sofern dessen mehrere Segmentrollen in den Daten beziehungsweise Kommentaren erfasst werden.

Das bedeutet jedoch nicht, dass ein Segment nur zusammen mit angrenzenden Segmenten gefahren werden kann. Jedes Segment besitzt durch seine PATHLINE weiterhin einen eigenen Anfang und ein eigenes Ende.

---

## 4. Mission-Editor-Draw-Linien als PATHLINE

Die im Mission Editor gezeichnete Linie ist die primäre geometrische Beschreibung eines Routensegments.

Beispiel:

```text
MSR_KUNAR_K01
```

MOOSE kann Mission-Editor-Draw-Linien als `PATHLINE` verwenden. Die Punkte einer PATHLINE besitzen bereits eine definierte Reihenfolge vom Start zum Ende.

### Aufgabe der Draw-Linie

Die Draw-Linie beschreibt:

- den beabsichtigten Routenkorridor;
- den Verlauf und die Fahrtrichtung des Segments;
- die Reihenfolge entlang der Strecke;
- die geometrische Referenz für Marker;
- die Grundlage für spätere Vereinfachung und Routenerzeugung.

### Was die Draw-Linie nicht automatisch garantiert

Sie ist nicht zwangsläufig:

- die direkt an die DCS-Gruppe zu übergebende Wegpunktliste;
- eine fehlerfrei fahrbare DCS-AI-Route;
- eine Garantie, dass `GetPathOnRoad()` an jeder Stelle die gewünschte Straße auswählt;
- eine Abbildung jeder taktischen oder infrastrukturellen Besonderheit.

Die bisher gezeichneten Linien besitzen teilweise mehrere hundert Punkte. Beispielsweise wurden in einem Zwischenstand folgende Größen ermittelt:

- `MSR_KUNAR_K01`: 367 Punkte;
- `MSR_CAL_C01`: 273 Punkte;
- `MSR_CAL_C02`: 238 Punkte.

Eine direkte Straßenpfadberechnung zwischen jedem benachbarten Draw-Punkt ist deshalb weder erforderlich noch sinnvoll. Die PATHLINE muss später vereinfacht beziehungsweise in wenige geeignete Routingabschnitte zerlegt werden.

---

## 5. Die zunächst vermischten Markerfunktionen

In der Diskussion wurden Infrastrukturmarker zunächst zugleich als sogenannte „Leuchttürme“ für die KI-Routenführung betrachtet.

Beispiele:

```text
BRG_K01_01
JCT_K01_01
FRD_K01_01
CHK_K01_01
```

Die angenommene Idee war:

> Der Konvoi fährt nacheinander Brücken, Kreuzungen, Furten und Engstellen an und bleibt dadurch auf der gewünschten Route.

Diese Betrachtung war unvollständig.

### Das Reihenfolgeproblem

Die Zähler laufen innerhalb unterschiedlicher Kategorien unabhängig voneinander:

```text
BRG_K01_01
BRG_K01_02
BRG_K01_03

JCT_K01_01
JCT_K01_02

FRD_K01_01
```

Aus diesen Namen lässt sich nicht ableiten, ob `FRD_K01_01` beispielsweise zwischen `BRG_K01_02` und `BRG_K01_03`, aber hinter `JCT_K01_02` liegt.

Die Namen kodieren:

- Objekttyp;
- Routensegment;
- laufende Nummer innerhalb dieses Objekttyps.

Sie kodieren **keine gemeinsame Fahrtfolge über alle Kategorien hinweg**.

Damit können diese Marker nicht ohne weitere Logik als vollständige geordnete Wegpunktliste dienen.

---

## 6. Aktuelle Trennung der Datenebenen

Der aktuelle Entwurfsstand trennt drei Ebenen.

### Ebene 1: Routengeometrie

```text
MSR_KUNAR_K01
```

Die PATHLINE definiert den vollständigen geordneten Korridor.

### Ebene 2: zwingende Routingpunkte

Vorgeschlagene Bezeichnung:

```text
RP_K01_001
RP_K01_002
RP_K01_003
```

Alternativ kann projektweit statt `RP_` weiterhin `CP_` verwendet werden, sofern die Bedeutung eindeutig als technischer Routingpunkt definiert wird. Die endgültige Präfixwahl ist noch festzulegen.

Diese Punkte sind die eigentlichen Routing-„Leuchttürme“. Sie werden nur dort gesetzt, wo die KI beziehungsweise die DCS-Straßensuche gezielt geführt werden muss, zum Beispiel:

- problematische Kreuzungen;
- parallele Straßen mit falscher Routenauswahl;
- zwingende Brücken oder Furten;
- Talwechsel;
- unzuverlässige DCS-Straßenverbindungen;
- Übergänge zwischen Teilkorridoren;
- bekannte Stellen, an denen eine direkt berechnete Route abweicht.

Ihre Nummerierung ist innerhalb des Segments typübergreifend und geordnet:

```text
RP_K01_001
RP_K01_002
RP_K01_003
```

### Ebene 3: Infrastruktur- und Taktikmerkmale

```text
BRG_K01_01
JCT_K01_01
FRD_K01_01
CHK_K01_01
GATE_K01_01
```

Diese Marker beschreiben reale oder missionsrelevante Eigenschaften entlang der Route. Sie sind nicht automatisch Wegpunkte.

Sie können später verwendet werden für:

- zerstörte oder gesperrte Brücken;
- Furt- und Wasserstandlogik;
- Route Clearance;
- Hinterhalte und IED-Szenarien;
- taktische Meldungen und Briefings;
- Watchguard-Sonderbehandlung;
- Gefahren- und Kostenbewertung;
- alternative Routenauswahl;
- Missionsziele und Zustandsänderungen.

Eine relevante Brücke kann zugleich einen Routingpunkt benötigen. Dann existieren zwei logische Datensätze an derselben oder nahezu derselben Koordinate:

```text
BRG_K01_03
RP_K01_007
```

Der eine beschreibt die Infrastruktur, der andere erzwingt die Routenführung.

---

## 7. Ermittlung der tatsächlichen Reihenfolge

Die gemeinsame Reihenfolge aller Infrastrukturmerkmale wird nicht aus deren typbezogenen Nummern abgeleitet.

Stattdessen werden Marker geometrisch auf die PATHLINE projiziert. Für jeden Marker wird seine Entfernung entlang der Linie vom Segmentstart bestimmt. Dieses Verfahren entspricht einer Kilometrierung beziehungsweise `chainage`.

Beispiel:

| Marker | Entfernung entlang K01 |
|---|---:|
| `JCT_K01_01` | km 2,4 |
| `BRG_K01_01` | km 4,8 |
| `BRG_K01_02` | km 7,1 |
| `JCT_K01_02` | km 8,3 |
| `FRD_K01_01` | km 9,0 |
| `BRG_K01_03` | km 10,6 |

Damit kann das Script die korrekte Reihenfolge unabhängig vom Markertyp bestimmen.

Die typbezogene Nummerierung bleibt für Identifikation und redaktionelle Ordnung sinnvoll, ist aber nicht die primäre Sortierlogik.

---

## 8. Benennungsschema

### Routensegmente

```text
MSR_EAST_E01
MSR_EAST_E02
MSR_EAST_E03
MSR_KUNAR_K01
MSR_CAL_C01
MSR_CAL_C02
```

Segmentnummern werden zweistellig geführt.

### Infrastrukturmarker

```text
BRG_E01_01
JCT_K01_01
FRD_C02_01
CHK_C01_01
GATE_C02_01
```

Schema:

```text
<TYP>_<SEGMENT>_<LAUFNUMMER>
```

Die laufende Nummer ist zweistellig und gilt innerhalb des Typs und Segments.

### Routingpunkte

Vorgeschlagen:

```text
RP_E01_001
RP_K01_001
RP_C02_001
```

Da Routingpunkte eine vollständige Reihenfolge darstellen, ist eine dreistellige Nummer sinnvoll. Sie bietet Platz für längere Segmente und vereinfacht spätere Reserven beziehungsweise Einfügungen.

### Physische Routenknoten

```text
NODE_TORKHAM
NODE_JALALABAD
NODE_KABUL
NODE_BAGRAM
NODE_ASADABAD
NODE_ASMAR
NODE_BOSTICK_GATE
```

Ortsbezogene Nodes sind keine typbezogen nummerierten Infrastrukturmarker.

---

## 9. Gemeinsame Infrastrukturpunkte mehrerer Routen

Eine reale Kreuzung, Brücke oder Furt kann auf mehreren Routensegmenten liegen.

Hier wurden zwei konkurrierende Modelle diskutiert.

### Modell A: ein physischer Marker mit mehreren Routenzuordnungen

Beispiel:

```text
JCT_JALALABAD_01
```

Metadaten:

```text
ROUTES: E02, K01
```

Vorteile:

- ein physisches Objekt wird nur einmal modelliert;
- keine übereinanderliegenden Marker;
- konzeptionell saubere Normalisierung.

Nachteile:

- die Routenzugehörigkeit ist nicht allein aus dem Namen ableitbar;
- zusätzliche Metadaten oder eine geometrische Zuordnung sind erforderlich;
- ein rein namensbasierter Parser reicht nicht aus.

### Modell B: je Route ein eigener logischer Marker

Beispiel:

```text
JCT_E02_01
JCT_K01_01
```

Beide können dieselbe reale Kreuzung und dieselbe Koordinate repräsentieren.

Vorteile:

- Routenzugehörigkeit ist unmittelbar aus dem Namen erkennbar;
- sehr einfache namensbasierte Filterung;
- unabhängige Nummerierung je Segment.

Nachteile:

- dasselbe physische Objekt wird doppelt modelliert;
- Statusänderungen müssten auf beide logischen Marker übertragen werden;
- überlagerte Marker erschweren die Editoransicht;
- eine Brücke könnte fälschlich als zwei unabhängige physische Brücken behandelt werden.

### Aktuelle Bewertung

Für reine Routingpunkte ist eine segmentbezogene Doppelung unproblematisch, weil sie logische Wegpunkte und keine physischen Objekte darstellen.

Für physische Infrastruktur ist ein einzelner physischer Datensatz langfristig robuster. Die Zugehörigkeit zu mehreren Segmenten sollte durch Metadaten oder durch geometrische Projektion auf die jeweiligen PATHLINEs bestimmt werden.

Solange die Implementierung ausschließlich namensbasiert arbeitet, kann eine routenspezifische Doppelung als Übergangslösung verwendet werden. Sie darf jedoch nicht mit zwei physischen Objekten verwechselt werden.

Diese Frage ist vor Implementierung des Infrastrukturregisters endgültig festzulegen.

---

## 10. Definition der Markertypen

### `NODE_`

Strategischer oder regionaler Routenknoten. Typischerweise Segmentanfang, Segmentende oder Verbindung mehrerer Segmente.

### `RP_`

Technischer Routingpunkt, den der Konvoi beziehungsweise die Routenerzeugung zwingend berücksichtigen soll.

### `CP_`

Ursprünglich als allgemeiner technischer Control Point diskutiert. Darf nicht gleichzeitig als taktischer Checkpoint verstanden werden. Falls `RP_` eingeführt wird, sollte `CP_` entweder entfallen oder sehr klar anders definiert werden.

### `JCT_`

Routing- oder missionsrelevante reale Straßenkreuzung. Nicht jede beliebige Straßenmündung wird markiert.

### `BRG_`

Relevante Brücke. Nicht jede kleine Brücke muss erfasst werden.

### `FRD_`

Furt oder nicht brückenbasierter Wasserübergang.

### `CHK_`

Chokepoint beziehungsweise Engstelle. Nicht mit `CP_` verwechseln.

### `GATE_`

Tor beziehungsweise Straßenanbindung einer FOB oder eines gesicherten Compounds.

### FOB- und Camp-Marker

FOB- und Camp-Marker markieren den Standort beziehungsweise Mittelpunkt der Basis. Das MSR-Segment endet dagegen am Gate oder an der Straßenanbindung, nicht im geometrischen Zentrum der Basis.

---

## 11. Kriterien für relevante Infrastrukturmarker

Nicht jedes sichtbare Objekt entlang einer Straße soll markiert werden.

### Brücken

Markieren, wenn mindestens eines der folgenden Kriterien zutrifft:

- keine sinnvolle Umfahrung;
- operative Bedeutung;
- möglicher Sperr- oder Zerstörungspunkt;
- geeigneter Hinterhaltspunkt;
- wichtiger Fluss- oder Talübergang;
- problematische AI-Routenführung;
- missionsrelevanter Kontrollpunkt.

### Junctions

Markieren, wenn:

- die Route an der Kreuzung eine relevante Richtungsentscheidung trifft;
- DCS möglicherweise den falschen Straßenarm wählt;
- mehrere geplante Routen oder Alternativen verbunden werden;
- die Kreuzung taktisch oder missionslogisch relevant ist.

Eine einfache Straßenkurve ist keine Junction.

### Furten und Chokepoints

Nur erfassen, wenn sie für Beweglichkeit, Risiko, Route Clearance, Sperrung oder Missionsdesign relevant sind.

---

## 12. Historische und geografische Erkenntnisse

### FOB Wright und Camp Fiaz

FOB Wright und Camp Fiaz sind getrennte Installationen.

Die historische Einordnung wurde unter anderem dadurch gestützt, dass:

- bei einem Mi-17-Absturz an FOB Fiaz Verletzte nach FOB Wright gebracht wurden;
- die Mission der Groberg-PSD an FOB Fiaz begann und zum Governor Compound führte.

Der Übergang beziehungsweise Routenknoten sollte daher nicht künstlich „in“ einer der beiden Basen liegen. Als funktionaler MSR-Knoten ist eine Straßenkreuzung beziehungsweise Straßenanbindung nahe FOB Wright geeigneter.

### FOB Bostick / Naray

Der OEF Base Tracker führt FOB Bostick unter `OBJECTID 188`.

Die DCS-Geometrie des Geländes und des Compounds passt überraschend gut zum realen Standort, obwohl generische Gebäude verwendet werden.

Für die Modellierung gilt:

- FOB-Marker am Standort beziehungsweise Compound-Zentrum;
- MSR-Ende am Gate oder Straßenanschluss;
- separater Node für `BOSTICK_GATE`;
- historischer Hinweis: formerly FOB Naray.

---

## 13. Bisherige Mission-Editor-Arbeiten

Im bisherigen Teststand wurden unter anderem folgende Änderungen durchgeführt:

- Ergänzung von FOB Bostick;
- Ergänzung von `MSR_CAL_C02`;
- Korrektur gemeinsamer Segmentendpunkte;
- Ergänzung der Nodes Asadabad, Asmar und Bostick Gate;
- Verkürzung von `MSR_KUNAR_K01` um die letzten 25 Draw-Punkte in einem Zwischenstand;
- Farb- und Linienstärkenkonzept für EAST, KUNAR und CALIFORNIA;
- erste Erfassung von Brücken, Kreuzungen und Furten;
- Korrektur einer K01-Brückennummerierung von `00–08` auf `01–09`.

Verwendetes Farbschema im überprüften Stand:

| Route | Farbe | Stärke |
|---|---|---:|
| MSR EAST | `0x0066ffff` | 14 |
| MSR KUNAR | `0x00d9ffff` | 12 |
| MSR CALIFORNIA | `0xffa000ff` | 12 |

Stil jeweils `solid2`.

Die visuelle Kontrolle im DCS Mission Editor bleibt nach jeder direkten Bearbeitung der `mission`-Datei erforderlich.

---

## 14. Verworfene oder korrigierte Überlegungen

### Irrtum 1: Infrastrukturmarker seien automatisch die vollständigen Wegpunkte

Diese Annahme scheitert an der fehlenden typübergreifenden Reihenfolge. `BRG_02`, `JCT_04` und `FRD_01` lassen sich allein aus ihren Namen nicht korrekt gegeneinander sortieren.

**Erkenntnis:** Infrastruktur und Routingpunkte müssen getrennt werden.

### Irrtum 2: Ein gemeinsamer Infrastrukturmarker sei immer ausreichend

Ein einzelner Marker ist physisch sauber, funktioniert aber nicht mit einem Parser, der die Routenzugehörigkeit ausschließlich aus einem Segmentcode im Namen ableitet.

**Erkenntnis:** Entweder zusätzliche Metadaten/geometrische Zuordnung verwenden oder vorübergehend je Segment einen logischen Marker führen.

### Irrtum 3: Zwei routenspezifische Marker seien grundsätzlich richtiger

Für rein logische Routingpunkte stimmt das. Für physische Infrastruktur entstehen dadurch jedoch Dubletten und Synchronisationsprobleme.

**Erkenntnis:** Zwischen physischem Objekt und logischer Routenreferenz unterscheiden.

### Irrtum 4: Die Nummerierung innerhalb der Infrastrukturtypen liefere die Fahrtfolge

Die Zähler wurden nach Auftreten innerhalb des jeweiligen Typs vergeben. Das ist für Identifikation geeignet, aber nicht für die gemeinsame Reihenfolge.

**Erkenntnis:** Die tatsächliche Reihenfolge wird aus der Position entlang der PATHLINE bestimmt.

### Irrtum 5: Die Draw-Linie sei entweder nur Dekoration oder direkt die komplette AI-Route

Beides ist zu extrem.

**Erkenntnis:** Die Draw-Linie ist die primäre geordnete Referenzgeometrie. Aus ihr werden vereinfachte und validierte Routingabschnitte erzeugt. Sie muss nicht unverändert als hunderte Wegpunkte umfassende Gruppenroute verwendet werden.

---

## 15. Vorgesehene Routingpipeline

Der derzeit bevorzugte Ablauf lautet:

1. Routensegment-PATHLINE aus dem Mission Editor laden.
2. Start, Ende und Punktreihenfolge validieren.
3. PATHLINE geometrisch vereinfachen.
4. explizite `RP_`-Marker als zwingende Anker ergänzen;
5. zwischen geeigneten Ankern DCS-/MOOSE-Straßenpfade berechnen;
6. Ergebnis gegen den gezeichneten Korridor plausibilisieren;
7. problematische Teilstücke durch zusätzliche Routingpunkte korrigieren;
8. finalen Wegpunktpfad an die Gruppe übergeben;
9. berechnete und getestete Pfade cachen beziehungsweise als freigegebene Routendaten speichern;
10. Infrastrukturmarker separat entlang der PATHLINE registrieren und kilometrieren.

Konzeptionell:

```text
Mission-Editor-PATHLINE
        ↓
Vereinfachung + zwingende RP-Anker
        ↓
GetPathOnRoad() je Teilabschnitt
        ↓
Korridor- und Plausibilitätsprüfung
        ↓
finale DCS-Gruppenroute
```

Die exakte verwendete MOOSE-API ist vor Implementierung gegen die im Projekt eingebundene MOOSE-Version zu validieren.

---

## 16. Beziehung zum Watchguard

Die Routendaten und Infrastrukturmarker können später vom Watchguard genutzt werden, sind aber nicht identisch mit dessen Recovery-Logik.

Mögliche Anwendungen:

- Erkennung, ob eine festgefahrene Gruppe nahe einer Brücke, Furt oder Junction steht;
- restriktivere Teleport- oder Repositionierungsregeln in sichtbarer, aufgeklärter oder bekämpfter Lage;
- Wiederaufnahme an einem gültigen Routingpunkt;
- Ausschluss gefährlicher Repositionierungen über Flüsse oder durch Hindernisse;
- Bewertung, ob ein alternativer Routenabschnitt verfügbar ist.

Der Watchguard muss sowohl für virtualisierte beziehungsweise „gepackte“ als auch für entpackte physische Gruppen funktionieren. Eine entpackte Gruppe darf insbesondere nicht unbemerkt teleportiert werden, wenn sie aufgeklärt, bekämpft oder in der Nähe von Spielern und Feinden ist.

Diese Anforderungen werden in der separaten Watchguard-Dokumentation detailliert behandelt.

---

## 17. Offene Designentscheidungen

Vor Implementierung sind folgende Punkte verbindlich zu entscheiden:

1. endgültiges Präfix für technische Routingpunkte: `RP_` oder `CP_`;
2. Datenmodell für physische Infrastruktur, die mehreren Routen angehört;
3. Ablage der Mehrfachzuordnung: Markerkommentar, Lua-Konfiguration oder automatische Geometrie;
4. Toleranzabstand für die Zuordnung eines Markers zu einer PATHLINE;
5. Algorithmus für die Kilometrierung entlang der PATHLINE;
6. Vereinfachungsverfahren und maximale Abstände zwischen Routingankern;
7. Korridorabweichung, ab der ein berechneter Straßenpfad verworfen wird;
8. Speicherung beziehungsweise Cacheformat validierter Routen;
9. Verhalten bei zerstörten Brücken und gesperrten Teilsegmenten;
10. Darstellung überlagerter technischer Marker im Mission Editor.

---

## 18. Vorläufig verbindliche Leitlinien

Bis zur nächsten Architekturentscheidung gelten folgende Regeln:

1. Jede MSR wird in unabhängig nutzbare Segmente zerlegt.
2. Jedes Segment besitzt genau eine geordnete Draw-Linie/PATHLINE.
3. Gemeinsame Segmentgrenzen verwenden exakt dieselbe Koordinate.
4. `NODE_` bezeichnet physische strategische Routenknoten.
5. `BRG_`, `JCT_`, `FRD_`, `CHK_` und `GATE_` sind Infrastruktur- beziehungsweise Taktikmetadaten.
6. Infrastrukturmarker sind nicht automatisch Wegpunkte.
7. Zwingende AI-Routinganker erhalten einen eigenen Markertyp.
8. Die Fahrtfolge der Infrastruktur wird geometrisch entlang der PATHLINE bestimmt.
9. Typbezogene Nummern dienen der Identifikation, nicht der vollständigen Fahrtfolge.
10. Physische Infrastruktur und logische Routenreferenzen dürfen nicht unbewusst gleichgesetzt werden.
11. Nicht jede Brücke oder Kreuzung wird markiert, sondern nur missions- oder routingrelevante Objekte.
12. Die PATHLINE ist weder bloße Dekoration noch ungeprüft die endgültige Gruppenroute; sie ist die primäre Referenzgeometrie für deren Erzeugung.

---

## 19. Nächste Arbeitsschritte

1. Präfix und Format der Routingpunkte endgültig festlegen.
2. Bestehende Marker in der Testmission nach Infrastruktur- und Routingfunktion klassifizieren.
3. Nur tatsächlich erforderliche Routinganker ergänzen.
4. Parser für Draw-Linien, Nodes und Marker entwerfen.
5. Projektion/Kilometrierung eines Markers auf eine PATHLINE prototypisch implementieren.
6. PATHLINE-Vereinfachung für ein einzelnes Segment testen.
7. Teilabschnittsweise `GetPathOnRoad()`-Berechnung gegen K01 oder C02 erproben.
8. Abweichungen zwischen berechnetem Straßenpfad und Draw-Korridor messen.
9. Testkonvoi mit validierter, vereinfachter Route fahren lassen.
10. Erkenntnisse in diesem Dokument und in `17-pathfinding-options.md` abgleichen.
