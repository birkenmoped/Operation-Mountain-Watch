---
document_id: OMW-TEST-SHINDAND-G2-AH64-DISPATCH-FAIL
status: TESTED_FAIL
document_class: MISSION_RUNTIME_TEST_RESULT
owning_policy: OMW-GOV-001
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/shindand-heliport-parking-diagnostic
validated_in_dcs: false
---

# Shindand G2 – AH-64 native AIRWING/AUFTRAG dispatch

## Ergebnis

Der isolierte native AIRWING/AUFTRAG-Dispatch wurde in DCS 2.9.28.26385 MT ausgeführt. Der Dispatch selbst funktionierte, der Test **bestand das Parking-Gate jedoch nicht**.

```text
Foundation: RUNNING
Commander: absent
OPSTRANSPORT: absent
Direct spawn: absent
CampaignState mutation: absent
Mission type: CAS
Required asset groups: 1
Assigned group: SQ_US_SHND_AH64D_ATTACK_AID-197
Assigned unit type: AH-64D_BLK_II
Flight state at observation: Parking
Observed nearest Shindand Heliport TerminalID: 41
Distance to TerminalID 41: 1.667 m
Owner-defined AH-64 TerminalIDs: 21,3,34,15
Parking allowed: false
G2 result: FAIL
```

Runtime marker:

```text
[OMW][AirOps.SHND.G2.AH64] FLIGHT_ON_MISSION group=SQ_US_SHND_AH64D_ATTACK_AID-197 missionType=CAS unitType=AH-64D_BLK_II terminalID=41 parkingAllowed=false distanceM=1.667 state=Parking
[OMW][AirOps.SHND.G2.AH64] FAIL Assigned AH-64 spawned outside owner-defined AH-64 parking pool: terminalID=41
```

Der spätere MOOSE-Marker `AUFTRAG ... CAS ... success!` belegt nur die AUFTRAG-Auswertung und hebt den zuvor festgestellten Parking-Verstoß nicht auf.

## Relevanter MOOSE-Quellbefund

Im tatsächlich gepinnten MOOSE-Stand 2.9.18 / Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54` gilt:

```text
SQUADRON:SetParkingIDs(...) setzt cohort.parkingIDs.
LEGION:onafterNewAsset(...) übernimmt cohort.parkingIDs nach asset.parkingIDs.
WAREHOUSE:_FindParkingForAssets(...) prüft asset.parkingIDs über _CheckParkingAsset(...).
```

Damit ist die Konfigurationskette im Quellcode vorhanden und war im Foundation-Lauf post-start ebenfalls synchron. Der DCS-Lauf zeigt trotzdem, dass die tatsächlich beobachtete AH-64-Position nicht dem owner-defined AH-64-Pool entsprach. Dieses Ergebnis ist als Runtime-Failure zu behandeln; aus dem Source-Contract darf keine tatsächliche Parking-Compliance abgeleitet werden.

## Artefaktprovenienz

```text
Source/Builder commit: 27e3877efdc1f76997b00593218e0d6390313ba5
BuilderVersion: SHND-G2-AH64-DISPATCH-3
G2 bundle SHA-256: 787cd3a54cacf7b3a4349bf8554d4124d778fe02607e680dc143474c24d0653f
MIZ SHA-256: b2dfdf00412e9318fc5635b49b9d6d590034b44d1db88ffbe44263e822471388
internal mission SHA-256: cff32c1a474aecd3aeb3859d1224da3f1a79ecf2bdaeb06d938ed2e3226eea89
embedded OMW_AirOps_Shindand.lua SHA-256: a7bd8a28ba9e72db2505a4237b6b5ea21465eba1ef09693cf6e6d461f8c6e2ea
embedded G2 bundle SHA-256: 787cd3a54cacf7b3a4349bf8554d4124d778fe02607e680dc143474c24d0653f
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: eb79bdc846203ce1b707794a7c9936e92b78604dbf6f15ff11b28f3b778efb61
debrief.log SHA-256: 73f7233d5ec19a8c841cd2e5588f9c1ae69f7da37428dfa062fb21186ecc9b88
DCS: 2.9.28.26385 MT
Test date: 2026-08-10
```

Debrief: `graveyard = {}`.

## Acceptance-Grenze

Bestätigt:

```text
- Shindand Foundation remained RUNNING
- direct AIRWING:AddMission(AUFTRAG) dispatch path executed without COMMANDER
- an AH-64D asset group was assigned
- the group existed in state Parking at FlightOnMission observation
```

Nicht akzeptiert:

```text
- actual AH-64 parking compliance
- actual vertical departure
- taxi/takeoff behavior
- recovery/landing
- persistence
```

## Nächste Architekturgrenze

Die vorhandene öffentliche MOOSE-Konfiguration `SQUADRON:SetParkingIDs()` darf für Shindand nicht als ausreichend validierte physische Parking-Enforcement-Lösung behandelt werden. Ein interner WAREHOUSE-Override, Native-DCS-Spawn oder andere Parallelimplementierung ist nach OMW-MOOSE-First nicht automatisch zulässig und benötigt eine gesonderte Projektinhaberentscheidung, falls die weitere MOOSE-Prüfung keine öffentliche Framework-Lösung ergibt.
