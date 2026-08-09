---
document_id: OMW-EVIDENCE-AFGHAN-WAR-DIARY-ROUTE-STAGE6-2026-07-31
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - provenance, method and limits of the stage-six spatial validation of selected War Diary routes
  - evidence-cluster and corridor-hypothesis status for Oregon, Honda, Volkswagen, Fosters, Cowboys, Violet, Torch, Lithium and Horseshoe
not_authoritative_for:
  - exact historical road centerlines
  - direct creation of DCS PATHLINE geometry
  - proof that every reported coordinate lies on the named route
  - scenario-period name continuity into 2010/2011
  - DCS runtime route acceptance
scenario_period: 2010-08-01/2011-12-31
source_period: 2004-01-01/2009-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: main
source_commit: c171c2dbee3d5e9038897513ff727443bf70d78c
validated_in_dcs: false
---

# Afghan War Diary – räumliche Routenvalidierung Stufe 6

## 1. Zweck

Diese Akte dokumentiert die räumliche Prüfung der priorisierten Routen:

```text
OREGON
HONDA
VOLKSWAGEN
FOSTERS
COWBOYS
VIOLET
TORCH
LITHIUM
HORSESHOE
```

Die Auswertung basiert ausschließlich auf den zuvor kuratierten War-Diary-Routenerwähnungen sowie dem separaten Horseshoe-Befund aus Stufe 3. Sie erzeugt keine historische Straßenmittellinie.

## 2. Verfahren

Verwendet wurden formal plausible Koordinaten innerhalb eines Afghanistan-Bounding-Box-Filters.

Räumliche Gruppierung:

```text
lokale Routen: 20 km DBSCAN-Nachbarschaft
lange Korridore Oregon, Honda, Volkswagen: 35 km DBSCAN-Nachbarschaft
Mindestpunktzahl: 2
Distanzmetrik: Haversine
```

Für jeden Cluster wurde zusätzlich eine PCA-Hauptachse berechnet. Diese Achse beschreibt nur die Orientierung der Punktwolke.

Verbindliche Bezeichnung:

```text
EVIDENCE_AXIS_ONLY
```

Eine solche Achse ist ausdrücklich:

- keine Straße;
- keine MSR-Mittellinie;
- keine DCS-PATHLINE;
- kein Beweis für durchgehende Befahrbarkeit.

Nicht zuordenbare Punkte bleiben als `NOISE` beziehungsweise `OUTLIER_OR_SEPARATE_USAGE` erhalten und werden nicht gelöscht.

## 3. Ergebnisübersicht

| Route | koordinierte Punkte | Cluster | Ausreißer | Anteil Hauptcluster | Bewertung |
|---|---:|---:|---:|---:|---|
| Cowboys | 108 | 2 | 0 | 97,2 % | dominanter Hauptsektor plus kleiner Nebencluster |
| Fosters | 171 | 2 | 2 | 97,7 % | dominanter Panjwayi-Sektor plus Neben-/Ausreißerbelege |
| Honda | 304 | 3 | 1 | 94,1 % | mehrere Nutzungsräume; keine automatische Ein-Routen-Annahme |
| Horseshoe | 1 | 0 | 1 | 0 % | einzelner Lageanker, keine Punktwolke |
| Lithium | 35 | 1 | 3 | 91,4 % | ein dominanter RC-West-Sektor |
| Oregon | 29 | 1 | 1 | 96,6 % | ein dominanter RC-South-Sektor |
| Torch | 78 | 1 | 0 | 100 % | kompakter Salerno-/Khost-Sektor |
| Violet | 79 | 2 | 1 | 89,9 % | Hauptcluster Kabul/RC Capital plus Nebencluster |
| Volkswagen | 87 | 1 | 1 | 98,9 % | kompakter Bermel-/östlicher Paktika-Sektor |

Die Anzahl der Punkte zählt Routenerwähnungen, nicht notwendigerweise unabhängige Vorfälle.

## 4. Quellenbasierte Korridorinterpretationen

### 4.1 Oregon

Quellenbasierter Korridor:

```text
Kandahar Airfield → Tarin Kowt
```

Bewertung:

```text
Korridorendpunkte: HIGH
historischer MSR-Name: HIGH durch separate niederländische Quelle
War-Diary-Namensbeleg: Route/RTE Oregon mehrfach
exakte Geometrie: LOW / UNVALIDATED
```

Die War-Diary-Punktwolke bildet einen dominanten RC-South-Sektor. Sie darf nicht durch einfaches Verbinden der Punkte in eine Straße umgewandelt werden.

### 4.2 Honda

Quellenbasierter Hauptkorridor:

```text
FOB Orgun-E → Zerok-Sektor
```

Bewertung:

```text
Korridorhypothese: MEDIUM-HIGH
MSR-Namensbeleg: mindestens eine explizite MSR-Honda-Nennung
Mehrfachnutzungsrisiko: HIGH
```

Die drei Cluster und der zusätzliche Pech-River-Road-Bezug zeigen, dass `Honda` nicht ohne weitere Prüfung als eine einzige durchgehende Route behandelt werden darf.

### 4.3 Volkswagen

Quellenbasierter Korridor:

```text
Zerok-/Orgun-E-Sektor → Bermel
```

Bewertung:

