---
document_id: OMW-TEST-STORAGE-FORCED-LANDING-RECOVERY-V1
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - forced-landing/recovery V1 runtime classification gate
  - client off-field landing observation within recovery envelope
  - pure recovery-delay and repair-lock policy verification
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/storage-forced-landing-recovery-v1
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/storage-resource-integration-final
base_commit: aec92c3574d338dba16aa0d615879e7de74e7f44
merged_to_main: false
---

# Forced Landing / Recovery V1 Gate

## 1. Zweck

Dieser Gate validiert nur die nach den bereits akzeptierten Warehouse-/STORAGE-Grundlagen noch offene Runtime-Frage: Erkennen die vorhandenen MOOSE-/DCS-Land- und Engine-Shutdown-Signale einen echten unerwarteten Client-Off-field-Landing-Fall so, dass die OMW-Recovery-Policy ihn innerhalb des 5-km-Recovery-Envelope korrekt als `RECOVERABLE_FORCED_LANDING` klassifiziert?

Nicht erneut getestet werden Materialisierung, normaler Return, Client-Rearm, Client-Refuel oder physischer Totalverlust.

## 2. MOOSE-First-Grenze

Der Observer verwendet ausschließlich öffentliche MOOSE-Pfade:

```text
EVENTHANDLER:New()
EVENTS.Land
EVENTS.EngineShutdown
GROUP:FindByName()
GROUP:IsAlive()
UNIT:GetCoordinate()
UNIT:GetFuel()
UNIT:IsAlive()
UNIT:InAir()
AIRBASE:FindByName()
AIRBASE:GetCoordinate()
AIRBASE:GetParkingSpotsTable()
COORDINATE:Get2DDistance()
SCHEDULER:New()
```

Für AIRWING-AI-Flüge bleiben die bereits source-reviewed FLIGHTGROUP-Pfade maßgeblich. Der Observer implementiert keinen eigenen Return-Controller.

Für Clients wird ein eigener read-only `TrackClientGroup()`-Pfad verwendet, weil Clients nicht über den produktiven AIRWING-Asset-Lifecycle laufen. Ein DCS/MOOSE-`PlaceName` allein ist **kein** ausreichender Nachweis für einen normalen Client-Return. Der erste Runtime-Lauf zeigte, dass ein Off-field-Landing noch 2223,6 m vom Shindand Heliport entfernt als `place=Shindand Heliport` gemeldet wurde.

Der korrigierte Client-Return-Nachweis verwendet deshalb die bereits in MOOSE vorhandene Parking-Semantik: `FLIGHTGROUP:GetParkingSpot(element, maxdist, airbase)` dokumentiert 5 m als Default-Distanzschwelle. Der OMW-Observer liest die öffentlichen `AIRBASE:GetParkingSpotsTable()`-Koordinaten und behandelt einen Client nur dann als `NORMAL_EXPECTED_RETURN`, wenn seine Position höchstens 5 m von einem Parking-Spot eines recovery-capable Nodes entfernt liegt.

Das ist kein eigener Parking-Lifecycle und keine DCS-Parallelimplementierung; es ist eine read-only Anwendung derselben source-reviewed MOOSE-Distanzgrenze auf Client-Gruppen, für die kein FLIGHTGROUP-`Arrived` existiert.

## 3. Bindende Policy

```text
Recovery envelope: 5000 m
Recovery delay: 1800 s
Repair lock: 21600 s
Low fuel <= 5%: supporting evidence only, not sole trigger
Client normal-return parking evidence: <= 5 m to a recovery-node parking spot
```

Der Gate prüft die 30-Minuten-/6-Stunden-Zustandsübergänge deterministisch mit synthetischen Zeitwerten. Es ist kein realer 30-Minuten-Warteversuch erforderlich.

## 4. Runtime-Fall

Verwendete Mission-Editor-Gruppe:

```text
CLIENT_US_SHND_AH64D_01
```

Recovery Node:

```text
Shindand Heliport
```

Ablauf:

```text
1. Mission mit gepinntem Moose.lua und dem Gate-Bundle starten.
2. CLIENT_US_SHND_AH64D_01 besetzen.
3. Vom Shindand Heliport abheben.
4. Off-field außerhalb des Parking-/Landepunkts, aber innerhalb 5 km des Shindand Heliport landen.
5. Engine-Shutdown durchführen.
6. dcs.log sichern.
```

Erwartete Marker:

```text
PLANNED_EXCLUSION_PASS
UNRECOVERABLE_POLICY_PASS
POLICY_TIMING_PASS recoverySeconds=1800 repairLockSeconds=21600
CLIENT_TRACKED group=CLIENT_US_SHND_AH64D_01
[OMW][ForcedLandingObserver] LAND_CANDIDATE mode=CLIENT_GROUP ... expectedReturn=false ...
[OMW][ForcedLandingObserver] CLASSIFIED mode=CLIENT_GROUP ... classification=RECOVERABLE_FORCED_LANDING ...
RECOVERABLE_RUNTIME_PASS ...
RESULT status=PASS campaignStateMutation=false storageMutation=false physicalMutation=false csar=false
```

## 5. Runtime-Versuch 1 vom 12.08.2026 – FAIL mit verwertbarer Evidenz

DCS:

```text
2.9.28.26385 MT
```

Verwendete Mission laut Debrief:

```text
OMW_Template_v8_AirOps_rdy.miz
```

Log-Provenienz:

```text
dcs.log SHA-256:     d33f7c46089a7284396272450c9de74c6bdb3cea010a9d2e4a71dfc1e31b2fae
debrief.log SHA-256: 9fda0649ae354b093b221cd8c6d541d8a034f80a179bc659ba3dd6a9155739f7
```

Der deterministische Policy-Teil bestand:

```text
PLANNED_EXCLUSION_PASS
UNRECOVERABLE_POLICY_PASS
POLICY_TIMING_PASS recoverySeconds=1800 repairLockSeconds=21600
CLIENT_TRACKED group=CLIENT_US_SHND_AH64D_01
```

Die reale Landung wurde mit folgenden Werten beobachtet:

```text
LAND_CANDIDATE
mode=CLIENT_GROUP
group=CLIENT_US_SHND_AH64D_01
place=Shindand Heliport
expectedReturn=true

CLASSIFIED
classification=NORMAL_EXPECTED_RETURN
recoveryNode=SHINDAND_HELIPORT
distanceM=2223.6182540257
```

Final:

```text
RESULT status=FAIL
reason=CLASSIFICATION
classification=NORMAL_EXPECTED_RETURN
expectedReturn=true
recoveryCapable=true
distanceM=2223.6182540257
```

### 5.1 Technische Interpretation

Der Lauf widerlegt die Annahme:

```text
DCS/MOOSE PlaceName == recovery-node airbase name
=> aircraft is physically back at that airbase
```

Für diesen exakten Lauf meldete DCS/MOOSE `Shindand Heliport` als `PlaceName`, obwohl die gemessene Aircraft-Position 2223,6 m vom Node-Zentrum entfernt lag und absichtlich off-field war.

Der Fehler liegt damit in der bisherigen OMW-Client-Klassifikation, nicht im 5-km-Recovery-Vertrag und nicht im Land-/EngineShutdown-Signalpfad. Land und EngineShutdown wurden erfolgreich beobachtet.

### 5.2 Korrektur

Die `PlaceName`-basierte Client-Return-Erkennung wurde entfernt. Ab dem Folgecommit gilt:

```text
CLIENT_GROUP normal expected return
-> recovery-capable AIRBASE resolve
-> public AIRBASE:GetParkingSpotsTable()
-> distance to nearest parking spot
-> <= 5 m => expected return
-> otherwise no expected-return evidence
```

Die 5-m-Grenze ist nicht frei erfunden. Sie entspricht dem dokumentierten Default von MOOSE `FLIGHTGROUP:GetParkingSpot(element, maxdist, airbase)` im gepinnten `Moose.lua`.

Der Runtime-Gate muss nach dieser Korrektur erneut ausgeführt werden. Der erste Lauf bleibt `FAIL` und darf nicht als Acceptance umetikettiert werden.

## 6. Grenzen

Der Gate mutiert weder CampaignState noch STORAGE und entfernt oder zerstört kein Aircraft. Er aktiviert noch keine automatische Recovery-Gutschrift und noch keinen Repair-Timer im produktiven CampaignState. CSAR ist ausdrücklich außerhalb dieses Testzyklus.

Ein PASS validiert die Erkennung/Klassifikation sowie die reine Policy-Zustandslogik. Erst danach darf die strategische Settlement-Integration für verbleibenden Fuel/Stores und Aircraft-Repair-Lock angeschlossen werden.

## 7. Build

```text
Builder:
tools/build-forced-landing-recovery-v1-gate.ps1

Bundle:
mission/tests/storage-forced-landing-recovery-v1/dist/OMW_Forced_Landing_Recovery_V1_Gate.lua

BuilderVersion:
FORCED-LANDING-RECOVERY-V1-GATE-1
```
