---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-AUTHORITY-ALLOCATION-VERIFICATION
status: DRAFT
document_class: MOOSE_CAPABILITY_VERIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase-2 boundary between OMW strategic authority and MOOSE runtime allocation
  - branch-local decision on native MOOSE asset recruitment versus OMW adapter responsibility
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Phase 2 – Authority / Allocation Verification

## 1. Zweck

Diese Prüfung entscheidet für den Foundation-Scope, welche Authority-/Allocation-Aufgaben OMW selbst behalten muss und welche durch die bereits source-geprüften nativen MOOSE-Mechanismen getragen werden.

Verbindliche Projektgrenze:

```text
CampaignState
= strategischer Zustand und Ressourcenautorität

MissionDemand / Air Tasking Domain
= Kampagnenbedarf, Authority, Request/Mission-Identität und persistente Planung

MOOSE
= operative Capability-, Asset- und Missionsausführung innerhalb der freigegebenen strategischen Grenzen
```

## 2. Source- und Example-Baseline

Die Bewertung basiert auf:

```text
embedded MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

embedded Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Bereits Phase-2-source-geprüft:

```text
COMMANDER:CanMission(...)
COMMANDER:RecruitAssetsForMission(...)
COMMANDER:MissionAssign(...)
COMMANDER:MissionCancel(...)
COMMANDER:AddMission(...)

LEGION / AIRWING / BRIGADE mission queues
COHORT:AddMissionCapability(...)
AUFTRAG:SetRequiredAssets(...)
OPSGROUP mission assignment / lifecycle
```

Offizielle MOOSE-Demos bestätigen zusätzlich die native Auswahl geeigneter Squadron-/Payload-Ressourcen in AIRWING sowie die Rekrutierung über mehrere Airwings durch COMMANDER.

## 3. OMW Authority bleibt vor MOOSE

MOOSE darf eine Mission erst operativ ausführen, nachdem OMW die strategisch erforderlichen Entscheidungen getroffen hat.

OMW bleibt zuständig für:

```text
MissionDemand identity
requesting / supported command identity
command authority
tasking authority
request authority
AIR_SUPPORT_REQUEST identity and lifecycle
AIR_TASKING_MISSION identity and persistent lifecycle
strategic aircraft / resource availability
strategic reservation
strategic settlement and exact-once resource return/loss handling
policy constraints not represented as MOOSE runtime capability
player_or_ai_assignment policy
persistent support relationships
persistent mission/result history
```

Insbesondere gilt:

```text
COMMANDER:CanMission(...)
!= CampaignState availability
```

`CanMission` beziehungsweise vorhandene MOOSE-Cohorts beantworten eine operative Framework-Frage. Sie beweisen nicht, dass CampaignState das betreffende strategische Asset freigegeben oder reserviert hat.

## 4. Native MOOSE Allocation nutzen

Nach erfolgreicher OMW-Authority-/Reservation-Prüfung soll MOOSE seine native operative Auswahl übernehmen.

MOOSE bleibt zuständig für:

```text
COHORT mission capability
COHORT performance
AIRWING payload compatibility / runtime payload availability
LEGION runtime asset availability
COMMANDER recruitment from eligible LEGIONs
AUFTRAG required asset count
runtime OPSGROUP assignment
runtime mission queue
FLIGHTGROUP / ARMYGROUP physical execution
MOOSE mission lifecycle and callbacks
```

Damit soll der Adapter **nicht** selbst vorab aus allen DCS-/MOOSE-Gruppen den vermeintlich besten Flight auswählen.

## 5. Strategic constraint versus runtime candidate selection

Die erforderliche Trennung lautet:

```text
OMW determines the allowed strategic envelope
        ↓
MOOSE selects and executes within that envelope
```

Beispielhaft:

```text
OMW:
- MissionDemand benötigt CAS
- Authority-Grenze erlaubt Tasking
- CampaignState reserviert 2 geeignete Aircraft aus einem zulässigen strategischen Pool
- Air Tasking legt zulässige Squadron-/Node-/Zeit-/Support-Constraints fest

