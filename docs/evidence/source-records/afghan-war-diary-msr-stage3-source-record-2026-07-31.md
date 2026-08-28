---
document_id: OMW-EVIDENCE-AFGHAN-WAR-DIARY-MSR-STAGE3-2026-07-31
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - provenance, normalization and confidence limits of the Afghan War Diary MSR stage-three analysis
  - inventory of additional explicit MSR names and unnamed endpoint-defined corridor evidence
not_authoritative_for:
  - final historical MSR PATHLINE geometry
  - automatic conversion of incident coordinates into route centerlines
  - proof that a reported coordinate lies exactly on the named road
  - continuity of every route name into the 2010-2011 OMW scenario period
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
source_period: 2004-01-01/2009-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: main
source_commit: ff88e812e713d08123ec0764ac1bb361eabdbf6b
validated_in_dcs: false
---

# Afghan War Diary – MSR-Auswertung Stufe 3

## 1. Bezug und Zweck

Diese Akte setzt die Stufe-2-Auswertung fort:

- [`OMW-EVIDENCE-AFGHAN-WAR-DIARY-MSR-STAGE2-2026-07-31`](afghan-war-diary-msr-stage2-source-record-2026-07-31.md)

Quelle bleibt der vom Projektinhaber bereitgestellte CSV-Export `afg.csv` der veröffentlichten Afghan War Diaries. Die Arbeitsmenge enthält 734 Berichte mit dem eigenständigen Suchbegriff `MSR`.

Stufe 3 konzentriert sich auf:

1. zusätzliche Codenamen und Schreibvarianten in den zuvor unaufgelösten Meldungen;
2. Abkürzungen wie `VT`, `HI`, `NV`, `AK` und `TX` nur bei eindeutigem MSR-Kontext;
3. lokale oder nichtstaatliche Routennamen;
4. Endpunktbeziehungen ohne überlieferten Codename;
5. Trennung zwischen benannter Route, unbenanntem Korridor und generischer MSR-Erwähnung.

Quellenklassifikation:

```text
INCORPORATED_WITH_LIMITS
```

## 2. Verifizierter Stufe-3-Stand

```text
Gefilterte MSR-Berichte:                         734
Berichte mit normalisiertem MSR-Namen:           622
Verbleibende Berichte ohne normalisierten Namen: 112
Davon mit extrahiertem Endpunkt-/Distanzbezug:      6
Normalisierte unterschiedliche Routennamen:       52
Koordinierte benannte Routenerwähnungen:          693
Räumliche Analysecluster:                          46
```

Die Zahlen unterscheiden sich von Stufe 2, weil:

- weitere Namen erkannt wurden;
- Schreibvarianten zusammengeführt wurden;
- der Stufe-3-Extraktor konservativer bei schwachen Namensnennungen arbeitet;
- einzelne Berichte mit mehreren Namen weiterhin mehrfach in der explodierten Routentabelle erscheinen.

Die Cluster verwenden weiterhin DBSCAN auf Haversine-Distanzen mit 15-km-Nachbarschaft und mindestens zwei Punkten. Sie sind keine historischen Routengrenzen.

## 3. Neu aufgelöste MSR-Namen

### 3.1 MSR Horseshoe

Ein Bericht vom 4. Mai 2005 nennt:

```text
Old Kabul Road (MSR Horseshoe)
25 km nordwestlich von Camp Phoenix
```

Dort wurde eine Mörsergranate als UXO gefunden und durch EOD gesprengt.

Zulässige Aussage:

```text
MSR Horseshoe war mindestens in diesem Bericht mit der Old Kabul Road
nordwestlich von Camp Phoenix verknüpft.
```

Nicht zulässig ist daraus allein eine vollständige Kabul-Bagram-Linie abzuleiten.

### 3.2 MSR Honda und MSR Volkswagen

Ein Route Status Report vom 21. Februar 2007 beschreibt eine Route-Clearance-Bewegung:

```text
FOB Orgun-E
→ MSR Honda und MSR Volkswagen
→ FOB Bermel
```

Dokumentierte Straßenbedingungen:

- kaum passierbar für militärische und zivile Fahrzeuge;
- Schnee und Eis;
- auswaschende Low-Water Crossings;
- tiefer Schlamm und stehendes beziehungsweise fließendes Wasser;
- Schlaglöcher und tiefe Spurrillen;
- Geschwindigkeit ungefähr 5-10 mph;
- Route Status `RED`.

