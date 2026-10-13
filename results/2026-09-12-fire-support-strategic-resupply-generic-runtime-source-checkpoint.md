---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GENERIC-RUNTIME-SOURCE-CHECKPOINT-2026-09-12
status: PASS
document_class: SOURCE_VERIFICATION_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - source-side generic Fire Support / Strategic Resupply runtime checkpoint through strategic resupply transport settlement
  - exact branch/commit and CI evidence for this checkpoint
not_authoritative_for:
  - DCS runtime validation of the generic composition root
  - six-site alarm/QRF/ARTY/CAS/resupply mission-data configuration
  - partial strategic resupply settlement policy
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: 2703e32474924127447315640f39c12ed479e9a6
validated_in_dcs: false
---

# Fire Support / Strategic Resupply – generische Runtime, Source-Checkpoint

## Ergebnis

Der generische Source-Pfad ist bis einschliesslich physischer MOOSE-Resupply-Transportgrenze und strategischem CampaignState-Settlement zusammengesetzt.

Der exakte geprüfte Code-Checkpoint ist:

```text
branch: agent/fire-support-strategic-resupply-base-gate0
commit: 2703e32474924127447315640f39c12ed479e9a6
main baseline: 980340c9225a81921aed8995aa8f50cad7d1c215
```

`main` war bei der Prüfung unverändert auf der genannten Baseline.

## Source-seitig vorhanden

```text
Base coordinator
SiteRegistry / SupportProfiles / IdContract
GuardRuntime + LEGION/BRIGADE recruitment boundary
accepted Guard PATHLINE materialization seam
QrfRuntime + local LEGION/BRIGADE recruitment boundary
PerimeterBridge + PerimeterRuntime
ExternalSupportRuntime
ARTY mission factory -> COMMANDER:AddMission
CAS mission factory -> COMMANDER:AddMission
ResupplyMonitor -> Base:RequestResupply
StorageTransportFactory -> OPSTRANSPORT
ResupplyTransportRuntime -> COMMANDER:AddOpsTransport
TransportSettlement -> CampaignState transfer lifecycle
```

Damit bleibt die Trennung erhalten:

```text
CampaignState
= strategische Ressourcenauthorität

MOOSE COMMANDER / LEGION / BRIGADE / AIRWING / OPSTRANSPORT
= operative Auswahl, Recruitment, Queueing und physische Ausführung
```

Es existiert keine OMW-eigene operative Carrier-/Cohort-/Asset-Vorselektion in den neuen generischen Bridges.

## Strategic Resupply Lifecycle

Der generische Pfad lautet:

```text
CampaignState shortage
-> ResupplyMonitor
-> Base GROUND_RESUPPLY / AIR_RESUPPLY demand
-> StorageTransportFactory
-> OPSTRANSPORT
-> strategic transfer reservation
-> COMMANDER:AddOpsTransport
-> MOOSE recruitment / physical execution
-> confirmed physical in-transit evidence
-> CampaignState IN_TRANSIT
-> confirmed STORAGE delivered/lost outcome
-> CampaignState DELIVERED / LOST
```

Ein gemischtes physisches STORAGE-Ergebnis (`cargoDelivered` + `cargoLost`) wird nicht stillschweigend als Vollzustellung verbucht. Es bleibt ein expliziter `PARTIAL`-Policy-Punkt.

## CI-Evidenz

Für Commit `2703e32474924127447315640f39c12ed479e9a6`:

```text
Documentation validation
run: 34720654291
result: SUCCESS

MissionDemand validation
run: 34720654284
job: mission-demand-contracts
job result: SUCCESS
```

Der MissionDemand-Job bestätigte insbesondere auch die neuen Tests:

```text
test_fire_support_strategic_resupply_runtime
test_fire_support_strategic_resupply_resupply_monitor
test_fire_support_strategic_resupply_storage_transport_factory
test_fire_support_strategic_resupply_transport_runtime
test_fire_support_strategic_resupply_transport_settlement
```

Das ist Source-/Contract-Evidenz und ausdrücklich **kein DCS-Runtime-PASS**.

## Verifizierter Diff-Umfang seit External-Support-Checkpoint

Vergleich:

```text
base: 9ec4d05ab54b2c4b1be26f0890a859d04c2915db
head: 2703e32474924127447315640f39c12ed479e9a6
status: ahead
commits: 16
```

Betroffene Runtime-/Test-/Dokumentationsdateien:

```text
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-ASSEMBLY.md
scripts/campaign/OMW_FireSupStratResupply_Runtime.lua
scripts/campaign/OMW_FireSupStratResupply_ResupplyTransportRuntime.lua
scripts/campaign/OMW_FireSupStratResupply_StorageTransportFactory.lua
scripts/campaign/OMW_FireSupStratResupply_TransportSettlement.lua
tests/mission-demand/run.lua
tests/mission-demand/test_fire_support_strategic_resupply_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_storage_transport_factory.lua
tests/mission-demand/test_fire_support_strategic_resupply_transport_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_transport_settlement.lua
```

## Noch nicht entschieden / noch nicht DCS-validiert

Für eine produktive kombinierte Six-Site-Acceptance fehlen weiterhin konkrete, projektinhaberseitig verbindliche Missionsdaten beziehungsweise Entscheidungen:

```text
1. sechs Alarmanker/-radien
2. QRF response coordinates/routes
3. taktische ARTY target resolver data
4. taktische CAS zone/resolver data
5. Ground/Air resupply pickup/deploy/STORAGE/route descriptors
6. generische PARTIAL-Resupply-Semantik, falls PARTIAL produktiv unterstützt werden soll
7. combined six-site DCS regression
```

Diese Werte wurden nicht aus ACCESS-Zonen, Guard-PATHLINEs, Warehouses oder historischen Einzeltests geraten.

## Status

```text
GENERIC SOURCE FOUNDATION: PASS
DCS VALIDATION: OPEN
PRODUCTIVE SIX-SITE MISSION DATA: OPEN
PR #149: DRAFT
```