MOOSE:
- Cohort capability passt zu CAS
- verfügbare operative Assets / Payloads werden bewertet
- COMMANDER / AIRWING weist konkrete Runtime-Assets zu
- FLIGHTGROUP führt AUFTRAG aus
```

Wie eine konkrete strategische Reservation auf einen oder mehrere MOOSE-Cohorts begrenzt wird, ist Adapterkonfiguration/Korrelation und keine neue Ressourcenhoheit.

## 6. Keine Rückautorität aus MOOSE

Nicht zulässig ist:

```text
MOOSE warehouse/asset count becomes strategic CampaignState truth
COHORT Ngroups becomes independent strategic inventory
AIRWING payload stock creates campaign resources
COMMANDER availability silently overrides CampaignState reservation
DCS group survival alone determines persistent inventory without settlement contract
```

Besonders AIRWING-/STORAGE-Seiteneffekte bleiben eine bekannte Integrationsgrenze. Sie dürfen niemals als strategische Ressourcenerzeugung interpretiert werden.

## 7. Assigned Squadron / Unit constraints

Phase 1 enthält `assigned_squadron_id` als Planungsfeld. Dieses Feld bedeutet nicht automatisch, dass OMW ein konkretes physisches DCS-Flight vorselektiert.

Vorgesehene Semantik:

```text
assigned_squadron_id
= OMW strategic / organizational constraint or assignment

SQUADRON / PLATOON capability and MOOSE asset selection
= operative Auswahl der physischen Gruppe innerhalb dieser zulässigen Cohort-Grenze
```

Wenn eine Mission nicht auf eine einzelne Squadron festgelegt ist, kann COMMANDER gemäß nativer Capability-/Availability-Logik aus mehreren geeigneten LEGION/Cohort-Quellen rekrutieren, sofern CampaignState/Authority dies zuvor zulässt.

## 8. Player assignment

`player_or_ai_assignment` bleibt OMW-Planungs-/Policy-Wahrheit.

Ein Spieler-Slot darf nicht als frei rekrutierbares MOOSE-AI-Asset behandelt werden, nur weil Muster oder Basis passen. Ebenso darf eine AI-Ausführung nicht eine für Spieler reservierte strategische Ressource verbrauchen, ohne den CampaignState-Vertrag einzuhalten.

Die konkrete Player-Integration ist nicht Teil dieser source-only Phase-2-Prüfung; die Authority-Grenze ist jedoch eindeutig.

## 9. Support assets

Support-Beziehungen wie AAR, ESCORT, ISR oder spätere CSAR-Abhängigkeiten bleiben als OMW-Domain-Relationen persistent nachvollziehbar.

Die physische Support-Mission wird soweit möglich als eigener nativer MOOSE-`AUFTRAG` beziehungsweise über die zuständige MOOSE-Klasse ausgeführt.

Damit gilt:

```text
OMW support relationship graph
!= parallel physical mission dispatcher
```

## 10. Allocation failure

Wenn MOOSE nach erfolgter strategischer Planung keine geeigneten Runtime-Assets rekrutieren kann, ist das kein Grund, CampaignState-Verfügbarkeit zu erfinden oder MOOSE intern zu umgehen.

Der spätere Adapter muss den Fall als operative Allocation-/Execution-Failure zurückmelden, damit die bereits definierte OMW-Failure-/Cancellation-/Settlement-Semantik entscheidet, ob:

```text
reservation released
mission retried
mission replanned
request returned to planning
or request failed
```

## 11. Ergebnis

Der Manifestpunkt

```text
Authority / Allocation cases against native MOOSE capability
```

ist für den Foundation-Scope abgeschlossen.

Ergebnis:

```text
PASS_FOR_ARCHITECTURE_AND_SOURCE_REVIEW
validated_in_dcs: false
```

Die native MOOSE-Capability-/Recruitment-/Assignment-Kette ist ausreichend, um die operative Asset-Allokation zu tragen. OMW benötigt nur eine kleine Adapter-/Korrelationsschicht, welche die bereits getroffene strategische Authority-/Reservation-Entscheidung an MOOSE begrenzt übergibt und Lifecycle-Ergebnisse zurückkorreliert.

Eine parallele OMW-Command-/Asset-Dispatcher-Engine ist weder erforderlich noch zulässig.
