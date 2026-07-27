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

Dieses Register verwaltet ausschließlich:

- aktuelle Dokumentnummern;
- stabile Dokument-IDs;
- den tatsächlichen Bestand auf `main`;
- Reservierungen für offene Branches;
- Umnummerierungs- und Merge-Regeln.

Für die thematische Navigation und Source-of-Truth-Matrix gilt:

- [`OMW-GOV-DOCUMENTATION-INDEX`](README.md)

Eine Nummer darf nur einmal als aktuelle Nummer vergeben sein. Unveränderte Legacy-Quelldatensätze dürfen alte Nummern im historischen Titel behalten, beanspruchen diese Nummer aber nicht.

## 2. Nummerierte Dokumente auf `main`

| Nr. | Stabile ID | Pfad | Status | Klasse / Funktion |
|---:|---|---|---|---|
| 00 | `OMW-GOV-001` | `docs/00-project-governance.md` | `BINDING_PROJECT_DECISION` | höchste Projekt-Governance |
| 01 | `OMW-VISION` | `docs/01-vision.md` | unbestätigte Legacy-Klassifikation | Vision |
| 02 | `OMW-GAMEPLAY-CONCEPT` | `docs/02-gameplay-concept.md` | unbestätigte Legacy-Klassifikation | Gameplay-Konzept |
| 03 | `OMW-ARCH-SYSTEM` | `docs/03-system-architecture.md` | `BINDING` | Systemarchitektur |
| 04 | `OMW-ARCH-CAMPAIGN-STATE` | `docs/04-campaign-state.md` | nachgeordnet zu Dokument 37 | frühe CampaignState-Grundlage |
| 05 | `OMW-LOGISTICS` | `docs/05-logistics.md` | nachgeordnet zu Dokument 37 | frühe Logistikgrundlage |
| 06 | `OMW-RED-DIRECTOR` | `docs/06-red-director.md` | nachgeordnet zu Dokument 37 | frühe RED-Grundlage |
| 07 | `OMW-VIRTUALIZATION` | `docs/07-virtualization.md` | nachgeordnet zu Dokument 37 | frühe Virtualisierungsgrundlage |
| 08 | `OMW-CSAR-LEGACY` | `docs/08-csar.md` | Legacy-Grundlage | aktuelle CSAR-Dokumentation unter `docs/csar/` |
| 09 | `OMW-HIST-SETTING` | `docs/09-historical-setting.md` | `BINDING` | historischer Kampagnenrahmen |
| 10 | `OMW-THEATER-SECTORS` | `docs/10-theater-and-sectors.md` | Legacy-Fachgrundlage | Operationsraum und Sektoren |
| 11 | `OMW-BASES-FOBS` | `docs/11-bases-and-fobs.md` | Legacy-Fachgrundlage | Basen und FOBs |
| 12 | `OMW-ROUTE-NETWORK` | `docs/12-route-network.md` | nachgeordnet zu Dokument 49 | frühes Routennetz |
| 13 | `OMW-UNIT-CATALOG` | `docs/13-unit-catalog.md` | Legacy-Fachgrundlage | Einheitenkatalog |
| 14 | `OMW-PHASE-VERTICAL-PROTOTYPE` | `docs/14-prototype-scope.md` | `SUPERSEDED` | historische Projektphase |
| 15 | `OMW-TEMPLATE-LIBRARY-SPAWNING` | `docs/15-template-library-and-spawning.md` | Legacy-Designgrundlage | Templates und Spawning |
| 16 | `OMW-WORLD-DATA-ROUTING` | `docs/16-world-data-and-routing.md` | Legacy-Designgrundlage | World Data und Routing |
| 17 | `OMW-ARCH-PATHFINDING-OPTIONS` | `docs/17-pathfinding-options.md` | Fachreferenz | Pathfinding-Optionen |
| 18 | `OMW-AIR-IMPLEMENTATION` | `docs/18-air-operations-implementation.md` | `BINDING` | technische Luftoperationen |
| 19 | `OMW-AIR-ACTIVE-ORBAT` | `docs/19-active-air-orbat-decisions.md` | `BINDING_PROJECT_DECISION` | aktive Luft-ORBAT und Clientgrenzen |
| 20 | `OMW-AIR-ME-WORKLIST` | `docs/20-air-orbat-mission-editor-worklist.md` | `BINDING` | Air-Ops-ME-Arbeitsablauf |
| 21 | `OMW-AIR-JBAD-MANIFEST` | `docs/21-jalalabad-air-operations-manifest.md` | `BINDING` | Jalalabad-ME-Baseline |
| 26 | `OMW-GOV-MOOSE-FIRST` | `docs/26-moose-first-development-policy.md` | `BINDING_PROJECT_DECISION` | MOOSE-First und Ausnahmen |
| 27 | `OMW-C2-JTAC-CALLSIGNS` | `docs/27-oef-jtac-callsign-reference.md` | `BINDING` | Source Reference / Callsign-Pool |
| 28 | `OMW-C2-TAD-COLOR-NETS` | `docs/28-afghanistan-tad-color-nets.md` | Fachreferenz | TAD-/Color-Net-Plan |
| 29 | `OMW-AAR-ISAF-ACO` | `docs/29-isaf-2009-2013-air-to-air-refueling.md` | Fachreferenz | ISAF AAR/ACO |
| 30 | `OMW-AAR-PART2-FIGURE` | `docs/30-isaf-2009-2013-aar-part2-figure-reference.md` | Fachreferenz | AAR-Abbildungsreferenz |
| 37 | `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` | `docs/37-campaign-architecture-and-dynamic-mission-design.md` | `BINDING` | Kampagnenarchitektur |
| 38 | `OMW-ME-MASTER-WORKLIST` | `docs/38-mission-editor-master-worklist.md` | `BINDING` | Foundation-Build-Masterarbeitsliste |
| 39 | `OMW-REVIEW-TM01-TM02-MOOSE-FIRST` | `docs/39-tm01-tm02-moose-first-code-review.md` | Review | technische Bestandsaufnahme |
| 40 | `OMW-PLAN-TM01-TM02-MOOSE-ADOPTION` | `docs/40-moose-module-adoption-plan-for-tm01-tm02.md` | `PLANNED` | Adoptionsplan |
| 41 | `OMW-WX-HISTORICAL-BASELINE` | `docs/41-historical-weather-baseline-2010-2011.md` | Fachbaseline | historisches Wetter |
| 42 | `OMW-WX-DCS-IMPLEMENTATION` | `docs/42-dcs-weather-editor-validation.md` | Test-/Editorbaseline | DCS-Wettereditor |
| 43 | `OMW-WX-RAIN-PROFILE` | `docs/43-dcs-rain-shower-preset-validation.md` | Testprofil | Regen/Schauer |
| 44 | `OMW-WX-MIST-PROFILE` | `docs/44-dcs-valley-mist-low-cloud-test-profile.md` | Testprofil | Talnebel/tiefe Wolken |
| 45 | `OMW-C2-AIR-C2-CAS-AFGHANISTAN` | `docs/45-air-c2-cas-afghanistan.md` | `BINDING` | Source-derived Design Reference |
| 46 | `OMW-ROE-NON-LETHAL-USE-OF-FORCE` | `docs/46-non-lethal-use-of-force.md` | `PLANNED` | Source-derived Design Reference |
| 47 | `OMW-C2-AIRCRAFT-TACTICAL-CALLSIGNS` | `docs/47-aircraft-tactical-callsigns.md` | `BINDING` | Source Reference / Callsign-Pool |
| 48 | `OMW-TARGETING-AFGHANISTAN-NSL` | `docs/48-afghanistan-no-strike-list.md` | `BINDING` | Targeting-Architektur |
| 49 | `OMW-MSR-ROUTE-DESIGN` | `docs/49-msr-routendesign-und-infrastrukturmarker.md` | `PLANNED` | MSR-Design und Worklist |

