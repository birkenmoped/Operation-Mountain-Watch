---
document_id: OMW-EVIDENCE-MQ1-MQ9-SOURCE-REVIEW-2026-08-13
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical extraction of owner-provided MQ-1 Predator and MQ-9 Reaper references
  - evidence classification for technical, endurance, payload, operational and Afghanistan-related claims
  - conflict notes against higher-authority OMW sources
not_authoritative_for:
  - active OMW air ORBAT
  - strategic fuel-stock quantities
  - runtime fuel-consumption accounting
  - DCS or MOOSE technical acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-ops-initial-stock-runtime-data
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# MQ-1 Predator / MQ-9 Reaper – Quellenprüfung 13.08.2026

## 1. Zweck und Quellen

Diese Akte dokumentiert die vollständige OMW-relevante Auswertung der am 13.08.2026 vom Projektinhaber bereitgestellten Quellen:

1. Dave Sloggett, *Drone Warfare: The Development of Unmanned Aerial Conflict*, Pen & Sword Aviation, 2014, ISBN 978-1-78346-187-5.
2. Reg Austin, *Unmanned Aircraft Systems: UAVS Design, Development and Deployment*, Wiley, 2010, ISBN 978-0-470-05819-0.
3. *Armada International – Unmanned Systems Special 2025*, June/July 2025.

Die beiden Bücher sind Sekundärquellen. Austin ist als zeitgenössische technische Synthese von 2010 besonders wertvoll; Sloggett liefert zusätzlich Afghanistan- und RAF-Reaper-Kontext und verweist auf eigene Afghanistan-Beobachtung 2011. Die Armada-Ausgabe 2025 ist post-periodisch und enthält in der geprüften Ausgabe keine belastbare MQ-1-/MQ-9-spezifische 2010/2011-Fachinformation.

Verbindliche Quellenregel:

```text
OWNER-PROVIDED SECONDARY SOURCE
!= OFFICIAL PRIMARY SOURCE
!= ACTIVE OMW ORBAT DECISION
!= DCS/MOOSE RUNTIME EVIDENCE
```

Bei Widerspruch gelten `docs/00-project-governance.md` und die dort definierte Autoritätshierarchie.

## 2. Reg Austin 2010 – technische Predator-/Reaper-Daten

### 2.1 System- und Missionsgrundlagen

Austin behandelt UAV als Gesamtsystem aus Air Vehicle, Payload, Control Station, Kommunikation, Navigation, Launch/Recovery und Support. Für OMW relevant ist insbesondere, dass der Downlink neben Payloaddaten auch Aircraft-`housekeeping data` wie Fuel State und Engine-/Systemzustände übertragen kann. Diese Aussage beschreibt die reale UAS-Systemarchitektur, beweist aber keine entsprechende DCS-/MOOSE-API.

Quelle: Austin 2010, Kapitel 1, insbesondere S. 1–14.

### 2.2 MALE-Einordnung

Austin beschreibt MALE-Systeme als Medium-Altitude-/Long-Endurance-Systeme mit typischerweise etwa 5.000–15.000 m Einsatzhöhe, ungefähr 24 h Endurance und Reichweiten über 500 km. Predator/Reaper sind in dieser technischen Entwicklungslinie einzuordnen.

Quelle: Austin 2010, S. 4–5.

### 2.3 Predator B – Ausdauer, Reichweite, Fuel Load und Flugleistung

In Abbildung 4.9 wird Predator B als MALE-Referenz mit folgenden Leading Particulars angegeben:

| Merkmal | Austin-Wert |
|---|---:|
| Maximum flight endurance | 32 h |
| Endurance on station | 24 h |
| Range | ca. 3.400 km |
| Ceiling | 12.000 m |
| Cruise speed | 230 kt |
| Loiter speed | ca. 150 kt |
| Fuel load | 1.360 kg |
| Payload | 360 kg |
| All-up mass | 4.536 kg |

Austin weist im selben Abschnitt ausdrücklich darauf hin, dass externe Payloads wie Waffen den aerodynamischen Widerstand erhöhen und Reichweite sowie Endurance reduzieren. Die genannten Werte sind daher nicht ohne Lastzustandsbezug als einheitliche Einsatzwerte zu verwenden.

Quelle: Austin 2010, Abb. 4.9 / S. 53–54.

### 2.4 Predator B und Reaper – bewaffnete Konfigurationen

Austin erklärt die Entwicklung vom ursprünglichen Predator-A-Aufklärungsansatz zu einer bewaffneten MALE-Lösung mit verkürztem Sensor-to-shooter-Zyklus. Abbildung 4.10 nennt:

| Plattform | Wingspan | AUM | Cruise | angegebene Bewaffnung |
|---|---:|---:|---:|---|
| Predator B | 20 m | 4.536 kg | 230 kt | 2 × Hellfire |
| Reaper | 20 m | 5.090 kg | 260 kt | 4 × Hellfire + 2 × 500-lb bombs |

Quelle: Austin 2010, S. 54, Abb. 4.10.

### 2.5 Predator-Familie – technische Entwicklung A/B/C

Abbildung 28.9 enthält eine kompakte technische Gegenüberstellung. Für OMW relevant sind A und B:

**Predator A:**

- wingspan 14,83 m;
- length 8,13 m;
- MTOM 1.020 kg;
- piston engine, 78,3 kW;
- endurance >20 h;
- ceiling 7.920 m;
- payload 204 kg;
- payload types: EO, IR, SAR, SIGINT;
- max speed 217 km/h.

**Predator B:**

- wingspan 20 m;
- length 10,6 m;
- MTOM 4.536 kg;
- turboprop, 500 kW;
- endurance 32 h;
- ceiling 12.000 m;
- payload: 385 kg internal / 1.360 kg external;
- payload types: EO/IR TV, SAR, weapons;
- max speed 440 km/h.

Die unterschiedliche Payload-Angabe von 360 kg in Abb. 4.9 gegenüber 385 kg intern / 1.360 kg extern in Abb. 28.9 wird nicht stillschweigend harmonisiert. Sie wird als quelleninterne Darstellungsdifferenz dokumentiert.

Quelle: Austin 2010, S. 314, Abb. 28.9.

### 2.6 Predator/Reaper – Entwicklung und Einsatzlogik

Austin beschreibt Predator B als turboprop-getriebene Weiterentwicklung und Reaper als vergrößerte, stärker bewaffnete Weiterentwicklung dieser Linie. Die bewaffnete Auslegung wird mit der Notwendigkeit begründet, nach ISR-Erkennung flüchtiger Ziele ohne langen Übergang zu einem separaten Strike Asset reagieren zu können.

Quelle: Austin 2010, S. 54 sowie S. 312–314.

### 2.7 Control-Station-/Remote-Operation

Austin beschreibt, dass Systeme wie Predator nahe dem Einsatzraum von einer Forward-GCS gestartet werden können, während die Missionskontrolle anschließend an ein weiter entferntes Command Centre übergeben wird. Dies reduziert den Personal- und Infrastrukturbedarf im Forward Area.

Quelle: Austin 2010, Kapitel 13, S. 193.

OMW-Relevanz: Dieses Konzept stützt die Trennung zwischen physischer Start-/Recovery-Basis und übergeordneter Missionsführung, ist aber keine direkte DCS-/MOOSE-Runtime-Vorgabe.

## 3. Dave Sloggett 2014 – Afghanistan- und Reaper-Kontext

### 3.1 Quellenwert und Afghanistan-Bezug

Sloggett weist darauf hin, dass offene Detailinformationen zu UAV-Operationen in Afghanistan vergleichsweise schwer zugänglich waren. Er beschreibt zugleich eine eigene Afghanistan-Reise 2011, bei der er amerikanische und britische unmanned-aircraft operations aus erster Hand beobachtet habe.

Quelle: Sloggett 2014, Acknowledgements, S. xiii–xiv.

Diese Aussage erhöht den Kontextwert des Buches, macht einzelne technische Zahlen aber nicht zu amtlichen Primärdaten.

### 3.2 Persistence und Pattern of Life

Sloggett betont als zentralen Entwicklungstreiber die lange Station Time: längere Endurance ermöglicht den Aufbau von Pattern-of-Life-Erkenntnissen und unterstützt präzise Wirkung nach längerer Beobachtung. SATCOM wird als entscheidender Enabler für ausgedehnte Einsätze beschrieben.

Quelle: Sloggett 2014, Preface, S. vii.

OMW-Relevanz: stützt die bereits bestehende ISR-/Pattern-of-Life-Architektur, ohne eigene Target Authorization zu begründen.

### 3.3 RAF MQ-9 in Afghanistan – Einsatzintensität und Waffen

Für die britischen Reaper in Afghanistan berichtet Sloggett:

- britische MQ-9 wurden seit ihrem Einsatzbeginn 2008 nahezu kontinuierlich betrieben;
- im November 2010 habe das UK MoD angegeben, dass etwa 15 % der Missionen irgendeine Form kinetischer Wirkung beinhalteten;
- genannt werden 293 abgefeuerte Hellfire-Luft-Boden-Flugkörper und 52 abgeworfene Paveway-Bomben;
- im September 2012 nennt die Quelle für fünf britische MQ-9 insgesamt 39.628 Flugstunden und 334 laser-guided Hellfire missiles sowie Bombeneinsätze gegen Ziele in Afghanistan.

