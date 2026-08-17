---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-COMMANDER-VERIFICATION
status: DRAFT
document_class: VERIFICATION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 2 source verification of MOOSE COMMANDER for Air Tasking
  - COMMANDER responsibility and authority boundary relative to CampaignState and the Air Tasking domain
  - source-reviewed COMMANDER construction, mission queue, asset recruitment and FSM integration points
not_authoritative_for:
  - final Air Tasking adapter implementation
  - final AUFTRAG mapping by mission type
  - DCS runtime acceptance beyond already documented project evidence
  - unverified MOOSE behavior outside the pinned artifact
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 2 COMMANDER Capability Verification

## 1. Zweck

Dieses Dokument prüft `COMMANDER` für die Air-Tasking-Foundation gegen den gepinnten MOOSE-Stand:

```text
MOOSE context: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Ziel ist nicht, `COMMANDER` als strategische Kampagneninstanz zu interpretieren. Geprüft wird, ob er den MOOSE-nativen operativen C2-/Asset-Assignment-Pfad unterhalb der OMW-Domain tragen kann, ohne eine parallele Dispatcher-Engine zu benötigen.

## 2. MOOSE-eigene Rolle

Der gepinnte Quellcode beschreibt `COMMANDER` als Kopf von `LEGION`-Objekten. Eine Legion kann insbesondere sein:

```text
AIRWING
BRIGADE
FLEET
```

Der `COMMANDER` verwaltet Missionen (`AUFTRAG`) und sucht geeignete Assets für diese Missionen.

Damit ist die originäre MOOSE-Weisungsstruktur:

```text
optional CHIEF
    ↓
COMMANDER
    ↓
LEGION
  ├ AIRWING
  ├ BRIGADE
  └ FLEET
      ↓
COHORT
  ├ SQUADRON
  ├ PLATOON
  └ FLOTILLA
      ↓
OPSGROUP
```

Für OMW bleibt `CHIEF` bewusst außerhalb des produktiven Pfads. Der `COMMANDER` kann dagegen eigenständig verwendet werden.

## 3. Konstruktion und FSM

Quellbestätigte Signatur:

```lua
COMMANDER:New(Coalition, Alias)
```

Dabei gilt im gepinnten Quellstand:

```text
Coalition = mandatory
Alias = optional
start state = NotReadyYet
Start -> OnDuty
Stop -> Stopped
```

Relevante FSM-Events werden im Konstruktor registriert:

```text
Start
Status
Stop
MissionAssign
MissionCancel
TransportAssign
TransportCancel
OpsOnMission
LegionLost
```

Damit ist `COMMANDER` kein passiver Container. Seine Mission- und Asset-Zuweisung ist Teil eines aktiven FSM-/Statuszyklus.

## 4. LEGION-Anbindung

Quellbestätigte API:

```lua
COMMANDER:AddLegion(Legion)
```

`AddLegion` setzt im gepinnten Quellcode:

```lua
Legion.commander = self
```

und registriert die Legion beim COMMANDER.

Die convenience APIs `AddAirwing`, `AddBrigade` und `AddFleet` bilden denselben LEGION-Pfad ab.

Für OMW bedeutet das:

```text
COMMANDER
= MOOSE-operativer C2-Knoten

AIRWING / BRIGADE / FLEET
= physische/operative Ressourcenmanager unter diesem C2-Knoten
```

Die Registrierung begründet jedoch keine strategische Ressourcenhoheit. CampaignState bleibt weiterhin autoritativ dafür, ob ein strategisches Asset überhaupt existiert und verfügbar sein darf.

## 5. Mission Queue

Quellbestätigte API:

```lua
COMMANDER:AddMission(Mission)
```

`Mission` ist ein MOOSE-`AUFTRAG`.

Der COMMANDER bindet die Mission an sich und führt sie in seiner Mission Queue. Der normale Statuszyklus ruft unter anderem auf:

```text
CheckTargetQueue()
CheckMissionQueue()
CheckTransportQueue()
```

`CheckMissionQueue()` verarbeitet geplante Missionen und versucht, geeignete Assets zu rekrutieren und die Mission geeigneten Legionen zuzuweisen.

Damit gilt für die Air-Tasking-Grenze:

```text
AIR_TASKING_MISSION
!= AUFTRAG

Air Tasking Adapter
creates/configures approved AUFTRAG
    ↓
COMMANDER:AddMission(AUFTRAG)
    ↓
