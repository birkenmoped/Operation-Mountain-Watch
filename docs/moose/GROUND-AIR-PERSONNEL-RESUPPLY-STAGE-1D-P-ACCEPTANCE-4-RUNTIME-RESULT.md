---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-RUNTIME-RESULT
status: SUPERSEDED
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Stage 1D-P Air PERSONNEL Acceptance-4 runtime evidence before final provenance closure
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL
source_branch: agent/automatic-response-orchestration-continuation
source_commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
validated_in_dcs: true
---

# Stage 1D-P – Air PERSONNEL Acceptance-4 Runtime Result

Dieses Dokument hält den vorläufigen Runtime-PASS fest, bevor der Hash der exakt getesteten Mission nachgereicht wurde. Die vollständige und maßgebliche technische Acceptance steht jetzt in:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md
```

Der historische Lauf bestätigte bereits den später formal akzeptierten Ablauf:

```text
Jalalabad CH-47 takeoff
-> OMW_FlightPath outbound
-> LANDATCOORDINATE Fortress
-> approximately 30 s physical dwell
-> matching MOOSE TaskDone at 4.1 m from OMW_BLUE_LZ_FORTRESS_01
-> CampaignState MarkDelivered exact once
-> MissionDemand SUCCESS
-> physical return corridor
-> physical Jalalabad landing
-> LegionAssetReturned afterwards
-> PASS final=447/160
```

Die damals noch fehlende Missionsprovenienz wurde anschließend durch den Owner geschlossen:

```text
mission: OMW_Template_v20_GroundWorks.miz
mission SHA-256: 3B93F9817379BA6C66C8C02DD2142D1EDA3D88090CB8FC88973D4DAC45EE6B11
bundle SHA-256: C2BD325AF48BF6EA08936BCA666E4460293B60CC36FB8FE0181BC5140DF9ABD3
DCS: 2.9.29.27278 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Für aktuelle Architektur-, Methoden- und Acceptance-Aussagen ist ausschließlich das Final-Dokument maßgeblich.