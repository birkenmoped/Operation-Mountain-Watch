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
  - registry without complete non-numbered document inventory
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Operation Mountain Watch – Zentrales Dokumentregister

## 1. Regeln

Eine Nummer und eine stabile `document_id` dürfen im aktuellen Bestand jeweils nur einmal vergeben sein. Der reale Repository-Baum entscheidet, welche Dateien auf `main` vorhanden sind. Offene Branches werden separat im [`Unterprojektregister`](SUBPROJECT-REGISTRY.md) geführt.

## 2. Nummerierte Dokumente

| Nr. | Stabile ID | Pfad | Status | Klasse/Funktion |
|---:|---|---|---|---|
| 00 | `OMW-GOV-001` | `docs/00-project-governance.md` | `BINDING_PROJECT_DECISION` | höchste Governance |
| 01 | `OMW-VISION` | `docs/01-vision.md` | `BINDING` | Projektvision |
| 02 | `OMW-GAMEPLAY-CONCEPT` | `docs/02-gameplay-concept.md` | `BINDING` | Gameplay-Konzept |
| 03 | `OMW-ARCH-SYSTEM` | `docs/03-system-architecture.md` | `BINDING` | Systemarchitektur |
| 04 | `OMW-ARCH-CAMPAIGN-STATE` | `docs/04-campaign-state.md` | `BINDING` | Domain Model |
| 05 | `OMW-LOGISTICS` | `docs/05-logistics.md` | `BINDING` | Logistikarchitektur |
| 06 | `OMW-RED-DIRECTOR` | `docs/06-red-director.md` | `SUPERSEDED` | früher RED-Entwurf |
| 07 | `OMW-VIRTUALIZATION` | `docs/07-virtualization.md` | `BINDING` | Repräsentationsarchitektur |
| 08 | `OMW-CSAR-LEGACY` | `docs/08-csar.md` | `SUPERSEDED` | früher CSAR-Entwurf |
| 09 | `OMW-HIST-SETTING` | `docs/09-historical-setting.md` | `BINDING` | historischer Rahmen |
| 10 | `OMW-THEATER-SECTORS` | `docs/10-theater-and-sectors.md` | `BINDING` | Theatermodell |
| 11 | `OMW-BASES-FOBS` | `docs/11-bases-and-fobs.md` | `PLANNED` | Basen-/FOB-Modell |
| 12 | `OMW-ROUTE-NETWORK` | `docs/12-route-network.md` | `SUPERSEDED` | frühes Routennetz |
| 13 | `OMW-UNIT-CATALOG` | `docs/13-unit-catalog.md` | `PLANNED` | Katalogplanung |
| 14 | `OMW-PHASE-VERTICAL-PROTOTYPE` | `docs/14-prototype-scope.md` | `SUPERSEDED` | historische Phase |
| 15 | `OMW-TEMPLATE-LIBRARY-SPAWNING` | `docs/15-template-library-and-spawning.md` | `BINDING` | Template-Architektur |
| 16 | `OMW-WORLD-DATA-ROUTING` | `docs/16-world-data-and-routing.md` | `BINDING` | World-Data-Architektur |
| 17 | `OMW-ARCH-PATHFINDING-OPTIONS` | `docs/17-pathfinding-options.md` | `PLANNED` | technische Designreferenz |
| 18 | `OMW-AIR-IMPLEMENTATION` | `docs/18-air-operations-implementation.md` | `BINDING` | technische Luftoperationen |
| 19 | `OMW-AIR-ACTIVE-ORBAT` | `docs/19-active-air-orbat-decisions.md` | `BINDING_PROJECT_DECISION` | aktive ORBAT/Clientgrenzen |
| 20 | `OMW-AIR-ME-WORKLIST` | `docs/20-air-orbat-mission-editor-worklist.md` | `BINDING` | Air-Ops-ME-Workflow |
| 21 | `OMW-AIR-JBAD-MANIFEST` | `docs/21-jalalabad-air-operations-manifest.md` | `BINDING` | Jalalabad-ME-Baseline |
| 26 | `OMW-GOV-MOOSE-FIRST` | `docs/26-moose-first-development-policy.md` | `BINDING_PROJECT_DECISION` | MOOSE-First |
| 27 | `OMW-C2-JTAC-CALLSIGNS` | `docs/27-oef-jtac-callsign-reference.md` | `BINDING` | Quellenreferenz |
| 28 | `OMW-C2-TAD-COLOR-NETS` | `docs/28-afghanistan-tad-color-nets.md` | `BINDING` | Quellenbasierter Datensatz |
| 29 | `OMW-AAR-ISAF-ACO` | `docs/29-isaf-2009-2013-air-to-air-refueling.md` | `BINDING` | AAR-/ACO-Referenz |
| 30 | `OMW-AAR-PART2-FIGURE` | `docs/30-isaf-2009-2013-aar-part2-figure-reference.md` | `BINDING` | Abbildungsreferenz |
| 37 | `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` | `docs/37-campaign-architecture-and-dynamic-mission-design.md` | `BINDING` | Kampagnenarchitektur |
| 38 | `OMW-ME-MASTER-WORKLIST` | `docs/38-mission-editor-master-worklist.md` | `BINDING` | ME-Masterarbeitsliste |
| 39 | `OMW-REVIEW-TM01-TM02-MOOSE-FIRST` | `docs/39-tm01-tm02-moose-first-code-review.md` | `DRAFT` | Code Review |
| 40 | `OMW-PLAN-TM01-TM02-MOOSE-ADOPTION` | `docs/40-moose-module-adoption-plan-for-tm01-tm02.md` | `PLANNED` | Implementierungsplan |
| 41 | `OMW-WX-HISTORICAL-BASELINE` | `docs/41-historical-weather-baseline-2010-2011.md` | `BINDING` | Wetterdatenbaseline |
| 42 | `OMW-WX-DCS-IMPLEMENTATION` | `docs/42-dcs-weather-editor-validation.md` | `BINDING` | DCS-Editorbaseline |
| 43 | `OMW-WX-RAIN-PROFILE` | `docs/43-dcs-rain-shower-preset-validation.md` | `BINDING` | visuell bestätigtes Arbeitsprofil |
| 44 | `OMW-WX-MIST-PROFILE` | `docs/44-dcs-valley-mist-low-cloud-test-profile.md` | `PLANNED` | Testprofil |
| 45 | `OMW-C2-AIR-C2-CAS-AFGHANISTAN` | `docs/45-air-c2-cas-afghanistan.md` | `BINDING` | Quellenbasierte Designreferenz |
| 46 | `OMW-ROE-NON-LETHAL-USE-OF-FORCE` | `docs/46-non-lethal-use-of-force.md` | `PLANNED` | Quellenbasierte Designreferenz |
| 47 | `OMW-C2-AIRCRAFT-TACTICAL-CALLSIGNS` | `docs/47-aircraft-tactical-callsigns.md` | `BINDING` | Quellenreferenz |
| 48 | `OMW-TARGETING-AFGHANISTAN-NSL` | `docs/48-afghanistan-no-strike-list.md` | `BINDING` | Targeting-Architektur |
| 49 | `OMW-MSR-ROUTE-DESIGN` | `docs/49-msr-routendesign-und-infrastrukturmarker.md` | `PLANNED` | Design-/Arbeitsliste |
| 50 | `OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION` | `docs/50-afghanistan-force-basing-aviation-2010-2011.md` | `BINDING` | historische Kräfte-, Basen-, Aviation- und TTP-Referenz |
| 51 | `OMW-HIST-USMC-RC-SOUTHWEST-COALITION-OPS` | `docs/51-usmc-rc-southwest-and-coalition-operations-2010-2011.md` | `BINDING` | USMC-RC-Southwest-, Koalitionsoperations- und Missionsmuster-Referenz |
| 52 | `OMW-HIST-ARMY-AVIATION-COIN-INTELLIGENCE-METRICS` | `docs/52-army-aviation-vignettes-and-coin-intelligence-metrics.md` | `BINDING` | Army-Aviation-, Chinook-, Emergency-, Intelligence- und Missionsmetriken-Referenz |
| 53 | `OMW-HIST-AFGHANISTAN-WAR-CARLISLE-SOURCE-REVIEW` | `docs/53-afghanistan-war-carlisle-source-review.md` | `BINDING` | quellenkritische Sekundär- und Hintergrundreferenz |
| 54 | `OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS` | `docs/54-air-tasking-airspace-control-cas-requests-and-mission-data.md` | `BINDING` | Air-C2-, ATO-/ACO-/SPINS-, Request- und Missionsdatenreferenz |
| 55 | `OMW-HIST-MONTHLY-COALITION-ORBAT-BASING` | `docs/55-monthly-coalition-orbat-and-basing-2010-2011.md` | `BINDING` | monatliche Koalitions-ORBAT-, Basierungs- und AOR-Referenz |
| 56 | `OMW-RED-INSURGENT-FACTIONS-BEHAVIOR` | `docs/56-insurgent-factions-shadow-governance-and-red-commander-behavior.md` | `BINDING` | konsolidierter RED Commander; historisches Insurgentenverhalten und optionale spätere Mehrfraktionsreferenz |
| 57 | `OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM` | `docs/57-kandahar-helmand-enemy-system-and-red-commander-strategy.md` | `BINDING` | Kandahar-/Helmand-Enemy-System, Clear-Hold-Reinfiltration, Kräfte-/ANSF-Kontext und RED-Strategie |

