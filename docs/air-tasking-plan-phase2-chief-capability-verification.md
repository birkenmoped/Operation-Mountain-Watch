---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-CHIEF-VERIFICATION
status: DRAFT
document_class: VERIFICATION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 2 source verification of MOOSE CHIEF for the Air Tasking foundation
  - branch-local decision boundary between CHIEF and OMW CampaignState/Air Tasking authority
  - evidence for retaining CHIEF as not used in the Air Tasking production path
not_authoritative_for:
  - MOOSE classes other than CHIEF
  - final COMMANDER adapter design
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 2 CHIEF Capability Verification

## 1. Zweck

Dieses Dokument prüft `CHIEF` gegen den für Phase 2 gepinnten MOOSE-Stand und bewertet ausschließlich seine Eignung für die OMW-Air-Tasking-Architektur.

Verifikationsbaseline:

```text
MOOSE context: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die Bewertung folgt `OMW-GOV-001`, `OMW-GOV-MOOSE-FIRST`, `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`, dem Phase-0-Command-Modell und den abgeschlossenen Phase-1-Domainverträgen.

## 2. Quellnachweis am gepinnten Commit

Die gepinnte Quelle `Moose Development/Moose/Ops/Chief.lua` beschreibt `CHIEF` als `INTEL`-basierte strategische Klasse mit insbesondere:

```text
automatic target engagement based on detection network
border / conflict / attack zones
automatic DEFCON
strategic strategy states
manual AUFTRAG / TARGET engagement
AIRWING / BRIGADE / FLEET resources
automatic cross-domain dispatching
```

Der Quellkommentar beschreibt außerdem, dass der Chief bei erkannten Zielen oder eingehenden Missionen geeignete Assets auswählt und der Mission zuweist.

Damit ist `CHIEF` nicht nur ein dünner Container über vorhandene OMW-Aufträge. Die Klasse trägt eigene strategische Erkennungs-, Priorisierungs-, Ziel- und Dispatch-Semantik.

## 3. Konstruktor und interne COMMANDER-Instanz

Am gepinnten Commit ist folgende öffentliche Konstruktion vorhanden:

```lua
function CHIEF:New(Coalition, AgentSet, Alias)
```

Parameter laut Quellkommentar:

```text
Coalition
AgentSet optional
Alias optional
```

Rückgabe:

```text
CHIEF self
```

Der Konstruktor erzeugt intern selbst einen `COMMANDER`:

```lua
self.commander = COMMANDER:New(Coalition, Alias)
```

`CHIEF` besitzt damit eine eigene COMMANDER-Schicht und ist nicht bloß ein externer Policy-Callback für einen bereits von OMW verwalteten COMMANDER.

## 4. Legions- und Missionsweitergabe

Die gepinnte Quelle bestätigt:

```lua
function CHIEF:AddAirwing(Airwing)
  self:AddLegion(Airwing)
  return self
end
```

`AddLegion(...)` bindet die Legion an den Chief und reicht sie an den internen Commander weiter:

```lua
Legion.chief = self
self.commander:AddLegion(Legion)
```

Für Missionen gilt entsprechend:

```lua
function CHIEF:AddMission(Mission)
  Mission.chief = self
  Mission.statusChief = AUFTRAG.Status.PLANNED
  self.commander:AddMission(Mission)
  return self
end
```

Damit liegt die reale Asset-/Missionsausführung zwar beim internen `COMMANDER`, aber `CHIEF` setzt eine zusätzliche strategische Steuerungs- und Statusschicht davor.

## 5. Strategische Funktionen mit OMW-Überlappung

Für OMW sind insbesondere folgende CHIEF-Fähigkeiten kritisch:

```text
INTEL-basierte automatische Zielerkennung
automatische Zielaufnahme und Missionserzeugung
Strategy / DEFCON
Border / Conflict / Attack Zones
Strategic Zones
ResponseOnTarget
asset selection across AIRWING / BRIGADE / FLEET
mission queue forwarding to internal COMMANDER
```

Diese Fähigkeiten sind technisch legitime MOOSE-Funktionen, liegen aber teilweise genau in Bereichen, die in OMW bereits autoritativ durch andere Domänen festgelegt sind.

## 6. OMW-Autoritätskonflikt

Die verbindliche OMW-Grenze lautet:

```text
CampaignState
= strategische Wahrheit und MissionDemand

