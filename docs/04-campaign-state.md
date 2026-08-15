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

### 8.2 Successful Handoff und Abort

```text
successful mission + confirmed external-gate handoff
OR
abort / demand end + confirmed external-gate handoff
-> CreditResourceOnce 1 AIRCRAFT_KC135
-> creditId = AAR-KC135-HANDOFF:<runtimeId>
-> immediately available again
```

Ohne bestätigten Handoff gibt es keine normale Handoff-Recreditierung.

### 8.3 Aircraft Loss

Der produktive AAR-Controller verwendet den source-reviewed MOOSE-`FLIGHTGROUP`-`Dead`-/`OnAfterDead`-Pfad:

```text
FLIGHTGROUP Dead
-> adapter OnLost
-> commitment remains consumed
-> NO AIRCRAFT_KC135 recredit
-> CreditResourceOnce 1 AIRCRAFT_KC135_LOST
-> creditId = AAR-KC135-LOSS:<runtimeId>
```

Damit sinkt der überlebende strategische Pool permanent um die bereits konsumierte KC-135. Der Loss-Audit wächst genau einmal.

Dieser neue AAR-Loss-Pfad ist implementiert und source-reviewed, aber noch nicht DCS-validiert.

## 9. AAR-Restore-Reconciliation

`OMW_AAR_RuntimeIntegration.Attach(...)` erhält den bereits erzeugten oder wiederhergestellten CampaignState-Store. Es erzeugt **keine zweite CampaignState-Instanz**.

Bei `restored=true` ruft es vor der Controller-Bindung `Adapter:ReconcileRestore()` auf.

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

## 10. Demand-Ende

Der AAR-Controller führt aktive Demands je Area-/Profil-Station. Für `COMPLETE`, `CANCELLED` und `ABORTED` gilt die Eigentümerentscheidung:

```text
if another demand remains on the same station
-> station remains active

if the last demand ends
-> station closes immediately
-> queued relief removed
-> ACTIVE Cancel/Egress
-> RELIEF_INBOUND Cancel/Egress
-> no further relief generation
```

Ein Abort mit später bestätigtem External-Gate-Handoff wird strategisch wie eine reguläre Rückkehr recreditiert. Ohne Handoff und ohne bestätigtes Loss-Event erfolgt keine normale Settlement-Aktion, bis ein definierter Abschluss oder Restore-Reconciliation vorliegt.

## 11. Operative Concurrency

Strategischer Stock und operative Concurrency bleiben getrennte Verantwortungen.

Produktive Limits:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Der AAR-Controller prüft diese Limits vor physischer Materialisierung. Der CampaignState-Adapter prüft **nur** strategische Verfügbarkeit.

Ein Relief gehört zum bereits belegten Station-/Support-Mission-Slot. Ein physisch noch vorhandener Egress-Tanker zählt bis Handoff/Loss gegen das globale Aircraft-Limit.

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

Nicht zulässig für dieselbe Off-map-KC-135-Verfügbarkeit:

```text
parallel MOOSE WAREHOUSE stock
parallel AIRWING stock
parallel DCS Warehouse stock
parallel SPAWN inventory authority
```

## 13. Verifikationstatus

Owner-lokale Source-/Build-Checkpoints bis `354fbbcdfcef7102eb1e9fe7207f97ef473cdc2f` bestätigen die jeweils dokumentierten Git-/Build-/Hash-Stände.

Die danach zusammengeführte Produktionsfinalisierung – Loss, Restore-Reconciliation, RuntimeIntegration und 2/2/4-Concurrency – ist **noch nicht DCS-validiert**. Ein neuer DCS-Integrationslauf benötigt gemäß Governance die ausdrückliche Eigentümerfreigabe.

Die konkrete gemeinsame Acceptance-Matrix steht in:

- [`OMW-AAR-ISAF-ACO`](29-isaf-2009-2013-air-to-air-refueling.md)
- [`OMW-TEST-AAR-PRODUCTION-INTEGRATION`](../mission/tests/aar-production-integration/README.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](moose/ISR-FAC-CAS-AAR.md)
