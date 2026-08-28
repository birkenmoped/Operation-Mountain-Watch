---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-FAIL-2
status: HISTORICAL_TEST_FIXTURE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - historical DCS evidence for Stage-1A Ground AMMO RESUPPLY attempt 2
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
source_branch: agent/automatic-response-orchestration
source_commit: dac19985de5ecae89b6948854e4a4bd5906f765b
validated_in_dcs: true
---

# Ground AMMO RESUPPLY Acceptance 1 – Lauf 2 – Historical FAIL

## Ergebnis

```text
Classification: FAIL
ResourceDemand candidate: PASS
MissionDemand reservation: PASS
CampaignState transfer IN_TRANSIT: PASS
physical materialization: PASS
AMMOSUPPLY execution: PASS
destination-zone proof: PASS
CampaignState DELIVERED: PASS
MissionDemand SUCCESS: PASS
RTZ command accepted: PASS
Returned: not reached before global timeout
Warehouse AddAsset: not reached before global timeout
```

## Provenienz

```text
MIZ: OMW_Template_v18.miz
MIZ SHA-256: 2518A950CC36110552AA962179D5D8A4674F4C73E1518009706DAA79DBF92C09
DCS: 2.9.28.26385
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Acceptance bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
```

## Finding

Der globale Testtimeout begann am Teststart und schnitt den Rückweg kurz nach dem RTZ-Aufruf ab. Deshalb ist aus diesem Lauf kein RTZ-Fehler ableitbar. Zusätzlich wurde der ungeschützte Einzel-M1083 als ungeeignete physische Darstellung verworfen und im Folgelauf durch `TPL_BLUE_CONVOY_LIGHT_06` ersetzt.

Die spätere Stage-1A-Acceptance ersetzt diesen historischen Fehlversuch als technische Aussage.
