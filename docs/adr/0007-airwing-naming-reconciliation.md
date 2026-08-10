---
document_id: OMW-ADR-0007-AIRWING-NAMING-RECONCILIATION
status: BINDING_PROJECT_DECISION
document_class: ARCHITECTURE_DECISION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - current Jalalabad AIRWING identifier
  - current Salerno AIRWING identifier
  - supersession of the generic Jalalabad and Salerno AIRWING names
not_authoritative_for:
  - historical DCS acceptance artifacts using the previous AIRWING identifiers
  - SQUADRON identities or aircraft inventories
  - Warehouse, parking, template or payload contracts beyond the naming change
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - AW_US_JALALABAD as the current Jalalabad foundation AIRWING identifier
  - AW_US_SALERNO as the current Salerno foundation AIRWING identifier
  - Jalalabad and Salerno technical-structure name entries in OMW-AIR-ACTIVE-ORBAT that use those generic identifiers
superseded_by: []
source_branch: agent/airwing-naming-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ADR 0007 – AIRWING-Naming für Jalalabad und Salerno vereinheitlichen

## Entscheidung

Nach Abschluss der Foundation-Neubauten für Salerno, Kandahar und Bagram werden die beiden noch generischen Army-Aviation-AIRWING-Identifier in Jalalabad und Salerno verbandsbezogen normalisiert.

Verbindliche Zielnamen:

```text
Jalalabad / FOB Fenty:
AW_US_JBAD_TF_SHOOTER_6_6_CAV

FOB Salerno:
AW_US_SAL_TF_TIGERSHARK_1_10_AVN
```

Damit werden die bisherigen technischen Namen

```text
AW_US_JALALABAD
AW_US_SALERNO
```

für die aktuelle Foundation superseded.

## Abgrenzung

Die Änderung betrifft ausschließlich den AIRWING-Identifier. Unverändert bleiben insbesondere:

- SQUADRON-IDs;
- logische Aircraft-Inventare;
- Warehouse-Anker;
- AIRBASE-Bindungen;
- Late-Activation-Templates;
- Payload- und Mission-Capabilities;
- Parking-Verträge;
- CampaignState- und Ressourcenhoheit.

Es wird keine neue MOOSE-Funktion eingeführt und keine vorhandene MOOSE-Funktion ersetzt. Die bestehenden `AIRWING:New(warehouseName, airwingName)`-Aufrufe verwenden lediglich den neuen Namen.

## Historische Namensgrenze

Für Jalalabad bleibt die historische Einordnung `6th Squadron, 6th Cavalry Regiment / Task Force Six Shooters` maßgeblich. Der technische Token `TF_SHOOTER` im Identifier ist eine projektinterne Kurzform und keine Behauptung, dass jede historische Quelle exakt die Bezeichnung `TF Shooter` verwendet.

Für Salerno bildet `TF_TIGERSHARK_1_10_AVN` die in der Projektbaseline dokumentierte Zuordnung `TF Tigershark / 1-10 Attack Aviation` ab.

## Acceptance-Grenze

Historische Jalalabad- und Salerno-Acceptance-Dateien werden nicht rückwirkend umgeschrieben. Ein DCS-PASS mit `AW_US_JALALABAD` oder `AW_US_SALERNO` bleibt Nachweis genau dieses alten Artefaktstands.

Die neuen Identifier gelten erst nach einem neuen exakt dokumentierten Foundation-Lauf als DCS-validiert. Bis dahin gilt:

```yaml
naming_decision: BINDING_PROJECT_DECISION
foundation_runtime_with_new_names: NOT_YET_VALIDATED
historical_acceptance_rewritten: false
```
