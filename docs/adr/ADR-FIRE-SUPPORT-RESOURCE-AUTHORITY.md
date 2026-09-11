---
document_id: OMW-ADR-FIRE-SUPPORT-RESOURCE-AUTHORITY
status: BINDING_PROJECT_DECISION
document_class: ADR
owning_policy: OMW-GOV-001
authoritative_for:
  - operational asset selection authority for fire support and strategic resupply
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - CampaignState preselection of concrete operational assets for this scope
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fire Support / Strategic Resupply – Ressourcenautorität

## Entscheidung

Für Fire Support und Strategic Resupply gilt MOOSE-first:

- MOOSE besitzt die operative Auswahl, Rekrutierung, Queue und physische Ausführung geeigneter Assets innerhalb der konfigurierten Organisationen und Warehouses.
- CampaignState selektiert keine konkreten operativen Assets vor MOOSE.
- CampaignState bleibt autoritativ für strategische Persistenz, Eigentum, Rechte, Verlegung, Verlust, Wartung und Ressourcen, die nicht bereits autoritativ durch MOOSE/DCS repräsentiert werden.
- Bestätigte MOOSE-/DCS-Lifecycle-Ereignisse werden idempotent in CampaignState übernommen.
- Kein Bestand darf zwei unabhängige Autoritäten besitzen.

Damit wird für diesen Scope die ältere Formulierung präzisiert, nach der CampaignState vor dem Dispatch den konkreten Herkunftspool und die konkrete strategische Ressource auswählt.
