---
document_id: OMW-AIR-UAS-AFGHANISTAN
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - historical MQ-1B and MQ-9 employment baseline for Afghanistan
  - period-appropriate MQ-1B and MQ-9 weapon families
  - OMW mission-design defaults for UAV loadout roles and operating altitudes
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/document-mq1-mq9-afghanistan
validated_in_dcs: false
---

# 50 – MQ-1B Predator und MQ-9 Reaper in Afghanistan

## 1. Status, Zweck und Abgrenzung

Dieses Dokument definiert die historische und missionsdesignerische Ausgangsbasis für den Einsatz von **MQ-1 Predator** und **MQ-9 Reaper** in Afghanistan während des verbindlichen Kampagnenzeitraums:

```text
01.08.2010 bis 31.12.2011
```

Es ist verbindlich für:

- die historische Grundrolle der beiden Systeme;
- die Einordnung bewaffneter und unbewaffneter Einsatzprofile;
- zeitgerechte Waffenfamilien;
- auszuschließende spätere Waffenintegration;
- Ausgangswerte für ISR-, Overwatch- und bewaffnete UAV-Orbits in OMW;
- die Trennung zwischen belegten Tatsachen und eigenen Missionsdesign-Entscheidungen.

Es ist **nicht** verbindlich für:

- einen exakten aktiven UAV-Bestand;
- eine konkrete Staffelstärke in der OMW-ORBAT;
- die Zahl gleichzeitig aktiver UAVs;
- konkrete DCS-Typnamen, Payload-IDs oder Parking-Positionen;
- ein technisch bereits validiertes MOOSE-Verhalten.

Die aktive Bestandsautorität verbleibt bei:

- `OMW-AIR-ACTIVE-ORBAT` – `docs/19-active-air-orbat-decisions.md`;
- basisbezogenen Mission-Editor-Baselines;
- später ausdrücklich freigegebenen UAV-Bestandsentscheidungen.

Die funktionale ISR-, FAC-, CAS- und Kontaktarchitektur bleibt definiert in:

- `docs/moose/ISR-FAC-CAS-AAR.md`.

---

## 2. Quellen- und Evidenzkategorien

| Kennzeichnung | Bedeutung |
|---|---|
| `OFFICIAL_SOURCE_VERIFIED` | Aussage wurde in einer offiziellen Quelle der US Air Force, AFCENT oder US Army geprüft. |
| `SUPPORTED_ASSESSMENT` | Mehrere offizielle Quellen stützen die Einordnung, ohne eine vollständige Statistik zu liefern. |
| `PROJECT_DECISION` | Verbindliche OMW-Umsetzungsentscheidung; keine Behauptung einer allgemeinen historischen SOP. |
| `PENDING_DCS_VALIDATION` | Muss im aktuell verwendeten DCS- und MOOSE-Stand praktisch geprüft werden. |
| `UNKNOWN` | Öffentlich nicht ausreichend belegt. |

Eine technische Plattformkapazität, eine dokumentierte Einzelmission und eine typische Missionskonfiguration sind nicht gleichzusetzen.

---

## 3. Bezeichnung: Predator A, MQ-1A und MQ-1B

### 3.1 Historische Einordnung

Die frühe Bezeichnung **Predator A** bezeichnet die kleinere Predator-Generation gegenüber dem größeren Predator B, aus dem die MQ-9 hervorging. Eine offizielle USAF-Testdarstellung beschreibt Predator A als bewaffnete Version der ursprünglich für ISR entwickelten RQ-1.

Für den OMW-Zeitraum 2010–2011 lautet die historisch vorzuziehende USAF-Bezeichnung:

```text
MQ-1B Predator
```

### 3.2 DCS-Abbildung

Falls DCS das verfügbare AI-Objekt als `MQ-1A Predator` bezeichnet, gilt projektseitig:

```text
Historisches Vorbild: MQ-1B Predator
DCS-Repräsentation: verfügbares Predator-AI-Objekt
Status: ausdrücklich gekennzeichneter technischer Ersatz
```

