---
document_id: OMW-ADR-0002-MOOSE-CTLD-CSAR
status: SUPERSEDED
document_class: ADR
owning_policy: OMW-GOV-001
authoritative_for:
  - historical prototype choice of MOOSE CTLD and MOOSE CSAR
scenario_period:
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-GOV-MOOSE-FIRST
  - OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION
  - OMW-CSAR-INDEX
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# ADR-0002: MOOSE CTLD und MOOSE CSAR

## Status

`SUPERSEDED` als prototypbezogene Entscheidung.

Die Präferenz für MOOSE CTLD und MOOSE CSAR bleibt bestehen, ist aber keine pauschale technische Acceptance und keine Freigabe für ungeprüfte Adapter.

Verbindlich sind:

- [`OMW-GOV-MOOSE-FIRST`](../26-moose-first-development-policy.md)
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](../37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-CSAR-INDEX`](../csar/README.md)

## Fortgeführte Entscheidung

- MOOSE CTLD und MOOSE CSAR werden vorrangig geprüft und eingesetzt.
- Ciribob CTLD/CSAR und MIST werden nicht parallel geladen, solange kein dokumentiertes, reproduzierbares Funktionsdefizit und keine ausdrückliche Projektinhaberfreigabe vorliegen.
- Fehlende projektspezifische Kampagnenlogik wird nur über genehmigte, kleine Adapter ergänzt.

## Noch erforderliche Acceptance

- C-130J Dynamic Cargo und Luftabwurf;
- stabile Paket-Endposition;
- CTLD-Aufnahme, Absetzen und Bau aus mehreren Lieferungen;
- MOOSE-CSAR-Ereignisse, Funkbaken und Übergabe an Rettungseinrichtungen;
- Integration mit Capture-, CampaignState- und Persistenzlogik;
- Multiplayer- und Langzeittest.
