---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-ASSEMBLY
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - generic runtime composition contract for Fire Support / Strategic Resupply
  - separation of local Guard/QRF, external ARTY/CAS, perimeter and strategic resupply
  - source-reviewed no-preselection/no-second-authority assembly boundary
not_authoritative_for:
  - repository-wide authority before merge to main
  - DCS runtime validation beyond the separately cited A4/A5 acceptance scopes
  - final ARTY/CAS tactical target geometry or strategic-resupply physical descriptor configuration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Fire Support / Strategic Resupply – generische Runtime-Assembly

## Zweck

`scripts/campaign/OMW_FireSupStratResupply_Runtime.lua` ist der Composition Root der allgemeinen Fire-Support-/Strategic-Resupply-Basis. Das Modul besitzt keine eigene strategische Ressourcenhoheit und keine zweite operative Queue. Es verdrahtet die getrennten Verantwortungsbereiche und laesst operative Auswahl soweit vorgesehen bei MOOSE.

Die lokale Ground-Reaktion ist durch die separaten Production-Base-Acceptances A4/A5 technisch belegt. Der gemeinsame Rotary-Wing-CAS-Pfad ist durch Acceptance 9 fuer dessen exakt dokumentierten Joyce/Jalalabad-Scope DCS-validiert. ARTY, ARTY-Rearm, Strategic Resupply und die kombinierte Full-Response-Kette bleiben getrennt nachzuweisen.

## Assembly

```text
SiteRegistry + SupportProfiles + IdContract
+ injected site BRIGADE objects
+ Guard PATHLINE/template resolvers for accepted compact materialization
+ QRF initial physical-target resolver
+ optional external COMMANDER + ARTY/CAS tactical resolvers
+ optional perimeter configuration
+ optional CampaignState ResourceDemandPolicy/store/rows
+ optional Ground/Air resupply COMMANDERs
+ optional physical STORAGE transport descriptors
+ optional strategic transfer resolver

-> incident-local GuardRuntime
-> direct-target QrfRuntime
-> optional ExternalSupportRuntime (ARTY/CAS via COMMANDER)
-> optional TransportSettlement
-> optional ResupplyTransportRuntime (OPSTRANSPORT via COMMANDER)
-> LifecycleAdapter
-> FireSupStratResupply_Base
-> optional PerimeterBridge + PerimeterRuntime
-> optional ResupplyMonitor
```

Die Base erhaelt mindestens:

```text
adapters.GUARD = GuardRuntime
adapters.QRF   = QrfRuntime
```

Wenn `externalSupport` konfiguriert ist:

```text
adapters.ARTY = CommanderBridge -> ARTY mission factory -> COMMANDER:AddMission(...)
adapters.CAS  = CommanderBridge -> CAS mission factory  -> COMMANDER:AddMission(...)
```

Wenn `resupply.transport` konfiguriert ist:

```text
adapters.GROUND_RESUPPLY = CommanderBridge -> OPSTRANSPORT -> COMMANDER:AddOpsTransport
adapters.AIR_RESUPPLY    = CommanderBridge -> OPSTRANSPORT -> COMMANDER:AddOpsTransport
```

`GUARD`/`QRF` duerfen nicht durch `externalAdapters` ueberschrieben werden. Bei konfiguriertem `externalSupport` duerfen auch `ARTY`/`CAS` nicht parallel aus `externalAdapters` ersetzt werden. Acceptance-Fixtures duerfen `externalAdapters` gezielt benutzen, wenn sie ausdruecklich nur eine deterministische Testprovider-Bindung darstellen und keine Produktionspolicy behaupten.

## MOOSE-first-Grenzen

### Guard

Der aktuelle, in Production Base Acceptance 5 bestaetigte Vertrag lautet:

```text
NORMAL
-> kein physischer Guard

qualified installation incident
-> GuardRuntime
-> lokale BRIGADE organisatorische Grenze
-> accepted PATHLINE materializer only for compact local placement
-> AUFTRAG:NewONGUARD(local materialization anchor)
-> MOOSE recruitment / ArmyOnMission
-> kein PATHLINE patrol routing
-> kein SetEngageDetected
-> kein OMW EngageTarget cycle

incident close
-> demand Cancel
-> AUFTRAG SetReturnToLegion(true)
-> MOOSE RTZ / Returned
```

Der Guard-PATHLINE-Resolver bleibt damit eine Materialisierungsgeometrie-Voraussetzung, **nicht** ein Patrol-Router.

### QRF

Der aktuelle, in Production Base Acceptance 4 / A4-8 bestaetigte Vertrag lautet:

```text
Base incident QRF demand
-> QrfRuntime
-> lokale BRIGADE organisatorische Grenze
-> AUFTRAG:NewONGUARD(initial physical threat coordinate)
   only as recruitment/materialization anchor
-> MOOSE recruitment
-> same physical ARMYGROUP
-> authoritative GroundInstallationAttackIncident:GetParticipants(true)
-> nearest living incident UNIT inside 5-NM tactical zone
-> ARMYGROUP:EngageTarget(concrete UNIT, speed, "On Road")
-> MOOSE Disengage -> reacquire
-> no living authorized incident target remains
-> mission Cancel / SetReturnToLegion(true)
-> RTZ / Returned
```

Keine zweite World-Scan-Autoritaet, kein eigener Target-Scheduler und kein eigener Strassenrouter werden hinzugefuegt.

### ARTY / CAS

#### ARTY lifecycle inheritance record – Reconciliation 22.09.2026

| Feld | Reconciliation |
|---|---|
| inherited_contract | Accepted Functional ARTY + physical M1083 local rearm |
| accepted_source_paths | `OMW_FobAttackFunctionalArtyDispatchAdapter.lua`, `OMW_FixedFireSupportAmmoRearmService.lua`, `OMW_FixedFireSupportAmmoSupport.lua`, `OMW_GroundAmmoRearmAdapter.lua` |
| evidence | Fixed Fire Support Rearm Acceptance 2-11; source/build commit `d52a47a418fe3a1a996a5b68198b8dc033ff86c4`; bundle `CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B`; mission hash `388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620`; DCS `2.9.28.26385 MT` |
| invariants | one Functional `ARTY` owner per battery; same long-lived instance fires and rearms; no restart after firing; M1083 physical rearm; CampaignState exactly-once consumption/completion; ARTY-owned support return |
| reuse_mode | direct reuse / shared production modules; no copied FSM in Acceptance |
| harness_role | stimulus + observation + assertion only |
| changed_boundary | generic C2/MOOSE provider selection -> exact selected battery -> existing Functional ARTY owner |
| owner_approval | required before any project-specific selection/handoff adapter, fixed-provider production exception, or switch to another ARTY/rearm owner model |
| revalidation_scope | only the approved selection/handoff boundary plus proof that the inherited fire/rearm/return invariants remain intact |

Pinned-MOOSE review establishes that `AUFTRAG:NewARTY` and Functional `ARTY` are different owners: `AUFTRAG:NewARTY` becomes a DCS `FireAtPoint` mission executed by the recruited OPSGROUP, while Functional `ARTY` is its own `FSM_CONTROLLABLE` with the accepted rearm chain. No public pinned-MOOSE handoff was found that lets COMMANDER select a battery and then transfers the same demand into an already running Functional-`ARTY` instance without retaining a second AUFTRAG fire owner.

Accordingly, the current generic `CommanderBridge -> NewARTY` path must not be combined with the accepted Functional-ARTY/M1083 owner on the same battery. `OPSGROUP:SetRearmOnOutOfAmmo()` is not treated as equivalent because it is a different MOOSE rearm lifecycle and does not inherit the accepted M1083/CampaignState evidence.

Status:

```text
ARTY selection/handoff = STOPPED_FOR_OWNER_DECISION
accepted Functional ARTY/M1083 lifecycle = REUSE / DO NOT REIMPLEMENT
generic NewARTY path = SOURCE_REVIEWED ONLY / NOT A REARM EQUIVALENCE
non-MOOSE or project-specific bridge = NOT APPROVED
```

