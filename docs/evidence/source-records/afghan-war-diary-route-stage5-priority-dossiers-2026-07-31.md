---
document_id: OMW-EVIDENCE-AFGHAN-WAR-DIARY-ROUTE-STAGE5-2026-07-31
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - stage-five priority-route evidence review from the Afghan War Diaries
  - terminology status and conservative corridor hypotheses for Oregon, Fosters, Cowboys, Violet, Torch, Lithium, Honda and Volkswagen
not_authoritative_for:
  - final historical route geometry
  - exact road centerlines
  - proof that every report coordinate lies directly on the named route
  - DCS PATHLINE acceptance
scenario_period: 2010-08-01/2011-12-31
source_period: 2004-01-01/2009-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: main
source_commit: ad58c25fe8b9d3f68a0b553e92e79242ffc5979c
validated_in_dcs: false
---

# Afghan War Diary – Prioritätsrouten Stufe 5

## 1. Zweck

Diese Akte dokumentiert die erste fokussierte Dossierbildung für folgende priorisierte Routennamen:

```text
OREGON
HORSESHOE
FOSTERS
COWBOYS
VIOLET
TORCH
LITHIUM
HONDA
VOLKSWAGEN
```

Ausgewertet wurden die in Stufe 4 konservativ kuratierten expliziten `MSR`, `ASR`, `ROUTE`- und `RTE`-Erwähnungen sowie die vollständigen War-Diary-Texte der zugehörigen Berichte.

## 2. Methodik

Je Route wurden erfasst:

- Anzahl unterschiedlicher Berichte;
- beobachtete Terminologiepräfixe;
- Zeitraum;
- regionale Konzentration;
- explizite FOB-/COP-/PB-Bezüge;
- `FROM ... TO ...`- und `BETWEEN ... AND ...`-Relationen;
- Distanz- und Richtungsangaben;
- Koordinatenpunkte;
- Incident-Muster.

Automatische Orts- und Relationsparser erzeugten in strukturierten Patrol Reports zahlreiche Fehlkandidaten aus Tabellenüberschriften und Satzfragmenten. Rohkandidaten wie `GRID`, `ORDER`, `APPROXIMATELY`, `REACTIONS`, `REPORT` oder Teile von Standardformularen sind keine Ortsknoten und dürfen nicht in die Routengeometrie übernommen werden.

## 3. Verifizierter Arbeitsstand

```text
Prioritätsrouten mit kuratierter Stufe-4-Datenbasis: 8
Unterschiedliche Berichte:                         478
Koordinierte Erwähnungen:                          891
```

`HORSESHOE` war nicht Teil der kuratierten Stufe-4-Datei und wird deshalb weiterhin separat aus der Stufe-3-Evidenz geführt. Die bekannte Aussage `Old Kabul Road (MSR Horseshoe), 25 km nordwestlich von Camp Phoenix` bleibt gültig, wurde in dieser automatisierten Dossiercharge aber nicht erneut verarbeitet.

## 4. Terminologiestatus

### 4.1 MSR Honda

Im kuratierten Bestand erscheinen 137 unterschiedliche Berichte und mindestens eine explizite `MSR Honda`-Nennung. Zusätzlich treten `Route Honda` und `RTE Honda` häufig auf.

Belastbare Textbezüge umfassen:

```text
FOB Orgun-E
Zerok
Bermel
Route Honda
Route Volkswagen
```

Ein Route Status Report beschreibt eine Bewegung von Orgun-E Richtung Bermel über Honda und Volkswagen. Mehrere Meldungen enthalten Winter-, Schlamm-, Washout- und Geschwindigkeitsangaben. Daraus folgt:

```text
nameConfidence: HIGH
corridorFunctionConfidence: MEDIUM-HIGH
exactGeometry: UNVALIDATED
```

Die War Diaries zeigen außerdem eine Honda-Nennung an der Pech River Road. Wegen der räumlichen Trennung darf nicht ohne weitere Prüfung angenommen werden, dass sämtliche Honda-Nennungen dieselbe durchgehende Route bezeichnen.

### 4.2 Route Volkswagen

45 unterschiedliche Berichte nennen `Route Volkswagen` beziehungsweise `RTE Volkswagen`; eine explizite `MSR Volkswagen`-Nennung wurde in dieser Charge nicht bestätigt.

Wiederkehrende Bezüge:

```text
Bermel
Rabat
Bermel Bazaar
Verbindung mit Route Honda
```

Status:

```text
terminology: ROUTE/RTE ATTESTED
corridorHypothesis: Orgun-E/Honda → Bermel/Volkswagen
exactGeometry: UNVALIDATED
```

### 4.3 Route Fosters

92 unterschiedliche Berichte, konzentriert in RC South. Wiederkehrende belastbare Ortsbezüge sind:

```text
Masum Ghar
Panjwayi / Panjwayee
Sperwan Ghar
```

Der Bestand enthält zahlreiche IED-/C-IED- und EOD-Bezüge. `Fosters` ist als Route/RTE gut belegt, aber in dieser Charge nicht ausdrücklich als MSR bestätigt.

```text
terminology: ROUTE/RTE ATTESTED
regionalCorridor: Panjwayi–Masum Ghar–Sperwan Ghar sector
exactGeometry: UNVALIDATED
```

### 4.4 Route Cowboys

73 unterschiedliche Berichte; Schwerpunkt RC South. Wiederkehrende Ortsbezüge umfassen:

```text
Hassan Abad
Koshtay / Kostay
```

Die Meldungen enthalten häufig IED-, Druckplatten- und EOD-Beschreibungen entlang Route/RTE Cowboys.

