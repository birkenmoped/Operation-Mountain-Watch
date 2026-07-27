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

### P0-Bereinigung

- [`legacy-18-msr-routendesign-und-infrastrukturmarker.md`](source-records/legacy-18-msr-routendesign-und-infrastrukturmarker.md)
- [`legacy-18-air-operations-implementation-pre-governance.md`](source-records/legacy-18-air-operations-implementation-pre-governance.md)
- [`legacy-20-air-orbat-mission-editor-worklist-vertical-prototype.md`](source-records/legacy-20-air-orbat-mission-editor-worklist-vertical-prototype.md)
- [`legacy-21-jalalabad-air-operations-baseline-audit.md`](source-records/legacy-21-jalalabad-air-operations-baseline-audit.md)

### Governance-, Architektur- und Registermigration

- [`legacy-root-readme-pre-documentation-index.md`](source-records/legacy-root-readme-pre-documentation-index.md)
- [`legacy-21-jalalabad-air-operations-manifest-pre-governance.md`](source-records/legacy-21-jalalabad-air-operations-manifest-pre-governance.md)
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

### CSAR und MSR

- [`legacy-csar-readme-source-series.md`](source-records/legacy-csar-readme-source-series.md)
- [`legacy-49-msr-route-design-pre-metadata-migration.md`](source-records/legacy-49-msr-route-design-pre-metadata-migration.md)

## 5. Verwendungsregel

- Aktuelle normative Aussagen werden aus den kanonischen Dokumenten gelesen.
- Legacy-Dateien dürfen zur Rekonstruktion früherer Entscheidungen, Daten, Quelleninhalte und Diffs verwendet werden.
- Bei Widerspruch gewinnt die Hierarchie aus `OMW-GOV-001`.
- Ein Legacy-Text wird nicht allein durch Detailtiefe erneut verbindlich.
- Quellen- und Testdaten werden nicht gelöscht; ihre Autoritätsklasse wird lediglich getrennt.
