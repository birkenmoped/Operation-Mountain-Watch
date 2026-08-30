---
document_id: OMW-GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1
status: SUPERSEDED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - historical record of the rejected Joyce/convoy test setup created during Stage 2B
  - explanation why the historical run provides no evidence for Fortress infantry return
not_authoritative_for:
  - Stage 2B Fortress Ground return architecture
  - suitability of Joyce for Stage 2B
  - suitability of native Warehouse geometry for every installation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-STAGE-2B-FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2
source_branch: agent/fob-attack-support-demand
source_commit: 3f8dc517a0a5c4f589b34ae35ee6ac370e5ab9ac
validated_in_dcs: false
---

# Superseded – Joyce native-homezone Acceptance 1

Dieser historische Testpfad wurde während der Stage-2B-Arbeit irrtümlich auf Joyce/MATV statt auf Fortress-Infanterie aufgebaut:

```text
OriginWarehouse: WH_BLUE_GND_JOYCE
Template: TPL_BLUE_GND_PATROL_MATV_4
DestinationZone: ZON_BLUE_GND_JOYCE_PATROL_TEST_01
```

Die Destination-Zone fehlte in der realen Mission; die Ground-Gruppe materialisierte deshalb nicht. Der Lauf testete weder Fortress-Infanterie noch den nativen Fortress-ReturnToLegion-Pfad.

Der Test wurde verworfen und durch den integrierten Fortress Acceptance-2-Pfad ersetzt. Dieser bestätigte im finalen DCS-Lauf drei native QRF-Returns zu `WH_BLUE_GND_FORTRESS` ohne explizites OMW-RTZ oder Spawnzone-Override.

Aktueller Nachweis:

```text
mission/tests/fob-attack-support-demand/RESULT-2.md
```