---
document_id: OMW-HIST-AIR-SOF-INTEL-METRICS-SOURCE-REVIEW
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - source-qualified review of the AV-8B OEF source for 2010-2011 Kandahar operations
  - source-qualified early-OEF F-14 and Takur Ghar TTP background
  - source-qualified COIN intelligence and metrics design principles from the 2008 RAND study
  - evidence limits separating historical source material from active OMW ORBAT and runtime design decisions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by:
source_branch: docs/afghanistan-force-aviation-source-consolidation
source_commit: GIT_HISTORY
validated_in_dcs: false
document_class: HISTORICAL_SOURCE_REVIEW
---

# AV-8B, F-14, Takur Ghar sowie Intelligence-/Metrics-Quellenreview

## 1. Zweck und Autoritätsgrenze

Dieses Dokument wertet vier vom Projektinhaber bereitgestellte Publikationen für **Operation Mountain Watch (OMW)** aus:

1. Lon Nordeen, *AV-8B Harrier II Units of Operation Enduring Freedom*, Osprey Combat Aircraft 104.
2. Tony Holmes, *F-14 Tomcat Units of Operation Enduring Freedom*, Osprey Combat Aircraft 70, 2008.
3. Leigh Neville, *Takur Ghar: The SEALs and Rangers on Roberts Ridge, Afghanistan 2002*.
4. Russell W. Glenn und S. Jamie Gayton, *Intelligence Operations and Metrics in Iraq and Afghanistan: Fourth in a Series of Joint Urban Operations and Counterinsurgency Studies*, RAND National Defense Research Institute, November 2008.

Die historische Evidenz steht gemäß `OMW-GOV-001` unter der aktuellen Projekt-Governance, den `BINDING_PROJECT_DECISION`- und `BINDING`-Baselines auf `main` sowie den exakt dokumentierten DCS-Acceptance-Ständen. Insbesondere erzeugt keine der vier Quellen automatisch eine aktive OMW-ORBAT-, Bestands-, Payload-, Missionseditor- oder Runtime-Entscheidung.

Für dieses Review gelten folgende Evidenzklassen:

- `IN_PERIOD_SECONDARY`: Sekundärquelle mit explizitem Bezug auf 01.08.2010–31.12.2011.
- `PRE_PERIOD_CONTINUITY`: unmittelbar vorausgehende Praxis oder Entwicklung mit möglicher Kontinuität in den OMW-Zeitraum, ohne den Zustand 2010–2011 allein zu beweisen.
- `TYPE_TTP_BACKGROUND`: zeitübergreifende Technik-, TTP- oder Organisationsreferenz ohne konkrete OMW-ORBAT-Wirkung.
- `BACKGROUND_ONLY`: außerhalb des Kampagnenzeitraums liegender historischer Kontext.
- `SOURCE_CONFLICT`: interne oder quellenübergreifende Unstimmigkeit, die OMW nicht stillschweigend auflöst.

**Governance-Hinweis:** Die derzeit autoritative aktive Kandahar-Air-ORBAT führt gemäß `OMW-GOV-001` die **74th Expeditionary Fighter Squadron mit 16 A-10C**. Die hier dokumentierten Harrier-Rotationen sind historische Evidenz und ändern diese Projektentscheidung nicht.

## 2. Quellenbewertung

| ID | Quelle | Zeitlicher Wert | OMW-Wert | Hauptgrenze |
|---|---|---|---|---|
| `NORDEEN-AV8B-OEF` | Lon Nordeen, *AV-8B Harrier II Units of Operation Enduring Freedom* | direkte 2011-Evidenz plus frühere/spätere Vergleichsphasen | **hoch** für Kandahar 2011, Missionsrhythmus, ISR/CAS, Loadout- und Rotationskontext | Sekundärquelle; keine automatische aktive OMW-ORBAT |
| `HOLMES-F14-OEF` | Tony Holmes, *F-14 Tomcat Units of Operation Enduring Freedom*, 2008 | frühe OEF 2001–2002 | **mittel** als Air-C2-, FAC(A)-, AAR-, TARPS-/ISR- und CAS-Hintergrund | vollständig außerhalb OMW-Zeitraum; F-14 nicht als OMW-Airframe ableiten |
| `NEVILLE-TAKUR-GHAR` | Leigh Neville, *Takur Ghar* | Operation Anaconda, März 2002 | **hoch** als Gebirgs-, Air-Assault-, SOF-Recon- und C2-Lernreferenz | vollständig außerhalb OMW-Zeitraum; keine 2010–2011-ORBAT daraus ableiten |
| `GLENN-GAYTON-INTEL-METRICS` | RAND NDRI, November 2008 | Afghanistan-/Iraq-COIN-Erfahrung bis 2007/2008 | **hoch** als Intelligence-, Daten-, Assessment- und Metrics-Designreferenz | Synthese aus Interviews und Literatur; keine exakte 2010–2011-Organisation oder Stärke |

## 3. AV-8B Harrier II: direkte Kandahar-Evidenz 2011

### 3.1 Historische Rotationen im OMW-Zeitraum

Nordeens Appendix weist für den OMW-Zeitraum zwei unmittelbar relevante USMC-Harrier-Rotationen in Kandahar aus:

