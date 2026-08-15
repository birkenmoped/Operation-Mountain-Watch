---
document_id: OMW-ARCH-CAMPAIGN-STATE
status: BINDING
document_class: DOMAIN_MODEL
owning_policy: OMW-GOV-001
authoritative_for:
  - CampaignState strategic authority
  - persistent strategic entity identity
  - separation of strategic state from DCS and MOOSE representations
  - aircraft total-loss, forced-landing, recovery and repair state semantics
  - AAR off-map KC-135 strategic pool, loss and restore semantics
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - prototype-only resource scope wording
superseded_by:
source_branch: agent/aar-runtime-finalization
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# 04 – CampaignState

## 1. Autorität

`CampaignState` ist die einzige strategische Wahrheit für Ressourcen, Entitäten, Verluste, Aufträge und persistente Zustände.

DCS-Gruppen, CTLD-Fracht, MOOSE-Warehouses, AIRWING-/SQUADRON-Bestände, Statics und andere Laufzeitobjekte bilden strategischen Zustand nur ab. Sie dürfen denselben Bestand nicht unabhängig besitzen oder erhöhen.

Historische Grundlage:

- [`Legacy-CampaignState-Grundlage`](evidence/source-records/legacy-04-campaign-state.md)

Übergeordnete Produktionsarchitektur:

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)

## 2. Kernobjekte und Repräsentationsregel

Mindestens vorgesehen sind `AirbaseState`, `FOBState`, `RedNetworkState`, `RedSiteState`, `StrategicEntity`, `CargoManifest`, `MissionDemand`, `CSARIncident`, `IntelligenceRecord` und `SettlementSupportState`.

```text
CampaignState entity/resource
-> optional MOOSE/DCS representation
-> events and observed result
-> validated strategic settlement
-> persisted CampaignState
```

Laufzeitnamen, MOOSE-Wrapper, DCS-Gruppen und Scheduler sind keine persistenten Primärschlüssel.

## 3. Ressourcen und Persistenz

Strategisch getrennt werden Ressourcen nur, wenn ihre Menge oder Verfügbarkeit spielerische beziehungsweise kampagnenrelevante Wirkung besitzt. `CampaignState` darf nicht durch parallele Bestände in CTLD, MOOSE WAREHOUSE/AIRWING oder DCS Warehouses ersetzt werden.

Der generische Store persistiert insbesondere:

```text
resource quantities
resource reservations / transactions
idempotent resource credits
aircraft-recovery records
```

über `ExportSnapshot()` und `Restore()`.

## 4. CampaignState -> STORAGE

Für die jeweils dokumentierten AirOps-Stände gilt der einseitige Mirror:

```text
CampaignState
-> OMW_CampaignStateStorageSync / resource adapters
-> MOOSE STORAGE
-> DCS Airbase Warehouse
```

`CampaignState` bleibt strategische Autorität; STORAGE-/DCS-Readback wird nicht zur unabhängigen Rückautorität.

## 5. Aircraft-Loss, Forced Landing, Recovery und Repair

Für physisch zerstörte reguläre Campaign-Aircraft gilt:

```text
PHYSICAL_TOTAL_LOSS
-> aircraft lost
-> remaining onboard fuel lost
-> remaining onboard weapons/stores lost
-> no strategic recredit
```

Geplante Außenlandungen müssen von Forced-Landing-Kandidaten getrennt bleiben. Die dokumentierte Recovery-V1-Semantik bleibt:

```text
RECOVERABLE_FORCED_LANDING
-> RECOVERY_IN_PROGRESS
-> fixed recovery delay: 30 minutes
-> recovery complete
-> remaining fuel/stores credited
-> aircraft -> RECOVERED_AWAITING_REPAIR
-> fixed repair lock: 6 hours
-> repair complete -> AVAILABLE
```

Diese 30-min-/6-h-Semantik gehört ausschließlich zum physischen Recovery-/Repair-Modell und **nicht** zum regulären Off-map-AAR-Lifecycle.

## 6. AAR-Off-map-KC-135-Pools

Verbindliche OMW-Designbestände:

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16 count

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40 count
```

Die Pools sind count-basiert. Es gibt in diesem Scope keine strategischen Tail Numbers, keine individuelle KC-135-Entity-Verwaltung, keine strategische per-Template-Bestandsführung und keinen regulären Turnaround-Timer.

Die Knoten `OFFMAP_MANAS` und `OFFMAP_AL_UDEID` sind reine CampaignState-Domänenressourcen, keine DCS-Airbases und keine MOOSE WAREHOUSE/AIRWING-Knoten.

Verfügbarkeitsressource:

```text
resourceId: AIRCRAFT_KC135
unit: count
resourceClass: AIRCRAFT_POOL_STRATEGIC
```

Persistenter Verlust-Audit:

```text
resourceId: AIRCRAFT_KC135_LOST
unit: count
resourceClass: AIRCRAFT_LOSS_AUDIT
initial: 0 per source node
```

`AIRCRAFT_KC135_LOST` ist nur kumulativer Audit-Zähler und keine Verfügbarkeitsquelle.

## 7. AAR-Adaptervertrag

Produktive Grenze:

```text
CanMaterialize(selection)
OnMaterialized(selection, runtime)
OnHandoff(selection, runtime)
OnLost(selection, runtime, reason)
ReconcileRestore()
```

Materialisierung:

```text
CanMaterialize
-> prüft available AIRCRAFT_KC135 im Source-Pool

