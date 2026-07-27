---
document_id: OMW-MOOSE-CLASS-INDEX
status: BINDING
document_class: MOOSE_CLASS_REGISTER
owning_policy: OMW-GOV-001
authoritative_for:
  - project MOOSE class statuses
  - planned MOOSE integration candidates
  - scope boundaries of class-level evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - class index without complete governance metadata
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: partial
---

# MOOSE-Projektklassenindex

## 1. Zweck

Dieser Index führt den Projektstatus der für **Operation Mountain Watch** relevanten MOOSE-Klassen und Module.

Der vollständige frühere Klassenindex mit allen Einträgen bleibt unverändert erhalten:

- [`Legacy-MOOSE-Klassenindex`](../evidence/source-records/legacy-moose-project-class-index.md)

## 2. Statusbedeutung

```text
CANDIDATE                    fachlich relevant, noch nicht geprüft
PLANNED                      zur Prüfung oder Einführung vorgesehen
IN_USE_PARTIAL               einzelne Funktionen werden verwendet
VALIDATED_FOR_DOCUMENTED_SCOPE
                             nur der konkret dokumentierte Testumfang ist belegt
INTERNAL_RESTRICTED          ausschließlich Diagnose-/Adapterzugriff
REJECTED_FOR_PROJECT_USE     bewusst nicht vorgesehen
```

Diese Klassenstatus sind keine Governance-Dokumentstatuswerte.

## 3. Aktuell besonders relevante Klassen

| Klasse | Projektstatus | Geltungsgrenze |
|---|---|---|
| `AIRBASE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Jalalabad-Suche, ID und Parking-Blacklist auf PR #18 |
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion und Grundstart des Jalalabad-Knotens |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | vier Jalalabad-Bestände und Payloadregistrierung |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AIRWING-Anbindung und Grundstart |
| `AUFTRAG` | `IN_USE_PARTIAL` | Capability-/Payloadzuordnung; taktische Ausführung offen |
| `WAREHOUSE` | `IN_USE_PARTIAL` | Warehouse-Funktion über AIRWING; strategische Logistik offen |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | geordnete Konstruktion und Diagnose |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-, Static-, Warehouse- und Zonenvalidierung |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` | Bodenoperations- und Bestandsmodell |
| `OPSTRANSPORT` | `PLANNED` | taktischer Transport |
| `CTLD`, `CSAR`, `AICSAR` | `PLANNED` / teilweise verwendet | separate Acceptance erforderlich |
| `Core.Astar`, `PATHLINE`, `MOVEMENT` | `PLANNED` | Routing und Bewegungsbegrenzung |
| `_DATABASE` | `INTERNAL_RESTRICTED` | nur Diagnose und Templateprüfung |

## 4. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn:

- die verwendete MOOSE-Version identifiziert ist;
- API und Signatur geprüft sind;
- Mission, OMW-Commit und relevante Hashes dokumentiert sind;
- beobachtetes Verhalten und Einschränkungen festgehalten sind;
- der Nachweis im Methodenregister oder Acceptance-Bericht verlinkt ist.
