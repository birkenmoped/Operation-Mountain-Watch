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
  - incomplete documentation index without subproject registry
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Operation Mountain Watch – Dokumentationsindex

## 1. Verbindliche Einstiegspunkte

| Zweck | Quelle |
|---|---|
| höchste Projekt-Governance | [`OMW-GOV-001`](00-project-governance.md) |
| Dokumentmetadaten und Provenienz | [`OMW-GOV-DOCUMENT-METADATA`](DOCUMENT-METADATA-POLICY.md) |
| Nummern und stabile IDs | [`OMW-GOV-DOCUMENT-REGISTRY`](DOCUMENT-REGISTRY.md) |
| offene Unterprojekte und Branchabhängigkeiten | [`OMW-GOV-SUBPROJECT-REGISTRY`](SUBPROJECT-REGISTRY.md) |
| MOOSE-First und Ausnahmen | [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md) |

## 2. Autoritätshierarchie

1. `OMW-GOV-001` und ausdrückliche Projektinhaberentscheidungen auf `main`;
2. aktuelle `BINDING_PROJECT_DECISION`- und `BINDING`-Dokumente auf `main`;
3. exakt nachgewiesene technische Acceptance für den dokumentierten Branch-, Commit-, Missions-, Bundle-, DCS- und MOOSE-Stand;
4. Manifeste und Arbeitslisten, soweit sie nicht ersetzt sind;
5. historische Testberichte und Legacy-Evidenz;
6. externe Quellen für den tatsächlich belegten Inhalt.

Ein offener Draft-PR ist keine `main`-Autorität. Ein branchgebundener PASS bleibt auf seinen exakt dokumentierten Teststand begrenzt.

## 3. Source-of-Truth-Matrix

