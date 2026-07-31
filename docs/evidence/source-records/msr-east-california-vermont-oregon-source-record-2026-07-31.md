---
document_id: OMW-EVIDENCE-MSR-EAST-CALIFORNIA-VERMONT-OREGON-2026-07-31
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - source provenance and confidence limits for the current MSR EAST-E3, California, Vermont and Oregon research intake
  - repository-state audit for these route findings as of 2026-07-31
not_authoritative_for:
  - final DCS PATHLINE geometry
  - exact incident or IED coordinates
  - runtime route acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: main
source_commit: b62726692942769c149c3749bfd3e60baf02ae5b
validated_in_dcs: false
---

# MSR EAST-E3, California, Vermont und Oregon – Quellenakte 31.07.2026

## 1. Zweck

Diese Quellenakte dokumentiert die im aktuellen Arbeitsstrang ausgewerteten Quellen zu vier Nachschubwegen beziehungsweise Routenkorridoren:

```text
MSR EAST-E3 / Kabul–Bagram
MSR California / Kunar
MSR Vermont / Surobi–Tagab–Kapisa
MSR Oregon / Kandahar Airfield–Tarin Kowt
```

Sie trennt:

1. quellenbelegte Aussagen;
2. projektinterne Segmentierung;
3. kartografische Arbeitsannahmen;
4. noch offene Namens-, Linien- und Koordinatenfragen;
5. den tatsächlichen Repository-Stand auf `main` und relevanten Alt-/Testbranches.

## 2. Repository-Stand

### 2.1 Main

`docs/49-msr-routendesign-und-infrastrukturmarker.md` enthält auf `main` seit Commit

```text
b62726692942769c149c3749bfd3e60baf02ae5b
```

die quellenqualifizierten historischen Baselines zu:

```text
MSR California
MSR Vermont
MSR Oregon
```

mit Quellenlisten, Quellenkritik, Missionsdesign-Ableitungen und ausdrücklichen Grenzen für DCS-Geometrie, IED-Punkte und Namenskontinuität.

Die im selben Arbeitsstrang vorgenommene Bewertung von `MSR EAST-E3` ist noch nicht als eigener Abschnitt in Dokument 49 konsolidiert. Sie wird deshalb in dieser Quellenakte vollständig festgehalten und bleibt bis zur Übernahme in Dokument 49 eine quellenbelegte Arbeitsbewertung, keine endgültig validierte Routenentscheidung.

### 2.2 Relevante Branches

Der historische Branch

```text
agent/complete-documentation-authority-migration
```

enthält eine ältere Fassung von Dokument 49 ohne die neueren historischen Baselines und Quellenangaben. Dieser Branch ist keine aktuelle Repository-Autorität.

Der offene Draft-PR #22 / Branch

```text
feature/tm01m-moose-native-baseline
```

verwendet vorhandene Mission-Editor-PATHLINEs für technische Konvoitests, darunter `MSR_EAST_E03`, `MSR_CAL_C01` und `MSR_CAL_C02`. Er ist technische Testevidenz für die dort getesteten Linien, aber keine historische Quellenakte und darf die quellenkritische Main-Dokumentation nicht überschreiben.

Beim späteren Rebase oder Merge branchgebundener Routentests ist die aktuelle Main-Fassung von Dokument 49 zu erhalten.

## 3. MSR EAST-E3 / Kabul–Bagram

### 3.1 Gegenstand

Untersucht wurde, ob der in OMW derzeit als `MSR_EAST_E03` geführte Abschnitt Kabul–Bagram eher:

1. der westlich/nordwestlich aus Kabul führenden NH01-/Kabul–Charikar-Achse folgt; oder
2. der direkteren, nordöstlich aus Kabul führenden Kabul–Bagram-/Old-Russian-Road-Achse.

### 3.2 Quellen

Vom Projektinhaber bereitgestellt:

- OpenDemocracy, *Supplying the War in Afghanistan: Frictions of Distance*: <https://www.opendemocracy.net/en/supplying-war-in-afghanistan-frictions-of-distance/>
- Reuters Factbox, *Afghan supply routes: problems and possibilities*: <https://www.reuters.com/article/economy/factbox-afghan-supply-routes-problems-and-possibilities-idUSISL312389/>
- Wikipedia, *Afghanistan Ring Road*: <https://en.wikipedia.org/wiki/Afghanistan_Ring_Road>
- `ghanistanTransportationReviewApril08.pdf` / *Transportation of Afghanistan* (2019), vom Projektinhaber bereitgestellte Datei; nicht in das öffentliche Repository übernommen.