## 3. Reservierte Nummern auf offenen Branches

| PR | Nummern | Status |
|---:|---|---|
| 18 | 22–25 | nur Draft-PR #18; branchgebundene Air-Ops-Dokumente |
| 18 | 27 | branchlokale Kollision; vor Integration zwingend neu nummerieren |
| 24 | 31–36 | nur Draft-PR #24; Bagram/Kandahar |

## 4. Nicht nummerierte aktuelle Dokumente

| Stabile ID | Pfad | Status/Funktion |
|---|---|---|
| `OMW-GOV-DOCUMENTATION-INDEX` | `docs/README.md` | `BINDING`; Themenindex |
| `OMW-GOV-DOCUMENT-METADATA` | `docs/DOCUMENT-METADATA-POLICY.md` | `BINDING`; Metadaten/Provenienz |
| `OMW-GOV-SUBPROJECT-REGISTRY` | `docs/SUBPROJECT-REGISTRY.md` | `BINDING`; offene Unterprojekte |
| `OMW-AIR-US-ORBAT-RESEARCH` | `docs/us-air-orbat-2010-2011.md` | `BINDING`; historische Forschung |
| `OMW-GOV-SOURCE-USE` | `docs/sources/graveyard-of-empires.md` | `BINDING_PROJECT_DECISION` |
| `OMW-GOV-MOOSE-VERSION` | `docs/moose/VERSION-AND-SOURCES.md` | `BINDING` |
| `OMW-MOOSE-DOCUMENTATION-INDEX` | `docs/moose/README.md` | `BINDING` |
| `OMW-MOOSE-CLASS-INDEX` | `docs/moose/PROJECT-CLASS-INDEX.md` | `BINDING` |
| `OMW-MOOSE-FOG-OF-WAR-RECCE` | `docs/moose/FOG-OF-WAR-RECCE.md` | `PLANNED`; MOOSE-Fähigkeits- und Grenzenanalyse |
| `OMW-MOOSE-VERIFIED-METHODS` | `docs/moose/VERIFIED-METHODS.md` | `BINDING` |
| `OMW-CSAR-INDEX` | `docs/csar/README.md` | `BINDING` |
| `OMW-CSAR-SOURCE-NOTES-1-8` | `docs/csar/source-notes-1-8.md` | `BINDING`; Quellenregister |
| `OMW-CSAR-AFGHANISTAN-2010-FACILITIES` | `docs/csar/afghanistan-2010-facilities-and-coverage.md` | `BINDING`; Datensatzreferenz |
| `OMW-CSAR-MISSION-DESIGN-REQUIREMENTS` | `docs/csar/mission-design-requirements.md` | `PLANNED`; Anforderungen |
| `OMW-CSAR-MOOSE-AICSAR-DEVELOPMENT-BASELINE` | `docs/csar/moose-csar-aicsar-development-baseline.md` | `PLANNED`; Architektur-, Entscheidungs- und Testbaseline |
| `OMW-WX-DATASET-DOCUMENTATION` | `docs/data/weather/README.md` | `BINDING`; Wetterdatensatz |
| `OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE` | `docs/targeting/afghanistan-nsl-data-use-policy.md` | `BINDING`; technische Datenverwendung |
| `OMW-TARGETING-AFGHANISTAN-NSL-LEGACY-PATH` | `docs/targeting/afghanistan-no-strike-list.md` | `SUPERSEDED`; Kompatibilitätspfad |
| `OMW-ADR-0001-USE-MOOSE` | `docs/adr/0001-use-moose.md` | `SUPERSEDED`; historische ADR |
| `OMW-ADR-0002-USE-MOOSE-CTLD-CSAR` | `docs/adr/0002-use-moose-ctld-and-csar.md` | `SUPERSEDED`; historische ADR |
| `OMW-ADR-0003-ME-GROUP-TEMPLATES` | `docs/adr/0003-use-mission-editor-group-templates.md` | `BINDING`; Spawnvorlagen |
| `OMW-ADR-0004-LOCATION-REGISTRY` | `docs/adr/0004-use-explicit-location-registry.md` | `BINDING`; Orts-/Routenregister |
| `OMW-EVIDENCE-INDEX` | `docs/evidence/README.md` | `BINDING`; Evidenzeinordnung |
| `OMW-EVIDENCE-SOURCE-INTAKE-AUDIT-2026-07-28` | `docs/evidence/source-intake-audit-2026-07-28.md` | `BINDING`; Quellenaufnahme- und Zuordnungsnachweis |
| `OMW-TEST-JBAD-AIR-OPS-INDEX` | `mission/tests/jalalabad-air-operations/README.md` | `BINDING`; Testprojektindex |

## 5. Legacy- und Evidenzregel

Dateien unter `docs/evidence/source-records/` bewahren frühere Vollfassungen. Ihre alten Titelnummern und Aussagen sind keine aktuelle Nummern-, Status- oder Governance-Vergabe.
