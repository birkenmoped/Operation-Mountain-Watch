---
document_id: OMW-AIR-JBAD-MANIFEST
status: BINDING
document_class: MISSION_EDITOR_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - Jalalabad-specific Mission Editor naming and object structure
  - application of the active Jalalabad ORBAT from OMW-AIR-ACTIVE-ORBAT
  - Jalalabad client, template, static, warehouse and zone authoring requirements
not_authoritative_for:
  - project-wide air ORBAT
  - project-wide client limits
  - branch-independent technical acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - pre-governance Jalalabad manifest with 24/8/6/0 inventory
  - four-client-per-type Jalalabad authoring rule
  - generic Jalalabad AIRWING name AW_US_JALALABAD
superseded_by:
source_branch: agent/airwing-naming-reconciliation
source_commit: b5345112f78e744018da59ebe45281dd12f8e3f8
validated_in_dcs: false
---

# 21 – Jalalabad Air Operations Manifest

## 1. Autorität und Abgrenzung

Dieses Manifest ist die aktuelle Jalalabad-spezifische Missionseditor-Arbeitsbaseline auf `main`.

Vorrangige Quellen:

- [`OMW-GOV-001`](00-project-governance.md) – Governance, Projektphase und Autorität;
- [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md) – aktive Verbände, Bestände und Client-Obergrenzen;
- [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md) – technische Bestands- und Darstellungsregeln;
- [`OMW-AIR-ME-WORKLIST`](20-air-orbat-mission-editor-worklist.md) – gemeinsamer Foundation-Build-Ablauf;
- [`OMW-ME-MASTER-WORKLIST`](38-mission-editor-master-worklist.md) – projektweite Missionseditor-Arbeitsliste.

Dieses Dokument wiederholt keine eigenständige ORBAT- oder Client-Entscheidung. Es setzt die jeweils verbindlichen Werte aus Dokument 19 für Jalalabad um.

Der vollständige frühere Manifesttext bleibt unverändert erhalten:

- [`Legacy-Manifest vor Governance-Migration`](evidence/source-records/legacy-21-jalalabad-air-operations-manifest-pre-governance.md)

## 2. Verbindlicher logischer Jalalabad-Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
-------------------
48 Luftfahrzeuge
```

Der logische Bestand ist strikt getrennt von:

- Client-Reservierungen;
- aktiven KI-Luftfahrzeugen;
- Late-Activation-Templates;
- sichtbaren Statics;
- virtueller Reserve;
- beschädigten und endgültig verlorenen Luftfahrzeugen.

## 3. Client-Gruppen

Projektweit gilt die Obergrenze aus Dokument 19:

```text
maximal 2 Client-Luftfahrzeuge je Muster und Basis
maximal 2 Client-Gruppen je Muster und Basis
1 Luftfahrzeug je Client-Gruppe
```

### 3.1 Verpflichtende modfreie Gruppen

```text
CLIENT_US_JBAD_OH58D_01
CLIENT_US_JBAD_OH58D_02

CLIENT_US_JBAD_AH64D_01
CLIENT_US_JBAD_AH64D_02

CLIENT_US_JBAD_CH47_01
CLIENT_US_JBAD_CH47_02
```

### 3.2 Optionale UH-60L-Modvariante

```text
CLIENT_US_JBAD_UH60L_01
CLIENT_US_JBAD_UH60L_02
```

Für die Kernmission sind nur `0` oder `2` UH-60L-Client-Gruppen zulässig. Eine Modabhängigkeit darf die modfreie Kernmission nicht unbrauchbar machen.

## 4. KI-Templates

Alle KI-Vorlagen werden als `Late Activation` geführt und nicht als zusätzlicher Bestand gezählt:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP       2 OH-58D
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP         2 AH-64D
TPL_AIR_US_JBAD_UH60_MEDEVAC_1SHIP      1 UH-60A
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP    1 CH-47F
```

Für UH-60 wird ein gemeinsamer physischer Single-Ship-Seed verwendet. Unterschiedliche spätere MOOSE-Rollen wie MEDEVAC Lead und Cover werden über Payload-/Missionsfähigkeiten abgebildet und erzeugen keine zusätzlichen Mission-Editor-Templates.

## 5. MOOSE-Struktur

```text
AW_US_JBAD_TF_SHOOTER_6_6_CAV
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

Der AIRWING-Identifier bildet den aktiven Jalalabad-/FOB-Fenty-Army-Aviation-Knoten nun verbandsbezogen ab und supersediert den früheren generischen technischen Namen `AW_US_JALALABAD`. Die SQUADRON-IDs, Warehouse-, Template-, Parking- und Bestandsverträge bleiben unverändert.

Die produktive Implementierung bleibt MOOSE-first. Jede projektspezifische Ergänzung benötigt das vollständige Ausnahmeverfahren aus Dokument 26.

## 6. Sichtbare Bestands-Statics

Die auf PR #18 technisch geprüfte Ramp-Darstellung lautet:

```text
7 OH-58D-Statics
4 AH-64D-Statics
4 UH-60A-Statics
5 CH-47F-Statics
```

Diese 20 Statics sind Teil des logischen Bestands und kein Zusatzbestand. Eine spätere Anpassung der sichtbaren Zahl ist zulässig, wenn Parkraum, Performance oder Missionsdesign dies erfordern und der Bestandsbezug erhalten bleibt.

## 7. Warehouse, Zonen und Flächen

Warehouse-Anker:

```text
WH_AIR_US_JALALABAD
```

Funktionszonen:

```text
ZONE_AIR_US_JBAD_STATIC_OH58D
ZONE_AIR_US_JBAD_STATIC_AH64D
ZONE_AIR_US_JBAD_STATIC_UH60
ZONE_AIR_US_JBAD_STATIC_CH47
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_CH47_READY
ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

Client-, KI-, Static-, Bereitschafts-, Logistik- und Entladeflächen müssen räumlich getrennt und auf Kollisionen geprüft werden.

## 8. Branchgebundene technische Acceptance

Die vollständige Jalalabad-Node-Acceptance liegt weiterhin ausschließlich auf:

```yaml
pr: 18
branch: feature/jalalabad-air-operations-diagnostics
head_commit: 734de196b37730c291edb892936a7dc685d88dc6
merged_to_main: false
status: ACCEPTED_TECHNICAL_BASELINE
```

Sie beweist den dort dokumentierten Missions-, Bundle-, DCS- und MOOSE-Stand mit dem damaligen AIRWING-Identifier. Dieses Manifest übernimmt die governance-konformen Sollwerte und den neuen verbandsbezogenen AIRWING-Identifier, behauptet aber keine neue branchunabhängige DCS-Acceptance für die Umbenennung.

## 9. Noch nicht produktiv akzeptiert

- taktische `AUFTRAG`-Ausführung;
- `OPSTRANSPORT`-Missionsketten;
- vollständiger 1+1-MEDEVAC-Koordinator;
- persistente Verlust-, Rückkehr- und Ramp-Neuverteilung;
- produktive CampaignState-Anbindung;
- Multiplayer- und Langzeitvalidierung des vollständigen Knotens.