| Einheit | Zeitraum laut Appendix | Standort | Evidenzklasse |
|---|---|---|---|
| VMA-513 `Nightmares` | 21.05.2011–15.11.2011 | Kandahar | `IN_PERIOD_SECONDARY` |
| VMA-223 `Bulldogs` | 31.10.2011–07.05.2012 | Kandahar | `IN_PERIOD_SECONDARY` für 31.10.–31.12.2011 |

VMA-231 war vom 05.11.2009 bis 09.05.2010 in Kandahar und liegt damit vollständig vor OMW; seine Erfahrungen werden nur als `PRE_PERIOD_CONTINUITY` genutzt. Frühere beziehungsweise spätere VMA-211-, VMA-214-, VMA-311-, VMA-542- und weitere Einsätze bleiben außerhalb des OMW-Zeitraums, sofern nicht ausdrücklich anders gekennzeichnet.

### 3.2 Von Nordeen gelistete Airframes

Für VMA-513 in Kandahar, Mai bis November 2011, listet die Appendix folgende zehn BuNos:

`163883`, `164128`, `164159`, `164571`, `165380`, `165567`, `165574`, `165580`, `165591`, `165595`.

Für VMA-223 in Kandahar, Oktober 2011 bis Mai 2012, listet die Appendix:

`165307`, `165309`, `165357`, `165384`, `165386`, `165388`, `165593`, `165596`, `165597`, `166288`.

Diese Listen sind **historische Rotations-/Airframe-Evidenz**. Sie sind nicht gleichzusetzen mit gleichzeitig einsatzbereiter Stärke, OMW-Warehouse-Bestand, Client-Pool, KI-Pool oder virtueller Reserve.

### 3.3 VMA-513: Stärke, Modifikation und Einsatzvorbereitung

Nordeen beschreibt für den 2011er Einsatz von VMA-513:

- zehn eingesetzte AV-8B;
- 17 Piloten und einen vollständigen Maintenance-Anteil;
- alle zehn Jets wurden vor dem Einsatz für die **centerline/belly carriage des Litening-II-Pods** umgerüstet;
- diese Konfiguration erhöhte die Waffenflexibilität, weil der Targeting Pod keinen Unterflügel-Waffenplatz mehr belegte;
- als operativ wahrnehmbarer Vergleich wird beschrieben, dass die Harrier damit zwei Bomben und zwei externe Tanks mitführen konnten, also eine für die Ablösung der zuvor eingesetzten Hornets wichtige vergleichbare Waffen-/Tankkonfiguration;
- die Quelle berichtet, dass zunächst Bedenken bestanden, zwölf F/A-18C durch zehn AV-8B zu ersetzen; die veränderte Konfiguration war ein Teil der Begründung, warum der kleinere Harrier-Verband den Auftrag übernehmen konnte.

OMW übernimmt daraus keine automatische Staffelstärke und keine DCS-Payload. Verwertbar ist die Evidenz für **Maintenance-/Upgrade-Abhängigkeit, Konfigurationswirkung auf Stationsnutzung und den Zusammenhang zwischen Sensorintegration und Missionsflexibilität**.

### 3.4 Typische 2011er Harrier-Konfigurationen

Die Farbtafeln und Bildbeschreibungen liefern für VMA-513 konkrete in-period Konfigurationsbeispiele:

- BuNo `165574`: GBU-38 JDAM unter einer Tragfläche; als typische Gegenstation nennt die Quelle GBU-12 oder einen 5-inch-Rocket-Pod; dazu GAU-12-25-mm-Gun-Pods und zentral montierter Litening-II-Pod.
- BuNo `165580`: GBU-54 500-lb Laser JDAM an einer Außenstation; die Quelle ordnet den erstmaligen Harrier-II-Kampfeinsatz dieses Waffentyps dem 2011er Afghanistan-Einsatz zu.

**Quellenkonflikt:** Eine Bildtafel bezeichnet diesen Combat Debut an einer Stelle als Teil einer „VMA-214 2011“-Deployment-Angabe, während die Deployment-Appendix VMA-214 nur 2009 in Kandahar führt und die operative Darstellung den GBU-54-Einsatz VMA-513 im Juli 2011 zuordnet. OMW behandelt daher die Staffelbezeichnung in der Bildtafel als `SOURCE_CONFLICT`. Belastbar ist: **GBU-54/Harrier combat use in Afghanistan 2011**; die interne Quellenchronologie stützt VMA-513, nicht eine 2011er VMA-214-Rotation.

Keine dieser Angaben überschreibt den bestehenden OMW-Loadout-Vertrag oder Weapon-Store-Bestand.

### 3.5 Tagesrhythmus und Sortiedauer

Für VMA-513 beschreibt Nordeen einen regulären OEF-Tagesrhythmus von drei Zyklen mit jeweils zwei Flugzeugen:

- Morning cycle: häufig ungefähr fünf Stunden je Flugzeug;
- Midday cycle: typischerweise etwa 3 bis 3,5 Stunden;
- Evening/night cycle: häufig wiederum ungefähr fünf Stunden;
- spätere Nachtmissionen wurden bei Bedarf zusätzlich geflogen, unter anderem zur Unterstützung von Special Forces.

Der Einsatzrhythmus wurde bewusst an beobachtete Aktivitätsmuster angepasst; die Quelle beschreibt höhere Taliban-Aktivität um Sonnenaufgang und Sonnenuntergang und vergleichsweise geringere Aktivität tief in der Nacht.