Der exakte DCS-Typname und seine Fähigkeiten sind vor der Template-Erstellung im Mission Editor und über die DCS-Datenstrukturen zu prüfen.

**Status:** `PENDING_DCS_VALIDATION`

---

## 4. Belegte Präsenz und Rolle in Afghanistan

### 4.1 Kandahar und 62nd Expeditionary Reconnaissance Squadron

Für Juni 2010 ist offiziell belegt:

- Die **62nd Expeditionary Reconnaissance Squadron** in Kandahar betrieb MQ-1 Predator und MQ-9 Reaper.
- Die Einheit führte Start, Landung und Bergung der Air-Force-RPA in Afghanistan durch.
- Beide Systeme erfüllten ISR- und Close-Air-Support-Aufgaben.
- Die MQ-1 konnte zwei AGM-114 Hellfire einsetzen.
- Die MQ-9 verband persistente ISR mit einer Hunter-Killer- beziehungsweise Strike-Fähigkeit.

Damit ist Kandahar innerhalb des OMW-Zeitraums als historisch belastbarer UAV-Operationsknoten bestätigt.

### 4.2 Kein automatisch abgeleiteter OMW-Bestand

Aus Präsenz, Einsatztempo oder späteren Stationsangaben wird keine konkrete aktive OMW-Stärke abgeleitet.

```text
Historische Präsenz in Kandahar: bestätigt
Exakte lokale Stärke im gesamten OMW-Zeitraum: nicht abschließend bestimmt
Aktiver OMW-Bestand: separate Projektentscheidung erforderlich
```

**Status:**

- Präsenz und Rollen: `OFFICIAL_SOURCE_VERIFIED`
- exakte kampagnenweite Stärke: `UNKNOWN`

---

## 5. Waren die UAVs normalerweise bewaffnet?

### 5.1 Belastbare Aussage

Offizielle Afghanistan-Berichte beschreiben MQ-1 und MQ-9 ausdrücklich als:

- waffentragende Luftfahrzeuge;
- ISR- und Hunter-Killer-Systeme;
- Plattformen für bewaffnete Aufklärung und Overwatch;
- CAS-fähige Assets;
- Systeme, die Ziele beobachten, verfolgen, bei Freigabe bekämpfen und anschließend BDA liefern konnten.

Bewaffnete ISR und bewaffnetes Overwatch waren damit **reguläre Einsatzrollen und keine außergewöhnliche Sonderverwendung**.

### 5.2 Nicht belegte Verallgemeinerung

Öffentlich zugängliche offizielle Quellen liefern für den OMW-Zeitraum keine vollständige Statistik zu:

- dem Anteil bewaffnet gestarteter Sorties;
- dem Anteil vollständig beladener Sorties;
- dem Anteil unbewaffneter ISR-Flüge;
- einer generellen Verpflichtung, bei jedem Kampfeinsatz Waffen mitzuführen.

Daher ist folgende Aussage unzulässig:

```text
Jede MQ-1- oder MQ-9-Sortie in Afghanistan war bewaffnet.
```

Ebenso ist ohne zusätzliche Statistik keine konkrete Prozentangabe zulässig.

### 5.3 Verbindliche OMW-Entscheidung

Für OMW wird nicht eine vermeintliche universelle historische Quote simuliert, sondern das Profil des jeweiligen Auftrags:

| OMW-Einsatzprofil | Standardkonfiguration |
|---|---|
| bewaffnetes Overwatch / CAS-ready ISR | bewaffnet |
| Hunter-Killer / Time-Sensitive Target | bewaffnet |
| Convoy- oder Troops-in-Contact-Overwatch | grundsätzlich bewaffnet, sofern ROE und Verfügbarkeit dies erlauben |
| reine Pattern-of-Life-Beobachtung | bewaffnet oder unbewaffnet nach Auftrag und Ressourcenlage |
| dedizierte unbewaffnete ISR | unbewaffnetes Template zulässig |
| Training, Überführung oder technische Mission | auftragsspezifisch |

