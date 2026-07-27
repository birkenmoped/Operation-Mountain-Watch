---
document_id: OMW-CSAR-MISSION-DESIGN-REQUIREMENTS
status: PLANNED
document_class: SOURCE_DERIVED_REQUIREMENTS
owning_policy: OMW-CSAR-INDEX
authoritative_for:
  - source-derived CSAR mission-design requirements awaiting architecture and DCS validation
not_authoritative_for:
  - approved MOOSE implementation
  - technical acceptance
  - final CampaignState schema
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified CSAR mission-design requirements
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: PENDING_MERGE
validated_in_dcs: false
source_status: SOURCE_DERIVATION_COMPLETE
---

# Combat Search and Rescue – Anforderungen an die Missionsgestaltung

## Gültigkeit

Dieses Dokument führt die aus der achtteiligen CSAR-Serie und der CombatFlite-Auswertung abgeleiteten Anforderungen als `PLANNED`.

Die vollständige bisherige Anforderungsliste bleibt unverändert erhalten:

- [`legacy-csar-mission-design-requirements.md`](../evidence/source-records/legacy-csar-mission-design-requirements.md)

Maßgebliche übergeordnete Dokumente:

- [`OMW-CSAR-INDEX`](README.md);
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](../37-campaign-architecture-and-dynamic-mission-design.md);
- [`OMW-GOV-MOOSE-FIRST`](../26-moose-first-development-policy.md);
- [`MOOSE ISR/FAC/CAS/AAR`](../moose/ISR-FAC-CAS-AAR.md).

## Statusgrenze

Die Anforderungen unterscheiden unter anderem SAR, CSAR, CR und NAR, Isolated-Personnel-Zustände, Authentifizierung, Evasion, Bedrohung, Recovery-Kräfte, HLO-Leistungsgrenzen, medizinische Übergaben und Basing.

Sie sind noch keine freigegebene Lua-, MOOSE-, CampaignState- oder Missionseditor-Implementierung. Jede technische Umsetzung benötigt MOOSE-First-Prüfung, konkrete Datenmodellentscheidung und reproduzierbare DCS-Tests.