Für OMW ist dies eine **Missionsdesignreferenz**, nicht ein festes Scheduler-Schema. Ein späterer Commander/AIRWING-Tasking-Entwurf darf daraus variable Nachfragefenster, längere On-Station-/Transitzeiten und lageabhängige Nachtaufträge ableiten, aber keine starre dreimal-tägliche Produktionsregel ohne gesonderte Projektentscheidung.

### 3.6 Operation Eastern Storm und integrierte Feuerunterstützung

Ende Oktober 2011 unterstützte VMA-513 **Operation Eastern Storm** in Sangin und Kajaki. Die Quelle beschreibt eine synchronisierte Aviation-Unterstützung gemeinsam mit MAGTF-Artillerie. Für OMW bestätigt dies die historische Plausibilität folgender Missionsmuster:

- CAS als Teil einer kombinierten Ground-/Fires-/Aviation-Lage;
- parallele beziehungsweise abgestimmte Artillerie- und Luftunterstützung;
- priorisierte Unterstützung von Bodeneinheiten in intensiven Clear-/Combat-Phasen;
- Luftoperationen nicht als isolierte „Strike-Slots“, sondern als Bestandteil eines synchronisierten Operationsplans.

### 3.7 VMA-513 Einsatzkennzahlen

Bis zum Abflug am 15.11.2011 nennt Nordeen für VMA-513:

- **4033,8 combat flight hours**;
- **2261 sorties**;
- Unterstützung von **2145 JTARs**;
- **81 PGMs** mit zusammen **64.647 lb**;
- **4737 Schuss 25 mm** in **50 strafing runs**;
- **59 show-of-force flybys**;
- Unterstützung des Verbandes durch **MALS-13**.

Diese Werte sind historische **Output-/Activity-Metriken** einer realen Rotation. Sie sind keine OMW-Balancing-Vorgaben und dürfen nicht als Zielverbrauch oder Sollsortierate in CampaignState oder Warehouse übernommen werden.

### 3.8 VMA-223: Übergabe Ende 2011

Etwa zwei Wochen vor dem Abflug von VMA-513 traf die Ablösung mit zehn VMA-223-Harriers ein. Nordeen beschreibt eine sehr schnelle Combat-Einführung während Eastern Storm. Für die ersten 51 Tage werden genannt:

- **288 combat sorties**;
- **1203 flying hours**.

Besonders relevant für OMW ist die Missionsbeschreibung: Ein großer Teil der Flugzeit wurde nicht für Waffenabwurf verwendet, sondern zum **Absuchen langer unbefestigter Straßenabschnitte mit dem Litening-II-Pod nach verdächtigen Aktivitäten**, insbesondere im IED-/Route-Overwatch-Kontext. Dies stützt eine missionsdesignerische Trennung zwischen:

- persistentem oder wiederkehrendem Route/Convoy Overwatch;
- ISR-/armed-reconnaissance-artiger Suche;
- Troops-in-Contact-Reaktion;
- kinetischer Wirkung nur bei ausreichender Identifikation und Freigabe.

### 3.9 VMA-231 als unmittelbare Vorperiodenreferenz

VMA-231 lag mit November 2009 bis Mai 2010 knapp vor dem OMW-Zeitraum und ist daher `PRE_PERIOD_CONTINUITY`.

Verwertbare Punkte:

- Der Verband war mit zehn AV-8B in Kandahar eingesetzt.
- Ab Januar 2010 wurden einzelne Harriers vom ausgebauten **Camp Dwyer** eingesetzt.
- Für die Fixed-Wing-Nutzung wurden dort Runway, North Parking Ramp, **Tactical Airfield Fuel Dispensing System** und verbindende Taxiways erweitert.
- Ziel der Infrastruktur war kürzere Refuel-/Rearm-Zeit und mehr verfügbare Unterstützungszeit für Bodentruppen.
- Litening-II-Sensorik wurde für Overwatch von ISAF-Patrouillen und die Reaktion auf TICs beziehungsweise IED-Ereignisse genutzt.
- ROVER erlaubte Ground FACs, das Targeting-Pod-Bild mitzuverfolgen und Angriffe auch noch abzubrechen, wenn Friendlies oder Zivilisten in den Zielraum gelangten.
- UAS wurden stark für Target Identification genutzt; die Quelle bewertet deren Sensor-Dwell-Time gegenüber dem Harrier als überlegen.
- Mit zunehmend restriktiven ROE wurde in bestimmten Lagen der 25-mm-Gun gegenüber mitgeführten Bomben häufiger tatsächlich eingesetzt.
- Für die sechsmonatige Rotation nennt die Quelle über 8000 Flugstunden, mehr als 100 named operations, mehr als 750 JTARs, über 4600 Schuss 25 mm, fünf abgeworfene LGBs und 41 CAS attacks.

Diese Daten belegen **kein** identisches Verhalten ab August 2010. Sie sind unmittelbarer Vorperiodenkontext für USMC-Air-Support-, Sensor-, ROVER-, UAS- und Expeditionary-Basing-Praktiken.

## 4. F-14 Tomcat: frühe OEF-Luftoperationsreferenz

Holmes behandelt die frühe OEF-Phase 2001–2002 und liegt vollständig außerhalb des OMW-Zeitraums. Der Band wird deshalb nur als `BACKGROUND_ONLY` beziehungsweise `TYPE_TTP_BACKGROUND` verwendet.

