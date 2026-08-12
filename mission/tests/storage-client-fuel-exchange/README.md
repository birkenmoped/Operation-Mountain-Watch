---
document_id: OMW-TEST-STORAGE-CLIENT-FUEL-EXCHANGE
status: ACCEPTED_TECHNICAL_BASELINE
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
validated_in_dcs: true
acceptance_branch: agent/storage-client-fuel-exchange
acceptance_commit: 2b0dd9229708c2c159076c55e9fda5218d4bfc84
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: 118efea7a8bdd1e3b02fd8a6f2f4ac8c4557dc12a654738cd7421103bfff3a4c
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
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

## Akzeptierter DCS-Lauf 2026-08-12

```text
Acceptance branch: agent/storage-client-fuel-exchange
Acceptance/source commit: 2b0dd9229708c2c159076c55e9fda5218d4bfc84
BuilderVersion: STORAGE-CLIENT-FUEL-EXCHANGE-1
DCS: 2.9.28.26385 MT
Mission path in debrief: OMW_Template_v8_AirOps_rdy.miz
Owner-supplied executed mission artifact uploaded as: OMW_Template_v8_AirOps_rdy(5).miz
MIZ SHA-256: 118efea7a8bdd1e3b02fd8a6f2f4ac8c4557dc12a654738cd7421103bfff3a4c
Internal mission SHA-256: 406ed8b914aba3b546026abdf70bd6b626142a536d298e768fa1077140368371
Embedded/local fuel-test bundle SHA-256: 60a94fb5d453be5f1292ddda66c0f81c44591ccecc9adbcd2ea1de110d3b45f8
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS log SHA-256: 27ee2f2a7cdfe2e61e189b46e829bb79d6ca4888b7e217b45313b0a73edfa705
Debrief SHA-256: 66da0c308cfd3ec06abd47da1421327fdb03a859f17c0a8c1074842a1ec82938
```

Der Harness meldete `READY` und band `CLIENT_US_BGRM_F16_01_UNIT_01` als F-16C_50-Client. Initial wurden `534769.328 kg` Bagram-JETFUEL und `3247.721 kg` physischer Aircraft-Fuel erfasst.

Die vier beabsichtigten Ground-Crew-Schritte wurden praktisch beobachtet. Die Prozentwerte ergeben sich nur aus dem initialen Fuel-Mass-Wert als 100-%-Referenz und dienen der Zuordnung zu den eingestellten Zielwerten:

| Schritt | Aircraft Fuel | Aircraft Delta | Bagram JETFUEL | STORAGE Delta | Befund |
|---|---:|---:|---:|---:|---|
| Start | 3247.721 kg | - | 534769.328 kg | - | Baseline |
| ca. 50 % | 1627.721 kg | -1620 kg | 536389.328 kg | +1620 kg | Fuel-Reduktion vollstaendig an STORAGE zurueckgebucht |
| ca. 80 % | 2595.721 kg | +968 kg | 535421.328 kg | -968 kg | Fuel-Erhoehung vollstaendig aus STORAGE abgebucht |
| ca. 30 % | 977.721 kg | -1618 kg | 537039.328 kg | +1618 kg | zweite Fuel-Reduktion vollstaendig zurueckgebucht |
| ca. 100 % | 3245.721 kg | +2268 kg | 534771.328 kg | -2268 kg | zweite Fuel-Erhoehung vollstaendig aus STORAGE abgebucht |

Der finale Zustand liegt 2 kg unter der initialen Aircraft-Fuel-Masse und entsprechend 2 kg ueber dem initialen STORAGE-Bestand. Damit bleibt die kombinierte Fuel-Masse ueber den gesamten Ablauf erhalten. Die laufenden Poll-Deltas lagen ueberwiegend bei exakt `+40/-40 kg` bzw. `-40/+40 kg`; auch kleinere Abschlussdeltas blieben gegenlaeufig. Einzelne Poll-Paare von `-42/+40`, `-40/+42`, `-40/+38` wurden in den unmittelbar folgenden Samples ausgeglichen und aendern die Endpunktbilanz nicht.

## Akzeptierter Befund

```text
client fuel reduction -> Bagram STORAGE JETFUEL increase: PASS
client fuel increase -> Bagram STORAGE JETFUEL decrease: PASS
quantitative mass correlation across completed exchange steps: PASS
repeated decrease/increase semantics: PASS
STORAGE mutation by harness: false
CampaignState mutation by harness: false
custom/native refuel workaround: not required by this gate
```

Architekturfolge fuer den dokumentierten Bagram-F-16-Scope:

```text
do not reimplement client refuel

DCS ground-crew fuel exchange
-> native DCS/STORAGE liquid transaction
-> later CampaignState observation/reconciliation
-> strategic commit by CampaignState
```

Der Test belegt die native DCS/STORAGE-Exchange-Semantik fuer den dokumentierten Bagram-F-16-Client-Stand. Er belegt nicht automatisch andere Flugzeugtypen, Unlimited-Liquid-Warehouses, AAR, laufenden Engine-Fuel-Verbrauch oder produktive CampaignState-Reconciliation.

## Harness-Ende

Die Mission wurde nach Abschluss der beobachteten Zielsequenz manuell beendet. Der letzte Fuel-Snapshot erfolgte um 20:15:37, DCS `Dispatcher Stop` um 20:15:49. Der 1800-s-Safety-Timeout wurde daher nicht erreicht und der Harness emittierte keinen finalen `RESULT ... OBSERVATION_COMPLETE`-Marker. Dies ist als Testablaufgrenze dokumentiert; die benoetigten mehrfachen Debit-/Return-Sequenzen und die quantitative Endpunktkorrelation waren vor Missionsende vollstaendig beobachtet.

## Grenzen

Nicht Teil dieser Acceptance:

- Weapon rearm; dieser Scope ist separat in `OMW-TEST-STORAGE-CLIENT-REARM-EXCHANGE` dokumentiert;
- Flug-/Engine-Fuel-Verbrauch;
- AIRWING-Fuel-Lifecycle;
- AAR-Fuel-Accounting;
- CampaignState-Mutation oder produktive Reconciliation;
- Persistenz und Restart-Reconciliation;
- andere Aircraft-Typen oder Airbases als der dokumentierte Bagram-F-16-Scope;
- Unlimited-Liquid-Semantik.

## Build

```text
tools/build-storage-client-fuel-exchange.ps1
```

Erzeugtes Bundle:

```text
mission/tests/storage-client-fuel-exchange/dist/OMW_Storage_Client_Fuel_Exchange_Test.lua
```

Der akzeptierte Runtime-Nachweis gehoert zum Bundle aus Commit `2b0dd9229708c2c159076c55e9fda5218d4bfc84` mit SHA-256 `60a94fb5d453be5f1292ddda66c0f81c44591ccecc9adbcd2ea1de110d3b45f8`. Ein spaeterer Neubau ist ein neues Artefakt und erbt diesen Hash nicht automatisch.