Der missionsdesignerische Standard lautet damit:

```text
Bewaffnete Combat-Overwatch-Templates sind die Regel für kampfbereite UAV-Aufträge.
Unbewaffnete ISR-Templates bleiben ausdrücklich verfügbar.
Waffeneinsatz erfolgt niemals automatisch allein aufgrund einer Erkennung.
```

**Status:** `PROJECT_DECISION`

---

## 6. Zeitgerechte Bewaffnung

## 6.1 MQ-1B Predator

### Belegt und zulässig

```text
bis zu 2 × AGM-114 Hellfire
```

Die MQ-1B war damit für präzise Angriffe gegen einzelne Fahrzeuge, kleine Stellungen oder andere geeignete Punktziele geeignet. Eine reduzierte Beladung ist historisch plausibel; die technische Maximalkapazität ist nicht mit einer garantierten Standardbeladung jeder Sortie gleichzusetzen.

### Für OMW nicht vorgesehen

- GBU-12;
- GBU-38;
- sonstige 500-lb-Bomben;
- spätere oder nicht belegte Waffenintegration.

### OMW-Templates

Mindestens vorzusehen:

```text
UAV_MQ1_ISR_UNARMED
UAV_MQ1_ISR_ARMED_2X_HELLFIRE
```

Optional nach DCS-Payloadprüfung:

```text
UAV_MQ1_ISR_ARMED_REDUCED
```

**Status:** historische Waffenfamilie `OFFICIAL_SOURCE_VERIFIED`; konkrete DCS-Payloads `PENDING_DCS_VALIDATION`

---

## 6.2 MQ-9 Reaper

### Belegt und zulässig

Für Afghanistan sind im relevanten technischen und zeitlichen Kontext belegt:

- AGM-114 Hellfire;
- GBU-12 Paveway II, lasergelenkte 500-lb-Bombe;
- gemischte Beladungen aus Hellfire und GBU-12.

Eine offizielle USAF-Aufnahme vom 27. Januar 2009 zeigt eine MQ-9 auf einer Kampfmission über Südafghanistan mit GBU-12 und AGM-114. Die zeittypische Plattformkapazität lag vor der späteren Acht-Hellfire-Erweiterung bei maximal vier Hellfire; zusätzlich konnten zwei 500-lb-Bomben vorgesehen werden.

### Periodengerechte Planungsobergrenze

```text
bis zu 4 × AGM-114 Hellfire
bis zu 2 × GBU-12 Paveway II
oder eine technisch zulässige gemischte Konfiguration
```

Die konkrete Kombination muss im DCS-Payloadsystem geprüft werden. Eine technisch mögliche Maximalbeladung wird nicht automatisch für jede Mission verwendet.

### Ausdrücklich nicht zeitgerecht

```text
GBU-38 JDAM
```

Die USAF bezeichnete den Abwurf der ersten GBU-38 durch eine MQ-9 im Mai 2017 als neue Integration und beschrieb Hellfire und GBU-12 als die zuvor über zehn Jahre verwendeten Waffen. Die GBU-38 wird deshalb für den OMW-Zeitraum 2010–2011 ausgeschlossen.

Ebenfalls nicht ohne neue periodenspezifische Entscheidung verwenden:

- GBU-49;
- GBU-54;
- Acht-Hellfire-Konfiguration;
- spätere Block-, Software- oder Waffenstände.

### OMW-Templates

Mindestens vorzusehen:

```text
UAV_MQ9_ISR_UNARMED
UAV_MQ9_ISR_ARMED_HELLFIRE
UAV_MQ9_ISR_ARMED_MIXED_HELLFIRE_GBU12
```

Eine reine GBU-12-Konfiguration kann ergänzt werden, wenn DCS- und Aufgabenverhalten dies rechtfertigen.

**Status:** historische Waffenfamilien `OFFICIAL_SOURCE_VERIFIED`; konkrete DCS-Payloads `PENDING_DCS_VALIDATION`

---

