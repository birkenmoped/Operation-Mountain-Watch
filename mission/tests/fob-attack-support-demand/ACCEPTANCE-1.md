---
document_id: OMW-STAGE-2-FOB-ATTACK-THREAT-ACCEPTANCE-1
status: VALIDATED_FOR_DOCUMENTED_SCOPE
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 DCS acceptance for MOOSE OPSZONE perimeter-threat qualification
  - Fortress runtime 1000 m security perimeter and PASS criteria
  - use of the existing OMW mission runtime stack
not_authoritative_for:
  - infantry casualty / survivor-return / restart settlement
  - CAS aircraft dispatch
  - general attack severity classification
  - production-wide OPSZONE cadence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Stage 2 Acceptance-1 requirement for real RED-on-BLUE EVENTS.Hit
  - dedicated TST_BLUE_GND_FORTRESS_HIT_TARGET Acceptance-1 target plan
  - standalone Acceptance-1 CampaignState/GroundBase bootstrap plan
  - dedicated Fortress patrol-test-zone dependency for the Sentry guard point
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
validated_in_dcs: true
---

# Stage 2 – FOB Attack Threat Acceptance 1

## 1. Ergebnis

```text
PASS
```

Der reale DCS-Lauf am 2026-08-29 bestätigte den korrigierten Stage-2-Vertrag:

```text
existing Moose.lua
-> existing OMW_AirOps_Warehouse_Base.lua
-> existing OMW_Ground_Base.lua
-> existing mission GroundBase.Attach(...)
-> Stage 2 Acceptance bundle
-> commit 9 Fortress GROUND_PERSONNEL
-> MOOSE BRIGADE / PLATOON / Warehouse materialization
-> TPL_BLUE_GND_INF_RIFLE_SQUAD_9
-> derive guard/security anchor from WH_BLUE_GND_FORTRESS via BRIGADE/WAREHOUSE:GetCoordinate()
-> AUFTRAG:NewONGUARD(...)
-> runtime ZONE_RADIUS(..., 1000 m)
-> BLUE OPSZONE
-> real RED ground presence inside perimeter while BLUE presence remains
-> OPSZONE OnAfterAttacked(..., RED)
-> CAS_IMMEDIATE MissionDemand
-> exactly one active CAS demand
-> PASS
```

Ein physischer Treffer auf BLUE war nicht erforderlich. Der Alarmzustand entstand bereits bei feindlicher Bodenpräsenz im Sicherheitsperimeter.

## 2. Runtime-Sicherheitsperimeter

```text
anchor        = WH_BLUE_GND_FORTRESS via BRIGADE/WAREHOUSE:GetCoordinate()
zone name     = OMW_SECURITY_BLUE_GROUND_COP_FORTRESS
radius        = 1000 m
owner         = BLUE
objects       = UNIT only
units         = GROUND_UNIT only
attack RED    = Nred > 0
threatlevel   = 0
captureNunits = 1 (separate capture semantics)
scan interval = 5 s (Acceptance only)
F10 draw      = off
F10 marker    = off
```

`ZON_BLUE_GND_FORTRESS_ACCESS` wurde nicht als Security-Perimeter wiederverwendet. Eine zusätzliche Mission-Editor-Security-Zone war nicht erforderlich.

## 3. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im Acceptance-Scope verwendet und jetzt runtime-validiert:

```text
BRIGADE / LEGION / WAREHOUSE
WAREHOUSE:GetCoordinate()
PLATOON / COHORT
AUFTRAG:NewONGUARD(...)
ARMYGROUP / OPSGROUP mission lifecycle
ZONE_RADIUS:New(name, Vec2, radius)
OPSZONE:New(zone, coalition.side.BLUE)
OPSZONE:SetObjectCategories(...)
OPSZONE:SetUnitCategories(...)
OPSZONE:SetCaptureThreatlevel(...)
OPSZONE:SetCaptureNunits(...)
OPSZONE:SetDrawZone(false)
OPSZONE:SetMarkZone(false)
OPSZONE.UpdateSeconds = 5 before Start()
OPSZONE:Start()
OPSZONE OnAfterAttacked(..., AttackerCoalition)
OPSZONE:Stop()
SCHEDULER:New(...)
```

## 4. Fortress-Sentry und CampaignState

Der bestehende gemeinsame CampaignState blieb strategische Autorität. Der Acceptance-Harness verbrauchte exakt neun Fortress-Personnel:

```text
node: GROUND_NODE_FORTRESS
resource: GROUND_PERSONNEL
quantity: 9
before: 160
after commit: 151
transaction: STAGE2-A1-FORTRESS-SENTRY-PERSONNEL
```