Quelle: Sloggett 2014, S. 106–107.

Die 2012-Gesamtwerte liegen außerhalb des OMW-Szenarioendes und dürfen nur als Kontinuitäts-/Plausibilitätskontext verwendet werden. Die November-2010-Angabe liegt im OMW-Zeitraum und unterstützt die Trennung zwischen überwiegender ISR-Nutzung und missionsabhängiger bewaffneter Wirkung.

### 3.4 MQ-9 Endurance nach Beladungszustand

Sloggett nennt für die dort beschriebenen britischen MQ-9:

- bis zu 18 h Endurance bei voller Beladung mit Hellfire und laser-guided bombs;
- nahe 30 h unbewaffnet;
- Range etwa 3.700 miles / 5.900 km;
- maximum airspeed 250 kt;
- ceiling bis 50.000 ft.

Quelle: Sloggett 2014, S. 107.

Diese Werte sind besonders wichtig, weil sie zeigen, dass `capacity / maximum endurance` keine belastbare konstante Fuel-Burn-Rate ergibt: Beladung und Einsatzkonfiguration verändern die Endurance erheblich.

### 3.5 Afghanistan-UOR und IED-Kontext

Sloggett beschreibt die Einführung der RAF-MQ-9 als Urgent Operational Requirement und nennt die IED-Bedrohung in Afghanistan als einen der Treiber für die beschleunigte Beschaffung.

Quelle: Sloggett 2014, S. 107.

### 3.6 Dokumentierter ziviler Schadensfall 25.03.2011

Sloggett berichtet, das UK MoD habe eingeräumt, dass bei einem bewaffneten UAV-Angriff am 25.03.2011 vier Zivilisten getötet und zwei weitere verletzt wurden.

Quelle: Sloggett 2014, S. 107.

OMW-Relevanz: stützt die Notwendigkeit von PID-, ROE-, Collateral- und Target-Authorization-Gates. Der Einzelfall wird nicht als statistische Treffer-/Fehlerrate verallgemeinert.

### 3.7 Bewaffnung und spätere Integrationen – Quellenkonflikt

Sloggett nennt für MQ-9 unter anderem:

- GBU-12 Paveway II;
- Hellfire;
- eine im März 2009 erfolgte Ausrüstung mit einer 500-lb-JDAM-Variante;
- GBU-39B Small Diameter Bomb;
- eine 2010 erfolgte Erweiterung auf AGM-114P+ mit verbessertem/off-axis engagement envelope.

Quelle: Sloggett 2014, Conclusions, um S. 190.

**Wichtige OMW-Quellengrenze:** Die bestehende OMW-Fachbaseline `docs/50-mq1-mq9-afghanistan-employment.md` war auf einem früheren Branch auf offizielle USAF-Quellen gestützt und schloss insbesondere GBU-38 für 2010/2011 aus, weil die USAF die MQ-9-GBU-38-Integration 2017 als neue Fähigkeit dokumentierte. Nach Governance besitzt eine amtliche Primärquelle höhere Evidenzstärke als Sloggetts Sekundärdarstellung. Daher wird aus dieser Passage **keine** neue OMW-Waffenfreigabe abgeleitet. Der Widerspruch bleibt dokumentiert und verlangt bei Bedarf eine konkrete Primärquellenprüfung der von Sloggett gemeinten JDAM-Variante.

### 3.8 Post-period MQ-9-Upgrades ausdrücklich nicht rückprojizieren

Sloggett beschreibt spätere Reaper-Upgrades mit etwa 35 h Endurance sowie vorgeschlagene/erweiterte Konfigurationen mit größerer Spannweite und bis zu etwa 42 h Endurance. Diese Angaben liegen außerhalb des OMW-Zeitraums und sind **nicht** auf die 2010/2011-Konfiguration zurückzuprojizieren.

Quelle: Sloggett 2014, S. 106.

## 4. Armada International 2025

Die bereitgestellte 24-seitige Sonderausgabe wurde vollständig auf OMW-relevante Predator-/Reaper-Angaben geprüft.

Ergebnis:

- Schwerpunkt sind aktuelle 2025-UAS, Ukraine-Erfahrungen und Herstellerübersichten;
- eine General-Atomics-Anzeige zeigt das moderne YFQ-42A-Konzept;
- es wurden keine belastbaren, periodenspezifischen MQ-1-Predator- oder MQ-9-Reaper-Daten für Afghanistan 2010/2011 gefunden;
- die Ausgabe liefert daher **keinen** neuen Fuel-, Endurance-, Payload-, ORBAT- oder Afghanistan-Wert für die OMW-Predator-/Reaper-Baseline.

