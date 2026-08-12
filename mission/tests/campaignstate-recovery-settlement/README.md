---
document_id: OMW-TEST-CAMPAIGNSTATE-RECOVERY-SETTLEMENT
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - CampaignState forced-landing recovery settlement gate
  - idempotent recovery remainder credits
  - aircraft recovery/repair state persistence in CampaignState snapshots
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/storage-campaignstate-finalization
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/storage-forced-landing-recovery-v1
base_commit: 58a188ffc12c63782aabde49e1da16af5f5b0b60
merged_to_main: false
---

# CampaignState Recovery Settlement Gate

## Zweck

Dieser Gate schließt die nach dem akzeptierten Forced-Landing-V1-Test noch offene CampaignState-Domänengrenze. Er implementiert keine zweite Warehouse- oder STORAGE-Hoheit.

Geprüft werden ausschließlich:

```text
RECOVERABLE_FORCED_LANDING
-> RECOVERY_IN_PROGRESS
-> recovery complete
-> idempotent remaining fuel/store credit in CampaignState
-> RECOVERED_AWAITING_REPAIR
-> snapshot/export + restore
-> duplicate recovery credit after restore remains blocked
-> repair lock complete
-> AVAILABLE
```

## Implementierung

`scripts/campaign/OMW_CampaignState.lua` erhält:

```text
CreditResourceOnce(spec)
BeginAircraftRecovery(spec)
CompleteAircraftRecovery(entityId, now)
CompleteAircraftRepair(entityId, now)
GetAircraftRecovery(entityId)
ExportSnapshot()
CampaignState.Restore(snapshot)
```

Die Ressourcen-Gutschrift verwendet einen stabilen `creditId`. Derselbe `creditId` mit identischer Spezifikation ist idempotent; eine abweichende Spezifikation mit derselben ID schlägt fehl.

Der Snapshot enthält ausschließlich strategische Domänendaten. Er enthält keine MOOSE-Wrapper, DCS-Objekte, Scheduler oder STORAGE-Zustände. Die Lua-Domäne führt selbst kein Dateisystem-I/O aus.

## Abgrenzung

Dieser Gate implementiert bewusst nicht:

```text
STORAGE writes
MOOSE WAREHOUSE/AIRWING lifecycle
DCS object removal
filesystem adapter / MissionScripting.lua changes
CSAR
```

Die tatsächliche Dateiablage eines CampaignState-Snapshots bleibt ein separater Persistenzadapter im vorgesehenen OMW-Persistenzbereich. Die Snapshot-/Restore-Domänensemantik verhindert dabei, dass ein Restart bereits verbuchte Recovery-Ressourcen erneut erzeugt.

## Build

```text
Builder: tools/build-campaignstate-recovery-settlement.ps1
Bundle: mission/tests/campaignstate-recovery-settlement/dist/OMW_CampaignState_Recovery_Settlement.lua
BuilderVersion: CAMPAIGNSTATE-RECOVERY-SETTLEMENT-1
```

Der Bundle-Test ist DCS-unabhängige CampaignState-Logik und benötigt keine Flugbewegung. Ein späterer produktiver Integrationslauf muss lediglich noch die akzeptierte Forced-Landing-Beobachtung mit dieser Domain-Grenze verbinden; bereits akzeptierte Warehouse-Grundlagen werden nicht erneut getestet.
