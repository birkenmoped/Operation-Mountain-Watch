---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-AUFTRAG-CONSTRUCTION-VERIFICATION
status: DRAFT
document_class: MOOSE_CAPABILITY_VERIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase-2 source review of MOOSE AUFTRAG construction for Air Tasking
  - branch-local mapping candidates for CAS, AAR, ISR, CSAR, AIRLIFT, and ESCORT
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS runtime acceptance outside previously documented exact acceptance scopes
  - final mission-type adapter selection before remaining Phase-2 lifecycle review
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Phase 2 – AUFTRAG Construction Verification

## 1. Zweck

Dieses Dokument prüft die MOOSE-`AUFTRAG`-Konstruktion für die in OMW bereits profilierten Air-Tasking-Missionstypen:

```text
CAS
AAR
ISR
CSAR
AIRLIFT
ESCORT
```

Die Prüfung ist Teil von Phase 2 und erzeugt keinen neuen DCS-Acceptance-Status.

Die strategische Grenze bleibt unverändert:

```text
CampaignState / MissionDemand / AIR_TASKING_MISSION
= strategische und persistente Domain-Wahrheit

AUFTRAG
= temporäres MOOSE-Runtime-Missionsobjekt für operative Ausführung
```

`AIR_TASKING_MISSION` wird nicht durch `AUFTRAG` ersetzt.

## 2. Tatsächlich geprüfte MOOSE-Baseline

Die aktuelle vom Projektinhaber bereitgestellte Missionsdatei wurde direkt geprüft:

```text
mission artifact: OMW_Template_v12_groundworks.miz
mission SHA-256: 3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078
embedded source: l10n/DEFAULT/Moose.lua
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MOOSE context: develop
```

Damit entspricht die tatsächlich in der aktuellen `.miz` enthaltene `Moose.lua` exakt der bereits für Phase 2 gepinnten Baseline.

Verbindlicher Prüfweg:

```text
MOOSE develop documentation
→ embedded Moose.lua from current mission artifact
→ signatures / returns / preconditions / side effects
→ official MOOSE demos/tests where relevant
```

## 3. Generischer AUFTRAG-Unterbau

Am eingebetteten Quellstand ist vorhanden:

```text
AUFTRAG:New(Type)
```

Für OMW sollen jedoch keine generischen Missionstypen aus Domain-Strings frei konstruiert werden, wenn ein spezialisierter öffentlicher Konstruktor existiert. Die spezialisierten Konstruktoren setzen unter anderem Missionsart, DCS-Task, Kategorien, ROE/ROT und missionsspezifische Parameter.

Relevante gemeinsame Zeit-/Ausführungsparameter sind source-geprüft:

```text
AUFTRAG:SetTime(ClockStart, ClockStop)
AUFTRAG:SetDuration(Duration)
AUFTRAG:SetPushTime(ClockPush)
AUFTRAG:SetPriority(Prio, Urgent, Importance)
AUFTRAG:SetRepeat(Nrepeat)
AUFTRAG:SetRepeatDelay(RepeatDelay)
AUFTRAG:SetRepeatOnFailure(Nrepeat)
AUFTRAG:SetRepeatOnSuccess(Nrepeat)
AUFTRAG:SetRequiredAssets(NassetsMin, NassetsMax)
AUFTRAG:SetMissionAltitude(Altitude)
AUFTRAG:SetMissionSpeed(Speed)
AUFTRAG:SetMissionRange(Range)
AUFTRAG:SetMissionEgressCoord(Coordinate, Altitude, Speed)
AUFTRAG:SetMissionIngressCoord(Coordinate, Altitude, Speed)
AUFTRAG:SetMissionHoldingCoord(Coordinate, Altitude, Speed, Duration)
```

Wichtige Semantik:

```text
SetTime()
- numerische Werte sind relativ zur aktuellen Missionszeit;
- Stringwerte werden als Uhrzeit interpretiert;
- Standardstart liegt fünf Sekunden nach Add/Erzeugungspfad;
- ein Stopzeitpunkt kann die Queue-Fähigkeit begrenzen.

SetDuration()
- begrenzt die ausgeführte Mission;
- nach Ablauf wird die Mission abgebrochen/cancelled.

SetRepeat*()
- gilt für LEGION/COMMANDER/CHIEF-geführte Missionen;
- ist MOOSE-Ausführungssemantik, keine OMW-Persistenz- oder Ressourcenautorität.
```

