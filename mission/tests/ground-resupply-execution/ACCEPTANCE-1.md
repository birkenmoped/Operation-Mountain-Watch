---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local DCS acceptance plan for the first MissionDemand-driven physical Ground AMMO RESUPPLY vertical slice
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Ground AMMO RESUPPLY Acceptance 1 – Joyce nach Honaker

## 1. Ziel

```text
Honaker AMMO 40
-> test-only consumption 20
-> Honaker AMMO 20
-> ResourceDemandPolicy = REORDER
-> one RESUPPLY MissionDemand
-> CampaignState TRANSFER Joyce -> Honaker / 20
-> one protected LIGHT_06 convoy AMMOSUPPLY mission
-> physical arrival in Honaker ACCESS zone
-> CampaignState DELIVERED
-> Honaker AMMO 40
-> MissionDemand SUCCESS
-> complete convoy RTZ Joyce
-> Returned
-> Warehouse AddAsset / physical cleanup
```

Erwarteter strategischer Endzustand:

```text
JOYCE AMMO   44 -> 24
HONAKER AMMO 40 -> 20 -> 40
```

## 2. Strategische / operative Grenze

```text
CampaignState = alleinige strategische Ressourcen-/Cargo-Autorität
MissionDemand = Demand-/Assignment-Zustand
MOOSE BRIGADE / PLATOON / ARMYGROUP / AUFTRAG = physische Ausführung
DCS group = temporäre physische Repräsentation
```

`OPSTRANSPORT` wird in diesem Slice nicht verwendet.

Der physische Convoy definiert **keine** strategische Kapazität. Insbesondere ist aus diesem Test nicht abzuleiten:

```text
1 M1083 = X GROUND_AMMO_PACKAGE
TPL_BLUE_CONVOY_LIGHT_06 = X packages
TPL_BLUE_CONVOY_STANDARD_07 = Y packages
```

## 3. Physical template decision

Nach DCS-Lauf 2 hat der Projektinhaber entschieden, keine neuen Resupply-Templates anzulegen, sondern die bereits in der Mission vorhandenen Templates zu verwenden:

```text
TPL_BLUE_CONVOY_LIGHT_06
TPL_BLUE_CONVOY_STANDARD_07
```

Für Stage 1A gilt:

```text
TPL_BLUE_CONVOY_LIGHT_06
```

`TPL_BLUE_CONVOY_STANDARD_07` bleibt für eine spätere Kapazitäts-/Auswahlregel reserviert; diese Regel ist noch nicht definiert.

## 4. Physischer MOOSE-Vertrag

```text
BRIGADE:New(...)
PLATOON:New(TPL_BLUE_CONVOY_LIGHT_06, 1, ...)
PLATOON:AddMissionCapability(AUFTRAG.Type.AMMOSUPPLY, 100)
BRIGADE:AddPlatoon(...)
AUFTRAG:NewAMMOSUPPLY(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:AddMission(...)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die bereits owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird ausschließlich für road-aligned Materialisierung verwendet. Der Adapter unterstützt mehrgliedrige Templates und richtet die komplette Convoy-Gruppe entlang der Straße aus.

## 5. Delivery-/Settlement-Gate

Delivery ist fail-closed:

```text
OnAfterMissionExecute
AND exact Mission == acceptance AMMOSUPPLY mission
AND ARMYGROUP:IsInZone(ZON_BLUE_GND_HONAKER_ACCESS) == true
```

Erst danach:

```text
CampaignState MarkDelivered(TRANSFER_ID)
MissionDemand reservationState = DELIVERED
MissionDemand SUCCESS
```

`MissionDone` allein ist kein Liefernachweis.

## 6. Return-/Warehouse-Gate

Nach Delivery:

```text
MissionDone
-> explicit ARMYGROUP:RTZ(Joyce ACCESS, OnRoad)
-> Returned
-> MOOSE ARMYGROUP:onafterReturned
-> legion:__AddAsset(10, group, 1)
-> physical cleanup
```

Der gepinnte MOOSE-Source plant `AddAsset` 10 Sekunden nach `Returned`. Deshalb wird die finale Acceptance-Prüfung erst 12 Sekunden nach `Returned` ausgeführt.

Timeouts werden phasenbezogen geprüft:

```text
OUTBOUND_TIMEOUT_SEC = 1800
RETURN_TIMEOUT_SEC = 1800
```

Der Return-Timeout startet erst nach akzeptiertem RTZ. Der Outbound-Timeout wird nach bestätigter Delivery wirkungslos.

## 7. Bisherige DCS-Läufe

### Lauf 1 – FAIL vor physischer Ausführung

```text
MIZ: OMW_Template_v17.miz
reason: RESOURCE_DEMAND_POLICY_NO_CANDIDATE
root cause: stale embedded Ground production bundle without current 50%/25% thresholds
physical AMMOSUPPLY reached: no
```

Ergebnis:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-ammo-resupply-acceptance-1-fail-1.md
```

