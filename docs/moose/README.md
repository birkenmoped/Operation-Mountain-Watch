---
document_id: OMW-MOOSE-DOCUMENTATION-INDEX
status: BINDING
document_class: TECHNICAL_DOCUMENTATION_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - project-specific MOOSE documentation structure
  - distinction between official MOOSE sources and OMW evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified MOOSE documentation index
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE-Projektdokumentation

## 1. Zweck

Diese Dokumentation ist die projektspezifische MOOSE-Wissensbasis für **Operation Mountain Watch**. Sie ersetzt weder die offizielle MOOSE-Klassendokumentation noch den Quellcode des tatsächlich verwendeten Commits.

Der vollständige frühere Index bleibt unverändert erhalten:

- [`Legacy-MOOSE-Dokumentationsindex`](../evidence/source-records/legacy-moose-readme.md)

## 2. Verbindliche Arbeitsregel

- [`OMW-GOV-MOOSE-FIRST`](../26-moose-first-development-policy.md) definiert das vollständige Prüf- und Ausnahmeverfahren.
- [`OMW-GOV-MOOSE-VERSION`](VERSION-AND-SOURCES.md) definiert Versions- und Nachweispflichten.
- Eine technische Begründung allein genehmigt keine Nicht-MOOSE-Lösung.
- Produktionsabweichungen benötigen ausdrückliche Projektinhaberfreigabe und reproduzierbare Acceptance.

## 3. Dokumentationsstruktur

- [`VERSION-AND-SOURCES.md`](VERSION-AND-SOURCES.md) – MOOSE-Version, Quellen und Acceptance-Provenienz;
- [`PROJECT-CLASS-INDEX.md`](PROJECT-CLASS-INDEX.md) – Projektstatus relevanter Klassen;
- [`VERIFIED-METHODS.md`](VERIFIED-METHODS.md) – praktisch geprüfte Methoden und Nachweisgrenzen;
- [`AIR-OPERATIONS.md`](AIR-OPERATIONS.md) – AIRBASE, AIRWING, SQUADRON, COMMANDER und AUFTRAG;
- [`GROUND-OPERATIONS.md`](GROUND-OPERATIONS.md) – geplante Bodengruppen-, Brigade- und Movement-Architektur;
- [`LOGISTICS-AND-TRANSPORT.md`](LOGISTICS-AND-TRANSPORT.md) – Warehouse, OPSTRANSPORT, CTLD und Carrier/Cargo;
- [`EVENTS-AND-FSM.md`](EVENTS-AND-FSM.md) – Events, FSM, Scheduler und Callback-Regeln;
- [`ISR-FAC-CAS-AAR.md`](ISR-FAC-CAS-AAR.md) – geplante ISR-, FAC-/JTAC-, CAS- und AAR-Kette;
- [`FOG-OF-WAR-RECCE.md`](FOG-OF-WAR-RECCE.md) – MOOSE-Develop-Fähigkeiten und Grenzen von INTEL, INTEL_DLINK, PLAYERRECCE, TARS, RECON, DETECTION, DESIGNATE und CHIEF.

## 4. Statusregel

MOOSE-Klassen- und Methodenstatus sind keine Governance-Dokumentstatuswerte.

Beispiele:

```text
CANDIDATE
PLANNED
IN_USE_PARTIAL
VALIDATED_FOR_DOCUMENTED_SCOPE
INTERNAL_RESTRICTED
REJECTED_FOR_PROJECT_USE
```

Jeder `VALIDATED`-Eintrag benötigt einen konkreten Test- und Versionsnachweis. Er gilt nicht automatisch für andere Methoden, Klassen, Basen, MOOSE-Versionen oder Missionen.