```text
Korridorhypothese: MEDIUM-HIGH
Terminologie: Route/RTE, kein gesicherter MSR-Beleg
exakter Anschluss Honda ↔ Volkswagen: UNKNOWN
```

Der dominante Cluster liegt im Bermel-/östlichen Paktika-Sektor.

### 4.4 Fosters

Quellenbasierter Sektor:

```text
Panjwayi / Masum Ghar / Sperwan Ghar
```

Bewertung:

```text
Sektorkorridor: MEDIUM
Terminologie: Route/RTE
Bedrohungsmuster: starke IED-/EOD-Konzentration
Endpunkte: UNRESOLVED
```

### 4.5 Cowboys

Quellenbasierter Sektor:

```text
Hassan Abad / Koshtay–Kostay
```

Bewertung:

```text
Sektorkorridor: MEDIUM
Terminologie: Route/RTE
Bedrohungsmuster: IED, Druckplatte, EOD
Endpunkte: UNRESOLVED
```

### 4.6 Violet

Quellenbasierter Sektor:

```text
Kabul / Checkpoint V
```

Bewertung:

```text
lokaler Routenkorridor: MEDIUM
Terminologie: Route/RTE
strategischer MSR-Status: UNCONFIRMED
```

Der Nebencluster ist getrennt zu prüfen und darf nicht automatisch in denselben Straßenverlauf integriert werden.

### 4.7 Torch

Quellenbasierter Sektor:

```text
FOB Salerno / Khost
```

Bewertung:

```text
lokaler Routenkorridor: MEDIUM-HIGH
Terminologie: Route/RTE
Bedrohungsmuster: Culvert-IED, Mine, EOD
```

Die Punktwolke bildet einen einzigen kompakten Cluster. Das verbessert die Sektorsicherheit, nicht automatisch die Straßenmittellinie.

### 4.8 Lithium

Quellenbasierter Sektor:

```text
Qala-e-Naw / PRT QEN / Sang Tesh
```

Bewertung:

```text
regionaler Routenkorridor: MEDIUM
Terminologie: Route/RTE
exakte Endpunkte: UNRESOLVED
```

### 4.9 Horseshoe

Quellenbeleg:

```text
Old Kabul Road (MSR Horseshoe)
ungefähr 25 km nordwestlich von Camp Phoenix
```

Bewertung:

```text
Namensbeleg: HIGH
Lageanker: MEDIUM
vollständiger Korridor: LOW
Gleichsetzung mit EAST-E3: NOT PROVEN
```

Ein einzelner Punkt genügt nicht zur Rekonstruktion der gesamten Old Kabul Road oder einer Kabul–Bagram-Verbindung.

## 5. Verbindliche Geometriestufen

Für die weitere OMW-Arbeit gelten:

```text
SOURCE_POINT
= Koordinate aus einem War-Diary-Bericht

EVIDENCE_CLUSTER
= räumliche Konzentration mehrerer Source Points

EVIDENCE_AXIS_ONLY
= statistische Hauptorientierung eines Clusters

CORRIDOR_HYPOTHESIS
= quellen- und ortsgestützte Annahme über einen Verbindungsraum

CARTOGRAPHICALLY_VALIDATED
= gegen reale Straße, Gelände und Endpunkte geprüft

DCS_VALIDATED
= im Missionseditor beziehungsweise Testlauf technisch geprüft
```

Ein Status darf nicht übersprungen werden.

## 6. Nicht zulässige Ableitungen

Aus Stufe 6 darf nicht automatisch abgeleitet werden:

- dass alle Punkte auf der Straße liegen;
- dass die PCA-Achse der Straße folgt;
- dass ein Cluster die vollständige Route abdeckt;
- dass zwei nahe Cluster durch denselben Straßenzug verbunden sind;
- dass Route/RTE-Namen automatisch MSR-Namen sind;
- dass Namen aus 2004–2009 unverändert für 2010/2011 galten;
- dass ein kartografischer Korridor in DCS befahrbar ist.

## 7. Arbeitsartefakte

```text
afg_war_diary_route_stage6_spatial_validation.xlsx
afg_war_diary_route_stage6_spatial_route_summary.csv
afg_war_diary_route_stage6_spatial_clusters.csv
afg_war_diary_route_stage6_classified_points.csv
afg_war_diary_route_stage6_corridor_interpretations.csv
afg_war_diary_route_stage6_points.geojson
afg_war_diary_route_stage6_evidence_axes.geojson
```

Das GeoJSON `evidence_axes` darf nur als Analyseoverlay verwendet werden. Es ist keine PATHLINE-Quelle.

## 8. Nächste Stufe

Nächste fachliche Aufgabe ist die tatsächliche kartografische Validierung gegen:

1. bekannte FOB-/COP-Lagen;
2. reale Straßen und Pässe;
3. Flussquerungen, Brücken und Engstellen;
4. DCS-Kartenstraßen;
5. vorhandene OMW-PATHLINEs;
6. getrennte technische Befahrbarkeitstests.

Priorität:

```text
1. Oregon: KAF → Tarin Kowt
2. Honda/Volkswagen: Orgun-E → Zerok → Bermel
3. Fosters/Cowboys: Panjwayi / Masum Ghar / Sperwan Ghar
4. Torch: Salerno / Khost
5. Lithium: Qala-e-Naw / Sang Tesh
6. Horseshoe: Old Kabul Road / Camp Phoenix
```
