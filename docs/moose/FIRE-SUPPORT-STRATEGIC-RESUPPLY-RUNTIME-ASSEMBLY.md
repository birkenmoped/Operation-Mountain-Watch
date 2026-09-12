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
  - DCS runtime validation of the new composition root
  - concrete six-site alarm radii, perimeter anchors or QRF response coordinates
  - final ARTY/CAS tactical target geometry or strategic-resupply physical descriptor configuration
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
+ optional external COMMANDER + ARTY/CAS tactical resolvers
+ optional perimeter configuration
+ optional CampaignState ResourceDemandPolicy/store/rows
+ optional Ground/Air resupply COMMANDERs
+ optional physical STORAGE transport descriptors
+ optional strategic transfer resolver

-> GuardRuntime
-> QrfRuntime
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
adapters.ARTY = CommanderBridge -> AUFTRAG:NewARTY(...)
adapters.CAS  = CommanderBridge -> AUFTRAG:NewCAS(...)
```

Wenn `resupply.transport` konfiguriert ist:

```text
adapters.GROUND_RESUPPLY = CommanderBridge -> OPSTRANSPORT -> COMMANDER:AddOpsTransport
adapters.AIR_RESUPPLY    = CommanderBridge -> OPSTRANSPORT -> COMMANDER:AddOpsTransport
```

`GUARD`/`QRF` duerfen nie ueberschrieben werden. Bei konfiguriertem `externalSupport` duerfen auch `ARTY`/`CAS` nicht parallel aus `externalAdapters` ersetzt werden. Bei konfiguriertem `resupply.transport` duerfen `GROUND_RESUPPLY`/`AIR_RESUPPLY` ebenfalls nicht parallel aus `externalAdapters` ersetzt werden.

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

### ARTY / CAS

External Support wird erst nach expliziter C2-Eskalation als Base-Demand erzeugt. Der generische ExternalSupportRuntime nutzt einen injizierten MOOSE-`COMMANDER` als Aggregator:

```text
ARTY demand -> caller-resolved target coordinate -> AUFTRAG:NewARTY -> COMMANDER:AddMission
CAS demand  -> caller-resolved tactical CAS zone -> AUFTRAG:NewCAS -> COMMANDER:AddMission
```

Der Runtime waehlt weder Batterie noch AIRWING/SQUADRON/Asset. Fehlende Zielgeometrie fuehrt zu einem expliziten Nicht-Dispatch und nicht zu einem geratenen Fallback.

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

ACCESS-Zonen sind weder Perimeter- noch Guard-Input. Ebenso gilt weiterhin:

```text
alarm perimeter != ARTY target area
alarm perimeter != CAS engagement zone
```

### Strategic Resupply

Der Resource-Monitor ist optional und besitzt keinen eigenen Scheduler. Wenn `resupply` injiziert ist, wird dieselbe Base mit

```text
CampaignState store
+ ResourceDemandPolicy
+ baseline rows
+ injected ground/air selector
-> ResupplyMonitor
-> Base:RequestResupply(...)
```

verbunden. CampaignState bleibt strategische Ressourcenautoritaet. Der Monitor bewertet keine MOOSE-Warehouses als strategischen Bestand und implementiert keine Transport-Retry-Queue.

Wenn zusaetzlich `resupply.transport` konfiguriert ist, wird die physische Seite wie folgt verdrahtet:

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

Die strategische Settlement-Grenze ist davon getrennt:

```text
CampaignState ReserveResource
-> MOOSE OPSTRANSPORT OnAfterExecuting => LOADING
-> caller-confirmed physical in-transit evidence => IN_TRANSIT
-> MOOSE STORAGE delivered/lost evidence
-> CampaignState DELIVERED / LOST
```

Die strategische Transaktion wird **vor** der COMMANDER-Submission gebunden. Kann keine strategische Transferzuordnung erstellt werden, wird der noch nicht eingereihte OPSTRANSPORT storniert und nicht an den COMMANDER uebergeben.

Die physische Quelle und der strategische CampaignState-Ursprung muessen nicht identisch benannt sein. Fuer Faelle wie `OFF_MAP` kann daher `resupply.transport.resolveTransfer(...)` explizit einen strategischen `originNodeId`/`destinationNodeId` liefern. Diese Zuordnung wird nicht aus Namen geraten.

`OPSTRANSPORT`-Abschluss wird nicht blind als strategische Vollzustellung interpretiert. Der Settlement-Adapter prueft die MOOSE-STORAGE-Werte:

```text
cargoDelivered == cargoAmount && cargoLost == 0 -> DELIVERED
cargoLost      == cargoAmount && cargoDelivered == 0 -> LOST
mixed delivered/lost                          -> PARTIAL
```

Ein `PARTIAL`-Ergebnis wird absichtlich **nicht** stillschweigend in CampaignState verbucht. Die aktuelle CampaignState-Transfertransaktion besitzt keine allgemeine Teiltransfer-Semantik. Der Fall wird ueber `onPartial` an eine explizite Projektentscheidung/Policy weitergereicht.

Der Composition Root stellt fuer den Resource-Monitor nur bereit:

```text
EvaluateResupply()
ReleaseResupplyDemand(demandId, reason)
```

Ein terminaler Transport (`DELIVERED`, `LOST`, `CANCELLED`) gibt den aktiven Shortage-Eintrag im Monitor frei. Dadurch kann eine spaetere Bewertung bei weiter bestehendem Mangel eine neue Demand-Generation erzeugen; der Runtime selbst startet keinen Retry.

## Keine stillschweigenden Geometrieentscheidungen

Der Runtime erwartet explizite Resolver beziehungsweise Konfiguration fuer:

```text
resolveGuardPathline
resolveGuardTemplateGroup
resolveQrfCoordinate
externalSupport.resolveArtyTarget
externalSupport.resolveCasGeometry
perimeters[siteId].anchorCoordinate
perimeters[siteId].radiusM
resupply.transport.resolveGroundTransport
resupply.transport.resolveAirTransport
resupply.transport.resolveTransfer        # optional strategic mapping
```

Guard-PATHLINE und Guard-Template sind bereits Teil der dokumentierten Six-Site-Baseline. QRF-Response-Koordinaten, ARTY-/CAS-Zielgeometrien, Alarmanker/-radien sowie Ground-/Air-Resupply-Pickup-/Deploy-/STORAGE-/Route-Daten werden nicht aus Warehouse, ACCESS-Zone, Guard-PATHLINE oder Installationsnamen geraten.

## Lebenszyklus

`Prepare()` assembliert alle konfigurierten Adapter einmalig. Der Runtime stellt danach die allgemeine Base ueber `GetBase()` bereit und bietet schmale Convenience-Grenzen:

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

Fuer die vollstaendige produktive Foundation fehlen danach noch:

```text
1. verbindliche sechs Site Alarmanker/-radien
2. verbindliche QRF response coordinates/routes bzw. deren Resolver
3. verbindliche taktische Resolverdaten fuer ARTY/CAS je Incident/C2-Pfad
4. konkrete Ground/Air resupply pickup/deploy/STORAGE/route descriptors
5. Projektentscheidung fuer generische PARTIAL-Resupply-Semantik, falls benoetigt
6. combined six-site DCS regression
```

Die generischen Guard-, QRF-, ARTY-, CAS-, Resource-Threshold-, OPSTRANSPORT- und CampaignState-Settlement-Grenzen sind damit source-seitig im Composition Root vorhanden. Offen bleiben konkrete Missionsdaten, gegebenenfalls die Teiltransfer-Policy und die kombinierte DCS-Verifikation.

Diese Punkte duerfen nicht durch Default-Geometrie oder OMW-eigene Asset-Vorselektion vorweggenommen werden.

## Contract-Tests

```text
tests/mission-demand/test_fire_support_strategic_resupply_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_external_support_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_resupply_monitor.lua
tests/mission-demand/test_fire_support_strategic_resupply_storage_transport_factory.lua
tests/mission-demand/test_fire_support_strategic_resupply_transport_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_transport_settlement.lua
```

Geprueft werden insbesondere:

- GuardRuntime wird vor der Base vorbereitet;
- Guard und QRF werden als lokale Base-Adapter gesetzt;
- ARTY/CAS nutzen den COMMANDER-Aggregationspfad ohne Provider-Vorselektion;
- Ground/Air Resupply nutzt OPSTRANSPORT und COMMANDER ohne Carrier-Vorselektion;
- Strategic Settlement wird vor COMMANDER-Submission gebunden;
- fehlende Settlement-Voraussetzungen verhindern die physische Einreihung;
- CampaignState wird erst bei bestaetigtem physischem Lifecycle fortgeschrieben;
- Vollverlust und Vollzustellung werden getrennt behandelt;
- gemischte STORAGE-Ergebnisse werden nicht stillschweigend als Vollzustellung gebucht;
- explizite strategische Transferauflösung kann physische/off-map Provider von CampaignState-Node-IDs entkoppeln;
- PerimeterBridge benutzt dieselbe Base;
- optionale Perimeterkonfiguration wird unveraendert weitergereicht;
- Runtime ohne Perimeter bleibt gueltig und meldet deren Fehlen explizit;
- optionaler ResourceDemandPolicy/CampaignState-Monitor benutzt dieselbe Base;
- Runtime ohne Resource-Monitor bleibt gueltig und meldet dessen Fehlen explizit.

Das ist CI-/Contract-Evidenz, kein DCS-Runtime-PASS.
