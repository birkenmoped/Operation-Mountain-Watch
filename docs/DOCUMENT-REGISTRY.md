---
document_id: OMW-GOV-DOCUMENT-REGISTRY
status: BINDING_PROJECT_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - document number reservations
  - stable document IDs
  - main-branch document inventory
  - merge-time renumbering
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/resolve-document-number-collisions
source_commit:
validated_in_dcs: false
---

# Operation Mountain Watch – Zentrales Dokumentregister

## 1. Zweck und Bestandsregel

Dieses Register reserviert projektweit Dokumentnummern und stabile IDs. Eine Nummer darf nur einmal als aktuelle Nummer vergeben sein.

Für die Frage, welche Datei auf `main` vorhanden ist, gilt ausschließlich der reale Repository-Baum. Dateien auf offenen PR- oder Feature-Branches werden separat als Reservierung oder branchgebundene Evidenz geführt.

Verweise verwenden bevorzugt:

```text
<document_id> – <Pfad>
```

und nicht nur eine Nummer wie „Dokument 28“.

## 2. Aktuell auf `main` vorhandene nummerierte Dokumente

| Nr. | Stabile ID | Pfad | Dokumentstatus / Funktion |
|---:|---|---|---|
| 00 | `OMW-GOV-001` | `docs/00-project-governance.md` | `BINDING_PROJECT_DECISION`; höchste Projekt-Governance |
| 01 | `OMW-VISION` | `docs/01-vision.md` | Legacy-Grundlagendokument; Statusmigration ausstehend |
| 02 | `OMW-GAMEPLAY-CONCEPT` | `docs/02-gameplay-concept.md` | Legacy-Grundlagendokument; Statusmigration ausstehend |
| 03 | `OMW-ARCH-SYSTEM` | `docs/03-system-architecture.md` | `BINDING`; Systemgrenzen und Supersede-Hinweis zum vertikalen Prototyp |
| 04 | `OMW-ARCH-CAMPAIGN-STATE` | `docs/04-campaign-state.md` | Legacy-Grundlagendokument; Statusmigration und Abgleich mit Dokument 37 ausstehend |
| 05 | `OMW-LOGISTICS` | `docs/05-logistics.md` | Legacy-Fachdokument; Statusmigration ausstehend |
| 06 | `OMW-RED-DIRECTOR` | `docs/06-red-director.md` | Legacy-Fachdokument; Statusmigration ausstehend |
| 07 | `OMW-VIRTUALIZATION` | `docs/07-virtualization.md` | Legacy-Fachdokument; Statusmigration ausstehend |
| 08 | `OMW-CSAR-LEGACY` | `docs/08-csar.md` | frühes CSAR-Grundlagendokument; aktuelle CSAR-Dokumentation zusätzlich beachten |
| 09 | `OMW-HIST-SETTING` | `docs/09-historical-setting.md` | `BINDING_PROJECT_DECISION`; historischer Rahmen und Kampagnenzeitraum |
| 10 | `OMW-THEATER-SECTORS` | `docs/10-theater-and-sectors.md` | Legacy-Fachdokument; Statusmigration ausstehend |
| 11 | `OMW-BASES-FOBS` | `docs/11-bases-and-fobs.md` | Legacy-Fachdokument; Statusmigration ausstehend |
| 12 | `OMW-ROUTE-NETWORK` | `docs/12-route-network.md` | Legacy-Fachdokument; Statusmigration ausstehend |
| 13 | `OMW-UNIT-CATALOG` | `docs/13-unit-catalog.md` | Legacy-Fachdokument; Statusmigration ausstehend |
| 14 | `OMW-PHASE-VERTICAL-PROTOTYPE` | `docs/14-prototype-scope.md` | `SUPERSEDED`; frühere vertikale Prototypphase |
| 15 | `OMW-TEMPLATE-LIBRARY-SPAWNING` | `docs/15-template-library-and-spawning.md` | Legacy-Designgrundlage; Statusmigration ausstehend |
| 16 | `OMW-WORLD-DATA-ROUTING` | `docs/16-world-data-and-routing.md` | Legacy-Designgrundlage; Statusmigration ausstehend |
| 17 | `OMW-ARCH-PATHFINDING-OPTIONS` | `docs/17-pathfinding-options.md` | Pathfinding- und Routingoptionen; Statusmigration ausstehend |
| 18 | `OMW-AIR-IMPLEMENTATION` | `docs/18-air-operations-implementation.md` | `BINDING`; technische Luftoperationsregeln, keine ORBAT- oder Client-Autorität |
| 19 | `OMW-AIR-ACTIVE-ORBAT` | `docs/19-active-air-orbat-decisions.md` | `BINDING_PROJECT_DECISION`; aktive Luft-ORBAT und Client-Grenzen |
| 20 | `OMW-AIR-ME-WORKLIST` | `docs/20-air-orbat-mission-editor-worklist.md` | `BINDING`; Foundation-Build-Arbeitsablauf für Luftoperationsknoten |
| 21 | `OMW-AIR-JBAD-MANIFEST` | `docs/21-jalalabad-air-operations-manifest.md` | älteres Jalalabad-Manifest; bis Statusmigration keine Autorität über Dokument 19/20 |
| 26 | `OMW-GOV-MOOSE-FIRST` | `docs/26-moose-first-development-policy.md` | `BINDING_PROJECT_DECISION`; MOOSE-First-Richtlinie |
| 27 | `OMW-C2-JTAC-CALLSIGNS` | `docs/27-oef-jtac-callsign-reference.md` | JTAC-Callsign-Referenz |
| 28 | `OMW-C2-TAD-COLOR-NETS` | `docs/28-afghanistan-tad-color-nets.md` | TAD-/Color-Net-Frequenzplan |
| 29 | `OMW-AAR-ISAF-ACO` | `docs/29-isaf-2009-2013-air-to-air-refueling.md` | ISAF-AAR-/ACO-Referenz |
| 30 | `OMW-AAR-PART2-FIGURE` | `docs/30-isaf-2009-2013-aar-part2-figure-reference.md` | AAR-Abbildungsreferenz |
| 37 | `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` | `docs/37-campaign-architecture-and-dynamic-mission-design.md` | Kampagnen- und Produktionsarchitektur; Governance-Metadatenmigration ausstehend |
| 38 | `OMW-ME-MASTER-WORKLIST` | `docs/38-mission-editor-master-worklist.md` | Foundation-Build-Masterarbeitsliste |
| 39 | `OMW-REVIEW-TM01-TM02-MOOSE-FIRST` | `docs/39-tm01-tm02-moose-first-code-review.md` | TM01-/TM02-MOOSE-First-Review |
| 40 | `OMW-PLAN-TM01-TM02-MOOSE-ADOPTION` | `docs/40-moose-module-adoption-plan-for-tm01-tm02.md` | MOOSE-Adoptionsplan |
| 41 | `OMW-WX-HISTORICAL-BASELINE` | `docs/41-historical-weather-baseline-2010-2011.md` | historische Wetterbaseline |
| 42 | `OMW-WX-DCS-IMPLEMENTATION` | `docs/42-dcs-weather-editor-validation.md` | DCS-Wettereditor-Validierung |
| 43 | `OMW-WX-RAIN-PROFILE` | `docs/43-dcs-rain-shower-preset-validation.md` | Regen-/Schauerprofil |
| 44 | `OMW-WX-MIST-PROFILE` | `docs/44-dcs-valley-mist-low-cloud-test-profile.md` | Talnebel-/Tiefe-Wolken-Testprofil |
| 45 | `OMW-C2-AIR-C2-CAS-AFGHANISTAN` | `docs/45-air-c2-cas-afghanistan.md` | Air C2 und CAS |
| 46 | `OMW-ROE-NON-LETHAL-USE-OF-FORCE` | `docs/46-non-lethal-use-of-force.md` | Show of Presence / Show of Force |
| 47 | `OMW-C2-AIRCRAFT-TACTICAL-CALLSIGNS` | `docs/47-aircraft-tactical-callsigns.md` | Aircraft Tactical Callsigns |
| 48 | `OMW-TARGETING-AFGHANISTAN-NSL` | `docs/48-afghanistan-no-strike-list.md` | Afghanistan No-Strike List und Targeting-Architektur |
| 49 | `OMW-MSR-ROUTE-DESIGN` | `docs/49-msr-routendesign-und-infrastrukturmarker.md` | MSR-Routendesign und Infrastrukturmarker |

