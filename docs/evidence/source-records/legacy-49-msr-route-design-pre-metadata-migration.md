---
document_id: OMW-MSR-ROUTE-DESIGN
status: PLANNED
authoritative_for:
  - MSR route segmentation
  - route geometry and routing-point separation
  - infrastructure marker classification
  - MSR design worklist
supersedes_legacy_title: "18 – MSR-Routendesign und Infrastrukturmarker"
source_record: docs/evidence/source-records/legacy-18-msr-routendesign-und-infrastrukturmarker.md
validated_in_dcs: false
---

# 49 – MSR-Routendesign und Infrastrukturmarker

## Zweck und Einordnung

Dieses Dokument ist die aktuelle, eindeutig nummerierte Projektreferenz für Main Supply Routes, Routensegmente, MOOSE-`PATHLINE`s, Routinganker und Infrastrukturmarker.

Der vollständige frühere Entwurfsstand bleibt unverändert als Evidenz- und Entwicklungsprotokoll erhalten:

- [`Legacy-Entwurfsstand: früheres Dokument 18`](evidence/source-records/legacy-18-msr-routendesign-und-infrastrukturmarker.md)

Die frühere Nummer `18` gehört ausschließlich zu `OMW-AIR-IMPLEMENTATION – docs/18-air-operations-implementation.md`. Der Titel im unveränderten Legacy-Datensatz ist nur historischer Quellenbestand und keine aktive Dokumentnummer.

## 1. Geltungsbereich

Operation Mountain Watch benötigt wiederverwendbare Bodenrouten für:

- Versorgungskonvois;
- Quick Reaction Forces;
- Patrouillen;
- virtuelle und physisch dargestellte Bodenbewegungen;
- Begleit-, Aufklärungs- und Route-Clearance-Aufträge;
- spätere Sperrungen, zerstörte Brücken, Hinterhalte und alternative Routen.

Die Route wird nicht als unstrukturierte Menge einzelner Missionseditor-Wegpunkte behandelt. Sie wird in getrennte Datenebenen zerlegt.

## 2. Verbindliche Datenebenen

### 2.1 Routengeometrie

Jedes MSR-Segment besitzt genau eine geordnete Mission-Editor-Draw-Linie beziehungsweise MOOSE-`PATHLINE`.

Beispiele:

```text
MSR_EAST_E01
MSR_EAST_E02
MSR_EAST_E03
MSR_KUNAR_K01
MSR_CAL_C01
MSR_CAL_C02
```

Die PATHLINE beschreibt den beabsichtigten Korridor, die Punktreihenfolge und die geometrische Referenz. Sie ist weder bloße Dekoration noch ungeprüft die endgültige DCS-Gruppenroute.

### 2.2 Technische Routingpunkte

Zwingende Routinganker erhalten einen eigenen, typübergreifend geordneten Markertyp:

```text
RP_K01_001
RP_K01_002
RP_K01_003
```

Sie werden nur dort gesetzt, wo DCS beziehungsweise die Straßensuche gezielt geführt werden muss, beispielsweise an problematischen Kreuzungen, parallelen Straßen, zwingenden Brücken, Furten oder Talwechseln.

### 2.3 Infrastruktur- und Taktikmarker

Physische oder missionsrelevante Merkmale werden getrennt erfasst:

```text
BRG_  Brücke
JCT_  relevante Straßenkreuzung
FRD_  Furt oder Wasserübergang
CHK_  Chokepoint oder Engstelle
GATE_ Tor beziehungsweise Straßenanbindung einer Basis
NODE_ strategischer oder regionaler Routenknoten
```

Diese Marker sind nicht automatisch Wegpunkte.

## 3. Aktuelle Routensegmentierung

### Hauptverbindungen

- `MSR_EAST_E01`: Torkham → Jalalabad
- `MSR_EAST_E02`: Jalalabad → Kabul
- `MSR_EAST_E03`: Kabul → Bagram
- `MSR_KUNAR_K01`: Jalalabad → Asadabad

### Historische MSR California

- `MSR_CAL_C01`: Asadabad → Asmar
- `MSR_CAL_C02`: Asmar → Naray / FOB Bostick

`MSR California` ist historisch belegt. `MSR EAST` und `MSR KUNAR` sind projektinterne Bezeichnungen.

## 4. Routenknoten

Gemeinsame Segmentgrenzen verwenden exakt dieselbe Koordinate.

```text
NODE_TORKHAM
NODE_JALALABAD
NODE_KABUL
NODE_BAGRAM
NODE_ASADABAD
NODE_ASMAR
NODE_BOSTICK_GATE
```

Ein physischer Knoten kann mehrere logische Segmentrollen besitzen. Er wird dennoch nur einmal als physischer Ort modelliert.

## 5. Reihenfolge und Kilometrierung

