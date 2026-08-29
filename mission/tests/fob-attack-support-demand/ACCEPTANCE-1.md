---
document_id: OMW-STAGE-2-FOB-ATTACK-THREAT-ACCEPTANCE-1
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 DCS acceptance plan for MOOSE OPSZONE perimeter-threat qualification
  - Fortress runtime 1000 m security perimeter and PASS criteria
  - use of the existing OMW mission runtime stack
not_authoritative_for:
  - runtime validation before the documented DCS run
  - infantry casualty / survivor-return / restart settlement
  - CAS aircraft dispatch
  - general attack severity classification
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Stage 2 Acceptance-1 requirement for real RED-on-BLUE EVENTS.Hit
  - dedicated TST_BLUE_GND_FORTRESS_HIT_TARGET Acceptance-1 target plan
  - standalone Acceptance-1 CampaignState/GroundBase bootstrap plan
  - dedicated Fortress patrol-test-zone dependency for the Sentry guard point
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 – FOB Attack Threat Acceptance 1

## 1. Ziel

Der Test bestätigt den korrigierten Stage-2-Vertrag gegen den bereits in der aktuellen OMW-Testmission vorhandenen Runtime-Stack:

```text
existing Moose.lua
-> existing OMW_AirOps_Warehouse_Base.lua
   -> authoritative OMW.AirOps.CampaignContext
   -> OMW_WAREHOUSE_READY = 1
-> existing OMW_Ground_Base.lua
-> existing mission GroundBase.Attach(...) trigger
   -> same OMW.AirOps.CampaignContext
   -> OMW_GROUND_READY = 1
-> Stage 2 Acceptance bundle
   -> commit 9 Fortress GROUND_PERSONNEL
   -> MOOSE BRIGADE / PLATOON / Warehouse materialization
   -> TPL_BLUE_GND_INF_RIFLE_SQUAD_9
   -> derive guard/security anchor from WH_BLUE_GND_FORTRESS via BRIGADE/WAREHOUSE:GetCoordinate()
   -> AUFTRAG:NewONGUARD(...)
   -> runtime ZONE_RADIUS(..., 1000 m)
   -> BLUE OPSZONE
   -> real RED ground presence inside perimeter
   -> OPSZONE OnAfterAttacked(..., RED)
   -> CAS_IMMEDIATE MissionDemand
   -> exactly one active CAS demand
   -> PASS
```

Ein physischer Treffer auf BLUE ist **nicht** mehr Voraussetzung. Der Alarmzustand soll bereits bei feindlicher Bodenpräsenz im Sicherheitsperimeter entstehen.

## 2. Produktions- und Autoritätsgrenze

Die bereits eingebettete Warehouse Production Base bleibt Besitzer des gemeinsamen autoritativen CampaignState-Kontexts:

```text
OMW.AirOps.CampaignContext
```

`OMW_Ground_Base.lua` erzeugt keinen zweiten Store. Die aktuelle Testmission führt bereits den erforderlichen Attach aus:

```lua
OMW.Ground.Base.Attach({
  store = OMW.AirOps.CampaignContext.store,
  campaignState = OMW.AirOps.CampaignContext.campaignState,
  restored = OMW.AirOps.CampaignContext.restored == true,
})
```

Der Stage-2-Harness verlangt nur einen aktiven `OMW.Ground.Base.GetContext()` und erzeugt keine zweite strategische Autorität.

## 3. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Für diesen Acceptance-Scope source-verifiziert:

```text
BRIGADE:New(...)
LEGION -> WAREHOUSE inheritance
WAREHOUSE:GetCoordinate()
PLATOON:New(...)
COHORT:AddMissionCapability(AUFTRAG.Type.ONGUARD, ...)
LEGION:AddMission(...)
AUFTRAG:NewONGUARD(...)
AUFTRAG:SetReturnToLegion(false)
BRIGADE OnAfterArmyOnMission
ARMYGROUP OnAfterMissionExecute
ZONE_RADIUS:New(name, Vec2, radius)
OPSZONE:New(zone, coalition.side.BLUE)
OPSZONE:SetObjectCategories(...)
OPSZONE:SetUnitCategories(...)
OPSZONE:SetCaptureThreatlevel(...)
OPSZONE:SetCaptureNunits(...)
OPSZONE:SetDrawZone(false)
OPSZONE:SetMarkZone(false)
OPSZONE:Start()
OPSZONE OnAfterAttacked(..., AttackerCoalition)
SCHEDULER:New(...)
```

Der gepinnte Source zeigt außerdem: Bei BLUE-owned OPSZONE führt RED-Präsenz mit ausreichendem Threat-Level zum Zustand `Attacked`, solange BLUE-Präsenz in der Zone verbleibt. Ohne BLUE-Präsenz läuft stattdessen der Capture-Pfad. Deshalb bleibt die reale Fortress-Sentry als lokale BLUE-Sicherung Bestandteil des Acceptance-Aufbaus.

## 4. Runtime-Sicherheitsperimeter

Der Sicherheitsperimeter wird vollständig zur Laufzeit erzeugt:

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