## 3. Reservierungen für offene, nicht auf `main` integrierte Zweige

Diese Dateien sind nicht Bestandteil des aktuellen `main`-Baums. Ihre technische oder fachliche Aussage gilt nur entsprechend ihrem Branch-, PR- und Acceptance-Status.

### 3.1 PR #18 – Jalalabad Air Operations

| Nr. | Stabile ID | Zielpfad | Status |
|---:|---|---|---|
| 22 | `OMW-TEST-BUILD-TRANSFER` | `docs/22-test-mission-build-transfer-and-validation-workflow.md` | nur auf Draft-PR #18 |
| 23 | `OMW-AIR-JBAD-PARKING-MEDEVAC` | `docs/23-jalalabad-parking-template-and-medevac-model.md` | nur auf Draft-PR #18 |
| 24 | `OMW-AIR-JBAD-CH47-PARKING` | `docs/24-jalalabad-ch47-static-parking-reservations.md` | nur auf Draft-PR #18 |
| 25 | `OMW-AIR-JBAD-ACCEPTANCE` | `docs/25-jalalabad-final-validation-and-operational-baseline.md` | nur auf Draft-PR #18; `ACCEPTED_TECHNICAL_BASELINE` für exakt dokumentierten Teststand |

PR #18 enthält zusätzlich einen branchlokalen Pfad `docs/27-helicopter-formations-and-ah64-afghanistan-configuration.md`. Die Nummer 27 ist auf `main` bereits vergeben und muss vor einer späteren Integration neu reserviert werden.