Aus den Kapiteln *Build-up to War*, *OEF Begins*, *Ground War* und *Operation Anaconda* sind für OMW folgende Muster verwertbar:

- Carrier-basierte TACAIR musste wegen der großen Entfernung zu Afghanistan auf wiederholte **Aerial Refueling**-Unterstützung zurückgreifen.
- Tanker-Verfügbarkeit, Wetter und verfügbare Divert-Möglichkeiten beeinflussten Missionsroute, Zeitplanung und Rückkehrreserven.
- F-14 wurden in OEF neben Strike auch für **TARPS tactical reconnaissance**, armed reconnaissance, CAS-Unterstützung und später verstärkt **FAC(A)** eingesetzt.
- LANTIRN ermöglichte Zielsuche, Identifikation, Laserführung und die Unterstützung präzisionsgelenkter Waffen.
- TARPS-Aufklärung erzeugte Bildmaterial, das nach Rückkehr ausgewertet und in weitere Targeting-/Operationsprozesse eingespeist wurde.
- CAOC, AWACS, Tanker, FAC/SOF und Strike-Aircraft bildeten eine vernetzte C2-Kette; die Wirksamkeit hing von korrekter Zielinformation, Frequenzen, Deconfliction und Freigabe ab.
- Mit dem Übergang vom anfänglichen Fixed-Target-Schwerpunkt zur Ground-War-Phase nahm der Bedarf an dynamischer Zielsuche, FAC(A), Reattack-Entscheidungen und engerer Ground-Air-Koordination zu.
- Electronic-attack-/support-Aircraft und situative Jamming-Unterstützung waren Teil der frühen Pakete; dies ist eine historische Air-C2-/EW-Referenz, keine Aussage über eine konkrete OMW-EW-ORBAT.

**OMW-Grenze:** Aus dieser Quelle wird weder eine F-14-Staffel noch ein F-14-Client, Warehouse-Bestand oder 2010–2011-Carrier-Air-Wing abgeleitet. Der Wert liegt ausschließlich in den **AAR-, ISR-, FAC(A)-, Targeting-, C2- und dynamischen CAS/TARPS-Mustern**.

## 5. Takur Ghar / Operation Anaconda: SOF, Hochgebirge, Air Assault und C2

Nevilles Werk behandelt März 2002 und ist damit vollständig außerhalb des OMW-Zeitraums. Seine Analyse ist dennoch eine starke `TYPE_TTP_BACKGROUND`-Quelle für Afghanistan-spezifische Gebirgs- und C2-Probleme.

### 5.1 Gelände, Höhe und Air-Assault-Planung

Takur Ghar wird mit ungefähr **10.469 ft** Höhe beschrieben. Für die Lower-Shahikot-Operation begrenzten Gelände und Höhe die nutzbaren Anflugkorridore. Die Planung verdeutlicht:

- Luftkorridore können durch Topographie stark vorhersehbar und damit für gegnerische Heavy Weapons gefährlich werden;
- SOF plädierten für **offset HLZs**, um Überraschung und Survivability zu verbessern;
- die konventionelle Seite bewertete dagegen Traglast, Marschleistung im Schnee und die Verfügbarkeit von Attack-Aviation-Unterstützung;
- für die eigentliche Insertion wurden CH-47D verwendet; die Quelle begründet dies unter anderem mit HLZ-Höhen um 8500 ft, bei denen ein voll beladener UH-60 für den vorgesehenen Auftrag nicht ausreichend geeignet gewesen sei;
- sechs AH-64A unterstützten den Plan; darüber hinaus war die eingesetzte Infanterie stark auf externe Air/Fires-Unterstützung angewiesen.

Diese historischen Performance-Aussagen sind **keine DCS-Leistungsdaten**. Für OMW folgt daraus nur die Designregel, LZ, Route, Höhe, Last und Bedrohung als zusammenhängendes Problem zu behandeln und Insertionen nicht allein anhand Kartenentfernung zu planen.

### 5.2 AFO-Reconnaissance und Pattern of Life

Neville beschreibt vor Operation Anaconda verdeckte Reconnaissance durch Advanced Force Operations (AFO):

- environmental reconnaissance zur Bewertung von Gelände, Schnee, Wasser, Wetter und Zugänglichkeit;
- längerfristige **pattern-of-life surveillance**;
- lokale 4WD-Toyota-Fahrzeuge für Route Reconnaissance;
- angepasste Polaris-ATVs mit IR-Scheinwerfern, GPS und gedämpften Abgasanlagen;
- sehr kleine Teams in schwierigem Gelände und extremer Witterung;
- verdeckte Observation Posts rund um den Operationsraum;
- Rückführung der Beobachtungen an Headquarters und spätere Nutzung derselben Teams zur CAS-/Targeting-Unterstützung.

Für OMW ist dies eine starke historische Referenz für **RECCE vor kinetischer Aktion**, kleine Beobachtungselemente, terrain-/weather-aware Infiltration und den Übergang von Reconnaissance zu Target Support. Eine konkrete MOOSE-Implementierung ist daraus nicht vorgegeben.

### 5.3 Communications und technische Redundanz