| Thema | Autoritative Quelle | Status | Ergänzende Evidenz |
|---|---|---|---|
| Projekt-Governance | [`OMW-GOV-001`](00-project-governance.md) | `BINDING_PROJECT_DECISION` | ADRs und Fachbaselines |
| Dokumentmetadaten | [`OMW-GOV-DOCUMENT-METADATA`](DOCUMENT-METADATA-POLICY.md) | `BINDING` | Dokumentationsvalidator |
| Dokumentnummern/IDs | [`OMW-GOV-DOCUMENT-REGISTRY`](DOCUMENT-REGISTRY.md) | `BINDING_PROJECT_DECISION` | dieser Index |
| Unterprojekte/PR-Stacks | [`OMW-GOV-SUBPROJECT-REGISTRY`](SUBPROJECT-REGISTRY.md) | `BINDING` | GitHub-PR-Metadaten |
| historischer Rahmen | [`OMW-HIST-SETTING`](09-historical-setting.md) | `BINDING` | historische Quellen |
| historische Kräfte-, Basen- und Aviation-Recherche | [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION`](50-afghanistan-force-basing-aviation-2010-2011.md) | `BINDING` | CMH-, Army-, DVIDS-, ORBAT- und Fachquellen; keine aktive ORBAT-Autorität |
| USMC RC-Southwest und Koalitionsoperationen | [`OMW-HIST-USMC-RC-SOUTHWEST-COALITION-OPS`](51-usmc-rc-southwest-and-coalition-operations-2010-2011.md) | `BINDING` | USMC-Anthologie, Army.mil, CENTCOM und quellenqualifizierte Sekundär-/Lead-Quellen |
| Army Aviation Vignetten und COIN-Intelligence/Metriken | [`OMW-HIST-ARMY-AVIATION-COIN-INTELLIGENCE-METRICS`](52-army-aviation-vignettes-and-coin-intelligence-metrics.md) | `BINDING` | Army-/State-DoD-/UK-MoD-Ursprungsquellen, qualifiziertes Memoir und gesperrte Quellenakte |
| Systemarchitektur | [`OMW-ARCH-SYSTEM`](03-system-architecture.md) | `BINDING` | Dokument 37 |
| CampaignState/dynamische Kampagne | [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md) | `BINDING` | Dokumente 04–07, TM01/TM02-Reviews |
| Fog of War / RECCE | [`OMW-MOOSE-FOG-OF-WAR-RECCE`](moose/FOG-OF-WAR-RECCE.md) | `PLANNED` | MOOSE-Develop geprüft; Laufzeitvalidierung im gepinnten MOOSE-Stand ausstehend |
| aktive Luft-ORBAT/Clientgrenzen | [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md) | `BINDING_PROJECT_DECISION` | historische ORBAT-Recherche |
| technische Luftoperationen | [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md) | `BINDING` | MOOSE Air Operations |
| Jalalabad-ME-Baseline | [`OMW-AIR-JBAD-MANIFEST`](21-jalalabad-air-operations-manifest.md) | `BINDING` | PR #18 und Testprojektindex |
| Missionseditor-Masterarbeit | [`OMW-ME-MASTER-WORKLIST`](38-mission-editor-master-worklist.md) | `BINDING` | basisbezogene Manifeste |
| MSR/Routing | [`OMW-MSR-ROUTE-DESIGN`](49-msr-routendesign-und-infrastrukturmarker.md) | `PLANNED` | TM01M und Legacy-Routentests |
| CSAR-Quellen/Anforderungen | [`OMW-CSAR-INDEX`](csar/README.md) | `BINDING` | CSAR-Unterdokumente |
| NSL/Targeting | [`OMW-TARGETING-AFGHANISTAN-NSL`](48-afghanistan-no-strike-list.md) | `BINDING` | [Datenrichtlinie](targeting/afghanistan-nsl-data-use-policy.md) |
| Wetterdaten | [`OMW-WX-HISTORICAL-BASELINE`](41-historical-weather-baseline-2010-2011.md) | `BINDING` | [Datensatzdokumentation](data/weather/README.md) |
| Regen-Arbeitsprofil | [`OMW-WX-RAIN-PROFILE`](43-dcs-rain-shower-preset-validation.md) | `BINDING` | visuell bestätigt, keine formale Acceptance |
| technische Evidenz | [`OMW-EVIDENCE-INDEX`](evidence/README.md) | `BINDING` für Einordnung | Testberichte und Legacy-Texte |

## 4. Nummerierte Dokumente auf `main`

### Grundlagen und Governance

- [00 – Projekt-Governance](00-project-governance.md)
- [01 – Vision](01-vision.md)
- [02 – Gameplay-Konzept](02-gameplay-concept.md)
- [03 – Systemarchitektur](03-system-architecture.md)
- [04 – CampaignState](04-campaign-state.md)
- [05 – Logistik](05-logistics.md)
- [06 – ersetzter Red Director](06-red-director.md)
- [07 – Virtualisierung](07-virtualization.md)
- [08 – ersetzte frühe CSAR-Grundlage](08-csar.md)
- [09 – historischer Rahmen](09-historical-setting.md)
- [10 – Operationsraum und Sektoren](10-theater-and-sectors.md)
- [11 – Basen und FOBs](11-bases-and-fobs.md)
- [12 – ersetztes frühes Routennetz](12-route-network.md)
- [13 – Einheitenkatalog](13-unit-catalog.md)
- [14 – ersetzter vertikaler Prototyp](14-prototype-scope.md)
- [15 – Template Library und Spawning](15-template-library-and-spawning.md)
- [16 – World Data und Routing](16-world-data-and-routing.md)
- [17 – Pathfinding-Optionen](17-pathfinding-options.md)

### Luftoperationen und MOOSE-First

- [18 – technische Luftoperationen](18-air-operations-implementation.md)
- [19 – aktive Luft-ORBAT](19-active-air-orbat-decisions.md)
- [20 – Air-Ops-ME-Arbeitsliste](20-air-orbat-mission-editor-worklist.md)
- [21 – Jalalabad-Manifest](21-jalalabad-air-operations-manifest.md)
- [26 – MOOSE-First](26-moose-first-development-policy.md)

### Kommunikation, AAR, Architektur und Fachbereiche

- [27 – JTAC-/Air-Land-C2-Callsigns](27-oef-jtac-callsign-reference.md)
- [28 – TAD und Color Nets](28-afghanistan-tad-color-nets.md)
- [29 – ISAF AAR/ACO](29-isaf-2009-2013-air-to-air-refueling.md)
- [30 – AAR-Abbildungsreferenz](30-isaf-2009-2013-aar-part2-figure-reference.md)
- [37 – Kampagnenarchitektur](37-campaign-architecture-and-dynamic-mission-design.md)
- [38 – Missionseditor-Masterarbeitsliste](38-mission-editor-master-worklist.md)
- [39 – TM01/TM02 MOOSE-First Review](39-tm01-tm02-moose-first-code-review.md)
- [40 – MOOSE-Adoptionsplan](40-moose-module-adoption-plan-for-tm01-tm02.md)
- [41 – historische Wetterbaseline](41-historical-weather-baseline-2010-2011.md)
- [42 – DCS-Wettereditor-Validierung](42-dcs-weather-editor-validation.md)
- [43 – Regen-/Schauer-Arbeitsprofil](43-dcs-rain-shower-preset-validation.md)
- [44 – Talnebel-/Tiefe-Wolken-Testplanung](44-dcs-valley-mist-low-cloud-test-profile.md)
- [45 – Air C2 und CAS](45-air-c2-cas-afghanistan.md)
- [46 – Non-Lethal Use of Force](46-non-lethal-use-of-force.md)
- [47 – Aircraft Tactical Callsigns](47-aircraft-tactical-callsigns.md)
- [48 – Afghanistan No-Strike List](48-afghanistan-no-strike-list.md)
- [49 – MSR-Routendesign](49-msr-routendesign-und-infrastrukturmarker.md)
- [50 – Afghanistan Kräfte, Basen und Aviation 2010–2011](50-afghanistan-force-basing-aviation-2010-2011.md)
- [51 – USMC RC-Southwest und Koalitionsoperationen 2010–2011](51-usmc-rc-southwest-and-coalition-operations-2010-2011.md)
- [52 – Army Aviation Vignetten, Chinook Operations und COIN-Intelligence/Metriken](52-army-aviation-vignettes-and-coin-intelligence-metrics.md)

## 5. Architekturentscheidungen

- [`ADR-0001`](adr/0001-use-moose.md) – historische Grundentscheidung MOOSE;
- [`ADR-0002`](adr/0002-use-moose-ctld-and-csar.md) – historische CTLD-/CSAR-Grundentscheidung;
- [`OMW-ADR-0003-ME-GROUP-TEMPLATES`](adr/0003-use-mission-editor-group-templates.md) – Mission-Editor-Gruppen als Spawnvorlagen;
- [`OMW-ADR-0004-LOCATION-REGISTRY`](adr/0004-use-explicit-location-registry.md) – eigenes Ortsregister und validierte Terrainpfade.

## 6. Thematische Unterverzeichnisse

### MOOSE

- [`MOOSE-Dokumentationsindex`](moose/README.md)
- [`VERSION-AND-SOURCES`](moose/VERSION-AND-SOURCES.md)
- [`PROJECT-CLASS-INDEX`](moose/PROJECT-CLASS-INDEX.md)
- [`VERIFIED-METHODS`](moose/VERIFIED-METHODS.md)
- [`AIR-OPERATIONS`](moose/AIR-OPERATIONS.md)
- [`GROUND-OPERATIONS`](moose/GROUND-OPERATIONS.md)
- [`LOGISTICS-AND-TRANSPORT`](moose/LOGISTICS-AND-TRANSPORT.md)
- [`EVENTS-AND-FSM`](moose/EVENTS-AND-FSM.md)
- [`ISR-FAC-CAS-AAR`](moose/ISR-FAC-CAS-AAR.md)
- [`FOG-OF-WAR-RECCE`](moose/FOG-OF-WAR-RECCE.md)

### CSAR

- [`OMW-CSAR-INDEX`](csar/README.md)
- [`OMW-CSAR-SOURCE-NOTES-1-8`](csar/source-notes-1-8.md)
- [`OMW-CSAR-AFGHANISTAN-2010-FACILITIES`](csar/afghanistan-2010-facilities-and-coverage.md)
- [`OMW-CSAR-MISSION-DESIGN-REQUIREMENTS`](csar/mission-design-requirements.md)

### Quellen, Targeting und Wetterdaten

- [`OMW-GOV-SOURCE-USE`](sources/graveyard-of-empires.md)
- [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION`](50-afghanistan-force-basing-aviation-2010-2011.md)
- [`OMW-HIST-USMC-RC-SOUTHWEST-COALITION-OPS`](51-usmc-rc-southwest-and-coalition-operations-2010-2011.md)
- [`OMW-HIST-ARMY-AVIATION-COIN-INTELLIGENCE-METRICS`](52-army-aviation-vignettes-and-coin-intelligence-metrics.md)
- [`OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE`](targeting/afghanistan-nsl-data-use-policy.md)
- [`OMW-TARGETING-AFGHANISTAN-NSL-LEGACY-PATH`](targeting/afghanistan-no-strike-list.md)
- [`OMW-WX-DATASET-DOCUMENTATION`](data/weather/README.md)

### Evidenz

- [`OMW-EVIDENCE-INDEX`](evidence/README.md)
- [`Jalalabad-Ausgangsaudit`](evidence/jalalabad-air-operations-baseline-audit.md)

## 7. Unterprojekte und offene Branches

Der vollständige und verbindliche Überblick steht in:

- [`OMW-GOV-SUBPROJECT-REGISTRY`](SUBPROJECT-REGISTRY.md).

Er erfasst derzeit PR #3–#18, #22, #24, #33 und #38 einschließlich Parent-/Base-Beziehungen, Acceptance-Grenzen und Produktionsrelevanz.

## 8. Status-, Provenienz- und Querverweisregel

- Zulässige Governance-Statuswerte stehen in `OMW-GOV-001`.
- Quellen- und Bearbeitungszustände werden getrennt geführt.
- `source_commit` folgt [`OMW-GOV-DOCUMENT-METADATA`](DOCUMENT-METADATA-POLICY.md).
- `ACCEPTED_TECHNICAL_BASELINE` benötigt vollständige technische Provenienz.
- Verweise verwenden stabile ID und relativen Pfad.
- Branchdateien werden mit PR, Branch und Commit bezeichnet.
- Legacy-Texte besitzen keine parallele Governance-Autorität.
