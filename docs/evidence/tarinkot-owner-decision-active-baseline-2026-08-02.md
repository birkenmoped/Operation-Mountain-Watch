---
document_id: OMW-DECISION-TARINKOT-ACTIVE-BASELINE-2026-08-02
status: BINDING_PROJECT_DECISION
document_class: PROJECT_OWNER_DECISION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - selected Tarinkot historical working baseline
  - relationship between the MIZ calendar date and the active Tarinkot ORBAT snapshot
  - active Tarinkot AIRWING and SQUADRON naming basis before runtime implementation
not_authoritative_for:
  - exact aircraft quantities beyond the accepted Tarinkot object contract
  - DCS or MOOSE runtime acceptance
scenario_period: 2010-08-01/2011-12-31
decision_date: 2026-08-02
source_branch: agent/tarinkot-object-contract-reconciliation
validated_in_dcs: false
decision_state: RECORDED
project_phase: TARINKOT_OBJECT_CONTRACT_RECONCILIATION
source_commit: PENDING_MERGE
supersedes: []
superseded_by: []
---

# Tarinkot – Eigentümerentscheidung zur aktiven Arbeitsbaseline

## Entscheidung

Für den aktuellen Tarinkot-Aufbau bleibt verbindlich:

```text
Zeitraum:
März bis Dezember 2011

AH-64:
Task Force Attack / 3-101 Attack Aviation

UH-60:
Task-Force-Attack-Komponente
administrative Company weiterhin offen

CH-47:
B Company, 1-52 Aviation Regiment
historisches Muster CH-47D
```

Daraus folgt der aktive technische Objektvertrag:

```text
AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

## MIZ-Datum

Das in der aktuellen MIZ eingetragene Datum:

```text
14.01.2011
```

ist für die aktuelle Tarinkot-ORBAT und Benennung nicht steuernd. Es wird als technische Missionskulisse behandelt.

Nicht für den aktuellen Tarinkot-Vertrag zu verwenden sind daher:

```text
Task Force No Mercy / 1-101 als aktiver AIRWING-Parent
C Company, 5-101 Aviation Regiment als aktive UH-60-SQUADRON
301 Squadron RNLAF als aktive AH-64-SQUADRON
```

Diese Verbände bleiben als historische Vorgänger und mögliche spätere datumsabhängige Presets dokumentiert.

## Implementierungsgrenze

Diese Entscheidung löst ausschließlich den historischen Zeit- und Benennungsvertrag.

Sie autorisiert noch keine Lua-Implementierung. Vor Tarinkot-Lua bleiben erforderlich:

1. Abschluss und Annahme des vollständigen Tarinkot-Objektvertrags;
2. G4-Prüfung der exakt eingebundenen MOOSE-Version 2.9.18, ihrer Quellen, Dokumentation und Demos;
3. danach ausschließlich ein isoliertes read-only G5-Diagnosebundle.
