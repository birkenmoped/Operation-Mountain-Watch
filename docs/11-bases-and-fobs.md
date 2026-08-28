---
document_id: OMW-BASES-FOBS
status: PLANNED
document_class: BASE_AND_FOB_MODEL
owning_policy: OMW-GOV-001
authoritative_for:
  - planned campaign functions and common metadata of bases, FOBs, COPs and checkpoints
  - planned Kunar and Nuristan ground-site reconciliation for existing mission templates
  - current ARMY Ground Foundation installation scope and parent relationships
not_authoritative_for:
  - active air ORBAT
  - final Mission Editor object state
  - final ground-force ORBAT or exact personnel strengths
  - final MOOSE BRIGADE topology
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - vertical-prototype-only base sequence
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
validated_in_dcs: false
---

# 11 – Basen, FOBs und Luftstützpunkte

## 1. Einordnung

Dieses Dokument beschreibt die geplanten Kampagnenfunktionen und gemeinsamen Datenfelder von Hauptbasen, Luftoperationsknoten, FOBs, COPs und Checkpoints.

Der vollständige frühere Basenentwurf bleibt unverändert erhalten:

- [`Legacy-Basen- und FOB-Planung`](evidence/source-records/legacy-11-bases-and-fobs.md)

Aktive Luftfahrzeugbestände und Staffeln stehen ausschließlich in:

- [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md)

Die vollständige historische Evidenz, Quellenklassifizierung und Abgrenzung von Stationierung, Detachment, FARP, Transit und einmaliger Nutzung steht in:

- [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION`](50-afghanistan-force-basing-aviation-2010-2011.md)

Der Juli-2011-ORBAT-Snapshot für Koalitionskampfkräfte steht in:

- [`OMW-HIST-AFGHANISTAN-ORBAT-2011-07`](64-afghanistan-order-of-battle-july-2011.md)

Konkrete Missionseditorzustände stehen in den basisbezogenen Manifesten und Acceptance-Berichten.

## 2. Gemeinsames Basenmodell

Jeder Standort erhält mindestens:

```text
locationId
displayName
baseClass
sectorId
missionEditorAnchors
campaignFunction
resourceCapacity
personnelAndGarrison
warehouse
roadAccess
airAccess
landingAndDropZones
repairAndMedicalCapabilities
defenseCapabilities
damageState
rebuildState
historicalSourceIds
evidenceClass
effectiveFrom
effectiveTo
stationingStatus
parentPoolId
sourceConflict
```

### 2.1 `stationingStatus`

Zulässige Werte:

```text
PERMANENT_HUB
LONG_TERM_DETACHMENT
ROTATIONAL_DETACHMENT
FARP
TRANSIT_DESTINATION
MISSION_STAGING
PZ_HLZ_ONLY
GROUND_BASE_ONLY
UNCONFIRMED
```

Verkehrsaufkommen oder eine einzelne Landung rechtfertigen kein `PERMANENT_HUB`.

## 3. Strategische Rollen

### Bagram

Strategisches Hauptquartier, Theaterreserven, schwere Wartung, Fighter-/Transportknoten und übergeordnete Luftoperationsbasis.

Historisch direkt beziehungsweise stark belegt sind:

- USAF-Fighter-, Airlift-, Electronic-Combat-, Reconnaissance- und Rescue-Strukturen am 30.09.2011;
- OH-58D-Sicherungs- und Aufklärungsbetrieb im Raum Bagram bereits im Mai 2010;
- CH-47-Elemente und General-Support-Aufgaben im Zeitraum;
- Craig Joint Theater Hospital als medizinischer Schwerpunkt im August 2010.

Die vollständigen Einheiten, Zeitangaben und Quellen stehen in Dokument 50.

### Kabul

Politischer und logistischer Rückraum, Personal- und Materialbewegung sowie alternative strategische Drehscheibe. USAF-/Air-Advisor-Strukturen sind am Stichtag 30.09.2011 belegt. Kabul ist nicht automatisch Heimatbasis jeder Quelle, die den Großraum pauschal als „Kabul“ bezeichnet.

### Jalalabad / FOB Fenty

Regionaler operativer und logistischer Knoten für Nangarhar, Laghman, Kunar und Nuristan mit Straße, Hubschrauber, QRF, CSAR und taktischem Lufttransport.

Historischer Kern:

- TF Lighthorse / 3-17 CAV bis zur Übergabe am 18.11.2010;
- TF Shooter / 6-6 CAV ab 18.11.2010;
- multifunktionaler Mix aus OH-58D, AH-64D, UH-60/MEDEVAC und CH-47;
- regionales Direct-Support- und General-Support-Tasking;
- Ausgangspunkt einer hochklassifizierten Spezialoperation am 02.05.2011.

Aktive OMW-Bestände bleiben ausschließlich Dokument 19 vorbehalten.

### Kandahar Airfield

Strategischer und regionaler Luftoperationsknoten für RC-South:

- Task Force Destiny / 101st CAB;
- 2-17 CAV OH-58D und lokale Wartungsfunktionen unmittelbar vor und innerhalb des OMW-Zeitraums;
- CH-47-Regionalpool mit vorgeschobenen Detachments;
- USAF-A-10-, Airlift-, MQ-1-/MQ-9- und Rescue-Präsenz am 30.09.2011.

### FOB Salerno / Khost

Regionaler RC-East-Aviation-Knoten und CH-47-Detachment-/Headquarters-Standort im Working-Paper-Nachweis. Die genaue lokale Luftfahrzeugstärke bleibt Forschungsgegenstand.

### FOB Shank

Vorgeschobener, hoch ausgelasteter CH-47-Standort:

- zwei CH-47 für eine dokumentierte Phase 2010;
- intensive Tag-/Nacht-Nutzung;
- hohe Platzhöhe und überwiegend hochgelegene HLZs;
- später Teil der B/7-158-Verteilung.

Die widersprüchliche Company-Bezeichnung wird nicht in diesem Basenmodell aufgelöst.

### FOB Sharana

Army-Aviation-/CH-47-Detachment- und Missionsknoten. Permanente Stärke und genaue organisatorische Zuordnung bleiben quellenabhängig.

### FOB Wolverine

Vorgeschobener Aviation- und Zabul-Knoten:

- OH-58D-Banshee-Detachment ab Anfang Juni 2010;
- Scout Weapons Team aus zwei OH-58D am 06.11.2010;
- CH-47-Platoon-/Detachment-Rolle 2011;
- lokale Kiowa-Wartungs- und Bewaffnungsfunktionen 2011.

### Tarinkot / Tarin Kowt

Vorgeschobener Detachment-Standort aus dem Kandahar-Regionalpool. CH-47-Platoon-Präsenz ist 2011 belegt. Andere lokale Luftfahrzeugmuster und exakte Bestände benötigen basisbezogene Quellen und Manifestentscheidungen.

### Shindand Air Base

Air-Advisor- und Ausbildungsstandort. Am 30.09.2011 sind 838 AEAG und 444 AEAS im USAF-zentrierten Stichtags-ORBAT genannt. Army-Aviation-Bestände werden daraus nicht abgeleitet.

### Vorgeschobene Standorte

FOBs, COPs und Checkpoints besitzen begrenzte Ressourcen, Fähigkeiten und Zufahrtsarten. Nicht jeder Standort unterstützt Fixed-Wing-Betrieb, Slingload, Luftabwurf oder ein eigenes AIRWING.

### 3.1 Aktueller ARMY-Ground-Foundation-Scope

Für die aktive BLUE-Ground-Foundation wird innerhalb des allgemeinen Standortkatalogs ein engerer Arbeitsraum verwendet. Die aktive Einheitenbaseline ist einheitlich **Juli 2011**; Installationsstatus und Schließungen werden weiterhin über den gesamten OMW-Zeitraum 01.08.2010–31.12.2011 bewertet.

Der reconciliierte GROUNDBASE-Scope umfasst sechs operative Ground-Domänen:

```text
Jalalabad / FOB Fenty
COP Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick
```

Für diesen Arbeitsstrang ausdrücklich außerhalb des aktuellen Spielfelds:

```text
FOB Salerno / Khost and adjacent ground sites
Camp Fiaz / Asadabad
```

Camp Fiaz wird nicht physisch aufgebaut; FOB Wright übernimmt den für OMW benötigten Asadabad-Knoten. Die historische `FARP`-Einordnung von Wright im Aviation-Kontext bleibt davon unberührt. Für den Ground-Foundation-Scope ist Wright zusätzlich als aktiver Support-/Security-Knoten vorgesehen; für Juli 2011 ist `1-14th Illinois Agribusiness Development Team` mit `Security Force Platoon` als konkreter Ground-Ansatz belegt. Die genaue Juli-2011-Artilleriezuordnung auf Wright bleibt offen und wird nicht aus dem 2010er M777-Nachweis fortgeschrieben.

Aktuelles operatives Installationsmodell:

```text
GROUND_NODE_JALALABAD
└── Jalalabad / FOB Fenty

GROUND_NODE_FORTRESS
└── COP Fortress

GROUND_NODE_JOYCE
└── FOB Joyce

GROUND_NODE_WRIGHT
└── FOB Wright

GROUND_NODE_HONAKER
└── COP Honaker-Miracle
    └── OP JoJo

GROUND_NODE_BOSTICK
└── FOB Bostick
    ├── OP Mustang
    ├── OP Clydesdale
    └── OP Stallion
```

Die sechs `GROUND_NODE_*`-IDs sind strategische CampaignState-Buchungsadressen und operative Domänenanker, keine historische Brigadegliederung. Die Ebenen bleiben strikt getrennt:

```text
Installation
!= historical formation
!= CampaignState resource node
!= MOOSE BRIGADE / PLATOON
!= physical DCS GROUP / ARMYGROUP
```

Support-parent-Beziehungen:

```text
GROUND_NODE_FORTRESS -> GROUND_NODE_JALALABAD
GROUND_NODE_JOYCE    -> GROUND_NODE_JALALABAD
GROUND_NODE_WRIGHT   -> GROUND_NODE_JALALABAD
GROUND_NODE_HONAKER  -> GROUND_NODE_JOYCE
GROUND_NODE_BOSTICK  -> GROUND_NODE_JALALABAD
```

Der Support-Parent ist keine zweite Ressourcenautorität und schreibt keinen zwingenden physischen Dispatch-Ursprung vor.

Für die aktuelle Juli-2011-Baseline gelten als belastbare Higher-HQ-/Battalion-Zuordnungen beziehungsweise 2011er Standortbelege:

```text
Jalalabad / FOB Fenty
  TF Bronco / 3rd BCT, 25th Infantry Division
  TF Steel / 3-7 Field Artillery

COP Fortress
  64th Military Police Company contingent assigned/based at COP Fortress in January 2011
  B Company / 2-327 Infantry / TF No Slack operational presence in March 2011

FOB Joyce
  TF Cacti / 2-35 Infantry

COP Honaker-Miracle
  D Company / 2-35 Infantry / TF Cacti 2011 operational presence
  retained Pech position / Hammer Down staging role

FOB Bostick
  TF Wolfhound / 2-27 Infantry

FOB Wright
  1-14th Illinois Agribusiness Development Team
  Security Force Platoon
```

Die konkrete Company-/Platoon-Zuordnung und physische DCS-Stärke ist damit nur dort festgelegt, wo die jeweilige Primärevidenz sie tatsächlich trägt.

CampaignState-Initialbestände für Fortress/Honaker sind durch `docs/ground/ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION.md` festgelegt und durch Acceptance 9-2 für die dokumentierte technische Provenienz bestätigt. Sie sind OMW-Designwerte und keine behaupteten historischen Tagesinventare.

#### OP-Parent-Regel

Ein OP ist keine eigenständige Ressourcenorganisation:

```text
OP active only if:
- assigned parent FOB/COP is active
  OR
- an explicit replacement parent is documented
```

Ein OP besitzt nicht automatisch einen eigenen Personnel Pool, ein eigenes Warehouse, einen eigenen QRF-Ursprung oder einen eigenen Patrol-Ursprung. Besatzung, Ablösung, Verstärkung und Versorgung binden Ressourcen des Parent-Ground-Nodes. `CampaignState` bleibt dafür die strategische Autorität.

Für Bostick sind Mustang, Clydesdale und Stallion als OMW-Overwatch-Kette geplant. `OP Mustang` ist im Februar 2011 als aktive Stellung durch C Troop / 1-32 Cavalry / TF Bandit belegt. Die Einordnung von Clydesdale und Stallion als abhängige Bostick-Overwatch-Positionen ist eine Missionsdesignentscheidung und wird nicht als Nachweis identischer Juli-2011-Besetzung formuliert.

Für Joyce/Honaker bleibt `OP JoJo` hinsichtlich der konkreten 2010/11-Besetzung `PROVISIONAL`; die geplante Parent-Beziehung über Honaker-Miracle erlaubt keine stärkere historische Behauptung.

## 4. Historisch qualifizierter Standortkatalog

| Standort | Klasse/Funktion | Historisch belegte Rolle | Evidenzquelle |
|---|---|---|---|
| Bagram Airfield | `PERMANENT_HUB` | strategischer Joint-/Army-/USAF-Knoten | Dokument 50, S05/S06/S09 |
| Jalalabad / FOB Fenty | `PERMANENT_HUB` | multifunktionale Army Aviation | Dokument 50, S08 |
| Kandahar Airfield | `PERMANENT_HUB` | RC-South Army Aviation und USAF | Dokument 50, S05/S06/S10/S12 |
| FOB Salerno | `LONG_TERM_DETACHMENT` | CH-47-/Army-Aviation-Knoten | Dokument 50, S05 |
| FOB Shank | `LONG_TERM_DETACHMENT` | kleiner CH-47-Standort | Dokument 50, S05 |
| FOB Sharana | `ROTATIONAL_DETACHMENT` | CH-47-/Army-Aviation-Knoten | Dokument 50, S05 |
| FOB Wolverine | `LONG_TERM_DETACHMENT` | OH-58D, später CH-47, Wartung | Dokument 50, S05/S14/S15 |
| Tarinkot | `LONG_TERM_DETACHMENT` | CH-47-Platoon aus Kandahar-Pool | Dokument 50, S05 |
| Camp Wright | `FARP` | 3-17 CAV Refuel/Rearm | Dokument 50 |
| FOB Wilson | `FARP` | 2-17 CAV Refuel/Rearm | Dokument 50, S13 |
| COP Sayed Abad | `MISSION_STAGING` | Talon-Purge-PZ/Aufnahmeraum | Dokument 50, S05 |
| FOB Howz-e Madad | `GROUND_BASE_ONLY` | Battalion-FOB und CH-47-Ziel/Versorgungsknoten | Dokument 50, S01/S05 |
| FOB Blessing | `GROUND_BASE_ONLY` | 2011 Übergabe/Aufgabe | Dokument 50, S01 |
| COP Fortress | `GROUND_BASE_ONLY` | aktiver Combat Outpost im Chawkay/Chowkay-Raum; 2011 MP-/Infanteriepräsenz und Steilfeuerkontext belegt | Ground-Resource-Decision / DVIDS-/Army-Evidenz |
| COP Honaker-Miracle | `GROUND_BASE_ONLY` | isolierter, gehaltener COP; 2011 TF-Cacti-/D-Co-Präsenz und Staging-Rolle | Dokument 50, S01; Ground-Resource-Decision |
| COP Stout | `GROUND_BASE_ONLY` | Hamkari-/Arghandab-Außenposten | Dokument 50, S01 |
| Außenposten Babur | `GROUND_BASE_ONLY` | nördlicher Folgeaußenposten, Name offen | Dokument 50, S01 |
| Patrol Base Dakota | `GROUND_BASE_ONLY` | Marjah Hold-/Build-Basis | Dokument 50, S01 |
| FOB Kunduz | `GROUND_BASE_ONLY` | 1-87 Infantry / RC-North | Dokument 50, S01 |
| FOB Pul-e-Khumri | `GROUND_BASE_ONLY` | 1-87 Infantry / RC-North | Dokument 50, S01 |
| FOB Bostick / früher FOB Naray | `GROUND_BASE_ONLY` | Juli 2011: TF Wolfhound / 2-27 Infantry, northern Kunar; 2010 zusätzlich nachgewiesene Cavalry- und Field-Artillery-Präsenz | Dokument 64; DVIDS 294427; DVIDS Story 52264 |

Diese Tabelle klassifiziert historische Funktionen. Sie ist keine Mission-Editor-Abnahme und legt keine aktiven Flugzeugzahlen fest.

### 4.1 Kunar-/Nuristan-Reconciliation der vorhandenen User-Templates

Die folgende Arbeitsbaseline erfasst die im Projekt bereits als DCS-User-Templates vorhandenen Kunar-/Nuristan-Stellungen sowie **FOB Bostick**, dessen manueller Aufbau durch den Projektinhaber am 16.08.2026 begonnen wurde. Ein Eintrag in dieser Tabelle genehmigt keine `.miz`-Änderung und keine konkrete Garnisonsstärke.

Statussemantik:

```text
ACTIVE
  im OMW-Zeitraum als aktive BLUE-Stellung belegt

PARTIAL
  innerhalb 01.08.2010–31.12.2011 aktiver und geschlossener/übergebener Zustand belegt

CLOSED_BEFORE_OMW
  vor 01.08.2010 als US-/Koalitionsstellung geschlossen

PROVISIONAL
  Existenz/Lage gestützt, exakte Belegung im OMW-Zeitraum noch offen

UNVERIFIED
  Template vorhanden, historische Identität oder Datierung noch nicht ausreichend bestätigt
```

| Standort / Template | Provinz / Raum | Reconciliation 01.08.2010–31.12.2011 | Arbeitsstatus für OMW | Bemerkung |
|---|---|---|---|---|
| COP Fortress | Kunar, Chawkay/Chowkay | 2011 aktive Stellung mit zugewiesenem 64th-MP-Kontingent und B/2-327-Operationsbezug bestätigt | `ACTIVE` | OMW canonical class `COP`; Fortress besitzt eigenen Ground stock node |
| FOB Joyce | Kunar, Chawkay | Juli 2011 TF Cacti / 2-35 Infantry laut Dokument 64; 2010 ebenfalls aktive Nutzung belegt | `ACTIVE` | regionaler Ground-Hub für southern Kunar |
| COP Honaker-Miracle | Kunar, Pech Valley | 2010/2011 aktive US-Stellung; 2011 D Co / 2-35 und Hammer-Down-Staging belegt | `ACTIVE` | eigener Ground stock node; Joyce bleibt Support-Parent |
| OP JoJo | Kunar, oberhalb Honaker-Miracle | OEF Base Tracker führt `OP Jojo` als `Outpost`; Lage unterstützt Overwatch-Beziehung | `PROVISIONAL` | Existenz/Lage gestützt; konkrete Besetzungsdaten 2010/11 noch offen |
| Firebase California | Kunar, Pech Valley | historische Existenz bestätigt; OMW-Zeitraum noch nicht ausreichend datiert | `PROVISIONAL` | keine konkrete Artillerie-/Mörserzuweisung ohne weiteren Nachweis |
| COP Michigan | Kunar, Pech Valley | Aug. 2010 aktiv; Ende März 2011 als US-Stellung geschlossen | `PARTIAL` | nach Schließung keine aktive US-Garnison; dokumentierte `mortar section` während Aktivzeit |
| Korengal Outpost / KOP | Kunar, Korengal Valley | US-Räumung im April 2010 | `CLOSED_BEFORE_OMW` | physische verlassene Stellung kann als historisches Terrainobjekt bestehen bleiben |
| OP 1, Korengal | Kunar, Korengal Valley | Bestandteil des früheren Korengal-Netzes; mit KOP vor OMW aufgegeben | `CLOSED_BEFORE_OMW` | historische Bezeichnung in Army-Studien gestützt |
| OP 2, Korengal | Kunar, Korengal Valley | Template vorhanden; kanonischer historischer Name bislang nicht bestätigt | `UNVERIFIED` | nicht als historisch benannter OP festschreiben, bis Identität geklärt ist |
| Firebase / OP Restrepo | Kunar, Korengal Valley | mit Korengal-Komplex vor OMW aufgegeben | `CLOSED_BEFORE_OMW` | historische Stellung bestätigt |
| Falcon Base / Bari Kot | Kunar, Nari/Naray border area | Basisexistenz 2010 gestützt; Spezial-/Partner-Force-Charakter | `ACTIVE` | als `SPECIAL_SITE`, nicht automatisch regulärer US-Army-FOB modellieren |
| OP Stallion | northern Kunar / Bostick sector | historische Existenz gestützt; genaue 2010/11-Belegung offen | `PROVISIONAL` | OMW plant die Parent-Beziehung zu Bostick; identische Juli-2011-Besetzung ist nicht belegt |
| OP Clydesdale | northern Kunar / Bostick sector | realer Standort gestützt; genaue 2010/11-Belegung offen | `PROVISIONAL` | OMW plant die Parent-Beziehung zu Bostick; identische Juli-2011-Besetzung ist nicht belegt |
| OP Mace | Kunar/Nuristan border sector | bis 21.12.2010 US-betrieben, danach ANA-Übernahme | `PARTIAL` | BLUE bleibt bestehen; Control/Owner wechselt US -> ANA |
| COP Keating / Kamdesh | Nuristan, Kamdesh | Schließung bereits Oktober 2009 angeordnet und nach Battle of Kamdesh aufgegeben | `CLOSED_BEFORE_OMW` | kein aktiver US-COP im OMW-Zeitraum |
| OP Fritsche | Nuristan, Kamdesh | gemeinsam mit Keating vor OMW geschlossen | `CLOSED_BEFORE_OMW` | Army belegt platoon-sized OP und 120-mm-Mortar-Fire-Support für 2009 |
| FOB Bostick / früher FOB Naray | Kunar, Naray/Nari | 2010 und Juli 2011 klar aktiv | `ACTIVE` | wird zusätzlich zum ursprünglichen User-Template-Bestand manuell durch den Projektinhaber aufgebaut |

### 4.2 FOB Bostick – Ground-Foundation-Arbeitsstand

FOB Bostick wird ab diesem Stand ausdrücklich in die Ground-Foundation aufgenommen. Der Standort hieß zuvor FOB Naray und liegt im Naray/Nari-Sektor von northern Kunar.

#### 4.2.1 Juli-2011-Referenz

Dokument 64 bestätigt für Juli 2011:

```text
TF Bronco / 3rd BCT, 25th Infantry Division
└── TF Wolfhound / 2-27 Infantry
    └── FOB Bostick, Naray
        └── operating in northern Kunar
```

Diese Zuordnung ist für den Juli-2011-Snapshot belastbar. Sie wird nicht automatisch als vollständige lokale Personal- oder Fahrzeugstärke interpretiert.

#### 4.2.2 Direkt belegte 2010er Präsenz

DVIDS Photo ID 294427 vom 17.06.2010 belegt auf FOB Bostick:

```text
Charlie Troop
1st Squadron, 32nd Cavalry Regiment
Task Force Bandit
```

Damit ist die aktive Nutzung durch `1-32 Cavalry` im OMW-Zeitraum unmittelbar nachgewiesen.

DVIDS Story 52264 vom 01.07.2010 beschreibt `Bravo Battery, 3rd Battalion, 321st Field Artillery Regiment` mit verteilten Platoons unter anderem auf FOB Bostick. Die Quelle nennt für diese Battery ausdrücklich den Einsatz des **M777** und Excalibur-Fähigkeit.

```text
B/3-321 Field Artillery
└── platoon element at FOB Bostick
    └── M777 155-mm towed artillery capability documented for the battery
```

Die Quelle bestätigt damit Artilleriepräsenz und M777-Fähigkeit. Sie wird nicht als Beweis für eine konkrete Zahl gleichzeitig auf Bostick stehender Geschütze interpretiert.

#### 4.2.3 Sekundäre Rotationsliste

Die vom Projektinhaber bereitgestellte Alchetron-Zusammenstellung `Forward Operating Base Bostick` enthält eine umfangreichere Einheiten-/Zeitraumliste als die einzelne DVIDS-Fotocaption und bleibt deshalb als **sekundärer Research Index** erhalten. Sie darf Primärquellen nicht überschreiben. Im Projektgespräch wurden daraus insbesondere folgende für den OMW-Zeitraum relevante Rotationen identifiziert:

```text
2010-2011
1st Squadron, 32nd Cavalry Regiment

March 2011-2012
2nd Battalion, 27th Infantry Regiment

2011-2012
1st Battalion, 377th Field Artillery Regiment
```

Diese Sekundärangaben werden für die Suche nach Primärquellen verwendet. Die Juli-2011-Zuordnung `2-27 Infantry -> FOB Bostick` ist unabhängig durch Dokument 64 bestätigt. Detailangaben zu Unterkompanien, exakten Stärken und der lokalen 2011er Artilleriegliederung bleiben zu verifizieren.

#### 4.2.4 DCS-Artillerieabbildung

Historisch nachgewiesen ist 2010 eine **M777-155-mm-Feldartilleriefähigkeit** im Bostick-Detachment-Kontext. DCS stellt im aktuell diskutierten BLUE-Bestand keinen M777 bereit. Verfügbare Kandidaten sind unter anderem:

```text
2B11 mortar
L118 Light Gun
M109 Paladin
M270 MLRS
```

Für Bostick gilt deshalb vorläufig:

```text
historical_system = M777
exact_DCS_equivalent = NONE
proxy_decision = OPEN
```

`L118` ist aufgrund der gezogenen/light-artillery-Charakteristik ein möglicher technischer Proxy, bildet aber weder Kaliber noch Reichweite des M777 korrekt ab. `M109` bildet die 155-mm-Klasse besser ab, wäre jedoch als selbstfahrende Kettenhaubitze physisch und logistisch eine deutlich andere Darstellung. Eine endgültige Proxy-Entscheidung ist eine Missionsdesignentscheidung des Projektinhabers und wird nicht durch dieses Dokument vorweggenommen.

### 4.3 Quellen für die Kunar-/Nuristan-Reconciliation

Primäre beziehungsweise projektinterne starke Referenzen:

- [`OMW-HIST-AFGHANISTAN-ORBAT-2011-07`](64-afghanistan-order-of-battle-july-2011.md) – Juli-2011-ORBAT mit `TF Wolfhound / 2-27 Infantry -> FOB Bostick` und `TF Cacti / 2-35 Infantry -> FOB Joyce`.
- U.S. Army, Staff Sergeant Ty Michael Carter Medal of Honor battlescape: <https://www.army.mil/medalofhonor/carter/> – COP Keating, OP Fritsche, Nuristan, OP-Größe und 120-mm-Mortar-Fire-Support; Schließungsentscheidung Oktober 2009.
- DVIDS Photo ID 294427, *Cavalry Soldiers Maintain Their Zero at FOB Bostick*, 17.06.2010: <https://www.dvidshub.net/image/294427/cavalry-soldiers-maintain-their-zero-fob-bostick> – `C/1-32 Cavalry`, TF Bandit, FOB Bostick.
- DVIDS Story 52264, *Top Chi reaches out, touches insurgent forces*, 01.07.2010: <https://www.dvidshub.net/news/52264/top-chi-reaches-out-touches-insurgent-forces> – `B/3-321 Field Artillery`, Platoon-Verteilung einschließlich FOB Bostick, M777-/Excalibur-Kontext.
- OEF Base Tracker / ArcGIS: <https://experience.arcgis.com/experience/11ea962acdac4706a172d72f5de85781/> – geographischer Datensatz unter anderem für `OP Jojo`; Datensatz dient als Geolokations-/Namenshinweis, nicht allein als Beleg für 2010/11-Belegung.

Vom Projektinhaber bereitgestellte ergänzende Sekundärquellen für Bostick:

- Alchetron, *Forward Operating Base Bostick*: <https://alchetron.com/Forward-Operating-Base-Bostick> – aggregierte Einheiten-/Rotationsliste; als Research Index zu behandeln und gegen Primärquellen zu prüfen.
- Alamy-Fotoseite zu Soldaten von Bravo Company/Battery, 3rd Battalion, 321st Field Artillery: <https://www.alamy.com/stock-photo-us-soldiers-from-bravo-company-3rd-battalion-321st-field-artillery-129496238.html> – ergänzender Bild-/Caption-Hinweis; Primärnachweis wird bevorzugt aus DVIDS/DoD abgeleitet.

Für `Firebase California`, `OP Stallion`, `OP Clydesdale`, `OP 2` und die exakten Besetzungsdaten von `OP JoJo` bleibt die Reconciliation ausdrücklich offen. Diese Punkte dürfen nicht aus Template-Namen oder geografischer Plausibilität allein als aktive 2011er OMW-Garnisonen abgeleitet werden.

## 5. Stationierungskriterien

Ein Standort gilt erst als Aviation-Stationierung, wenn mindestens ein starker Nachweis vorliegt:

- Einheit oder Detachment ausdrücklich am Standort genannt;
- Crew Chiefs, Armament, Wartung oder Operationspersonal lokal belegt;
- längere split-based-Zuordnung;
- Hauptquartier oder Direct-Support-Auftrag am Standort;
- wiederholte lokale Nutzung mit Bestandsbezug.

Nicht ausreichend:

- einzelne Landung oder Betankung;
- einmaliger Air Assault;
- DCS-Parkplatzkapazität;
- Satellitenbild ohne Einheitsidentifikation;
- Verkehrsvolumen ohne lokale Zuordnung.

## 6. Zulässige Lieferverfahren

Pro Standort ausdrücklich konfigurieren:

```text
ROAD_CONVOY
HELICOPTER_INTERNAL
HELICOPTER_SLING
FIXED_WING_LANDED
FIXED_WING_AIRDROP
```

Zusätzlich können für Aviation-Knoten vorgesehen werden:

```text
FARP_REFUEL
FARP_REARM
AOG_PARTS_DELIVERY
DOWNED_AIRCRAFT_RECOVERY
MEDEVAC_TRANSFER
```

Diese Funktionen benötigen eigene Ressourcen-, Übergabe- und Acceptance-Regeln.

## 7. Foundation-Build-Anforderungen

- Standort und DCS-Anker validieren;
- Warehouse- und Ressourcenmodell festlegen;
- Zufahrten, Parkplätze und Landezonen prüfen;
- Garnison, Verteidigung und Bereitschaft definieren;
- Schadens- und Wiederaufbaustufen modellieren;
- basisbezogene Manifeste und Testfälle anlegen;
- historische Quellen-ID und Evidenzklasse eintragen;
- Detachments vom Parent-Pool abziehen;
- Stationierung, FARP, Transit und Missionsstaging getrennt halten;
- keine ORBAT-Zahlen aus dieser allgemeinen Planung ableiten.