### 3.2 PR #24 – Bagram/Kandahar Air Operations

| Nr. | Stabile ID | Zielpfad | Status |
|---:|---|---|---|
| 31 | `OMW-AIR-BAGRAM-MANIFEST` | `docs/31-bagram-air-operations-manifest.md` | reserviert für Draft-PR #24 |
| 32 | `OMW-AIR-PLAYER-SLOT-POLICY` | `docs/32-player-aircraft-slot-policy.md` | reserviert für Draft-PR #24 |
| 33 | `OMW-AIR-KANDAHAR-MANIFEST` | `docs/33-kandahar-air-operations-manifest.md` | reserviert für Draft-PR #24 |
| 34 | `OMW-AIR-BAGRAM-ME-BASELINE` | `docs/34-bagram-current-mission-editor-baseline.md` | reserviert für Draft-PR #24 |
| 35 | `OMW-AIR-KANDAHAR-ISR-POLICY` | `docs/35-kandahar-isr-asset-policy.md` | reserviert für Draft-PR #24 |
| 36 | `OMW-AIR-KANDAHAR-MUSTANG-RAMP` | `docs/36-kandahar-mustang-ramp-army-aviation-baseline.md` | reserviert für Draft-PR #24 |

### 3.3 Branch `agent/document-mq1-mq9-afghanistan`

| Nr. | Stabile ID | Zielpfad | Status |
|---:|---|---|---|
| 50 | `OMW-AIR-UAS-AFGHANISTAN` | `docs/50-mq1-mq9-afghanistan-employment.md` | branchlokale Reservierung; vor Merge als aktuelles `main`-Dokument in Abschnitt 2 überführen |

## 4. Nicht nummerierte stabile Dokumente