## 7. Flughöhen im normalen ISR-Setting

## 7.1 Grundproblem der Quellenlage

Für Afghanistan 2010–2011 wurde keine öffentlich zugängliche offizielle Vorschrift gefunden, die eine einzige allgemeingültige Standard-Orbithöhe für alle MQ-1- oder MQ-9-ISR-Missionen festlegt.

Die tatsächliche Höhe hing unter anderem ab von:

- Geländehöhe und Gebirgskämmen;
- Sensor-Sichtlinie und gewünschter Bildauflösung;
- Wetter, Wolkenuntergrenze und Sicht;
- Bedrohungslage;
- Luftraumstruktur und Deconfliction;
- Zielbewegung und Orbitgeometrie;
- Treibstoff, Beladung und gewünschter Einsatzdauer.

Technische Höchstflughöhe und normale Arbeitshöhe dürfen nicht verwechselt werden.

---

## 7.2 MQ-1B / Predator A

Eine offizielle USAF-Testdarstellung nennt:

```text
übliche Flughöhe: etwa 15.000 ft
technische Höhe: bis etwa 25.000 ft
```

Daraus folgt für OMW:

| Verwendung | OMW-Ausgangswert |
|---|---:|
| Standard-ISR über niedrigem bis mittlerem Gelände | 15.000 ft MSL |
| höherer Orbit bei Gelände-/Luftraumbedarf | 18.000–22.000 ft MSL |
| technische Obergrenze | ungefähr 25.000 ft MSL |

Die technische Obergrenze ist kein normaler Standardorbit.

**Status:** technische Referenz `OFFICIAL_SOURCE_VERIFIED`; OMW-Band `PROJECT_DECISION`

---

## 7.3 MQ-9 Reaper

Eine offizielle US-Army-Darstellung aus Dezember 2011 nennt für die MQ-9 eine typische Reiseflughöhe zwischen:

```text
15.000 und 20.000 ft
```

Die Plattform kann wesentlich höher fliegen; öffentlich angegebene Maximalwerte von ungefähr 50.000 ft beschreiben jedoch keine allgemeine Afghanistan-Arbeitshöhe.

Daraus folgt für OMW:

| Verwendung | OMW-Ausgangswert |
|---|---:|
| Standard-ISR / Overwatch | 18.000–22.000 ft MSL |
| höherer Orbit bei Gebirge, Wetter oder Deconfliction | 22.000–28.000 ft MSL |
| technische Obergrenze | bis ungefähr 50.000 ft MSL |

Ein Orbit nahe 50.000 ft wird nicht als Normalprofil verwendet.

**Status:** Reiseflughöhenreferenz `OFFICIAL_SOURCE_VERIFIED`; OMW-Band `PROJECT_DECISION`

---

## 7.4 Geländeabhängige OMW-Regel

Alle in diesem Dokument genannten Orbitwerte sind **MSL-Werte**. In Afghanistan ist zusätzlich die tatsächliche Geländefreiheit entlang des gesamten Orbits zu prüfen.

Verbindliche Planungsregel:

```text
Mindestanforderung:
Orbit-Höhe >= höchstes Gelände innerhalb und unmittelbar neben dem Orbit + 5.000 ft

Planungsziel, sofern Sensorik, Deconfliction und Plattformleistung es erlauben:
Orbit-Höhe >= höchstes Gelände + 8.000 ft
```

Für die MQ-1 darf die Geländeanforderung nicht durch einen unrealistischen Orbit oberhalb ihrer Leistungsgrenze gelöst werden. In solchen Fällen sind zu ändern:

- Orbitposition;
- Orbitform oder Radius;
- überwachte Talachse;
- Plattformwahl zugunsten der MQ-9;
- Aufteilung auf mehrere Sensorpositionen.

**Status:** `PROJECT_DECISION`

---

## 8. Verbindliche Missionsdesign-Baseline

