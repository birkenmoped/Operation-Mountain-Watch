---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-SQUADRON-PLATOON-VERIFICATION
status: DRAFT
document_class: MOOSE_CAPABILITY_VERIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase-2 source review of MOOSE SQUADRON and PLATOON for Air Tasking
  - branch-local capability and asset-selection boundary below AIRWING and BRIGADE
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - unverified MOOSE methods outside the documented scope
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Phase 2 – SQUADRON / PLATOON Capability Verification

## 1. Zweck

Dieses Dokument prüft die MOOSE-Klassen `SQUADRON` und `PLATOON` für den OMW-Air-Tasking-Pfad am tatsächlich gepinnten MOOSE-Stand.

Verifikationsbaseline:

```text
MOOSE context: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Geprüft wurden:

```text
MOOSE source:
Moose Development/Moose/Ops/Squadron.lua
Moose Development/Moose/Ops/Platoon.lua
Moose Development/Moose/Ops/Cohort.lua

Official MOOSE demos:
Ops/Airwing/Airwing - 010 - Fighter Wing
Ops/Brigade/Brigade - 010 - Patrol Mission
```

Die Prüfung ist eine Source-/Demo-Verifikation. Sie erzeugt keinen neuen DCS-Acceptance-Status.

## 2. Stellung in der MOOSE-Hierarchie

Beide Klassen erben von `COHORT`:

```text
LEGION
├── AIRWING
│   └── SQUADRON
└── BRIGADE
    └── PLATOON
```

Für OMW bleibt die operative Zielkette:

```text
CampaignState / MissionDemand
        ↓
Air Tasking Domain
        ↓
small OMW adapter
        ↓
COMMANDER
        ↓
AIRWING / BRIGADE
        ↓
SQUADRON / PLATOON
        ↓
FLIGHTGROUP / ARMYGROUP
        ↓
DCS
```

`SQUADRON` und `PLATOON` sind dabei keine strategischen Ressourcenautoritäten. Sie bilden MOOSE-Cohorts mit Mission-Capabilities und den zugehörigen physischen Assetgruppen ab.

## 3. Gemeinsamer COHORT-Vertrag

### 3.1 Konstruktion und Identität

`COHORT:New(TemplateGroupName, Ngroups, CohortName)` ist die gemeinsame Basiskonstruktion.

Quellseitig bestätigt:

```text
TemplateGroupName
= Mission-Editor-Templategruppe

Ngroups
= Anzahl der Assetgruppen; Default 3

CohortName
= logischer MOOSE-Cohortname; muss innerhalb der Mission eindeutig sein
```

Der Quellstand führt eine globale `_COHORTNAMES`-Liste und verweigert die Konstruktion bei doppeltem Cohortnamen. Das ist eine MOOSE-Runtime-Voraussetzung, aber keine OMW-Domain-ID.

Daraus folgt:

```text
SQUADRON/PLATOON name
!= OMW stable entity ID
!= CampaignState entity identity
```

OMW behält stabile IDs in der Domain und verwendet MOOSE-Namen nur als Runtime-/Konfigurationsreferenz.

### 3.2 Template-Abhängigkeit

`COHORT:New(...)` löst die Templategruppe mit `GROUP:FindByName(...)` auf und gibt `nil` zurück, wenn sie nicht existiert.

Damit ist für jede spätere produktive Cohort-Erzeugung erforderlich:

```text
valid ME template
→ valid MOOSE GROUP wrapper
→ COHORT / SQUADRON / PLATOON construction
```

Eine fehlende Templategruppe darf im OMW-Adapter nicht als verfügbare strategische Einheit interpretiert werden.

### 3.3 Mission Capability

Die gemeinsame öffentliche Capability-Funktion ist:

```text
COHORT:AddMissionCapability(MissionTypes, Performance)
```

Quellseitig bestätigt:

```text
MissionTypes
= einzelner MissionType oder Tabelle von MissionTypes

Performance
= Capability-Performance; Default 50
```

Die Capability ist damit eine native MOOSE-Eigenschaft des Cohorts und soll nicht als parallele OMW-Dispatcher-Matrix nachgebaut werden.

OMW darf fachliche Anforderungen wie Missionstyp, gewünschte Aircraft-Klasse oder Authority-Scope planen. Die operative Prüfung, ob ein MOOSE-Cohort den resultierenden AUFTRAG ausführen kann, soll jedoch auf den nativen MOOSE-Capabilities aufbauen.

### 3.4 Common operational properties

`COHORT` stellt gemeinsame Konfiguration bereit, unter anderem:

```text
SetLivery(...)
SetSkill(...)
SetTurnoverTime(...)
SetRadio(...)
SetGrouping(...)
AddMissionCapability(...)
```

Die Cohort-FSM besitzt mindestens:

```text
Stopped -> Start -> OnDuty
OnDuty -> Pause -> Paused
Paused -> Unpause -> OnDuty
OnDuty -> Relocate -> Relocating -> Relocated -> OnDuty
* -> Stop -> Stopped
```

Diese Zustände gehören zum MOOSE-Runtime-Cohort und dürfen nicht mit den persistenten OMW-Request-/Mission-Statusautomaten gleichgesetzt werden.

## 4. SQUADRON

### 4.1 Konstruktor

Am gepinnten Stand bestätigt:

```text
SQUADRON:New(TemplateGroupName, Ngroups, SquadronName)
```

Der Konstruktor ruft `COHORT:New(...)` auf und ergänzt unter anderem:

```text
AUFTRAG.Type.ORBIT capability
isAir = true
refuelSystem from template unit
 tankerSystem from template unit
