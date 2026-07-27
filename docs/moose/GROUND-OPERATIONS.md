---
document_id: OMW-MOOSE-GROUND-OPERATIONS
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned MOOSE ground-operations evaluation scope
  - required tests for ARMYGROUP, BRIGADE, OPSGROUP and movement control
not_authoritative_for:
  - accepted ground runtime architecture
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified MOOSE ground-operations reference
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# MOOSE-Bodenoperationen in Operation Mountain Watch

## 1. Status

```text
PLANNED – vollständige Bodenoperationsarchitektur noch nicht technisch akzeptiert
```

Der vollständige frühere Prüf- und Klassenentwurf bleibt erhalten:

- [`Legacy-MOOSE-Ground-Operations`](../evidence/source-records/legacy-moose-ground-operations.md)

## 2. Vorrangig zu prüfende Klassen

- `ARMYGROUP` für laufende Bodengruppen, Routing, FSM und Aufträge;
- `BRIGADE` für lokale Landbestände und Platoons;
- `PLATOON` für typ- und rollenbezogene Assetpools;
- `OPSGROUP` als operative Gruppenbasis;
- `AUFTRAG` für Bodenmissionen;
- `OPSTRANSPORT` für Carrier-/Cargo-Transport;
- `MOVEMENT` für begrenzte gleichzeitige Bewegungen;
- `PATHLINE`, `COORDINATE` und `Core.Astar` für Routing;
- MOOSE-Events, Sets und Scheduler.

## 3. Verbindliche Testfälle

- normale, transportierte und wieder entpackte Gruppen;
- Routenstart, Wegpunktfortschritt und Zielankunft;
- Stuck-Erkennung und Recovery ohne sichtbaren Teleport;
- Schutz während Aufklärung, Verfolgung und Kampf;
- Verlust, Dead-State und CampaignState-Rückmeldung;
- Cargo-/Carrier-Zustände bei `OPSTRANSPORT`;
- Persistenz und Missionsneustart;
- Multiplayer-Synchronisation.

## 4. Architekturgrenze

CampaignState entscheidet über Bestand, Auftrag, Route, Ressourcen und strategische Folgen. MOOSE führt die physische Gruppe und deren operative FSM aus.

Eigene Watchguard-, Routing-, Scheduler- oder Zustandslogik darf erst nach dokumentierter MOOSE-Lücke und ausdrücklicher Projektinhaberfreigabe produktiv werden.
