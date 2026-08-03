---
document_id: OMW-EVIDENCE-TARINKOT-AVIATION-2011
status: BINDING
document_class: HISTORICAL_BASING_AND_UNIT_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - contemporaneous 2011 evidence for AH-64, UH-60, and CH-47 presence at FOB Tarin Kowt
  - historical Task Force Attack / 3-101 Aviation Regiment association at Tarin Kowt
  - B Company, 1-52 Aviation Regiment CH-47D detachment at Tarin Kowt
  - separation of aircraft-presence evidence from exact local inventory claims
not_authoritative_for:
  - exact total 2011 Tarinkot aircraft inventory
  - mission-ready rates
  - exact UH-60 subordinate company identity
  - DCS or MOOSE runtime acceptance
scenario_period: 2010-08-01/2011-12-31
source_branch: agent/tarinkot-object-contract-reconciliation
validated_in_dcs: false
evidence_state: REVIEWED
project_phase: TARINKOT_OBJECT_CONTRACT_RECONCILIATION
source_commit: PENDING_MERGE
supersedes: []
superseded_by: []
---

# Tarinkot – Aviation-Einheiten und Luftfahrzeugpräsenz 2011

## 1. Zweck

Dieses Dokument prüft, ob die Tarinkot-Stationierung von UH-60 Black Hawk und CH-47 Chinook ausschließlich aus den dokumentierten Satellitenbildern von Mai 2012 abgeleitet werden muss oder ob inzwischen zeitgenössische Text- und Bildquellen für 2011 vorliegen.

Ergebnis:

```text
CH-47-Präsenz 2011: zeitgenössisch und einheitsbezogen belegt
UH-60-Präsenz 2011: zeitgenössisch und Task-Force-bezogen belegt
exakte lokale Stückzahlen 2011: weiterhin nicht textlich belegt
```

## 2. Quellenhierarchie

Für historische Einheits- und Stationszuordnungen gilt:

1. offizielle zeitgenössische militärische Quelle mit Datum, Standort und Einheit;
2. Juli-2011-ORBAT als theaterweite Standardautorität;
3. qualifizierte Sekundärquelle mit nachvollziehbarer Stations- und Rotationsauswertung;
4. zeitnahe Satellitenbeobachtung für Typ, Mindestzahl, Rampennutzung und Größenordnung;
5. Mission-Editor-Objekte ausschließlich als technische Projektabbildung.

Satellitenbilder und Mission-Editor-Namen erzeugen keine historische Verbandsidentität.

## 3. Juli-2011-ORBAT

Die Juli-2011-ORBAT nennt:

```text
Task Force Attack / 3-101 Attack Aviation
Commander: Lt. Col. Rod Hynes
Standort: FOB Tarin Kowt
Auftrag: Aviation Support in Uruzgan Province
```

Übergeordnet:

```text
Task Force Thunder / 159th Combat Aviation Brigade
Standort des Brigade-Hauptquartiers: Kandahar Airfield
Auftrag: Aviation Support RC South
```

Die ORBAT belegt damit den lokalen Aviation-Task-Force-Knoten und seinen Parent. Sie nennt für Tarin Kowt jedoch keine vollständige Typen- oder Stückzahlliste.

## 4. Offizieller Direktbeleg vom 11. September 2011

Eine offizielle Aufnahme der 159th Combat Aviation Brigade Public Affairs vom 11.09.2011 trägt die Bildbeschreibung:

```text
Two AH-64 Apaches, a UH-60 Black Hawk, and a CH-47 Chinook
from Task Force Attack (3rd Battalion, 101st Aviation Regiment)
conduct a fly-over at Forward Operating Base Tarin Kowt.
```

Quellenidentifikation:

```yaml
publisher: Defense Visual Information Distribution Service / U.S. Army
VIRIN: 110911-A-CK382-001
DVIDS photo ID: 454567
dateTaken: 2011-09-11
location: Forward Operating Base Tarin Kowt, Afghanistan
credit: Sgt. Shanika Futrell, 159th Combat Aviation Brigade Public Affairs
```

