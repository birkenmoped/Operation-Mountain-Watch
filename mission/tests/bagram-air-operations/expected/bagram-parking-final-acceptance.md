---
document_id: OMW-TEST-BAGRAM-PARKING-FINAL-ACCEPTANCE
status: PLANNED
document_class: DCS_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - final Bagram AIRWING/SQUADRON parking policy acceptance criteria
  - controlled physical materialization acceptance for all seven Bagram SQUADRONs
  - aggregate final gate before parking-policy merge decision
not_authoritative_for:
  - tactical mission completion
  - taxi, takeoff, landing or recovery behavior
  - persistence or CampaignState settlement
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/bagram-parking-policy-integration
source_commit: GIT_HISTORY
acceptance_branch: agent/bagram-parking-policy-integration
acceptance_commit: PENDING_FINAL_DCS_RUN
acceptance_mission: OMW_Template_v20_BGRM_Parking_Correlation_1.miz
acceptance_mission_sha256: PENDING_FINAL_MIZ_GATE
dcs_version: PENDING_FINAL_DCS_RUN
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
---

# Bagram Final Parking Acceptance

## Ziel

Dieser Vertrag definiert den einen abschließenden DCS-Lauf für die Bagram-Parking-Policy. Der Lauf bündelt die bereits einzeln untersuchten Teilbereiche in einem einzigen Testbundle und ergänzt den bisher fehlenden physischen Materialisierungsnachweis.

```text
TestID: BAGRAM-PARKING-FINAL-ACCEPTANCE-1
BuilderVersion: BGRAM-PARKING-FINAL-ACCEPTANCE-1
Bundle: mission/tests/bagram-air-operations/dist/OMW_AirOps_Bagram.lua
```

Der produktionsnahe Bagram-Foundation-Source bleibt unverändert. Der Builder hängt ausschließlich den Test-Harness an denselben generierten Testbundle an.

## MOOSE-First-Pfad

Verwendet werden ausschließlich im gepinnten MOOSE-Stand nachgewiesene öffentliche Pfade:

```text
AIRBASE:GetParkingSpotsTable()
COORDINATE:Get2DDistance()
AUFTRAG:NewALERT5(MissionType)
AUFTRAG:SetRequiredAssets(1, 1)
AUFTRAG:AssignSquadrons({ squadron })
AIRWING:AddMission(mission)
LEGION/AIRWING OnAfterOpsOnMission callback
SCHEDULER:New(...)
GROUP:FindByName()
GROUP:GetUnits()
UNIT:GetCoordinate()
```

`AUFTRAG:NewALERT5()` wird verwendet, weil der gepinnte Source den ALERT5-Pfad ausdrücklich als materialisierte, uncontrolled wartende Luftfahrzeuge beschreibt und in `LEGION` den Takeoff-Typ für ALERT5 auf Parking setzt. Es gibt keinen `SPAWN`-Pfad, keinen Native-DCS-Spawn, keinen MOOSE-Override, keinen COMMANDER und keinen OPSTRANSPORT.

## Finaler Scope

Der Lauf muss in einem Bundle und einer MIZ-Einbindung nachweisen:

```text
1. 187/187 Bagram TerminalID-Runtimebaseline vollständig und eindeutig
2. beide Warehouse-Anker vorhanden
3. sieben SQUADRON-Templates vorhanden und Gruppengröße korrekt
4. beide AIRWINGs RUNNING
5. 69 registrierte Foundation-Assets vorhanden
6. 69/69 Assets tragen exakt ihre SQUADRON parkingIDs
7. 44 AI-Pool-TerminalIDs eindeutig, vorhanden und nicht blacklisted
8. 10 Blacklist-TerminalIDs vorhanden und außerhalb aller AI-Pools
9. genau eine ALERT5-Assetgruppe je SQUADRON angefordert
10. sieben Gruppen physisch materialisiert
11. neun Units physisch materialisiert
12. jede Unit wird dem nächsten realen Bagram-Parking-Spot zugeordnet
13. jede Unit steht im eigenen SQUADRON-Pool
14. keine Unit steht auf einem anderen SQUADRON-Pool
15. keine Unit steht auf einer Blacklist-ID
16. keine Unit kann keinem realen Parking-Spot innerhalb 50 m zugeordnet werden
17. keine unerwartete Mission wird beobachtet
```

Die erwartete Materialisierung lautet:

```text
F-15E   1 x 2-ship = 2 Units
F-16C   1 x 2-ship = 2 Units
MQ-1A   1 x 1-ship = 1 Unit
C-130   1 x 1-ship = 1 Unit
HH-60G  1 x 1-ship = 1 Unit
UH-60   1 x 1-ship = 1 Unit
CH-47   1 x 1-ship = 1 Unit

Total: 7 groups / 9 units
```

