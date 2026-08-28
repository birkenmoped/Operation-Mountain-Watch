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
source_branch: main
source_commit: 2e9cbe6104f2e23bc3031821459e1f16309a946b
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

Mindestens vorgesehen:

- `AirbaseState`;
- `FOBState`;
- `RedNetworkState` und `RedSiteState`;
- `StrategicEntity`;
- `CargoManifest`;
- `MissionDemand`;
- `CSARIncident`;
- `IntelligenceRecord`;
- `SettlementSupportState`.

Verbindliche Grenze:

```text
CampaignState entity/resource
-> optional MOOSE/DCS representation
-> events and observed result
-> validated strategic settlement
-> persisted CampaignState
```

Laufzeitnamen, MOOSE-Wrapper, DCS-Gruppen und Scheduler sind keine persistenten Primärschlüssel.

## 3. Ressourcen

Strategisch getrennt werden Ressourcen nur, wenn ihre Menge oder Verfügbarkeit spielerische beziehungsweise kampagnenrelevante Wirkung besitzt. Dazu gehören insbesondere:

- Personal;
- Fahrzeuge und Luftfahrzeuge;
- Munition;
- Treibstoff;
- Baumaterial und Versorgungsgüter;
- Cargo-Manifeste;
- Bereitschaft, Schaden und Verluste.

`CampaignState` darf nicht durch parallele Bestände in CTLD, MOOSE WAREHOUSE/AIRWING oder DCS Warehouses ersetzt werden.

## 4. Persistenz

Gespeichert werden strategische IDs und Domänendaten, nicht flüchtige Controller-/Wrapper-Zustände.

Jeder Speicherstand benötigt:

- Schema-Version;
- Kampagnen- und Missionskennung;
- Migrationspfad;
- Integritätsprüfung;
- reproduzierbare Rekonstruktion beziehungsweise Reconciliation zulässiger Runtime-Objekte.

Der aktuelle generische Store persistiert insbesondere:

```text
resource quantities
resource reservations / transactions
idempotent resource credits
aircraft-recovery records
```

über `ExportSnapshot()` und `Restore()`.

## 5. CampaignState -> STORAGE

Die dokumentierten AirOps-Tests bestätigen den einseitigen Mirror:

```text
CampaignState
-> OMW_CampaignStateStorageSync / resource adapters
-> MOOSE STORAGE
-> DCS Airbase Warehouse
```

für den jeweils exakt dokumentierten Teststand. `CampaignState` bleibt dabei strategische Autorität; der DCS-/STORAGE-Readback wird nicht zur unabhängigen Rückautorität.

Der erfolgreiche ruhige Sieben-Knoten-Lauf vom 10.08.2026 bestätigte Bagram, Jalalabad, Kandahar, Kandahar Heliport, FOB Salerno, Tarinkot und Shindand Heliport für den dokumentierten Mirror-Scope. Ein vorheriger Lauf mit aktivem Spieler-Spawn zeigte zugleich, dass native DCS-Fuelbuchungen ein streng synchrones Write/Readback-Fenster verändern können. Diese Evidenz genehmigt keine zweite strategische Ressourcenhoheit.

## 6. Aircraft-Loss, Forced Landing, Recovery und Repair

### 6.1 Physischer Totalverlust

Für physisch zerstörte reguläre Campaign-Aircraft gilt:

```text
PHYSICAL_TOTAL_LOSS
-> aircraft lost
-> remaining onboard fuel lost
-> remaining onboard weapons/stores lost
-> no strategic recredit
```

Die technische Grundlage ist der dokumentierte `STORAGE-PHYSICAL-LOSS-RECOVERY-1`-Owner-Lauf. `OPSGROUP:Destroy()` beziehungsweise bloßes Despawn ist nicht automatisch mit physischem Totalverlust gleichzusetzen.

### 6.2 Forced-Landing-Klassifikation

`Landed` oder `airbase == nil` allein ist kein Verlustsignal. Geplante Außenlandungen müssen ausgeschlossen werden.

Vorgesehene Domain-Klassifikation:

```text
planned off-field landing / planned transport landing
-> NORMAL

unexpected landing at or within 5 km of recovery-capable friendly aviation infrastructure
-> RECOVERABLE_FORCED_LANDING

unexpected landing outside that envelope
-> OFF_FIELD_UNRECOVERABLE candidate
```

Sehr niedriger Fuel-Stand (`<= 5 %`) ist nur ein zusätzliches Evidenzsignal, kein alleiniger Trigger.

### 6.3 Recovery V1

Für die bereits definierte **Forced-Landing-Recovery** gilt weiterhin:

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

### 6.4 Nicht bergbare Außenlandung

```text
OFF_FIELD_UNRECOVERABLE
-> aircraft, remaining fuel and remaining stores lost
-> CSAR/AICSAR only where applicable and without duplicate survivor creation
```

Die konkrete Forced-Landing-Erkennung und CSAR-Kopplung sind gesonderter Scope.

## 7. AAR-Off-map-KC-135-Pools