## 3. Reservierungen für offene Branches

### PR #18 – Jalalabad Air Operations

Diese Dateien liegen nicht auf `main`:

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

| Stabile ID | Pfad | Status / Funktion |
|---|---|---|
| `OMW-GOV-DOCUMENTATION-INDEX` | `docs/README.md` | `BINDING`; Themenindex und Source-of-Truth-Matrix |
| `OMW-AIR-US-ORBAT-RESEARCH` | `docs/us-air-orbat-2010-2011.md` | historische Recherche |
| `OMW-GOV-SOURCE-USE` | `docs/sources/graveyard-of-empires.md` | zentrale Quellen- und Veröffentlichungsregel |
| `OMW-GOV-MOOSE-VERSION` | `docs/moose/VERSION-AND-SOURCES.md` | MOOSE-Version und Nachweise |
| `OMW-MOOSE-CLASS-INDEX` | `docs/moose/PROJECT-CLASS-INDEX.md` | Klassenindex |
| `OMW-MOOSE-VERIFIED-METHODS` | `docs/moose/VERIFIED-METHODS.md` | verifizierte Methoden |
| `OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE` | `docs/targeting/afghanistan-nsl-data-use-policy.md` | verbindliche NSL-Datenverwendung |
| `OMW-CSAR-INDEX` | `docs/csar/README.md` | CSAR-Quellen- und Anforderungsindex |
| `OMW-EVIDENCE-INDEX` | `docs/evidence/README.md` | Evidenz- und Legacy-Einordnung |
| `OMW-EVIDENCE-JBAD-AIR-OPS-BASELINE-AUDIT` | `docs/evidence/jalalabad-air-operations-baseline-audit.md` | `HISTORICAL_TEST_FIXTURE` |

## 5. Legacy-Evidenz

Vollständige frühere Fassungen liegen unter `docs/evidence/source-records/`. Sie bleiben für Historie und Diff-Nachweis erhalten, besitzen aber keine parallele Governance- oder Nummernautorität.

## 6. Merge- und Nummerierungsregel

1. Neue Dokumente dürfen auf einem Branch zunächst unnummeriert entstehen.
2. Vor Merge wird eine Nummer reserviert oder ein unnummerierter stabiler ID-Pfad festgelegt.
3. Nummernkollisionen werden vor Merge beseitigt.
4. Relative Links, Themenindex und Register werden im selben Änderungssatz aktualisiert.
5. Branchdateien werden mit PR, Branch und Commit referenziert und nicht als `main`-Dateien dargestellt.
6. Testberichte und Legacy-Protokolle werden bevorzugt als unnummerierte Evidenzdokumente geführt.
7. Das Register beschreibt den realen Repository-Bestand; bei Abweichungen ist der Baum auf `main` maßgeblich und das Register unverzüglich zu korrigieren.
