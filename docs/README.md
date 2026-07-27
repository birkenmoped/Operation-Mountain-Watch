---
document_id: OMW-GOV-DOCUMENTATION-INDEX
status: BINDING
document_class: DOCUMENTATION_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - documentation navigation
  - topic-to-source-of-truth mapping
  - document class and validation overview
not_authoritative_for:
  - document number reservations
  - runtime acceptance not explicitly listed
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# Operation Mountain Watch – Dokumentationsindex

## 1. Zweck

Dieser Index ist der zentrale Einstieg in die Projektdokumentation. Er ordnet Themen ihren verbindlichen Quellen, Arbeitsbaselines, Quellenreferenzen und Testnachweisen zu.

Für Dokumentnummern und stabile IDs bleibt ausschließlich verbindlich:

- [`OMW-GOV-DOCUMENT-REGISTRY`](DOCUMENT-REGISTRY.md)

Für Konflikte gilt die Hierarchie aus:

- [`OMW-GOV-001`](00-project-governance.md)

## 2. Autoritätshierarchie

1. `OMW-GOV-001` und ausdrückliche Projektinhaberentscheidungen auf `main`;
2. aktuelle `BINDING_PROJECT_DECISION`- und `BINDING`-Dokumente auf `main`;
3. exakt nachgewiesene technische Acceptance für den dokumentierten Branch-, Commit-, Missions-, Bundle-, DCS- und MOOSE-Stand;
4. Manifeste und Arbeitslisten, soweit sie nicht ersetzt sind;
5. historische Testberichte und Legacy-Evidenz;
6. externe Quellen für den tatsächlich belegten Inhalt.

## 3. Source-of-Truth-Matrix

| Thema | Autoritative Quelle | Klasse | Status | Nachgeordnete Quellen / Evidenz |
|---|---|---|---|---|
| Projekt-Governance | [`OMW-GOV-001`](00-project-governance.md) | Governance | `BINDING_PROJECT_DECISION` | ADRs, Fachbaselines |
| Dokumentnummern und IDs | [`OMW-GOV-DOCUMENT-REGISTRY`](DOCUMENT-REGISTRY.md) | Register | `BINDING_PROJECT_DECISION` | dieser Themenindex |
| Projektphase | [`OMW-GOV-001`](00-project-governance.md), [`OMW-PHASE-VERTICAL-PROTOTYPE`](14-prototype-scope.md) | Governance / Historie | `BINDING_PROJECT_DECISION` / `SUPERSEDED` | Legacy-Prototypdokumente |
| Historischer Rahmen | [`OMW-HIST-SETTING`](09-historical-setting.md) | Fachbaseline | `BINDING` | historische Quellen und ORBAT-Recherche |
| Systemarchitektur | [`OMW-ARCH-SYSTEM`](03-system-architecture.md) | Architektur | `BINDING` | Dokument 37 |
| MOOSE-First | [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md) | Governance | `BINDING_PROJECT_DECISION` | ADR-0001/0002 als ergänzte Historie |
| MOOSE-Version und Nachweise | [`OMW-GOV-MOOSE-VERSION`](moose/VERSION-AND-SOURCES.md) | Governance/Fachregel | `BINDING` | Klassenindex, verifizierte Methoden |
| CampaignState und dynamische Kampagne | [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md) | Architektur | `BINDING` | Dokumente 03–07, TM01/TM02-Reviews |
| aktive Luft-ORBAT und Clientgrenzen | [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md) | Projektentscheidung | `BINDING_PROJECT_DECISION` | ORBAT-Recherche, basisbezogene Manifeste |
| technische Luftoperationen | [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md) | Architektur | `BINDING` | MOOSE Air Operations |
| Air-Ops-Missionseditor-Ablauf | [`OMW-AIR-ME-WORKLIST`](20-air-orbat-mission-editor-worklist.md) | Worklist | `BINDING` | Dokument 38 |
| projektweite ME-Arbeitsliste | [`OMW-ME-MASTER-WORKLIST`](38-mission-editor-master-worklist.md) | Worklist | `BINDING` | basisbezogene Manifeste |
| Jalalabad-ME-Baseline | [`OMW-AIR-JBAD-MANIFEST`](21-jalalabad-air-operations-manifest.md) | Mission Editor Baseline | `BINDING` | PR #18 Acceptance, Evidenz-Audit |
| Bagram/Kandahar | PR #24, Dokumente 31–36 | Draft-Manifeste | `DRAFT` | basiert derzeit auf PR #18 |
| MSR-/Routendesign | [`OMW-MSR-ROUTE-DESIGN`](49-msr-routendesign-und-infrastrukturmarker.md) | Design/Worklist | `PLANNED` | Legacy-MSR-Entwurf |
| Air C2 und CAS | [`OMW-C2-AIR-C2-CAS-AFGHANISTAN`](45-air-c2-cas-afghanistan.md) | Source-derived Design Reference | `BINDING` | vollständige Quellenfassung als Evidenz |
| JTAC-/Air-Land-C2-Callsigns | [`OMW-C2-JTAC-CALLSIGNS`](27-oef-jtac-callsign-reference.md) | Source Reference | `BINDING` | Originalgrafik-/Quellenauswertung |
| Aircraft Tactical Callsigns | [`OMW-C2-AIRCRAFT-TACTICAL-CALLSIGNS`](47-aircraft-tactical-callsigns.md) | Source Reference | `BINDING` | vollständige Quellenfassung als Evidenz |
| Non-Lethal Use of Force | [`OMW-ROE-NON-LETHAL-USE-OF-FORCE`](46-non-lethal-use-of-force.md) | Source-derived Design Reference | `PLANNED` | SOP/SOF-Quellen, ein Beitrag ausstehend |
| NSL und Targeting | [`OMW-TARGETING-AFGHANISTAN-NSL`](48-afghanistan-no-strike-list.md) | Targeting Architecture | `BINDING` | [`NSL-Datenrichtlinie`](targeting/afghanistan-nsl-data-use-policy.md), Quelldatensatz |
| Quellen- und Dateinutzung | [`OMW-GOV-SOURCE-USE`](sources/graveyard-of-empires.md) | Governance/Fachregel | `BINDING_PROJECT_DECISION` | fachliche Quellenreferenzen |
| CSAR-Quellen und Anforderungen | [`OMW-CSAR-INDEX`](csar/README.md) | Source Series Index | `BINDING` | Source Notes, Facilities, Mission Requirements |
| Wetter 2010–2011 | Dokumente [41](41-historical-weather-baseline-2010-2011.md)–[44](44-dcs-valley-mist-low-cloud-test-profile.md) | Baseline / Testprofile | dokumentabhängig | Wetterdaten und DCS-Tests |
| technische Evidenz | [`OMW-EVIDENCE-INDEX`](evidence/README.md) | Evidenzindex | `BINDING` für Einordnung | Testberichte und Legacy-Quelldatensätze |