| Muster | Primäre OMW-Rolle | Standard Combat-Template | Standardhöhe | Zeitgerechte Waffen |
|---|---|---|---:|---|
| MQ-1B / DCS-Predator-Ersatz | persistente ISR, lokale Overwatch, Zielverfolgung, BDA | bewaffnetes ISR-Template; unbewaffnete Variante zusätzlich | 15.000 ft MSL, geländeabhängig höher | bis zu 2 × AGM-114 |
| MQ-9 | persistente ISR, Overwatch, CAS-ready ISR, Hunter-Killer | bewaffnetes ISR-/Overwatch-Template; unbewaffnete Variante zusätzlich | 18.000–22.000 ft MSL, geländeabhängig höher | AGM-114 und/oder GBU-12 |

Diese Tabelle ist keine Behauptung, dass jede reale Sortie exakt so geflogen wurde. Sie ist die quellenbasierte OMW-Ausgangskonfiguration.

---

## 9. DCS- und MOOSE-Umsetzungsregeln

### 9.1 Getrennte Templates

Bewaffnung wird nicht während der Mission stillschweigend erfunden. Für jede Rolle sind getrennte Late-Activation-Templates beziehungsweise SQUADRON-Payloads anzulegen.

Mindestsatz:

```text
MQ-1:
- unbewaffnete ISR
- bewaffnete ISR mit Hellfire

MQ-9:
- unbewaffnete ISR
- Hellfire-ISR / Overwatch
- gemischte Hellfire-/GBU-12-Konfiguration
```

### 9.2 Auftrag und Waffenfreigabe

Die bloße Verfügbarkeit von Waffen erzeugt keine automatische Angriffserlaubnis.

Vor jedem AI-Waffeneinsatz sind die in `docs/moose/ISR-FAC-CAS-AAR.md` definierten Prüfungen anzuwenden, insbesondere:

- Zielklassifikation;
- Track-Qualität;
- ROE;
- Freundnähe;
- No-Strike- und No-Engage-Zonen;
- zivile und neutrale Objekte;
- Kollateralschadensrisiko;
- geeignete Waffenwirkung;
- BDA und weiterer Auftragsstatus.

### 9.3 MOOSE-First

Vor eigener UAV-Steuerlogik sind mindestens zu prüfen:

- `AUFTRAG:NewRECON()`;
- `AUFTRAG:NewFAC()` und `AUFTRAG:NewFACA()`;
- geeignete CAS-, BAI-, Bombing- und Precision-Bombing-Aufträge;
- `INTEL`;
- `TARGET`;
- `DESIGNATE`;
- `FLIGHTGROUP`;
- `AIRWING`, `SQUADRON`, `COMMANDER` und Payload-Verwaltung.

Jede Methode ist gegen die tatsächlich geladene MOOSE-Version, den Quellcode und eine DCS-Testmission zu validieren.

### 9.4 Kein versteckter ORBAT-Bestand

Templates, sichtbare Statics und aktive AI-Gruppen erhöhen nicht automatisch den logischen Kampagnenbestand. Ein UAV-Bestand wird erst nach ausdrücklicher aktiver ORBAT-Entscheidung geführt.

---

## 10. Noch offene Validierungen

1. Exakter DCS-Typname des Predator-AI-Objekts.
2. Abweichungen des DCS-Objekts vom historischen MQ-1B.
3. Verfügbare MQ-1- und MQ-9-Payload-IDs im aktuellen DCS-Stand.
4. Technisch zulässige gemischte MQ-9-Konfigurationen.
5. DCS-AI-Sensorreichweite und Erkennungsverhalten in 15.000 bis 28.000 ft MSL.
6. Orbitverhalten über Gebirgstälern und nahe hoher Kämme.
7. Wirkung von Wolken, Sichtweite und Nacht auf Detection, Designation und Angriff.
8. DCS-AI-Waffenwahl zwischen Hellfire und GBU-12.
9. MOOSE-RECON-, FAC-/FACA-, INTEL- und DESIGNATE-Verhalten mit den konkreten UAV-Typen.
10. Historisch und spielerisch vertretbarer aktiver OMW-UAV-Bestand.
11. Prüfung, ob neben Kandahar weitere OMW-Start- und Recovery-Knoten im Kampagnenzeitraum ausreichend belegt sind.