Nevilles Analyse bewertet Technik ausdrücklich als zugleich großen Vorteil und mögliche Schwachstelle. Dokumentiert werden unter anderem:

- SATCOM-Ausfälle in kritischen Phasen;
- fehlende beziehungsweise nicht abgestimmte Frequenzen;
- Line-of-Sight-Grenzen von Handfunkgeräten;
- Verwirrung über Kommunikationsprotokolle und Air-C2;
- ein Fall, in dem falsche HLZ-Koordinaten über eine Relay-Kette weitergegeben wurden;
- nach Stromausfall eines MH-47E waren elektrisch angetriebene Miniguns nicht mehr nutzbar; die Quelle beschreibt daraus entstandene spätere technische Redundanzmaßnahmen.

OMW-Designfolge: Kritische Transport-/CSAR-/SOF-Szenarien sollten nicht von **einem** Funkpfad, einem Sensorfeed, einem Koordinatengeber oder einer einzelnen C2-Rolle abhängen. Dies ist eine Designreferenz, keine Anweisung, reale Kommunikationsausfälle oder eine bestimmte Avionik technisch nachzubauen.

### 5.4 C2 als zentrales Lessons-Learned-Thema

Nevilles Schlussanalyse bezeichnet die verwirrte Command-and-Control-Struktur als einen der folgenreichsten Faktoren:

- taktische Entscheidungen wurden teilweise weit vom physischen Battlespace getroffen;
- conventional forces, Air Force und „white“ SOF lagen anfangs in getrennten Command-Strukturen;
- Task Force 11 blieb nochmals separat;
- falsche beziehungsweise verspätete Lageinformationen verschärften die Probleme;
- die hohe Dichte gleichzeitig verfügbarer CAS-Assets erzeugte selbst zusätzliche Deconfliction-/C2-Anforderungen.

Für OMW ist daraus keine historische Task-Force-Struktur für 2010–2011 abzuleiten. Verwertbar ist das Architekturprinzip: **mehr Assets sind ohne kohärente C2-, Informations- und Priorisierungslogik nicht automatisch mehr Kampfkraft**.

### 5.5 Fires/CAS-Mix und adaptive Unterstützung

Die Takur-Ghar-Darstellung zeigt einen heterogenen Support-Mix aus AC-130, F/A-18, B-52, französischen Mirage, AH-1W und weiteren Assets. Die Wirkung reichte von direkter CAS über Bunker-/Mortar-Suppression bis zur Sicherung von Extraction/CASEVAC-Fenstern.

OMW kann daraus Missionsmuster ableiten:

- Air support für Insertion/Extraction;
- Airborne overwatch über gefährdeten HLZs;
- unmittelbarer Wechsel zwischen ISR, suppression und precision strike;
- Priorisierung knapper Air Assets bei mehreren gleichzeitigen Ground Contacts;
- Abbruch beziehungsweise Umplanung bei unklarer Friendly-/Enemy-Lage.

## 6. RAND 2008: Intelligence Operations und Metrics

### 6.1 Quellencharakter und Nutzungslimit

Die RAND-Studie wurde für U.S. Joint Forces Command erstellt und im November 2008 veröffentlicht. Sie ist eine Synthese aus Interviews, schriftlichen Quellen und vorheriger RAND-/COIN-Arbeit. Die Autoren erklären ausdrücklich, dass das Werk **keine vollständige Bestandsaufnahme** aller Intelligence-, Metrics- oder COIN-Fragen sein soll; einzelne Issue-Discussion-Recommendation-Einträge können die Sicht einzelner oder mehrerer Interviewpartner wiedergeben.

Die bereitgestellte Fassung trägt die Kennzeichnung `UNCLASSIFIED//FOR OFFICIAL USE ONLY//REL TO USA/AUS/NZL/ISR/NATO`. OMW übernimmt deshalb ausschließlich quellenkritisch paraphrasierte Projekterkenntnisse und reproduziert keine unnötigen längeren Passagen.

### 6.2 Population als Intelligence-Quelle und Schutzgut

Eine zentrale Syntheseaussage ist, dass die Zivilbevölkerung eine entscheidende Intelligence-Quelle und möglicherweise ein friendly-force center of gravity sein kann. Daraus folgen für OMW:

- HUMINT-/lokale Informationsgewinne dürfen nicht isoliert von Bevölkerungsschutz und Vertrauen modelliert werden;
- Aktionen mit hohem Kollateralschaden oder als willkürlich wahrgenommenem Verhalten können zukünftige Informationsqualität verschlechtern;
- Kontakt mit der Bevölkerung erzeugt Risiko für Informanten; sichtbare Kooperation kann Repressalien auslösen;
- Schutz, Verlässlichkeit und langfristige Präsenz können die Bereitschaft zur Kooperation beeinflussen.

Dies unterstützt eine spätere CampaignState-/Assessment-Architektur mit getrennten Größen für **Security, local confidence/influence und intelligence quality**, ohne dass dieses Dokument konkrete Formeln festlegt.

### 6.3 Intelligence auf unteren Ebenen

RAND empfiehlt beziehungsweise diskutiert:

- ausgewählte Companies mit einer 24-Stunden-Intel-Analysefähigkeit;
- robustere Battalion-Intel-Elemente;
- stärkere Nutzung der Informationen, die Soldaten und Marines im täglichen Kontakt sammeln;
- eine direkte Verbindung zwischen Priority Intelligence Requirements, nachgeordneten Information Requirements und den Fragen, die tatsächlich auf der Straße gestellt werden.