Für den verteidigten BLUE-Zustand prüft MOOSE `Nred > 0` und den Threat-Level. `captureNunits=1` gehört zur separaten Capture-Logik, falls die BLUE-Präsenz verschwindet; es ist nicht das eigentliche Attacked-Kriterium.

Damit ist keine zusätzliche Mission-Editor-Security-Zone erforderlich.

`ZON_BLUE_GND_FORTRESS_ACCESS` bleibt unverändert. Sie wird nur weiterhin für die validierte Ground-Materialisierung genutzt. Nach der Ground-Baseline ist ACCESS eine Materialisierungs-/Departure-/Return-/Handoff-Grenze und nicht die Installationsgeometrie.

## 5. Bestehende Mission-Editor-Objekte

Erforderlich:

```text
WH_BLUE_GND_FORTRESS
ZON_BLUE_GND_FORTRESS_ACCESS
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

Nicht erforderlich:

```text
ZON_BLUE_GND_FORTRESS_SECURITY
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
TST_BLUE_GND_FORTRESS_HIT_TARGET
zusätzliche BLUE-Testgruppe
```

Das Rifle-Squad-Template bleibt:

```text
7 x Soldier M4
2 x Soldier M249
```

## 6. Stage-2-Bundle

Builder:

```text
tools/build-fob-attack-threat-acceptance-1.ps1
```

Output:

```text
mission/tests/fob-attack-support-demand/dist/OMW_FOB_Attack_Threat_Acceptance_1.lua
```

Der Builder enthält ausschließlich:

```text
OMW_MissionDemand.lua
OMW_FobAttackDemandPolicy.lua
OMW_FobThreatOpsZoneAdapter.lua
01-fob-attack-threat-acceptance-1.lua
```

Kein CampaignState wird erzeugt; GroundBase wird nicht ersetzt; die bestehende Mission bleibt unverändert.

## 7. Fortress-Sentry und PERSONNEL

Der Acceptance-Harness reserviert/consumed genau:

```text
node: GROUND_NODE_FORTRESS
resource: GROUND_PERSONNEL
quantity: 9
transaction: STAGE2-A1-FORTRESS-SENTRY-PERSONNEL
```

Bei frischem Produktionskontext entspricht dies `160 -> 151`; das eigentliche Runtime-Kriterium bleibt `before - 9`.

Danach materialisiert MOOSE:

```text
BRIGADE alias: BDE_BLUE_GND_FORTRESS_STAGE2_A1
PLATOON alias: PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A1
Template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
Mission: OMW_STAGE2_A1_FORTRESS_SENTRY
Mission type: AUFTRAG ONGUARD
Guard point: WH_BLUE_GND_FORTRESS runtime coordinate
```

Die Sentry ist jetzt **kein spezielles Hit-Ziel**. Sie stellt reale lokale BLUE-Präsenz im Installationsbereich her und hält damit die OPSZONE im verteidigten Zustand.

## 8. Historische Hit-Versuche

Die bisherigen Läufe am 2026-08-29 bleiben diagnostische Evidenz für den verworfenen Hit-Vertrag:

```text
- Warehouse-basierter Guard-Punkt funktionierte.
- 9 Fortress PERSONNEL wurden korrekt committed.
- BRIGADE/PLATOON/ONGUARD und dynamische Sentry funktionierten bis READY.
- Ein realer Feuerkampf entstand.
- Ein exakter RED-on-dynamic-Sentry EVENTS.Hit war nicht zuverlässig reproduzierbar.
```

Diese Ergebnisse erhöhen den neuen OPSZONE-Scope nicht auf `VALIDATED`. Sie erklären nur, warum `EVENTS.Hit` nicht länger als notwendiges Alarmkriterium verwendet wird.

## 9. Runtime-Ablauf

Vor der Bedrohungsqualifikation müssen im `dcs.log` insbesondere erscheinen:

```text
PERSONNEL_COMMITTED ... quantity=9
SENTRY_QUEUED ... warehouse=WH_BLUE_GND_FORTRESS guardSource=warehouse-coordinate
SENTRY_ON_MISSION ...
SENTRY_ONGUARD_EXECUTING ... warehouse=WH_BLUE_GND_FORTRESS
[FobThreatOpsZoneAdapter] started MOOSE OPSZONE security perimeter ...
READY ... securityZone=OMW_SECURITY_BLUE_GROUND_COP_FORTRESS securityRadiusM=1000 detection=OPSZONE_ATTACKED scanSeconds=5
```

Danach genügt reale RED-Bodenpräsenz innerhalb von 1000 m um den Fortress-Warehouse-Anker.

Erwartung:

```text
MOOSE OPSZONE sees RED ground presence while BLUE sentry remains in zone
-> OPSZONE Attacked(RED)
-> QUALIFIED_THREAT count=1
-> DEMAND_RESULT ... created=true reason=nil
-> PASS ... activeDemands=1 missionType=CAS_IMMEDIATE installationId=BLUE_GROUND_COP_FORTRESS
```

Kein Schuss und kein Treffer sind erforderlich.

## 10. PASS-Kriterien

Alle müssen gleichzeitig gelten:

```text
1. Die bestehende Mission erreicht OMW_WAREHOUSE_READY=1 und OMW_GROUND_READY=1.
2. Stage 2 verwendet den bereits attached OMW Ground CampaignState-Kontext; kein zweiter Store wird erzeugt.
3. Genau 9 Fortress GROUND_PERSONNEL werden committed/consumed.
4. TPL_BLUE_GND_INF_RIFLE_SQUAD_9 wird über MOOSE BRIGADE/PLATOON/Warehouse materialisiert.
5. Guard-/Security-Anker wird aus WH_BLUE_GND_FORTRESS über BRIGADE/WAREHOUSE:GetCoordinate() abgeleitet.
6. Die Sentry erreicht AUFTRAG ONGUARD und bleibt als BLUE Ground presence im Perimeter.
7. Zur Laufzeit entsteht `OMW_SECURITY_BLUE_GROUND_COP_FORTRESS` als ZONE_RADIUS mit 1000 m Radius.
8. Daraus entsteht eine BLUE-owned OPSZONE mit UNIT/GROUND_UNIT-Scan und `captureThreatlevel=0`; für den Attacked-Pfad gilt `Nred > 0`.
9. Keine Mission-Editor-Security-Zone wird benötigt.
10. Reale RED Ground presence innerhalb des Perimeters löst `OnAfterAttacked(..., coalition.side.RED)` aus.
11. Dieser Threat erzeugt genau einen CAS_IMMEDIATE Demand für BLUE_GROUND_COP_FORTRESS.
12. Genau ein aktiver Fortress-CAS-Demand verbleibt.
13. Kein EVENTS.Hit/Shot wird für die Qualifikation benötigt.
14. Kein CAS-AUFTRAG/COMMANDER/AIRWING/SQUADRON-Dispatch wird ausgeführt.
15. Kein world.addEventHandler/MIST/MissionScripting.lua-Pfad wird verwendet.
16. dcs.log enthält den expliziten PASS-Eintrag.
```

Der `active_duplicate`-Vertrag für wiederholte Threat-Incidents wird zusätzlich durch die MissionDemand-/Adapter-CI geprüft; Acceptance 1 verlangt keinen künstlich erzeugten zweiten physischen Treffer.

## 11. Vorbereiteter lokaler Build – 2026-08-29

Der Projektinhaber hat den Remote-Stand erfolgreich per Fast-Forward in den vorgesehenen Worktree gezogen und den Stage-2-Threat-Acceptance-Bundle lokal gebaut.

Dokumentierte reale Konsolenausgabe:

```text
branch: agent/fob-attack-support-demand
GitCommit: 43e728e1a80ae8e36d62bcc29101c67c38e38db3
BuilderVersion: FOB-ATTACK-THREAT-ACCEPTANCE-1-2
TestId: FOB-ATTACK-THREAT-ACCEPTANCE-1
GeneratedUtc: 2026-08-29T19:52:34Z
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
BundleSHA256: E51C997A869E0972EC106B7C8DF2914D0C06958B3352B1FB3B1FD9E831ED74F3
```

Der externe `Get-FileHash`-Aufruf bestätigte denselben Bundle-Hash:

```text
E51C997A869E0972EC106B7C8DF2914D0C06958B3352B1FB3B1FD9E831ED74F3
```

Zusätzliche lokale Source-Hashes aus demselben Build:

```text
scripts/campaign/OMW_MissionDemand.lua
E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848