### 7.1 Eigentümerentscheidung

Verbindliche OMW-Designbestände:

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16 count

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40 count
```

Diese Pools sind bewusst count-basiert. Es gibt in diesem Scope:

```text
keine strategischen Tail Numbers
keine individuelle KC-135-Entity-Verwaltung
keine strategische per-Template-Bestandsführung
keinen regulären Turnaround-Timer
```

Die historische Plausibilisierung steht in [`OMW-AAR-ISAF-ACO`](29-isaf-2009-2013-air-to-air-refueling.md).

### 7.2 Off-map-Knoten

Die Knoten sind reine CampaignState-Domänenressourcen:

```text
OFFMAP_MANAS
OFFMAP_AL_UDEID
```

Sie sind keine DCS-Airbases und besitzen kein MOOSE WAREHOUSE/AIRWING.

`OMW_AirOpsCampaignStateInitializer` verwendet wegen des aktuellen generischen Node-Schemas ausdrücklich gekennzeichnete logische `airbaseName`-Labels. Diese Labels dürfen niemals an DCS-/MOOSE-Airbase-, WAREHOUSE- oder AIRWING-APIs übergeben werden.

### 7.3 Ressourcenvertrag

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

`AIRCRAFT_KC135_LOST` ist ein **kumulativer Audit-Zähler**. Er ist keine Verfügbarkeitsquelle und wird von `CanMaterialize()` nicht ausgewertet.

Die Daten liegen in `scripts/logistics/OMW_AARStrategicStock.lua`.

## 8. AAR-Adaptervertrag

Produktive Grenze:

```text
CanMaterialize(selection)
OnMaterialized(selection, runtime)
OnHandoff(selection, runtime)
OnLost(selection, runtime, reason)
ReconcileRestore()
```

Implementierung:

- `scripts/air-operations/OMW_AAR_CampaignStateAdapter.lua`
- `scripts/air-operations/OMW_AAR_RuntimeIntegration.lua`

### 8.1 Materialisierung

```text
CanMaterialize
-> prüft available AIRCRAFT_KC135 im Source-Pool

OnMaterialized
-> ReserveResource exactly 1
-> Consume immediately
-> transactionId = AAR-KC135-COMMIT:<runtimeId>
```

Die `runtimeId` ist ausschließlich technische Korrelations-/Exactly-once-ID, keine strategische Tail Number.

### 8.2 Successful Handoff

```text
confirmed external handoff
-> CreditResourceOnce 1 AIRCRAFT_KC135
-> creditId = AAR-KC135-HANDOFF:<runtimeId>
-> immediately available again
```

Für STANDARD-Tracks löst MissionDemand-Ende keinen Handoff aus. Für RESERVE-Tracks ordnet das Ende des letzten zugehörigen Demands Egress an; der Recredit erfolgt trotzdem ausschließlich nach bestätigtem External-Handoff des tatsächlich egressenden Tankers.

Ohne bestätigten External-Handoff gibt es keine normale Handoff-Recreditierung.

### 8.3 Aircraft Loss

Der produktive AAR-Controller verwendet den in `AAR-PRODUCTION-FINAL-ACCEPTANCE-5` validierten MOOSE-`FLIGHTGROUP`-`Dead`-/`OnAfterDead`-Pfad:

```text
FLIGHTGROUP Dead
-> adapter OnLost
-> commitment remains consumed
-> NO AIRCRAFT_KC135 recredit
-> CreditResourceOnce 1 AIRCRAFT_KC135_LOST
-> creditId = AAR-KC135-LOSS:<runtimeId>
```

Damit sinkt der überlebende strategische Pool permanent um die bereits konsumierte KC-135. Der Loss-Audit wächst genau einmal. Ein Ersatz wird nur materialisiert, wenn der Track nach seinem Verfügbarkeitsmodell weiterhin benötigt beziehungsweise offen ist.

## 9. AAR-Restore-Reconciliation

`OMW_AAR_RuntimeIntegration.Attach(...)` erhält den bereits erzeugten oder wiederhergestellten CampaignState-Store. Es erzeugt **keine zweite CampaignState-Instanz**.

Bei `restored=true` ruft es vor der Controller-Bindung `Adapter:ReconcileRestore()` auf. Nach der Adapterbindung startet der Controller ausschließlich die vier STANDARD-Tracks; `LISA` und `MOE` bleiben als RESERVE ohne MissionDemand unbesetzt.

Reconciliation für konsumierte AAR-Commitments:

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

Das dritte Ergebnis behauptet **keinen physischen Handoff**. Es ist die deterministische strategische Reconciliation des count-basierten No-tail-Modells nach Mission-/Serverrestart.

Grenze:

```text
physical loss
-> server failure before Dead/OnLost was persisted
-> snapshot contains no proof of that loss
-> restore cannot reconstruct an unpersisted physical fact
```

Ohne per-tail persistente Runtime-Identität kann dieser Fall nicht nachträglich beweissicher unterschieden werden. OMW führt für den beschlossenen AAR-Scope bewusst kein per-tail-Modell ein.

## 10. MissionDemand-Ende

MissionDemand und Track-Verfügbarkeit sind getrennt.

STANDARD:

```text
NELSON / PATTY / MILHOUSE / KRUSTY

