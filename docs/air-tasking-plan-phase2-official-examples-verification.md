---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-OFFICIAL-EXAMPLES-VERIFICATION
status: DRAFT
document_class: MOOSE_CAPABILITY_VERIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase-2 review of official MOOSE example combinations required by Air Tasking
  - branch-local evidence for COMMANDER/AIRWING/SQUADRON and BRIGADE/PLATOON mission combinations
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS runtime acceptance
  - APIs not source-verified against the embedded Moose.lua baseline
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Phase 2 – Official MOOSE Examples Verification

## 1. Zweck

Diese Prüfung erfüllt den MOOSE-first-Schritt, die für OMW tatsächlich benötigten Klassenkombinationen gegen offizielle MOOSE-Demo-/Testmissionen zu prüfen.

Die Source-Baseline für APIs bleibt die tatsächlich in `OMW_Template_v12_groundworks.miz` eingebettete `Moose.lua`:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Offizielle Beispielquelle:

```text
FlightControl-Master/MOOSE_MISSIONS_UNPACKED
branch: develop
```

Die Beispiele dienen zur Bestätigung von Konstruktorreihenfolge, Zusammenspiel der Klassen und Event-Nutzung. Sie ersetzen nicht die Source-Prüfung der eingebetteten `Moose.lua`.

## 2. AIRWING / SQUADRON / AUFTRAG

Offizielle Demo:

```text
OPS - Airwing/
Airwing - 010 - Fighter Wing/
Airwing - 010 - Fighter Wing.lua
```

Die Demo verwendet nachweislich:

```text
SQUADRON:New(...)
SQUADRON:AddMissionCapability(...)
AIRWING:New(...)
AIRWING:AddSquadron(...)
AIRWING:NewPayload(...)
AIRWING:Start()
AUFTRAG:NewCAP(...)
AUFTRAG:NewBAI(...)
AUFTRAG:SetRepeatOnFailure(...)
AIRWING:AddMission(...)
AIRWING:OnAfterFlightOnMission(...)
```

Die Demo beschreibt zudem ausdrücklich die native Auswahl nach Squadron-Capability/Performance und Payload-Verfügbarkeit/-Performance.

Für OMW bestätigt das die vorgesehene MOOSE-first-Kombination:

```text
SQUADRON capability
→ AIRWING registration / payload availability
→ AUFTRAG
→ AIRWING:AddMission(...)
→ FLIGHTGROUP runtime
→ FlightOnMission callback
```

Die Demo beweist **keine** OMW-strategische Ressourcenautorität. CampaignState bleibt für OMW Reservation/Settlement maßgeblich.

## 3. BRIGADE / PLATOON / AUFTRAG

Offizielle Demo:

```text
OPS - Brigade/
Brigade - 010 - Patrol Mission/
Brigade - 010 - Patrol Mission.lua
```

Die Demo verwendet nachweislich:

```text
PLATOON:New(...)
PLATOON:AddMissionCapability(...)
BRIGADE:New(...)
BRIGADE:AddPlatoon(...)
BRIGADE:Start()
AUFTRAG:NewPATROLZONE(...)
AUFTRAG:SetDuration(...)
AUFTRAG:SetRepeat(...)
AUFTRAG:SetRequiredAssets(...)
BRIGADE:AddMission(...)
BRIGADE:OnAfterArmyOnMission(...)
```

Damit ist die native Ground-Kombination bestätigt:

```text
PLATOON capability
→ BRIGADE registration
→ AUFTRAG
→ native asset assignment
→ ARMYGROUP runtime
→ ArmyOnMission callback
```

Auch hier ist kein paralleler OMW-Ground-Mission-Dispatcher erforderlich.

## 4. COMMANDER / mehrere AIRWINGs / AUFTRAG

Offizielle Demo:

```text
OPS - Commander/
Commander - 020 - Bombing with Airwings/
Commander - 020 - Bombing with Airwings.lua
```

