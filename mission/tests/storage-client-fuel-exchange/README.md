---
document_id: OMW-TEST-STORAGE-CLIENT-FUEL-EXCHANGE
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram F-16 client ground-crew fuel exchange observation gate
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-client-fuel-exchange
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# STORAGE Client Fuel Exchange

## Zweck

Dieser read-only Gate prueft, ob normale Ground-Crew-Aenderungen des F-16-Kraftstoffstands auf Bagram den nativen DCS/MOOSE-STORAGE-JETFUEL-Bestand konsistent veraendern. Der Test baut keinen Refuel-Pfad nach und mutiert weder STORAGE noch CampaignState.

## Basis

```text
base_branch: agent/storage-client-rearm-exchange
base_commit: ffe1943d46e04b9e4aca341ef2497dbde61576fd
base_status: ACCEPTED_TECHNICAL_BASELINE for the documented client-rearm scope
merged_to_main: false
inherited_risk: parent branch remains unmerged
```

Pinned MOOSE:

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## MOOSE-first Pfad

Verwendet werden ausschliesslich oeffentliche, im gepinnten `Moose.lua` vorhandene Lesepfade:

```text
AIRBASE:FindByName("Bagram")
AIRBASE:GetStorage()
STORAGE:FindByName("Bagram")
STORAGE:GetLiquidAmount(STORAGE.Liquid.JETFUEL)
SET_CLIENT:New()
SET_CLIENT:FilterCategories("plane")
SET_CLIENT:FilterTypes("F-16C_50")
SET_CLIENT:FilterStart()
SET_CLIENT:ForEachClient()
UNIT:GetCurrentFuelKgs() via CLIENT wrapper
SCHEDULER:New()
MESSAGE:New(...):ToAll()
```

`STORAGE:GetLiquidAmount()` liefert fuer Liquids kg. `UNIT:GetCurrentFuelKgs()` wird read-only fuer die physische Aircraft-Fuel-Telemetrie genutzt. Polling erfolgt alle zwei Sekunden und nur Aenderungen werden detailliert geloggt.

## Testablauf

Keine Triebwerksstarts, kein Taxi und kein Flug erforderlich. Nach `READY` und `CLIENT_BOUND` im Bagram-F-16-Client ueber das Ground-Crew-Bewaffnungs-/Fuel-Fenster nacheinander ungefaehr folgende Werte einstellen und jede Aenderung vollstaendig abschliessen lassen:

```text
100 % -> 50 % -> 80 % -> 30 % -> 100 %
```

Der exakte Prozentwert ist weniger wichtig als mehrere klare Reduktions- und Erhoehungsschritte.

## Zu beantwortende Fragen

1. Erhoeht eine Fuel-Reduktion am Client den Bagram-JETFUEL-Bestand?
2. Reduziert eine Fuel-Erhoehung am Client den Bagram-JETFUEL-Bestand?
3. Korrelieren STORAGE-Delta und physisches Aircraft-Fuel-Delta mengenmaessig?
4. Ist die Semantik bei wiederholtem Ab- und Auftanken konsistent?

## Erwartete Logmarker

```text
READY
CLIENT_BOUND
SNAPSHOT ... storageJetFuelKg=... aircraftFuelKg=...
DELTA ... storageJetFuelKg=... aircraftFuelKg=... combinedDeltaKg=...
RESULT ... status=OBSERVATION_COMPLETE
```

Der Harness klassifiziert keinen semantischen PASS/FAIL automatisch. Die Bewertung erfolgt nach dem realen DCS-Lauf anhand der beobachteten Delta-Sequenz.

## Grenzen

Nicht Teil dieses Gates:

- Weapon rearm;
- Flug-/Engine-Fuel-Verbrauch;
- AIRWING-Fuel-Lifecycle;
- CampaignState-Mutation oder Reconciliation;
- STORAGE-Mutation;
- Persistenz;
- eigener/native Refuel-Workaround.

## Build

```text
tools/build-storage-client-fuel-exchange.ps1
```

Erzeugtes Bundle:

```text
mission/tests/storage-client-fuel-exchange/dist/OMW_Storage_Client_Fuel_Exchange_Test.lua
```

Ein DCS-Lauf ist vor jeder `VALIDATED`- oder Acceptance-Einstufung erforderlich.
