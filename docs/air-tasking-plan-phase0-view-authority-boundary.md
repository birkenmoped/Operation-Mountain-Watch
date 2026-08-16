---
document_id: OMW-AIR-TASKING-PLAN-PHASE0-VIEW-AUTHORITY
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 0 separation of Air Tasking source data from player-facing and operator-facing views
  - prohibition of resource, mission or command authority in derived briefing/view products
not_authoritative_for:
  - final player UI layout or wording
  - final Kneeboard/F10 implementation
  - final ATO-like presentation format
  - MOOSE or DCS runtime behavior
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 0 View / Briefing Authority Boundary

## 1. Zweck

Dieses Dokument schließt die Phase-0-Frage, welche Daten ausschließlich Darstellung, Briefing oder Lageübersicht sind und keine eigene Missions-, Ressourcen- oder Command-Autorität besitzen.

Grundsatz:

```text
Domain state / CampaignState / MissionDemand / Air Tasking records
    = authoritative source data

Player and operator products
    = derived read-only views
```

Ein View darf niemals zur zweiten Wahrheit für Bestand, Reservierung, MissionDemand, Tasking, Allocation oder Missionsergebnis werden.

## 2. Autoritative Quelldomänen

Je nach Information bleibt die Autorität bei der bereits zuständigen Domäne:

```text
CampaignState
= strategic state, inventory, availability, reservations, settlements

MissionDemand
= canonical campaign need / required effect identity and lifecycle

Command / Authority model
= command, tasking, request and allocation boundaries

AIR_SUPPORT_REQUEST
= documented support need across an authority boundary

AIR_TASKING_MISSION / AIR_TASKING_PLAN
= planned and assigned air mission relationships

MOOSE / DCS runtime
= transient execution evidence and physical mission state
```

Ein View darf diese Daten lesen und formatieren, aber nicht unabhängig davon verändern oder rekonstruieren.

## 3. Reine Views

Folgende Produkte sind grundsätzlich Views beziehungsweise Renderings:

```text
Mission Briefing
Player Mission Card
Kneeboard data/page
F10 mission information
ATO-like overview
Air-support status overview
Mission history / debrief presentation
operator/debug overview, soweit sie nur darstellt
```

Für diese Produkte gilt:

```text
view data
!= CampaignState resource authority
!= MissionDemand authority
!= Air Support Request authority
!= Air Tasking Mission authority
!= MOOSE mission authority
```

## 4. Keine persistente Parallelwahrheit

Ein generierter View soll grundsätzlich aus den strukturierten Quelldaten reproduzierbar sein.

Persistiert werden erforderlichenfalls die zugrunde liegenden Domain-Daten, nicht eine zweite fachliche Kopie derselben Wahrheit im gerenderten Produkt.

Beispiel:

```text
AIR_TASKING_MISSION ATM-000042
    ↓
render
    ├── F10 information
    ├── Mission Card
    ├── Kneeboard
    └── ATO-like overview
```

Nicht zulässig:

```text
Mission Card says aircraft_count = 2
→ therefore CampaignState inventory becomes 2
```

oder:

```text
F10 entry says mission ACTIVE
→ therefore MissionDemand/AIR_TASKING_MISSION is forced to ACTIVE
```

## 5. IDs und spielersichtbare Kennungen

Die Stable-ID-Konvention bleibt maßgeblich:

```text
internal stable ID
!= display mission number
!= callsign
!= player-facing label
```

Ein View darf interne IDs anzeigen, wenn dies für Diagnose oder Nachvollziehbarkeit sinnvoll ist. Spielerprodukte dürfen dagegen verständlichere Labels verwenden. Diese Labels ersetzen niemals die stabile interne Identität.

Beispiel:

```text
internal:
ATM-000042

player-facing:
CAS-017 / HAWG 2
```

Die konkrete spätere Nummerierungs- und Darstellungsregel bleibt Phase 4.

## 6. Aktualität und Ableitung

Views sollen aus dem jeweils aktuellen autoritativen Stand erzeugt oder aktualisiert werden.

Wenn ein View veraltet ist, gilt immer die Quelldomäne.

```text
stale briefing/view
    ↓
does not override
    ↓
current CampaignState / MissionDemand / Air Tasking state
```

Die technische Refresh-Strategie wird erst in der jeweiligen Runtime-/UI-Phase festgelegt.

## 7. Benutzerinteraktion über Views

Ein View kann später Interaktionen anbieten, zum Beispiel F10-Auswahl oder eine Mission-Annahme. Die Darstellung selbst bleibt trotzdem ohne Autorität.

Eine Benutzeraktion muss über einen expliziten Domain-/Command-Pfad verarbeitet werden:

```text
player action in view
    ↓
validated command/request operation
    ↓
authoritative domain update
    ↓
view is re-rendered
```

Nicht zulässig:

```text
editing/changing view state
= direct resource or mission authority
```

Damit kann Phase 4 interaktive Produkte entwickeln, ohne die Phase-0-Autoritätsgrenze zu verletzen.

## 8. Debrief und Mission History

Ein Debrief- oder History-View darf Ergebnisse darstellen, aber nicht selbst Ergebnisse erzeugen.

```text
MOOSE/DCS execution evidence
    ↓
authoritative result/settlement path
    ↓
CampaignState / MissionDemand / Air Tasking result records
    ↓
Debrief / history view
```

Die genaue History-Retention und Persistenz bleibt Phase 6.

## 9. Konsequenz für Phase 0

Damit gilt branch-lokal:

```text
1. Views are read-only projections of authoritative domain records.
2. Views never own strategic resources, reservations, command authority or MissionDemand state.
3. Player-facing labels are presentation data, not stable internal identity.
4. Interactive UI actions must call an authoritative domain operation; the view itself remains non-authoritative.
5. Stale or conflicting view data never overrides the authoritative source domain.
```

Kein Runtime-Code wurde geändert. Kein DCS-Test ist für diese Architekturgrenze erforderlich. `validated_in_dcs` bleibt `false`.
