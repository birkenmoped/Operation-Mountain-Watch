---
document_id: OMW-TEST-STORAGE-WEAPON-CONSUMPTION-CORRELATION-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_REPORT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS acceptance provenance for STORAGE-WEAPON-CONSUMPTION-CORRELATION-1
  - isolated Shindand AH-64D external-store warehouse debit correlation
  - observed AGM-114K, HYDRA_70_M151 and IAFS_ComboPak_100 deltas for the documented 2-ship payload action
not_authoritative_for:
  - M230 30-mm STORAGE mapping
  - GAU-8 30-mm STORAGE mapping
  - OH-58 M3P .50-cal STORAGE mapping
  - CampaignState debit or STORAGE mutation adapters
  - AIRWING payload accounting mutation
  - OPSTRANSPORT, CTLD, persistence, restart or multiplayer reconciliation
  - Shindand type-specific parking acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-weapon-consumption-correlation
source_commit: 4844c4fab70e1227e6e96a70b8747cc12238190d
validated_in_dcs: true
base_branch: agent/ammunition-exact-item-mapping
base_commit: e93b0ad022a6ba6c32d2899ac24bdabb80615008
base_status: BINDING_CHILD_BRANCH
merged_to_main: false
inherited_risk:
  - parent mapping contract and resource-ID decision are not yet merged to main
---

# STORAGE Weapon Consumption Correlation – Acceptance

## 1. Testidentitaet

```text
Test ID: STORAGE-WEAPON-CONSUMPTION-CORRELATION-1
Branch: agent/storage-weapon-consumption-correlation
Source/Builder commit: 4844c4fab70e1227e6e96a70b8747cc12238190d
BuilderVersion: STORAGE-WEAPON-CONSUMPTION-CORRELATION-1
Base branch: agent/ammunition-exact-item-mapping
Base commit: e93b0ad022a6ba6c32d2899ac24bdabb80615008
DCS: 2.9.28.26385 MT
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

## 2. Artefakt-Provenienz

```text
Executed MIZ: OMW_Template_v8_AirOps_rdy.miz
Uploaded executed-copy SHA-256: abfaff193ac3618d2e0e3414d0ffd88f51f009c5b4b7f35f3ba8350459207093
Internal mission SHA-256: 28fd89a1ac9c3556d97bb438a90ec9db6c47f60d6550e241ad904173b06c5819
Embedded correlation bundle: l10n/DEFAULT/OMW_Storage_Weapon_Consumption_Correlation_Test.lua
Embedded correlation bundle SHA-256: 1fe44ed294784563a358148fb0463b6ce93fb7c8bbd506de1c43128a361cd729
Local build correlation bundle SHA-256: 1fe44ed294784563a358148fb0463b6ce93fb7c8bbd506de1c43128a361cd729
Embedded isolated action harness: l10n/DEFAULT/OMW_AirOps_Shindand_G2_AH64_Dispatch.lua
Embedded isolated action harness SHA-256: 787cd3a54cacf7b3a4349bf8554d4124d778fe02607e680dc143474c24d0653f
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS log SHA-256: 45e9d0e1f3a74ba8cbf33829ec27835334412db3089a0ad94c25ebff7755093d
Debrief SHA-256: 88fa0088298c510ed7136655b41a53f1c8b23d2a789336d0bd8935462df499e3
```

Die ausgefuehrte Mission enthaelt den gepinnten MOOSE-Stand, das lokal gebaute Korrelationsbundle bit-identisch sowie den isolierten Shindand-G2-AH-64-Aktionsharness.

## 3. Isolierter Runtime-Ablauf

Der relevante zweite Lauf innerhalb des DCS-Logs zeigte:

```text
13:41:33  correlation TEST_BEGIN
13:41:44  BASELINE_PASS
13:41:55  ACTION_WINDOW_OPEN
13:41:57  Shindand foundation begins
13:42:09  Shindand foundation RUNNING
13:42:20  G2 MISSION_PREPARED + DISPATCH_REQUEST
13:42:59  three SHINDAND_HELIPORT WEAPON_DELTA records
13:43:03  G2 FLIGHT_ON_MISSION
13:43:15  ACTION_WINDOW_CLOSE, deltasObserved=3
13:43:25  FINAL_SNAPSHOT + correlation PASS
```

Es wurde fuer diesen Korrelationsscope genau die isolierte G2-AH-64-CAS-Aktion ausgeloest. Die fruehere Shindand-FinalFoundation mit zusaetzlichen UH-60-/CH-47-Dispatches war in diesem Lauf nicht aktiv.

## 4. Beobachtete Warehouse-Deltas

Am einzigen betroffenen Endpoint `SHINDAND_HELIPORT` wurden innerhalb des offenen Action Window genau drei Deltas beobachtet:

```text
weapons.droptanks.{IAFS_ComboPak_100}
100 -> 98
delta = -2