Damit ist innerhalb des OMW-Zeitraums direkt belegt:

- AH-64 am FOB Tarin Kowt;
- UH-60 Black Hawk am FOB Tarin Kowt;
- CH-47 Chinook am FOB Tarin Kowt;
- operative Zuordnung aller drei an diesem Ereignis beteiligten Typen zu Task Force Attack / 3-101 Aviation Regiment.

Die Quelle beweist eine zeitgenössische Mindestpräsenz, aber nicht den vollständigen lokalen Bestand.

## 5. CH-47 – B Company, 1-52 Aviation Regiment

### 5.1 Offizielle Stations- und Detachmentquelle

Der offizielle Beitrag `TF Thunder welcomes Alaskan assets` vom 27.07.2011 dokumentiert:

```text
Team Denali / 1st Battalion, 52nd Aviation Regiment
Companies B (Sugar Bears) and D
CH-47D Chinook
Einsatzbeginn in southern Afghanistan: June 2011
Attachment: Task Force Lift / 7th Battalion, 101st Aviation Regiment
```

Der Beitrag nennt ausdrücklich:

```text
Capt. Robert Bender
Detachment commander for B/1-52 at FOB Tarin Kowt
```

Quellenidentifikation:

```yaml
publisher: 159th Combat Aviation Brigade Public Affairs / DVIDS / U.S. Army
story: TF Thunder welcomes Alaskan assets
storyId: 75775
dateTaken: 2011-07-27
author: Spc. Jennifer Andersson
```

### 5.2 Weitere lokale Bestätigung

Weitere offizielle Beiträge bestätigen B/1-52 am Standort:

```yaml
2011-09-16:
  title: Enduring Freedom: SGT Daniel Scott
  publisher: DVIDS / AFN Afghanistan
  location: Tarin Kowt
  statement: Soldier of Bravo Company, 1-52 Aviation Regiment works with CH-47 Chinooks

2011-10-18:
  title: Enduring Freedom: Sugar Bears, Capt. Travis Easterling
  publisher: DVIDS / AFN Afghanistan
  location: Tarin Kowt
  statement: Soldiers with B Company, 1-52 Aviation Regiment operate CH-47 Chinooks
```

### 5.3 Organisationsgrenze

Für den CH-47-Pool sind zwei gleichzeitig wahre Ebenen zu unterscheiden:

```text
administrative / unit identity:
B Company, 1-52 Aviation Regiment / Sugar Bears

regional attachment:
Task Force Lift / 7-101 Aviation under Task Force Thunder / 159th CAB

local operational task-force association:
Task Force Attack / 3-101 Aviation Regiment at FOB Tarin Kowt
```

Der lokale MOOSE-SQUADRON-Name soll die spezifischste sicher belegte fliegende Einheit verwenden:

```text
SQ_US_TKOT_CH47_B_1_52_AVN
```

`Task Force Attack` bleibt der lokale AIRWING-/Operationsknoten; es wird nicht behauptet, B/1-52 sei organischer Bestandteil von 3-101 Attack Aviation gewesen.

### 5.4 Mustergrenze

Historisch belegt ist für B/1-52:

```text
CH-47D
```

Die aktuelle OMW-MIZ verwendet technisch:

```text
CH-47Fbl1
```

Dies ist eine gekennzeichnete DCS-Ersatzdarstellung und keine historische Behauptung.

## 6. UH-60 Black Hawk

### 6.1 Innerhalb des OMW-Zeitraums belegt

Der offizielle Direktbeleg vom 11.09.2011 weist mindestens einen UH-60 Black Hawk am FOB Tarin Kowt aus und ordnet das beteiligte Luftfahrzeug Task Force Attack / 3-101 Aviation Regiment zu.

