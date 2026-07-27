---
document_id: OMW-CSAR-AFGHANISTAN-2010-FACILITIES
status: BINDING
document_class: SOURCE_DERIVED_DATASET_REFERENCE
owning_policy: OMW-CSAR-INDEX
authoritative_for:
  - documented contents and integrity findings of the supplied CSAR CombatFlite mission.xml
  - source-derived 2010 facility, coverage and HLO-limit reference
not_authoritative_for:
  - current DCS placement
  - current medical capability
  - technical CSAR implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified CSAR facilities and coverage document
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: PENDING_MERGE
validated_in_dcs: false
source_status: SOURCE_CAPTURE_COMPLETE_WITH_METADATA_CONFLICT
---

# Afghanistan 2010 – CSAR-Einrichtungen, Abdeckung und Höhenlimits

## Gültigkeit

Dieses Dokument klassifiziert die Auswertung der bereitgestellten CombatFlite-Datei `mission.xml` sowie der Teile 7 und 8 der CSAR-Serie.

Der vollständige bisherige Datensatzbericht bleibt unverändert erhalten:

- [`legacy-csar-afghanistan-2010-facilities-and-coverage.md`](../evidence/source-records/legacy-csar-afghanistan-2010-facilities-and-coverage.md)

Übergeordnete Einordnung:

- [`OMW-CSAR-INDEX`](README.md);
- [`OMW-CSAR-SOURCE-NOTES-1-8`](source-notes-1-8.md).

## Integritätsnachweis

```text
Datei:   mission.xml
Größe:   2.049.457 Byte
SHA-256: 1c4e77588d3ae9dce684215e6641f74aabcc17cc2e59778a39a736033b2c824c
```

Die XML enthält Afghanistan-bezogene Inhalte, führt im Kopf jedoch `PersianGulf` und ein Missionsdatum 2025. Dieser Metadatenwiderspruch bleibt ausdrücklich dokumentiert und wird nicht stillschweigend korrigiert.

Die enthaltenen Einrichtungen, Radien und Höhenangaben sind Quellen- und Planungsreferenzen. Sie sind keine automatisch gültigen DCS-Positionen oder aktuelle medizinische Fähigkeitsnachweise.
