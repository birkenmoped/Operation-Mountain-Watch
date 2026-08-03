---
document_id: OMW-GOV-DOCUMENT-REGISTRY
status: BINDING
document_class: DOCUMENT_REGISTRY
owning_policy: OMW-GOV-001
authoritative_for:
  - stable project document identifiers
  - current numbered-document allocation
  - registration of unnumbered current documents
not_authoritative_for:
  - runtime acceptance
  - merge approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_MOOSE_SOURCE_REVIEW_COMPLETE
supersedes:
  - incomplete document registry before Tarinkot reconciliation
superseded_by: []
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Dokumentregister

## 1. Zweck

Dieses Register ordnet den aktuellen Dokumentenbestand stabilen `document_id`-Werten und, soweit vorhanden, zweistelligen Dokumentnummern zu. Eine Nummer und eine stabile `document_id` dürfen im aktuellen Bestand jeweils nur einmal verwendet werden.

## 2. Nummerierte aktuelle Dokumente

| Nr. | Stabile ID | Pfad | Status | Funktion |
|---:|---|---|---|---|
| 00 | `OMW-GOV-001` | `docs/00-project-governance.md` | `BINDING` | Projektgovernance |
| 01 | `OMW-MISSION-DESIGN-001` | `docs/01-mission-design.md` | `BINDING` | Missionsdesign |
| 02 | `OMW-SETTING-001` | `docs/02-setting.md` | `BINDING` | Setting |
| 03 | `OMW-CAMPAIGN-STATE-001` | `docs/03-campaign-state.md` | `BINDING` | Kampagnenzustand |
| 04 | `OMW-LOGISTICS-001` | `docs/04-logistics.md` | `BINDING` | Logistik |
| 05 | `OMW-BLUE-FORCES-001` | `docs/05-blue-forces.md` | `BINDING` | BLUE-Kräfte |
| 06 | `OMW-RED-FORCES-001` | `docs/06-red-forces.md` | `BINDING` | RED-Kräfte |
| 07 | `OMW-MISSION-GENERATION-001` | `docs/07-mission-generation.md` | `BINDING` | Mission Generation |
| 08 | `OMW-RADIO-001` | `docs/08-radio-and-comms.md` | `BINDING` | Funk und Kommunikation |
| 09 | `OMW-AIR-ORBAT-RESEARCH-001` | `docs/09-air-orbat-research.md` | `BINDING` | Air-ORBAT-Forschung |
| 10 | `OMW-MAP-AREAS-001` | `docs/10-map-and-areas.md` | `BINDING` | Karte und Räume |
| 11 | `OMW-BASES-FOBS-001` | `docs/11-bases-and-fobs.md` | `BINDING` | Basen und FOBs |
| 12 | `OMW-PLAYER-OPS-001` | `docs/12-player-operations.md` | `BINDING` | Spieleroperationen |
| 13 | `OMW-UNIT-CATALOG-001` | `docs/13-unit-catalog.md` | `BINDING` | Einheitenkatalog |
| 14 | `OMW-WEATHER-001` | `docs/14-weather.md` | `BINDING` | Wetter |
| 15 | `OMW-GROUND-OPS-001` | `docs/15-ground-operations.md` | `BINDING` | Bodenoperationen |
| 16 | `OMW-AIR-OPS-001` | `docs/16-air-operations.md` | `BINDING` | Luftoperationen |
| 17 | `OMW-CSAR-001` | `docs/17-csar.md` | `BINDING` | CSAR |
| 18 | `OMW-IMPLEMENTATION-001` | `docs/18-implementation.md` | `BINDING` | Implementierung |
| 19 | `OMW-AIR-ORBAT-ACTIVE-001` | `docs/19-active-air-orbat-decisions.md` | `BINDING_PROJECT_DECISION` | aktive Air-ORBAT |
| 20 | `OMW-AIR-ME-WORKLIST-001` | `docs/20-air-orbat-mission-editor-worklist.md` | `PLANNED` | ME-Arbeitsliste |
| 21 | `OMW-AIR-JBAD-MANIFEST-001` | `docs/21-jalalabad-air-operations-manifest.md` | `DRAFT` | Jalalabad-Manifest |
| 26 | `OMW-GOV-MOOSE-FIRST-001` | `docs/26-moose-first-development-policy.md` | `BINDING` | MOOSE-first |
| 27 | `OMW-AIR-HELICOPTER-FORMATIONS-001` | `docs/27-helicopter-formations-and-ah64-afghanistan-configuration.md` | `DRAFT` | Helicopter-Formationen |
| 28 | `OMW-WX-AFGHANISTAN-CLIMATE-001` | `docs/28-afghanistan-climate-and-weather-reference.md` | `BINDING` | Klima-Referenz |
| 29 | `OMW-GEO-AFGHANISTAN-001` | `docs/29-afghanistan-geography-and-operational-environment.md` | `BINDING` | Geographie/OE |
| 30 | `OMW-GOV-DOCUMENTATION-001` | `docs/30-documentation-governance-and-cross-references.md` | `BINDING` | Dokumentationsgovernance |
| 37 | `OMW-HIST-AFGHANISTAN-AVIATION-001` | `docs/37-afghanistan-aviation-and-force-basing-2010-2011.md` | `BINDING` | Aviation/Force Basing |
| 38 | `OMW-AIR-AFGHANISTAN-FORCE-BASING-001` | `docs/38-afghanistan-force-basing-and-aviation-2010-2011.md` | `BINDING` | Force Basing |
| 39 | `OMW-HIST-AFGHANISTAN-COALITION-ORBAT-001` | `docs/39-afghanistan-coalition-orbat-2010-2011.md` | `BINDING` | Koalitions-ORBAT |
| 40 | `OMW-AIR-AFGHANISTAN-AIR-C2-001` | `docs/40-afghanistan-air-command-and-control-2010-2011.md` | `BINDING` | Air C2 |
| 41 | `OMW-HIST-AFGHANISTAN-SOF-001` | `docs/41-afghanistan-special-operations-forces-2010-2011.md` | `BINDING` | SOF |
| 42 | `OMW-HIST-AFGHANISTAN-ANSF-001` | `docs/42-afghanistan-security-forces-2010-2011.md` | `BINDING` | ANSF |
| 43 | `OMW-WX-RAIN-SHOWER-PRESET-001` | `docs/43-dcs-rain-shower-preset-validation.md` | `BINDING` | Wetter-Preset-Validierung |
| 44 | `OMW-HIST-AFGHANISTAN-ISAF-ORBAT-001` | `docs/44-afghanistan-isaf-order-of-battle-2010-2011.md` | `BINDING` | ISAF-ORBAT |
| 45 | `OMW-HIST-AFGHANISTAN-COIN-001` | `docs/45-afghanistan-coin-and-operational-environment-2010-2011.md` | `BINDING` | COIN/OE |
| 46 | `OMW-RED-COMMANDER-STRATEGY-001` | `docs/46-red-commander-strategy-and-behavior.md` | `BINDING` | RED Commander |
| 47 | `OMW-AIR-AFGHANISTAN-TACTICAL-CALLSIGNS-001` | `docs/47-afghanistan-aircraft-tactical-callsigns.md` | `BINDING` | Aircraft Callsigns |
| 48 | `OMW-AIR-AFGHANISTAN-JTAC-CALLSIGNS-001` | `docs/48-afghanistan-jtac-callsigns.md` | `BINDING` | JTAC Callsigns |
| 49 | `OMW-TARGETING-AFGHANISTAN-NSL-001` | `docs/49-afghanistan-no-strike-list-and-targeting-policy.md` | `BINDING` | NSL/Targeting |
| 50 | `OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION-001` | `docs/50-afghanistan-force-basing-aviation-2010-2011.md` | `BINDING` | Force Basing/Aviation |
| 51 | `OMW-AIR-AFGHANISTAN-AIR-C2-OPERATIONS-001` | `docs/51-afghanistan-air-command-control-and-operations.md` | `BINDING` | Air C2/Operations |
| 52 | `OMW-HIST-AFGHANISTAN-COALITION-ORBAT-001` | `docs/52-afghanistan-coalition-orbat-and-force-posture.md` | `BINDING` | Coalition ORBAT/Force Posture |
| 53 | `OMW-RED-COMMANDER-STRATEGIC-DOSSIER-001` | `docs/53-red-commander-strategic-dossier.md` | `BINDING` | RED Commander Dossier |
| 54 | `OMW-RED-NETWORK-OPERATIONS-001` | `docs/54-red-network-operations-and-insurgent-systems.md` | `BINDING` | Insurgent Networks |
| 55 | `OMW-CAMPAIGN-ASSESSMENT-001` | `docs/55-campaign-assessment-and-nonstate-security.md` | `BINDING` | Campaign Assessment |
| 56 | `OMW-RED-INSURGENT-FACTIONS-SHADOW-GOVERNANCE` | `docs/56-insurgent-factions-shadow-governance-and-red-commander-behavior.md` | `BINDING` | Insurgent factions and shadow governance |
| 57 | `OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM` | `docs/57-kandahar-helmand-enemy-system-and-red-commander-strategy.md` | `BINDING` | Kandahar-/Helmand-Enemy-System |
| 58 | `OMW-RED-EASTERN-AFGHANISTAN-NETWORK-OPERATIONS` | `docs/58-eastern-afghanistan-network-operations-and-complex-attack-model.md` | `BINDING` | ostafghanisches Netzwerk- und Complex-Attack-Modell |
| 59 | `OMW-COIN-ASSESSMENT-TRANSITIONS-NONSTATE-SECURITY` | `docs/59-campaign-assessment-operational-transitions-and-nonstate-security.md` | `BINDING` | Campaign Assessment und nichtstaatliche Sicherheitsakteure |
| 60 | `OMW-HIST-AFGHANISTAN-AIR-WARS-2009-2011` | `docs/60-afghan-air-wars-2009-2011-airpower-operations-reference.md` | `BINDING` | Airpower-, ORBAT-, ISR- und CSAR-Referenz |
| 61 | `OMW-COIN-GOVERNANCE-STRATEGY-TRANSITION` | `docs/61-coin-governance-strategy-and-afghan-led-transition.md` | `BINDING` | COIN-, Governance- und Transition-Referenz |
| 62 | `OMW-RED-CONTROL-INTELLIGENCE-TTP-COIN-IPB` | `docs/62-insurgent-control-intelligence-ttp-and-coin-ipb.md` | `BINDING` | RED-Kontrolle, Intelligence, TTP und COIN-IPB |
| 63 | `OMW-BLUE-NTMA-SFA-ATN-STRATCOM-LOCAL-INFLUENCE` | `docs/63-ntma-sfa-attack-the-network-stratcom-and-local-influence.md` | `BINDING` | NTM-A, SFA, AtN, StratCom und Einflussnetzwerke |
| 64 | `OMW-HIST-AFGHANISTAN-ORBAT-2011-07` | `docs/64-afghanistan-order-of-battle-july-2011.md` | `BINDING` | vollständiger Juli-2011-ORBAT-Snapshot |
| 65 | `OMW-STAB-PRT-INTERAGENCY-DISTRICT-FRAMEWORK` | `docs/65-stability-operations-prt-interagency-and-district-framework.md` | `BINDING` | Stability Operations, PRT und District Framework |
| 66 | `OMW-RED-LAYEHA-COMMAND-DISCIPLINE-SHADOW-JUSTICE` | `docs/66-taliban-layeha-command-discipline-and-shadow-justice.md` | `BINDING` | Taliban-Layeha, Disziplin und Shadow Justice |
| 67 | `OMW-CIED-ROUTE-CLEARANCE-CONVOY-DESIGN` | `docs/67-afghanistan-route-clearance-counter-ied-and-convoy-design.md` | `BINDING` | Route Clearance, C-IED und Convoy Design |
| 68 | `OMW-OE-KANDAHAR-CITY-DAND-2010` | `docs/68-kandahar-city-and-dand-operational-environment-2010.md` | `BINDING` | Kandahar City/Dand OE 2010 |
| 69 | `OMW-STAB-CERP-REGIONAL-PROJECTS-2009-2010` | `docs/69-cerp-regional-projects-2009-2010.md` | `BINDING` | regionale CERP-Projekte |
| 70 | `OMW-RED-SIGACT-PATTERNS-2010-08-10` | `docs/70-nato-isaf-sigact-patterns-august-october-2010.md` | `BINDING` | SIGACT-Muster Aug–Okt 2010 |
| 71 | `OMW-HIST-ISAF-FORCE-POSTURE-MAPS-ADDITIONAL-SOURCES` | `docs/71-isaf-force-posture-maps-and-additional-historical-sources.md` | `BINDING` | ISAF-RC-/PRT-Karten und Zusatzquellen |
| 72 | `OMW-AIR-AFGHANISTAN-AIP-2008` | `docs/72-afghanistan-aip-2008-airspace-aerodromes-and-flight-procedures.md` | `BINDING` | Afghanistan-AIP-Baseline |
| 73 | `OMW-AIR-KAIA-LOCAL-OPERATING-PROCEDURES-2009` | `docs/73-kaia-local-operating-procedures-2009.md` | `BINDING` | KAIA-Betriebsverfahren |
| 74 | `OMW-HIST-WANAT-TF-BAYONET-TF-ROCK-FORCE-POSTURE` | `docs/74-wanat-tf-bayonet-tf-rock-force-posture-2007-2008.md` | `BINDING` | Wanat-, TF-Bayonet-/TF-Rock- und Aviation-Force-Posture |
| 75 | `OMW-HIST-VANGUARD-SMALL-UNIT-OPERATIONS-2006-2011` | `docs/75-vanguard-of-valor-small-unit-operations-2006-2011.md` | `BINDING` | Small-Unit Operations, Enabler, Fires und Sustainment |
| 76 | `OMW-HIST-STRYKER-KANDAHAR-2009` | `docs/76-stryker-brigade-operations-kandahar-2009.md` | `BINDING` | Stryker-Brigade-/Bataillonsoperationen Kandahar 2009 |
| 77 | `OMW-HIST-ARSOF-SOF-AVIATION-EARLY-OEF` | `docs/77-arsof-sof-aviation-and-early-oef-operational-models.md` | `BINDING` | ARSOF, SOF Aviation, CSAR, PSYOP und CA 2001–2002 |
| 78 | `OMW-HIST-US-ARMY-OEF-COMMAND-FORCE-POSTURE-2001-2005` | `docs/78-us-army-oef-command-force-posture-and-orbat-2001-2005.md` | `BINDING` | US-Army-Kommando, Force Posture und ORBAT 2001–2005 |
| 79 | `OMW-HIST-BALUCH-KALAY-AIR-ASSAULT-2005` | `docs/79-baloch-kalay-air-assault-and-company-combat-2005.md` | `BINDING` | Baluch-Kalay-Air-Assault, Company Combat und adaptive Führung |
| 80 | `OMW-COIN-CULTURAL-TURN-HUMAN-TERRAIN-CRITICISM` | `docs/80-cultural-turn-human-terrain-and-coin-criticism.md` | `BINDING` | Cultural Turn, Human Terrain und quellenkritische COIN-Referenz |
| 81 | `OMW-AIR-SALERNO-MANIFEST` | `docs/81-salerno-air-operations-manifest.md` | `BINDING` | Salerno-ME-Baseline und Objektvertrag |
| 82 | `OMW-HIST-RUSSIA-OEF-ISAF-AFGHANISTAN` | `docs/82-russia-oef-isaf-afghanistan-role.md` | `BINDING` | russische Rolle, Kooperation, Konkurrenz und Evidenzgrenzen in OEF/ISAF |

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
| `OMW-AIR-AIRFIELD-IMPLEMENTATION-WORKFLOW` | `docs/airfield-airwing-squadron-commander-implementation-workflow.md` | `BINDING`; allgemeiner Airfield-AIRWING-Workflow |
| `OMW-HANDOFF-TEMPLATE-AIRFIELD-AIRWING-COMMANDER` | `docs/handoffs/TEMPLATE-airfield-airwing-squadron-commander-chat-handoff.md` | `BINDING`; Chat-Handoff-Vorlage |
| `OMW-AIR-US-ORBAT-RESEARCH` | `docs/us-air-orbat-2010-2011.md` | `BINDING`; historische Forschung |
| `OMW-GOV-SOURCE-USE` | `docs/sources/graveyard-of-empires.md` | `BINDING_PROJECT_DECISION` |
| `OMW-GOV-MOOSE-VERSION` | `docs/moose/VERSION-AND-SOURCES.md` | `BINDING` |
| `OMW-MOOSE-DOCUMENTATION-INDEX` | `docs/moose/README.md` | `BINDING` |
| `OMW-MOOSE-CLASS-INDEX` | `docs/moose/PROJECT-CLASS-INDEX.md` | `BINDING` |
| `OMW-MOOSE-FOG-OF-WAR-RECCE` | `docs/moose/FOG-OF-WAR-RECCE.md` | `PLANNED` |
| `OMW-MOOSE-VERIFIED-METHODS` | `docs/moose/VERIFIED-METHODS.md` | `BINDING` |
| `OMW-CSAR-INDEX` | `docs/csar/README.md` | `BINDING` |
| `OMW-CSAR-SOURCE-NOTES-1-8` | `docs/csar/source-notes-1-8.md` | `BINDING` |
| `OMW-CSAR-AFGHANISTAN-2010-FACILITIES` | `docs/csar/afghanistan-2010-facilities-and-coverage.md` | `BINDING` |
| `OMW-CSAR-MISSION-DESIGN-REQUIREMENTS` | `docs/csar/mission-design-requirements.md` | `PLANNED` |
| `OMW-CSAR-MOOSE-AICSAR-DEVELOPMENT-BASELINE` | `docs/csar/moose-csar-aicsar-development-baseline.md` | `PLANNED` |
| `OMW-WX-DATASET-DOCUMENTATION` | `docs/data/weather/README.md` | `BINDING` |
| `OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE` | `docs/targeting/afghanistan-nsl-data-use-policy.md` | `BINDING` |
| `OMW-TARGETING-AFGHANISTAN-NSL-LEGACY-PATH` | `docs/targeting/afghanistan-no-strike-list.md` | `SUPERSEDED` |
| `OMW-ADR-0001-USE-MOOSE` | `docs/adr/0001-use-moose.md` | `SUPERSEDED` |
| `OMW-ADR-0002-USE-MOOSE-CTLD-CSAR` | `docs/adr/0002-use-moose-ctld-and-csar.md` | `SUPERSEDED` |
| `OMW-ADR-0003-ME-GROUP-TEMPLATES` | `docs/adr/0003-use-mission-editor-group-templates.md` | `BINDING` |
| `OMW-ADR-0004-LOCATION-REGISTRY` | `docs/adr/0004-use-explicit-location-registry.md` | `BINDING` |
| `OMW-EVIDENCE-INDEX` | `docs/evidence/README.md` | `BINDING` |
| `OMW-EVIDENCE-SOURCE-INTAKE-AUDIT-2026-07-28` | `docs/evidence/source-intake-audit-2026-07-28.md` | `BINDING` |
| `OMW-AIR-TKOT-MANIFEST` | `docs/tarinkot-air-operations-manifest.md` | `DRAFT`; owner-accepted branch contract; G4 source review complete |
| `OMW-EVIDENCE-TARINKOT-ME-AUDIT-OMW-TEMPLATE-V5-SALERNO` | `docs/evidence/tarinkot-mission-editor-audit-omw-template-v5-salerno.md` | `BINDING`; current MIZ audit |
| `OMW-EVIDENCE-TARINKOT-AVIATION-2011` | `docs/evidence/tarinkot-2011-aviation-unit-and-aircraft-evidence.md` | `BINDING`; 2011 aviation/unit evidence |
| `OMW-EVIDENCE-TARINKOT-AVIATION-ROTATIONS` | `docs/evidence/tarinkot-aviation-rotations-and-national-attribution-2006-2013.md` | `BINDING`; rotation/national-attribution evidence |
| `OMW-EVIDENCE-TARINKOT-POST-PERIOD-AVIATION-BASE-LAYOUT` | `docs/evidence/tarinkot-post-period-aviation-and-base-layout-context-2012-2013.md` | `BINDING`; post-period context |
| `OMW-EVIDENCE-TARINKOT-FARP-HOT-REFUEL-UH60-2011` | `docs/evidence/tarinkot-farp-hot-refuel-uh60-2011.md` | `BINDING`; FARP/hot-refuel evidence |
| `OMW-EVIDENCE-TARINKOT-TF-ATTACK-STRUCTURE-CORRECTION` | `docs/evidence/tarinkot-source-critical-correction-task-force-attack-structure.md` | `BINDING`; source-critical correction |
| `OMW-DECISION-TARINKOT-ACTIVE-BASELINE-2026-08-02` | `docs/evidence/tarinkot-owner-decision-active-baseline-2026-08-02.md` | `BINDING_PROJECT_DECISION`; historical baseline |
| `OMW-DECISION-TARINKOT-G2-OBJECT-CONTRACT-2026-08-03` | `docs/evidence/tarinkot-g2-object-contract-acceptance-checklist-2026-08-03.md` | `DRAFT`; complete G2 checklist |
| `OMW-DECISION-TARINKOT-G2-OWNER-ACCEPTANCE-2026-08-03` | `docs/evidence/tarinkot-g2-owner-acceptance-2026-08-03.md` | `BINDING_PROJECT_DECISION`; explicit G2 acceptance |
| `OMW-EVIDENCE-TARINKOT-G4-MOOSE-2-9-18-SOURCE-REVIEW` | `docs/evidence/tarinkot-g4-moose-2-9-18-source-review.md` | `BINDING`; exact MOOSE source review |
| `OMW-TEST-JBAD-AIR-OPS-INDEX` | `mission/tests/jalalabad-air-operations/README.md` | `BINDING` |

## 5. Legacy- und Evidenzregel

Dateien unter `docs/evidence/source-records/` bewahren frühere Vollfassungen. Ihre alten Titelnummern und Aussagen sind keine aktuelle Nummern-, Status- oder Governance-Vergabe.