```

Damit besitzt jedes `SQUADRON` automatisch ORBIT-Fähigkeit. Diese implizite MOOSE-Capability ist bei späterer Mission-Compatibility-Prüfung zu berücksichtigen.

### 4.2 AIRWING-Bindung

Bestätigt:

```text
SQUADRON:SetAirwing(Airwing)
SQUADRON:GetAirwing()
```

Die eigentliche Integration erfolgt im bereits geprüften `AIRWING:AddSquadron(...)`-Pfad. Dort wird das SQUADRON in das AIRWING aufgenommen, Assets werden registriert und das SQUADRON bei Bedarf gestartet.

Diese Bindung bedeutet:

```text
SQUADRON belongs to AIRWING in MOOSE runtime
```

aber nicht:

```text
SQUADRON owns strategic aircraft inventory
```

Strategische Verfügbarkeit und Reservierung bleiben OMW/CampaignState-Verantwortung.

### 4.3 Gruppierung und Parking

Bestätigt:

```text
SQUADRON:SetGrouping(nunits)
SQUADRON:SetParkingIDs(ParkingIDs)
```

`SetGrouping(...)` begrenzt die Gruppengröße im SQUADRON-spezifischen Pfad auf 1 bis 4 Units.

`SetParkingIDs(...)` beschränkt erlaubte Spawn-Parking-IDs. Die MOOSE-Dokumentation weist ausdrücklich darauf hin, dass diese IDs nicht den im Mission Editor angezeigten IDs entsprechen müssen.

Für OMW bleibt deshalb die bereits etablierte airfield-spezifische Parking-Kalibrierung maßgeblich. Parking-IDs dürfen nicht aus der Air-Tasking-Domain erfunden oder aus sichtbaren ME-Nummern ungeprüft übernommen werden.

### 4.4 Takeoff / landing lifecycle options

Bestätigt:

```text
SetTakeoffType(...)
SetTakeoffCold()
SetTakeoffHot()
SetTakeoffAir()
SetDespawnAfterLanding(...)
SetDespawnAfterHolding(...)
```

Diese Methoden konfigurieren die physische MOOSE-Ausführung. Sie sind keine Planungsstatus und keine CampaignState-Ressourcenentscheidungen.

### 4.5 Fuel behavior

Bestätigt:

```text
SQUADRON:SetFuelLowThreshold(LowFuel)
SQUADRON:SetFuelLowRefuel(switch)
```

Das ist native MOOSE-Cohort-/Flight-Konfiguration. OMW darf daraus keine neue allgemeine strategische Fuel-Autorität ableiten. Missionsspezifische Fuel-/Recovery-Verträge bleiben an die jeweils zuständige OMW-/AAR-/CampaignState-Baseline gebunden.

### 4.6 Offizielle Demo-Evidenz

Die offizielle MOOSE-Demo `Airwing - 010 - Fighter Wing` verwendet unter anderem:

```text
SQUADRON:New(...)
SetGrouping(...)
SetModex(...)
SetCallsign(...)
SetRadio(...)
SetSkill(...)
AddMissionCapability(...)
AIRWING:New(...)
AIRWING:AddSquadron(...)
AIRWING:NewPayload(...)
AIRWING:AddMission(...)
```

Die Demo bestätigt damit die vorgesehene native Kombination:

```text
SQUADRON capability definition
→ AIRWING registration
→ AIRWING asset/payload selection
→ AUFTRAG execution
```

OMW soll diese Capability-/Auswahlmechanik verwenden und keine parallele Squadron-Dispatch-Engine implementieren.

## 5. PLATOON

### 5.1 Konstruktor

Am gepinnten Stand bestätigt:

```text
PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)
```

Der Konstruktor ruft `COHORT:New(...)` auf und ergänzt:

```text
AUFTRAG.Type.NOTHING capability with performance 50
isGround = true
ammo = _CheckAmmo()
```

Die `NOTHING`-Capability ist ein MOOSE-Default und keine OMW-Ground-Mission.

### 5.2 BRIGADE-Bindung

Bestätigt:

```text
PLATOON:SetBrigade(Brigade)
PLATOON:GetBrigade()
```

Die eigentliche Integration erfolgt über den bereits geprüften `BRIGADE:AddPlatoon(...)`-Pfad. Dort wird das Platoon dem BRIGADE-Cohortbestand hinzugefügt, Assetgruppen werden registriert und das Platoon bei Bedarf gestartet.

### 5.3 Capability-Definition

PLATOON verwendet wie SQUADRON die geerbte:

```text
COHORT:AddMissionCapability(...)
```

Die offizielle Brigade-Demo definiert beispielsweise:

```text
PATROLZONE
ARTY
AMMOSUPPLY
```

mit unterschiedlichen Performance-Werten für verschiedene Platoons.

Das bestätigt denselben MOOSE-first-Grundsatz wie bei SQUADRON:

```text
OMW defines required effect / mission intent
MOOSE COHORT capability defines operational suitability
```

Eine zweite OMW-Platoon-Capability- oder Asset-Scoring-Engine ist nicht erforderlich.

### 5.4 Offizielle Demo-Evidenz

Die offizielle Demo `Brigade - 010 - Patrol Mission` verwendet:

```text
PLATOON:New(...)
AddMissionCapability(...)
BRIGADE:New(...)
BRIGADE:AddPlatoon(...)
BRIGADE:Start()
AUFTRAG:NewPATROLZONE(...)
BRIGADE:AddMission(...)
BRIGADE:OnAfterArmyOnMission(...)
```

Damit ist die native Kombination für Ground-Cohorts belegt:

```text
PLATOON capability definition
→ BRIGADE registration
→ AUFTRAG assignment
→ ARMYGROUP runtime callback
```

## 6. Asset- und Authority-Grenze

Die Phase-2-Prüfung ergibt für beide Cohortklassen dieselbe Grundregel:

```text
OMW strategic availability / reservation
!= MOOSE cohort capability / asset availability
```

### OMW bleibt zuständig für

```text
MissionDemand identity and campaign need
AIR_SUPPORT_REQUEST / AIR_TASKING_MISSION domain records
strategic resource availability
strategic reservation / settlement
command / tasking / request authority
stable IDs and persistence
```

### MOOSE COHORT bleibt zuständig für

```text
runtime cohort identity
mission capability / performance
cohort configuration
runtime duty / pause state
physical asset-group association through LEGION
operational suitability input for native MOOSE selection
```

### Nicht zulässig

```text
OMW reimplements SQUADRON/PLATOON capability scoring
OMW uses DCS group names as persistent cohort identity
OMW treats Ngroups as independent strategic inventory authority
OMW infers CampaignState availability solely from MOOSE cohort state
OMW bypasses COMMANDER/LEGION selection with a parallel dispatcher without an approved framework-gap exception
```

## 7. Relevanz für die finale Adaptergrenze

Für einen späteren `AIR_TASKING_MISSION`-zu-MOOSE-Adapter sollen nur die Informationen übergeben werden, die MOOSE zur physischen Ausführung benötigt.

Vorläufige Trennung:

```text
OMW domain truth:
mission_id
request_ids
mission_demand_ids
planning/request status
strategic reservation refs
player_or_ai_assignment
support relationships
command / authority references
persistent result/correlation

