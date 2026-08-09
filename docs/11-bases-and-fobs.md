---
document_id: OMW-BASES-FOBS
status: PLANNED
document_class: BASE_AND_FOB_MODEL
owning_policy: OMW-GOV-001
authoritative_for:
  - planned campaign functions and common metadata of bases, FOBs, COPs and checkpoints
not_authoritative_for:
  - active air ORBAT
  - final Mission Editor object state
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - vertical-prototype-only base sequence
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: 6ba400be6ae0748aeb8722ad53669b7bc2ae9f13
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
| COP Honaker-Miracle | `GROUND_BASE_ONLY` | isolierter, gehaltener COP | Dokument 50, S01 |
| COP Stout | `GROUND_BASE_ONLY` | Hamkari-/Arghandab-Außenposten | Dokument 50, S01 |
| Außenposten Babur | `GROUND_BASE_ONLY` | nördlicher Folgeaußenposten, Name offen | Dokument 50, S01 |
| Patrol Base Dakota | `GROUND_BASE_ONLY` | Marjah Hold-/Build-Basis | Dokument 50, S01 |
| FOB Kunduz | `GROUND_BASE_ONLY` | 1-87 Infantry / RC-North | Dokument 50, S01 |
| FOB Pul-e-Khumri | `GROUND_BASE_ONLY` | 1-87 Infantry / RC-North | Dokument 50, S01 |

Diese Tabelle klassifiziert historische Funktionen. Sie ist keine Mission-Editor-Abnahme und legt keine aktiven Flugzeugzahlen fest.

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