COMMANDER performs MOOSE-native asset selection / assignment
```

Die Air-Tasking-Domain darf deshalb keine eigene parallele Auswahlengine für AIRWING-/SQUADRON-Assets bauen.

## 6. Capability-Prüfung

Quellbestätigte API:

```lua
COMMANDER:CanMission(Mission)
```

Die Methode prüft, ob mindestens ein verfügbarer Cohort-/Legion-Pfad die übergebene Mission ausführen kann.

Für OMW ist dies eine technische MOOSE-Capability-Prüfung, nicht strategische Verfügbarkeit:

```text
COMMANDER:CanMission(AUFTRAG) == true
!= CampaignState asset available
!= resource reservation exists
!= AIR_SUPPORT_REQUEST approved
```

Die fachliche Freigabe muss vorher aus der autoritativen OMW-Domain kommen.

## 7. Native Asset Recruitment

Der gepinnte `COMMANDER` besitzt ausdrücklich native Asset-Rekrutierung für Missionen:

```lua
COMMANDER:RecruitAssetsForMission(Mission)
```

Der Quellpfad bestimmt zunächst die benötigte Assetanzahl aus dem `AUFTRAG`, ermittelt geeignete Cohorts/Legions und delegiert die Auswahl an die LEGION-Rekrutierungslogik.

Der Statuszyklus zeigt konzeptionell:

```text
planned AUFTRAG
    ↓
RecruitAssetsForMission
    ↓
LEGION / COHORT candidate selection
    ↓
mission assets attached
    ↓
optional escort / transport recruitment
    ↓
MissionAssign
```

Das ist für OMW eine wesentliche MOOSE-First-Feststellung:

```text
eigene Air Tasking Asset-Auswahlengine
= nicht erforderlich und nicht zulässig
```

solange der native COMMANDER-/LEGION-Pfad die Anforderung trägt.

## 8. Mission Assignment

Quellbestätigtes FSM-Ereignis:

```lua
COMMANDER:MissionAssign(Mission, Legions)
```

Der dazugehörige `onafterMissionAssign`-Pfad fügt die Mission der COMMANDER-Queue hinzu und übergibt sie den ausgewählten Legionen.

Die konkrete physische Ausführung bleibt danach Aufgabe der jeweiligen LEGION-/COHORT-/OPSGROUP-Struktur.

Damit ist die technische Verantwortungsfolge für OMW:

```text
CampaignState / MissionDemand
    ↓ strategic authorization
Air Tasking Domain
    ↓ mission planning / request correlation
Air Tasking Adapter
    ↓ AUFTRAG translation
COMMANDER
    ↓ MOOSE-native mission assignment / asset recruitment
AIRWING / BRIGADE / FLEET
    ↓
SQUADRON / PLATOON / FLOTILLA
    ↓
FLIGHTGROUP / ARMYGROUP / NAVYGROUP
```

## 9. OpsOnMission als Beobachtungspunkt

Der gepinnte COMMANDER registriert:

```text
OpsOnMission
```

und dokumentiert den Callback-Kontext:

```lua
OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)
```

Dieser Event ist ein geeigneter späterer Runtime-Korrelationspunkt für:

```text
EXE- execution attempt
ATM- mission
MOOSE AUFTRAG
OPSGROUP
```

Er ist jedoch kein Beweis für Kampagnenerfolg und kein automatischer CampaignState-Settlement-Trigger.

## 10. MissionCancel

Der COMMANDER besitzt den FSM-Pfad:

```lua
COMMANDER:MissionCancel(Mission)
```

Die MOOSE-Dokumentation und der gepinnte Source-Pfad beschreiben, dass die Cancellation an zugewiesene Legionen und OPSGROUPs weitergereicht wird.

Für OMW gilt weiterhin die bereits festgelegte Domain-Grenze:

```text
COMMANDER MissionCancel
= physical/operational cancellation request

ATM CANCELLED / ABORTED
= Air Tasking domain decision/result

CampaignState transaction cancellation/loss/consumption
= separate authoritative settlement
```

Diese Zustände dürfen nicht automatisch gleichgesetzt werden.

## 11. Verhältnis zu CHIEF

`CHIEF` erzeugt intern einen `COMMANDER` und nutzt ihn als untergeordneten operativen Dispatcher.

OMW verwendet diese obere CHIEF-Schicht nicht, weil strategische Entscheidung, MissionDemand und Ressourcenautorität bereits außerhalb von MOOSE liegen.

Daraus folgt für den produktiven Zielpfad:

```text
NO CHIEF