Quelle: *Armada International – Unmanned Systems Special 2025*, June/July 2025, bereitgestellte Ausgabe.

Status für OMW:

```text
POST_PERIOD_CONTEXT_ONLY
NO_2010_2011_BASELINE_CHANGE
```

## 5. Abgleich mit bestehender OMW-Evidenz

Bereits höher oder gleichwertig dokumentiert sind:

### MQ-1

```text
Fuel type: AVGAS
Fuel capacity: 665 lb / 100 US gal
Endurance: >24 h
```

Die OMW-Arbeitsgröße `100 gal / 24 h = 4.1667 GPH` bleibt eine **Capacity/Endurance-Proxy-Rechnung**, kein gemessener Fuel Flow. Die neuen Bücher liefern keinen belastbaren gemessenen MQ-1-GPH-Wert.

### MQ-9

```text
Baseline fuel capacity: 4,000 lb / 602 US gal
Fuel path: JP-8 / aviation fuel
```

Die frühere OMW-Arbeitsgröße `602 gal / 14 h = 43 GPH` bleibt ebenfalls ein Proxy. Austin und Sloggett zeigen sogar ausdrücklich, dass Endurance stark von Beladungszustand und Konfiguration abhängt. Ein einzelner fixer GPH-Wert darf daher nicht als reale Plattformkonstante dargestellt werden.

## 6. Verwertbare OMW-Ableitungen

### 6.1 Für Fuel Planning

Die neuen Quellen **ersetzen keinen** bereits festgelegten Fuel-Stock-Schlüssel. Sie verbessern jedoch die Evidenzgrenze:

```text
capacity / endurance
= planning proxy
!= measured fuel burn
```

Der vom Projektinhaber festgelegte MQ-1-Planungsansatz von vier Aircraft, 24 h/day und 4.1667 gal/h bleibt damit eine bewusste OMW-Planungsentscheidung, nicht eine Behauptung über einen gemessenen realen MQ-1-Verbrauch.

### 6.2 Für Mission Profiles

Quellenunterstützt sind:

- persistente ISR / Pattern-of-Life;
- armed ISR / Overwatch;
- Sensor-to-shooter-Verkürzung bei flüchtigen Zielen;
- Missionsrollen mit getrenntem Sensor und Shooter;
- missionsabhängige Bewaffnung statt pauschal bewaffneter Sorties;
- deutliche Endurance-Abhängigkeit von Payload/Drag;
- Remote-Mission-Control bei lokaler Start-/Recovery-Komponente.

### 6.3 Für Payloads

Für den OMW-Zeitraum belastbar als Familien-/Rollenreferenz:

```text
MQ-1 / Predator lineage:
- EO/IR/SAR/SIGINT reconnaissance payloads
- Hellfire-capable armed development

MQ-9 / Reaper:
- EO/IR/SAR
- Hellfire
- 500-lb class guided bombs, insbesondere GBU-12 als bereits anderweitig bestätigte OMW-Familie
```

Nicht aus diesen Sekundärquellen allein freigeben:

```text
GBU-38 for OMW 2010/2011
GBU-39B for OMW 2010/2011
post-period extended-endurance configurations
modern wing/gear upgrades
```

## 7. Konflikte und offene Punkte

1. Austin nennt für Predator B unterschiedliche Payloadwerte in Abb. 4.9 und Abb. 28.9; keine stille Harmonisierung.
2. Sloggetts JDAM-/GBU-39B-Angaben stehen mindestens teilweise im Konflikt mit der bereits genutzten offiziellen USAF-Timeline; Primärquelle entscheidet.
3. Keine der drei Quellen liefert einen gemessenen MQ-1-Fuel-Flow in GPH für Afghanistan 2010/2011.
4. Keine der drei Quellen liefert einen gemessenen MQ-9-Fuel-Flow in GPH für Afghanistan 2010/2011.
5. Endurance-Werte sind konfigurationsabhängig; bewaffnet/unbewaffnet darf nicht zusammengeworfen werden.
6. Die 2025-Armada-Ausgabe ist für den OMW-Zeitraum nur Hintergrund und erzeugt keine Baselineänderung.

## 8. Projektstatus nach dieser Quellenprüfung

Diese Akte ändert keine aktive ORBAT und keine DCS-/MOOSE-Acceptance.

Sie bestätigt bzw. schärft:

```text
MQ-1 -> AVGAS strategic fuel family
MQ-9 -> JP-8 strategic fuel family
RPA fuel burn proxies remain planning proxies
persistent ISR and armed-overwatch roles are historically plausible and well supported
payload/endurance coupling must be preserved in planning assumptions
```

Die bestehenden Governance-, ORBAT-, Warehouse- und Resource-Verträge bleiben autoritativ.