Für OMW ist dies eine Referenz gegen eine ausschließlich zentralisierte „allwissende“ Intel-Engine. Lokale Einheiten, Patrouillen, OPs und Interaktionen sollten langfristig als **Sensor-/Informationsquellen mit begrenzter Reichweite und Qualität** modellierbar sein.

### 6.4 Kontinuität und Rotation

RAND beschreibt Personalwechsel als erhebliches Problem für Intelligence-Arbeit:

- neue Analysten benötigen Zeit, um AO, Akteure, Muster und Datenbanken zu verstehen;
- persönliche Beziehungen zu lokalen Kontakten gehen durch Rotation teilweise verloren;
- auch politische beziehungsweise operative Programme werden durch häufige Richtungsänderungen zwischen Rotationen geschwächt.

Das stützt für OMW die Trennung zwischen kurzfristigen taktischen Erfolgen und langfristigem **local knowledge / network familiarity / campaign continuity**. Ein Staffel-, Unit- oder Commander-Wechsel sollte nicht automatisch vollständige lokale Kenntnis erhalten, wenn später eine solche Mechanik umgesetzt wird.

### 6.5 Datenbanken, Sharing und Source Deconfliction

RAND betont:

- Datenbanken zu Personen, Infrastruktur, Threats und lokalen Faktoren als wesentliches COIN-Wissensfundament;
- Interoperabilität und kompatible Daten-/Softwarestrukturen;
- Abbau von Intelligence-Stovepipes;
- Übergang von reflexivem `need-to-know` zu stärkerem `need-to-share`, soweit Schutzanforderungen dies erlauben;
- Collocation oder virtuelle Verbindung von Intel-Elementen;
- Source-identification beziehungsweise anonymisierte Kennzeichnung, damit mehrere Organisationen erkennen können, ob vermeintlich unabhängige HUMINT-Meldungen in Wahrheit von derselben Quelle stammen.

Als Afghanistan-Beispiel wird Kabul genannt, wo Informanten dieselben oder schlechte Informationen an mehrere Stellen verkaufen konnten, weil eine gemeinsame Source Registry fehlte.

Für OMW bedeutet dies konzeptionell:

- eine Information braucht **Provenienz**, nicht nur einen Wahr/Falsch-Wert;
- mehrere Meldungen dürfen nicht automatisch als unabhängige Bestätigung zählen;
- Coalition-/Agency-Sharing kann abgestuft sein;
- Informationen können zeitlich altern und unterschiedlich verlässlich sein;
- zentrale Datenhaltung und CampaignState dürfen trotzdem nicht mit einer omniscienten Spieleransicht verwechselt werden.

### 6.6 Gemeinsame Lagebilder und Interoperabilität

Die Studie nennt Probleme mit unterschiedlichen Karten, Grids, Imagery-Produkten und Freigabestufen zwischen Services und Nationen. Ferner werden unzureichende SOF-/Conventional- und Interagency-Informationsflüsse als Friktion beschrieben.

OMW-Designwert:

- ein gemeinsamer C2-Layer kann Informationen aggregieren, sollte aber Herkunft, Verzögerung und Sichtbarkeit berücksichtigen;
- Intelligence- oder RECCE-Ergebnisse müssen zielgerichtet an die Nutzer gelangen, die daraus Missionen ableiten;
- bloße Existenz eines Sensors oder einer Meldung bedeutet nicht, dass jeder Commander sie sofort besitzt.

### 6.7 Metrics: Ziele statt leicht messbarer Aktivität

RAND trennt **Inputs, Outputs und Effects** und warnt davor, Ziele danach auszuwählen, was leicht messbar ist. Für OMW ist dies unmittelbar relevant:

- `sorties_flown`, `rounds_fired`, `missions_completed`, `convoys_dispatched` oder `targets_destroyed` sind überwiegend Activity-/Output-Größen;
- strategischer Fortschritt muss an Effekten auf definierte Campaign Objectives gemessen werden;
- hohe Aktivität kann bei ausbleibendem oder negativem Effekt strategisch wertlos sein;
- die historischen VMA-513-Zahlen dieses Dokuments sind daher bewusst **keine Success Metrics**.

### 6.8 Lokale und zusammengesetzte Metrics

RAND fordert beziehungsweise empfiehlt:

- lokale Bedingungen bei der Metrics-Auswahl zu berücksichtigen;
- qualitative und quantitative Daten bei Bedarf zu **compound metrics** zu verbinden;
- Ursache und Korrelation zu unterscheiden; eindeutige Kausalität wird in COIN oft nicht erreichbar sein;
- Metriken auf unterschiedlichen Ebenen zu verschachteln, ohne lokal sinnvolle Größen nur wegen fehlender Vergleichbarkeit zu verwerfen.

Für OMW unterstützt dies ein späteres Assessment-Modell, in dem beispielsweise District Security, freedom of movement, local influence, insurgent access, intelligence confidence und infrastructure/functionality nicht auf einen einzelnen simplen Kill-/Loss-Score reduziert werden.

### 6.9 Regelmäßige Neubewertung und Red Team

RAND fordert periodische systematische Überprüfung der verwendeten Metrics und Baselines sowie einen Red-Team-Ansatz bei deren Entwicklung und Weiterentwicklung.

