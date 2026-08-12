---
document_id: OMW-MOOSE-STORAGE-CLIENT-FUEL-EXCHANGE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: MOOSE_TOPIC_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE-first client fuel exchange observation path
  - Bagram F-16 STORAGE JETFUEL exchange diagnostic boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-client-fuel-exchange
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_branch: agent/storage-client-fuel-exchange
acceptance_commit: 2b0dd9229708c2c159076c55e9fda5218d4bfc84
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: 118efea7a8bdd1e3b02fd8a6f2f4ac8c4557dc12a654738cd7421103bfff3a4c
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# MOOSE Client-Fuel-/STORAGE-Beobachtung

## Zweck

Dieses Dokument beschreibt den praktisch bestaetigten read-only MOOSE-Pfad fuer normalen Ground-Crew-Fuel-Exchange eines Bagram-F-16-Clients. Ziel ist nicht, Refuel nachzubauen, sondern die native DCS/STORAGE-Liquid-Semantik zu messen.

## Gepinnter Stand

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS 2.9.28.26385 MT
```

## Verwendete MOOSE-Methoden

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetLiquidAmount(STORAGE.Liquid.JETFUEL)
SET_CLIENT:New()
SET_CLIENT:FilterCategories()
SET_CLIENT:FilterTypes()
SET_CLIENT:FilterStart()
SET_CLIENT:ForEachClient()
UNIT:GetCurrentFuelKgs()
SCHEDULER:New()
MESSAGE:New(...):ToAll()
```

`STORAGE:GetLiquidAmount()` liefert den Bagram-JETFUEL-Bestand in kg. `UNIT:GetCurrentFuelKgs()` liefert ueber den CLIENT-Wrapper die physische Fuel-Masse des aktiven F-16C_50. Beide Pfade wurden im akzeptierten Lauf gegeneinander korreliert.

## Runtime-Evidenz 2026-08-12

```text
Branch: agent/storage-client-fuel-exchange
Acceptance/source commit: 2b0dd9229708c2c159076c55e9fda5218d4bfc84
BuilderVersion: STORAGE-CLIENT-FUEL-EXCHANGE-1
Mission path in debrief: OMW_Template_v8_AirOps_rdy.miz
Owner-supplied artifact: OMW_Template_v8_AirOps_rdy(5).miz
MIZ SHA-256: 118efea7a8bdd1e3b02fd8a6f2f4ac8c4557dc12a654738cd7421103bfff3a4c
Internal mission SHA-256: 406ed8b914aba3b546026abdf70bd6b626142a536d298e768fa1077140368371
Embedded/local bundle SHA-256: 60a94fb5d453be5f1292ddda66c0f81c44591ccecc9adbcd2ea1de110d3b45f8
DCS log SHA-256: 27ee2f2a7cdfe2e61e189b46e829bb79d6ca4888b7e217b45313b0a73edfa705
Debrief SHA-256: 66da0c308cfd3ec06abd47da1421327fdb03a859f17c0a8c1074842a1ec82938
```

Die Endpunkte der vier Fuel-Schritte waren:

```text
start:       aircraft 3247.721 kg | STORAGE 534769.328 kg
~50 percent: aircraft 1627.721 kg | STORAGE 536389.328 kg
~80 percent: aircraft 2595.721 kg | STORAGE 535421.328 kg
~30 percent: aircraft  977.721 kg | STORAGE 537039.328 kg
~100 pct:    aircraft 3245.721 kg | STORAGE 534771.328 kg
```

Daraus folgen die exakten gegenlaeufigen Endpunktdeltas:

```text
3247.721 -> 1627.721 aircraft: -1620 kg
534769.328 -> 536389.328 STORAGE: +1620 kg

1627.721 -> 2595.721 aircraft: +968 kg
536389.328 -> 535421.328 STORAGE: -968 kg

2595.721 -> 977.721 aircraft: -1618 kg
535421.328 -> 537039.328 STORAGE: +1618 kg

977.721 -> 3245.721 aircraft: +2268 kg
537039.328 -> 534771.328 STORAGE: -2268 kg
```

Damit ist fuer den dokumentierten Bagram-F-16-Scope praktisch bestaetigt:

```text
client fuel removal -> native STORAGE JETFUEL return
client fuel addition -> native STORAGE JETFUEL debit
mass correlation -> 1:1 at completed step endpoints
repeated cycles -> consistent
```

Die Poll-Telemetrie zeigte ueberwiegend exakte 40-kg-Gegenbuchungen. Kleinere zeitliche Poll-Versetzungen wurden in Folgesamples ausgeglichen; die Endpunktbilanz blieb erhalten.

## Architekturgrenze

```text
CampaignState = strategische Ressourcenautoritaet
DCS STORAGE = operative Liquid-Repräsentation und native Ground-Crew-Transaktion
physical client fuel = Runtime-Evidenz fuer die tatsaechliche Aircraft-Fuel-Masse
```

Aus dem Test ergibt sich fuer OMW:

```text
do not reimplement client refuel
```

Die spaetere produktive Aufgabe ist ein CampaignState-Adapter, der die native DCS/STORAGE-Transaktion beobachtet, gegen den strategischen Zustand reconciled und den strategischen Commit idempotent ausfuehrt. DCS/STORAGE wird dadurch nicht zur strategischen Ressourcenhoheit.

## Nicht uebertragene Aussagen

Nicht automatisch validiert sind:

- andere Flugzeugtypen oder Airbases;
- Unlimited-Liquid-Warehouses;
- laufender Engine-/Flugverbrauch;
- AAR;
- AI-Fuel-Lifecycle;
- CampaignState-Reconciliation und Persistenz;
- Restart-/Multiplayer-Semantik.

## Testende

Die Mission wurde nach Abschluss der Fuel-Sequenz manuell beendet. Letzter Snapshot: 20:15:37; `Dispatcher Stop`: 20:15:49. Daher wurde der 1800-s-Safety-Timeout nicht erreicht und kein finaler Harness-`RESULT`-Marker erzeugt. Die fuer die Acceptance erforderlichen mehrfachen Debit-/Return-Schritte und deren quantitative Korrelation waren vorher vollstaendig erfasst.

## Testreferenz

```text
mission/tests/storage-client-fuel-exchange/README.md
mission/tests/storage-client-fuel-exchange/src/01-storage-client-fuel-exchange.lua
tools/build-storage-client-fuel-exchange.ps1
```