Zusätzliche Quellen:

- NATO, *NATO and Kabul police capture bomb plotters*, 8. November 2006: <https://www.nato.int/en/news-and-events/articles/news/2006/11/08/nato-and-kabul-police-capture-bomb-plotters>
- Radio Free Europe/Radio Liberty, Bericht zu einem Anschlag auf einer nach Bagram führenden Straße am nördlichen Stadtrand Kabuls, Mai 2009: <https://www.rferl.org/a/Suicide_Blast_Kills_Two_Foreign_Soldiers_Outside_Kabul/1735452.html>
- Al Jazeera, Bericht zu einem Angriff auf einen Konvoi auf der Verbindung Bagram–Kabul, Juni 2006: <https://www.aljazeera.com/news/2006/6/26/afghans-killed-in-attack-on-us-convoy>
- Wired/Danger Room, Bericht zur Kabul–Charikar-Straße als stark befahrenem Korridor zwischen Kabul und Bagram, Juli 2009: <https://www.wired.com/2009/07/danger-room-in-afghanistan-on-a-short-drive-signs-of-progress/>

### 3.3 Quellenbelegte Aussagen

Die Quellen belegen mit unterschiedlicher Genauigkeit:

- Bagram und Kabul waren über mehrere operative und logistische Straßenkorridore verbunden.
- Die Kabul–Charikar-/NH01-Achse war eine ausgebaute, stark befahrene nationale Hauptverbindung und ein plausibler schwerer Logistikkorridor zwischen Kabul, Bagram und Nordafghanistan.
- NATO bezeichnete eine direkte Straße nördlich von Kabul als `Old Russian Road`; ein festgenommener Aufständischer war dort von Kabul in Richtung Bagram unterwegs und wollte einen Sprengsatz platzieren.
- Weitere Berichte bestätigen militärische Konvoibewegungen und Anschläge auf direkten beziehungsweise nördlichen Bagram-Zufahrten aus dem Kabul-Raum.
- OpenDemocracy und Reuters bestätigen Bagram und Kabul als zentrale End- beziehungsweise Umschlagpunkte des Pakistan-GLOC, legen aber die lokale Straße zwischen Kabul und Bagram nicht fest.
- Die Ring-Road- und Transportquellen bestätigen NH01 und die überregionale Nordverbindung, nicht die ISAF-interne Abschnittsbezeichnung `EAST-E3`.

### 3.4 Arbeitsbewertung

```text
direct Kabul–Bagram / Old Russian Road use: HIGH
NH01 / Kabul–Charikar logistics use: HIGH
exact EAST-E3 name-to-line assignment: UNCONFIRMED
```

Für OMW ist deshalb folgende quellenkritische Trennung zulässig:

```text
Kandidat MSR_EAST_E03:
Kabul → direkter nördlicher/nordöstlicher Bagram-Korridor

separate strategische Haupt-/Ausweichachse:
Kabul → Charikar / NH01 → Bagram-Abzweig
```

Die endgültige Änderung einer bestehenden PATHLINE erfordert eine historische MSR-/Route-Overlay-Karte oder eine andere Quelle, die `EAST-E3` ausdrücklich einer konkreten Straßenlinie zuordnet.

## 4. MSR California

### 4.1 Primär- und Bestätigungsquellen

- Military Times Hall of Valor, Jeffrey A. Conn, Silver Star: <https://valor.militarytimes.com/recipient/recipient-84896/>
- U.S. Army Medical Department Center of History and Heritage, Silver-Star-Citations OIF/OEF: <https://achh.army.mil/regiment/silverstar-oifoef-oifoef1/>
- Army University Press / NCO Journal, *Reaching the Finish Line*: <https://www.armyupress.army.mil/Journals/NCO-Journal/Muddy-Boots/Reaching-the-Finish-Line/>

### 4.2 Kartografische Arbeitsanker

Die in Dokument 49 verwendeten Ortsanker stammen aus Mapcarta-Seiten, die ihrerseits OpenStreetMap-/GeoNames-Daten ausweisen:

- Asmar: <https://mapcarta.com/14642088>
- Shal locality: <https://mapcarta.com/14597144>
- Dab locality: <https://mapcarta.com/14635250>

Arbeitskoordinaten:

```text
Asmar          35.033328, 71.358087
Shal locality  35.088560, 71.366070
Dab locality   35.096950, 71.354380
```

Diese Werte bezeichnen Orts-/Siedlungsanker. Sie belegen weder den Gipfel von Shal Mountain noch einen Hinterhalts-, IED- oder Außenpostenpunkt.