OnMaterialized
-> ReserveResource exactly 1
-> Consume immediately
-> transactionId = AAR-KC135-COMMIT:<runtimeId>
```

Successful Handoff:

```text
confirmed external handoff
-> CreditResourceOnce 1 AIRCRAFT_KC135
-> creditId = AAR-KC135-HANDOFF:<runtimeId>
-> immediately available again
```

Ein Handoff-Credit setzt einen tatsächlich egressenden physischen Tanker und bestätigten External-Handoff voraus.

Aircraft Loss:

```text
FLIGHTGROUP Dead
-> adapter OnLost
-> commitment remains consumed
-> NO AIRCRAFT_KC135 recredit
-> CreditResourceOnce 1 AIRCRAFT_KC135_LOST
-> creditId = AAR-KC135-LOSS:<runtimeId>
```

Ein Ersatz wird nur materialisiert, wenn der betroffene Track nach seinem Verfügbarkeitsmodell weiterhin benötigt/offen ist.

## 8. AAR-Restore-Reconciliation

`OMW_AAR_RuntimeIntegration.Attach(...)` erhält den bereits erzeugten oder wiederhergestellten einzigen CampaignState-Store. Bei `restored=true` erfolgt `Adapter:ReconcileRestore()` vor neuer AAR-Materialisierung.

Danach startet der Controller **nur die vier STANDARD-Tracks**. Die RESERVE-Tracks `LISA` und `MOE` bleiben ohne MissionDemand unbesetzt.

```text
loss credit exists
-> permanent loss remains
-> no recredit

handoff credit or previous restart credit exists
-> already resolved
-> no duplicate credit

no handoff/loss/restart credit exists
-> pre-restart transient DCS tanker representation no longer exists
-> CreditResourceOnce 1 AIRCRAFT_KC135
-> creditId = AAR-KC135-RESTART:<runtimeId>
-> reason = AAR_RESTART_RECONCILIATION
```

Das letzte Ergebnis behauptet keinen physischen Handoff, sondern reconciled ein flüchtiges Runtime-Commitment im count-basierten No-tail-Modell.

## 9. MissionDemand und AAR-Verfügbarkeit

Die AAR-Betriebsbaseline trennt STANDARD und RESERVE:

```text
STANDARD / bis auf weiteres kontinuierlich:
NELSON FAST
PATTY SLOW
MILHOUSE SLOW
KRUSTY SLOW

RESERVE / nur bei passendem MissionDemand:
LISA FAST
MOE FAST
```

Für STANDARD gilt:

```text
MissionDemand COMPLETE / CANCELLED / ABORTED
-> Demand ownership ends
-> Standard-Track remains active
-> no demand-end egress
```

Für RESERVE gilt:

```text
first matching demand
-> open/materialize reserve track

last matching demand ends
-> stop further relief generation
-> ACTIVE/RELIEF egress
-> confirmed external handoff
-> reserve track unoccupied
```

Die kontinuierliche STANDARD-Verfügbarkeit ist eine vorläufige OMW-Betriebsentscheidung, kein historischer Nachweis einer 24/7-CAS-/AAR-Abdeckung. Eine spätere genehmigte ATO-/Zeitfensterlogik darf sie ersetzen.

## 10. Operative AAR-Concurrency

Die AI-Unterstützungsregel `2/2/4` gilt **nicht** für AAR.

```text
steady state STANDARD = 4 physische KC-135
RESERVE = +1 je geöffnetem Reserve-Track
pro Track maximal 1 ACTIVE + 1 RELIEF
kein globales AAR-Mission-Limit = 2
kein globales AAR-Aircraft-Limit = 4
```

Der 60-s-Materialisierungsabstand gilt innerhalb derselben Source Domain; MANAS und AL UDEID dürfen parallel materialisieren.

## 11. FIR- und External-Handoff-Grenze

Strategisches Settlement bleibt an den technischen External-Handoff gekoppelt, nicht an den FIR-Grenzübertritt.

```text
external spawn
-> FIR ingress fix
-> AAR track
-> FIR egress fix
-> external handoff
-> strategic recredit + despawn
```

Aktuelle Zuordnung:

```text
NELSON/PATTY    -> EGPAN
KRUSTY/MILHOUSE -> DAVER
LISA/MOE        -> PINAX
```

Vollständiges ATS-Airway-Routing ist späterer Scope.

## 12. Produktionskomposition

```text
CampaignState NEW/RESTORE
-> OMW_AirOpsCampaignStateInitializer + AAR strategic stock
-> one authoritative CampaignState store
-> OMW_AAR_RuntimeIntegration
-> OMW_AAR_CampaignStateAdapter
-> OMW_AAR_Controller
-> MOOSE SPAWN / FLIGHTGROUP / AUFTRAG
```

Nicht zulässig für dieselbe Off-map-KC-135-Verfügbarkeit sind parallele MOOSE-WAREHOUSE-/AIRWING-/DCS-Warehouse-/SPAWN-Inventarautoritäten.

## 13. Verifikationsstatus

Acceptance-1/2/3 sind keine final akzeptierten Produktionsbaselines. Der korrigierte nächste gemeinsame Abschlusslauf ist:

```text
AAR-PRODUCTION-FINAL-ACCEPTANCE-4
```

Er prüft die vier STANDARD-Tracks, demand-getriebene LISA/MOE-RESERVE, stabile Callsign-Familien, FIR-Fix-Routing, External-Handoff-Settlement, Scheduled/FuelLow-Relief, Loss und Restore-Reconciliation. Der neue Pfad bleibt bis zum realen dokumentierten DCS-PASS `SOURCE_REVIEWED` / `PLANNED`.

Die konkrete Acceptance-Matrix steht in:

- [`OMW-AAR-ISAF-ACO`](29-isaf-2009-2013-air-to-air-refueling.md)
- [`OMW-TEST-AAR-PRODUCTION-INTEGRATION`](../mission/tests/aar-production-integration/README.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](moose/ISR-FAC-CAS-AAR.md)