Ein weiterer Bericht nennt `Route Honda` an der südlichen Seite der Pech River Road. Da dieser zweite Beleg räumlich weit vom Orgun-E/Bermel-Bericht entfernt liegt, darf nicht automatisch angenommen werden, dass beide Nennungen dieselbe durchgehende Straße bezeichnen. Möglich sind mehrfach verwendete Codenamen, fehlerhafte Meldungszuordnung oder lokale Benennung.

### 3.3 Weitere explizite Namen

| Name | Quellenbezug | Zulässige Einordnung |
|---|---|---|
| `MSR Norwood` | Nähe `Route Norlina`, Straßenbau-/TCP-Ereignis, April 2008 | lokaler RC-East-Routenname; keine vollständige Geometrie |
| `MSR Montgomery` | Goshta District, Nangarhar; IED-Komponentenfund, August/September 2008 | Goshta-/Grenzraumbezug; Schreibvariante `Montogomery` normalisiert |
| `MSR Onyx` | RC West; möglicher RCIED-Fund, Oktober 2008 | benannter RC-West-Korridor, exakte Linie offen |
| `MSR Gemini` | RC North; RCIED gegen HART-Sicherheitsfahrzeug, Dezember 2008/Januar 2009 | benannter RC-North-Korridor, exakte Linie offen |
| `MSR Topaz` | RC West; CWIED an Culvert, April 2009 | benannter RC-West-Korridor mit Culvert-/IED-Bezug |
| `MSR Whale` | RC South; RCIED-Fund, QRF ab FOB Ripley, Mai 2009 | FOB-Ripley-/RC-South-Bezug; exakte Linie offen |
| `MSR New Hampshire` | Shamalzai District, Zabul; IED gegen A/4-23 IN, August 2009 | belastbarer Distrikt- und Ereignisbezug |
| `MSR Beaverton` | C-IED-Patrouille von D/1-32, September 2009 | Schreibform `Beavertoni` als wahrscheinliche Variante normalisiert |
| `MSR Pacesetter` | westwärts fahrendes Taxi, Bezug zu COP Najil, September 2009 | lokaler Laghman-/Najil-Bezug, exakte Linie offen |
| `MSR Highway 4` | Spin Boldak District, Kandahar, August 2009 | Schreibform `MSR HWY 4`; nicht automatisch identisch mit nationalem Highway-System ohne Kartenabgleich |

Jeder Name bleibt `SOURCE-DERIVED`. Eine aktive OMW-PATHLINE benötigt Kartografie- und DCS-Prüfung.

## 4. Unbenannte, aber endpoint-definierte Korridore

Sechs Berichte enthalten keinen normalisierten Codename, aber brauchbare Abschnittsangaben.

### 4.1 Atghar–Shamulzai

Bericht vom 26. Juli 2004:

```text
MSR between Atghar and Shamulzai
```

Ein IED traf Elemente von 2-35; Verwundete wurden nach KAF evakuiert.

Einordnung:

```text
UNNAMED_CORRIDOR_WITH_ENDPOINTS
```

### 4.2 Kamdesh-/Gowardesh-/Gardesh-Sektor

Mehrere Meldungen beschreiben:

```text
Kamdesh-Gardesh MSR
BK-Gowardesh MSR
MSR from Kamdesh to Gowardesh
```

Zusätzlich werden Bari Khowt, Kamdesh PRT, FB Lybert/Gowardesh und dominierendes Gelände entlang der Straße genannt.

Die Schreibweisen `Gardesh`, `Gowardesh` und Kürzel wie `BK` müssen vor einer endgültigen Namensnormalisierung gegen Karten und weitere Meldungen geprüft werden. Sie dürfen noch nicht zu einer einzigen offiziellen MSR-Bezeichnung verschmolzen werden.

### 4.3 Südlich von FOB Naray

Ein Bericht vom 2. Februar 2007 nennt zwei brennende Jingle Trucks:

```text
22 km südlich von FOB Naray auf der MSR
```

Der Korridorbezug ist stark, der Codename fehlt. Der Punkt kann die Kunar-Achse beziehungsweise den südlichen Zulauf nach Naray stützen, aber nicht allein den Namen `MSR California` beweisen.