Bis zum Abschluss dieser Punkte bleibt `validated_in_dcs: false`.

---

## 11. Quellen

### Offizielle US-Quellen

1. U.S. Air Force, **Airmen reach 250K flying hours with remotely piloted aircraft**, 17. Juni 2010: 62nd ERS, MQ-1 und MQ-9 in Kandahar, ISR/CAS-Doppelrolle und zwei Hellfire für MQ-1.  
   <https://www.af.mil/News/Article-Display/Article/116362/airmen-reach-250k-flying-hours-with-remotely-piloted-aircraft/>

2. U.S. Air Forces Central, **Airmen demonstrate unmanned aircraft systems not merely ‘drones’**, 25. März 2009: waffentragende MQ-1/MQ-9, Hunter-Killer- und ISR-Rolle, Hellfire und 500-lb-Laserbomben. Die dort genannte Flughöhenpassage wird wegen des erkennbaren Widerspruchs zu den Plattformleistungsdaten nicht als Höhenquelle verwendet.  
   <https://www.afcent.af.mil/Units/379th-Air-Expeditionary-Wing/News/Display/Article/221240/airmen-demonstrate-unmanned-aircraft-systems-not-merely-drones/>

3. U.S. Air Force Photo, **MQ-9 Reaper on Patrol**, 27. Januar 2009: MQ-9 mit GBU-12 und AGM-114 auf Kampfmission über Südafghanistan.  
   <https://www.af.mil/News/Photos/igphoto/2000608254/mediaid/5461083/>

4. Edwards Air Force Base, **Air Force Flight Test Center's 452nd Flight Test Squadron stands up new detachment**, 22. November 2006: Predator A als bewaffnete RQ-1-Weiterentwicklung; üblicher Flug bei 15.000 ft, bis 25.000 ft.  
   <https://www.edwards.af.mil/News/Article/396584/air-force-flight-test-centers-452nd-flight-test-squadron-stands-up-new-detachme/>

5. U.S. Army, **MQ-9 'Reaper' finds training home at Fort Drum**, 2. Dezember 2011: Reiseflughöhe ungefähr 15.000 bis 20.000 ft. Die Quelle beschreibt Ausbildung, nicht eine allgemeine Afghanistan-SOP, und wird daher nur als zeitgerechte technische Arbeitsreferenz verwendet.  
   <https://www.army.mil/article/70093/mq_9_reaper_finds_training_home_at_fort_drum>

6. U.S. Air Force, **MQ-9 Reapers add to arsenal with first GBU-38 drop**, 8. Mai 2017: erste MQ-9-GBU-38-Integration; zuvor Hellfire und GBU-12.  
   <https://www.af.mil/News/Article-Display/Article/1175849/mq-9-reapers-add-to-arsenal-with-first-gbu-38-drop/>

7. U.S. Air Force, **MQ-9 Reaper takes flight with 8 Hellfire missiles**, 1. Oktober 2020: Acht-Hellfire-Fähigkeit als spätere Erweiterung; davor Begrenzung auf vier AGM-114.  
   <https://www.af.mil/News/Article-Display/Article/2367554/mq-9-reaper-takes-flight-with-8-hellfire-missiles/>

8. U.S. Air Force, **The evolution of the combat RPA**, 19. Dezember 2016: historische Entwicklung von zwei Hellfire bei MQ-1 zu vier Hellfire und zwei 500-lb-Bomben bei MQ-9.  
   <https://www.af.mil/News/Article-Display/Article/1032544/the-evolution-of-the-combat-rpa/>

### Quellenregel

Spätere Quellen werden ausschließlich verwendet, wenn sie eine frühere technische Grenze oder den Zeitpunkt einer späteren Integration ausdrücklich rückblickend benennen. Sie dürfen keine späteren Waffenstände in den OMW-Zeitraum zurückprojizieren.
