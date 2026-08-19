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
  - registry that listed Document 22 only as a branch reservation
superseded_by:
source_branch: main
source_commit: GIT_HISTORY
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
| 22 | `OMW-TEST-MISSION-BUILD-TRANSFER-VALIDATION` | `docs/22-test-mission-build-transfer-and-validation-workflow.md` | `BINDING` | Testartefakt-, Transfer-, Hash- und Validierungsworkflow |
| 26 | `OMW-GOV-MOOSE-FIRST` | `docs/26-moose-first-development-policy.md` | `BINDING_PROJECT_DECISION` | MOOSE-First |
| 27 | `OMW-C2-JTAC-CALLSIGNS` | `docs/27-oef-jtac-callsign-reference.md` | `BINDING` | Quellenreferenz |
| 28 | `OMW-C2-TAD-COLOR-NETS` | `docs/28-afghanistan-tad-color-nets.md` | `BINDING` | Quellenbasierter Datensatz |
| 29 | `OMW-AAR-ISAF-ACO` | `docs/29-isaf-2009-2013-air-to-air-refueling.md` | `BINDING_PROJECT_DECISION` | AAR-/ACO-Referenz und operative AAR-Baseline |
| 30 | `OMW-AAR-PART2-FIGURE` | `docs/30-isaf-2009-2013-aar-part2-figure-reference.md` | `BINDING` | Abbildungsreferenz |
| 31 | `OMW-AIR-BAGRAM-MANIFEST` | `docs/31-bagram-air-operations-manifest.md` | `BINDING` | Bagram aktive Air-ORBAT und dualer AIRWING-Foundation-Vertrag |
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
| 50 | `OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION` | `docs/50-afghanistan-force-basing-aviation-2010-2011.md` | `BINDING` | historische Kräfte-, Basierungs-, Aviation- und TTP-Referenz |
| 51 | `OMW-HIST-USMC-RC-SOUTHWEST-COALITION-OPS` | `docs/51-usmc-rc-southwest-and-coalition-operations-2010-2011.md` | `BINDING` | USMC-RC-Southwest-, Koalitionsoperations- und Missionsmuster-Referenz |
| 52 | `OMW-HIST-ARMY-AVIATION-COIN-INTELLIGENCE-METRICS` | `docs/52-army-aviation-vignettes-and-coin-intelligence-metrics.md` | `BINDING` | Army-Aviation-, Chinook-, Emergency-, Intelligence- und Missionsmetriken-Referenz |
| 53 | `OMW-HIST-AFGHANISTAN-WAR-CARLISLE-SOURCE-REVIEW` | `docs/53-afghanistan-war-carlisle-source-review.md` | `BINDING` | quellenkritische Sekundär- und Hintergrundreferenz |
| 54 | `OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS` | `docs/54-air-tasking-airspace-control-cas-requests-and-mission-data.md` | `BINDING` | Air-C2-, ATO-/ACO-/SPINS-, Request- und Missionsdatenreferenz |
| 55 | `OMW-HIST-MONTHLY-COALITION-ORBAT-BASING` | `docs/55-monthly-coalition-orbat-and-basing-2010-2011.md` | `BINDING` | monatliche Koalitions-ORBAT-, Basierungs- und AOR-Referenz |
| 56 | `OMW-RED-INSURGENT-FACTIONS-BEHAVIOR` | `docs/56-insurgent-factions-shadow-governance-and-red-commander-behavior.md` | `BINDING` | konsolidierter RED Commander; historisches Insurgentenverhalten |
| 57 | `OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM` | `docs/57-kandahar-helmand-enemy-system-and-red-commander-strategy.md` | `BINDING` | Kandahar-/Helmand-Enemy-System |
| 58 | `OMW-RED-EASTERN-AFGHANISTAN-NETWORK-OPERATIONS` | `docs/58-eastern-afghanistan-network-operations-and-complex-attack-model.md` | `BINDING` | ostafghanisches Netzwerk- und Complex-Attack-Modell |
| 59 | `OMW-COIN-ASSESSMENT-TRANSITIONS-NONSTATE-SECURITY` | `docs/59-campaign-assessment-operational-transitions-and-nonstate-security.md` | `BINDING` | Campaign Assessment und nichtstaatliche Sicherheitsakteure |
| 60 | `OMW-HIST-AFGHAN-AIR-WARS-2009-2011` | `docs/60-afghan-air-wars-2009-2011-airpower-operations-reference.md` | `BINDING` | Airpower-, ORBAT-, ISR- und CSAR-Referenz |
| 61 | `OMW-COIN-GOVERNANCE-STRATEGY-TRANSITION` | `docs/61-coin-governance-strategy-and-afghan-led-transition.md` | `BINDING` | COIN-, Governance- und Transition-Referenz |
| 62 | `OMW-RED-CONTROL-INTELLIGENCE-TTP-COIN-IPB` | `docs/62-insurgent-control-intelligence-ttp-and-coin-ipb.md` | `BINDING` | RED-Kontrolle, Intelligence, TTP und COIN-IPB |
| 63 | `OMW-BLUE-NTMA-SFA-ATN-STRATCOM-LOCAL-INFLUENCE` | `docs/63-ntma-sfa-attack-the-network-stratcom-and-local-influence.md` | `BINDING` | NTM-A, SFA, AtN und lokale Einflussnetzwerke |
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
| 83 | `OMW-HIST-A10-SOF-VEHICLE-SOURCE-REVIEW` | `docs/83-a10-sof-and-special-operations-vehicle-source-review.md` | `BINDING` | A-10-, SOF- und Special-Operations-Vehicle-Quellenreview |
| 84 | `OMW-HIST-AIR-SOF-INTEL-METRICS-SOURCE-REVIEW` | `docs/84-av8b-f14-takur-ghar-and-intelligence-metrics-source-review.md` | `BINDING` | AV-8B-, F-14-, Takur-Ghar- sowie Intelligence-/Metrics-Quellenreview |
| 85 | `OMW-HIST-PREDATOR-REAPER-AFGHANISTAN-SOURCE-REVIEW` | `docs/85-predator-reaper-afghanistan-source-review.md` | `BINDING` | MQ-1-/MQ-9-, Afghanistan-, Bewaffnungs-, Endurance- und RPA-Betriebsquellenreview |
| 86 | `OMW-HIST-KC135-AFGHANISTAN-2011-SOURCE-REVIEW` | `docs/86-kc135-afghanistan-2011-source-review.md` | `BINDING` | KC-135-, Afghanistan-2011-, Fuel-, Einheiten- und AAR-Betriebsquellenreview |
| 87 | `OMW-HIST-AFGHANISTAN-CSAR-KANDAHAR-SOURCE-REVIEW` | `docs/87-afghanistan-csar-and-kandahar-airfield-source-review.md` | `BINDING` | Afghanistan-2011-CSAR-, Rescue-, Kandahar- und Airfield-Quellenreview |
| 88 | `OMW-AIR-TASKING-PLAN-FOUNDATION` | `docs/88-air-tasking-plan-foundation.md` | `BINDING_PROJECT_DECISION` | Air-Tasking-Plan-Architektur und MOOSE-Integrationsgrenze |
| 89 | `OMW-AAR-ACCEPTANCE-7-FINALIZATION` | `docs/89-aar-acceptance-7-finalization.md` | `BINDING_PROJECT_DECISION` | Acceptance-7-abgeleitete finale AAR-Designbaseline |

