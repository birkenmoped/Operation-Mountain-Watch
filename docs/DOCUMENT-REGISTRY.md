---
document_id: OMW-GOV-DOCUMENT-REGISTRY
status: BINDING_PROJECT_DECISION
document_class: DOCUMENT_REGISTRY
owning_policy: OMW-GOV-001
authoritative_for:
  - document number reservations
  - stable document IDs
  - main-branch document inventory
  - merge-time renumbering
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - pre-PR-32 document registry
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# Operation Mountain Watch – Zentrales Dokumentregister

## 1. Zweck

Dieses Register verwaltet aktuelle Dokumentnummern, stabile IDs, den tatsächlichen `main`-Bestand, Branchreservierungen und Umnummerierungsregeln.

Thematische Navigation und Source-of-Truth-Matrix:

- [`OMW-GOV-DOCUMENTATION-INDEX`](README.md)

Eine Nummer darf nur einmal als aktuelle Nummer vergeben sein. Alte Nummern in unveränderten Legacy-Dateien besitzen keine aktuelle Nummernautorität.

## 2. Nummerierte Dokumente auf `main`

| Nr. | Stabile ID | Pfad | Governance-Status | Klasse / Funktion |
|---:|---|---|---|---|
| 00 | `OMW-GOV-001` | `docs/00-project-governance.md` | `BINDING_PROJECT_DECISION` | höchste Projekt-Governance |
| 01 | `OMW-VISION` | `docs/01-vision.md` | `BINDING` | `PROJECT_VISION` |
| 02 | `OMW-GAMEPLAY-CONCEPT` | `docs/02-gameplay-concept.md` | `BINDING` | `GAMEPLAY_CONCEPT` |
| 03 | `OMW-ARCH-SYSTEM` | `docs/03-system-architecture.md` | `BINDING` | Systemarchitektur |
| 04 | `OMW-ARCH-CAMPAIGN-STATE` | `docs/04-campaign-state.md` | `BINDING` | `DOMAIN_MODEL` |
| 05 | `OMW-LOGISTICS` | `docs/05-logistics.md` | `BINDING` | `LOGISTICS_ARCHITECTURE` |
| 06 | `OMW-RED-DIRECTOR` | `docs/06-red-director.md` | `SUPERSEDED` | frühe RED-Architektur; ersetzt durch 37 |
| 07 | `OMW-VIRTUALIZATION` | `docs/07-virtualization.md` | `BINDING` | `REPRESENTATION_ARCHITECTURE` |
| 08 | `OMW-CSAR-LEGACY` | `docs/08-csar.md` | `SUPERSEDED` | frühes CSAR-Konzept |
| 09 | `OMW-HIST-SETTING` | `docs/09-historical-setting.md` | `BINDING` | historischer Kampagnenrahmen |
| 10 | `OMW-THEATER-SECTORS` | `docs/10-theater-and-sectors.md` | `BINDING` | `THEATER_MODEL` |
| 11 | `OMW-BASES-FOBS` | `docs/11-bases-and-fobs.md` | `PLANNED` | `BASE_AND_FOB_MODEL` |
| 12 | `OMW-ROUTE-NETWORK` | `docs/12-route-network.md` | `SUPERSEDED` | frühes Routennetz; ersetzt durch 49 |
| 13 | `OMW-UNIT-CATALOG` | `docs/13-unit-catalog.md` | `PLANNED` | `TEMPLATE_AND_UNIT_CATALOG` |
| 14 | `OMW-PHASE-VERTICAL-PROTOTYPE` | `docs/14-prototype-scope.md` | `SUPERSEDED` | historische Projektphase |
| 15 | `OMW-TEMPLATE-LIBRARY-SPAWNING` | `docs/15-template-library-and-spawning.md` | `BINDING` | `TEMPLATE_ARCHITECTURE` |
| 16 | `OMW-WORLD-DATA-ROUTING` | `docs/16-world-data-and-routing.md` | `BINDING` | `WORLD_DATA_ARCHITECTURE` |
| 17 | `OMW-ARCH-PATHFINDING-OPTIONS` | `docs/17-pathfinding-options.md` | `PLANNED` | `TECHNICAL_DESIGN_REFERENCE` |
| 18 | `OMW-AIR-IMPLEMENTATION` | `docs/18-air-operations-implementation.md` | `BINDING` | technische Luftoperationen |
| 19 | `OMW-AIR-ACTIVE-ORBAT` | `docs/19-active-air-orbat-decisions.md` | `BINDING_PROJECT_DECISION` | aktive Luft-ORBAT und Clientgrenzen |
| 20 | `OMW-AIR-ME-WORKLIST` | `docs/20-air-orbat-mission-editor-worklist.md` | `BINDING` | Air-Ops-ME-Arbeitsablauf |
| 21 | `OMW-AIR-JBAD-MANIFEST` | `docs/21-jalalabad-air-operations-manifest.md` | `BINDING` | Jalalabad-ME-Baseline |
| 26 | `OMW-GOV-MOOSE-FIRST` | `docs/26-moose-first-development-policy.md` | `BINDING_PROJECT_DECISION` | MOOSE-First und Ausnahmen |
| 27 | `OMW-C2-JTAC-CALLSIGNS` | `docs/27-oef-jtac-callsign-reference.md` | `BINDING` | `SOURCE_REFERENCE` |
| 28 | `OMW-C2-TAD-COLOR-NETS` | `docs/28-afghanistan-tad-color-nets.md` | `BINDING` | `SOURCE_DERIVED_DATASET` |
| 29 | `OMW-AAR-ISAF-ACO` | `docs/29-isaf-2009-2013-air-to-air-refueling.md` | `BINDING` | `SOURCE_DERIVED_DESIGN_REFERENCE` |
| 30 | `OMW-AAR-PART2-FIGURE` | `docs/30-isaf-2009-2013-aar-part2-figure-reference.md` | `BINDING` | `SOURCE_REFERENCE` |
| 37 | `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` | `docs/37-campaign-architecture-and-dynamic-mission-design.md` | `BINDING` | Kampagnenarchitektur |
| 38 | `OMW-ME-MASTER-WORKLIST` | `docs/38-mission-editor-master-worklist.md` | `BINDING` | Foundation-Build-Masterarbeitsliste |
| 39 | `OMW-REVIEW-TM01-TM02-MOOSE-FIRST` | `docs/39-tm01-tm02-moose-first-code-review.md` | `DRAFT` | `CODE_REVIEW` |
| 40 | `OMW-PLAN-TM01-TM02-MOOSE-ADOPTION` | `docs/40-moose-module-adoption-plan-for-tm01-tm02.md` | `PLANNED` | `IMPLEMENTATION_PLAN` |
| 41 | `OMW-WX-HISTORICAL-BASELINE` | `docs/41-historical-weather-baseline-2010-2011.md` | `BINDING` | `HISTORICAL_DATA_BASELINE` |
| 42 | `OMW-WX-DCS-IMPLEMENTATION` | `docs/42-dcs-weather-editor-validation.md` | `BINDING` | `DCS_EDITOR_BASELINE` |
| 43 | `OMW-WX-RAIN-PROFILE` | `docs/43-dcs-rain-shower-preset-validation.md` | `ACCEPTED_TECHNICAL_BASELINE` | begrenztes `DCS_TEST_PROFILE` |
| 44 | `OMW-WX-MIST-PROFILE` | `docs/44-dcs-valley-mist-low-cloud-test-profile.md` | `PLANNED` | `DCS_TEST_PROFILE` |
| 45 | `OMW-C2-AIR-C2-CAS-AFGHANISTAN` | `docs/45-air-c2-cas-afghanistan.md` | `BINDING` | `SOURCE_DERIVED_DESIGN_REFERENCE` |
| 46 | `OMW-ROE-NON-LETHAL-USE-OF-FORCE` | `docs/46-non-lethal-use-of-force.md` | `PLANNED` | `SOURCE_DERIVED_DESIGN_REFERENCE` |
| 47 | `OMW-C2-AIRCRAFT-TACTICAL-CALLSIGNS` | `docs/47-aircraft-tactical-callsigns.md` | `BINDING` | `SOURCE_REFERENCE` |
| 48 | `OMW-TARGETING-AFGHANISTAN-NSL` | `docs/48-afghanistan-no-strike-list.md` | `BINDING` | `TARGETING_ARCHITECTURE` |
| 49 | `OMW-MSR-ROUTE-DESIGN` | `docs/49-msr-routendesign-und-infrastrukturmarker.md` | `PLANNED` | `DESIGN_WORKLIST` |

