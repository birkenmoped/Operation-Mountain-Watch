---
document_id: OMW-GOV-DOCUMENT-METADATA
status: BINDING
document_class: GOVERNANCE_POLICY
owning_policy: OMW-GOV-001
authoritative_for:
  - interpretation of documentation frontmatter
  - required metadata fields
  - source and acceptance provenance rules
scenario_period:
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - implicit and inconsistent metadata interpretation
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# Dokumentmetadaten und Provenienz

## 1. Geltungsbereich

Diese Richtlinie konkretisiert die Metadatenanforderungen aus [`OMW-GOV-001`](00-project-governance.md). Sie gilt für aktuelle Governance-, Architektur-, Fach-, Baseline-, Register-, ADR-, Daten- und Testindexdokumente.

Unveränderte Quelldatensätze unter `docs/evidence/source-records/` sind von der Frontmatterpflicht ausgenommen. Vorhandenes Frontmatter in solchen Quelldatensätzen dient nur der Provenienz und verleiht keine aktuelle Governance-Autorität. Bei nicht als Legacy gekennzeichneten Quelldatensätzen werden relative Links, Repository-Grenzen und vorhandene stabile IDs dennoch geprüft.

Dateien mit Präfix `docs/evidence/source-records/legacy-` sind unveränderliche Archivkopien früherer Projektstände. Zusätzlich gelten die beiden vor Einführung der Handoff-Metadaten entstandenen Dateien

- `docs/handoffs/2026-07-31-bagram-current-state-and-kandahar-chat-handoff.md` und
- `docs/handoffs/2026-07-31-bagram-handoff-addendum.md`

als historische Sonderfälle ohne nachträglich erfundene Frontmatter-Provenienz. Legacy-Quelldatensätze und diese Handoffs werden in ihrem ursprünglichen Zustand bewahrt; ihre durch die Archivverschiebung veralteten Links sind keine aktuellen Repository-Verweise. Neue Handoffs und alle aktuellen Missions-Testdokumente unter `mission/tests/` unterliegen dagegen der Frontmatterpflicht.

## 2. Pflichtfelder

Maßgebliche Dokumente führen mindestens:

```yaml
document_id:
status:
document_class:
owning_policy:
authoritative_for:
scenario_period:
project_phase:
supersedes:
superseded_by:
source_branch:
source_commit:
validated_in_dcs:
```

Nicht anwendbare Werte dürfen leer sein. Der Schlüssel selbst bleibt vorhanden.

## 3. `source_commit`

Zulässige Werte sind:

- vollständiger 40-stelliger Git-Commit-SHA, wenn der Ursprung eindeutig bekannt ist;
- `PENDING_MERGE` für Inhalte eines offenen Pull Requests, dessen endgültiger Merge-Commit noch nicht existiert;
- `GIT_HISTORY` für vor Einführung dieser Richtlinie entstandene Dokumente, deren vollständige Provenienz ausschließlich aus der Dateihistorie hervorgeht;
- leer nur für bereits vorhandene Migrationsbestände, solange der zugehörige PR Draft ist.

Ein leerer Wert ist **nicht** als technische Acceptance-Provenienz zulässig.

`PENDING_MERGE` ist auf einem offenen Arbeitsbranch zulässig, aber nicht auf `main`. Nach der Integration wird der Wert durch den vollständigen Commit ersetzt, der den dokumentierten Quellstand im Repository nachweisbar enthält.

## 4. Technische Acceptance

`ACCEPTED_TECHNICAL_BASELINE` verlangt zusätzlich mindestens:

```yaml
acceptance_branch:
acceptance_commit:
acceptance_mission:
acceptance_mission_sha256:
dcs_version:
moose_commit:
moose_artifact_sha256:
validated_in_dcs: true
```

`moose_commit` oder `moose_artifact_sha256` darf nur dann leer bleiben, wenn die Nichtanwendbarkeit ausdrücklich begründet ist. Visuelle Einzelbeobachtungen, Editorversuche oder Arbeitsprofile ohne vollständige Mission- und Hashprovenienz erhalten nicht den Status `ACCEPTED_TECHNICAL_BASELINE`.

## 5. Dokumentklassen und Quellenstatus

`document_class` beschreibt die Funktion, beispielsweise `ARCHITECTURE`, `SOURCE_REFERENCE`, `DATASET_DOCUMENTATION`, `TEST_PROJECT_INDEX` oder `ADR`.

Quellen- und Bearbeitungsstände werden getrennt geführt, beispielsweise:

```yaml
source_status: SOURCE_CAPTURE_COMPLETE
validation_status: VISUALLY_CONFIRMED
```

Diese Werte ersetzen nicht den Governance-Status.

## 6. Automatische Prüfung

[`tools/validate_documentation.py`](../tools/validate_documentation.py) prüft mindestens:

- doppelte Dokument-IDs und Dokumentnummern;
- zulässige Governance-Statuswerte;
- Frontmatter und Pflichtschlüssel;
- zulässige Projektphasen und DCS-Validierungswerte;
- relative Links und Überschriftenanker;
- Acceptance-Provenienz;
- registrierte Dokument-IDs gegen die zugehörigen Repository-Pfade;
- aktuelle Handoffs und alle Markdown-Testdokumente unter `mission/tests/`;
- Archiv- und Quelldatensatzpfade ohne ihnen aktuelle Autorität zuzuschreiben.

Fehler blockieren den CI-Lauf. Auf Pull-Request-Branches darf `PENDING_MERGE` bis zur Integration bestehen; der `main`-Lauf verbietet diesen Wert ausdrücklich.