scripts/campaign/OMW_FobAttackDemandPolicy.lua
F1BB5041382823B8B4DD6EE2EA6418B38C834C3347FBAAD633F8F24DA1A07FF5

scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
C53BE08B5F0ABCEA8DF3FADDA9EA41E2FEBAACA34FED1B3D1D195F63E0D6650D

mission/tests/fob-attack-support-demand/src/01-fob-attack-threat-acceptance-1.lua
C979A41892320006DB83A2965A41BBC52203877479F611B30085D4CB6FC791FE
```

Dieser Abschnitt dokumentiert ausschließlich die reale Build-Provenienz. Er ist **kein** DCS-Runtime-PASS und ändert `validated_in_dcs: false` nicht.

Der lokale Worktree enthielt vor dem Pull bereits untracked Bereiche:

```text
mission/ground-operations/
mission/tests/fob-attack-support-demand/dist/
```

Diese wurden nicht als Branch-Inhalt interpretiert und durch den Fast-Forward nicht als validierte Repository-Artefakte übernommen.

## 12. Provenienz nach realem DCS-Lauf

Erst nach realem DCS-PASS werden zusätzlich dokumentiert:

```text
Git commit
BuilderVersion
Stage-2-Bundle SHA-256
MIZ filename + SHA-256
DCS version
MOOSE commit + Moose.lua SHA-256
dcs.log SHA-256
debrief.log SHA-256, soweit erzeugt
Result
```

Bis dahin bleibt `PLANNED` / `validated_in_dcs: false`.