weapons.nurs.HYDRA_70_M151
100 -> 24
delta = -76

weapons.missiles.AGM_114K
100 -> 96
delta = -4
```

An den anderen sechs beobachteten STORAGE-Endpunkten wurde kein Weapon-Inventory-Delta protokolliert.

Die Shindand-AH-64-SQUADRON verwendet `grouping=2` und das Template `TPL_AIR_US_SHND_AH64D_CAS_2SHIP`. `SetRequiredAssets(1,1)` fordert damit eine SQUADRON-Assetgruppe an, die zwei AH-64D repraesentiert. Die beobachteten Deltas entsprechen daher der Materialisierung einer einzelnen 2-Ship-Assetgruppe und nicht einem einzelnen Luftfahrzeug.

## 5. Korrigierte Mengeninterpretation

Die vor dem Lauf formulierte Erwartung `-38 M151 / -2 AGM-114K / -1 ComboPak` war fuer die konkrete Shindand-SQUADRON-Konfiguration falsch, weil sie ein einzelnes Luftfahrzeug statt einer `grouping=2`-Assetgruppe zugrunde legte.

Der Runtime-Befund ist konsistent mit der dokumentierten 2-Ship-Payload:

```text
per AH-64D:
38 x HYDRA_70_M151
2 x AGM_114K
1 x IAFS_ComboPak_100

per materialisierter 2-Ship-Assetgruppe:
76 x HYDRA_70_M151
4 x AGM_114K
2 x IAFS_ComboPak_100
```

Damit ist fuer diesen exakten DCS-/MOOSE-/Mission-/Payload-Stand die External-Store-Debit-Korrelation technisch bestaetigt.

## 6. Harness-Ergebnis

```text
RESULT testId=STORAGE-WEAPON-CONSUMPTION-CORRELATION-1 status=PASS nodesExpected=7 nodesReady=7 deltasObserved=3 mutation=false campaignStateMutation=false opstransport=false ctld=false
```

Der Korrelationsharness hat keine STORAGE- oder CampaignState-Mutation ausgefuehrt.

## 7. Parking-Fehler ist ausserhalb dieses Acceptance-Scopes

Der historische G2-Harness meldete nach der Materialisierung:

```text
FLIGHT_ON_MISSION ... terminalID=41 parkingAllowed=false
FAIL Assigned AH-64 spawned outside owner-defined AH-64 parking pool
```

Dieser Befund ist kein Fehler des Weapon-Correlation-Gates. Die Shindand-Foundation-Dokumentation hat type-specific parking enforcement bereits als Foundation-Acceptance-Kriterium ausgeschlossen. Fuer den hier akzeptierten Scope ist entscheidend, dass genau die dokumentierte AH-64-Aktion materialisiert wurde und die Warehouse-Deltas waehrend des Action Window eindeutig beobachtbar waren.

Der Parking-Befund darf aus dieser Acceptance nicht als behoben oder validiert abgeleitet werden.

## 8. Nicht bewiesen

Weiterhin nicht bewiesen sind:

```text
M230/M789 direct STORAGE debit or item mapping
GAU-8 direct STORAGE debit or item mapping
OH-58 M3P container-to-round semantics
unused-store return/recredit semantics
rearm-after-return semantics
CampaignState-to-STORAGE weapon mutation
AIRWING payload debit/replenishment coupling
OPSTRANSPORT / CTLD resupply
persistence / restart / multiplayer reconciliation
```

Insbesondere wurde fuer `AMMUNITION_30MM_M230` trotz AH-64-Materialisierung kein zusaetzlicher Warehouse-Item-Delta beobachtet. Es wird daher weiterhin kein Shell-/Gunmount-Key als direkter M230-Mirror angenommen.

## 9. Akzeptierter technischer Schluss

Fuer den exakt dokumentierten Stand gilt:

```text
AMMUNITION_ROCKETS_70MM
  -> OMW AH-64D CAS variant proven runtime debit item:
     weapons.nurs.HYDRA_70_M151

AMMUNITION_HELLFIRE
  -> OMW AH-64D CAS variant proven runtime debit item:
     weapons.missiles.AGM_114K

AH-64D IAFS store
  -> proven runtime debit item:
     weapons.droptanks.{IAFS_ComboPak_100}

AMMUNITION_30MM_M230
  -> NO_DIRECT_STORAGE_MIRROR_YET
```

Diese Acceptance beweist die konkrete Warehouse-Buchung der getesteten OMW-AH-64D-CAS-Payload. Sie genehmigt noch keine strategische CampaignState-Verbrauchsautomatik.