### 4.4 Asmar–Naray

Ein Bericht vom 27. März 2007 nennt ausdrücklich:

```text
MSR between Asmar and Naray
ungefähr 8 km südlich von Naray
```

Dort wurde ein brennender Jingle Truck beobachtet; fünf feindliche Personen exfiltrierten aus dem Hinterhaltsraum.

Dieser Bericht ist ein starker funktionaler Beleg für den Asmar-Naray-Korridor und unterstützt die bestehende Projektsegmentierung von MSR California. Da der Bericht selbst den Codename `California` nicht nennt, bleibt die Zuordnung:

```text
CORRIDOR CONFIRMED
CODENAME IN THIS REPORT UNCONFIRMED
```

## 5. Methodische Korrekturen gegenüber Stufe 2

1. Ein Wort nach `MSR` wird nicht automatisch als Routename akzeptiert.
2. Begriffe wie `update`, `enroute`, `north`, Entfernungsangaben und Satzfragmente werden ausgeschlossen.
3. Kurzcodes wie `VT`, `HI`, `NV`, `AK` und `TX` werden nur in explizitem Routen-/MSR-Kontext normalisiert.
4. Ähnliche Namen an weit getrennten Orten dürfen nicht automatisch als dieselbe durchgehende Route behandelt werden.
5. Endpunktangaben ohne Codename werden separat als `UNNAMED_CORRIDOR_WITH_ENDPOINTS` geführt.
6. Meldungskoordinaten bleiben Incident-/Meldepunkte und keine automatischen Straßenmittelpunkte.

## 6. Arbeitsartefakte

Außerhalb des Repositorys wurden erzeugt:

```text
afg_war_diary_msr_stage3_analysis.xlsx
afg_war_diary_msr_stage3_mentions.csv
afg_war_diary_msr_stage3_route_summary.csv
afg_war_diary_msr_stage3_unresolved.csv
afg_war_diary_msr_stage3_unnamed_corridor_evidence.csv
afg_war_diary_msr_stage3_clusters.csv
afg_war_diary_msr_stage3_points.geojson
```

Die Excel-Arbeitsmappe enthält:

- `README`;
- `Route Summary`;
- `Named Mentions`;
- `Unresolved`;
- `Unnamed Corridors`;
- `Spatial Clusters`.

## 7. Konsequenzen für OMW

### 7.1 Sofort zulässige Dokumentationsnutzung

- neue Routennamen als quellenbelegte historische Namen erfassen;
- Asmar-Naray und Atghar-Shamulzai als endpoint-definierte Korridore führen;
- Orgun-E-Bermel als quellenbelegte Bewegung über Honda und Volkswagen dokumentieren;
- Horseshoe mit Old Kabul Road nordwestlich Camp Phoenix verknüpfen;
- Ereignispunkte als Kandidaten für spätere Kartografie und Hotspotprüfung verwenden.

### 7.2 Noch nicht zulässig

- direkte Erzeugung neuer PATHLINEs aus Incident-Punkten;
- Verbindung aller Punkte eines Namens zu einer einzigen Straße;
- Gleichsetzung von `MSR Highway 4` mit einer bestimmten nationalen Straße ohne Kartenbeleg;
- automatische Kontinuität der 2004-2009-Namen in den Missionszeitraum 2010-2011;
- automatische Klassifikation jedes Vorfalls als Angriff direkt auf der Straßenmittellinie.

## 8. Nächste Prüfcharge

1. vollständige Einzelfallprüfung der 112 verbleibenden generischen MSR-Meldungen;
2. kartografische Prüfung von Horseshoe/Old Kabul Road und der Beziehung zu Kabul-Bagram-Routen;
3. getrennte Kartografieprüfung der beiden `Honda`-Nennungen;
4. Rekonstruktion der Orgun-E-Bermel-Segmentfolge Honda/Volkswagen;
5. Kunar-Abgleich der Asmar-Naray-, Naray-südlich- und California-Meldungen;
6. Prüfung neuer Namen gegen weitere War-Diary-Einträge ohne exakten Suchbegriff `MSR`, insbesondere `Route <Name>`, `RTE <Code>` und `ASR <Name>`;
7. Zeitkontinuitätsprüfung für 2010/2011 anhand anderer Quellen.