CampaignState / MissionDemand / Air Tasking
    ↓
COMMANDER
    ↓
MOOSE operational hierarchy
```

Dies ist eine bewusste Nutzung der originären MOOSE-Struktur ohne deren strategische CHIEF-Automatik.

## 12. Verhältnis zu CampaignState

COMMANDER darf für OMW besitzen beziehungsweise entscheiden:

```text
- MOOSE mission queue
- MOOSE eligibility/capability evaluation
- Auswahl geeigneter LEGION/COHORT assets innerhalb des freigegebenen MOOSE-Pools
- Zuweisung eines AUFTRAG
- operative Cancellation-Weitergabe
- Runtime-FSM-Events
```

COMMANDER darf für OMW nicht zur Autorität werden für:

```text
- strategischen Aircraft-Bestand
- Fuel-/Weapon-Bestand
- CampaignState reservation truth
- MissionDemand creation/result authority
- AIR_SUPPORT_REQUEST approval
- persistente ATM-/ASR-Identität
- Campaign success/failure settlement
```

## 13. Verhältnis zur Air Tasking Domain

Die Phase-1-Domain bleibt oberhalb des Frameworks:

```text
AIR_TASKING_MISSION
= persistente fachliche Mission

AUFTRAG
= transiente MOOSE-Ausführungsmission
```

Der kleinste spätere Adapter muss deshalb nur die tatsächlich erforderlichen Daten aus einer freigegebenen `AIR_TASKING_MISSION` in ein passendes `AUFTRAG` übersetzen und stabile Korrelation herstellen.

Er darf nicht nachbauen:

```text
COMMANDER mission queue
COMMANDER asset recruitment
LEGION cohort selection
AIRWING mission request/dispatch
OPSGROUP lifecycle
```

## 14. Bereits vorhandene OMW-Runtime-Evidenz

Die bestehende OMW-MOOSE-Dokumentation enthält für denselben gepinnten MOOSE-Stand bereits dokumentierte COMMANDER-Evidenz.

Der verbindliche AIRWING-/SQUADRON-/WAREHOUSE-Lifecycle beschreibt den Acceptance-Pfad:

```lua
local commander = COMMANDER:New(...)
commander:AddAirwing(airwing)
commander:Start()
local canMission = commander:CanMission(mission)
commander:AddMission(mission)
commander:Status()
```

und fordert als positive Runtime-Evidenz unter anderem:

```text
NotReadyYet -> OnDuty
CanMission == true
MissionAssign
AIRWING MissionRequest
expected asset OpsOnMission
AUFTRAG at least started
```

Diese bestehende Evidenz wird nicht als neue Phase-2-DCS-Validierung umetikettiert. Phase 2 nutzt sie nur innerhalb ihres exakt dokumentierten Provenienzbereichs.

## 15. Phase-2-Bewertung

Für die Air-Tasking-Foundation ist `COMMANDER` geeignet und soll als primärer MOOSE-C2-/Mission-Assignment-Layer weiterverfolgt werden.

Bewertung:

```text
COMMANDER availability: SOURCE CONFIRMED
COMMANDER constructor/FSM: SOURCE CONFIRMED
LEGION registration: SOURCE CONFIRMED
mission queue: SOURCE CONFIRMED
CanMission: SOURCE CONFIRMED
native mission asset recruitment: SOURCE CONFIRMED
MissionAssign: SOURCE CONFIRMED
OpsOnMission correlation point: SOURCE CONFIRMED
MissionCancel: SOURCE CONFIRMED
existing OMW runtime evidence: AVAILABLE FOR DOCUMENTED SCOPE
new DCS validation in this record: NO
```

Architekturentscheidung für die weitere Phase-2-Prüfung:

```text
CampaignState / MissionDemand / Air Tasking
    ↓
small OMW adapter
    ↓
COMMANDER
    ↓
AIRWING / BRIGADE / FLEET
```

Damit besteht derzeit kein Nachweis einer Framework-Lücke, die eine eigene OMW-Air-Asset-Dispatcher-Engine rechtfertigen würde.

## 16. Nächster Prüfschritt

Nach `COMMANDER` folgen im Manifest:

```text
AIRWING / BRIGADE
SQUADRON / PLATOON
AUFTRAG
Mission Assignment / Lifecycle / FSM callbacks
FLIGHTGROUP / ARMYGROUP
```

Kein Runtime-Code wurde geändert. Kein neuer DCS-Test wurde durchgeführt. `validated_in_dcs` bleibt `false`.