## 4. Nummerierte Dokumente auf `main`

### Grundlagen und Governance

- [00 – Projekt-Governance](00-project-governance.md)
- [01 – Vision](01-vision.md)
- [02 – Gameplay-Konzept](02-gameplay-concept.md)
- [03 – Systemarchitektur](03-system-architecture.md)
- [04 – CampaignState](04-campaign-state.md)
- [05 – Logistik](05-logistics.md)
- [06 – Red Director](06-red-director.md)
- [07 – Virtualisierung](07-virtualization.md)
- [08 – frühe CSAR-Grundlage](08-csar.md)
- [09 – historischer Rahmen](09-historical-setting.md)
- [10 – Operationsraum und Sektoren](10-theater-and-sectors.md)
- [11 – Basen und FOBs](11-bases-and-fobs.md)
- [12 – Routennetz](12-route-network.md)
- [13 – Einheitenkatalog](13-unit-catalog.md)
- [14 – ersetzter vertikaler Prototyp](14-prototype-scope.md)
- [15 – Template Library und Spawning](15-template-library-and-spawning.md)
- [16 – World Data und Routing](16-world-data-and-routing.md)
- [17 – Pathfinding-Optionen](17-pathfinding-options.md)

### Luftoperationen und MOOSE

- [18 – technische Luftoperationen](18-air-operations-implementation.md)
- [19 – aktive Luft-ORBAT](19-active-air-orbat-decisions.md)
- [20 – Air-Ops-ME-Arbeitsliste](20-air-orbat-mission-editor-worklist.md)
- [21 – Jalalabad-Manifest](21-jalalabad-air-operations-manifest.md)
- [26 – MOOSE-First](26-moose-first-development-policy.md)

### Kommunikation, C2, AAR und ROE

- [27 – OEF JTAC-/Air-Land-C2-Callsigns](27-oef-jtac-callsign-reference.md)
- [28 – TAD und Color Nets](28-afghanistan-tad-color-nets.md)
- [29 – ISAF AAR/ACO](29-isaf-2009-2013-air-to-air-refueling.md)
- [30 – AAR-Abbildungsreferenz](30-isaf-2009-2013-aar-part2-figure-reference.md)

### Produktionsarchitektur und Reviews