Zusätzlich zeigt eine offizielle Aufnahme vom 14.10.2010 australische Spezialkräfte beim Besteigen eines UH-60 Black Hawk am FOB Tarin Kowt. Diese Aufnahme belegt ebenfalls den Typ am Standort innerhalb des OMW-Zeitraums, löst aber die betreibende Company nicht auf.

### 6.2 Noch nicht aufgelöst

Bislang nicht sicher belegt ist:

- die exakte UH-60-Company beziehungsweise das administrative Herkunftsbataillon im 2011er Task-Force-Mix;
- ob alle lokal eingesetzten UH-60 dauerhaft stationiert oder teilweise rotations-/missionsweise präsent waren;
- die exakte lokale Stückzahl 2011;
- eine separate 2011er MEDEVAC-Company am Standort.

Der technisch-historische Name darf daher nur die belegte Task-Force-Zuordnung ausdrücken:

```text
SQ_US_TKOT_UH60_TF_ATTACK
```

Nicht zulässig ohne weitere Quelle:

```text
Company- oder Battalion-Bezeichnung für den UH-60-Pool
eigenständige MEDEVAC-Einheitsidentität
Zuordnung zu TF Lift / 7-101 allein aus dem Muster
```

## 7. Abgleich mit den Satellitenbildern von Mai 2012

Die dokumentierten Aufnahmen vom 03.05.2012 und 17.05.2012 zeigen:

| Muster | sichtbar am 17.05.2012 |
|---|---:|
| AH-64 | 14 |
| UH-60 | 6 |
| CH-47 | 1 |
| OH-58D | 0 bestätigt |

Diese Bilder bleiben `POST_PERIOD_CONTEXT`. Sie sind stark für:

- Typidentifikation;
- sichtbare Mindestzahlen am Aufnahmetag;
- Rampenbelegung und Größenordnung;
- räumliche Trennung der Muster.

Sie sind nicht allein ausreichend für:

- exakte 2011er Sollstärke;
- historische Einheitsnamen;
- vollständigen Bestand einschließlich Luftfahrzeugen im Flug oder in Wartung.

Durch die neuen offiziellen 2011er Belege ist die Typenpräsenz von UH-60 und CH-47 nicht mehr ausschließlich satellitenbildbasiert. Die Satellitenbilder bleiben jedoch die wichtigste Grundlage für die lokale Größenordnung, insbesondere die sechs sichtbaren UH-60.

## 8. Evidenzmatrix

| Aussage | Status | Beste Quelle |
|---|---|---|
| Task Force Attack / 3-101 am FOB Tarin Kowt | `CONFIRMED` | Juli-2011-ORBAT |
| AH-64 am Standort 2011 | `CONFIRMED` | offizieller Direktbeleg 11.09.2011 |
| UH-60 am Standort 2011 | `CONFIRMED` | offizieller Direktbeleg 11.09.2011 |
| CH-47 am Standort 2011 | `CONFIRMED` | offizieller Direktbeleg und B/1-52-Quellen |
| B/1-52 CH-47D-Detachment am Standort | `CONFIRMED` | 159th CAB PAO, Juli 2011 |
| exakte UH-60-Untereinheit 2011 | `UNRESOLVED` | keine ausreichend spezifische Quelle |
| 14 AH-64 im OMW-Zeitraum | `RECONSTRUCTED` | post-period visual context |
| 6 UH-60 im OMW-Zeitraum | `RECONSTRUCTED` | post-period visual context |
| 2 CH-47 im OMW-Zeitraum | `RECONSTRUCTED` | Detachment evidence plus OMW inventory decision; nicht exakt textbelegt |

## 9. Konsequenz für den Objektvertrag

```text
AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

Die Benennung folgt damit jeweils der sichersten verfügbaren Quelle:

- AH-64: Task Force Attack / 3-101;
- UH-60: Task Force Attack, Company noch offen;
- CH-47: B Company, 1-52 Aviation Regiment, lokal Task Force Attack unterstützt.

Die Evidenzänderung autorisiert noch keine Lua-Implementierung. Der Objektvertrag muss zuerst entsprechend aktualisiert und angenommen werden.