### 4.3 Status

```text
route name and Kunar corridor: HIGH
Asadabad–Asmar–Naray/Bostick functional segmentation: HIGH as project segmentation
exact segment boundary at Asmar: PROJECT_DECISION
Shal/Dab tactical sector: HIGH for general area
exact coordinates of mountain, valleys and incidents: UNCONFIRMED
```

## 5. MSR Vermont

### 5.1 Quellen

- PICRYL/DVIDS, ANA- und Koalitionskräfte an MSR Vermont im Tagab District: <https://picryl.com/media/soldiers-from-the-afghan-national-army-and-coalition-6f0301>
- DVIDS, *Checkpoint*, Checkpoint 5 entlang MSR Vermont: <https://www.dvidshub.net/image/75194/checkpoint>
- ImagesDéfense, *Opération Road Again*: <https://imagesdefense.gouv.fr/fr/operation-road-again.html>
- ImagesDéfense, *Reconnaissance du génie avec le GTIA Kapisa*: <https://imagesdefense.gouv.fr/fr/reconnaissance-du-genie-avec-le-gtia-kapisa.html>
- DVIDS, *PRT welcomes new governor of Kapisa*: <https://www.dvidshub.net/news/68420/prt-welcomes-new-governor-kapisa>
- Christophe Lafaye, *L’armée française en Afghanistan. Le Génie au combat. 2001–2012*, CNRS Éditions/Ministère de la Défense, 2016.

### 5.2 Status

```text
route name in Tagab/Kapisa: HIGH
name continuity into 2010/2011: HIGH
southern core between Naghlu area and FOB Tagab: MEDIUM-HIGH
exact full continuation to Nijrab: UNCONFIRMED
checkpoint coordinates and exact IED locations: UNCONFIRMED
```

## 6. MSR Oregon

### 6.1 Quellen

- Vereniging Officieren Artillerie, *AFGHANISTAN 2008 Main Supply Route (MSR) Oregon*: <https://voaweb.nl/afghanistan-2008-main-supply-route-msr-oregon/>
- U.S. Department of State, *Groundbreaking of the Kandahar to Tarin Kowt Road*: <https://2001-2009.state.gov/r/pa/ei/pix/b/sa/af/36146.htm>
- U.S. Army, *The first 100 days: a story of sustainment*: <https://www.army.mil/article/50711/the_first_100_daysa_story_of_sustainment>
- U.S. Army Corps of Engineers, *Route Bear highway*: <https://www.usace.army.mil/Media/News/Article/475345/usace-completes-major-section-of-route-bear-highway/>

### 6.2 Status

```text
MSR Oregon name in 2008: HIGH
Kandahar Airfield–Tarin Kowt endpoints: HIGH
corridor use in 2010/2011: HIGH
MSR Oregon name continuity in 2010/2011: UNCONFIRMED
identity with Route Bear: UNCONFIRMED
exact ambush valley and firing positions: UNKNOWN
```

## 7. Verwendungsregeln

1. Ein historisch belegter Routenname ist nicht automatisch eine meter-genaue PATHLINE.
2. Eine nationale Straßenbezeichnung wie `NH01` ist nicht automatisch mit einer ISAF-internen MSR-Abschnittsbezeichnung identisch.
3. Einzelne Hinterhalte oder IED-Suchen rechtfertigen ohne Georeferenzierung keinen punktgenauen `IED_`- oder `AMB_`-Marker.
4. Projektinterne Segmentgrenzen müssen als solche gekennzeichnet bleiben.
5. Technische DCS-Konvoitests validieren Befahrbarkeit und Routingverhalten, nicht historische Namens- oder Linienrichtigkeit.
6. Historische Altbranches dürfen beim Rebase oder Merge die aktuelle Main-Provenienz nicht zurücksetzen.

## 8. Offene Arbeit

- `MSR EAST-E3` als eigenen quellenqualifizierten Abschnitt in Dokument 49 konsolidieren;
- direkte historische Karte oder Overlay für die EAST-E3-Namenszuordnung suchen;
- Shal Mountain, Shal Valley, Dab Valley, COP Monti und ANA-Outpost georeferenzieren;
- MSR Vermont nördlich von FOB Tagab kartografisch und namensbezogen prüfen;
- MSR Oregon gegen 2010/2011-Karten, SPINS, Convoy-/Route-Clearance-Unterlagen oder SIGACTs prüfen;
- offene Draft-/Testbranches vor Merge auf Erhalt der Main-Dokumentation kontrollieren.
