---
document_id: OMW-EVIDENCE-AFGHAN-WAR-DIARY-MSR-STAGE2-2026-07-31
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - provenance, extraction method and confidence limits for the Afghan War Diary MSR stage-two analysis
  - inventory of explicitly named MSR references, coordinates and analytically grouped incident clusters
not_authoritative_for:
  - final historical MSR pathline geometry
  - exact road-centerline reconstruction
  - proof that every reported coordinate lies directly on the named MSR
  - DCS runtime route acceptance
scenario_period: 2010-08-01/2011-12-31
source_period: 2004-01-01/2009-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: main
source_commit: 165f0a80ff7d0a71b8ef34c09762f6e012f5fdda
validated_in_dcs: false
---

# Afghan War Diary – MSR-Auswertung Stufe 2

## 1. Quelle

Vom Projektinhaber bereitgestellter CSV-Export der bei WikiLeaks veröffentlichten Afghan War Diaries:

```text
afg.csv
```

Die Datei wurde zunächst auf Meldungen mit dem eigenständigen Suchbegriff `MSR` gefiltert. Die daraus erzeugte Arbeitsmenge umfasst:

```text
734 Berichte
731 Berichte mit formal plausiblen Latitude-/Longitude-Werten
0 formal fehlerhafte CSV-Zeilen im Einleselauf
```

Die War Diaries sind operative Einzelmeldungen. Sie sind keine systematische MSR-Karte und keine vollständig konsistente Ereignisdatenbank.

Quellenklassifikation:

```text
INCORPORATED_WITH_LIMITS
```

## 2. Stufe-2-Verfahren

Die zweite Auswertungsstufe führte folgende Schritte durch:

1. Normalisierung beobachteter Schreibvarianten und Tippfehler, unter anderem `ILLIONIS`/`ILLIONOIS` zu `ILLINOIS`, `CALI` zu `CALIFORNIA`, `VIRGINA` zu `VIRGINIA` und `CONNETICUT` zu `CONNECTICUT`.
2. Aufspaltung von Meldungen mit mehreren Routennamen in mehrere Routenerwähnungen.
3. Kennzeichnung der Namenssicherheit:
   - `HIGH`: explizite Form `MSR <Name>` oder `ROUTE <Name>`;
   - `MEDIUM`: Routenname im selben MSR-haltigen Bericht, aber nicht direkt nach `MSR`/`ROUTE`;
   - `LOW`: MSR erwähnt, aber kein normalisierter Routename extrahiert.
4. Regelbasierte Klassifikation von Ereignismustern wie IED, Ambush, Small Arms Fire, RPG, Indirect Fire, VBIED, Route Clearance, Convoy Movement, Road Status und Checkpoint.
5. Extraktion von FOB-Erwähnungen und einfachen `FROM ... TO ...`-/`BETWEEN ... AND ...`-Relationen.
6. Räumliche Gruppierung koordinierter Punkte pro Route mit DBSCAN auf Haversine-Distanzen:

```text
Nachbarschaftsradius: 15 km
Mindestpunktzahl: 2
```

Die Cluster sind analytische Gruppierungen. Sie sind keine historisch belegten Routensegmente, Hotspot-Grenzen oder exakten MSR-Korridore.

## 3. Verifizierter Stufe-2-Stand

```text
Gefilterte MSR-Berichte:                  734
Berichte mit normalisiertem Routennamen:  613
Berichte ohne normalisierten Routennamen: 121
Normalisierte unterschiedliche Namen:     39
Koordinierte benannte Routenerwähnungen:  741
Räumliche Analysecluster:                  57
```

Die Zahl der koordinierten benannten Routenerwähnungen liegt über der Zahl der Berichte, weil einzelne Berichte mehrere MSRs nennen und deshalb mehrfach in der explodierten Routentabelle erscheinen.

## 4. Häufigste explizit oder mittelbar normalisierte MSR-Namen

Die folgenden Werte zählen Berichte pro normalisiertem Routennamen, nicht unabhängige Vorfälle und nicht eindeutige Straßenpunkte:

| Route | Berichte | Zeitraum in der Arbeitsmenge | Bemerkung |
|---|---:|---|---|
| `MSR Vermont` | 93 | 2006-09 bis 2009-12 | Tagab-/Kapisa-Bezug häufig; FOB Tagab und FOB Kutschbach erscheinen mehrfach |
| `MSR Ohio` | 88 | 2006-11 bis 2009-11 | mehrere Cluster; unter anderem Ghazni-, Wardak-, Shank- und Bagram-Bezüge |
| `MSR Illinois` | 71 | 2006-06 bis 2009-12 | starke Konvoi-/CLP-Verknüpfung mit FOB Fenty/Jalalabad und Bagram |
| `MSR California` | 70 | 2007-08 bis 2009-12 | Kunar-Korridor; Fenty, Monti, Bostick und Pirtle-King treten wiederholt auf |
| `MSR Nevada` | 64 | 2007-03 bis 2009-05 | häufig gemeinsam mit Illinois in Fenty-/Bagram-CLP-Berichten |
| `MSR Rhode Island` | 36 | 2008-04 bis 2009-09 | wiederholte Bezüge zu Blessing und Abad |
| `MSR Alaska` | 31 | 2006-08 bis 2009-12 | unter anderem Salerno-/Khost-Raum |
| `MSR Iowa` | 30 | 2007-09 bis 2009-12 | Kalagush-, Mehtar-Lam- und Laghman-Bezüge |
| `MSR Florida` | 24 | 2006-06 bis 2009-12 | unter anderem Sharana, Orgun-E, Tillman und Bagram |
| `MSR Utah` | 22 | 2007-02 bis 2009-11 | Logar-/Shank-/Hades-Bezüge |
| `MSR Virginia` | 20 | 2007-03 bis 2009-09 | Ghazni–Gardez-Bezüge in einzelnen Meldungen |
| `MSR Nebraska` | 18 | 2009-03 bis 2009-12 | Laghman-/Mehtar-Lam-Bezug |

Weitere normalisierte Namen umfassen unter anderem:

```text
Hawaii
Montana
Idaho
Texas
Georgia
Connecticut
Alabama
Wyoming
Maine
Pluto
Uranus
Stetson
Bear
Zodiac
Audi
Keystone
Miami / Miami South
Philadelphia
New Orleans
Viper
Alingar
Libra
Line 8 / L8
```

Diese Namen sind zunächst als `SOURCE-DERIVED ROUTE NAME` zu behandeln. Eine Übernahme als aktive OMW-PATHLINE erfordert getrennte kartografische Validierung.

## 5. Robuste Routenzusammenhänge

### 5.1 FOB Fenty / Jalalabad – Bagram

Mehrere Convoy Logistics Patrol Reports nennen gemeinsam:

```text
FOB Fenty / Jalalabad
→ MSR Illinois
→ Kabul-Raum
→ MSR Nevada
→ Bagram Airfield
```

Ein besonders strukturierter Bericht führt `MSR Illinois` auf dem ersten Teil und `MSR Nevada` auf dem späteren Abschnitt nach Bagram. Wiederholte Meldungen nennen außerdem `FOB Fenty → Bagram`, `Bagram Airfield → FOB Fenty` beziehungsweise `BAF → FOB Fenty`.

Diese Berichte sind starke Hinweise auf eine operative Abschnittsfolge Illinois/ Nevada. Sie bestimmen aber noch nicht die exakte Straßenlinie jeder Teilstrecke.

### 5.2 MSR California / Kunar

Die Arbeitsmenge enthält wiederholte Kombinationen mit:

```text
FOB Fenty
FOB Monti
FOB Bostick
COP Pirtle-King
Naray
```

Dies stützt den bereits separat dokumentierten Kunar-Korridor. Die War-Diary-Daten können zur Verdichtung von Ereignispunkten und Teilstrecken verwendet werden, ersetzen aber nicht die quellenkritische Trennung zwischen projektinterner Segmentierung und historischer Benennung.

### 5.3 MSR Vermont / Tagab–Kapisa

Die Meldungen bestätigen wiederholt:

```text
Tagab-/Kapisa-Raum
FOB Tagab
FOB Kutschbach
FOB Morales-Frazier
```

IED-, Route-Clearance-, SAF-, RPG- und Convoy-Meldungen treten in diesem Bestand häufig auf. Die Daten ergänzen die bereits dokumentierte historische Vermont-Baseline, erlauben aber ohne Kartenabgleich keine automatische Verlängerung bis Nijrab oder eine exakte Straßenmittellinie.

### 5.4 Weitere belastbare Paarungen

In einzelnen oder mehreren strukturierten Meldungen erscheinen unter anderem:

```text
MSR Virginia: FOB Ghazni ↔ FOB Gardez
MSR Florida: FOB Sharana ↔ Bagram; Orgun-E ↔ FB Tillman
MSR Rhode Island: Blessing ↔ Abad
MSR Illinois/California: Fenty ↔ Monti
```

Jede Paarung benötigt eine Einzelfallprüfung des vollständigen Meldungstextes, bevor sie in eine definitive Routentabelle übernommen wird.

## 6. Ereignismuster

Die automatische Ereignisklassifikation dient nur als Arbeitsindex. Häufig auftretende Klassen sind:

```text
IED / explosive hazard
route clearance / EOD
small arms fire
RPG
indirect fire / mortar / rocket
convoy movement / CLP
ambush / complex attack
road status / passability
checkpoint / TCP / VCP
road or bridge development
```

Mehrfachklassifikation ist zulässig. Ein Bericht kann beispielsweise zugleich `IED`, `ROUTE_CLEARANCE` und `CONVOY_MOVEMENT` tragen.

Die Häufigkeit einer Klasse darf nicht als standardisierte Angriffswahrscheinlichkeit interpretiert werden. Meldepraktiken, Einheitenaktivität, Datenlücken und Mehrfachmeldungen verzerren die Verteilung.

## 7. Koordinaten- und Clustergrenzen

Ein War-Diary-Koordinatenpunkt kann bezeichnen:

- den eigentlichen Angriffsort;
- einen Fundort;
- eine Sicherungsposition;
- eine Meldungs- oder Link-up-Position;
- einen nahegelegenen Ort oder Checkpoint;
- einen gerundeten MGRS-/Lat-Lon-Konvertierungspunkt.

Daher gilt:

1. Ein Punkt in einem Bericht mit `MSR California` ist nicht automatisch ein Punkt auf der Straßenmittellinie.
2. Räumliche Cluster dürfen zunächst nur als `INCIDENT CONCENTRATION CANDIDATE` geführt werden.
3. Ein `IED_`, `AMB_`, `OBS_` oder `CHK_`-Marker benötigt Einzelfallprüfung des Textes und Kartenabgleich.
4. Linienrekonstruktion darf nicht durch bloßes Verbinden chronologisch oder räumlich sortierter Vorfallspunkte erfolgen.

## 8. Noch offene 121 Berichte

Nach der zweiten automatischen Stufe verbleiben 121 Berichte ohne normalisierten Routennamen. Diese Gruppe enthält unter anderem:

- generische Formulierungen wie `main MSR`;
- Lagebezüge ohne Codenamen;
- explizite Endpunktangaben wie `between Atghar and Shamulzai`;
- lokale Straßennamen oder Route-Namen außerhalb der bisherigen Aliasliste;
- Meldungen, in denen `MSR` nur als Funktionsbezeichnung erscheint;
- potenzielle neue Namen wie `Honda` oder andere nicht abschließend geprüfte Varianten.

Diese Berichte sind nicht wertlos. Sie bilden die nächste manuelle beziehungsweise halbautomatische Prüfcharge.

## 9. Arbeitsartefakte

Außerhalb des Repositorys wurden erzeugt:

```text
afg_war_diary_msr_stage2_analysis.xlsx
afg_war_diary_msr_stage2_mentions.csv
afg_war_diary_msr_stage2_route_summary.csv
afg_war_diary_msr_stage2_unresolved.csv
afg_war_diary_msr_stage2_clusters.csv
afg_war_diary_msr_stage2_points.geojson
```

Die Excel-Datei enthält:

- `README`;
- `Route Summary`;
- `Named Mentions`;
- `Unresolved`;
- `Spatial Clusters`;
- `Original Filtered`.

## 10. Verwendungsregeln für OMW

1. Explizite War-Diary-Namen erhöhen die historische Namenssicherheit, ersetzen aber keine Geometrieprüfung.
2. Wiederholte FOB-zu-FOB-Berichte dürfen als Korridorhypothese und Segmentierungsbeleg verwendet werden.
3. Einzelkoordinaten werden nicht ungeprüft als PATHLINE-Waypoint übernommen.
4. Ereigniscluster werden zunächst als Kandidaten geführt und erhalten keine automatische Spieler-Sichtbarkeit.
5. Routennamen aus der Vorperiode 2004–2009 dürfen nicht ohne Kontinuitätsbeleg als unverändert gültig für 2010/2011 angenommen werden.
6. Technische DCS-Befahrbarkeit und historische Richtigkeit bleiben getrennte Acceptance-Dimensionen.
7. Jede spätere Dokument-49-Übernahme muss zwischen `SOURCE-DERIVED`, `PROJECT-INFERRED`, `CARTOGRAPHICALLY-VALIDATED` und `DCS-VALIDATED` unterscheiden.

## 11. Nächste Prüfcharge

Priorität:

1. manuelle Prüfung der 121 unbenannten Berichte;
2. Validierung der Illinois-/Nevada-Abschnittsfolge Fenty–Bagram;
3. kartografische Clusterprüfung für California, Vermont, Ohio, Rhode Island, Alaska, Iowa und Florida;
4. Zeit- und Namenskontinuitätsprüfung Richtung 2010/2011;
5. Abgleich mit vorhandenen OMW-PATHLINEs und Dokument 49;
6. erst danach Erzeugung neuer oder korrigierter DCS-Routenlinien.
