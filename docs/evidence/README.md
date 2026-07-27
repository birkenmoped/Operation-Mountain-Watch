---
document_id: OMW-EVIDENCE-INDEX
status: BINDING
document_class: EVIDENCE_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - classification of evidence and legacy source records
  - separation of historical records from current authority
scenario_period:
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier evidence indexes with incomplete legacy inventory
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# Operation Mountain Watch – Evidenzdokumente

## 1. Zweck

Dieses Verzeichnis enthält technische Prüfberichte, Ausgangsanalysen, historische Entwicklungsstände und unveränderte Legacy-Quelldatensätze.

Evidenzdokumente dienen der Nachvollziehbarkeit. Sie sind nicht automatisch aktuelle Governance, aktive ORBAT, Produktionsarchitektur oder verbindliche Implementierungsvorgabe.

## 2. Nummerierungsregel

Unnummerierte Evidenzdokumente erhalten eine stabile `document_id`, aber keine reguläre Dokumentnummer. Historische Titelnummern in unveränderten Quelldatensätzen sind keine aktuelle Nummernvergabe.

Aktuelle Nummern und IDs stehen in:

- [`OMW-GOV-DOCUMENT-REGISTRY`](../DOCUMENT-REGISTRY.md)

## 3. Aktuelle Evidenzdokumente

- [`OMW-EVIDENCE-JBAD-AIR-OPS-BASELINE-AUDIT`](jalalabad-air-operations-baseline-audit.md) – Prüfung der ursprünglichen Jalalabad-Ausgangsmission; `HISTORICAL_TEST_FIXTURE`.

## 4. Legacy-Quelldatensätze

### Projektgrundlagen 01–17

- [`legacy-01-vision.md`](source-records/legacy-01-vision.md)
- [`legacy-02-gameplay-concept.md`](source-records/legacy-02-gameplay-concept.md)
- [`legacy-04-campaign-state.md`](source-records/legacy-04-campaign-state.md)
- [`legacy-05-logistics.md`](source-records/legacy-05-logistics.md)
- [`legacy-06-red-director.md`](source-records/legacy-06-red-director.md)
- [`legacy-07-virtualization.md`](source-records/legacy-07-virtualization.md)
- [`legacy-08-csar.md`](source-records/legacy-08-csar.md)
- [`legacy-10-theater-and-sectors.md`](source-records/legacy-10-theater-and-sectors.md)
- [`legacy-11-bases-and-fobs.md`](source-records/legacy-11-bases-and-fobs.md)
- [`legacy-12-route-network.md`](source-records/legacy-12-route-network.md)
- [`legacy-13-unit-catalog.md`](source-records/legacy-13-unit-catalog.md)
- [`legacy-15-template-library-and-spawning.md`](source-records/legacy-15-template-library-and-spawning.md)
- [`legacy-16-world-data-and-routing.md`](source-records/legacy-16-world-data-and-routing.md)
- [`legacy-17-pathfinding-options.md`](source-records/legacy-17-pathfinding-options.md)

Dokument 03 wurde bereits in PR #32 ohne vollständige Ablageverschiebung governance-konform überarbeitet. Dokument 09 und 14 besitzen bereits gültige Statusmetadaten.

### P0-Bereinigung und Luftoperationsgrundlagen

- [`legacy-18-msr-routendesign-und-infrastrukturmarker.md`](source-records/legacy-18-msr-routendesign-und-infrastrukturmarker.md)
- [`legacy-18-air-operations-implementation-pre-governance.md`](source-records/legacy-18-air-operations-implementation-pre-governance.md)
- [`legacy-20-air-orbat-mission-editor-worklist-vertical-prototype.md`](source-records/legacy-20-air-orbat-mission-editor-worklist-vertical-prototype.md)
- [`legacy-21-jalalabad-air-operations-baseline-audit.md`](source-records/legacy-21-jalalabad-air-operations-baseline-audit.md)
- [`legacy-21-jalalabad-air-operations-manifest-pre-governance.md`](source-records/legacy-21-jalalabad-air-operations-manifest-pre-governance.md)

### Governance-, Architektur- und Registermigration