### Lauf 2 – FAIL mit bestätigter Delivery

```text
MIZ: OMW_Template_v18.miz
MIZ SHA-256: 2518A950CC36110552AA962179D5D8A4674F4C73E1518009706DAA79DBF92C09
internal mission SHA-256: A94F9F4D77245A0FA6E65B7E7657E5B8B3457CFD5FCB60A528F83EA57B563F34
DCS: 2.9.28.26385
Ground production bundle SHA-256: E616D35F5EBDBDDD4275785091D47F57445348D1FF4BB4CFBE7DEE0F0B12D78E
Acceptance bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
```

Praktisch bestätigt:

```text
ResourceDemand candidate
MissionDemand reservation
CampaignState transfer -> IN_TRANSIT
physical M1083 materialization
AUFTRAG AMMOSUPPLY
Honaker destination-zone proof
CampaignState DELIVERED
MissionDemand SUCCESS
MissionDone
RTZ accepted / RETURN_RTZ_ACTIVE
```

Nicht bestätigt:

```text
Returned
Warehouse AddAsset
physical cleanup
full roundtrip PASS
```

Harness-Ende:

```text
FAIL reason=TIMEOUT seconds=1800 ... returnedCount=0 addAssetCount=0
```

Der globale Timeout lief bereits seit Teststart und schnitt den Return-Pfad kurz nach RTZ ab. Das beweist keinen RTZ-Fehler.

Ergebnis:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-ammo-resupply-acceptance-1-fail-2.md
```

## 8. Nächster Build

Die Acceptance-Quelle ist jetzt auf folgende Änderungen umgestellt:

```text
physical template: TPL_BLUE_CONVOY_LIGHT_06
carrier entity: GROUND-RESUPPLY-JOYCE-HONAKER-CONVOY-LIGHT-001
outbound timeout: 1800 s
return timeout: 1800 s after accepted RTZ
final verification: 12 s after Returned
```

Builder:

```text
tools/build-ground-ammo-resupply-acceptance-1.ps1
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-4
```

Der neue Bundle-Hash ist erst nach owner-seitigem lokalen PowerShell-Build bekannt und darf nicht vorweggenommen werden.

## 9. Erwartete Runtime-Pflichtmarker des nächsten Laufs

```text
START testId=GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
DEMAND_RESERVED
PHYSICAL_EXECUTION_READY ... template=TPL_BLUE_CONVOY_LIGHT_06
BRIGADE_STARTED
MISSION_QUEUED type=AMMOSUPPLY ... template=TPL_BLUE_CONVOY_LIGHT_06
GROUP_MATERIALIZED ... template=TPL_BLUE_CONVOY_LIGHT_06
ARMY_ON_MISSION
DELIVERY_CONFIRMED
MISSION_DONE deliveryCommitted=true
RETURN_RTZ_ISSUED
RETURN_RTZ_ACTIVE
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS ... template=TPL_BLUE_CONVOY_LIGHT_06 ... returnedCount=1 warehouseAddAssetCount=1
```

Jeder `FAIL reason=...`, `OUTBOUND_TIMEOUT` oder `RETURN_TIMEOUT` macht den Lauf FAIL.

## 10. Nicht Teil dieses Gates

```text
package-per-truck capacity
automatic LIGHT_06 / STANDARD_07 selection
FUEL RESUPPLY
generic SUPPLY
multiple concurrent resupply demands
convoy under attack
CAS / BLUE COMMANDER
CSAR
real external process/server persistence
production orchestration scheduler
```

## 11. Aktueller Status

```text
Source review: UPDATED
DCS run 1: FAIL / stale Ground bundle
DCS run 2: FAIL / DELIVERY PATH CONFIRMED / RETURN CUT BY GLOBAL TIMEOUT
physical template decision: TPL_BLUE_CONVOY_LIGHT_06
acceptance source: UPDATED
builder: UPDATED TO -4
new local build: NOT RUN
new bundle hash: UNKNOWN UNTIL REAL BUILD
next MIZ: NOT YET CREATED
next DCS runtime: NOT RUN
Acceptance classification: NOT YET PASS
```