Materialisiert wurde das vorhandene Template:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
7 x Soldier M4
2 x Soldier M249
```

Die Sentry war kein spezielles Hit-Ziel. Sie stellte reale lokale BLUE-Ground-Präsenz bereit, damit die BLUE-owned OPSZONE den verteidigten `Attacked`-Pfad verwenden konnte.

## 5. Reale Log-Evidenz

Im DCS-Log wurde folgende Kette beobachtet:

```text
SENTRY_ON_MISSION group=PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A1_AID-219
SENTRY_ONGUARD_EXECUTING group=PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A1_AID-219 warehouse=WH_BLUE_GND_FORTRESS
OPSZONE OMW_SECURITY_BLUE_GROUND_COP_FORTRESS | Starting OPSZONE v0.6.2
[FobThreatOpsZoneAdapter] started MOOSE OPSZONE security perimeter zone=OMW_SECURITY_BLUE_GROUND_COP_FORTRESS radiusM=1000 owner=2 updateSeconds=5 threatlevel=0 captureNunits=1
READY targetGroup=PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A1_AID-219 installationId=BLUE_GROUND_COP_FORTRESS personnelCommitted=9 guardMission=ONGUARD guardSource=warehouse-coordinate securityZone=OMW_SECURITY_BLUE_GROUND_COP_FORTRESS securityRadiusM=1000 detection=OPSZONE_ATTACKED scanSeconds=5
QUALIFIED_THREAT count=1 installationId=BLUE_GROUND_COP_FORTRESS zone=OMW_SECURITY_BLUE_GROUND_COP_FORTRESS radiusM=1000 evidence=OPSZONE_ATTACKED
DEMAND_RESULT threat=1 incidentId=INC-STAGE2-A1|BLUE_GROUND_COP_FORTRESS|PERIMETER|1 demandId=MD-CAS-FOB-ATTACK|INC-STAGE2-A1|BLUE_GROUND_COP_FORTRESS|PERIMETER|1 created=true reason=nil
PASS qualifiedThreats=1 activeDemands=1 demandId=MD-CAS-FOB-ATTACK|INC-STAGE2-A1|BLUE_GROUND_COP_FORTRESS|PERIMETER|1 missionType=CAS_IMMEDIATE installationId=BLUE_GROUND_COP_FORTRESS sentryGroup=PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A1_AID-219 personnelCommitted=9 personnelBefore=160 personnelAfterCommit=151 securityRadiusM=1000 detection=OPSZONE_ATTACKED
OPSZONE OMW_SECURITY_BLUE_GROUND_COP_FORTRESS | Stopping OPSZONE
```

## 6. Getestete Acceptance-LUA

```text
Datei:
OMW_FOB_Attack_Threat_Acceptance_1.lua

Verzeichnis:
P:\DCS-DEV\Operation-Mountain-Watch-fob-attack-support-demand\mission\tests\fob-attack-support-demand\dist\

Vollständiger Pfad:
P:\DCS-DEV\Operation-Mountain-Watch-fob-attack-support-demand\mission\tests\fob-attack-support-demand\dist\OMW_FOB_Attack_Threat_Acceptance_1.lua
```

## 7. Provenienz

```text
Tested source commit:
e3bc977e35ab3a06a5417124684250ae50a15a8b

BuilderVersion:
FOB-ATTACK-THREAT-ACCEPTANCE-1-2

Acceptance bundle SHA-256:
9A3382BF0EE476ED105A5EEF56575C73EBE591AAA00C1C4B1DA7A55F27835650

DCS version:
2.9.29.27278

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

dcs.log SHA-256:
8C8821ABDD412258A1B2ABF18FC9AA8018767E80894B174DAFE982513B3D2B2D

debrief.log SHA-256:
081FE758DAE40933F011CE8156364BAC5EF40C13247150999F7CACE2159FD227

Owner-supplied MIZ artifact:
OMW_Template_v20_GroundWorks(10).miz

Owner-supplied MIZ artifact SHA-256:
54E6562A095E771721E417CC8F5AEE0606066EA619E9E72D462E402A6D3EC118

Runtime debrief mission path:
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v20_GroundWorks.miz

Result:
PASS
```

Die Dateinamensabweichung zwischen dem hochgeladenen MIZ-Artefakt und dem Runtime-Pfad aus dem Debrief wird bewusst unverändert dokumentiert. Der angegebene MIZ-Hash gehört zum vom Projektinhaber nach dem Lauf bereitgestellten Artefakt; aus dem Dateinamen allein wird keine zusätzliche Identität abgeleitet.

## 8. Validierter Scope

Validiert ist ausschließlich:

```text
shared CampaignState / GroundBase context
Fortress PERSONNEL commitment 160 -> 151
BRIGADE / PLATOON / Warehouse materialization
AUFTRAG ONGUARD local-security squad
Warehouse-derived installation anchor
runtime ZONE_RADIUS 1000 m
BLUE OPSZONE
UNIT / GROUND_UNIT filtering
captureThreatlevel = 0 for this defended-zone alarm path
Acceptance-only UpdateSeconds = 5
OPSZONE OnAfterAttacked callback
RED Ground presence -> qualified threat
qualified threat -> exactly one CAS_IMMEDIATE MissionDemand
```

Nicht durch diesen Lauf validiert:

```text
CAS dispatch through AUFTRAG / COMMANDER / AIRWING / SQUADRON
production OPSZONE scan cadence
generalized capture/ownership behavior
other installations beyond Fortress
persistent threat-incident lifecycle across restart
```

Der detaillierte Ergebnisnachweis liegt zusätzlich in `mission/tests/fob-attack-support-demand/RESULT-1.md`.