## 3. Reservierungen für offene Branches

### PR #18 – Jalalabad Air Operations

| Nr. | Stabile ID | Zielpfad | Branchstatus |
|---:|---|---|---|
| 22 | `OMW-TEST-BUILD-TRANSFER` | `docs/22-test-mission-build-transfer-and-validation-workflow.md` | Draft-PR #18 |
| 23 | `OMW-AIR-JBAD-PARKING-MEDEVAC` | `docs/23-jalalabad-parking-template-and-medevac-model.md` | Draft-PR #18 |
| 24 | `OMW-AIR-JBAD-CH47-PARKING` | `docs/24-jalalabad-ch47-static-parking-reservations.md` | Draft-PR #18 |
| 25 | `OMW-AIR-JBAD-ACCEPTANCE` | `docs/25-jalalabad-final-validation-and-operational-baseline.md` | branchgebundene `ACCEPTED_TECHNICAL_BASELINE` |

PR #18 enthält zusätzlich einen kollidierenden branchlokalen Pfad mit Nummer 27. Dieser Pfad muss vor einer späteren Integration neu reserviert und umbenannt werden.

### PR #24 – Bagram/Kandahar

| Nr. | Stabile ID | Zielpfad | Branchstatus |
|---:|---|---|---|
| 31 | `OMW-AIR-BAGRAM-MANIFEST` | `docs/31-bagram-air-operations-manifest.md` | Draft-PR #24 |
| 32 | `OMW-AIR-PLAYER-SLOT-POLICY` | `docs/32-player-aircraft-slot-policy.md` | Draft-PR #24 |
| 33 | `OMW-AIR-KANDAHAR-MANIFEST` | `docs/33-kandahar-air-operations-manifest.md` | Draft-PR #24 |
| 34 | `OMW-AIR-BAGRAM-ME-BASELINE` | `docs/34-bagram-current-mission-editor-baseline.md` | Draft-PR #24 |
| 35 | `OMW-AIR-KANDAHAR-ISR-POLICY` | `docs/35-kandahar-isr-asset-policy.md` | Draft-PR #24 |
| 36 | `OMW-AIR-KANDAHAR-MUSTANG-RAMP` | `docs/36-kandahar-mustang-ramp-army-aviation-baseline.md` | Draft-PR #24 |