## 3. Reservierte Nummern auf offenen Branches

| PR | Nummern | Status |
|---:|---|---|
| 18 | 23–25 | nur Draft-PR #18; branchgebundene Air-Ops-Dokumente |
| 18 | 22 | branchlokale Altversion; durch die kanonische `main`-Fassung von Dokument 22 ersetzt |
| 18 | 27 | branchlokale Kollision; vor Integration zwingend neu nummerieren |
| 24 | 31 | branchlokale ältere Fassung; die reduzierte `main`-Fassung von Dokument 31 ist autoritativ |
| 24 | 32–36 | nur Draft-PR #24; Bagram/Kandahar; vor Integration gegen den aktuellen `main`-Bestand und Nummernkollisionen prüfen |

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
| `OMW-MOOSE-VERIFIED-METHODS` | `docs/moose/VERIFIED-METHODS.md` | `BINDING` |
| `OMW-MOOSE-AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE` | `docs/moose/AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE.md` | `BINDING`; Lifecycle- und Testgrenzen |
| `OMW-MOOSE-WAREHOUSE-PARKING-OVERRIDE-RESEARCH` | `docs/moose/WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md` | `BINDING`; WAREHOUSE-Parking-Scanwerte, APIs und Override-Grenzen |
| `OMW-MOOSE-FOG-OF-WAR-RECCE` | `docs/moose/FOG-OF-WAR-RECCE.md` | `PLANNED` |
| `OMW-MOOSE-STORAGE-WAREHOUSE-RESOURCE-FOUNDATION` | `docs/moose/STORAGE-WAREHOUSE-RESOURCE-FOUNDATION.md` | `BINDING`; MOOSE STORAGE/Warehouse Resource Foundation |
| `OMW-WAREHOUSE-RESOURCE-FOUNDATION-COMPLETE` | `docs/warehouse-resource-foundation-complete.md` | `BINDING_PROJECT_DECISION`; konsolidierter Warehouse-/Resource-Abschlussstand |
| `OMW-ACC-FIGHTER-STORE-RUNTIME-CORRELATION-2026-08-13` | `docs/evidence/fighter-store-runtime-correlation-acceptance-2026-08-13.md` | `ACCEPTED_TECHNICAL_BASELINE`; finale Fighter-Store-Mapping-Acceptance |
| `OMW-DECISION-KANDAHAR-A10C-CAS-LOADOUT-2026-08-01` | `docs/evidence/kandahar-a10c-cas-loadout-decision-2026-08-01.md` | `BINDING_PROJECT_DECISION`; Kandahar A-10C II CAS-Stationen, Payload und Evidenzgrenze |
| `OMW-TEST-ARMY-GROUND-ACCEPTANCE-4` | `mission/tests/army-ground-foundation/ACCEPTANCE-4.md` | `ACCEPTED_TECHNICAL_BASELINE`; Fenty MOOSE return-handoff runtime gate |
| `OMW-TEST-ARMY-GROUND-ACCEPTANCE-5` | `mission/tests/army-ground-foundation/ACCEPTANCE-5.md` | `DCS_PENDING`; isolated Fenty four-out/four-back CampaignState normal-return gate |
| `OMW-RESULT-ARMY-GROUND-ACCEPTANCE-4-RUNTIME-20260819` | `mission/tests/army-ground-foundation/results/2026-08-19-acceptance-4-runtime.md` | `ACCEPTED_TECHNICAL_BASELINE`; exact Fenty return-handoff runtime evidence |
| `OMW-PLAN-ARMY-GROUND-RETURN-SETTLEMENT` | `docs/ground/ARMY-GROUND-RETURN-SETTLEMENT-DECISION-PREPARATION.md` | `PLANNED`; owner-decision inputs for Ground strategic return settlement |