- [`legacy-root-readme-pre-documentation-index.md`](source-records/legacy-root-readme-pre-documentation-index.md)
- [`legacy-37-campaign-architecture-pre-governance.md`](source-records/legacy-37-campaign-architecture-pre-governance.md)
- [`legacy-38-mission-editor-master-worklist-pre-governance.md`](source-records/legacy-38-mission-editor-master-worklist-pre-governance.md)
- [`legacy-39-tm01-tm02-moose-first-code-review.md`](source-records/legacy-39-tm01-tm02-moose-first-code-review.md)
- [`legacy-40-moose-module-adoption-plan.md`](source-records/legacy-40-moose-module-adoption-plan.md)

### C2-, AAR-, ROE- und Targeting-Quellen

- [`legacy-27-oef-jtac-callsign-reference.md`](source-records/legacy-27-oef-jtac-callsign-reference.md)
- [`legacy-28-afghanistan-tad-color-nets-source-capture.md`](source-records/legacy-28-afghanistan-tad-color-nets-source-capture.md)
- [`legacy-29-isaf-aar-aco-source-capture.md`](source-records/legacy-29-isaf-aar-aco-source-capture.md)
- [`legacy-30-isaf-aar-part2-figure-reference.md`](source-records/legacy-30-isaf-aar-part2-figure-reference.md)
- [`legacy-45-air-c2-cas-afghanistan-source-capture.md`](source-records/legacy-45-air-c2-cas-afghanistan-source-capture.md)
- [`legacy-46-non-lethal-use-of-force-source-capture.md`](source-records/legacy-46-non-lethal-use-of-force-source-capture.md)
- [`legacy-47-aircraft-tactical-callsigns-source-capture.md`](source-records/legacy-47-aircraft-tactical-callsigns-source-capture.md)
- [`legacy-48-afghanistan-no-strike-list-source-and-architecture.md`](source-records/legacy-48-afghanistan-no-strike-list-source-and-architecture.md)

### Wetter

- [`legacy-41-historical-weather-baseline-2010-2011.md`](source-records/legacy-41-historical-weather-baseline-2010-2011.md)
- [`legacy-42-dcs-weather-editor-validation.md`](source-records/legacy-42-dcs-weather-editor-validation.md)
- [`legacy-43-dcs-rain-shower-preset-validation.md`](source-records/legacy-43-dcs-rain-shower-preset-validation.md)
- [`legacy-44-dcs-valley-mist-low-cloud-test-profile.md`](source-records/legacy-44-dcs-valley-mist-low-cloud-test-profile.md)

### MOOSE

- [`legacy-moose-readme.md`](source-records/legacy-moose-readme.md)
- [`legacy-moose-project-class-index.md`](source-records/legacy-moose-project-class-index.md)
- [`legacy-moose-verified-methods.md`](source-records/legacy-moose-verified-methods.md)
- [`legacy-moose-air-operations.md`](source-records/legacy-moose-air-operations.md)
- [`legacy-moose-ground-operations.md`](source-records/legacy-moose-ground-operations.md)
- [`legacy-moose-logistics-and-transport.md`](source-records/legacy-moose-logistics-and-transport.md)
- [`legacy-moose-events-and-fsm.md`](source-records/legacy-moose-events-and-fsm.md)
- [`legacy-moose-isr-fac-cas-aar.md`](source-records/legacy-moose-isr-fac-cas-aar.md)

### CSAR und MSR

- [`legacy-csar-readme-source-series.md`](source-records/legacy-csar-readme-source-series.md)
- [`legacy-49-msr-route-design-pre-metadata-migration.md`](source-records/legacy-49-msr-route-design-pre-metadata-migration.md)

## 5. Verwendungsregel

- Aktuelle normative Aussagen werden aus den kanonischen Dokumenten gelesen.
- Legacy-Dateien dürfen zur Rekonstruktion früherer Entscheidungen, Daten, Quelleninhalte und Diffs verwendet werden.
- Bei Widerspruch gewinnt die Hierarchie aus `OMW-GOV-001`.
- Ein Legacy-Text wird nicht allein durch Detailtiefe erneut verbindlich.
- Quellen- und Testdaten werden nicht gelöscht; ihre Autoritätsklasse wird getrennt.
