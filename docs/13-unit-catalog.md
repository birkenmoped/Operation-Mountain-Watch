---
document_id: OMW-UNIT-CATALOG
status: PLANNED
document_class: TEMPLATE_AND_UNIT_CATALOG
owning_policy: OMW-GOV-001
authoritative_for:
  - planned identifier and metadata model for DCS units and templates
  - naming separation between templates, runtime groups and strategic entities
not_authoritative_for:
  - final complete unit catalog
  - unverified DCS type names
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: d2f45fa6424f22cbd13dd0cbfb9c59e7b0466a16
validated_in_dcs: false
---

# 13 – Einheiten- und Templatekatalog

## 1. Zweck

Der Katalog umfasst nur Einheiten, Gruppen, Templates und Luftfahrzeuge, die in der Kampagne tatsächlich verwendet werden.

Der vollständige frühere Katalogentwurf bleibt unverändert erhalten:

- [`Legacy-Einheiten- und Templatekatalog`](evidence/source-records/legacy-13-unit-catalog.md)

Historische Einheits-, Standort-, Zeitraum- und Stärkenbelege werden aus folgender Referenz übernommen:

- [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION`](50-afghanistan-force-basing-aviation-2010-2011.md)

Die Aufnahme einer historischen Einheit in die Recherche erzeugt noch kein DCS-Template und keinen aktiven CampaignState-Bestand.

## 2. Vier getrennte Identifikatoren

1. DCS-Typname aus der tatsächlich verwendeten DCS-Version;
2. Mission-Editor-Gruppenname des Templates;
3. Mission-Editor-/Laufzeit-Einheitenname;
4. stabile strategische CampaignState-Entity-ID.

DCS- und MOOSE-Laufzeitnamen dürfen nicht als persistente strategische Primärschlüssel verwendet werden.

Zusätzlich besitzt jede historisch abgeleitete Einheit einen stabilen Research-Identifier:

```text
HIST_<NATION>_<UNIT>_<PERIOD_OR_ROTATION>
```

Research-Identifier und aktive CampaignState-Entity-ID sind nicht identisch.

## 3. Namensregeln

```text
TPL_<COALITION>_<ROLE>_<VARIANT>
```

Das Zeichen `#` wird in eigenen Template- und Aliasnamen nicht verwendet, weil MOOSE es für Laufzeitsuffixe nutzt.

## 4. Pflichtmetadaten je Template

### 4.1 Technische Felder

- Template-Gruppenname;
- Koalition und Land;
- operative Rolle;
- Zusammensetzung und Gruppengröße;
- bestätigte DCS-Typnamen;
- Skill, Formation, Bewaffnung und Loadout;
- Ressourcen- und Wiederbeschaffungskosten;
- Transport- oder Frachtkapazität;
- erlaubte Missionsarten und Geländearten;
- Modul- oder Modabhängigkeiten;
- DCS- und MOOSE-Validierungsstatus.

### 4.2 Historische Provenienzfelder

Jede historisch begründete Einheit beziehungsweise Variante führt zusätzlich:

```text
historicalResearchId
historicalSourceIds
evidenceClass
effectiveFrom
effectiveTo
homeBase
forwardDetachments
parentPoolId
strengthValue
strengthBasis
configurationNotes
sourceConflict
activeDecisionSource
```

Bedeutung:

- `historicalSourceIds`: Quellen-IDs aus Dokument 50;
- `evidenceClass`: beispielsweise `DIRECT_OFFICIAL`, `SECONDARY`, `VISUAL_CONFIRMED`;
- `effectiveFrom/effectiveTo`: belegter oder begrenzter Zeitraum;
- `homeBase`: ausdrücklich belegter Haupt- oder Einsatzstandort;
- `forwardDetachments`: vorgeschobene, vom Parent-Pool abzuziehende Elemente;
- `strengthValue`: nur bei belegter oder ausdrücklich als Schätzung gekennzeichneter Stärke;
- `strengthBasis`: Quelle, Berechnung oder bewusste Projektentscheidung;
- `configurationNotes`: Varianten, Selbstschutz, Bewaffnung oder DCS-Ersatz;
- `sourceConflict`: offene widersprüchliche Angaben;
- `activeDecisionSource`: bei aktiver Verwendung grundsätzlich Dokument 19 oder ein nicht widersprechendes Basenmanifest.

## 5. Historische Research-Einträge

Die folgenden Einträge sind **Rechercheobjekte**, keine automatisch aktiven Templates oder Bestände.

### 5.1 TF Lighthorse / 3-17 CAV

```yaml
historicalResearchId: HIST_US_3_17_CAV_TF_LIGHTHORSE_2009_2010
unit: 3rd Squadron, 17th Cavalry Aviation Regiment
rotationName: Task Force Lighthorse
homeBase: Jalalabad Airfield / FOB Fenty
effectiveFrom: 2009-11
effectiveTo: 2010-11-18
aircraftFamilies:
  - OH-58D
  - AH-64D
  - UH-60
  - CH-47
historicalSourceIds: [S08]
evidenceClass: DIRECT_OFFICIAL
strengthValue: null
strengthBasis: Rotation performance is documented; local aircraft count is not stated by S08
activeDecisionSource: OMW-AIR-ACTIVE-ORBAT
```

### 5.2 TF Shooter / 6-6 CAV

```yaml
historicalResearchId: HIST_US_6_6_CAV_TF_SHOOTER_2010_2011
unit: 6th Squadron, 6th Cavalry Aviation Regiment
rotationName: Task Force Shooter
homeBase: Jalalabad Airfield / FOB Fenty
effectiveFrom: 2010-11-18
effectiveTo: 2011
historicalSourceIds: [S08, S05]
evidenceClass: DIRECT_OFFICIAL
strengthValue: null
strengthBasis: Historical task-force presence; active OMW strength is a separate project decision
activeDecisionSource: OMW-AIR-ACTIVE-ORBAT
```

### 5.3 2-17 CAV / Task Force Destiny

```yaml
historicalResearchId: HIST_US_2_17_CAV_TF_DESTINY_2010
unit: 2nd Squadron, 17th Cavalry Regiment
elements:
  - Delta Troop OH-58D pilots and maintenance
  - E Troop FARP personnel
homeBase: Kandahar Airfield
forwardDetachments:
  - FOB Wilson FARP
  - FOB Wolverine Banshee detachment context
historicalSourceIds: [S12, S13, S14]
evidenceClass: CORROBORATED
strengthValue: null
strengthBasis: Local presence and functions documented; complete squadron inventory not stated
activeDecisionSource: null
```

Die genaue organisatorische Zuordnung des Banshee-Detachments bleibt nach der Quellenformulierung gesondert zu prüfen und wird nicht allein aus dem Troop-Namen abgeleitet.

### 5.4 B Company, 2-3 Aviation

```yaml
historicalResearchId: HIST_US_B_2_3_AVN_BGRM_2010
unit: B Company, 2d Battalion, 3d Aviation Regiment
aircraftFamily: CH-47
homeBase: Bagram Airfield
effectiveFrom: 2010
effectiveTo: 2010
historicalSourceIds: [S05]
evidenceClass: SECONDARY
strengthValue: 2
strengthBasis: At least two Bagram aircraft directly participated in Operation Talon Purge; not total company strength
sourceConflict: null
```

### 5.5 168th Aviation / FOB Shank Element

```yaml
historicalResearchId: HIST_US_168_AVN_SHANK_2010
unit: 168th Aviation Regiment element
aircraftFamily: CH-47
homeBase: FOB Shank
effectiveFrom: 2010
effectiveTo: 2010
historicalSourceIds: [S05]
evidenceClass: SECONDARY
strengthValue: 2
strengthBasis: Working Paper explicitly describes two Chinooks in the cited phase
sourceConflict: Main text says D Company 1-169 AVN; footnote says B Company 1-169 GSAB
```

### 5.6 B Company, 3-10 GSAB

```yaml
historicalResearchId: HIST_US_B_3_10_GSAB_RCE_2010
unit: B Company, 3d Battalion, 10th General Support Aviation Battalion
aircraftFamily: CH-47
homeBase: split-based
forwardDetachments:
  - Jalalabad: direct support
  - Bagram: RC-East general support
effectiveFrom: 2010
effectiveTo: 2011
historicalSourceIds: [S05]
evidenceClass: SECONDARY
strengthValue: null
strengthBasis: Several aircraft at Jalalabad; exact local split not given
```

### 5.7 B Company, 7-158 AVN

```yaml
historicalResearchId: HIST_US_B_7_158_AVN_RCE_2011
unit: B Company, 7th Battalion, 158th Aviation Regiment
aircraftFamily: CH-47
homeBase: FOB Salerno
forwardDetachments:
  - Bagram Airfield
  - FOB Shank
effectiveFrom: 2011-04
effectiveTo: 2011
historicalSourceIds: [S05]
evidenceClass: SECONDARY
strengthValue: 25
strengthBasis: 19 organic CH-47 plus 6 aircraft and crews from B/2-135 GSAB
sourceConflict: Exact 25-aircraft split by location is not stated
```

### 5.8 159th CAB CH-47 Elements

```yaml
historicalResearchId: HIST_US_159_CAB_CH47_RCS_2011
parentUnit: 159th Combat Aviation Brigade
elements:
  - B Company, 7-101 AVN: CH-47F
  - B Company, 1-171 AVN: CH-47D
  - B Company, 1-52 AVN: CH-47D
homeBase: Kandahar Airfield
forwardDetachments:
  - Tarinkot
  - FOB Wolverine
effectiveFrom: 2011-02
effectiveTo: 2011
historicalSourceIds: [S05]
evidenceClass: SECONDARY
strengthValue: null
strengthBasis: Majority at Kandahar; platoons forward; exact local split incomplete
sourceConflict: B/1-171 is also described as split-based at Bagram, Kandahar, Salerno and Shank
```

### 5.9 USAF-Stichtagseinheiten

S06 darf für folgende Research-Einträge verwendet werden:

- Bagram: 774 EAS/C-130J, 41 EECS/EC-130H, 492 EFS/F-15E, 510 EFS/F-16C, 4 ERS/MC-12W, 56 RQS/HH-60G, VMAQ-3/EA-6B;
- Kandahar: 702 EAS/C-27J, 772 EAS/C-130J, 42 EATKS/MQ-9, 75 EFS/A-10C, 62 ERS/MQ-1B, 26 und 46 RQS/HH-60G;
- Shindand: 838 AEAG/444 AEAS;
- Jalalabad, Kabul, Herat und Mazar-e Sharif: Air-Advisor-Elemente.

Für alle diese Einträge gilt:

```yaml
effectiveDate: 2011-09-30
strengthValue: null
strengthBasis: Unit presence list without aircraft count
scopeWarning: USAF/AETF-A centered; not a complete Army aviation ORBAT
```

## 6. Konfigurationsmetadaten OH-58D

Für OH-58D-Templates beziehungsweise Livery-/Static-Varianten dürfen folgende quellenqualifizierte Hinweise geführt werden:

| Konfiguration | Zeitraum/Ort | Evidenz | Quelle |
|---|---|---|---|
| sichtbarer AN/ALQ-144-Familien-Störsender | 31.01.2011, Kandahar | `VISUAL_CONFIRMED` | Dokument 50, S10 |
| M260-artiger Siebenrohr-Raketenbehälter | 31.01.2011, Kandahar | `VISUAL_CONFIRMED` auf Systemfamilienebene | S10 |
| gegenüberliegender Zweifachträger mit wahrscheinlich zwei Hellfire | 31.01.2011, Kandahar | `VISUAL_PROBABLE` | S10 |
| kein sichtbarer AN/ALQ-144 an zwei Maschinen | März 2012, Jalalabad | `POST_PERIOD_CONTEXT` | S16 |
| Raketen und .50-cal-Bewaffnung | März 2012, Jalalabad | `POST_PERIOD_CONTEXT` | S16 |

Ein Test-Fire-Foto legt keine Standardhäufigkeit fest. Exakte Hellfire-Untervarianten werden nicht geraten.

## 7. Missionsrollen als Templatefamilien

Quellenbasierte Templatefamilien:

```text
TPL_BLUE_RECON_OH58D_TWO_SHIP
TPL_BLUE_ESCORT_AH64D_TWO_SHIP
TPL_BLUE_AIR_ASSAULT_CH47_TWO_SHIP
TPL_BLUE_AIR_ASSAULT_CH47_FOUR_SHIP
TPL_BLUE_UTILITY_UH60_TWO_SHIP
TPL_BLUE_MEDEVAC_UH60_LEAD
TPL_BLUE_MEDEVAC_UH60_COVER
TPL_BLUE_FARP_SUPPORT
TPL_BLUE_FIXED_WING_CAS
TPL_BLUE_FIXED_WING_OVERWATCH
```

Die Templategröße ist keine Bestandszahl. `SQUADRON:New(..., Ngroups, ...)` zählt Gruppen und muss gegen die jeweilige Template-Gruppengröße umgerechnet werden.

## 8. Validierungsregel

Interne DCS-Typnamen werden aus der verwendeten DCS-Version per Testmission und Diagnose ausgelesen. Unsichere externe Listen gelten nicht als technische Wahrheit.

Vor Aktivierung eines historisch abgeleiteten Templates sind zu prüfen:

- Quelle und Evidenzklasse;
- aktive Entscheidung in Dokument 19;
- korrekte Parent-/Detachment-Abbuchung;
- DCS-Typname;
- Payload und Livery;
- Gruppenstärke gegen logischen Bestand;
- Parking und Rotorabstand;
- MOOSE-AIRWING-/SQUADRON-Verhalten;
- Modabhängigkeiten;
- DCS- und MOOSE-Version.

Die konkrete Template-Bibliothek und die Spawnstrategie stehen in Dokument 15. Aktive Luftfahrzeugbestände und Client-Grenzen stehen in Dokument 19.
