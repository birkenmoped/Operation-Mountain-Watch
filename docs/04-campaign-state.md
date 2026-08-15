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
  - AAR off-map KC-135 strategic pool semantics
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

DCS-Gruppen, CTLD-Fracht, MOOSE-Warehouses, AIRWING-/SQUADRON-Bestände, Statics und andere Laufzeitobjekte bilden diesen Zustand ab. Sie dürfen ihn nicht unabhängig besitzen oder erhöhen.

Der ursprüngliche Objektentwurf bleibt unverändert erhalten:

- [`Legacy-CampaignState-Grundlage`](evidence/source-records/legacy-04-campaign-state.md)

Übergeordnete Produktionsarchitektur:

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)

## 2. Kernobjekte

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

Jedes Objekt besitzt eine stabile ID, einen Schema- und Zustandsstatus sowie nachvollziehbare Beziehungen zu Ressourcen und Aufträgen.

## 3. Repräsentationsregel

```text
CampaignState entity
→ optional MOOSE/DCS representation
→ events and observed result
→ validated state transition
→ persisted CampaignState
```

Laufzeitnamen oder MOOSE-Wrapper sind keine persistenten Primärschlüssel.

## 4. Ressourcen

Ressourcen werden nur getrennt geführt, wenn sie spielerische oder strategische Wirkung besitzen. Dazu zählen insbesondere:

- Personal;
- Fahrzeuge und Luftfahrzeuge;
- Munition;
- Treibstoff;
- Baumaterial und Versorgungsgüter;
- Cargo-Manifeste;
- Bereitschaft, Schaden und Verluste.

## 5. Persistenz

Gespeichert werden strategische IDs und Domänendaten, nicht flüchtige Controller-, Wrapper- oder Scheduler-Zustände.

Jeder Speicherstand benötigt:

- Schema-Version;
- Kampagnen- und Missionskennung;
- Migrationspfad;
- Integritätsprüfung;
- reproduzierbare Rekonstruktion der zulässigen Laufzeitobjekte.

## 6. DCS-Runtime-Evidenz: CampaignState -> STORAGE Fuel Mirror

Am 10.08.2026 wurde auf `agent/campaignstate-storage-multinode-sync` der bestehende einseitige Fuel-Mirror-Pfad in einer gemeinsamen Sieben-Knoten-Matrix geprüft:

```text
CampaignState
  -> OMW_CampaignStateStorageSync
  -> OMW_StorageFuelAdapter
  -> MOOSE STORAGE
  -> DCS Airbase Warehouse
```

Getesteter Source-/Builder-Stand:

```text
Commit: e54b6c4eba126979a57efdbc86f485cde03f69e5
BuilderVersion: CAMPAIGNSTATE-STORAGE-MULTINODE-1
Bundle SHA-256: 3de006db91bb2888b5e2dd67662eae39454df9a5d2258d57e5ce9008c9f7ff00
DCS: 2.9.28.26385 MT
MOOSE: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Mission filename: OMW_Template_v8_AirOps_rdy.miz
```

Geprüfte operative STORAGE-Endpunkte:

```text
Bagram
Jalalabad
Kandahar
Kandahar Heliport
FOB Salerno
Tarinkot
Shindand Heliport
```

### 6.1 Lauf mit Spieler-Spawn auf Jalalabad

Mit einem OH-58D-Spieler-Spawn auf Jalalabad ergab der Harness:

```text
nodesExpected=7
nodesPassed=6
nodesFailed=1
status=FAIL
```

Nur Jalalabad schlug beim exakten `SetLiquid()`-Readback/Restore fehl. Vor Testbeginn lag dort der native JETFUEL-Bestand bereits bei `99666.309997559 kg` statt `100000 kg`. Die übrigen sechs Knoten bestanden vollständig.

Artifact-Hashes:

```text
DCS log SHA-256: bc21980d05fc08bf9ba91bc53a65d31807705c0b867e9306c29e34c40646cc5a
Debrief SHA-256: 2f91450a0698ed62a7e690186e40d0b8f0ca2e8659a9f45019e311f06554efd8
```

Dieser Lauf belegt eine wichtige Runtime-Grenze: native DCS-Fuelbuchungen eines aktiven Luftfahrzeugs können denselben Warehouse-Bestand während eines streng synchronen Mirror-Write/Readback-Fensters verändern.

### 6.2 Wiederholung ohne Spieler-Spawn