## Erwartete Runtime-Marker

Foundation-/Lifecycle-Gates:

```text
PARKING_POLICY_PRESTART status=PASS blacklist=10 assignedAI=44
PARKING_POLICY_POSTSTART status=PASS assetsChecked=69 expectedAssets=69 failed=0 lifecycle=WAREHOUSE_NEWASSET
```

Finaler Harness:

```text
PARKING_RUNTIME_BASELINE status=PASS candidates=187 runtimeParkingSpots=187 runtimeUniqueTerminalIDs=187 runtimeDuplicateIDs=0 missingCandidates=0 unexpectedRuntimeIDs=0
OBJECT_CONTRACT status=PASS ... foundationAssets=69 foundationParkingChecked=69 foundationParkingFailed=0 ...
DISPATCH_BATCH status=QUEUED requested=7 expected=7
```

Für jede materialisierte Unit muss ein `PHYSICAL_PARKING`-Marker vorliegen. Der finale Aggregatmarker muss exakt die fachlichen Sollwerte erfüllen:

```text
BAGRAM_PARKING_FINAL_RESULT status=PASS reason=ALL_GATES_PASS foundationAssets=69 foundationParkingChecked=69 foundationParkingFailed=0 dispatchRequested=7 groupsMaterialized=7 unitsMaterialized=9 unitsParkingChecked=9 unitsInOwnPool=9 crossPoolViolations=0 blacklistViolations=0 unknownParking=0 unexpectedMissions=0 groupFailures=0
```

Jede andere Kombination ist `FAIL`.

## Vorherige Evidenz

Der erste Parking-Policy-Lauf mit Foundation-5 scheiterte ausschließlich am zu frühen Post-Start-Check (`assetsChecked=0`). Dieser Fehler wurde gegen den gepinnten MOOSE-Lifecycle analysiert und durch den öffentlichen `OnAfterNewAsset`-Callback korrigiert.

Der nachfolgende Foundation-6-Lauf vom 28.08.2026 beobachtete anschließend:

```text
PARKING_POLICY_POSTSTART status=PASS assetsChecked=69 expectedAssets=69 failed=0 lifecycle=WAREHOUSE_NEWASSET
parkingPolicy=PASS parkingAssetsChecked=69
```

Die vom Projektinhaber bereitgestellten unveränderlichen Runtime-Artefakte dieses Laufs besitzen:

```text
DCS log SHA-256: 41874509E8959A52B766091443F0F14E677BBC388D40BC97931DD86AB34B8E46
Debrief SHA-256: F6A3A24A0623CE12B21DF4B0D25067B5F9D341D6932614475D83B1BB017C14E4
DCS: 2.9.29.27278
Source commit: 2a0e8044543d42bf4ac9ff087bf3e6ff69d7d45f
Generated bundle SHA-256: 705B2EE891A990A686721B411BC0835A0F3FC500D7F3F82B9F9D0D1496186D0A
```

Dieser Lauf bleibt Evidenz für die korrekte ParkingID-Propagation. Er ersetzt nicht den hier definierten finalen Materialisierungs-PASS.

## Statische Freigabe vor dem letzten DCS-Lauf

Nach der finalen MIZ-Einbindung müssen vor DCS erneut dokumentiert sein:

```text
Branch / Commit
BuilderVersion
Builder-/Source-/Bundle-SHA-256
MIZ-SHA-256
interner mission-SHA-256
eingebetteter Bundle-SHA-256
eingebetteter Moose.lua-SHA-256
Objektvertragssmoke
Trigger-/Ressourcenpfad
keine parallele alte Parking-Correlation-Aktion
```

Ohne vollständigen statischen Gate-PASS wird der finale DCS-Lauf nicht gestartet.

## Abschlussgrenze

Ein finaler `PASS` validiert Bagram-Parking für den exakt dokumentierten Branch-/Commit-/MIZ-/DCS-/MOOSE-Stand bis einschließlich tatsächlicher physischer AI-Materialisierung auf den vorgesehenen SQUADRON-Pools.

Er validiert ausdrücklich nicht Taxi, Takeoff, taktische Missionsausführung, Landung, Recovery oder Persistenz. Diese Bereiche sind nicht Teil der Parking-Policy und blockieren bei einem Parking-PASS die Merge-Entscheidung dieses Branches nicht.

`PASS` erteilt weiterhin keine automatische Merge-Freigabe. Nach PASS werden Ergebnisbericht, README, Manifest/MOOSE-Dokumentation und PR-Status synchronisiert; Ready-for-Review beziehungsweise Merge bleiben eine ausdrückliche Entscheidung des Projektinhabers.