- [37 – Kampagnenarchitektur](37-campaign-architecture-and-dynamic-mission-design.md)
- [38 – Missionseditor-Masterarbeitsliste](38-mission-editor-master-worklist.md)
- [39 – TM01/TM02 MOOSE-First Review](39-tm01-tm02-moose-first-code-review.md)
- [40 – MOOSE-Adoptionsplan](40-moose-module-adoption-plan-for-tm01-tm02.md)

### Wetter

- [41 – historische Wetterbaseline](41-historical-weather-baseline-2010-2011.md)
- [42 – DCS-Wettereditor-Validierung](42-dcs-weather-editor-validation.md)
- [43 – Regen-/Schauerprofil](43-dcs-rain-shower-preset-validation.md)
- [44 – Talnebel-/Tiefe-Wolken-Profil](44-dcs-valley-mist-low-cloud-test-profile.md)

### Fach- und Quellenarchitektur

- [45 – Air C2 und CAS](45-air-c2-cas-afghanistan.md)
- [46 – Non-Lethal Use of Force](46-non-lethal-use-of-force.md)
- [47 – Aircraft Tactical Callsigns](47-aircraft-tactical-callsigns.md)
- [48 – Afghanistan No-Strike List](48-afghanistan-no-strike-list.md)
- [49 – MSR-Routendesign](49-msr-routendesign-und-infrastrukturmarker.md)

## 5. Thematische Unterverzeichnisse

### MOOSE

- [`docs/moose/README.md`](moose/README.md)
- [`VERSION-AND-SOURCES.md`](moose/VERSION-AND-SOURCES.md)
- [`PROJECT-CLASS-INDEX.md`](moose/PROJECT-CLASS-INDEX.md)
- [`VERIFIED-METHODS.md`](moose/VERIFIED-METHODS.md)
- [`AIR-OPERATIONS.md`](moose/AIR-OPERATIONS.md)
- [`GROUND-OPERATIONS.md`](moose/GROUND-OPERATIONS.md)
- [`LOGISTICS-AND-TRANSPORT.md`](moose/LOGISTICS-AND-TRANSPORT.md)
- [`EVENTS-AND-FSM.md`](moose/EVENTS-AND-FSM.md)
- [`ISR-FAC-CAS-AAR.md`](moose/ISR-FAC-CAS-AAR.md)

### CSAR

- [`CSAR-Index`](csar/README.md)
- [`Source Notes 1–8`](csar/source-notes-1-8.md)
- [`Afghanistan 2010 Facilities and Coverage`](csar/afghanistan-2010-facilities-and-coverage.md)
- [`Mission Design Requirements`](csar/mission-design-requirements.md)

### Quellen und Targeting

- [`Graveyard of Empires – Quellen- und Dateinutzung`](sources/graveyard-of-empires.md)
- [`Afghanistan NSL Data Use Policy`](targeting/afghanistan-nsl-data-use-policy.md)

### Evidenz und Historie

- [`Evidenzindex`](evidence/README.md)
- [`Jalalabad-Ausgangsaudit`](evidence/jalalabad-air-operations-baseline-audit.md)
- [`Legacy-Quelldatensätze`](evidence/source-records/)

## 6. Offene Branches

### PR #18

```text
Status: Draft
Branch: feature/jalalabad-air-operations-diagnostics
Technische Acceptance: branchgebunden
Merge nach main: nein
```

Dokumente 22–25 und eine kollidierende branchlokale Nummer 27 liegen ausschließlich dort.

### PR #24

```text
Status: Draft
Branch: docs/bagram-air-operations-manifest
Base: PR-#18-Branch
Merge nach main: nein
```

Dokumente 31–36 sind dafür reserviert.

## 7. Status- und Metadatenregel

Zulässige Governance-Statuswerte:

```text
DRAFT
PLANNED
ACCEPTED_TECHNICAL_BASELINE
BINDING_PROJECT_DECISION
BINDING
SUPERSEDED
HISTORICAL_TEST_FIXTURE
REJECTED
```

Quellen- und Bearbeitungszustände werden getrennt geführt, beispielsweise:

```yaml
document_class: SOURCE_REFERENCE
source_status: VERIFIED
validated_in_dcs: false
```

Begriffe wie `REFERENCE`, `PARTIAL`, `SOURCE_IMPORTED`, `SOURCE_CAPTURE_COMPLETE`, `GOE_POST_VERIFIED` oder `AUSSTEHEND` sind keine Governance-Dokumentstatuswerte.

## 8. Querverweisregel

- Verweise verwenden stabile ID und relativen Pfad.
- Branchdateien werden mit PR, Branch und Commit verlinkt.
- Historische Testberichte verweisen auf die ersetzende Fachbaseline.
- Fachbaselines verweisen auf Governance, MOOSE-First und zuständige Source of Truth.
- Quellenreferenzen dürfen keine eigenständige Projektentscheidung vortäuschen.
