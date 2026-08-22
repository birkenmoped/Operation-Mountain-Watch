---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-FAIL-2
status: TEST_RESULT
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS result of Stage-1A Ground AMMO RESUPPLY runtime attempt 2 on 2026-08-22
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground AMMO RESUPPLY Acceptance 1 – Lauf 2 – FAIL mit bestätigter Delivery

## 1. Provenienz

```text
TestId: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
MIZ: OMW_Template_v18.miz
MIZ SHA-256: 2518A950CC36110552AA962179D5D8A4674F4C73E1518009706DAA79DBF92C09
internal mission SHA-256: A94F9F4D77245A0FA6E65B7E7657E5B8B3457CFD5FCB60A528F83EA57B563F34
DCS: 2.9.28.26385
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Ground production bundle SHA-256: E616D35F5EBDBDDD4275785091D47F57445348D1FF4BB4CFBE7DEE0F0B12D78E
Acceptance bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
```

Owner returned:

```text
dcs(20260822-173236).log
debrief(20260822-173236).log
```

## 2. Ergebnis

```text
Classification: FAIL
ResourceDemand candidate: PASS
MissionDemand reservation: PASS
CampaignState transfer IN_TRANSIT: PASS
M1083 physical materialization: PASS
AMMOSUPPLY mission execution: PASS
destination-zone proof: PASS
CampaignState DELIVERED: PASS
MissionDemand SUCCESS: PASS
RTZ command accepted: PASS
Returned event: NOT REACHED BEFORE TEST TIMEOUT
Warehouse AddAsset: NOT REACHED BEFORE TEST TIMEOUT
Final roundtrip PASS: NO
```

## 3. Beobachtete Runtime-Marker

```text
17:29:07.649 START
17:29:07.649 DEMAND_RESERVED
17:29:07.660 PHYSICAL_EXECUTION_READY
17:29:07.836 BRIGADE_STARTED
17:29:13.015 MISSION_QUEUED type=AMMOSUPPLY
17:29:39.271 GROUP_MATERIALIZED
17:29:39.536 ARMY_ON_MISSION
17:31:36.811 DELIVERY_CONFIRMED ... quantity=20 ... demandStatus=SUCCESS
17:31:36.862 MISSION_DONE deliveryCommitted=true
17:31:36.961 RETURN_RTZ_ACTIVE
17:31:36.961 RETURN_RTZ_ISSUED ... zone=ZON_BLUE_GND_JOYCE_ACCESS formation=OnRoad
17:31:45.051 FAIL reason=TIMEOUT seconds=1800 ... returnedCount=0 addAssetCount=0
```

Damit ist der bisher ungetestete Joyce->Honaker-AMMOSUPPLY-Hinweg einschließlich strategischem Delivery-Settlement praktisch bestätigt. Der vollständige Roundtrip ist durch diesen Lauf nicht bestätigt.

## 4. Zwei getrennte Findings

### 4.1 Physische Repräsentation war zu klein

Der Acceptance-Slice verwendete `TPL_BLUE_GND_SUP_M1083`, also einen einzelnen M1083. Der Projektinhaber hat nach dem Lauf entschieden, dass produktiver Resupply nicht als ungeschützter Einzel-Lkw dargestellt werden soll.

Bereits in der Mission vorhanden und für die weitere Acceptance zu verwenden:

```text
TPL_BLUE_CONVOY_LIGHT_06
TPL_BLUE_CONVOY_STANDARD_07
```

Für den nächsten Stage-1A-Lauf wird ausschließlich `TPL_BLUE_CONVOY_LIGHT_06` verwendet. Diese Auswahl definiert noch keine strategische Kapazitätsabbildung `GROUND_AMMO_PACKAGE -> trucks`. CampaignState bleibt alleinige Cargo-/Mengenautorität.

### 4.2 Globaler Timeout schnitt den Return-Pfad ab

Der bisherige Harness verwendete einen einzigen `TIMEOUT_SEC=1800` ab Teststart. Im beobachteten Lauf wurde RTZ erst kurz vor dem bereits fälligen globalen Timeout ausgelöst. Deshalb ist aus `returnedCount=0` und `addAssetCount=0` kein RTZ-Fehler ableitbar.

Korrektur für den nächsten Lauf:

```text
outbound timeout: 1800 s, endet logisch mit Delivery
return timeout: 1800 s, startet erst nach akzeptiertem RTZ
```

Zusätzlich zeigt der gepinnte MOOSE-Source:

```text
ARMYGROUP:onafterReturned
-> legion:__AddAsset(10, group, 1)
```

Die bisherige Acceptance-Verifikation nur 3 s nach `Returned` wäre deshalb ebenfalls zu früh. Der nächste Harness wartet 12 s vor der finalen `AddAsset`-/Cleanup-Verifikation.

## 5. Nächster Gate

```text
replace physical acceptance template with TPL_BLUE_CONVOY_LIGHT_06
retain AUFTRAG:NewAMMOSUPPLY(destinationZone)
retain CampaignState transfer quantity 20
retain delivery fail-closed destination-zone proof
retain explicit OnRoad RTZ to Joyce
split outbound/return timeout
verify final state only after MOOSE __AddAsset(10,...) window
rebuild acceptance bundle
owner embeds rebuilt bundle in next MIZ revision
static hash/object preflight
rerun DCS acceptance
```

Nicht Bestandteil dieses Fixes:

```text
package-per-truck capacity model
automatic LIGHT_06 vs STANDARD_07 selection
convoy attack response
CAS/CSAR orchestration
production scheduler
```