`AUFTRAG:Cancel()` ist im vorhandenen OMW-AAR-Scope bereits praktisch bestätigt. Die vollständige Mission-Assignment-/Lifecycle-/FSM-Auswertung bleibt der unmittelbar folgenden Phase-2-Prüfung vorbehalten.

## 4. AAR

Bestätigter Konstruktor:

```text
AUFTRAG:NewTANKER(Coordinate, Altitude, Speed, Heading, Leg, RefuelSystem)
→ AUFTRAG
```

Parameter am eingebetteten Quellstand:

```text
Coordinate
= Orbit-/Track-Referenz

Altitude
= optional, ft; Default aus Coordinate

Speed
= optional, KIAS; Default 350

Heading
= optional, Grad; Default 270

Leg
= optional, NM; Default 10
= 0 erzeugt Kreisorbit

RefuelSystem
= 0 boom / 1 probe
= Auswahlhilfe für AIRWING
```

Der Konstruktor erzeugt intern ORBIT, setzt anschließend:

```text
mission.type = AUFTRAG.Type.TANKER
missionTask = ENUMS.MissionTask.REFUELING
ROE = WeaponHold
ROT = PassiveDefense
category = AIRCRAFT
```

OMW-Bewertung:

```text
AAR -> AUFTRAG:NewTANKER(...)
```

ist die bestätigte native MOOSE-Abbildung. Diese Methode ist für den bestehenden AAR-Scope bereits praktisch bestätigt; die Phase-2-Prüfung ändert keine AAR-Ressourcen- oder Lifecycle-Baseline.

## 5. CAS

Bestätigte Konstruktoren:

```text
AUFTRAG:NewCAS(ZoneCAS, Altitude, Speed, Coordinate, Heading, Leg, TargetTypes)
AUFTRAG:NewCASENHANCED(CasZone, Altitude, Speed, RangeMax, NoEngageZoneSet, TargetTypes)
```

### `NewCAS(...)`

Source-geprüfte Kernsemantik:

```text
ZoneCAS
= Kreiszone, in der erkannte Ziele bekämpft werden

Altitude
= optional; Default 10,000 ft

Speed
= optional; Default 350 KIAS

Coordinate
= optional; Default Zentrum der CAS-Zone

Heading / Leg
= optionaler Racetrack; ohne beide Kreisorbit

TargetTypes
= optional; Default Helicopters / Ground Units / Light armed ships
```

Der Konstruktor setzt `AUFTRAG.Type.CAS`, DCS-CAS-Task, `OpenFire`, `EvadeFire` und Aircraft-Kategorie.

### `NewCASENHANCED(...)`

Der Konstruktor ist ebenfalls vorhanden und besitzt zusätzliche Reichweiten-/No-Engage-Zonen-Parameter. Er ist damit kein automatischer Ersatz für `NewCAS(...)`; die Auswahl hängt vom späteren OMW-CAS-Ausführungsvertrag und dem gewünschten Detektions-/Engagement-Verhalten ab.

OMW-Bewertung:

```text
CAS -> native AUFTRAG support exists
```

Für Gate 2 ist damit keine eigene CAS-Missions-FSM oder eigene CAS-Dispatcher-Engine erforderlich. Die endgültige Auswahl `NewCAS` versus `NewCASENHANCED` bleibt bewusst offen, bis Mission Assignment/Lifecycle und der spätere Ground-Alert/CAS-Scope abgeglichen sind.

## 6. ISR

Bestätigter Konstruktor:

```text
AUFTRAG:NewRECON(ZoneSet, Speed, Altitude, Adinfinitum, Randomly, Formation)
→ AUFTRAG
```

Source-geprüfte Semantik:

```text
ZoneSet
= SET_ZONE oder ZONE_BASE

Speed
= optional, knots

Altitude
= optional, ft; Default 2000 ft ASL

Adinfinitum
= Route nach letztem Gebiet erneut beginnen

Randomly
= zufällige Gebietsreihenfolge/-auswahl

Formation
= Formation für die Recon-Route
```

Der Konstruktor setzt `AUFTRAG.Type.RECON`, `WeaponHold`, `PassiveDefense`, AlarmState Auto und Kategorie `ALL`.

