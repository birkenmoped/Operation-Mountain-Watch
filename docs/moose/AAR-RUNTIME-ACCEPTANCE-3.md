---
document_id: OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-3
status: PLANNED
document_class: TECHNICAL_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE-first design of AAR-KC135-RUNTIME-ACCEPTANCE-3
  - existing Bagram F-16C AI Boom receiver path for this acceptance
  - owner-approved gate relocation candidates and materialization spacing rule
not_authoritative_for:
  - DCS runtime acceptance before the owner-run test
  - final production MissionDemand/CampaignState activation logic
  - final gate/map-edge clearance before DCS observation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# AAR Runtime Acceptance-3 – MOOSE-first Plan

## 1. Ausgangslage

Der Owner-Lauf von `AAR-KC135-RUNTIME-ACCEPTANCE-2` am 14.08.2026 bestätigte für den getesteten Fünf-Tanker-Stressstand plausible 90/96-%-Seed-Fuelwerte, `AUFTRAG:TANKER -> EXECUTING` für alle fünf, den vorgesehenen 180-s-Dwell, `FuelLow -> AUFTRAG:Cancel() -> Egress`, Gate-Eintritt innerhalb 10 NM sowie `OPSGROUP:Despawn(1, true)`. Die Racetrack-Flüge wurden visuell bestätigt.

Der Lauf war weiterhin eine Testausnahme. Die produktive Baseline bleibt:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Aus der visuellen Beobachtung folgen zusätzlich:

```text
same gate/domain minimum materialization separation = 60 s
different gate domains may materialize simultaneously
```

## 2. Gate-Kandidaten für Acceptance-3

```text
OMW_TANKER_GATE_S
old: N29.9818333333 E64.6116666667
candidate: N28.90264890 E64.61166667
approximate displacement: 120 km south

OMW_TANKER_GATE_NE
old: N38.1211666667 E70.3600000000
candidate: N37.64268794 E70.96231552
approximate displacement: 75 km southeast
```

Diese Koordinaten sind Testkandidaten. Sie werden erst durch den DCS-Lauf auf Spawn-/Ingress-/Egress-Nutzbarkeit und Sichtbarkeit geprüft.

## 3. Repräsentative Tanker

Acceptance-3 verwendet nur zwei bereits vorhandene Mission-Editor-Templates:

```text
CLANCY / OMW_AAR_KC135_CLANCY
Shell 1
241.600 AM
TACAN 60X / CLA
Gate domain SOUTH

NELSON / OMW_AAR_KC135_NELSON
Texaco 1
384.400 AM
TACAN 47X / NEL
Gate domain NORTH_EAST
```

Clancy und Nelson dürfen gleichzeitig materialisieren, weil sie unterschiedlichen Gate-Domänen angehören. Homer, Krusty und Patty werden in diesem fokussierten Lauf nicht gestartet.

## 4. Bestehender AI-Boom-Receiver

Es wird kein neues Mission-Editor-Template angelegt. Der vorhandene Bagram-Pfad wird wiederverwendet:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Das bestehende F-16C-CAS-Payload wird über den laufenden Bagram-AIRWING-/SQUADRON-Pfad rekrutiert. Ein Test-`AUFTRAG:NewCAS()` mit `WeaponHold` / `NoReaction` materialisiert den vorhandenen Assetpfad ohne künstliches Ziel.

## 5. Gepinnter MOOSE-Stand

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Zusätzlich zum bereits source-reviewten Tanker-/Fuel-/Egress-Pfad sind für Acceptance-3 im tatsächlich verwendeten `Moose.lua` geprüft:

- `AUFTRAG:NewCAS(ZoneCAS, Altitude, Speed, Coordinate, Heading, Leg, TargetTypes)`;
- `AUFTRAG:AssignSquadrons({squadron})`;
- `AUFTRAG:AddRequiredPayload(payload)`;
- `AUFTRAG:SetRequiredAssets(NassetsMin, NassetsMax)`;
- `AIRWING:AddMission(mission)` und der öffentliche `OnAfterFlightOnMission`-Callback;
- `FLIGHTGROUP:IsAirborne()`;
- `FLIGHTGROUP:Refuel(Coordinate)`;
- FSM `Refuel -> Going4Fuel -> Refueled`;
- `FLIGHTGROUP:OnAfterRefueled(...)`.

Der MOOSE-Refuel-Handler erzeugt den DCS-Refueling-Task intern. OMW implementiert keinen parallelen Native-DCS-Receivercontroller.

## 6. Acceptance-Sequenz

```text
CLANCY + NELSON spawn at relocated candidate gates
-> both AUFTRAG:TANKER reach EXECUTING
-> existing Bagram F-16C is recruited through AIRWING/SQUADRON/payload
-> once airborne and Clancy is EXECUTING: FLIGHTGROUP:Refuel(Clancy track coordinate)
-> positive OnAfterRefueled / AI_BOOM_REFUELED_PASS
-> arm tanker FuelLow 99% only after AI Boom proof
-> FuelLow -> AUFTRAG:Cancel() -> Mission Egress
-> <=10 NM relocated gate -> EGRESS_GATE_PASS -> OPSGROUP:Despawn(1, true)
```

Damit prüft derselbe fokussierte Lauf Boom-Refueling sowie die verlegten Gate-Kandidaten beim Ein- und Ausflug.

## 7. Manuelle Beobachtung

Der Projektinhaber prüft exemplarisch höchstens die zwei aktiven Tanker:

- Clancy: Funk 241.600 AM und TACAN 60X;
- Nelson: Funk 384.400 AM und TACAN 47X;
- Spawn-/Despawn-Sichtbarkeit der beiden neuen Gate-Kandidaten.

Der Boom-Transfer wird durch den KI-F-16C ausgeführt und über MOOSE-/DCS-Lifecycle und Fueltelemetrie nachgewiesen.

## 8. Grenzen

Nicht Teil dieses Acceptance-Harness sind:

- produktive MissionDemand-/CampaignState-Auswahl;
- produktive Implementierung des 60-s-Same-Domain-Staggerings;
- Tanker-Initial-Fuelübernahme über produktiven AIRWING-/WAREHOUSE-Assetpfad;
- endgültige Off-map-/CampaignState-Fuelbilanz;
- Persistenz und Missionsneustart.

`VALIDATED` bleibt an einen exakt dokumentierten Owner-DCS-Lauf mit Branch, Commit, MIZ-/Bundle-/MOOSE-Hashes und beobachtetem Ergebnis gebunden.
