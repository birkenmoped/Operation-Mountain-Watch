---
document_id: OMW-ADR-0001-MOOSE-PRIMARY
status: SUPERSEDED
document_class: ADR
owning_policy: OMW-GOV-001
authoritative_for:
  - historical decision to use MOOSE as primary framework
scenario_period:
project_phase:
supersedes:
superseded_by:
  - OMW-GOV-MOOSE-FIRST
  - OMW-GOV-001
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# ADR-0001: MOOSE als primäres Framework

## Status

`SUPERSEDED` in der Regelungstiefe, Entscheidung inhaltlich fortgeführt.

Die ursprüngliche Entscheidung, MOOSE als primäres DCS-Scripting-Framework zu verwenden, bleibt gültig. Das damalige ADR beschreibt jedoch nicht das heute zwingende Ausnahme- und Eigentümerfreigabeverfahren.

Verbindlich sind deshalb:

- [`OMW-GOV-001`](../00-project-governance.md)
- [`OMW-GOV-MOOSE-FIRST`](../26-moose-first-development-policy.md)

## Historische Entscheidung

MOOSE wurde gewählt, um dynamische Spawns, Wrapper, Events, Scheduler, Zonen, Menüs, CTLD, CSAR und operative Logik in einem einheitlichen Framework abzubilden. MIST wird nicht standardmäßig parallel geladen.

## Aktuelle Ergänzung

Eigene Kampagnenmodule dürfen nicht allein deshalb auf der nativen DCS-API aufbauen, weil MOOSE ein projektspezifisches Domänenmodell nicht vollständig bereitstellt.

Jede produktive Ergänzung benötigt:

1. dokumentierte MOOSE-Prüfung;
2. nachgewiesene technische Lücke;
3. kleinstmöglichen Ergänzungsumfang;
4. ausdrückliche Projektinhaberfreigabe;
5. ADR- oder Acceptance-Dokumentation;
6. reproduzierbaren DCS-Test.