## 4. Nicht nummerierte stabile Dokumente

| Stabile ID | Pfad | Governance-Status | Funktion |
|---|---|---|---|
| `OMW-GOV-DOCUMENTATION-INDEX` | `docs/README.md` | `BINDING` | Themenindex und Source-of-Truth-Matrix |
| `OMW-AIR-US-ORBAT-RESEARCH` | `docs/us-air-orbat-2010-2011.md` | `BINDING` | historische ORBAT-Recherche; nicht aktive ORBAT |
| `OMW-GOV-SOURCE-USE` | `docs/sources/graveyard-of-empires.md` | `BINDING_PROJECT_DECISION` | Quellen- und Veröffentlichungsregel |
| `OMW-GOV-MOOSE-VERSION` | `docs/moose/VERSION-AND-SOURCES.md` | `BINDING` | MOOSE-Version und Nachweise |
| `OMW-MOOSE-DOCUMENTATION-INDEX` | `docs/moose/README.md` | `BINDING` | MOOSE-Themenindex |
| `OMW-MOOSE-CLASS-INDEX` | `docs/moose/PROJECT-CLASS-INDEX.md` | `BINDING` | Klassenstatusregister |
| `OMW-MOOSE-VERIFIED-METHODS` | `docs/moose/VERIFIED-METHODS.md` | `BINDING` | Methodenevidenzregister |
| `OMW-MOOSE-AIR-OPERATIONS` | `docs/moose/AIR-OPERATIONS.md` | `BINDING` | Air-Ops-Technikreferenz |
| `OMW-MOOSE-GROUND-OPERATIONS` | `docs/moose/GROUND-OPERATIONS.md` | `PLANNED` | Ground-Ops-Technikreferenz |
| `OMW-MOOSE-LOGISTICS-TRANSPORT` | `docs/moose/LOGISTICS-AND-TRANSPORT.md` | `BINDING` | Logistik-Verantwortungstrennung |
| `OMW-MOOSE-EVENTS-FSM` | `docs/moose/EVENTS-AND-FSM.md` | `BINDING` | Events-/FSM-Entwicklungsregel |
| `OMW-MOOSE-ISR-FAC-CAS-AAR` | `docs/moose/ISR-FAC-CAS-AAR.md` | `PLANNED` | technische ISR-/CAS-/AAR-Architektur |
| `OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE` | `docs/targeting/afghanistan-nsl-data-use-policy.md` | `BINDING_PROJECT_DECISION` | NSL-Datenverwendung |
| `OMW-CSAR-INDEX` | `docs/csar/README.md` | `BINDING` | CSAR-Quellen- und Anforderungsindex |
| `OMW-EVIDENCE-INDEX` | `docs/evidence/README.md` | `BINDING` | Evidenz- und Legacy-Einordnung |
| `OMW-EVIDENCE-JBAD-AIR-OPS-BASELINE-AUDIT` | `docs/evidence/jalalabad-air-operations-baseline-audit.md` | `HISTORICAL_TEST_FIXTURE` | Ausgangs-Audit |

## 5. Legacy-Evidenz

Vollständige frühere Fassungen liegen unter `docs/evidence/source-records/`. Sie bleiben für Historie, Quelleninhalt und Diff-Nachweis erhalten, besitzen aber keine parallele Governance- oder Nummernautorität.

## 6. Merge- und Nummerierungsregel

1. Neue Dokumente dürfen auf einem Branch zunächst unnummeriert entstehen.
2. Vor Merge wird eine Nummer reserviert oder ein unnummerierter stabiler ID-Pfad festgelegt.
3. Nummernkollisionen werden vor Merge beseitigt.
4. Relative Links, Themenindex und Register werden im selben Änderungssatz angepasst.
5. Branchdateien werden mit PR, Branch und Commit referenziert und nicht als `main`-Dateien dargestellt.
6. Testberichte und Legacy-Protokolle werden bevorzugt als unnummerierte Evidenzdokumente geführt.
7. Das Register beschreibt den realen Repository-Bestand; bei Abweichungen ist der Baum auf `main` maßgeblich.
8. `status` enthält ausschließlich die in `OMW-GOV-001` zugelassenen Governance-Werte. Quellen-, Bearbeitungs- und Klassenstatus werden getrennt geführt.
