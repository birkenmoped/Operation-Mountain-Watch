---
document_id: OMW-CSAR-LEGACY
status: SUPERSEDED
document_class: HISTORICAL_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - historical early CSAR campaign concept
not_authoritative_for:
  - current CSAR source classification
  - technical MOOSE CSAR acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-CSAR-INDEX
  - OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# 08 – Frühes CSAR-Konzept

## Status

`SUPERSEDED` als aktuelle CSAR-Architektur.

Der vollständige frühere Konzepttext bleibt unverändert erhalten:

- [`Legacy-CSAR-Konzept`](evidence/source-records/legacy-08-csar.md)

Aktuelle Einordnung:

- [`OMW-CSAR-INDEX`](csar/README.md)
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md)

## Fortgeführte Grundideen

- ein Abschuss oder Ausstieg kann einen persistenten Personnel-Recovery-Vorfall erzeugen;
- BLUE-Rettung und RED-Capture dürfen auf denselben Vorfall reagieren;
- Informationsstände und Koordinatengenauigkeit unterscheiden sich zwischen den Seiten;
- Recovery gilt erst nach Übergabe an eine geeignete Einrichtung als abgeschlossen;
- Rettung, Gefangennahme, Tod, Vermisststatus und Ablauf besitzen Kampagnenfolgen;
- Evasion nutzt kurze, validierte Bewegungen statt freier kilometerlanger Boden-KI-Navigation.

## Ersetzte technische Annahme

MOOSE CSAR „erzeugt und verwaltet“ nicht automatisch die vollständige OMW-Kampagnenwahrheit. Maßgeblich ist genau ein CampaignState-`CSARIncident`. MOOSE CSAR und `AICSAR` bilden operative Teile ab und werden durch genehmigte Adapter angebunden.

Eine technische Produktionsarchitektur und Acceptance sind separat zu erstellen.
