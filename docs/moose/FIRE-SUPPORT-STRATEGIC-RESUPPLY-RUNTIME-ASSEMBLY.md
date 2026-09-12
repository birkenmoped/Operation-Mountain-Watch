---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-ASSEMBLY
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - generic runtime composition contract for Fire Support / Strategic Resupply
  - separation of local Guard/QRF adapters from external support, perimeter and resource monitoring
  - source-reviewed no-preselection/no-second-authority assembly boundary
not_authoritative_for:
  - DCS runtime validation of the new composition root
  - concrete six-site alarm radii, perimeter anchors or QRF response coordinates
  - final ARTY, CAS or strategic-resupply provider configuration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fire Support / Strategic Resupply – generische Runtime-Assembly

## Zweck

`scripts/campaign/OMW_FireSupStratResupply_Runtime.lua` ist der Composition Root der allgemeinen Fire-Support-/Strategic-Resupply-Basis. Das Modul enthaelt keine eigene Feinderkennung, keine operative Asset-Auswahl, keine strategische Ressourcenautoritaet und keine zweite Queue. Es verdrahtet ausschliesslich die bereits getrennten Verantwortungsbereiche.

## Assembly

Der vorbereitete Runtime-Vertrag lautet:

```text
SiteRegistry + SupportProfiles + IdContract
+ injected six-site BRIGADE objects
+ Guard PATHLINE/template resolvers
+ QRF response-coordinate resolver
+ optional external support adapters
+ optional perimeter configuration
+ optional CampaignState ResourceDemandPolicy/store/rows

-> GuardRuntime
-> QrfRuntime
-> LifecycleAdapter
-> FireSupStratResupply_Base
-> optional PerimeterBridge + PerimeterRuntime
-> optional ResupplyMonitor
```

Die Base erhaelt damit mindestens:

```text
adapters.GUARD = GuardRuntime
adapters.QRF   = QrfRuntime
```

Externe Adapter koennen fuer

```text
ARTY
CAS
GROUND_RESUPPLY
AIR_RESUPPLY
```

injiziert werden. `GUARD` und `QRF` duerfen von `externalAdapters` nicht ueberschrieben werden.

## MOOSE-first-Grenzen

### Guard

```text
Base StartSite
-> GuardRuntime
-> lokale BRIGADE organisatorische Grenze
-> AUFTRAG NewONGUARD
-> LEGION AddMission
-> MOOSE recruitment
-> genehmigte Guard-Materialisierungs-Ausnahme
-> public ArmyOnMission/PATHLINE routing
```

### QRF

```text
Base incident QRF demand
-> QrfRuntime
-> lokale BRIGADE organisatorische Grenze
-> caller-supplied response coordinate
-> AUFTRAG NewONGUARD
-> LEGION AddMission
-> MOOSE recruitment
```

Die lokale BRIGADE ist eine fachliche Organisationsgrenze, keine konkrete Asset-Selektion. COHORT-/Assetwahl und Warehouse-Recruitment bleiben MOOSE.

### Perimeter

Perimeter sind absichtlich optional. Solange keine verbindlichen sechs Site-Anker/-Radien vorliegen, kann die allgemeine Runtime ohne Perimeter vorbereitet und fuer Guard sowie explizite Demands genutzt werden. `StartPerimeters()` liefert dann explizit `PERIMETERS_NOT_CONFIGURED`.

Mit injizierter Perimeterkonfiguration gilt:

```text
ZONE_RADIUS / OPSZONE
-> FobThreatOpsZoneAdapter
-> PerimeterBridge
-> Base incident
-> local QRF demand
```

ACCESS-Zonen sind weder Perimeter- noch Guard-Input.

### Strategic Resupply Monitor

Der Resource-Monitor ist ebenfalls optional und besitzt keinen eigenen Scheduler. Wenn `resupply` injiziert ist, wird dieselbe Base mit

```text
CampaignState store
+ ResourceDemandPolicy
+ baseline rows
+ injected ground/air selector
-> ResupplyMonitor
-> Base:RequestResupply(...)
```

verbunden. CampaignState bleibt strategische Ressourcenautoritaet. Der Monitor bewertet keine MOOSE-Warehouses als strategischen Bestand und implementiert keine Transport-Retry-Queue.

Der Composition Root stellt dafuer nur bereit:

```text
EvaluateResupply()
ReleaseResupplyDemand(demandId, reason)
```

`ReleaseResupplyDemand` ist ein expliziter terminaler Lifecycle-Hook; er startet selbst keinen neuen Transport.

## Keine stillschweigenden Geometrieentscheidungen

Der Runtime erwartet explizite Resolver beziehungsweise Konfiguration fuer:

```text
resolveGuardPathline
resolveGuardTemplateGroup
resolveQrfCoordinate
perimeters[siteId].anchorCoordinate
perimeters[siteId].radiusM
```

Guard-PATHLINE und Guard-Template sind bereits Teil der dokumentierten Six-Site-Baseline. QRF-Response-Koordinaten sowie konkrete Alarmanker/-radien werden nicht aus Warehouse, ACCESS-Zone, Guard-PATHLINE oder Installationsnamen geraten.

## Lebenszyklus

`Prepare()` assembliert alle Adapter einmalig. Der Runtime stellt danach die allgemeine Base ueber `GetBase()` bereit und bietet schmale Convenience-Grenzen:

```text
StartSite(siteId, spec)
StartPerimeters()
StopPerimeters()
EvaluateResupply()
ReleaseResupplyDemand(demandId, reason)
GetAdapter(supportType)
```

Die fachlichen Base-Methoden fuer Incidents, Support und Resupply bleiben am Base-Objekt und werden nicht parallel nachimplementiert.

## Aktuell absichtlich offen

Fuer die vollstaendige produktive Foundation fehlen danach noch die fachlich getrennten Bloecke:

```text
1. verbindliche sechs Site Alarmanker/-radien
2. verbindliche QRF response coordinates/routes bzw. deren Resolver
3. external ARTY mission factory / COMMANDER bridge integration
4. external CAS mission factory / COMMANDER/AIRWING integration
5. MOOSE ground/air resupply transport adapters + confirmed CampaignState settlement hooks
6. combined six-site DCS regression
```

Die strategische Threshold-Seite selbst ist jetzt in die allgemeine Runtime integrierbar; offen bleibt die physische MOOSE-Transportseite und deren Settlement.

Diese Punkte duerfen nicht durch Default-Geometrie oder OMW-eigene Asset-Vorselektion vorweggenommen werden.

## Contract-Tests

```text
tests/mission-demand/test_fire_support_strategic_resupply_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_resupply_monitor.lua
```

Geprueft werden insbesondere:

- GuardRuntime wird vor der Base vorbereitet;
- Guard und QRF werden als lokale Base-Adapter gesetzt;
- externe Adapter bleiben getrennt;
- PerimeterBridge benutzt dieselbe Base;
- optionale Perimeterkonfiguration wird unveraendert weitergereicht;
- Runtime ohne Perimeter bleibt gueltig und meldet deren Fehlen explizit;
- optionaler ResourceDemandPolicy/CampaignState-Monitor benutzt dieselbe Base;
- Runtime ohne Resource-Monitor bleibt gueltig und meldet dessen Fehlen explizit.

Das ist CI-/Contract-Evidenz, kein DCS-Runtime-PASS.