MOOSE execution/configuration:
AUFTRAG mission type and mission parameters
eligible native Cohort capabilities
LEGION/Cohort runtime availability
physical asset-group selection
runtime FlightGroup/ArmyGroup lifecycle
```

Die exakte AUFTRAG-Feldabbildung bleibt dem nächsten Phase-2-Arbeitspunkt vorbehalten.

## 8. Source-review result

```text
SQUADRON: SOURCE_REVIEWED for Phase-2 Air Tasking scope
PLATOON: SOURCE_REVIEWED for Phase-2 Air Tasking scope
COHORT shared capability path: SOURCE_REVIEWED
```

Bestehende ältere DCS-validierte SQUADRON-/COHORT-Scope-Einträge bleiben unverändert für ihre exakt dokumentierte Provenienz. Diese Phase-2-Prüfung erweitert den DCS-validierten Scope nicht.

## 9. Phase-2-Entscheidung

Der Manifestpunkt kann geschlossen werden:

```text
[x] SQUADRON-/PLATOON-relevante APIs prüfen
```

Für die Architektur ergibt sich keine Framework-Lücke, die eine eigene Cohort- oder Asset-Capability-Engine rechtfertigt.

Der nächste Verifikationspunkt ist:

```text
AUFTRAG construction and mission types
```

Dabei sind insbesondere die für die profilierten OMW-Missionstypen benötigten Konstruktoren, Parameter, Voraussetzungen, Status-/Result-Semantik und die später erforderliche Domain-zu-AUFTRAG-Abbildung am gepinnten Quellstand zu prüfen.