Der unmittelbar folgende Lauf ohne Spieler-Spawn ergab:

```text
nodesExpected=7
nodesPassed=7
nodesFailed=0
status=PASS
direction=CampaignState-to-STORAGE
campaignStateMutation=false
reverseOverwrite=false
persistence=false
automaticAircraftDebit=false
```

Alle sieben Knoten bestanden CampaignState-Snapshot, initialen Plan mit zwei Änderungen, Write/Readback, zweiten Plan mit `changeCount=0`, Idempotenz, fehlende Rückmutation und Restore.

Artifact-Hashes:

```text
DCS log SHA-256: 9f81fef5d283f1ca6b94b72e55e9b258e6cc8680ae01f016ad92e47aade8071b
Debrief SHA-256: 35c3eba64237b24e4210e210f58d7313169ee9da82b6a388bab5cebf39e87ab0
```

### 6.3 Architekturfolgerung

Die strategische Hoheit bleibt unverändert bei `CampaignState`. Der bestätigte Pfad ist ein einseitiger operativer Mirror und kein zweites Ressourcenbuch:

```text
CampaignState resource stock
!= MOOSE WAREHOUSE / AIRWING asset stock
!= MOOSE STORAGE / DCS warehouse liquids/items
```

Die DCS-Runtime-Evidenz bestätigt den technischen Mirror für alle sieben Knoten unter einem ruhigen Sync-Fenster. Sie genehmigt noch keine automatische Produktionsstrategie für konkurrierenden Verbrauch. Insbesondere bleiben Locking, Retry, Toleranz, Event-Buchung, Transaktionsmodell und Reconciliation gesonderte Architekturentscheidungen.

Der Test darf noch nicht als vollständige `ACCEPTED_TECHNICAL_BASELINE` hochgestuft werden, solange der exakte SHA-256 der tatsächlich ausgeführten `.miz` und der darin eingebettete Bundle-Hash für den 7/7-Lauf nicht nachgewiesen sind. Diese Werte dürfen nicht aus älteren Missionen abgeleitet oder geraten werden.

## 7. Aircraft-Loss, Forced Landing, Recovery und Repair

Der Projektinhaber hat am 12.08.2026 folgende CampaignState-Semantik festgelegt.

### 7.1 Physischer Totalverlust

Ein physisch zerstörtes Luftfahrzeug gilt als Totalverlust:

```text
PHYSICAL_TOTAL_LOSS
-> aircraft lost
-> remaining onboard fuel lost
-> remaining onboard weapons/stores lost
-> no strategic recredit
```

Technische Grundlage ist der DCS-Lauf `STORAGE-PHYSICAL-LOSS-RECOVERY-1` auf Branch `agent/storage-physical-loss-recovery`, Commit `5f40fb1e4e97049a6a9c6db57bfa087da7d5df99`. Ein AH-64D-TwoShip wurde über den öffentlichen MOOSE-Pfad `UNIT:Explode(1500)` physisch zerstört. Das Debrief führte zwei AH-64D im Graveyard; danach wurden weder zwei Aircraft-Items, 2280 kg JETFUEL noch M151, AGM-114K oder IAFS recreditiert.

```text
Bundle SHA-256: 3236db339aff985eb493c81d87d72089744d06c123bef56e6e4eb4ffb33a5587
MIZ SHA-256: 11e4651368be6cbcfd2f9d200621fe62e9a9da93d9776ca4b04269425a896ba4
dcs.log SHA-256: 7e0a835ee2ca3061d22ae9f68ef923f47dda48c0cef50fa86dd876f1bbf9362b
debrief.log SHA-256: 803fa74793e53df44fbe4b55a636a5a354ca3ba4e06f750b20b6c03b51c3c22a
```

Der frühere `OPSGROUP:Destroy()`-Pfad bleibt ein technischer UnitLost-/Despawn-Lifecycle und darf nicht als physischer Totalverlust interpretiert werden.

### 7.2 Forced-Landing-Klassifikation

`Landed` oder `airbase == nil` allein ist kein Verlustsignal. Geplante Außenlandungen, insbesondere Transport- und `LANDATCOORDINATE`-Aufträge, müssen ausgeschlossen werden.

Vorgesehene Domain-Klassifikation:

```text
planned off-field landing / planned transport landing
-> NORMAL

unexpected landing at or within 5 km of recovery-capable friendly aviation infrastructure
-> RECOVERABLE_FORCED_LANDING

unexpected landing outside that envelope
-> OFF_FIELD_UNRECOVERABLE candidate
```