| Stabile ID | Pfad | Status / Funktion |
|---|---|---|
| `OMW-AIR-US-ORBAT-RESEARCH` | `docs/us-air-orbat-2010-2011.md` | historischer Recherche- und Planungsbestand |
| `OMW-GOV-SOURCE-USE` | `docs/sources/graveyard-of-empires.md` | zentrale Quellen-, Datei- und Veröffentlichungsregel |
| `OMW-GOV-MOOSE-VERSION` | `docs/moose/VERSION-AND-SOURCES.md` | MOOSE-Versions- und Nachweisregeln |
| `OMW-MOOSE-CLASS-INDEX` | `docs/moose/PROJECT-CLASS-INDEX.md` | projektbezogener MOOSE-Klassenindex |
| `OMW-MOOSE-VERIFIED-METHODS` | `docs/moose/VERIFIED-METHODS.md` | praktisch verifizierte Methoden |
| `OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE` | `docs/targeting/afghanistan-nsl-data-use-policy.md` | verbindliche NSL-Datenverwendung |
| `OMW-EVIDENCE-JBAD-AIR-OPS-BASELINE-AUDIT` | `docs/evidence/jalalabad-air-operations-baseline-audit.md` | unnummerierter historischer Ausgangs-Audit |
| `OMW-EVIDENCE-INDEX` | `docs/evidence/README.md` | Einordnung von Evidenz- und Legacy-Datensätzen |

Weitere thematische Unterverzeichnisse wie `docs/csar/`, `docs/moose/`, `docs/sources/` und `docs/targeting/` werden im geplanten vollständigen Themenindex `docs/README.md` erfasst. Das Fehlen dieses Themenindex ist als P1-Dokumentationsaufgabe offen.

## 5. Legacy-Evidenz und historische Titelnummern

Unveränderte Quelldatensätze unter `docs/evidence/source-records/` dürfen ihre damaligen Titelzeilen behalten. Eine darin enthaltene alte Nummer ist keine aktuelle Nummernvergabe und darf nicht als aktiver Querverweis verwendet werden.

Aktuell erhalten bleiben unter anderem:

- `legacy-18-msr-routendesign-und-infrastrukturmarker.md`;
- `legacy-18-air-operations-implementation-pre-governance.md`;
- `legacy-20-air-orbat-mission-editor-worklist-vertical-prototype.md`;
- `legacy-21-jalalabad-air-operations-baseline-audit.md`.

## 6. Branch- und Merge-Regel

1. Ein Branch darf neue Dokumente zunächst ohne endgültige Nummer entwickeln.
2. Spätestens vor Merge wird eine Nummer in diesem Register reserviert.
3. Kollidierende Branch-Dateinamen werden vor Merge umbenannt.
4. README-Links, Querverweise und ADRs werden im selben Änderungssatz angepasst.
5. Alte Nummern dürfen in Historie oder unveränderter Evidenz genannt werden, aber nicht als aktuelle Referenz bestehen bleiben.
6. Branchspezifische Dubletten zentraler Richtlinien werden entfernt oder auf das zentrale Dokument umgestellt.
7. Technische Prüfberichte, Baseline-Audits und unveränderte Entwicklungsprotokolle werden bevorzugt als unnummerierte Evidenzdokumente geführt.
8. Ein Branchdokument darf nicht als vorhandene `main`-Datei verlinkt werden; stattdessen wird PR, Branch und Commit angegeben.

## 7. Pflege

Jede Reservierung oder Statusänderung erfolgt gemeinsam mit der zugehörigen Dokumentänderung. Ein ungenutzter reservierter Platz kann durch ausdrückliche Projektentscheidung freigegeben werden; eine bereits veröffentlichte stabile ID wird nicht neu vergeben.

Die vollständige Statusmigration und der Themenindex werden als eigene P1/P2-Arbeitspakete durchgeführt. Dieses Register trennt bis dahin ausdrücklich zwischen realem `main`-Bestand, offenen Branchreservierungen und Legacy-Evidenz.