OMW-Designfolge:

- Assessment-Parameter und Schwellenwerte benötigen Versions-/Provenienzbezug;
- eine einmal sinnvolle Metrik darf nicht unverändert als ewige Kampagnenwahrheit behandelt werden;
- Tests sollten prüfen, ob Spieler oder Runtime-Logik eine Metrik „gamen“ können, ohne den eigentlich gewünschten Campaign Effect zu erzeugen.

### 6.10 Commander-Darstellung

RAND empfiehlt einfache, leicht verständliche Darstellungen, die Entscheidungen unterstützen, statt maximal viele Daten gleichzeitig zu präsentieren.

Für OMW ist dies eine UI-/Briefing-Referenz:

- strategische Commander-/Campaign-Ansichten sollen priorisierte Effekte und Unsicherheit zeigen;
- Rohdaten und Detailmetriken können im Hintergrund beziehungsweise in tieferen Ebenen liegen;
- die Oberfläche soll nicht bloß die interne Datenmenge spiegeln.

### 6.11 Interagency Campaign Plan und habitual relationships

RAND nennt zwei weitere übergreifende Punkte:

- echte interagency Campaign Plans mit organisatorischen Strukturen, die Kontinuität über Rotationen hinweg sichern;
- Erhalt eingespielter `habitual relationships`, statt Verbände bei Deployment ohne zwingenden Grund auseinanderzureißen.

Für OMW stützt dies:

- langfristige Beziehungen zwischen C2, Ground Units, Aviation, Intelligence und lokalen Partnern;
- CampaignState als dauerhafte strategische Ebene über temporären DCS-Gruppen;
- keine automatische strategische „Gedächtnislöschung“ beim Despawn oder Austausch einer physischen Gruppe;
- zugleich keine Annahme, dass neu eingesetzte physische Verbände automatisch sämtliche lokalen Beziehungen besitzen.

## 7. Projektrelevante Synthese

Die vier Quellen liefern zusammen folgende belastbare Designreferenzen:

| Themenfeld | Quellenbefund | OMW-Nutzung |
|---|---|---|
| Kandahar Fixed Wing 2011 | VMA-513 und VMA-223 mit je zehn AV-8B in historischer Rotation | historische Air-ORBAT-/Basing-Evidenz; keine Änderung der aktiven 74th-EFS-Baseline |
| CAS/ISR | großer Anteil von Overwatch, Route Search, FAC-/ROVER-/UAS-Integration neben kinetischen Aktionen | Missionsmix und Tasking-Nachfrage diversifizieren |
| Air Ops Rhythmus | lange Sorties, mehrere Tagesfenster, Anpassung an Enemy Activity | variable Demand Windows statt kurzer Arcade-Zyklen |
| Expeditionary Basing | Camp Dwyer zeigt Nutzen von Runway, Ramp, Fuel und Taxiway als zusammenhängender Turnaround-Infrastruktur | Basen als Funktionssysteme, nicht nur Spawnpunkte |
| AAR | F-14-OEF zeigt AAR als Voraussetzung weitreichender Afghanistan-TACAIR | AAR als operative Enabler-/Constraint-Referenz |
| FAC(A)/C2 | F-14- und Takur-Ghar-Quellen zeigen dynamisches Targeting und C2-Friktion | kohärente C2-, Priorisierungs- und Deconfliction-Logik |
| SOF RECCE | AFO/OP/POL-/Environmental Reconnaissance vor Anaconda | RECCE/Fog-of-War als Informationsprozess statt magischer Reveal |
| Air Assault | Höhe, Gelände, vorhersehbare Korridore und offset HLZs beeinflussen Survivability | validierte LZ/route/altitude/threat-Planung |
| Communications | Redundanz und korrekte Frequenz-/Koordinatenweitergabe entscheidend | keine Single-Point-of-Failure-Designs in kritischen Missionen |
| Intelligence | lokale Quellen, Provenienz, Sharing, Source Deconfliction und Kontinuität | Campaign-Intel mit Confidence/Provenance statt globaler Wahrheit |
| Metrics | Inputs/Outputs/Effects unterscheiden, lokal anpassen, regelmäßig prüfen | effect-based Campaign Assessment statt reiner Kill-/Sortie-Scores |

## 8. Was ausdrücklich **nicht** aus diesen Quellen abgeleitet wird

Diese Quellen autorisieren **nicht**:

- AV-8B, F-14 oder andere neue Client-/AI-Airframes in der aktiven OMW-ORBAT;
- Änderungen an der aktiven Kandahar-Entscheidung `74th EFS / 16 A-10C`;
- neue SQUADRON-, AIRWING-, Warehouse- oder CampaignState-Bestände;
- DCS-Flugleistungswerte aus realen Höhen-/Reichweitenbeschreibungen;
- konkrete MOOSE-Implementierungen;
- feste Sortieraten oder Munitionsverbrauchsraten aus historischen Einsatzkennzahlen;
- automatische Erfolgspunkte für Kills, Sorties oder abgeworfene Waffen;
- eine 2010–2011-Verwendung früher OEF-Task-Force-Namen oder -Kommandostrukturen;
- Annahmen über Echtzeit-Informationszugang allein aufgrund vorhandener Sensoren.