OMW-Bewertung:

```text
ISR physical routing/presence -> AUFTRAG:NewRECON(...) is a native candidate
```

Aber:

```text
AUFTRAG:NewRECON(...)
!= vollständige OMW-ISR-Sensor-/INTEL-Wirkung
```

Der Konstruktor beweist eine native Recon-Mission und deren Route, aber nicht automatisch die spätere kampagnenweite Aufklärungswirkung, INTEL-Erzeugung oder Persistenz. Diese bleiben in den zuständigen ISR-/INTEL-Verträgen zu prüfen.

## 7. CSAR

Im eingebetteten Quellstand existiert:

```text
AUFTRAG:NewRESCUEHELO(Carrier)
```

Die Quellsemantik ist jedoch spezifisch:

```text
Carrier
= UNIT, die als Träger-/Carrier-Ziel dient
category = HELICOPTER
missionTask = NOTHING
```

Damit ist dieser Konstruktor **keine generische CSAR-Mission für abgeschossene Besatzungen**.

OMW-Bewertung:

```text
CSAR != AUFTRAG:NewRESCUEHELO(Carrier)
```

Für OMW bleibt MOOSE-first zu prüfen beziehungsweise zu verwenden:

```text
CSAR / AICSAR
```

Eine eigene OMW-CSAR-Engine wird daraus ausdrücklich nicht abgeleitet. Es liegt hier keine Genehmigung für eine Nicht-MOOSE-Ausnahme vor und es wird keine solche benötigt, solange die vorhandenen MOOSE-CSAR-Klassen den späteren Scope tragen.

## 8. AIRLIFT

Der eingebettete Quellstand besitzt mehrere spezialisierte Transportkonstruktoren.

### Troop transport

```text
AUFTRAG:NewTROOPTRANSPORT(TransportGroupSet, DropoffCoordinate, PickupCoordinate, PickupRadius)
```

Er akzeptiert eine `GROUP` oder `SET_GROUP`; andere Typen führen zu Fehler und `nil`.

Kategorien:

```text
HELICOPTER
GROUND
```

### Slingload cargo

```text
AUFTRAG:NewCARGOTRANSPORT(StaticCargo, DropZone)
```

Wichtige Source-Voraussetzung:

```text
DropZone muss eine Mission-Editor-Zone mit referenzierbarer ZoneID sein.
```

Dieser Konstruktor ist nur für Rotary Wing / Slingload vorgesehen.

### Internal freight

```text
AUFTRAG:NewFREIGHTTRANSPORT(StaticCargo, Destination)
```

Source-geprüfte Voraussetzungen:

```text
Destination darf nicht nil sein;
String-Destination wird via AIRBASE:FindByName(...) aufgelöst;
StaticCargo darf nicht nil sein;
String-Cargo wird via STATIC:FindByName(...) aufgelöst;
STATIC wird bei Bedarf in SET_STATIC überführt;
leeres Cargo-Set -> nil;
```

Kategorien:

```text
HELICOPTER
AIRCRAFT
```

### OPSTRANSPORT-Warnung

In der tatsächlich eingebetteten `Moose.lua` steht zwar der Quelltext von

```text
AUFTRAG:NewOPSTRANSPORT(CargoGroupSet, PickupZone, DeployZone)
```

aber der gesamte Funktionsblock liegt zwischen:

```lua
--[[
...
]]
```

und ist damit **auskommentiert und nicht als aufrufbare öffentliche Methode verfügbar**.

Daraus folgt verbindlich:

```text
AUFTRAG:NewOPSTRANSPORT(...)
= NOT AVAILABLE in the embedded Moose.lua baseline
```

Eine Dokumentationsfundstelle oder Textsuche nach dem Funktionsnamen darf daher nicht als API-Verfügbarkeit interpretiert werden.

OMW-Bewertung:

```text
AIRLIFT is not one single AUFTRAG constructor.
```

Der spätere Adapter muss nach tatsächlicher Frachtsemantik auswählen:

```text
troops/groups -> NewTROOPTRANSPORT
external sling cargo -> NewCARGOTRANSPORT
internal static freight to airbase -> NewFREIGHTTRANSPORT
```

`NewOPSTRANSPORT` darf am gepinnten Stand nicht verwendet werden.

## 9. ESCORT

Bestätigter Konstruktor:

```text
AUFTRAG:NewESCORT(EscortGroup, OffsetVector, EngageMaxDistance, TargetTypes)
→ AUFTRAG
```

Source-geprüfte Semantik:

```text
EscortGroup
= GROUP oder Gruppenname

OffsetVector
= optional; Default {x=-100, y=0, z=200}

EngageMaxDistance
= optional; Default 32 NM

TargetTypes
= optional; Default {"Air"}
= leere Tabelle ergibt FOLLOW-artige Mission ohne automatische Zielbekämpfung
```

Der Konstruktor setzt `AUFTRAG.Type.ESCORT`, DCS-ESCORT-Task, Aircraft-Kategorie und entsprechende ROE/ROT-Werte.

OMW-Bewertung:

```text
ESCORT -> AUFTRAG:NewESCORT(...)
```

ist die native MOOSE-Abbildung für die physische Escort-Ausführung. OMW muss keine eigene Follow-/Escort-Task-Engine erstellen.

## 10. Domain-to-AUFTRAG-Grenze

Nach dieser Prüfung bleibt folgende Trennung belastbar:

```text
OMW domain truth
----------------
mission_id
request_ids
mission_demand_ids
planning/request lifecycle
planned_start / planned_stop
alert/readiness semantics
command/tasking/request authority
strategic reservation references
assigned OMW squadron/entity IDs
support relationships
player_or_ai_assignment
persistent result/history

MOOSE AUFTRAG runtime
--------------------
mission type implementation
runtime target/zone/coordinate objects
orbit / route / speed / altitude execution parameters
MOOSE required asset counts
runtime priority/urgency where explicitly mapped
ingress / holding / egress execution parameters
runtime repeat behavior only where explicitly intended
runtime cancellation/execution FSM
```

Nicht zulässig:

```text
AUFTRAG becomes strategic resource authority
AUFTRAG object is persisted as campaign truth
OMW duplicates AUFTRAG mission FSM
OMW invents generic CSAR semantics from NewRESCUEHELO
OMW calls commented-out NewOPSTRANSPORT
OMW maps every domain field blindly into MOOSE
```

## 11. Vorläufige Mapping-Matrix

| OMW Mission Type | Native MOOSE construction | Phase-2 assessment |
|---|---|---|
| `AAR` | `AUFTRAG:NewTANKER(...)` | `SUPPORTED`; existing AAR subset already practically confirmed |
| `CAS` | `NewCAS(...)` / `NewCASENHANCED(...)` | `SUPPORTED`; final variant selection remains later-scope decision |
| `ISR` | `NewRECON(...)` | `SUPPORTED_FOR_RECON_EXECUTION`; sensor/INTEL effect remains separate |
| `CSAR` | `NewRESCUEHELO(...)` exists but is carrier-specific | `NOT_A_GENERIC_CSAR_MAPPING`; use MOOSE CSAR/AICSAR path |
| `AIRLIFT` | `NewTROOPTRANSPORT`, `NewCARGOTRANSPORT`, `NewFREIGHTTRANSPORT` | `SUPPORTED_BY_CARGO_SEMANTICS`; `NewOPSTRANSPORT` unavailable/commented out |
| `ESCORT` | `NewESCORT(...)` | `SUPPORTED` |

## 12. Ergebnis für Phase 2

Der Manifestpunkt

```text
AUFTRAG construction and mission types
```

ist für den Foundation-Scope source-seitig abgeschlossen.

Ergebnis:

```text
PASS_FOR_SOURCE_REVIEW
validated_in_dcs: false
```

Es wurde keine neue Nicht-MOOSE-Lücke festgestellt, die eine Eigenimplementierung rechtfertigt.

Die einzige wichtige negative API-Feststellung ist:

```text
AUFTRAG:NewOPSTRANSPORT(...)
= source text present
= implementation commented out
= not callable at this pinned embedded baseline
```

Die nächste Phase-2-Prüfung bleibt:

```text
Mission Assignment / Lifecycle / FSM callbacks
```

Dabei sind insbesondere die Übergänge von `COMMANDER`/`LEGION` zu `AUFTRAG`, die `OpsOnMission`-/`FlightOnMission`-/`ArmyOnMission`-Rückmeldungen sowie Completion/Failure/Cancellation gegen den eingebetteten Quellstand zu verifizieren.