Recovery-capable sind nur ausdrücklich als solche geführte freundliche Airbases, Heliports und FARPs mit realistisch ausreichender Aviation-/Bergungsinfrastruktur. Ein gewöhnliches FOB/COP ohne entsprechende Strukturen genügt nicht.

Sehr niedriger Fuel-Stand ist ein zusätzliches starkes Evidenzsignal. Für die spätere Implementierung ist `<= 5 %` verbleibender Fuel als Forced-Landing-Indikator vorgesehen, aber nicht als alleiniger Trigger. Ejection-/Crew-Verhalten ist bei DCS-Helicoptern nicht einheitlich und darf ebenfalls nicht allein entscheiden.

### 7.3 Recovery V1

```text
RECOVERABLE_FORCED_LANDING
-> RECOVERY_IN_PROGRESS
-> fixed recovery delay: 30 minutes
-> no aircraft/fuel/store credit during recovery
-> recovery complete:
   remaining fuel and remaining stores are credited immediately
   physical aircraft representation is removed as recovered
   aircraft -> RECOVERED_AWAITING_REPAIR
-> fixed repair lock: 6 hours
-> repair complete -> AVAILABLE
```

Es werden keine eigenen Schadensstufen, Repair-Prozente oder DCS-Health-to-Repair-Konvertierungen eingeführt.

### 7.4 Nicht bergbare Außenlandung

```text
OFF_FIELD_UNRECOVERABLE
-> aircraft, remaining fuel and remaining stores lost
-> surviving crew should use existing MOOSE CSAR/AICSAR capabilities where applicable
-> avoid duplicate survivor creation when native ejection already produced a case
-> delayed aircraft destruction target: 5-10 minutes after confirmed unrecoverable landing
```

Die konkrete Forced-Landing-Erkennung, CSAR-Kopplung und verzögerte Zerstörung sind noch nicht implementiert oder DCS-validiert.

### 7.5 Spätere Gameplay-Erweiterung

Eine umkämpfte Recovery-Site mit optionalem Sicherungsauftrag von maximal etwa 30 Minuten bleibt als spätere V2-Erweiterung vorgesehen. Die aktuelle Foundation-V1 verwendet zunächst nur die abstrakte Recovery-Zeit und die anschließende Repair-Sperre.

## 8. AAR-Off-map-KC-135-Pools

### 8.1 Eigentümerentscheidung und Bestand

Für OMW gelten folgende strategische Designbestände:

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40
```

Die Zahlen sind plausible OMW-Kompositbestände und keine Behauptung einer historisch exakt zugewiesenen Stärke. Die historische Evidenz und die ausgewerteten Satelliten-Snapshots sind in [`OMW-AAR-ISAF-ACO`](29-isaf-2009-2013-air-to-air-refueling.md) dokumentiert.

Die AAR-Pools werden bewusst **count-basiert** geführt. Es gibt für diesen Scope keine strategischen Tail Numbers, keine individuelle KC-135-Entity-Verwaltung und keine per-Template-Bestandsführung.

### 8.2 Strategische Autorität und Off-map-Knoten

Die Pools sind reine CampaignState-Domänenressourcen. Sie werden nicht als DCS-Airbase, MOOSE WAREHOUSE oder AIRWING modelliert.

Der Initializer `OMW_AirOpsCampaignStateInitializer` führt dafür die logischen Knoten:

```text
OFFMAP_MANAS
OFFMAP_AL_UDEID
```

Da `OMW_CampaignState.lua` im aktuellen Schema für jeden Resource-Node noch ein nichtleeres Feld `airbaseName` verlangt, verwendet der Initializer dort ausdrücklich gekennzeichnete **logische Labels**. Diese Labels sind keine DCS-Airbase-Namen und dürfen niemals an `AIRBASE`, `WAREHOUSE`, `AIRWING` oder andere DCS-/MOOSE-Airbasepfade übergeben werden.

```text
CampaignState Off-map Pool
-> OMW AAR CampaignState Adapter
-> MOOSE SPAWN at external gate
-> FLIGHTGROUP
-> AUFTRAG
-> mission / relief lifecycle
-> external gate / off-map handoff
-> immediate CampaignState recredit
```

### 8.3 Resource Contract

Produktiv implementierte Ressource:

```text
resourceId: AIRCRAFT_KC135
unit: count
resourceClass: AIRCRAFT_POOL_STRATEGIC
```

Initialwerte:

```text
OFFMAP_MANAS    = 16
OFFMAP_AL_UDEID = 40
```

Die Daten liegen in `scripts/logistics/OMW_AARStrategicStock.lua`. Der Initializer kann diesen Stock gemeinsam mit weiteren zusätzlichen Stock-Modulen in denselben CampaignState-Startzustand komponieren.

### 8.4 Adaptervertrag

Der Controller verwendet die bestehende Grenze:

```text
CanMaterialize(selection)
OnMaterialized(selection, runtime)
OnHandoff(selection, runtime)
```

`scripts/air-operations/OMW_AAR_CampaignStateAdapter.lua` bindet diese Grenze an die vorhandene generische CampaignState-Transaktions-API.

Verbindliche Semantik:

```text
CanMaterialize
-> prüft available AIRCRAFT_KC135 im zugeordneten Off-map-Pool

