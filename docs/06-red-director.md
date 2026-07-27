---
document_id: OMW-RED-DIRECTOR
status: SUPERSEDED
document_class: HISTORICAL_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - historical early Red Director design
not_authoritative_for:
  - current RED production architecture
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION
  - OMW-GOV-001
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 06 – Red Director

## Status

`SUPERSEDED` als aktuelle Produktionsarchitektur.

Der frühere Red-Director-Entwurf bleibt als historischer Architekturstand erhalten:

- [`Legacy-Red-Director`](evidence/source-records/legacy-06-red-director.md)

Aktuell verbindlich ist:

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)

## Fortgeführte Grundideen

- RED besitzt begrenzte regionale Ressourcen und Informationsstände.
- Zielauswahl berücksichtigt strategische Bedeutung, Entfernung, Risiko, Versorgung, BLUE-Präsenz und eigene Verluste.
- Operationen besitzen Vorbereitung, Bewegung, Angriff, Rückzug und strategische Folgen.
- RED-Gruppen sollen sich bei hohen Verlusten zurückziehen oder zerstreuen, statt zwingend bis zur Vernichtung zu kämpfen.
- Regeneration entsteht über Netzwerke und Ressourcen, nicht über einen reinen Respawn-Timer.

## Ersetzte Annahmen

Die aktuelle Produktionsrichtung verwendet keine starre einzelne Zell-FSM als vollständige RED-Architektur. Maßgeblich sind:

- gewichtete Kommando-, Bewegungs- und Personalnetze;
- mehrere Quellen und alternative Wege;
- getrennte Standort- und Operationszustände;
- Guard Floor, Readiness Target und Hard Capacity;
- bounded command cycles;
- MOOSE-first für physische Ausführung und Überwachung.