Die gemeinsame Reihenfolge verschiedener Infrastrukturtypen wird nicht aus deren typbezogenen Nummern abgeleitet. Marker werden geometrisch auf die PATHLINE projiziert und anhand ihrer Entfernung vom Segmentstart sortiert.

Die typbezogene Nummerierung dient der Identifikation. Die tatsächliche Fahrtfolge ergibt sich aus der Position entlang der Route.

## 6. Vorgesehene Routingpipeline

1. Routensegment-PATHLINE aus dem Mission Editor laden.
2. Start, Ende und Punktreihenfolge validieren.
3. PATHLINE geometrisch vereinfachen.
4. explizite `RP_`-Marker als zwingende Anker ergänzen.
5. zwischen geeigneten Ankern DCS-/MOOSE-Straßenpfade berechnen.
6. Ergebnis gegen den gezeichneten Korridor plausibilisieren.
7. problematische Teilstücke durch zusätzliche Routingpunkte korrigieren.
8. finalen Wegpunktpfad an die Gruppe übergeben.
9. getestete Pfade cachen oder als freigegebene Routendaten speichern.
10. Infrastrukturmarker separat registrieren und kilometrieren.

Die konkrete MOOSE-API ist vor Implementierung gegen die eingebundene MOOSE-Version zu prüfen. Die MOOSE-First-Richtlinie `OMW-GOV-MOOSE-FIRST` gilt uneingeschränkt.

## 7. Beziehung zum Watchguard

Routendaten und Infrastrukturmarker können den Watchguard unterstützen, ersetzen aber nicht dessen Recovery-Logik.

Insbesondere gilt:

- gepackte und entpackte Gruppen müssen überwacht werden;
- beobachtete, aufgeklärte oder bekämpfte Gruppen dürfen nicht unbemerkt teleportiert werden;
- Brücken, Furten, Junctions und gültige Routingpunkte können Recovery-Entscheidungen begrenzen;
- Repositionierungen über Flüsse oder durch Hindernisse sind zu verhindern.

## 8. Noch offene Entscheidungen

Vor einer produktiven Implementierung sind insbesondere festzulegen:

1. endgültiges Präfix `RP_` oder alternativ klar abgegrenztes `CP_`;
2. Datenmodell für physische Infrastruktur mit mehreren Routenzuordnungen;
3. Ablage dieser Mehrfachzuordnung;
4. Toleranzabstand zur PATHLINE;
5. Algorithmus für Projektion und Kilometrierung;
6. Vereinfachungsverfahren und maximale Ankerabstände;
7. zulässige Korridorabweichung berechneter Straßenpfade;
8. Cacheformat freigegebener Routen;
9. Verhalten bei zerstörten Brücken und gesperrten Segmenten;
10. Darstellung überlagerter technischer Marker im Mission Editor.

## 9. Vorläufig verbindliche Leitlinien

1. Jede MSR wird in unabhängig nutzbare Segmente zerlegt.
2. Jedes Segment besitzt genau eine geordnete Draw-Linie beziehungsweise PATHLINE.
3. Gemeinsame Segmentgrenzen verwenden exakt dieselbe Koordinate.
4. `NODE_` bezeichnet physische strategische Routenknoten.
5. Infrastrukturmarker und technische Routinganker bleiben getrennt.
6. Infrastrukturmarker sind nicht automatisch Wegpunkte.
7. Die Fahrtfolge wird geometrisch entlang der PATHLINE bestimmt.
8. Typbezogene Nummern dienen der Identifikation, nicht der vollständigen Fahrtfolge.
9. Physische Infrastruktur und logische Routenreferenzen werden nicht gleichgesetzt.
10. Nur missions- oder routingrelevante Objekte werden markiert.
11. Die PATHLINE ist die primäre Referenzgeometrie für die spätere Routenerzeugung.
12. Produktive Eigenlogik bleibt von MOOSE-First und ausdrücklicher Ausnahmefreigabe abhängig.

## 10. Nächste Arbeitsschritte

1. Routingpunkt-Präfix verbindlich entscheiden.
2. vorhandene Marker nach Infrastruktur- und Routingfunktion klassifizieren.
3. nur tatsächlich notwendige Routinganker ergänzen.
4. Parser für PATHLINEs, Nodes und Marker entwerfen.
5. Projektion und Kilometrierung prototypisch testen.
6. PATHLINE-Vereinfachung an einem Segment testen.
7. abschnittsweise `GetPathOnRoad()`-Berechnung gegen K01 oder C02 erproben.
8. Abweichungen zum Draw-Korridor messen.
9. Testkonvoi mit validierter Route fahren lassen.
10. Ergebnisse mit [`OMW Pathfinding-Optionen`](17-pathfinding-options.md) abgleichen.