Solche Änderungen erfordern die jeweils zuständige OMW-Baseline, gegebenenfalls eine ausdrückliche Projektinhaberentscheidung und bei Runtime-Änderungen den vollständigen MOOSE-First-/Acceptance-Prozess.

## 9. Quellen und Fundstellen

### 9.1 Lon Nordeen

Lon Nordeen, *AV-8B Harrier II Units of Operation Enduring Freedom*, Osprey Combat Aircraft 104.

Projektverwendete Fundstellen:

- Kapitel 5, insbesondere S. 60 sowie S. 68: VMA-214/VMA-231, Camp Dwyer, Litening II, ROVER, UAS, CAS-/ISR-Erfahrung und Vorperiodenkennzahlen.
- Kapitel 6, insbesondere S. 70–75: VMA-513-Vorbereitung, centerline Litening II, Missionsrhythmus, Eastern Storm, Einsatzkennzahlen und Übergabe an VMA-223.
- Appendix S. 91–94: Deployment-Zeiträume, BuNos und Farbtafel-/Konfigurationsangaben für VMA-513 und VMA-223.

### 9.2 Tony Holmes

Tony Holmes, *F-14 Tomcat Units of Operation Enduring Freedom*, Osprey Combat Aircraft 70, Osprey Publishing, 2008.

Projektverwendete Fundstellen:

- *Build-up to War* und *OEF Begins*, etwa S. 7–45: CAOC-/AWACS-/AAR-/TARPS-/LANTIRN-Kontext, Strike-Planung und frühe OEF-Air-C2.
- *Ground War*, etwa S. 46–77: FAC/SOF-CAS, dynamische Zielsuche, Reattack, LGB-Einsatz und Ground-Air-Koordination.
- *Operation Anaconda*, ab etwa S. 78: frühe OEF-CAS-/C2- und Support-Muster.

Die bereitgestellte Datei ist bildbasiert; OMW übernimmt daraus nur in den gerenderten Seiten klar erkennbare Aussagen und keine ungesicherten OCR-Rekonstruktionen.

### 9.3 Leigh Neville

Leigh Neville, *Takur Ghar: The SEALs and Rangers on Roberts Ridge, Afghanistan 2002*.

Projektverwendete Fundstellen:

- S. 4–18: Shahikot/Takur Ghar, SOF-Strukturen, AFO, Environmental Reconnaissance, Pattern of Life, Fahrzeuge/ATVs und Air-Assault-Planung.
- S. 39–50: MH-47E-Verwundbarkeit, Communications-/Power-Ausfälle, Frequenz-/Koordinatenprobleme und QRF-Insertion.
- S. 63–64: CAS-/Fires-Mix bei Extraction und Verwundetenversorgung.
- S. 71–75: Analyse zu Technology, Communications und Command and Control.

### 9.4 Russell W. Glenn / S. Jamie Gayton

Russell W. Glenn und S. Jamie Gayton, *Intelligence Operations and Metrics in Iraq and Afghanistan: Fourth in a Series of Joint Urban Operations and Counterinsurgency Studies*, RAND National Defense Research Institute, November 2008, prepared for United States Joint Forces Command.

Projektverwendete Fundstellen:

- Summary, S. xiii–xviii: Syntheseempfehlungen zu Bevölkerung, Intelligence, Datenbanken, Sharing, Metrics, Interagency und habitual relationships.
- Chapter Two, *Intelligence*, S. 11–35: lower-echelon intelligence, databases, source registry, sharing, mindset und soldier/marine as sensor.
- Chapter Three, *Metrics*, S. 37–66: Objectives, Inputs/Outputs/Effects, lokale Bedingungen, compound metrics, Reassessment und Red Team.
- Chapter Four, *General COIN Observations*, S. 67–80: Interagency Campaign Plan, Population/Shaping, Basing amid population und habitual relationships.
- Appendices, insbesondere die I-D-R- und Matrix-Zusammenfassungen: quellenübergreifende Wiederholung und Einordnung der Kernaussagen.

## 10. Folgezuordnung innerhalb der OMW-Dokumentation

Dieses Review ergänzt insbesondere:

- `OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION` – historische Kandahar-/Camp-Dwyer-/Aviation-Evidenz;
- `OMW-HIST-USMC-RC-SOUTHWEST-COALITION-OPS` – USMC-Air-Support und RC-Southwest-Missionsmuster;
- `OMW-HIST-ARMY-AVIATION-COIN-INTELLIGENCE-METRICS` – Intelligence-/Metrics- und Aviation-Lessons-Learned;
- `OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS` – JTAR, FAC(A), CAS, AAR und dynamisches Targeting;
- `OMW-HIST-AFGHAN-AIR-WARS-2009-2011` – VMA-513/VMA-223 und ISR/CAS-Missionsmuster;
- `OMW-HIST-ARSOF-SOF-AVIATION-EARLY-OEF` – Takur-Ghar-/AFO-/160th-SOAR-/C2-Hintergrund;
- `OMW-MOOSE-FOG-OF-WAR-RECCE` – ausschließlich als fachliche RECCE-/Information-Requirement-Referenz; keine MOOSE-API-Aussage.

Bei späterer technischer Umsetzung bleiben MOOSE-Dokumentation, tatsächlich verwendete `Moose.lua`, offizielle Beispiele und DCS-Tests maßgeblich.