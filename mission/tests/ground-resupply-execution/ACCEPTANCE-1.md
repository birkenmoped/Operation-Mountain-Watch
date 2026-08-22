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
validated_in_dcs: false
---

# Ground AMMO RESUPPLY Acceptance 1 – Joyce nach Honaker

## 1. Ziel

Der Test prüft erstmals die vollständige Kette von einem autoritativen Ground-Ressourcenmangel bis zur physischen MOOSE-Lieferung und strategischen Gutschrift.

```text
Honaker AMMO 40
-> test-only consumption 20
-> Honaker AMMO 20
-> ResourceDemandPolicy = REORDER
-> one RESUPPLY MissionDemand
-> CampaignState TRANSFER Joyce -> Honaker / 20
-> one M1083 AMMOSUPPLY mission
-> physical arrival in Honaker ACCESS zone
-> CampaignState DELIVERED
-> Honaker AMMO 40
-> MissionDemand SUCCESS
-> M1083 RTZ Joyce
-> Warehouse AddAsset / physical cleanup
```

## 2. Verbindliche strategische Werte

Aus aktuellem `main`:

```text
GROUND_NODE_JOYCE / GROUND_AMMO_PACKAGE
initial/target = 44

GROUND_NODE_HONAKER / GROUND_AMMO_PACKAGE
initial/target = 40
reorder = 20
critical = 10
supplyParent = GROUND_NODE_JOYCE
```

Der Acceptance-Test erzeugt bewusst einen Consumption-Vorgang von 20 Einheiten bei Honaker. Das ist Testvorbereitung und keine behauptete reale Feuerverbrauchsmenge.

Erwarteter strategischer Endzustand:

```text
JOYCE AMMO   44 -> 24
HONAKER AMMO 40 -> 20 -> 40
```

## 3. Physischer MOOSE-Vertrag

```text
BRIGADE:New(...)
PLATOON:New(...)
PLATOON:AddMissionCapability(AUFTRAG.Type.AMMOSUPPLY, 100)
BRIGADE:AddPlatoon(...)
AUFTRAG:NewAMMOSUPPLY(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:AddMission(...)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die bekannte und owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird ausschließlich für straßenausgerichtete Materialisierung wiederverwendet. MOOSE behält Request-, Asset-, PLATOON-, ARMYGROUP- und AUFTRAG-Lifecycle.

## 4. Delivery- und Settlement-Gate

CampaignState darf erst gutgeschrieben werden, wenn:

```text
OnAfterMissionExecute
AND exact Mission == acceptance AMMOSUPPLY mission
AND ARMYGROUP:IsInZone(ZON_BLUE_GND_HONAKER_ACCESS) == true
```

Dann:

```text
CampaignState MarkDelivered(TRANSFER_ID)
MissionDemand reservationState = DELIVERED
MissionDemand SUCCESS
```

Ohne positiven Zonenbeweis ist der Test FAIL. `MissionDone` allein ist kein Liefernachweis.

## 5. Rückkehr

Nach bestätigter Lieferung wird die AMMOSUPPLY-Mission beendet. Danach:

```text
MissionDone
-> ARMYGROUP:RTZ(ZON_BLUE_GND_JOYCE_ACCESS, OnRoad)
-> OnAfterReturned
-> BRIGADE OnAfterAddAsset
-> physical group removed
```

## 6. Benötigter Mission-Editor-Vertrag

Vor Einbindung des Bundles müssen in der Arbeits-MIZ real bestätigt werden:

```text
WH_BLUE_GND_JOYCE
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
TPL_BLUE_GND_SUP_M1083
```

Zusätzlich muss die Produktions-Startup-Kette aktiv sein:

```text
Moose.lua
OMW_AirOps_Warehouse_Base.lua
OMW_Ground_Base.lua
```

und die MOOSE-USERFLAGs müssen vor Acceptance-Start den Wert `1` liefern:

```text
OMW_WAREHOUSE_READY
OMW_GROUND_READY
```

Dateinamen oder ältere MIZ-Acceptances ersetzen den Objektvertragssmoke der tatsächlich verwendeten Test-MIZ nicht.

## 7. Build-Provenienz

Builder:

```text
tools/build-ground-ammo-resupply-acceptance-1.ps1
```

BuilderVersion:

```text
GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-2
```

Ausgabe:

```text
mission/tests/ground-resupply-execution/dist/OMW_Ground_Ammo_Resupply_Acceptance_1.lua
```

Verwendete Source-Dateien:

```text
scripts/campaign/OMW_MissionDemand.lua
scripts/campaign/OMW_ResourceDemandPolicy.lua
scripts/ground/OMW_GroundRoadSpawnAdapter.lua
mission/tests/ground-resupply-execution/src/01-ground-ammo-resupply-acceptance.lua
```

MOOSE-Provenienz:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Lokaler Build und Bundle-Hash sind noch nicht ausgeführt beziehungsweise bekannt und dürfen erst nach realer Owner-Ausgabe eingetragen werden.

## 8. Erwartete Pflichtmarker

Mindestens:

```text
START testId=GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
DEMAND_RESERVED
PHYSICAL_EXECUTION_READY
BRIGADE_STARTED
MISSION_QUEUED type=AMMOSUPPLY
GROUP_MATERIALIZED
ARMY_ON_MISSION
DELIVERY_CONFIRMED
MISSION_DONE deliveryCommitted=true
RETURN_RTZ_ISSUED
RETURN_RTZ_ACTIVE
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS originFinal=24 destinationFinal=40 transferQuantity=20 demandStatus=SUCCESS spawnCount=1 returnedCount=1 warehouseAddAssetCount=1
```

Jeder `FAIL reason=...`-Marker macht den Lauf FAIL.

## 9. Nicht Teil dieses Gates

```text
FUEL RESUPPLY
generic SUPPLY
multiple concurrent resupply demands
convoy under attack
CAS / BLUE COMMANDER
CSAR
real external process/server persistence
production orchestration scheduler
```

## 10. Aktueller Status

```text
Source review: COMPLETE FOR THIS TEST SCOPE
Acceptance source: STAGED
Builder: STAGED
Local owner build: NOT RUN
Independent bundle hash: NOT AVAILABLE
MIZ object-contract smoke: NOT RUN
MIZ embedding: NOT STARTED
DCS runtime: NOT RUN
Acceptance classification: NOT_RUN
```

Der nächste Gate ist ausschließlich lokaler PowerShell-Build plus unabhängige SHA-256-Prüfung. Erst nach Rückgabe dieser realen Ausgabe wird die MIZ-Einbindung vorbereitet.