MissionDemand COMPLETE / CANCELLED / ABORTED
-> demand ownership removed from matched track
-> STANDARD track remains active
-> no demand-end egress
-> no demand-end handoff/recredit
```

RESERVE:

```text
LISA / MOE

first matching demand
-> reserve track opens/materializes

last matching demand COMPLETE / CANCELLED / ABORTED
-> no further relief generation
-> active/relief tanker egresses
-> recredit only after confirmed external handoff
-> reserve track becomes unoccupied
```

Eine spätere genehmigte ATO-/Zeitfensterlogik darf die STANDARD-Verfügbarkeit oberhalb des Tanker-Lifecycles steuern. Die aktuelle kontinuierliche STANDARD-Abdeckung ist eine vorläufige OMW-Betriebsentscheidung und kein historischer 24/7-Nachweis.

## 11. Operative AAR-Concurrency

Strategischer Stock und operative AAR-Concurrency bleiben getrennte Verantwortungen.

Die für bestimmte AI-Unterstützungsmissionen bekannte `2/2/4`-Begrenzung gilt **nicht** für AAR.

Produktiv gilt bis auf weiteres:

```text
STANDARD / kontinuierlich:
NELSON     FAST
PATTY      SLOW
MILHOUSE   SLOW
KRUSTY     SLOW

RESERVE / MissionDemand:
LISA       FAST
MOE        FAST

kein globales AAR-Mission-Limit = 2
kein globales AAR-Aircraft-Limit = 4

pro Track maximal:
1 ACTIVE
1 RELIEF
```

Normalzustand der STANDARD-Abdeckung sind damit vier physische KC-135. Jeder geöffnete RESERVE-Track ergänzt einen Tanker; eine kurzzeitige Doppelbesetzung ist nur für ACTIVE+RELIEF desselben Tracks vorgesehen.

Der 60-s-Materialisierungsabstand innerhalb derselben Source Domain bleibt eine separate Spawn-/Sichtbarkeitsregel; MANAS und AL UDEID dürfen parallel materialisieren.

## 12. FIR versus External Handoff

Die strategische Ressourcenbuchung unterscheidet FIR-Grenzübertritt und technischen Off-map-Handoff:

```text
External Spawn
-> FIR Ingress Fix
-> AAR Track
-> FIR Egress Fix
-> External Handoff
-> exact-once recredit + despawn
```

Aktuelle FIR-Fix-Zuordnung:

```text
NELSON / PATTY    -> EGPAN
KRUSTY / MILHOUSE -> DAVER
LISA / MOE        -> PINAX
```

Der FIR-Egress allein recreditiert keine KC-135. Vollständiges Lower-/Upper-Airway-Routing bleibt späterer Scope.

## 13. Produktionskomposition

```text
CampaignState NEW/RESTORE
-> OMW_AirOpsCampaignStateInitializer + AAR strategic stock
-> one authoritative CampaignState store
-> OMW_AAR_RuntimeIntegration
-> OMW_AAR_CampaignStateAdapter
-> OMW_AAR_Controller
-> MOOSE SPAWN / FLIGHTGROUP / AUFTRAG
```

Nicht zulässig für dieselbe Off-map-KC-135-Verfügbarkeit:

```text
parallel MOOSE WAREHOUSE stock
parallel AIRWING stock
parallel DCS Warehouse stock
parallel SPAWN inventory authority
```

## 14. Verifikationsstatus

Der kombinierte AAR-Abschlusslauf `AAR-PRODUCTION-FINAL-ACCEPTANCE-5` ist für den exakt dokumentierten Stand akzeptiert:

```text
Acceptance commit: 5e7dbec37f53155f39c63c25590cf6b4e35814ca
Mission SHA-256: c9e3978a4bbb35ebbfe5ae362021b5f8870129d6c8b06b58147424dde71a94e3
Bundle SHA-256: f33b0a5a6212d9a1103dfa2e0ab677777142ca771a2f5007a3ab1c7fee594cbf
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

Damit sind für diesen Acceptance-Scope insbesondere Restore-Reconciliation, exact-once Handoff-Recredit, Loss ohne Recredit plus Loss-Audit, Standard-/Reserve-Lifecycle, Scheduled Relief und FuelLow praktisch bestätigt.

Die vollständige Acceptance-Matrix und Provenienz stehen in:

- [`OMW-AAR-ISAF-ACO`](29-isaf-2009-2013-air-to-air-refueling.md)
- [`OMW-TEST-AAR-PRODUCTION-INTEGRATION`](../mission/tests/aar-production-integration/README.md)
- [`OMW-TEST-AAR-PRODUCTION-ACCEPTANCE-5`](../mission/tests/aar-production-integration/ACCEPTANCE-5.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](moose/ISR-FAC-CAS-AAR.md)