External Support wird erst nach expliziter C2-Eskalation als Base-Demand erzeugt. Der generische ExternalSupportRuntime nutzt einen injizierten MOOSE-`COMMANDER` als Aggregator:

```text
ARTY demand -> caller-resolved tactical target -> MOOSE AUFTRAG -> COMMANDER:AddMission
CAS demand  -> caller-resolved tactical CAS geometry -> MOOSE AUFTRAG -> COMMANDER:AddMission
```

Der Runtime waehlt weder Batterie noch AIRWING/SQUADRON/Asset. Fehlende Zielgeometrie fuehrt zu einem expliziten Nicht-Dispatch und nicht zu einem geratenen Fallback.

Die CAS-Factory Schema 2 unterstuetzt neben `NewCAS(...)` auch den source-geprueften Stage-3-Modus:

```text
PATROLZONE_ENGAGE
-> AUFTRAG:NewPATROLZONE(...)
-> SetEngageDetected(...)
-> optional caller-owned configureMission(...) geometry
```

Das erweitert die taktische Missionsform, nicht die Provider-Selektion.

Deterministische Acceptance-Zuordnungen wie `Honaker -> Wright L118` oder `Honaker -> Jalalabad AH-64D` sind Testfixtures und duerfen nicht als allgemeine Produktionsauswahl in SiteRegistry/SupportProfiles uebernommen werden.

#### CAS-Status nach Acceptance 9

Der Rotary-Wing-CAS-Pfad ist fuer den exakt dokumentierten A9-Scope DCS-validiert:

```text
source commit: c956b7b03b82c4ab04e529d09b1ff9bf4e480bf2
bundle SHA-256: D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0
DCS: 2.9.29.27468
MOOSE: 2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
result: PASS
```

Damit ist fuer diesen Scope die gesamte Kette belegt:

```text
MOOSE provider/asset selection
-> selected-provider owner route
-> tactical corridor
-> AUFTRAG executing
-> own FLIGHTGROUP detection
-> profile-specific release
-> controlled mission closure
-> reverse owner route
-> home landing
-> exact LegionAssetReturned
-> lifecycle complete
```

Dieser Lifecycle ist eingefrorene Reuse-Baseline. Neue Base-, Full-Response- oder Site-Integrationen duerfen ihn nicht im Harness nachbauen. Sie muessen die produktiven Module direkt wiederverwenden.

### Perimeter

Mit Perimeterkonfiguration gilt:

```text
ZONE_RADIUS / OPSZONE
-> FobThreatOpsZoneAdapter
-> MOOSE scanned RED ground presence / Evaluated
-> PerimeterBridge
-> authoritative installation incident
-> incident-local Guard + mobile QRF demands
```

Die produktiven Site-Anker/-Radien stehen in `OMW_FireSupStratResupply_SiteRegistry.lua`. ACCESS-Zonen sind weder Alarm- noch Fire-Support-/CAS-Geometrie.

```text
alarm perimeter != tactical battlespace
alarm perimeter != ARTY target area
alarm perimeter != CAS engagement zone
alarm perimeter != mission-end condition
```

### Strategic Resupply

Der Resource-Monitor ist optional und besitzt keinen eigenen Scheduler. Wenn `resupply` injiziert ist:

```text
CampaignState store
+ ResourceDemandPolicy
+ baseline rows
+ injected ground/air selector
-> ResupplyMonitor
-> Base:RequestResupply(...)
```

CampaignState bleibt strategische Ressourcenautoritaet. Der Monitor bewertet keine MOOSE-Warehouses als strategischen Bestand und implementiert keine Transport-Retry-Queue.

Mit `resupply.transport`:

```text
Base GROUND_RESUPPLY / AIR_RESUPPLY demand
-> StorageTransportFactory
-> caller-resolved pickup/deploy/STORAGE descriptor
-> OPSTRANSPORT:New(...)
-> OPSTRANSPORT:AddCargoStorage(...)
-> TransportSettlement reservation
-> COMMANDER:AddOpsTransport(...)
-> MOOSE carrier/provider recruitment and physical execution
```