Air Tasking Domain
= Request-/Missionsplanung und Authority-Korrelation

MOOSE
= bevorzugte Asset-Auswahl und physische Ausführung innerhalb der von OMW freigegebenen Mission
```

Ein produktiver `CHIEF` würde dagegen potenziell selbst:

```text
- aus INTEL neue Ziele ableiten;
- anhand eigener Strategie entscheiden, welche Ziele engagiert werden;
- eigene strategische Zonenlogik führen;
- anhand eigener Response-Regeln Missionsbedarf erzeugen;
- Missions-/Asset-Auswahl über mehrere Legionsdomänen steuern.
```

Das wäre keine kleine Adapterfunktion. Es würde eine zweite strategische Entscheidungsinstanz neben `CampaignState`/`MissionDemand` und der Air-Tasking-Domain einführen.

## 7. Warum CHIEF trotz MOOSE-First nicht verwendet wird

MOOSE-first bedeutet nicht, jede verfügbare High-Level-Klasse zwingend einzusetzen.

Hier ist die MOOSE-Funktionalität nachgewiesen, aber ihr Verantwortungsbereich ist für die aktuelle OMW-Architektur zu breit.

Die korrekte MOOSE-first-Entscheidung ist deshalb:

```text
CHIEF
= available in pinned MOOSE
= source reviewed
= technically capable of strategic dispatch
= NOT USED for OMW Air Tasking production path
```

Die Entscheidung ist keine genehmigungspflichtige Nicht-MOOSE-Ausnahme. OMW ersetzt `CHIEF` nicht durch eine eigene Kopie seiner Funktionen. Stattdessen bleibt die bereits autoritative Kampagnenlogik strategisch zuständig und die folgende Phase-2-Prüfung untersucht, ob `COMMANDER` die benötigte MOOSE-Ausführungs-/Asset-Management-Schicht ohne CHIEF-Strategie ausreichend bereitstellt.

## 8. Nicht zu übernehmende CHIEF-Semantik

Die Air-Tasking-Foundation darf nicht parallel nachbauen:

```text
CHIEF Strategy
CHIEF DEFCON
CHIEF automatic target queue
CHIEF border/conflict/attack-zone policy
CHIEF ResponseOnTarget policy
CHIEF strategic capture-zone engine
```

Falls später eine einzelne dieser Fähigkeiten fachlich benötigt wird, ist erneut zu prüfen, ob sie durch MOOSE direkt oder durch vorhandene OMW-Domänen bereits abgedeckt ist.

## 9. Verifizierte öffentliche CHIEF-Punkte für diesen Scope

Am gepinnten Commit source-geprüft:

```text
CHIEF:New(Coalition, AgentSet, Alias)
CHIEF:AddAirwing(Airwing)
CHIEF:AddMission(Mission)
CHIEF:GetCommander()
```

Zusätzlich source-geprüfte Architekturwirkung:

```text
CHIEF extends INTEL
CHIEF creates its own COMMANDER
CHIEF forwards LEGIONs and AUFTRAG missions to that COMMANDER
CHIEF owns strategy / DEFCON / target and strategic-zone behavior
```

Diese Punkte sind `SOURCE_REVIEWED`, nicht DCS-validiert durch dieses Dokument.

## 10. Phase-2-Entscheidung

Für die Air-Tasking-Foundation gilt:

```text
CHIEF status for this path: REJECTED_FOR_PROJECT_USE
reason: strategic authority overlap, not missing MOOSE capability
replacement: no custom CHIEF clone
next MOOSE layer to verify: COMMANDER
```

Der bestehende Eintrag `CHIEF = REJECTED_FOR_PROJECT_USE` im `OMW-MOOSE-CLASS-INDEX` wird damit für den Air-Tasking-Scope am gepinnten MOOSE-Commit quellenbasiert begründet.

Kein Runtime-Code wurde geändert. Kein DCS-Test wurde durchgeführt. `validated_in_dcs` bleibt `false`.
