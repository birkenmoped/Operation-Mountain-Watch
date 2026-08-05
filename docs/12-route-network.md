---
document_id: OMW-ROUTE-NETWORK
status: SUPERSEDED
document_class: HISTORICAL_DESIGN
owning_policy: OMW-GOV-001
authoritative_for:
  - historical early route-network and prototype-route design
not_authoritative_for:
  - current MSR route model
  - current project sequence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-MSR-ROUTE-DESIGN
  - OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# 12 – Frühes Routennetz und Nachschubverbindungen

## Status

`SUPERSEDED` als aktuelle Routennetzarchitektur.

Der vollständige frühere Entwurf, einschließlich Jalalabad–Connolly-Prototyproute, bleibt erhalten:

- [`Legacy-Routennetz`](evidence/source-records/legacy-12-route-network.md)

Aktuell verbindliche beziehungsweise geplante Quellen:

- [`OMW-MSR-ROUTE-DESIGN`](49-msr-routendesign-und-infrastrukturmarker.md)
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-VIRTUALIZATION`](07-virtualization.md)

## Fortgeführte Grundideen

- Routen verbinden strategische Reserven, regionale Lager, FOBs und RED-Netzwerke.
- Eine Route besteht aus geprüften Segmenten, Ankern, Übergängen, Alternativen und taktischen Punkten.
- Physisch genutzte Strecken werden mit vorgesehenen Fahrzeugtypen in DCS getestet.
- Große Konvois können in mehrere kontrollierte Gruppen oder Pulse geteilt werden.
- Virtualisierte Bewegung bleibt an validierte Routen und strategische Bestände gebunden.
- RED-Verbindungen transportieren reale Personal-, Waffen-, Fahrzeug- und Intelligence-Ressourcen.

## Ersetzte Ablaufannahme

Jalalabad–Connolly ist keine verpflichtende erste und einzige Produktionsroute mehr. Routen dürfen im Foundation Build parallel erfasst werden; jede erhält eine eigene technische Acceptance.
