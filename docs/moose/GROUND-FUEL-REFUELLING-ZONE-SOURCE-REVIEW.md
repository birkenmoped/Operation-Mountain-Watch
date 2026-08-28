---
document_id: OMW-MOOSE-GROUND-FUEL-REFUELLING-ZONE-SOURCE-REVIEW
status: BINDING
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE source and runtime interpretation for Ground FUELSUPPLY one-shot execution
  - distinction between one-shot FUELSUPPLY and persistent BRIGADE refuelling services
not_authoritative_for:
  - strategic fuel authority outside CampaignState
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: dac19985de5ecae89b6948854e4a4bd5906f765b
validated_in_dcs: true
---

# Ground FUELSUPPLY – MOOSE Source Review

## 1. Geprüfter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Maßgeblich ist die tatsächlich verwendete `Moose.lua`.

## 2. One-Shot FUELSUPPLY

Der gepinnte Source bestätigt `AUFTRAG:NewFUELSUPPLY(Zone)` als direkten Ground-FUELSUPPLY-Auftrag. Für einen einzelnen strategischen CampaignState-Transfer ist dies die kleinste passende MOOSE-Abstraktion.

```text
AUFTRAG:NewFUELSUPPLY(destinationZone)
-> BRIGADE:AddMission(mission)
```

Build 2-3 bestätigte diesen Pfad praktisch einschließlich MissionExecute, CampaignState exact-once Delivery, MissionDemand SUCCESS, MOOSE ReturnToLegion, Returned und Warehouse AddAsset.

Akzeptierte Provenienz:

```text
Build commit: 2bd930729ed12a073f5364dc139281b60151acf0
BuilderVersion: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-3
Bundle SHA-256: 8CBDFA12B1A052517D82CB20A460CA665415353FE38ED2F1C50928BE6C7966A0
DCS: 2.9.28.26385 MT
Mission: OMW_Template_v19.miz
Executed MIZ SHA-256: 603422EFAFFA860041089D0F1AD41D35642A7863BC1C7B658E0B8F15A6EB63F2
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Maßgebliches Acceptance-Dokument:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-4.md
```

## 3. BRIGADE:AddRefuellingZone

Der gepinnte Source registriert mit `BRIGADE:AddRefuellingZone(...)` eine persistente Refuelling-Service-Zone. Der BRIGADE-Statuspfad erzeugt erneut `AUFTRAG:NewFUELSUPPLY(...)`, sobald die vorherige Mission over ist.

Build 2-2 bestätigte genau diese Semantik in DCS:

```text
FUELSUPPLY assigned
-> destination reached
-> delivery committed
-> MissionDone
-> replacement FUELSUPPLY generated
```

Daher gilt:

```text
BRIGADE:AddRefuellingZone for persistent service: VALID
BRIGADE:AddRefuellingZone for one-shot CampaignState transfer: NOT SUITABLE
```

## 4. OMW-Architekturgrenze

```text
CampaignState GROUND_FUEL_PACKAGE
= sole strategic resource authority

FUELSUPPLY / BRIGADE / PLATOON / ARMYGROUP / M978
= physical operational execution only
```

Nicht zulässig ist die Ableitung einer autoritativen CampaignState-Menge aus physischer M978-/DCS-/MOOSE-Fuel-Menge.

## 5. Praktisch bestätigter Methoden-Scope

```text
AUFTRAG:NewFUELSUPPLY(...)                              VALIDATED_FOR_DOCUMENTED_SCOPE
BRIGADE:AddMission(one-shot FUELSUPPLY)                VALIDATED_FOR_DOCUMENTED_SCOPE
FUELSUPPLY cancel -> MissionDone                       VALIDATED_FOR_DOCUMENTED_SCOPE
normal MOOSE Ground ReturnToLegion                     VALIDATED_FOR_DOCUMENTED_SCOPE
Returned -> Warehouse AddAsset                        VALIDATED_FOR_DOCUMENTED_SCOPE
BRIGADE:AddRefuellingZone persistent replacement      SOURCE_REVIEWED + DCS_OBSERVED
```

Die Validierung gilt ausschließlich für die dokumentierte Stage-1B2-Provenienz und den gepinnten MOOSE-Stand.