Settlement bleibt getrennt:

```text
CampaignState ReserveResource
-> MOOSE OPSTRANSPORT OnAfterExecuting => LOADING
-> caller-confirmed physical in-transit evidence => IN_TRANSIT
-> MOOSE STORAGE delivered/lost evidence
-> CampaignState DELIVERED / LOST
```

Ein `PARTIAL`-Ergebnis wird nicht stillschweigend als Vollzustellung verbucht; dafuer fehlt weiterhin eine allgemeine CampaignState-Teiltransfer-Semantik.

## Keine stillschweigenden Geometrie- oder Providerentscheidungen

Der Runtime erwartet explizite Resolver beziehungsweise Konfiguration fuer:

```text
resolveGuardPathline
resolveGuardTemplateGroup
resolveQrfCoordinate / resolveTarget
externalSupport.resolveArtyTarget
externalSupport.resolveCasGeometry
perimeters[siteId].anchorCoordinate
perimeters[siteId].radiusM
resupply.transport.resolveGroundTransport
resupply.transport.resolveAirTransport
resupply.transport.resolveTransfer
```

Weder Warehouse-/ACCESS-Namen noch Guard-PATHLINE oder Installationsnamen duerfen als ungeschriebene ARTY-/CAS-/Resupply-Providerentscheidung missbraucht werden.

## Lebenszyklus

`Prepare()` assembliert alle konfigurierten Adapter einmalig. Danach stehen unter anderem bereit:

```text
GetBase()
StartSite(siteId, spec)
StartPerimeters()
StopPerimeters()
ReportInstallationEvidence(...)
CloseInstallationIncident(...)
EvaluateResupply()
ReleaseResupplyDemand(demandId, reason)
GetAdapter(supportType)
```

Die fachlichen Base-Methoden fuer Incidents, Support und Resupply bleiben am Base-Objekt und werden nicht parallel nachimplementiert.

## Aktuell offen

```text
1. ARTY-Reconciliation:
   source/FSM reconciliation complete
   public pinned-MOOSE selection -> existing Functional ARTY handoff not established
   STOPPED_FOR_OWNER_DECISION before implementation
   accepted Functional ARTY + M1083 lifecycle remains unchanged

2. Strategic Resupply:
   konkrete Ground/Air pickup/deploy/STORAGE/route descriptors
   + physischer OPSTRANSPORT-Lifecycle
   + idempotentes Settlement

3. PARTIAL-Resupply-Semantik nur falls tatsaechlich benoetigt:
   keine stillschweigende Vollzustellung

4. kombinierte Full-Response-Acceptance:
   eingefrorene Ground-/Guard-/QRF-/CAS-Lifecycles wiederverwenden
   und nur ARTY/Resupply/Orchestration-Neugrenzen testen

5. finale _base-Reconciliation:
   Source/Docs/Builder/Acceptance-Matrix konsolidieren
   keine alten Acceptance-Harness-Lifecycles in Production zurueckkopieren

6. optional spaetere Expansion:
   fixed-wing CAS, weitere Provider-/Site-Profile, combined six-site regression
```

Nicht mehr offen sind die grundsaetzliche incident-local Guard-Semantik, der direkte QRF-Target-Cycle und der A9-validierte Rotary-Wing-CAS-Lifecycle fuer dessen dokumentierten Scope.

## Contract-Tests

```text
tests/mission-demand/test_fire_support_strategic_resupply_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_external_support_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_resupply_monitor.lua
tests/mission-demand/test_fire_support_strategic_resupply_storage_transport_factory.lua
tests/mission-demand/test_fire_support_strategic_resupply_transport_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_transport_settlement.lua
```

CI prueft die generischen Composition-/Factory-Grenzen. DCS-Evidenz fuer konkrete physische Lifecycles bleibt an die jeweiligen Acceptance-Provenienzen gebunden.