OnMaterialized
-> reserviert genau 1 AIRCRAFT_KC135
-> konsumiert die Reservierung unmittelbar
-> transactionId = AAR-KC135-COMMIT:<runtimeId>

successful off-map handoff
-> CreditResourceOnce genau 1 AIRCRAFT_KC135
-> creditId = AAR-KC135-HANDOFF:<runtimeId>
-> Maschine ist sofort wieder als Poolkapazität verfügbar
```

Die Runtime-ID dient ausschließlich Transaktionskorrelation und Exactly-once-Buchung. Sie ist **keine strategische Tail Number**.

### 8.5 Kein regulärer AAR-Turnaround-Timer

Für diese Off-map-Pools gilt ausdrücklich **kein** separater regulärer Turnaround-/Repair-Timer:

```text
materialized tanker
-> available count - 1

successful return through external gate
-> available count + 1 immediately
```

Die in Abschnitt 7 beschriebene Forced-Landing-Recovery-/Repair-Semantik bleibt davon getrennt. Sie darf nicht auf reguläre Off-map-AAR-Rückkehr übertragen werden.

Damit kann bei ausreichendem Poolbestand ein zurückgekehrter Tanker unmittelbar wieder als abstrakte Poolkapazität für eine spätere Ablösung zur Verfügung stehen.

### 8.6 Verlust und Abbruch

Ein Tanker wird nur bei bestätigtem Off-map-Handoff recreditiert. Erreicht eine physische Tankerrepräsentation den Handoff nicht, erfolgt über `OnHandoff` keine Rückbuchung.

```text
successful mission / abort with confirmed off-map handoff
-> immediate recredit

aircraft loss / no confirmed handoff
-> no recredit
```

Ein expliziter produktiver Aircraft-loss-Callback des AAR-Controllers ist in diesem Stand noch nicht integriert. Bis dahin ist die strategische Kerneigenschaft dennoch fail-safe: Ohne erfolgreichen Handoff bleibt die beim Materialisieren konsumierte Einheit aus dem verfügbaren Pool entfernt. Die eindeutige Verlustklassifikation und das zugehörige Logging müssen vor vollständiger Runtime-Acceptance ergänzt beziehungsweise geprüft werden.

### 8.7 Persistenz und Reconciliation

CampaignState persistiert Ressourcenstände, Transaktionen und idempotente Resource-Credits in `ExportSnapshot()`/`Restore()`. Dadurch sind sowohl konsumierte KC-135-Commitments als auch bereits erfolgte Handoff-Credits grundsätzlich Bestandteil des persistierten strategischen Zustands.

Noch nicht DCS-validiert beziehungsweise abschließend reconciled ist der Neustartfall, in dem ein Snapshot während einer noch existierenden physischen AAR-Repräsentation entsteht. Vor produktiver Acceptance muss deshalb geprüft werden, dass Restore und physische Rekonstruktion weder Doppelmaterialisierung noch Doppelcredit erzeugen.

### 8.8 Trennung von operativer Concurrency und strategischem Bestand

Der strategische Bestand `16/40` ist kein Spawnlimit. Die operative AAR-Concurrency bleibt eine separate Missionsregel:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Der CampaignState-Adapter besitzt diese Missionsregel nicht ein zweites Mal. Er entscheidet ausschließlich, ob aus dem jeweiligen strategischen Pool noch mindestens eine KC-135 verfügbar ist.
