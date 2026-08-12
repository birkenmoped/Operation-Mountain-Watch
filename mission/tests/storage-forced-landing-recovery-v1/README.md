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
COORDINATE:Get2DDistance()
SCHEDULER:New()
```

Für AIRWING-AI-Flüge bleiben die bereits source-reviewed FLIGHTGROUP-Pfade maßgeblich. Der Observer implementiert keinen eigenen Return-Controller.

Für Clients wird ein eigener read-only `TrackClientGroup()`-Pfad verwendet, weil Clients nicht über den produktiven AIRWING-Asset-Lifecycle laufen. Ein Land-Event mit passendem recovery-capable Airbase-`PlaceName` gilt als normaler erwarteter Return; ein Off-field-Land-Event ohne diesen Airbase-Bezug kann nach Engine-Shutdown als unerwartete Landung klassifiziert werden.

## 3. Bindende Policy

```text
Recovery envelope: 5000 m
Recovery delay: 1800 s
Repair lock: 21600 s
Low fuel <= 5%: supporting evidence only, not sole trigger
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
4. Off-field außerhalb des Airbase-Landepunkts, aber innerhalb 5 km des Shindand Heliport landen.
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

## 5. Grenzen

Der Gate mutiert weder CampaignState noch STORAGE und entfernt oder zerstört kein Aircraft. Er aktiviert noch keine automatische Recovery-Gutschrift und noch keinen Repair-Timer im produktiven CampaignState. CSAR ist ausdrücklich außerhalb dieses Testzyklus.

Ein PASS validiert die Erkennung/Klassifikation sowie die reine Policy-Zustandslogik. Erst danach darf die strategische Settlement-Integration für verbleibenden Fuel/Stores und Aircraft-Repair-Lock angeschlossen werden.

## 6. Build

```text
Builder:
tools/build-forced-landing-recovery-v1-gate.ps1

Bundle:
mission/tests/storage-forced-landing-recovery-v1/dist/OMW_Forced_Landing_Recovery_V1_Gate.lua

BuilderVersion:
FORCED-LANDING-RECOVERY-V1-GATE-1
```
