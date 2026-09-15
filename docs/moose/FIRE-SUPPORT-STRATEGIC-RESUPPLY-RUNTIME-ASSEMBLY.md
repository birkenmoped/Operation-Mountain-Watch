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

Die lokale Ground-Reaktion ist inzwischen durch die separaten Production-Base-Acceptances A4/A5 technisch belegt. ARTY/CAS-External-Support und die kombinierte Full-Response-Kette bleiben getrennt nachzuweisen.

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
1. kombinierte Full-Response-Acceptance mit A4/A5 als Ground authority
2. konkrete C2-/Missionsdaten je Szenario fuer ARTY/CAS-Geometrie
3. konkrete Ground/Air-resupply pickup/deploy/STORAGE/route descriptors je Szenario
4. Projektentscheidung fuer generische PARTIAL-Resupply-Semantik, falls benoetigt
5. combined six-site regression, soweit spaeter gefordert
```

Nicht mehr offen sind die grundsaetzliche incident-local Guard-Semantik, der direkte QRF-Target-Cycle und die sechs produktiven Alarmradien dieses Branches; dafuer existieren separate akzeptierte beziehungsweise festgelegte Baselines.

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