Die Demo verwendet drei getrennte `AIRWING`-Instanzen unter einem `COMMANDER` und bestätigt:

```text
SQUADRON:New(...)
SQUADRON:AddMissionCapability(...)
AIRWING:New(...)
AIRWING:NewPayload(...)
AIRWING:AddSquadron(...)
COMMANDER:New(coalition.side.BLUE)
COMMANDER:AddAirwing(...)
COMMANDER:__Start(1)
AUFTRAG:NewBOMBING(...)
AUFTRAG:SetRequiredAssets(2, 6)
AUFTRAG:SetRepeatOnFailure(...)
COMMANDER:AddMission(...)
COMMANDER:OnAfterOpsOnMission(...)
```

Die Demo beschreibt ausdrücklich, dass der COMMANDER benötigte Assets aus mehreren Airwings rekrutiert, wenn ein einzelner Wing den Bedarf nicht decken kann.

Für OMW bestätigt das:

```text
COMMANDER
= native operative Aggregations-/Rekrutierungsschicht über mehreren LEGIONs
```

Daraus folgt gerade **nicht**, dass OMW eine zweite Asset-Allokationsengine benötigt. OMW muss lediglich vor der MOOSE-Zuweisung seine strategischen Authority-/Reservation-Regeln erfüllen.

## 5. Mission-Lifecycle-Callbacks

Die offiziellen Beispiele bestätigen auch die zuvor source-geprüften Runtime-Hooks praktisch als vorgesehene Framework-Nutzung:

```text
AIRWING:OnAfterFlightOnMission(...)
BRIGADE:OnAfterArmyOnMission(...)
COMMANDER:OnAfterOpsOnMission(...)
```

Damit ist die event-driven Korrelation von OMW-Execution-Attempts mit MOOSE-`FLIGHTGROUP`/`ARMYGROUP` ein framework-native Ansatz. Ein globaler DCS-Gruppenscan ist dafür nicht erforderlich.

## 6. Missionsarten

Für die OMW-Missionstypen wurden die Konstruktoren bereits separat gegen die eingebettete `Moose.lua` source-geprüft. Die offiziellen Beispiele werden hier **nicht** künstlich auf jede OMW-Missionsart erweitert.

Bestätigte Foundation-Aussage:

```text
AAR     -> AUFTRAG NewTANKER source-verified; bestehender OMW-AAR-Scope separat DCS-bestätigt
CAS     -> NewCAS / NewCASENHANCED source-verified
ISR     -> NewRECON source-verified for recon execution
CSAR    -> NewRESCUEHELO is not generic downed-aircrew CSAR; dedicated MOOSE CSAR/AICSAR path remains relevant
AIRLIFT -> TROOP/CARGO/FREIGHT transport constructors by cargo semantics; NewOPSTRANSPORT not callable in pinned source
ESCORT  -> NewESCORT source-verified
```

Nicht für jede dieser Konstruktorvarianten wurde im Rahmen dieses Foundation-Punkts eine eigene offizielle Demo benötigt oder gefunden. Wo kein passendes Beispiel herangezogen wurde, bleibt ausschließlich die bereits dokumentierte Source-Verifikation maßgeblich.

## 7. Ergebnis für Phase 2

Der Manifestpunkt

```text
official examples for required class combinations
```

ist abgeschlossen.

Ergebnis:

```text
PASS_FOR_SOURCE_AND_OFFICIAL_EXAMPLE_REVIEW
validated_in_dcs: false
```

Offizielle MOOSE-Beispiele bestätigen die benötigten Framework-Kombinationen für:

```text
SQUADRON -> AIRWING -> AUFTRAG -> FLIGHTGROUP
PLATOON -> BRIGADE -> AUFTRAG -> ARMYGROUP
COMMANDER -> multiple AIRWINGs -> AUFTRAG -> OPSGROUP
```

Es wurde kein Grund gefunden, diese Kombinationen durch eine OMW-eigene Command-/Asset-Dispatcher-Engine zu ersetzen.