```text
terminology: ROUTE/RTE ATTESTED
regionalCorridor: RC South, Hassan Abad–Koshtay/Kostay sector
exactGeometry: UNVALIDATED
```

### 4.5 Route Violet

58 unterschiedliche Berichte; deutlicher Schwerpunkt RC Capital. Belastbare Bezüge:

```text
Kabul
Checkpoint V
```

Mehrere Meldungen betreffen IED-Ereignisse und QRF-/Polizeireaktionen. Eine explizite MSR-Nennung wurde nicht bestätigt.

```text
terminology: ROUTE/RTE ATTESTED
regionalCorridor: Kabul / RC Capital
exactGeometry: UNVALIDATED
```

### 4.6 Route Torch

34 unterschiedliche Berichte; RC East. Wiederkehrende Bezüge:

```text
Salerno
Culverts
Mines / IEDs east of Route Torch
```

Die Berichte stützen eine lokale Route im Khost-/Salerno-Raum mit ausgeprägter IED-/Minenbedrohung.

```text
terminology: ROUTE/RTE ATTESTED
regionalCorridor: Salerno/Khost sector
exactGeometry: UNVALIDATED
```

### 4.7 Route Lithium

29 unterschiedliche Berichte; Schwerpunkt RC West. Wiederkehrende Bezüge:

```text
Sang Tesh / Sanga Tesh
PRT QEN
Qala-e-Naw sector
```

Die Berichte enthalten TIC-, ANSF-Unterstützungs- und Bewegungsbezüge.

```text
terminology: ROUTE/RTE ATTESTED
regionalCorridor: Qala-e-Naw / Sang Tesh sector
exactGeometry: UNVALIDATED
```

### 4.8 Route Oregon

18 unterschiedliche War-Diary-Berichte nennen `Route Oregon` beziehungsweise `RTE Oregon`, konzentriert in RC South. Eine explizite MSR-Nennung wurde in dieser War-Diary-Charge nicht gefunden.

Die separate niederländische Quelle dokumentiert jedoch ausdrücklich `MSR Oregon` für den KAF–Tarin-Kowt-Korridor im Jahr 2008. Zusammen ergibt sich:

```text
War Diaries: ROUTE/RTE Oregon repeatedly attested
separate source: MSR Oregon explicitly attested
corridor endpoints: Kandahar Airfield → Tarin Kowt
exact War-Diary event-to-centerline relationship: UNVALIDATED
```

## 5. Horseshoe

Der Stufe-3-Befund bleibt separat gültig:

```text
Old Kabul Road (MSR Horseshoe)
25 km northwest of Camp Phoenix
```

Diese Aussage ist ein konkreter Namens- und Lagebezug. Sie genügt nicht zur vollständigen Gleichsetzung von Horseshoe mit einer bestimmten Kabul–Bagram-Linie oder mit `MSR EAST-E3`.

## 6. Quellenkritische Regeln

1. Wiederholte `ROUTE`-/`RTE`-Nennungen belegen einen Routencodename, aber nicht automatisch eine MSR-Klassifikation.
2. Eine einzelne explizite `MSR`-Nennung erhöht die Terminologiesicherheit, ersetzt aber keine Geometrieprüfung.
3. Berichtspunkte können Angriffsort, Meldungsposition, Sicherungsposition, Link-up, Fundort oder gerundete Ortsangabe sein.
4. Rohparser-Orte werden nicht als Nodes übernommen, sofern sie nicht im Volltext eindeutig als reale Orte oder Einrichtungen erkennbar sind.
5. Eine Linie darf nicht durch einfaches Verbinden der Ereignispunkte konstruiert werden.
6. Routen mit demselben Codename in räumlich getrennten Regionen können lokale Wiederverwendungen oder Datenfehler darstellen.
7. Für OMW bleiben die Zustände getrennt:

```text
NAME_ATTESTED
CORRIDOR_HYPOTHESIS
CARTOGRAPHICALLY_VALIDATED
DCS_VALIDATED
```

## 7. Arbeitsartefakte

Außerhalb des Repositorys wurden erzeugt:

```text
afg_war_diary_route_stage5_priority_analysis.xlsx
afg_war_diary_route_stage5_priority_dossiers.csv
afg_war_diary_route_stage5_priority_evidence.csv
afg_war_diary_route_stage5_candidate_nodes.csv
afg_war_diary_route_stage5_priority_points.geojson
```

Die Datei `candidate_nodes.csv` enthält Rohkandidaten und ist ausdrücklich nicht autoritativ. Für dokumentarische Übernahmen sind Volltextprüfung und Kartenabgleich erforderlich.

## 8. Nächste Schritte

1. manuelle Volltextprüfung der wiederkehrenden Ortsbezüge pro Prioritätsroute;
2. separate GIS-Layer je Route statt gemeinsamer Punktwolke;
3. Kartenabgleich mit DCS Afghanistan, Google Earth und vorhandenen OMW-PATHLINEs;
4. Oregon zuerst gegen KAF–Tarin-Kowt prüfen;
5. Honda/Volkswagen gegen Orgun-E–Bermel prüfen;
6. Fosters/Cowboys gegen Panjwayi–Masum-Ghar-/Sperwan-Ghar-Sektor prüfen;
7. Violet gegen Kabul-/Checkpoint-V-Bezüge prüfen;
8. Torch gegen Salerno-/Khost-Sektor prüfen;
9. Lithium gegen Qala-e-Naw-/Sang-Tesh-Sektor prüfen;
10. Horseshoe separat gegen Camp Phoenix und Old Kabul Road untersuchen.
